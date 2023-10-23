//
//  ProfileService.swift
//  ImageFeed_8_sprint
//
//  Created by Марат Хасанов on 12.10.2023.
//

import Foundation
import UIKit

final class ProfileSevice {
    static let shared = ProfileSevice()
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private (set) var profile: Profile?
    
    private enum NetworkError: Error {
        case codeError
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        //Проверка что код из главного потока
        assert(Thread.isMainThread)
        
        let request = makeRequest(token: token)
        let session = URLSession.shared
        let task = session.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            switch result {
            case .success(let body):
                let profile = Profile(decodedData: body)
                self?.profile = profile
                completion(.success(profile))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
}

extension ProfileSevice {
    private func makeRequest(token: String) -> URLRequest {
        guard let url = URL(string: "https://unsplash.com" + "/me") else {
            fatalError("Failed to create URL")
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

//Декодирование ответа
struct ProfileResult: Codable {
    let username: String
    let firstName: String
    let lastName: String
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case username = "username"
        case firstName = "first_name"
        case lastName = "last_name"
        case bio = "bio"
    }
}

//для UI-кода
struct Profile: Codable {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
    
    init(decodedData: ProfileResult) {
        self.username = decodedData.username
        self.name = (decodedData.firstName ) + " " + (decodedData.lastName )
        self.loginName = "@" + (decodedData.username)
        self.bio = decodedData.bio
    }
}
