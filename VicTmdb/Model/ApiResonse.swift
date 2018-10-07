//
//  Resonse.swift
//  VicTmdb
//
//  Created by victory1908 on 7/10/18.
//  Copyright © 2018 victory1908. All rights reserved.
//

import Foundation

struct ApiResponse: Codable {
    let totalPages: Int
    let results: [Movie]
    
    enum CodingKeys : String, CodingKey {
        case totalPages = "total_pages"
        case results
    }
}
