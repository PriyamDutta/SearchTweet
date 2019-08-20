//
//  SearchSectionController.swift
//  TwitterDemo
//
//  Created by Priyam Dutta on 18/08/19.
//  Copyright © 2019 Priyam Dutta. All rights reserved.
//

import Foundation
import IGListKit

final class SearchSectionController: ListBindingSectionController<ListDiffable>, ListBindingSectionControllerDataSource {
    
    private var tweetModel: TweetModel?
    override init() {
        super.init()
        dataSource = self
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, viewModelsFor object: Any) -> [ListDiffable] {
        guard let bindable = object as? TweetModel else { return [] }
        self.tweetModel = bindable
        return [bindable]
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, cellForViewModel viewModel: Any, at index: Int) -> UICollectionViewCell & ListBindable {
        guard let tweetCell = collectionContext?.dequeueReusableCell(withNibName: String(describing: TweetCell.self), bundle: nil, for: self, at: index) as? TweetCell else {
            fatalError()
        }
        return tweetCell
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, sizeForViewModel viewModel: Any, at index: Int) -> CGSize {
        guard let collectionContext = collectionContext else { return .zero }
        guard let tweetModel = tweetModel else { return .zero }
        var height: CGFloat = 80.0
        if let font = UIFont(name: "Helvetica", size: 15.0) {
            let calculatedHeight = Utility.heightForView(text: tweetModel.tweet, font: font, width: collectionContext.containerSize.width - 64.0)
            height += calculatedHeight
        }
        if let mediaType = tweetModel.mediaType, mediaType == MediaType.photo.rawValue {
            height += 150.0
        }
        return CGSize(width: collectionContext.containerSize.width, height: height)
    }
}
