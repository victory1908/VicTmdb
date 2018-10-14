//
//  UIAlertController+Msg.swift
//  VicTmdb
//
//  Created by victory1908 on 12/10/18.
//  Copyright © 2018 victory1908. All rights reserved.
//
import UIKit
extension UIAlertController {
    func show() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIViewController()
        window.windowLevel = UIWindow.Level.alert
        window.makeKeyAndVisible()
        window.rootViewController?.present(self, animated: false, completion: nil)
    }
    static func show(in viewController: UIViewController?, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        if viewController?.presentedViewController == nil {
            viewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    static func createAlert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        return alert
    }
}
