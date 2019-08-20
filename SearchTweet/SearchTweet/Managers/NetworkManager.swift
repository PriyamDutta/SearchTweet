//
//  NetworkManager.swift
//  YMLDemo
//
//  Created by Priyam Dutta on 09/08/19.
//  Copyright © 2019 Priyam Dutta. All rights reserved.
//

import Foundation
import RxSwift
import ObjectMapper

private struct APIKeys {
    static let apiKey = "yD7KaBsAJSjqeOLXTucW2pVCz"
    static let apiSecretKey = "kQdZMLEPXja7WkDsqRcHYUSFhl9z0lp6pbLzBJScgynrYQgkMF"
}

struct URLConstants {
    static let baseURLLink = "https://api.twitter.com/"
    static let oauthEndPoint = "oauth2/token"
    static let searchTweetEndPoint = "1.1/search/tweets.json"
}

enum HTTPMethodType: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

enum APIType {
    case oAuth, general
}

final class NetworkManager {
    
    func getHeaders(type: APIType) -> [String: String] {
        var params = [String: String]()
        params["Content-Type"] = "application/x-www-form-urlencoded;charset=UTF-8"
        if type == .general, let bearerToken = Preference.bearerToken {
            params["Authorization"] = "Bearer " + bearerToken
        } else {
            params["Authorization"] = "Basic " + "\(APIKeys.apiKey):\(APIKeys.apiSecretKey)".toBase64()
        }
        return params
    }
    
    static func requestForAuthenticatation(apiEndPoint: String,
                                          requestType: HTTPMethodType,
                                          params: Any,
                                          success: @escaping (_ response: [String: Any]) -> Void,
                                          failure: @escaping (_ error: Error) -> Void) {
        guard let url = URL(string: URLConstants.baseURLLink + apiEndPoint) else { return }
        let urlRequest = NetworkRequestManager().getOAuthRequest(url,
                                                                 requestType: requestType,
                                                                 params: params)
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard let data = data else { return }
            if let error = error {
                print("🆘 Error: \(error.localizedDescription)")
                failure(error)
                return
            }
            if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                success(jsonObject)
                print("✅ Got it \(jsonObject)")
            }
            }.resume()
    }
    
    static func requestForTweets(withSearchString searchString: String,
                                success: @escaping (_ response: [TweetModel]) -> Void,
                                failure: @escaping (_ error: Error) -> Void) {
        let path = "?q=\(searchString)%20new%20premium&result_type=recent&count=20"
        guard let url = URL(string: URLConstants.baseURLLink + URLConstants.searchTweetEndPoint + path) else { return }
        let urlRequest = NetworkRequestManager().getTweetsRequest(url, requestType: .get)
        NetworkManager.requestTweets(withRequest: urlRequest, success: success, failure: failure)
    }
    
    static func getMostRecentTweets(_ sinceId: String,
                                    success: @escaping (_ response: [TweetModel]) -> Void,
                                    failure: @escaping (_ error: Error) -> Void) {
        let path = "?q=\("")%20new%20premium&result_type=recent&count=20?since_id=\(sinceId)"
        guard let url = URL(string: URLConstants.baseURLLink + URLConstants.searchTweetEndPoint + path) else { return }
        let urlRequest = NetworkRequestManager().getTweetsRequest(url, requestType: .get)
        NetworkManager.requestTweets(withRequest: urlRequest, success: success, failure: failure)
    }
    
    static func loadMoreTweets(_ searchString: String,
                               maxId: String,
                               success: @escaping (_ response: [TweetModel]) -> Void,
                               failure: @escaping (_ error: Error) -> Void) {
        let path = "?q=\(searchString)%20new%20premium&count=20?next_cursor=\(maxId)"
        guard let url = URL(string: URLConstants.baseURLLink + URLConstants.searchTweetEndPoint + path) else { return }
        let urlRequest = NetworkRequestManager().getTweetsRequest(url, requestType: .get)
        NetworkManager.requestTweets(withRequest: urlRequest, success: success, failure: failure)
    }
}

extension NetworkManager {
    private static func requestTweets(withRequest urlRequest: URLRequest,
                             success: @escaping (_ response: [TweetModel]) -> Void,
                             failure: @escaping (_ error: Error) -> Void) {
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard let data = data else { return }
            if let error = error {
                print("🆘 Error: \(error.localizedDescription)")
                failure(error)
                return
            }
            if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                if let jsonArray = jsonObject["statuses"] as? [[String: Any]] {
                    print("Statuses: \(jsonArray)")
                    let objects = Mapper<TweetModel>().mapArray(JSONArray: jsonArray)
                    success(objects)
                    print(objects.count)
                }
            }
            }.resume()
    }
}
