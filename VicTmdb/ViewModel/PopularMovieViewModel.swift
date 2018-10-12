//
//  PopularMovieViewModel.swift
//  VicTmdb
//
//  Created by victory1908 on 7/10/18.
//  Copyright © 2018 victory1908. All rights reserved.
//

import Moya
import RxSwift
import RxCocoa

final class PopularMovieViewModel {
    
    // Inputs
    var refresher = PublishSubject<Void>()
    var loadMore = PublishSubject<Void>()
    
    // Outputs
    var results : Driver<[Movie]> = Driver.just([])
    var currentPage: Driver<Int> = Driver.just(0)
    var isLoading: Driver<Bool> {
        return self.isLoadingRelay.asDriver()
    }
    
    // Private
    private let pageNo = BehaviorRelay<Int>(value: 0)
    private let movies = BehaviorRelay<[Movie]>(value: [])
    private let service: MovieService
    
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    
    init(service: MovieService) {
        self.service = service
        bindRx()
    }
    
    func bindRx(){
        self.currentPage = self.pageNo.asObservable()
            .share()
            .asDriver(onErrorJustReturn: -1)
        
        let refresh = refresher.asObservable()
            .startWith(())
            .do(onNext: {
                self.pageNo.accept(0)
            })
        
        let loadNext = loadMore.asObservable()
            .do(onNext: { _ in
                self.pageNo.accept(self.pageNo.value + 1)
            })
        
        let request = Observable.of(refresh,loadNext)
            .merge()
            .share()
            .asDriver(onErrorDriveWith: Driver.empty())
        
        results = request
            .do(onNext: {
                self.isLoadingRelay.accept(true)
            })
            .flatMap { _ in
                return self.service.popularMovie(page: self.pageNo.value + 1)
                    .asDriver(onErrorJustReturn: [])
            }.do(onNext: {
                if self.pageNo.value == 0 {
                    self.movies.accept($0)
                }
                else {
                    self.movies.accept(self.movies.value + $0)
                }
                self.isLoadingRelay.accept(false)
            })
            .flatMap { _ in self.movies.asDriver() }
    }
    
}
