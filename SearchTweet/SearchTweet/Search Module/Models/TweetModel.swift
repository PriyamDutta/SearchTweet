//
//  TweetModel.swift
//  TwitterDemo
//
//  Created by Priyam Dutta on 18/08/19.
//  Copyright © 2019 Priyam Dutta. All rights reserved.
//

import Foundation
import ObjectMapper
import IGListKit
import RealmSwift

enum MediaType: String {
    case photo = "photo"
}

final class TweetModel: Object, Mappable, ListDiffable {
    
    @objc dynamic var id: String!
    @objc dynamic var createdDate: Date = Date()
    @objc dynamic var tweet: String!
    @objc dynamic var favoriteCount = 0
    @objc dynamic var retweetCount = 0
    @objc dynamic var commentCount = 0
    @objc dynamic var mediaImage: String?
    @objc dynamic var mediaType: String?
    @objc dynamic var syncDate: Date = Date()
    @objc dynamic var user: User!
    
    required convenience init?(map: Map) {
        self.init()
        mapping(map: map)
    }
    
    override class func primaryKey() -> String {
        return "id"
    }
    
    func mapping(map: Map) {
        if let id = map.JSON["id"] as? Int {
            self.id = String(id)
        }
        if let createdDate = map.JSON["created_at"] as? String {
            let date = DateFormattingUtility.getDateFromString(createdDate)
            self.createdDate = date
        }
        tweet <- map["text"]
        favoriteCount <- map["favorite_count"]
        commentCount <- map["statuses_count"]
        retweetCount <- map["retweet_count"]
        user <- map["user"]
        mediaImage <- map["entities.media.media_url"]
        mediaType <- map["entities.media.type"]
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return self.id as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? TweetModel else { return false }
        return self.diffIdentifier().isEqual(object.diffIdentifier())
    }
}

final class User: Object, Mappable {
    
    @objc dynamic var id: String!
    @objc dynamic var profileImage: String?
    @objc dynamic var name: String!
    @objc dynamic var backgroundColor: String?
    @objc dynamic var followersCount = 0
    @objc dynamic var verified = false
    @objc dynamic var handlerName: String = ""
    
    required convenience init?(map: Map) {
        self.init()
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        profileImage <- map["profile_image_url"]
        name <- map["name"]
        backgroundColor <- map["profile_background_color"]
        followersCount <- map["followers_count"]
        verified <- map["verified"]
        handlerName <- map["screen_name"]
    }
}
