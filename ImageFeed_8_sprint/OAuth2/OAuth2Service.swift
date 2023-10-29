//
//  OAuth2Service.swift
//  ImageFeed_8_sprint
//
//  Created by Марат Хасанов on 06.10.2023.
//

import Foundation
fileprivate let unsplashTokenURL = "https://unsplash.com/oauth/token"

class OAuth2Service {
    
    static let shared = OAuth2Service()
    
    //переменная для хранения указателя на последнюю задачу
    private var task: URLSessionTask?
    
    //переменная для хранения значения code
    private var lastCode: String?
    
    
//MARK: - PROVIDER
    //Синглтон
    let urlSession = URLSession.shared
    
    //Доступ к последнему полученному токену
    private (set) var authToken: String? {
        get {
            return OAuth2TokenStorage().token
        }
        set {
            OAuth2TokenStorage().token = newValue
        }
    }
    
    //Получат code, получаемый из WebView. Он нужен для получения токена
    //Возвращает токен через блоку, если все успешно.
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        //Проверка что код из главного потока
        assert(Thread.isMainThread)
        //проверяем есть ли активная задача
        if lastCode == code { return }
        task?.cancel()
        lastCode = code
        
        let request = authTokenRequest(code: code)
        let session = URLSession.shared
        let task = session.objectTask(for: request) {[weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let body):
                let authToken = body.accessToken
                print(authToken)
                self.authToken = authToken
                completion(.success(authToken))
            case .failure(let error):
                completion(.failure(error))
                }
            }
        self.task = task
        task.resume()
    }
}

//MARK: -
//Сетевой запрос с использованием вспомогательных функций
//Используя вспомогательные функции, ответ от сервера можно запросить и обработать так:
extension OAuth2Service {
    //Делаем POST request
    private func authTokenRequest(code: String) -> URLRequest {
        URLRequest.makeHTTPRequest(
            path: "/oauth/token"
            + "?client_id=\(accessKey)"
            + "&&client_secret=\(secretKey)"
            + "&&redirect_uri=\(redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            httpMethod: "POST",
            baseURL: URL(string: "https://unsplash.com")!)
    }
}
//MARK: - HTTP Request
//Вспомогательный метод для создания запросов
extension URLRequest {
    static func makeHTTPRequest(
        path: String,
        httpMethod: String,
        baseURL: URL = defaultBaseURL
    ) -> URLRequest {
        var request = URLRequest(url: URL(string: path, relativeTo: baseURL)!)
        request.httpMethod = httpMethod
        return request
    }
}

//MARK: - Network Connection
private enum NetworkError: Error {
    case codeError
}

