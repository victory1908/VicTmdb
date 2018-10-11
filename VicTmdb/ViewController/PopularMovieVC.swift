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
    
    // Private
    var viewModel: PopularMovieViewModel = PopularMovieViewModel(service: PhotoService.shared)
    private let disposeBag = DisposeBag()
    private weak var refreshControl: UIRefreshControl!
    private let dataSource = MovieDatasource()
    
    private let flowLayoutNew = FlowLayout()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        if #available(iOS 11.0, *) {
//            navigationController?.navigationBar.prefersLargeTitles = true
//        }
        
        setupCollectionView()
        setupRefreshControl()
        bindRx()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        DispatchQueue.main.async {
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
}

// MARK:- Layout Configuration
extension PopularMovieVC {
    
    func setupCollectionView() {
        
        
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .always
        } else {
            // Fallback on earlier versions
            automaticallyAdjustsScrollViewInsets = true
        }
        
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
}

extension PopularMovieVC {
    func bindRx() {
        collectionView.rx.reachedBottom
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
    }
}

