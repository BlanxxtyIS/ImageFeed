//
//  ImageListService.swift
//  ImageFeed_8_sprint
//
//  Created by Марат Хасанов on 30.10.2023.
//
import UIKit

//алгоритм для постраничной загрузки из сети
final class ImageListService: UIViewController {
    
    static let shared = ImageListService()
    
    private let perPage = "10"
    private let orderBy = "latest"
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    private let dateFormatter = ISO8601DateFormatter()

    
    //Получаем ответ из сети, формирует объект Photo для каждого PhotoResult
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        //какую страницу загружать
        if task != nil { return }
        let nextPage = lastLoadedPage == nil ? 1 : lastLoadedPage! + 1
        
        guard let token = oauth2TokenStorage.token else { return }
        let request = photoRequest(token: token, page: String(nextPage), perPage: perPage)
        let task = urlSession.objectTask(for: request) {[weak self] (result: Result<[PhotoResult], Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let photoResult):
                    for photoResult in photoResult {
                        self.photos.append(self.toChange(photoResult: photoResult))
                    }
                    self.lastLoadedPage = nextPage
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
}

extension ImageListService {
    
    private func photoRequest(token: String, page: String, perPage: String) -> URLRequest {
        var request = URLRequest.makeHTTPRequest(
            path: "/photos?page=\(page)&&per_page=\(perPage)",
            httpMethod: "GET",
            baseURL: DefaultApiBaseURL)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    
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
        
        guard let token = oauth2TokenStorage.token else { return }
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
                                         isLiked: isLiked)
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
                                                 baseURL: DefaultApiBaseURL)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func removeLike(_ token: String, id: String) -> URLRequest? {
        var request = URLRequest.makeHTTPRequest(path: "photos/\(id)/like",
                                                       httpMethod: "DELETE",
                                                       baseURL: DefaultApiBaseURL)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
