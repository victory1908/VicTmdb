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
    let provider = MoyaProvider<TMDB>()
//    init(provider: MoyaProvider<TMDB>) {
//        self.provider = provider
//    }
    
    func searchMovie(query: String, page: Int) -> Single<[Movie]> {
        return provider.rx
            .request(.searchMovie(query: query, page: page + 1))
            .retry(3)
//            .do(onSuccess: { resp in
//                if page.value > 0 { return }
//                do {
//                    let decoder = JSONDecoder()
//                    let data = try decoder.decode(ApiResponse.self, from: resp.data)
//                    totalPages.value = data.totalPages
//                } catch {
//                    print(error.localizedDescription)
//                }
//            })
            .map([Movie].self, atKeyPath: "results")
    }
    
    func popularMovie(page: Int) -> Single<[Movie]> {
        return provider.rx
            .request(.popularMovie(page: page + 1))
            .retry(3)
            .map([Movie].self, atKeyPath: "results")
    }
    
}
