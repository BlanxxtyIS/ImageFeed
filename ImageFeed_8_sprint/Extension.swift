//
//  extension.swift
//  ImageFeed_8_sprint
//
//  Created by Марат Хасанов on 04.11.2023.
//

import Foundation
import UIKit

extension Array {
    func replacement(itemAt: Int, newValue: Photo) -> [Photo] {
        var photos = ImageListService.shared.photos
        photos.replaceSubrange(itemAt...itemAt, with: [newValue])
        return photos
    }
}

extension UIColor {
    static var ypBlack: UIColor { UIColor(named: "YP BLACK") ?? .black }
    static var ypGray: UIColor { UIColor(named: "YP Gray") ?? .gray }
    static var ypWhite: UIColor { UIColor(named: "YP White") ?? .white }
}
