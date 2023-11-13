//
//  Constants.swift
//  ImageFeed_8_sprint
//
//  Created by Марат Хасанов on 05.10.2023.
//

import Foundation

//ключ доступа
let AccessKey = "dWeKfzMOk0OiyM90xPEbwjf1HA1PAhyCmq3W5kawRs4"
//секретный ключ
let SecretKey = "R44xk7_WbPPet2SDxWOQHP_OnBrZbSJhIBdNxCRELOg"
//авторизованные права
let RedirectURI = "urn:ietf:wg:oauth:2.0:oob"
//список доступов
let AccessScope = "public+read_user+write_likes"
//базовый адрес API
let DefaultBaseURL = URL(string: "https://unsplash.com")!
let DefaultApiBaseURL = URL(string: "https://api.unsplash.com")!
let UnsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let defaultApiBaseURL: URL
    let unsplashAuthorizeURLString: String
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: AccessKey,
                                 secretKey: SecretKey,
                                 redirectURI: RedirectURI,
                                 accessScope: AccessScope,
                                 defaultBaseURL: DefaultBaseURL,
                                 defaultApiBaseURL: DefaultApiBaseURL,
                                 unsplashAuthorizeURLString: UnsplashAuthorizeURLString)
    }
}

