//
//  ImageListService.swift
//  ImageFeed_8_sprint
//
//  Created by Марат Хасанов on 30.10.2023.
//

import Foundation
import UIKit
import SwiftKeychainWrapper

//алгоритм для постраничной загрузки из сети
class ImageListService: UIViewController {
    
    static let shared = ImageListService()  //Синглтон
    
    private (set) var photos: [Photo] = []  //скаченные фото
    
    var lastsLoadedPage: Int?   //последняя страница
    
    private let perPage = "10"
    
    private let oAuth2StorageToken = OAuth2TokenStorage.shared
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange") //Нотификация
    
    var task: URLSessionTask?
    
    private let urlSession = URLSession.shared
    
    private let dateFormatter = ISO8601DateFormatter()
    
    //Получаем ответ из сети, формирует объект Photo для каждого PhotoResult
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        //какую страницу загружать
        if task != nil { return }
        let nextPage = lastsLoadedPage == nil ? 1 : lastsLoadedPage! + 1
        
        guard let token = oAuth2StorageToken.token else { return }
        let request = photoRequest(token: token, page: String(nextPage), perPage: perPage)
        let task = urlSession.objectTask(for: request) {[weak self] (result: Result<[PhotoResult], Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let photoResult):
                    for photoResult in photoResult {
                        self.photos.append(self.toChange(photoResult: photoResult))
                    }
                    self.lastsLoadedPage = nextPage
                    NotificationCenter.default.post(name: ImageListService.didChangeNotification, object: self, userInfo: ["Images": self.photos])
                case .failure(let error):
                    print("Не получили данные из запроса ")
                    assertionFailure("Ошибка при загрузке \(error)")
                }
                self.task = nil
            }
        }
        self.task = task
        task.resume()
    }
    
    func clean(){
        photos = []
        lastsLoadedPage = nil
        task?.cancel()
        task = nil
    }
}

extension ImageListService {
                                
    private func photoRequest(token: String, page: String, perPage: String) -> URLRequest {
        var request = URLRequest.makeHTTPRequest(
            path: "/photos?page=\(page)&&per_page=\(perPage)",
            httpMethod: "GET",
            baseURL: defaultApiBaseURL)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }

    private func toChange(photoResult: PhotoResult) -> Photo {
        return Photo.init(
            id: photoResult.id,
            size: CGSize(width: photoResult.width, height: photoResult.height),
            createdAt: self.dateFormatter.date(from: photoResult.createdAt ?? ""),
            welcomeDescription: photoResult.description,
            thumbImageURL: photoResult.urls.thumbImageURL ?? "",
            largeImageURL: photoResult.urls.largeImageURL ?? "",
            isLiked: photoResult.likedByUser)
    }
    
    func like(id: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        guard let token = oAuth2StorageToken.token else { return }
        var request: URLRequest
        if isLike {
            request = removeLike(token, id: id)!
        } else {
            request = toPutLike(token, id: id)!
        }
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<Like, Error>) in
            guard let self = self else { return }
            self.task = nil
            switch result {
            case .success(let photoResult):
                let isLiked = photoResult.photo?.likedByUser ?? false
                if let index = self.photos.firstIndex(where: {$0.id == photoResult.photo?.id}) {
                    let photo = self.photos[index]
                    let newPhoto = Photo(id: photo.id,
                                         size: CGSize(width: photo.size.width, height: photo.size.height),
                                         createdAt: photo.createdAt,
                                         welcomeDescription: photo.welcomeDescription,
                                         thumbImageURL: photo.thumbImageURL,
                                         largeImageURL: photo.largeImageURL,
                                         isLiked: photo.isLiked)
                    self.photos = self.photos.replacement(itemAt: index, newValue: newPhoto)
                }
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
    
    func toPutLike(_ token: String, id: String) -> URLRequest? {
        var request = URLRequest.makeHTTPRequest(path: "photos/\(id)/like",
                                                 httpMethod: "POST",
                                                 baseURL: defaultApiBaseURL)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    func removeLike(_ token: String, id: String) -> URLRequest? {
        var request = URLRequest.makeHTTPRequest(path: "photos/\(id)/like",
                                                       httpMethod: "DELETE",
                                                       baseURL: defaultApiBaseURL)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

extension Array {
    func replacement(itemAt: Int, newValue: Photo) -> [Photo] {
        var photos = ImageListService.shared.photos
        photos.replaceSubrange(itemAt...itemAt, with: [newValue])
        return photos
    }
}





