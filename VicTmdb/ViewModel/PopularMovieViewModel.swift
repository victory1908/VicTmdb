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
    let results: Driver<[Movie]>
    let currentPage: Driver<Int>
    
    // Private
    private let pageNo: BehaviorRelay<Int>
    private let movies: BehaviorRelay<[Movie]>
    private let service: PhotoService
    
    init(service: PhotoService) {
        self.service = service
        
        let pageNo = BehaviorRelay<Int>(value: 0)
        self.pageNo = pageNo
        self.currentPage = pageNo.asObservable()
            .share()
            .asDriver(onErrorJustReturn: -1)
        
        let movies = BehaviorRelay<[Movie]>(value: [])
        self.movies = movies
        
        let refresh = refresher.asObservable()
            .startWith(())
            .do(onNext: {
                pageNo.accept(0)
            })
        
        let loadNext = loadMore.asObservable()
            .do(onNext: { _ in
                pageNo.accept(pageNo.value + 1)
            })
        
        let request = Observable.of(refresh,loadNext)
            .merge()
            .share()
            .asDriver(onErrorDriveWith: Driver.empty())
        
        results = request
            .flatMap { _ in
                return service.popularMovie(page: pageNo.value + 1)
                    .asDriver(onErrorJustReturn: [])
            }.do(onNext: {
                if pageNo.value == 0 {
                    movies.accept($0)
                }
                else {
                    movies.accept(movies.value + $0)
                }
            })
            .flatMap { _ in movies.asDriver() }
    }
    
}
