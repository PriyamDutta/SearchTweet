//
//  Preference.swift
//  TwitterDemo
//
//  Created by Priyam Dutta on 17/08/19.
//  Copyright © 2019 Priyam Dutta. All rights reserved.
//

import Foundation

final class Preference {
    
    struct PreferenceKeys {
        static let bearerToken = "bearerToken"
    }
    
    static var bearerToken: String? {
        get {
            return UserDefaults.standard.string(forKey: PreferenceKeys.bearerToken)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: PreferenceKeys.bearerToken)
        }
    }
}
