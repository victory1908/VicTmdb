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
    var search = PublishSubject<String>()
    var loadMore = PublishSubject<Void>()
    
    // Outputs
    let results: Driver<[Movie]>
    let currentPage: Driver<Int>
//    let noResult: Driver<Void>
    
    // Private
    private let query: BehaviorRelay<String>
    private let pageNo: BehaviorRelay<Int>
    private let totalPages: BehaviorRelay<Int>
    private let movies: BehaviorRelay<[Movie]>
    private let service: PhotoService
    
    let test = BehaviorRelay<String>(value: "test")
    
    init(service: PhotoService) {
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
        
        let keyword = search.asDriver(onErrorJustReturn: "")
            .do(onNext: {
                query.accept($0)
                pageNo.accept(0)
            })
            .map { _ in () }
        
        let loadNext = loadMore.asObservable()
            .filter { _ in pageNo.value < totalPages.value }
            .do(onNext: { _ in
                pageNo.accept(pageNo.value + 1)
            })
        
        let request = Observable.of(keyword.asObservable(),loadNext)
            .merge()
            .share()
            .asDriver(onErrorDriveWith: Driver.empty())
        
        results = request
            .flatMap { _ in return
                service.searchMovie(query: query.value, page: pageNo.value + 1).asDriver(onErrorJustReturn: [])}
            .do(onNext: {
                print($0.count)
                
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

//fileprivate extension SearchMovieViewModel {
//    
//    struct ListAPIResponse: Codable {
//        let totalPages: Int
//        let results: [Movie]
//        
//        enum CodingKeys : String, CodingKey {
//            case totalPages = "total_pages"
//            case results
//        }
//    }
//}
