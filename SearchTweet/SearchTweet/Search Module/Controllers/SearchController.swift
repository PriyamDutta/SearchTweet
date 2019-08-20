//
//  ViewController.swift
//  YMLDemo
//
//  Created by Priyam Dutta on 09/08/19.
//  Copyright © 2019 Priyam Dutta. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import IGListKit
import ObjectMapper
import RealmSwift

final class SearchController: UIViewController, BindableType {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newTweetButton: UIButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var viewModel: SearchViewModelType!
    private let disposeBag = DisposeBag()
    
    private lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    private var datasource: [TweetModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        cacheRefresh()
        setupUI()
        authenticateUser()
        bindViewModel()
    }
    
    private func setupUI() {
        adapter.collectionView = collectionView
        adapter.dataSource = self
        adapter.delegate = self
        newTweetButton.layer.cornerRadius = newTweetButton.frame.height * 0.5
        newTweetButton.isHidden = true
        KeyboardUtility.keyboardHeightObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (height) in
                guard let weakSelf = self else { return }
                weakSelf.collectionView.contentInset.bottom = height
            }).disposed(by: disposeBag)
    }
    
    private func authenticateUser() {
        NetworkManager.requestForAuthenticatation(apiEndPoint: URLConstants.oauthEndPoint,
                                                  requestType: .post,
                                                  params: "grant_type=client_credentials",
                                                  success: { (response) in
                                                    if let token = response["access_token"] as? String {
                                                        Preference.bearerToken = token
                                                    }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    private func cacheRefresh() {
        RealmManager.deleteAllData(TweetModel.self,
                                   predicate: NSPredicate(format: "createdDate > %@", DateFormattingUtility.addDays(Date(), days: 1) as CVarArg))
    }
    
    func bindViewModel() {
        viewModel = SearchViewModel()
        let inputs = viewModel.inputs
        let outputs = viewModel.outputs
        let offline = viewModel.offlineSupport
        
        searchBar.rx.text.subscribe(onNext: { (string) in
            inputs.searchText.onNext(string ?? "")
        }).disposed(by: disposeBag)
        
        searchBar.rx.textDidBeginEditing.subscribe(onNext: { (_) in
            outputs.isSearchActive.onNext(true)
        }).disposed(by: disposeBag)
        
        searchBar.rx.textDidEndEditing.subscribe(onNext: { (_) in
            outputs.isSearchActive.onNext(false)
        }).disposed(by: disposeBag)
        
        searchBar.rx.cancelButtonClicked.asObservable().subscribe(onNext: { [unowned self] (_) in
            self.searchBar.resignFirstResponder()
        }).disposed(by: disposeBag)
        
        outputs.isSearchServiceRunning
            .map { $0 == false }
            .bind(to: activityIndicatorView.rx.isHidden)
            .disposed(by: disposeBag)
        
        outputs.newTweets.asObservable()
            .bind { (newTweets) in
            DispatchQueue.main.async { [weak self] in
                guard let weakSelf = self else { return }
                weakSelf.newTweetButton.isHidden = newTweets.isEmpty
            }
        }.disposed(by: disposeBag)
        outputs.tweets.asObservable().observeOn(MainScheduler.instance)
            .bind { [weak self] (tweets) in
                guard let weakSelf = self else { return }
                weakSelf.datasource = tweets
                weakSelf.adapter.performUpdates(animated: true, completion: nil)
        }.disposed(by: disposeBag)
        newTweetButton.rx.controlEvent(.touchUpInside)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (_) in
            do {
                guard let weakSelf = self else { return }
                let tweets = try outputs.newTweets.value()
                outputs.tweets.onNext(tweets)
                offline.realmManager.writeData(tweets)
                weakSelf.newTweetButton.isHidden = true
            } catch {
                fatalError()
            }
        }).disposed(by: disposeBag)
    }
}

extension SearchController: ListAdapterDataSource, IGListAdapterDelegate {
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return datasource
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return SearchSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        let emptyLabel = UILabel()
        emptyLabel.text = "No tweets found 😪"
        emptyLabel.textAlignment = .center
        return emptyLabel
    }
    
    func listAdapter(_ listAdapter: ListAdapter, willDisplay object: Any, at index: Int) {
        if index == datasource.count - 1 {
            viewModel.inputs.loadMoreData.onNext(true)
        }
    }
    
    func listAdapter(_ listAdapter: ListAdapter, didEndDisplaying object: Any, at index: Int) {}
}
