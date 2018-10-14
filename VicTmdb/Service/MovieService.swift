//
//  PhotoService.swift
//  VicTmdb
//
//  Created by victory1908 on 7/10/18.
//  Copyright © 2018 victory1908. All rights reserved.
//

import Foundation
import Moya
import RxSwift

struct MovieService {

    let provider: MoyaProvider<TMDB>
    
    var errorMessage = PublishSubject<String>()
    
    init(provider: MoyaProvider<TMDB>) {
        self.provider = provider
    }
    
    func searchMovie(query: String, page: Int) -> Observable<([Movie],totalPages: Int)> {
        return provider.rx
            .request(.searchMovie(query: query, page: page + 1))
            .asObservable()
            .retrySmart(3, delay: DelayOptions.constant(time: 1))
            .map(ApiResponse.self)
            .map{($0.results,$0.totalPages)}
            .do(onError: {ErrorHandler.handleError(error: $0)})
    }
    
    func popularMovie(page: Int) -> Observable<[Movie]> {
        return provider.rx
            .request(.popularMovie(page: page + 1))
            .asObservable()
            .retrySmart(3, delay: DelayOptions.constant(time: 1))
            .map(ApiResponse.self)
            .map{$0.results}
            .do(onError: {ErrorHandler.handleError(error: $0)})
//            .catchError({ (error) in
//                if let error = error as? MoyaError {
//                    let errorMsg = ErrorHandler.handleError(error: error)
//                    self.errorMessage.onNext(errorMsg)
//                }
//                return Observable.just([])
//            })
    }
    
}
