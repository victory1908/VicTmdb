//
//  SearchMovieViewModel.swift
//  VicTmdb
//
//  Created by victory1908 on 8/10/18.
//  Copyright © 2018 victory1908. All rights reserved.
//

import Moya
import RxSwift
import RxCocoa

class SearchMovieViewModel {
    
    // Inputs
    var refresher = PublishSubject<Void>()
    var search = PublishSubject<String>()
    var loadMore = PublishSubject<Void>()
    var cancelClick = PublishSubject<Void>()
    var historyClick = PublishSubject<String>()
    
    // Outputs
    let results: Driver<[Movie]>
    let currentPage: Driver<Int>
    var seachHistory: Driver<[String]>
    var isLoading: Driver<Bool>
    let errorMessage: PublishSubject<String>
    let noResult: PublishSubject<Bool>
    
    
    // Private
    private let query: BehaviorRelay<String>
    private let pageNo: BehaviorRelay<Int>
    private let totalPages: BehaviorRelay<Int>
    private let movies: BehaviorRelay<[Movie]>
    private let service: MovieService
    private let history: BehaviorRelay<[String]>
    private let isLoadingRelay: BehaviorRelay<Bool>
    
    init(service: MovieService) {
        self.service = service
        
        let query = BehaviorRelay<String>(value: "")
        self.query = query
        
        let pageNo = BehaviorRelay<Int>(value: 0)
        self.pageNo = pageNo
        self.currentPage = pageNo.asObservable()
            .share()
            .asDriver(onErrorJustReturn: -1)
        
        let totalPages = BehaviorRelay<Int>(value: 100)
        self.totalPages = totalPages
        
        let movies = BehaviorRelay<[Movie]>(value: [])
        self.movies = movies
        
        self.errorMessage = service.errorMessage
        
        let noResult = PublishSubject<Bool>()
        self.noResult = noResult
        noResult.onNext(false)
        
        let history = BehaviorRelay<[String]>(value: UserDefaults.fetch())
        self.history = history
        self.seachHistory = history.asDriver(onErrorJustReturn: UserDefaults.fetch())
        
        let isLoadingRelay = BehaviorRelay<Bool>(value: false)
        self.isLoadingRelay = isLoadingRelay
        self.isLoading = isLoadingRelay.asDriver()
        
        let refresh = refresher.asObservable()
            .do(onNext: {
                pageNo.accept(0)
            })
        
        let keyword = search.asDriver(onErrorJustReturn: "")
            .filter{!$0.isEmpty}
            .do(onNext: {
                query.accept($0)
                pageNo.accept(0)
            })
            .map { _ in () }
        
        let loadNext = loadMore.asObservable()
            .filter{!query.value.isEmpty}
            .filter { _ in pageNo.value < totalPages.value }
            .filter{_ in return isLoadingRelay.value == false}
            .do(onNext: { _ in
                pageNo.accept(pageNo.value + 1)
            })
        
        let selectedHistory = historyClick.asObservable()
            .do(onNext: { selectedHistory in
                pageNo.accept(0)
                query.accept(selectedHistory)
            })
            .map{_ in () }
        
        
        let request = Observable.of(keyword.asObservable(),loadNext,refresh,selectedHistory)
            .merge()
            .share()
            .asDriver(onErrorDriveWith: Driver.empty())
        
        results = request
            .do(onNext:{
                isLoadingRelay.accept(true)
            })
            .flatMap { _ in return
                service.searchMovie(query: query.value, page: pageNo.value + 1)
                    .asDriver(onErrorJustReturn: ([],0))
            }
            .do(onNext: {
                if $0.0.count != 0 {
                    history.accept(UserDefaults.add(text: query.value))
                }
                
                if pageNo.value == 0 {
                    movies.accept($0.0)
                }
                else {
                    movies.accept(Movie.union(left: movies.value, right: $0.0))
                }

                totalPages.accept($0.1)

                if pageNo.value == 0 && $0.0.count == 0 {
                    noResult.onNext(true)
                    print("go here?")
                }

                isLoadingRelay.accept(false)
            })
            .flatMap { _ in movies.asDriver() }
    
    }
    
}
