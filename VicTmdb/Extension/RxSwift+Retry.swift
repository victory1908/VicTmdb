//
//  RxSwift+Retry.swift
//  VicTmdb
//
//  Created by victory1908 on 12/10/18.
//  Copyright © 2018 victory1908. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


extension ObservableType {
    /// Retries the source observable sequence on error using a provided retry
    /// strategy.
    /// - parameter maxAttemptCount: Maximum number of times to repeat the
    /// sequence. `Int.max` by default.
    /// - parameter didBecomeReachable: Trigger which is fired when network
    /// connection becomes reachable.
    /// - parameter shouldRetry: Always retruns `true` by default.
    func retrySmart(_ maxAttemptCount: Int = Int.max,
               delay: DelayOptions,
               didBecomeReachable: Signal<Void> = Reachability.shared.didBecomeReachable,
               shouldRetry: @escaping (Error) -> Bool = { _ in true }) -> Observable<Element> {
        return retryWhen { (errors: Observable<Error>) in
            return errors.enumerated().flatMap { attempt, error -> Observable<Void> in
                guard shouldRetry(error), maxAttemptCount > attempt + 1 else {
                    return .error(error)
                }
                
//                let timer = Observable<Int>.timer(
//                    RxTimeInterval(delay.make(attempt + 1)),
//                    scheduler: MainScheduler.instance
//                    ).map { _ in () } // cast to Observable<Void>
//                return Observable.merge(timer, didBecomeReachable.asObservable())
                let timer = Observable<Int>.timer(
                    .seconds(attempt + 1),
                    scheduler: MainScheduler.instance
                    ).map { _ in () } // cast to Observable<Void>
                return Observable.merge(timer, didBecomeReachable.asObservable())
            }
        }
    }
}

enum DelayOptions {
    case immediate
    case constant(time: Double)
    case exponential(initial: Double, multiplier: Double, maxDelay: Double)
    case custom(closure: (Int) -> Double)
}

extension DelayOptions {
    func make(_ attempt: Int) -> Double {
        switch self {
        case .immediate: return 0.0
        case .constant(let time): return time
        case .exponential(let initial, let multiplier, let maxDelay):
            // if it's first attempt, simply use initial delay, otherwise calculate delay
            let delay = attempt == 1 ? initial : initial * pow(multiplier, Double(attempt - 1))
            return min(maxDelay, delay)
        case .custom(let closure): return closure(attempt)
        }
    }
}
