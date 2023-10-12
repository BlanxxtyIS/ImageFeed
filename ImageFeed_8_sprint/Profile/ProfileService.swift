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
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        let request = makeRequest(token: token)
        let session = URLSession.shared
        let task = object(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
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
    
    private func object(
        for request: URLRequest,
        completion: @escaping (Result<ProfileResult, Error>) -> Void) -> URLSessionTask {
        let decoder = JSONDecoder()
        return urlSession.data(for: request) { (result: Result<Data, Error>) in
            let response = result.flatMap { data -> Result<ProfileResult, Error> in
                Result { try decoder.decode(ProfileResult.self, from: data)
                }
            }
            completion(response)
        }
    }
    
    func performRequest(urlString: String) {
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error!)
                    return
                }
                if let safeData = data {
                    self.parseJSON(username: safeData)
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(username: Data) {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(ProfileResult.self, from: username)
            print(decodedData.userName)
        } catch {
            print(error)
        }
    }
}
    //Декодирование ответа
struct ProfileResult: Codable {
    let userName: String
    let firstName: String
    let lastName: String
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case userName = "username"
        case firstName = "first_name"
        case lastName = "last_name"
        case bio = "bio"
    }
}
    
struct Profile: Codable {
    let userName: String
    let name: String
    let loginName: String
    let bio: String?
    
    init(decodedData: ProfileResult) {
        self.userName = decodedData.userName
        self.name = (decodedData.firstName ) + " " + (decodedData.lastName )
        self.loginName = "@" + (decodedData.userName)
        self.bio = decodedData.bio
    }
}

extension URLSession {
    func dataProfile(for request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionTask {
        let fulfillCompletion: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data,
               let response = response,
               let statusCode = (response as? HTTPURLResponse)?.statusCode
            {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletion(.success(data))
                } else {
                    fulfillCompletion(.failure(NetworkError .httpStatusCode(statusCode)))
                }
            } else if let error = error {
                fulfillCompletion(.failure(NetworkError.urlRequestError(error)))
            } else {
                fulfillCompletion(.failure(NetworkError.urlSessionError))
            }
        })
        task.resume()
        return task
    }
}

