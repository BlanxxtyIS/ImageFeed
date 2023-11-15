//
//  extension.swift
//  ImageFeed_8_sprint
//
//  Created by Марат Хасанов on 04.11.2023.
//

import Foundation
import UIKit

extension Array {
    mutating func withReplaced(itemAt index: Int, newValue: Element) -> [Element]{
        guard index >= 0, index < self.count else {
            print("индекс превышает значение")
            return self
        }
        var newArray = self
        newArray[index] = newValue
        return newArray
    }
}

extension UIColor {
    static var ypBlack: UIColor { UIColor(named: "YP BLACK") ?? .black }
    static var ypGray: UIColor { UIColor(named: "YP Gray") ?? .gray }
    static var ypWhite: UIColor { UIColor(named: "YP White") ?? .white }
}
