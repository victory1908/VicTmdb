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
    private weak var refreshControl: UIRefreshControl!

    private let disposeBag = DisposeBag()
    private var searchController: UISearchController!
    private var activityView: UIActivityIndicatorView!
    private var searchHistoryTV: UITableView!
    private let movieDataSource = RxCollectionViewSectionedAnimatedDataSource<Group<Movie>>(configureCell: { (ds, cv, ip, item) -> MovieCell  in
        let cell = cv.dequeueReusableCell(withReuseIdentifier: Constant.movieCellidentifier, for: ip) as! MovieCell
        cell.configure(forItem: item)
        return cell
    })
    private let searchDataSource = RxTableViewSectionedAnimatedDataSource<Group<String>>(
        configureCell: { (ds, tv, ip, item) -> UITableViewCell  in
            let cell = tv.dequeueReusableCell(withIdentifier: Constant.searchCell, for: ip)
            cell.textLabel?.text = item
            return cell
    })
    
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
        setupRefreshControl()
        setUpSearchHistory()
        bindRx()
    }
    
}

// MARK:- Layout Configuration

fileprivate extension SearchMovieVC {
    
    func setupCollectionView() {
        collectionView.collectionViewLayout = flowLayoutNew
        collectionView.keyboardDismissMode = .onDrag
        
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .always
        } else {
            // Fallback on earlier versions
            automaticallyAdjustsScrollViewInsets = true
        }
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
        self.searchController.definesPresentationContext = true
    }
    
    func setupActivityIndicator() {
        activityView = UIActivityIndicatorView(style: .whiteLarge)
        activityView.color = UIColor.blue
        activityView.center = view.center
        view.addSubview(activityView)
    }
    
    func setupRefreshControl() {
        let rc = UIRefreshControl()
        rc.backgroundColor = .clear
        rc.tintColor = .lightGray
        collectionView.addSubview(rc)
        refreshControl = rc
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
        
        collectionView.rx.reachedBottom
            .throttle(2, scheduler: scheduler)
            .asDriver(onErrorJustReturn: ())
            .drive(viewModel.loadMore)
            .disposed(by: disposeBag)
        
        viewModel.results
            .map { [Group<Movie>(header: "", items: $0)] }
            .do(onNext: { [weak self] _ in
                self?.refreshControl.endRefreshing()
            })
            .drive(collectionView.rx.items(dataSource: movieDataSource))
            .disposed(by: disposeBag)
        
        viewModel.seachHistory.map{[Group<String>(header: "", items: $0)]}
                .drive(searchHistoryTV.rx.items(dataSource: searchDataSource))
                .disposed(by: disposeBag)
        
        RxKeyboard.instance.visibleHeight
            .drive(onNext: { [weak self] keyboardVisibleHeight in
                    self?.searchHistoryTV.contentInset.bottom = keyboardVisibleHeight
            })
            .disposed(by: disposeBag)

        searchBar.rx.textDidBeginEditing.map{_ in false}.asDriver(onErrorJustReturn: true).drive(searchHistoryTV.rx.isHidden)
            .disposed(by: disposeBag)

        searchBar.rx.textDidEndEditing.map{_ in true}.asDriver(onErrorJustReturn: true).drive(searchHistoryTV.rx.isHidden)
                .disposed(by: disposeBag)
        
        let historyClick = searchHistoryTV.rx.modelSelected(String.self)
            .map{$0}.share()
        
        historyClick.subscribe(onNext: {[weak self] history in
            self?.searchBar.text = history
            self?.searchHistoryTV.isHidden = true
            self?.searchBar.resignFirstResponder()
        }).disposed(by: disposeBag)
        
        historyClick.bind(to: viewModel.historyClick)
            .disposed(by: disposeBag)
        
        searchBar.rx.searchButtonClicked
            .withLatestFrom(searchBar.rx.text.orEmpty.filter{!$0.isEmpty})
            .filter{!$0.isEmpty}
            .bind(to: viewModel.search)
            .disposed(by: disposeBag)
        
        showActivity.asDriver(onErrorJustReturn: false)
                    .drive(activityView.rx.isAnimating)
                    .disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged)
            .asDriver(onErrorJustReturn: ())
            .drive(viewModel.refresher)
            .disposed(by: disposeBag)
        
    }
}

