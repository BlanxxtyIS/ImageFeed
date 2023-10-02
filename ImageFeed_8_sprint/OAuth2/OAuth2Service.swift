//
//  OAuth2Service.swift
//  ImageFeed_8_sprint
//
//  Created by Марат Хасанов on 02.10.2023.
//

import Foundation

class OAuth2Service {
    func fetchAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        completion(.success(""))
    }
}
