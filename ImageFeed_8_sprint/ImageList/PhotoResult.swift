//
//  PhotoResult.swift
//  ImageFeed_8_sprint
//
//  Created by Марат Хасанов on 30.10.2023.
//

import Foundation

//Структура для декодинга JSON ответа от Unsplash
struct PhotoResult: Codable {
    static let dateFormatter = ISO8601DateFormatter()
    
    let id: String
    let createdAt: String?
    let width: Double
    let height: Double
    let description: String?
    let urls: UrlsResult
    let likedByUser: Bool
    
    func asDomain() -> Photo {
        let photo = Photo(id: self.id,
                          size: CGSize(width: self.width, height: self.height),
                          createdAt: self.makeDate(body: self),
                          welcomeDescription: self.description,
                          thumbImageURL: URL(string: self.urls.small)!,
                          largeImageURL: URL(string: self.urls.full)!,
                          isLiked: self.likedByUser)
        return photo
    }
    
    private func makeDate(body: PhotoResult) -> Date? {
        return body.createdAt.flatMap { PhotoResult.dateFormatter.date(from: $0) }
    }
}

struct UrlsResult: Codable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

struct LikeResult: Codable {
    let photo: PhotoResult
}



