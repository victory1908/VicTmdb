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
    
    // Private
    @IBOutlet weak var collectionView: UICollectionView!

    private let disposeBag = DisposeBag()
    private var searchController: UISearchController!
    private weak var refreshControl: UIRefreshControl!
    private var activityView: UIActivityIndicatorView!
    private var searchHistoryTV: UITableView!
    private let movieDataSource = MovieDatasource()
    private let searchDataSource = SearchDatasource()
    private let flowLayoutNew = FlowLayout()


    lazy var scheduler: SchedulerType! = MainScheduler.instance

    
    // Public
    var viewModel = SearchMovieViewModel(service: PhotoService.shared)
    var searchBar: UISearchBar { return searchController.searchBar }
    
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if #available(iOS 11.0, *) {
//            navigationItem.largeTitleDisplayMode = .never
//        }
//        self.navigationItem.title = "RxMovie123"
        
        setupCollectionView()
        setupSearchController()
//        setupRefreshControl()
        setupActivityIndicator()
        setUpSearchHistory()
        bindRx()
    }
    
    override func viewDidLayoutSubviews() {
//        searchController.searchBar.showsCancelButton = false
    }
    override func viewDidAppear(_ animated: Bool) {
//        searchBar.becomeFirstResponder()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
//        DispatchQueue.main.async {
//            self.collectionView.collectionViewLayout.invalidateLayout()
//        }
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
    

    
//    func setupRefreshControl() {
//        let rc = UIRefreshControl()
//        rc.backgroundColor = .clear
//        rc.tintColor = .lightGray
//        if #available(iOS 10.0, *) {
//            collectionView.refreshControl = rc
//        } else {
//            // Fallback on earlier versions
//            collectionView.addSubview(rc)
//        }
//        refreshControl = rc
//    }
    
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
                print("get here?")
                let alert = UIAlertController(title: "OOPs", message: "No film found. Please try another name", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)

                self.present(alert, animated: true, completion: nil)
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
            print("history click at \($0)")
            self.searchBar.text = $0
            self.searchHistoryTV.isHidden = true
            self.searchBar.resignFirstResponder()
        })
        

//        let eventSwitch = BehaviorSubject(value: Observable
//            .of(searchClick,historyClick)
//            .merge()
//            .debounce(0.3, scheduler: scheduler)
//        )
//        let events = eventSwitch.switchLatest()


//        let test = Observable.of(searchClick,historyClick).merge().debounce(0.3, scheduler: scheduler).share()
//        let eventSwitch = BehaviorSubject(value: test)
//        let events = eventSwitch.switchLatest()
//        events.bind(to: viewModel.search)
//            .disposed(by: disposeBag)
        
//        searchBar.rx.cancelButtonClicked.subscribe({_ in
////            eventSwitch.onNext(Observable.empty())
//             eventSwitch.onNext(test)
//        }).disposed(by: disposeBag)
        
//        let eventSwitch = BehaviorSubject.create(test)
        
//        events
        Observable.of(searchClick,historyClick).merge().debounce(0.3, scheduler: scheduler)
//                    .takeUntil(searchBar.rx.cancelButtonClicked)
//                    .takeWhile(searchBar.isFirstResponder)
                    .bind(to: viewModel.search)
                    .disposed(by: disposeBag)
//
////        searchBar.rx.cancelButtonClicked.subscribe({_ in
////            eventSwitch.onNext(test)
////        })
        
        showActivity.asDriver(onErrorJustReturn: false)
                    .drive(activityView.rx.isAnimating)
                    .disposed(by: disposeBag)
        
    }
}

