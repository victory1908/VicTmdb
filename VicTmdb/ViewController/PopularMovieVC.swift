//
//  FirstViewController.swift
//  VicTmdb
//
//  Created by victory1908 on 7/10/18.
//  Copyright © 2018 victory1908. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

class PopularMovieVC: UIViewController {

    // Public
    @IBOutlet weak var collectionView: UICollectionView!
    private var activityView: UIActivityIndicatorView!
    
    // Private
    var viewModel: PopularMovieViewModel!
    private let disposeBag = DisposeBag()
    private weak var refreshControl: UIRefreshControl!
    private let movieDataSource = RxCollectionViewSectionedAnimatedDataSource<Group<Movie>>(configureCell: { (ds, cv, ip, movie) -> MovieCell in
        let cell = cv.dequeueReusableCell(withReuseIdentifier: Constant.movieCellidentifier, for: ip) as! MovieCell
        cell.configure(forItem: movie)
        return cell
    })
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
            .throttle(2, scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(viewModel.loadMore)
            .disposed(by: disposeBag)
    
        refreshControl.rx.controlEvent(.valueChanged)
            .asDriver(onErrorJustReturn: ())
            .drive(viewModel.refresher)
            .disposed(by: disposeBag)
        viewModel.results
            .map { [Group<Movie>(header: "", items: $0)] }
            .do(onNext: { [weak self] _ in
                self?.refreshControl.endRefreshing()
            })
            .drive(collectionView.rx.items(dataSource: movieDataSource))
            .disposed(by: disposeBag)
        
        showActivity.asDriver(onErrorJustReturn: false)
            .drive(activityView.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel.errorMessage.asObservable().share()
                .throttle(2, scheduler: MainScheduler.instance)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: {[weak self] errorMsg in
                    UIAlertController.show(in: self, title: "Error", message: errorMsg)
                })
                .disposed(by: disposeBag)
        
    }
}

