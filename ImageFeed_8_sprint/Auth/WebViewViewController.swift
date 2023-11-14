//
//  WebViewViewController.swift
//  ImageFeed_8_sprint
//
//  Created by Марат Хасанов on 06.10.2023.
//

import UIKit
import WebKit
import SwiftKeychainWrapper

public protocol WebViewViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}

protocol WebViewViewControllerDelegate: AnyObject {
    //webViewViewController - получил код
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    //пользователь нажал кнопку назад и отменил авторизацию
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

//Экран показа веб-страницы
final class WebViewViewController: UIViewController & WebViewViewControllerProtocol {
    
    var presenter: WebViewPresenterProtocol?
    
    static let shared = WebViewViewController()
    let authSevice = OAuth2Service()
    
    private var estigmatedProgressObservation: NSKeyValueObservation?
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var webView: WKWebView!
    weak var delegate: WebViewViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        webView.accessibilityIdentifier = "UnsplashWebView"
        presenter?.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        delegate?.webViewViewControllerDidCancel(self)
    }
    
    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }
    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
    
    func load(request: URLRequest) {
        webView.load(request)
    }
}
//MARK: - Networking

extension WebViewViewController {
    
    static func clean(){
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}

extension WebViewViewController: WKNavigationDelegate {
    //Этот метот вызывается когда в рез. действий пользователя WKWebView готовится совершить навигационные действия
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
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
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url {
            return presenter?.code(from: url)
        }
        return nil
    }
}


