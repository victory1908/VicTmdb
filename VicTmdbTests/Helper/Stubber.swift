//
//  Stubber.swift
//  VicTmdbUITests
//
//  Created by victory1908 on 7/10/18.
//  Copyright © 2018 victory1908. All rights reserved.
//

import Foundation

class Stubber {
    class func jsonDataFromFile(_ fileName: String) -> Data {

        guard let path = Bundle.main.path(forResource: fileName, ofType: "json") else {
            fatalError("Invalid path for file")
        }
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            fatalError("Invalid json file")
        }
        return data
    }
}
