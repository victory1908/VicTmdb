//
//  Photo.swift
//  VicTmdb
//
//  Created by victory1908 on 7/10/18.
//  Copyright © 2018 victory1908. All rights reserved.
//

import Foundation
import RxDataSources

struct Movie: Codable {
    // Required
    let id: Int
    let title: String
    
    // Optionals
    let overview: String?
    let posterPath: String?
    let releaseDate: String?
    let status: String?
    
    func posterUrl(size: Constant.Size) -> URL? {
        return URL(string: "\(Constant.imageUrlString)\(size.rawValue)\(self.posterPath ?? "")")
    }
    
    init(id: Int, title: String, overview: String? = nil, posterPath: String? = nil, releaseDate: String? = nil, status: String? = nil) {
        self.id = id
        self.title = title
        self.overview = overview
        self.posterPath = posterPath
        self.releaseDate = releaseDate
        self.status = status
    }
    
    // MARK: Codable Protocol
    enum CodingKeys : String, CodingKey {
        case id
        case title
        case releaseDate = "release_date"
        case status
        case posterPath = "poster_path"
        case overview
    }
    
}

extension Movie: Equatable {
    static func ==(lhs: Movie, rhs: Movie) -> Bool {
        return lhs.id == rhs.id // For now id comparision is enough
    }
}

extension Movie: Hashable {
    static func union (left: [Movie],right: [Movie] ) -> [Movie]{
        return Array(Set(left).union(Set(right)))
    }
    
}

extension Movie:IdentifiableType {
    typealias Identity = Int

    var identity: Identity {
        return id
    }
}


