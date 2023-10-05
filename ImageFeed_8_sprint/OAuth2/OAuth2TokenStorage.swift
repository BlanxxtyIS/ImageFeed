//
//  OAuth2TokenStorage.swift
//  ImageFeed_8_sprint
//
//  Created by Марат Хасанов on 02.10.2023.
//

import Foundation

final class OAuth2TokenStorage {
    
    private let tokenKey = "BearerToken"
    
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: tokenKey)
        }
    }
}
