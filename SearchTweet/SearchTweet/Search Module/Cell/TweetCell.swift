//
//  TweetCell.swift
//  TwitterDemo
//
//  Created by Priyam Dutta on 18/08/19.
//  Copyright © 2019 Priyam Dutta. All rights reserved.
//

import UIKit
import IGListKit
import SDWebImage

final class TweetCell: UICollectionViewCell {

    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var twitterHandleLabel: UILabel!
    @IBOutlet weak var tweetTimeLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var tweetImageView: UIImageView!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    private var tweetModel: TweetModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }
    
    private func setupUI() {
        userProfileImageView.layer.cornerRadius = userProfileImageView.frame.height * 0.5
        tweetImageView.layer.cornerRadius = 10.0
    }

    private func configure(_ model: TweetModel) {
        tweetLabel.text = model.tweet
        twitterHandleLabel.text = "@\(model.user.handlerName)"
        usernameLabel.text = model.user.name
        if let urlString = model.user.profileImage, let url = URL(string: urlString) {
            userProfileImageView.sd_setImage(with: url, completed: nil)
        }
        if let mediaType = model.mediaType,
            mediaType == MediaType.photo.rawValue,
            let imageUrl = model.mediaImage,
            let url = URL(string: imageUrl) {
            tweetImageView.isHidden = false
            tweetImageView.sd_setImage(with: url, completed: nil)
        } else {
            tweetImageView.isHidden = true
        }
        retweetButton.setTitle(String(model.retweetCount) + " retweets", for: .normal)
        likeButton.setTitle(String(model.favoriteCount) + " likes", for: .normal)
        commentButton.setTitle(String(model.commentCount) + " comments", for: .normal)
        tweetTimeLabel.text = DateFormattingUtility.getIntervalDifference(model.createdDate)
    }
    
    @IBAction func performCommentAction(_ sender: UIButton) {}
    @IBAction func performRetweetAction(_ sender: UIButton) {}
    @IBAction func performLikeAction(_ sender: UIButton) {}
    @IBAction func performShareAction(_ sender: UIButton) {}
}

extension TweetCell: ListBindable {
    
    func bindViewModel(_ viewModel: Any) {
        guard let tweetModel = viewModel as? TweetModel else { return }
        self.tweetModel = tweetModel
        self.configure(tweetModel)
    }
}
