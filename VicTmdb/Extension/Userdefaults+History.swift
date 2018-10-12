//
//  Userdefault+History.swift
//  VicTmdb
//
//  Created by victory1908 on 8/10/18.
//  Copyright © 2018 victory1908. All rights reserved.
//

import Foundation
import RxSwift

extension UserDefaults {
    
    static let historyKey = "searchHistory"
    static var history = [String]()
    
    static func save() {
        UserDefaults.standard.set(history, forKey: historyKey)
    }
    
    
    static func fetch() -> [String] {
        if let hitoryArray = UserDefaults.standard.object(forKey: historyKey) as? [String] {
            history = hitoryArray
        }
        return history
    }
    
    static func add(text: String) -> [String]{
        if !history.contains(text) {
            if history.count < 10 {
                history.append(text)
            }else {
                history.removeFirst()
                history.append(text)
            }
        }
        self.save()
        return history
    }
    
}
