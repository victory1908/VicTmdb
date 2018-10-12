//
//  UIStoryboard+Additions.swift
//  victory1908
//
//

import UIKit.UIStoryboard
import RxSwift

extension UIStoryboard {
    static var main: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
    
    func searchMovieVC(_ scheduler: SchedulerType? = nil) -> SearchMovieVC {
        let identifier = Constant.searchMovieVCidentifier
        guard let vc = self.instantiateViewController(withIdentifier: identifier) as? SearchMovieVC
            else {
                fatalError("SearchMovieVC couldn't be found in Storyboard file")
        }
        return vc
    }
    
    func popularMovieVC() -> PopularMovieVC {
        let identifier = Constant.popularVCidentifier
        guard let vc = self.instantiateViewController(withIdentifier: identifier) as? PopularMovieVC
            else {
                fatalError("PopularMovieVC couldn't be found in Storyboard file")
        }
        return vc
    }
    
}
