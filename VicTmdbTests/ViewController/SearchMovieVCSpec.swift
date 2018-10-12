//
//  MovieListViewControllerSpec.swift
//  eigamiTests
//
//  Created by aarif on 2018/03/10.
//  Copyright © 2018 Aarif Sumra. All rights reserved.
//

import Quick
import Nimble
import Moya
import RxSwift
import RxTest
import RxCocoa

@testable import VicTmdb

class SearchMovieVCSpec: QuickSpec {
    override func spec() {
        describe("List of Movie") {
            var sut: SearchMovieVC!
            
            context("after view did load") {
                describe("Layout") {
                    beforeEach {
                        sut = UIStoryboard.main.searchMovieVC()
                    
                        let stubProvider = MoyaProvider<TMDB>(stubClosure: MoyaProvider.immediatelyStub)
                        let stubService = MovieService(provider: stubProvider)
                        sut.viewModel = SearchMovieViewModel(service: stubService)
                        _ = sut.view
                    }
                    afterEach {
                        sut = nil
                    }
                    it("has a search bar in navigation item to search for movies") {
                        if #available(iOS 11, *) {
                            expect(sut.navigationItem.searchController).notTo(beNil())
                        }else{
                            expect(sut.navigationItem.titleView).to(beAnInstanceOf(UISearchBar.self))
                        }
                        
                    }
                    it("has a collection view") {
                        expect(sut.collectionView).notTo(beNil())
                    }
                }
                describe("Behaviour") {
                    context("When entered or changed text in searchbar") {
                        var scheduler: TestScheduler!
//                        var disposeBag: DisposeBag!
                        beforeEach {
                            scheduler = TestScheduler(initialClock: 0, resolution: 1/1000)
                            SharingScheduler.mock(scheduler: scheduler) {
                                sut = UIStoryboard.main.searchMovieVC(scheduler)
                                let stubProvider = MoyaProvider<TMDB>(stubClosure: MoyaProvider.immediatelyStub)
                                let stubService = MovieService(provider: stubProvider)
                                sut.viewModel = SearchMovieViewModel(service: stubService)
                                _ = sut.view
//                                disposeBag = DisposeBag()
                            }
                        }
                        afterEach {
                            scheduler = nil
                            sut = nil
//                            disposeBag = nil
                        }
                        it("has a view model") {
                            expect(sut.viewModel).notTo(beNil())
                        }
                        it("hides keyboard when user scrolls") {
                            expect(sut.collectionView.keyboardDismissMode) == UIScrollView.KeyboardDismissMode.onDrag
                        }
                
                    }
                }
            }
        }
    }
}
