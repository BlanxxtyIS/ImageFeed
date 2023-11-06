//
//  ProfileImageService.swift
//  ImageFeed_8_sprint
//
//  Created by Марат Хасанов on 12.10.2023.
//

import Foundation

final class ProfileImageService {
    //новое имя нотификации
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    static let shared = ProfileImageService()
    private init() {}
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private let storageToken = OAuth2TokenStorage()
    private (set) var avatarURL: String?
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        //Проверка что код из главного потока
        assert(Thread.isMainThread)
    
        let request = makeRequest(token: storageToken.token!, username: username)
        let session = URLSession.shared
        let task = session.objectTask(for: request) {[weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let body):
                let profileImage = ProfileImage(decodedData: body)
                self.avatarURL = profileImage.profileImage["small"]
                completion(.success(self.avatarURL!))
                NotificationCenter.default
                    .post(name: ProfileImageService.didChangeNotification, object: self, userInfo: ["URL": avatarURL!])
            case .failure(let error):
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
    
    func clean() {
        avatarURL = nil
        task?.cancel()
        task = nil
    }
}

extension ProfileImageService {
    private func makeRequest(token: String, username: String) -> URLRequest {
        guard let url = URL(string: "https://api.unsplash.com/" + "/users/" + username) else {
            fatalError("Failed to create URL")
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

//Для декордирования JSON ответа
struct UserResult: Codable {
    let profileImage: [String: String]

    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

struct ProfileImage: Codable {
    let profileImage: [String: String]
    
    init(decodedData: UserResult) {
        self.profileImage = decodedData.profileImage
    }
}


