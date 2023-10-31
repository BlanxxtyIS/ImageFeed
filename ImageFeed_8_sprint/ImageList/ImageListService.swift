//
//  ImageListService.swift
//  ImageFeed_8_sprint
//
//  Created by Марат Хасанов on 30.10.2023.
//

import Foundation
import UIKit

private enum NetworkPhotosError: Error {
    case errorPhotos
}

//Такой алгоритм подойдет во многих случаях, когда подразумевается постраничная загрузка данных из сети
class ImageListService: UIViewController {
    
    static let shared = ImageListService()
    private let urlSession = URLSession.shared
    private let dateFormatter = ISO8601DateFormatter()
    
    //скаченные фото
    private (set) var photos: [Photos] = []
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    //последняя страница
    var lastsLoadedPage: Int?
    
    var task: URLSessionTask?
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        if task != nil { return }
        let nextPage = lastsLoadedPage == nil ? 1 : lastsLoadedPage! + 1
        lastsLoadedPage = nextPage
        
        guard let request = photosRequest(path: "/photos?page=\(nextPage)") else {
            return assertionFailure("Ошибка с соединением")
        }
        let task = urlSession.objectTask(for: request) {[weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let photoResult):
                self.preparePhoto(photoResult)
                NotificationCenter.default.post(name: ImageListService.didChangeNotification, object: self, userInfo: ["photos": self.photos])
            case .failure(let error):
                print(error)
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
    
    func photosRequest(path: String) -> URLRequest? {
        guard let baseURL = URL(string: path, relativeTo: defaultBaseURL) else {
            assertionFailure("Error token")
            return nil
        }
        return nil
    }
    
    func preparePhoto(_ photoResult: [PhotoResult]) {
        let newPhotos = photoResult.map { item in
            return Photos(
                id: item.id,
                size: CGSize(width: item.width, height: item.height),
                createdAt: dateFormatter.date(from: item.createdAt!),
                welcomeDescription: item.description,
                rawImageURL: item.urls.raw,
                smallImageURL: item.urls.small,
                thumbImageURL: item.urls.thumb,
                fullImageURL: item.urls.full,
                regularImageURL: item.urls.regular,
                isLiked: item.likedByUser)
        }
        self.photos.append(contentsOf: newPhotos)
    }
}


