//
//  WebViewViewController.swift
//  ImageFeed_8_sprint
//
//  Created by Марат Хасанов on 06.10.2023.
//

import UIKit
import WebKit
import SwiftKeychainWrapper


protocol WebViewViewControllerDelegate: AnyObject {
    //webViewViewController - получил код
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    //пользователь нажал кнопку назад и отменил авторизацию
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

//Экран показа веб-страницы
final class WebViewViewController: UIViewController {
    static let shared = WebViewViewController()
    let authSevice = OAuth2Service()
    
    private var estigmatedProgressObservation: NSKeyValueObservation?
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var webView: WKWebView!
    weak var delegate: WebViewViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        estigmatedProgressObservation = webView.observe(\.estimatedProgress, options: [], changeHandler: { [weak self] _ ,  _ in
            guard let self = self else { return }
            self.updateProgress()
        })
        webView.navigationDelegate = self
        loadWebView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        estigmatedProgressObservation = webView.observe(
            \.estimatedProgress,
             options: [],
             changeHandler: {[weak self] _, _ in
                 guard let self = self else {return}
                 self.updateProgress()
             })
    }
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        delegate?.webViewViewControllerDidCancel(self)
    }
    
    private func updateProgress() {
        progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
    
    func webViewClean() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}
//MARK: - Networking

extension WebViewViewController {
    //Формируем запрос Request, чтобы загрузить веб-контент
    func loadWebView() {
        //Инициализируем URLComponents
        var urlComponents = URLComponents(string: unsplashAuthorizeURLString)!
        //Устанавливаем значения, достаем url
        urlComponents.queryItems = [
        URLQueryItem(name: "client_id", value: accessKey),
        URLQueryItem(name: "redirect_uri", value: redirectURI),
        URLQueryItem(name: "response_type", value: "code"),
        URLQueryItem(name: "scope", value: accessScope)]
        let url = urlComponents.url!
        
        //Формируем URLRequest и передаем WKWebView для загрузки
        let request = URLRequest(url: url)
        webView.load(request)
        //теперь при открытии экрана, он загружает авторизационный экран
    }
}

extension WebViewViewController: WKNavigationDelegate {
    //Этот метот вызывается когда в рез. действий пользователя WKWebView готовится совершить навигационные действия
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let code = code(from: navigationAction) {
            authSevice.fetchOAuthToken(code) { result in
                switch result {
                case .success(let bearerToken):
                    let token = bearerToken
                    let isSuccess = KeychainWrapper.standard.set(token, forKey: "Auth token")
                    guard isSuccess else {
                        // ошибка
                        return
                    }
                    self.delegate?.webViewViewControllerDidCancel(self)
                    
                    //                     self.switchToTabBarController()
                    self.switchToSplashScreen()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    func switchToSplashScreen() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let splashScreenViewController = SplashViewController()
        window.rootViewController = splashScreenViewController
    }
    
    
    //Получаем из navigationAction - URL, Создаем URLComponents
    //Ищем в массиве значение name == code, возвращаем value
    //При успешной авторизации перехватываем строку "код"
    func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url,
           let urlComponents = URLComponents(string: url.absoluteString),
           urlComponents.path == "/oauth/authorize/native",
           let items = urlComponents.queryItems,
           let codeItem = items.first(where: {$0.name == "code"}) {
            return codeItem.value
        } else {
            return nil
        }
    }
}


