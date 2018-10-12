//
//  Reachability.swift
//  VicTmdb
//
//  Created by victory1908 on 12/10/18.
//  Copyright © 2018 victory1908. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import RxCocoa


final class Reachability {
    static var shared: Reachability {
//        return AppContainer.shared.reachability
        return Reachability()
    }
    
    /// Monitors general network reachability.
    let reachability = NetworkReachabilityManager()
    
    var didBecomeReachable: Signal<Void> { return _didBecomeReachable.asSignal() }
    private let _didBecomeReachable = PublishRelay<Void>()
    
    init() {
//        self.isReachable = _isReachable.asDriver()
        if let reachability = self.reachability {
            reachability.listener = { [weak self] in
                self?.update($0)
            }
            reachability.startListening()
        }
    }
    
    private func update(_ status: NetworkReachabilityManager.NetworkReachabilityStatus) {
        if case .reachable = status {
            _didBecomeReachable.accept(())
        }
    }
}
