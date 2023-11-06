//
//  OAuth2TokenStorage.swift
//  ImageFeed_8_sprint
//
//  Created by Марат Хасанов on 06.10.2023.
//

import Foundation
import SwiftKeychainWrapper


//Сохраняем Bearer Token
final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    
    private let keychainStorage = KeychainWrapper.standard
    
    private enum Keys: String {
        case token
    }
    
    private let tokenKey = "Auth token"
    
    var token: String? {
        get{
            keychainStorage.string(forKey: tokenKey)
        }
        set {
            if let token = newValue {
                keychainStorage.set(token, forKey: tokenKey)
            } else {
                keychainStorage.removeObject(forKey: tokenKey)
            }
        }
    }
    
    static func deleteToken() {
         KeychainWrapper.standard.removeObject(forKey: shared.tokenKey)
     }
    
}
