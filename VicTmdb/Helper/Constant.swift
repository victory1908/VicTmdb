//
//  Constant.swift
//  VicTmdb
//
//  Created by victory1908 on 7/10/18.
//  Copyright © 2018 victory1908. All rights reserved.
//

import Foundation

struct Constant {
    static let ApiKey = "58da429caf2e25e8ff9436665e2f0e36"
    static let ApiUrlString = "https://api.themoviedb.org/3"
    static let imageUrlString = "https://image.tmdb.org/t/p/w500"
    static let defaultParams:[String : Any] = [
    "api_key": Constant.ApiKey
    ]
    static let photoCellidentifier = "photoCell"
    static let popularVCidentifier = "PopularMovieVC"
}
