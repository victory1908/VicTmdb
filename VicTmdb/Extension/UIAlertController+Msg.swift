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
}
