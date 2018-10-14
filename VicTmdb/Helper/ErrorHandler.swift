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
    
    static var error = PublishSubject<String>()
    
    static func handleError (error: Error) {
        if error is MoyaError {
            switch error as! MoyaError {
            case .imageMapping:
                ErrorHandler.error.onNext("imageMapping error")
            case .jsonMapping:
                ErrorHandler.error.onNext("jsonMapping error")
            case .statusCode:
                ErrorHandler.error.onNext("statusCode error")
            case .stringMapping:
                ErrorHandler.error.onNext("stringMapping error")
            case .objectMapping:
                ErrorHandler.error.onNext("objectMapping error")
            case .encodableMapping:
                ErrorHandler.error.onNext("encodableMapping error")
            case .underlying:
                ErrorHandler.error.onNext("Network error")
            case .requestMapping:
                ErrorHandler.error.onNext("requestMapping error")
            case .parameterEncoding:
                ErrorHandler.error.onNext("parameterEncoding error")
            }
        }else {
            ErrorHandler.error.onNext(error.localizedDescription)
        }
    }
    enum VicTmdbError: Error {
        case moyaError(error: MoyaError)
        case unknownError
        case connectionError
        case invalidCredentials
        case invalidRequest
        case notFound
        case invalidResponse
        case serverError
        case serverUnavailable
        case timeOut
        case unsuppotedURL
    }
}
