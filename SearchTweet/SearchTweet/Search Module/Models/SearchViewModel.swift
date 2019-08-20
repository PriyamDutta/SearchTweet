//
//  SearchViewModel.swift
//  TwitterDemo
//
//  Created by Priyam Dutta on 18/08/19.
//  Copyright © 2019 Priyam Dutta. All rights reserved.
//

import Foundation
import RxSwift

protocol OfflineSupportProtocol {
    var realmManager: RealmManager! { get }
}

protocol SearchViewModelInputProtocol {
    var searchText: BehaviorSubject<String> { get set }
    var loadMoreData: BehaviorSubject<Bool> { get }
}

protocol SearchViewModelOutputProtocol {
    var tweets: BehaviorSubject<[TweetModel]>! { get }
    var newTweets: BehaviorSubject<[TweetModel]>! { get }
    var isSearchActive: BehaviorSubject<Bool>! { get }
    var isSearchServiceRunning: BehaviorSubject<Bool>! { get }
}

protocol SearchViewModelType: AnyObject {
    var inputs: SearchViewModelInputProtocol { get }
    var outputs: SearchViewModelOutputProtocol { get }
    var offlineSupport: OfflineSupportProtocol { get }
}

final class SearchViewModel: SearchViewModelType, SearchViewModelInputProtocol, SearchViewModelOutputProtocol, OfflineSupportProtocol {
    
    var inputs: SearchViewModelInputProtocol { return self }
    var outputs: SearchViewModelOutputProtocol { return self }
    var offlineSupport: OfflineSupportProtocol { return self }
    private let disposeBag = DisposeBag()
    // Inputs
    var searchText = BehaviorSubject<String>(value: "")
    var loadMoreData = BehaviorSubject<Bool>(value: false)
    // Outputs
    var isSearchActive: BehaviorSubject<Bool>! = BehaviorSubject<Bool>(value: false)
    var isSearchServiceRunning: BehaviorSubject<Bool>! = BehaviorSubject<Bool>(value: false)
    lazy var newTweets: BehaviorSubject<[TweetModel]>! = {
        return BehaviorSubject<[TweetModel]>(value: [])
    }()
    lazy var tweets: BehaviorSubject<[TweetModel]>! = {
        return BehaviorSubject<[TweetModel]>(value: [])
    }()
    // Offline Support
    lazy var realmManager: RealmManager! = { return RealmManager() }()
    
    init() {
        let cachedTweets = realmManager.readData(TweetModel.self,
                                                 predicate: NSPredicate(),
                                                 orderBy: (keyPath: "createdDate", isAsc: false))
        if !cachedTweets.isEmpty {
            tweets.onNext(cachedTweets)
            NetworkManager.getMostRecentTweets(cachedTweets.first!.id, success: { [weak self] (newTweets) in
                guard let weakSelf = self else { return }
//                weakSelf.newTweets.onNext(newTweets)
                weakSelf.isSearchServiceRunning.onNext(false)
            }) { (_) in
            }
        } else {
            getTweets(withSearchText: "")
        }
        
        searchText.asObserver()
            .debounce(RxTimeInterval.milliseconds(300), scheduler: MainScheduler.instance).subscribe(onNext: { [weak self] (searchText) in
                guard let weakSelf = self else { return }
                do {
                    let value = try weakSelf.isSearchActive.value()
                    if value {
                        print("Search: \(searchText)")
                        weakSelf.getTweets(withSearchText: searchText)
                    }
                } catch {
                    print("Error....")
                }
            }).disposed(by: disposeBag)
        
        Observable.combineLatest(loadMoreData, searchText, tweets) { [unowned self]
            (loadMoreData, searchText, tweets) in
            if loadMoreData, let lastTweet = tweets.last {
                self.isSearchServiceRunning.onNext(true)
                NetworkManager.loadMoreTweets(searchText, maxId: lastTweet.id, success: { [weak self] (response) in
                    do {
                        guard let weakSelf = self else { return }
                        let oldTweets = try weakSelf.tweets.value()
                        weakSelf.tweets.onNext(oldTweets + response.dropLast())
                        weakSelf.loadMoreData.onNext(false)
                        weakSelf.isSearchServiceRunning.onNext(false)
                    } catch {
                        fatalError()
                    }
                }, failure: { [weak self] (_) in
                    guard let weakSelf = self else { return }
                    weakSelf.isSearchServiceRunning.onNext(false)
                })
            }
        }.observeOn(MainScheduler.instance)
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    func getTweets(withSearchText searchText: String) {
        isSearchServiceRunning.onNext(true)
        NetworkManager.requestForTweets(withSearchString: searchText,
                                        success: { [weak self] (response) in
                                            guard let weakSelf = self else { return }
                                            print("Count: \(response.count)")
                                            do {
                                                let value = try weakSelf.isSearchActive.value()
                                                if !value {
                                                    DispatchQueue.main.async {
                                                        weakSelf.realmManager.writeData(response)
                                                    }
                                                }
                                            } catch {
                                                print("Error....")
                                            }
                                            weakSelf.tweets.onNext(response)
                                            weakSelf.isSearchServiceRunning.onNext(false)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}
