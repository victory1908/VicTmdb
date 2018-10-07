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
    var viewModel: PopularMovieViewModel = PopularMovieViewModel(service: PhotoService())
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.keyboardDismissMode = .onDrag
            
            let flowLayout = UICollectionViewFlowLayout()
            let width = (collectionView.frame.size.width - CGFloat(100)) / CGFloat(1)
            let height = (collectionView.frame.size.height - CGFloat(50)) / CGFloat(1)
            flowLayout.itemSize = CGSize(width: width, height: height)
            collectionView.setCollectionViewLayout(flowLayout, animated: true)
            
        }
    }
    
    // Private
    private let disposeBag = DisposeBag()
    private weak var refreshControl: UIRefreshControl!
    private weak var noResultsLabel: UILabel!
    private let dataSource = MovieDatasource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRefreshControl()
        setupNoResults()
        bindRx()
    }

}

// MARK:- Layout Configuration
extension PopularMovieVC {
    
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
    
    func setupNoResults() {
        let label = UILabel()
        label.text = "No Movies Found!"
        label.sizeToFit()
        label.isHidden = true
        collectionView.backgroundView = label
        noResultsLabel = label
    }
}

fileprivate extension PopularMovieVC {
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

extension UIStoryboard {
    var popularMovieListViewController: PopularMovieVC {
        guard let vc = self.instantiateViewController(withIdentifier: Constant.popularVCidentifier) as? PopularMovieVC else {
            fatalError("PopularMovieVC couldn't be found in Storyboard file")
        }
        return vc
    }
}

