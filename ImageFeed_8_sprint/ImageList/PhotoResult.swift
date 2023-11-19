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
    let createdAt: String?
    let description: String?
    let likedByUser: Bool
    let width, height: CGFloat
    let urls: UrlsResult
    
    private enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case likedByUser = "liked_by_user"
        case id, width, height, description, urls
    }
}

struct UrlsResult: Decodable {
    let thumbImageURL: String?
    let largeImageURL: String?
    
    enum CodingKeys: String, CodingKey {
        case thumbImageURL = "thumb"
        case largeImageURL = "full"
    }
}




