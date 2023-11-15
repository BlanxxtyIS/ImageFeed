//
//  ImagesListCell.swift
//  ImageFeed_8_sprint
//
//  Created by Марат Хасанов on 30.08.2023.
//
import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    
    weak var delegate: ImagesListCellDelegate?
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    
    
    override func prepareForReuse(){
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
        likeButton.accessibilityIdentifier = "BackButton"
        
    }
    
    func establishLike(isLiked: Bool){
        likeButton.setBackgroundImage(isLiked ? UIImage(named: "like") : UIImage(named: "dislike"), for: .normal)
    }
    
    @IBAction private func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }
}
