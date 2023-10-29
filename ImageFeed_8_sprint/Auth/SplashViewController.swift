//
//  SplashViewController.swift
//  ImageFeed_8_sprint
//
//  Created by Марат Хасанов on 06.10.2023.
//

import UIKit
import ProgressHUD
import SwiftKeychainWrapper

//Будет "Дережировать" выбором нужного нам флоу приложения в зависимости от условий
class SplashViewController: UIViewController {
    private let authenticationSegueIdentifier = "ShowAuthenticationScreen"
    private let profileService = ProfileSevice.shared
    private let profileImageService = ProfileImageService.shared
    private let oauth2Service = OAuth2Service()
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private let splashImage = UIImage(named: "logo_of_Unsplash")
    
    private lazy var imageView : UIImageView = {
        let imageView = UIImageView(image: splashImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if oauth2TokenStorage.token != nil {
            let token = oauth2TokenStorage.token!
            fetchProfile(token: token)
        } else {
            showAuthViewController()  
        }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSplashView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = UIColor(named: "YP BLACK")
        setNeedsStatusBarAppearanceUpdate()
    }
    
    private func setupSplashView(){
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func switchToTabBarViewController() {
        let scenes = UIApplication.shared.connectedScenes
        let windowScenes = scenes.first as? UIWindowScene
        guard let window = windowScenes?.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
    
    func showAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let authVC = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController {
            authVC.delegate = self
            authVC.modalPresentationStyle = .fullScreen
            present(authVC, animated: true)
        }
    }
}
    
extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == authenticationSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else { fatalError("Faild to prepare for \(authenticationSegueIdentifier)") }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            UIBlockingProgressHUD.show()
            self.fetchOAuthToken(code)
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                fetchProfile(token: token)
            case .failure:
                showAlert(message: "Не удалост войти в систему")
                break
            }
            UIBlockingProgressHUD.dismiss()
        }
    }
    
    private func fetchProfile(token: String) {
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                guard let username = profileService.profile?.username else { return }
                fetchProfileImage(username: username, token: token)
                self.switchToTabBarViewController()
            case .failure:
                showAlert(message: "Не удалось получить данные профиля")
            }
            UIBlockingProgressHUD.dismiss()
        }
    }
    
    private func fetchProfileImage(username: String, token: String) {
        profileImageService.fetchProfileImageURL(username: username, token: token) { _ in
            UIBlockingProgressHUD.dismiss()
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Что-то пошло не так", message: message, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.showAuthViewController()
        })
        self.present(alert, animated: true, completion: nil)
    }
}



