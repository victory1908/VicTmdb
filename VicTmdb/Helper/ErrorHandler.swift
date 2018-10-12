//
//  ErrorHandler.swift
//  VicTmdb
//
//  Created by victory1908 on 12/10/18.
//  Copyright © 2018 victory1908. All rights reserved.
//

import Foundation

import Moya
import RxSwift
struct ErrorHandler {
    
    static var errorObserver: Observable<String> = Observable.create { (observer) -> Disposable in
        
        return Disposables.create()
    }
    
    static func handleError (moyaError: MoyaError) -> String {
        switch moyaError {
        case .imageMapping:
            return "imageMapping error"
        case .jsonMapping:
            return "jsonMapping error"
        case .statusCode:
            return "statusCode error"
        case .stringMapping:
            return "stringMapping error"
        case .objectMapping:
            return("objectMapping error")
        case .encodableMapping:
            return "encodableMapping error"
        case .underlying:
            return "Network error"
        case .requestMapping:
            return "requestMapping error"
        case .parameterEncoding:
            return "parameterEncoding error"
        }
    }
    
    static func displayErrorMsg(in viewcontroller: UIViewController, message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        if viewcontroller.presentedViewController == nil{
            alert.show()
        }
    }
}
