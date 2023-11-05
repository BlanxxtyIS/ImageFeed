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
            guard let token = oauth2TokenStorage.token else { return }
            fetchProfile(token: token)
        } else {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            guard let authViewController = storyBoard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else { return }
            authViewController.delegate = self
            authViewController.modalPresentationStyle = .fullScreen
            self.present(authViewController, animated: true)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = UIColor(named: "YP BLACK")
        setupSplashView()
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
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid Configuration")
            return
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
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
        UIBlockingProgressHUD.show()
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code)
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                self.oauth2TokenStorage.token = token
                self.fetchProfile(token: token)
            case .failure(let error):
                self.showAlert(with: error)
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
                guard let username = self.profileService.profile?.username else { return }
                self.profileImageService.fetchProfileImageURL(username: username) { _ in }
                DispatchQueue.main.async {
                    self.switchToTabBarViewController()
                }
            case .failure(let error):
                self.showAlert(with: error)
                print(error)
                break
            }
            UIBlockingProgressHUD.dismiss()
        }
    }

    
    private func showAlert(with error: Error) {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Не удалось войти в систему",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }
}



