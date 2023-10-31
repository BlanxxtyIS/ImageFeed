//
//  PhotoResult.swift
//  ImageFeed_8_sprint
//
//  Created by Марат Хасанов on 30.10.2023.
//

import Foundation

//Структура для декодинга JSON ответа от Unsplash
struct PhotoResult: Decodable {
    let id: String
    let createdAt, description: String?
    let width, height: Int
    let likedByUser: Bool
    let urls: UrlsResult
    
    private enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case likedByUser = "liked_by_user"
        case id, width, height, description, urls
    }
}

struct UrlsResult: Decodable {
    let raw: String
    let full: String
    let regular: String
    let small : String
    let thumb: String
}


