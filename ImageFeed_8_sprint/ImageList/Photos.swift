//
//  Photos.swift
//  ImageFeed_8_sprint
//
//  Created by Марат Хасанов on 31.10.2023.
//

import Foundation

struct Photos {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let rawImageURL: String
    let smallImageURL: String
    let thumbImageURL: String
    let fullImageURL: String
    let regularImageURL: String
    let isLiked: Bool
}
