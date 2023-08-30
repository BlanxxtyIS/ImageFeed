//
//  ImagesListCell.swift
//  ImageFeed_8_sprint
//
//  Created by Марат Хасанов on 30.08.2023.
//
import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    

}
