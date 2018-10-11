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
//import RxMoya

struct PhotoService {
    static let shared = PhotoService()
    let provider = TMDBprovider
    
    func searchMovie(query: String, page: Int) -> Single<[Movie]> {
        return provider.rx
            .request(.searchMovie(query: query, page: page + 1))
            .retry(3)
            .map([Movie].self, atKeyPath: "results")
    }
    
    func popularMovie(page: Int) -> Single<[Movie]> {
        return provider.rx
            .request(.popularMovie(page: page + 1))
            .retry(3)
            .map([Movie].self, atKeyPath: "results")
    }
    
}
