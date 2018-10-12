//
//  SearchMovieVC.swift
//  VicTmdb
//
//  Created by victory1908 on 8/10/18.
//  Copyright © 2018 victory1908. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
import RxKeyboard

class SearchMovieVC: UIViewController,UITableViewDelegate  {
    
    // MARK: Private
    @IBOutlet weak var collectionView: UICollectionView!

    private let disposeBag = DisposeBag()
    private var searchController: UISearchController!
    private var activityView: UIActivityIndicatorView!
    private var searchHistoryTV: UITableView!
    private let movieDataSource = MovieDatasource()
    private let searchDataSource = SearchDatasource()
    private let flowLayoutNew = FlowLayout()
    private lazy var scheduler: SchedulerType! = MainScheduler.instance
    
    // Mark: Public
    var viewModel: SearchMovieViewModel!
    private var searchBar: UISearchBar { return searchController.searchBar }
    
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupSearchController()
        setupActivityIndicator()
        setUpSearchHistory()
        bindRx()
    }
    
}

// MARK:- Layout Configuration

fileprivate extension SearchMovieVC {
    
    func setupCollectionView() {
        collectionView.collectionViewLayout = flowLayoutNew
        collectionView.keyboardDismissMode = .onDrag
    }
    
    func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true

        let searchBar = searchController.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search Movies"
        
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            self.navigationItem.titleView = searchBar
        }
        self.definesPresentationContext = true
    }
    
    func setupActivityIndicator() {
        activityView = UIActivityIndicatorView(style: .whiteLarge)
        activityView.color = UIColor.blue
        activityView.center = view.center
        view.addSubview(activityView)
    }
    
    func setUpSearchHistory() {
        let frame = CGRect(x: 0, y: searchBar.frame.height, width: searchBar.frame.width, height: view.frame.size.height)
        searchHistoryTV = UITableView(frame: frame, style: .plain)
        searchHistoryTV.register(UITableViewCell.self, forCellReuseIdentifier: Constant.searchCell)
        searchHistoryTV.rx.setDelegate(self).disposed(by: disposeBag)
        searchHistoryTV.isUserInteractionEnabled = true
        view.addSubview(searchHistoryTV)
        searchHistoryTV.isHidden = true
    }
    
}

extension SearchMovieVC {
    func bindRx() {
        
        let searchClick = searchBar.rx.textDidEndEditing.withLatestFrom(searchBar.rx.text.orEmpty)
        
        collectionView.rx.reachedBottom
            .debounce(0.1, scheduler: scheduler)
            .throttle(0.1, scheduler: scheduler)
            .bind(to:viewModel.loadMore)
            .disposed(by: disposeBag)
        let movies = viewModel.results.asObservable().share()
        
        movies
            .map { [Group<Movie>(header: "", items: $0)] }
            .bind(to: collectionView.rx.items(dataSource: movieDataSource))
            .disposed(by: disposeBag)
        
        movies
            .filter{$0.count == 0}
            .debounce(0.3, scheduler: scheduler)
            .subscribe({_ in
                let alert = UIAlertController(title: "OOPs", message: "No film found. Please try another name", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                alert.show()
            })
            .disposed(by: disposeBag)
        
        viewModel.seachHistory.map{[Group<String>(header: "", items: $0)]}
                .drive(searchHistoryTV.rx.items(dataSource: searchDataSource))
                .disposed(by: disposeBag)
        
        RxKeyboard.instance.visibleHeight
            .drive(onNext: { keyboardVisibleHeight in
                self.searchHistoryTV.contentInset.bottom = keyboardVisibleHeight
            })
            .disposed(by: disposeBag)
        
        searchBar.rx.textDidBeginEditing.subscribe(onNext: {
            self.searchHistoryTV.isHidden = false
        }).disposed(by: disposeBag)
        
        searchBar.rx.textDidEndEditing.subscribe(onNext: {
            self.searchHistoryTV.isHidden = true
        }).disposed(by: disposeBag)
        
        let historyClick = searchHistoryTV.rx.modelSelected(String.self).map{$0}.do(onNext: {
            self.searchBar.text = $0
            self.searchHistoryTV.isHidden = true
            self.searchBar.resignFirstResponder()
        })
        
        Observable.of(searchClick,historyClick).merge().debounce(0.3, scheduler: scheduler)
            .withLatestFrom(viewModel.isLoading.filter{!$0}, resultSelector: {query, _ in return query })
            .filter{!$0.isEmpty}
            .bind(to: viewModel.search)
            .disposed(by: disposeBag)
        
        showActivity.asDriver(onErrorJustReturn: false)
                    .drive(activityView.rx.isAnimating)
                    .disposed(by: disposeBag)
        
    }
}

