//
//  AppDelegateSpec.swift
//  VicTmdbTests
//
//  Created by victory1908 on 11/10/18.
//  Copyright © 2018 victory1908. All rights reserved.
//

import Quick
import Nimble

@testable import VicTmdb

class AppDelegateSpec: QuickSpec {
    override func spec() {
        describe("App Delegate") {
            var sut: AppDelegate!
            
            beforeEach {
                sut = UIApplication.shared.delegate as? AppDelegate
            }
            afterEach {
                sut = nil
            }
            
            context("after application launched") {
                it("sets application's window and makes it key and visible") {
                    expect(sut.window).notTo(beNil())
                    expect(sut.window?.isKeyWindow).to(beTruthy())
                    expect(sut.window?.isHidden).to(beFalsy())
                }
                it("sets window's rootviewcontroller with four tabs") {
                    let rvc = sut.window!.rootViewController
                    expect(rvc).notTo(beNil())
                    expect(rvc).to(beAnInstanceOf(UITabBarController.self))
                    expect(rvc?.children.count) == 2
                }
            }
        }
    }
}
