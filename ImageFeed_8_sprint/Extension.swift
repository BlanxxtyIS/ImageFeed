//
//  extension.swift
//  ImageFeed_8_sprint
//
//  Created by Марат Хасанов on 04.11.2023.
//

import Foundation

extension Array {
    func replacement(itemAt: Int, newValue: Photo) -> [Photo] {
        var photos = ImageListService.shared.photos
        photos.replaceSubrange(itemAt...itemAt, with: [newValue])
        return photos
    }
}
