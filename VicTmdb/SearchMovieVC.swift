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

class SearchMovieVC: UIViewController  {
    
    // Private
    private let disposeBag = DisposeBag()
    private var searchController: UISearchController!
    private weak var refreshControl: UIRefreshControl!
    private var activityView: UIActivityIndicatorView!
    
    private let dataSource = MovieDatasource()
    fileprivate lazy var scheduler: SchedulerType! = MainScheduler.instance
    
    // Public
    var viewModel = SearchMovieViewModel(service: PhotoService.shared)
    var searchBar: UISearchBar { return searchController.searchBar }
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            
//            let flowLayout = UICollectionViewFlowLayout()
//            let width = (collectionView.frame.size.width - CGFloat(100)) / CGFloat(1)
//            let height = (collectionView.frame.size.height - CGFloat(50)) / CGFloat(1)
//            flowLayout.itemSize = CGSize(width: width, height: height)
//            collectionView.setCollectionViewLayout(flowLayout, animated: true)
            
            
            collectionView.keyboardDismissMode = .onDrag
        }
    }
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchController()
        setupRefreshControl()
        setupActivityIndicator()
        bindRx()
    }
    
}
// MARK:- Layout Configuration
fileprivate extension SearchMovieVC {
    func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        
        let searchBar = searchController.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search Movies"
        
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = searchController
            searchController.hidesNavigationBarDuringPresentation = true
        } else {
            // Fallback on earlier versions
            self.navigationItem.titleView = searchBar
        }

        
//        self.navigationItem.titleView = searchBar
        
        self.definesPresentationContext = true
    }
    
    func setupRefreshControl() {
        let rc = UIRefreshControl()
        rc.backgroundColor = .clear
        rc.tintColor = .lightGray
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = rc
        } else {
            // Fallback on earlier versions
            collectionView.addSubview(rc)
        }
        refreshControl = rc
    }
    
    func setupActivityIndicator() {
        activityView = UIActivityIndicatorView(style: .whiteLarge)
        activityView.color = UIColor.blue
        activityView.center = view.center
        view.addSubview(activityView)
    }
}

extension SearchMovieVC {
    func bindRx() {
        
        let searchClick = searchBar.rx.textDidEndEditing
            .withLatestFrom(searchBar.rx.text.orEmpty)
            .throttle(0.3, scheduler: scheduler)
//            .distinctUntilChanged()
            .share()
        
        searchClick
//            .throttle(0.3, scheduler: scheduler)
//            .distinctUntilChanged()
            .bind(to: viewModel.search)
            .disposed(by: disposeBag)
        
        collectionView.rx.reachedBottom
            .debounce(0.1, scheduler: scheduler)
            .bind(to:viewModel.loadMore)
            .disposed(by: disposeBag)
        let movies = viewModel.results.asObservable().share()
        movies
            .map { [Group<Movie>(header: "", items: $0)] }
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
//        searchClick
//            .withLatestFrom(movies)
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
        
        showActivity.asDriver(onErrorJustReturn: false)
                    .drive(activityView.rx.isAnimating)
                    .disposed(by: disposeBag)
        
    }
}
