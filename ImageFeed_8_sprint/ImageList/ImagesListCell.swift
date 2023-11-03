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
    
    @IBAction private func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }
    
    override func prepareForReuse(){
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
    }
    
    func establishLike(isLiked: Bool){
        let like = isLiked ? UIImage(named: "like") : UIImage(named: "dislike")
        likeButton.imageView?.image = like
        likeButton.setImage(like, for: .normal)
    }
}
