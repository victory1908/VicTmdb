//
//  FirstViewController.swift
//  VicTmdb
//
//  Created by victory1908 on 7/10/18.
//  Copyright © 2018 victory1908. All rights reserved.
//

import UIKit
import RxSwift

class PopularMovieVC: UIViewController {

    // Public
    @IBOutlet weak var collectionView: UICollectionView!
    private var activityView: UIActivityIndicatorView!
    
    // Private
    var viewModel: PopularMovieViewModel!
    private let disposeBag = DisposeBag()
    private weak var refreshControl: UIRefreshControl!
    private let dataSource = MovieDatasource()
    private let flowLayoutNew = FlowLayout()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupRefreshControl()
        setupActivityIndicator()
        bindRx()
    }
}

// MARK:- Layout Configuration
extension PopularMovieVC {
    
    func setupCollectionView() {
        collectionView.collectionViewLayout = flowLayoutNew
        collectionView.keyboardDismissMode = .onDrag
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

extension PopularMovieVC {
    func bindRx() {
        collectionView.rx.reachedBottom
            .throttle(0.1, scheduler: MainScheduler.instance)
            .withLatestFrom(viewModel.isLoading.asObservable().filter{!$0}.map{_ in Void()})
            .bind(to:viewModel.loadMore)
            .disposed(by: disposeBag)
    
        refreshControl.rx.controlEvent(.valueChanged)
            .bind(to: viewModel.refresher)
            .disposed(by: disposeBag)
        viewModel.results.asObservable()
            .map { [Group<Movie>(header: "", items: $0)] }
            .do(onNext: { [unowned self] _ in
                self.refreshControl.endRefreshing()
            })
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        showActivity.asDriver(onErrorJustReturn: false)
            .drive(activityView.rx.isAnimating)
            .disposed(by: disposeBag)
        
    }
}

