//
//  ImagesListPresenter.swift
//  ImageFeed_8_sprint
//
//  Created by Марат Хасанов on 13.11.2023.
//

import Foundation
import UIKit

protocol ImagesListViewPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }
    var photosCount: Int { get }
    func viewDidLoad()
    func updateTableViewAnimated()
    func fetchPhotos()
    func calculateHeightForRow(indexPath: IndexPath) -> CGFloat
    func chekIfNextPageNeeded(indexPath: IndexPath)
    func imagesListCellDidTapLike(_ cell: ImagesListCell, indexPath: IndexPath)
    func returnPhoto(indexPath: IndexPath) -> Photo
}

final class ImagesListViewPresenter: ImagesListViewPresenterProtocol {
    func imagesListCellDidTapLike(_ cell: ImagesListCell, indexPath: IndexPath) {
        
    }
    
    
    private var imagesListService = ImageListService.shared
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    
    var view: ImagesListViewControllerProtocol?
    var photos: [Photo] = []
    var photosCount: Int {
        photos.count
    }
    
    func viewDidLoad() {
        view?.setupTableView()
        fetchPhotos()
    }
    
    func fetchPhotos() {
        imagesListService.fetchPhotosNextPage()
        print(imagesListService.fetchPhotosNextPage())
    }
    
    func updateTableViewAnimated() {
        let oldCount = photosCount
        photos = imagesListService.photos
        let newCount = photosCount
        if oldCount != newCount {
            view?.tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                view?.tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
    
    func calculateHeightForRow(indexPath: IndexPath) -> CGFloat {
        guard let view = view else { return 0 }
        let imageInsert = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = view.tableView.bounds.width - imageInsert.left - imageInsert.right
        let imageWidth = photos[indexPath.row].size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photos[indexPath.row].size.height * scale + imageInsert.top + imageInsert.bottom
        return cellHeight
    }
    
    func chekIfNextPageNeeded(indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            imagesListService.fetchPhotosNextPage()
        }
    }
    //MARK: -----
//    func imagesListCellDidTapLike(_ cell: ImagesListCell, indexPath: IndexPath) {
//        let photo = photos[indexPath.row]
//        UIBlockingProgressHUD.show()
//        imagesListService.changeLike(photoId: photo.id,
//                                     token: oauth2TokenStorage.token!,
//                                     isLike: photo.isLiked) { [ weak self ] result in
//            guard let self = self else { return }
//            switch result {
//            case .success(_):
//                self.photos = self.imagesListService.photos
//                cell.establishLike(isLiked: self.photos[indexPath.row].isLiked)
//                UIBlockingProgressHUD.dismiss()
//            case .failure(let error):
//                UIBlockingProgressHUD.dismiss()
//                view?.errorLikeAlert(error: error)
//            }
//        }
//    }
    
    func returnPhoto(indexPath: IndexPath) -> Photo {
        photos[indexPath.row]
    }
}
