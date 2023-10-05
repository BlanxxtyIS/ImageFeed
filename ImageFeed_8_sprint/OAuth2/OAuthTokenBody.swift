//
//  OAuthTokenBody.swift
//  ImageFeed_8_sprint
//
//  Created by Марат Хасанов on 05.10.2023.
//

import Foundation

struct OAuthTokenBody: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope
        case createdAt = "created_at"
    }
}
