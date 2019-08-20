//
//  NetworkRequestManager.swift
//  SearchTweet
//
//  Created by Priyam Dutta on 20/08/19.
//  Copyright © 2019 Priyam Dutta. All rights reserved.
//

import Foundation

final class NetworkRequestManager {
    
    func getOAuthRequest(_ url: URL, requestType: HTTPMethodType, params: Any) -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = NetworkManager().getHeaders(type: .oAuth)
        urlRequest.httpMethod = requestType.rawValue
        if let paramString = params as? String {
            urlRequest.httpBody = paramString.data(using: .utf8)
        } else if let paramsObject = params as? [String: Any] {
            urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: paramsObject, options: .prettyPrinted)
        }
        return urlRequest
    }
    
    func getTweetsRequest(_ url: URL, requestType: HTTPMethodType) -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = NetworkManager().getHeaders(type: .general)
        urlRequest.httpMethod = HTTPMethodType.get.rawValue
        return urlRequest
    }
}
