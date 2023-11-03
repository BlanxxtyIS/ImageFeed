//
//  OAuth2TokenStorage.swift
//  ImageFeed_8_sprint
//
//  Created by Марат Хасанов on 06.10.2023.
//

import Foundation
import SwiftKeychainWrapper
import WebKit

//Сохраняем Bearer Token
final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    
    private let keychainStorage = KeychainWrapper.standard
    
    private enum Keys: String {
        case token
    }
    
    private let tokenKey = "BearerToken"
    
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
    
    static func clean() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}
