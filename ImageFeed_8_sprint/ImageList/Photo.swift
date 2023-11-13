//
//  Photos.swift
//  ImageFeed_8_sprint
//
//  Created by Марат Хасанов on 31.10.2023.
//

import Foundation
//Будет использоваться в UI части приложени
struct Photo: Codable {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: URL
    let largeImageURL: URL
    let isLiked: Bool
}

struct Like: Decodable {
    let photo: PhotoResult?
}
