//
//  ProfileViewController.swift
//  ImageFeed_8_sprint
//
//  Created by Марат Хасанов on 19.09.2023.
//

import UIKit
import Kingfisher
import SwiftKeychainWrapper
import WebKit

final class ProfileViewController: UIViewController {
    
    private let storageToken = OAuth2TokenStorage()
    private let profileService = ProfileSevice.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    private let webViewViewController = WebViewViewController.shared
    
    //Создание_Настройка картинки
    private let imageView: UIImageView = {
        let profileImage = UIImage(named: "avatar")
        let imageView = UIImageView(image: profileImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    //Создание_Настройка Лейлбла под картинкой и его констрейнты
    private let nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.text = "Екатерина Новикова"
        nameLabel.textColor = UIColor(named: "YP White")
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        return nameLabel
    }()
    
    //Создание_Настройка лейбла, под первым лейблом и его констрейнты
    private let usernameLabel: UILabel = {
        let loginLabel = UILabel()
        loginLabel.text = "@ecaterina_nov"
        loginLabel.textColor = UIColor(named: "YP Gray")
        loginLabel.font = UIFont.systemFont(ofSize: 13)
        loginLabel.translatesAutoresizingMaskIntoConstraints = false
        return loginLabel
    }()
    
    //Создание_Настройка третего лейбла, и его констрейнты
    private let userDescription: UILabel = {
        let textLabel = UILabel()
        textLabel.text = "Hello, Wold!"
        textLabel.textColor = UIColor(named: "YP White")
        textLabel.font = UIFont(name: "Regular", size: 13)
        textLabel.numberOfLines = 0
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        return textLabel
    }()
    
    //Создание_Настройка кнопки
    private let button: UIButton = {
        let button = UIButton.systemButton(with: UIImage(named: "Exit")!,
                                           target: self,
                                           action: #selector(Self.didTapButton))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = UIColor(named: "YP Red")
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAllViews()
        setupAllConstaints()
        updateProfileDetails(profile: profileService.profile)
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(forName: ProfileImageService.didChangeNotification, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self.updateAvatar()
        }
        view.backgroundColor = UIColor(named: "YP BLACK")
        updateAvatar()
        
    }
    
    @objc private func didTapButton() {
        showLogoutAlert()
    }
    
    private func showLogoutAlert() {
        let alert = UIAlertController(
            title: "Выход",
            message: "Выйти из Вашего профиля?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            self.logout()
        }))
        alert.addAction(UIAlertAction(title: "Нет", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func cleanTokenDataAndResetToAuth() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()
        ) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(
                    ofTypes: record.dataTypes,
                    for: [record],
                    completionHandler: {}
                )
            }
        }
        OAuth2TokenStorage.deleteToken()
        guard let window = UIApplication.shared.windows.first else {fatalError("окно не обноружено")}
        window.rootViewController = SplashViewController()
        window.makeKeyAndVisible()
    }
    
    private func logout() {
        let logoutAccount: Bool = KeychainWrapper.standard.removeObject(forKey: "Auth token")
        WebViewViewController.clean()
        cleanServicesData()
        tabBarController?.dismiss(animated: true)
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration") }
        window.rootViewController = SplashViewController()
        window.makeKeyAndVisible()
    }
    
    private func cleanServicesData() {
        ImageListService.shared.clean()
        ProfileSevice.shared.clean()
        ProfileImageService.shared.clean()
    }
    
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else {return}
        let processor = RoundCornerImageProcessor(cornerRadius: imageView.frame.width)
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholder.svg"), options: [.processor(processor),.cacheSerializer(FormatIndicatedCacheSerializer.png)])
        let cache = ImageCache.default
        cache.clearDiskCache()
        cache.clearMemoryCache()
    }
    
    private func setupAllViews() {
        view.addSubview(imageView)
        view.addSubview(nameLabel)
        view.addSubview(usernameLabel)
        view.addSubview(userDescription)
        view.addSubview(button)
    }
    private func setupAllConstaints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            imageView.heightAnchor.constraint(equalToConstant: 70),
            imageView.widthAnchor.constraint(equalToConstant: 70),
            
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            usernameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            
            userDescription.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8),
            userDescription.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            
            button.widthAnchor.constraint(equalToConstant: 44),
            button.heightAnchor.constraint(equalToConstant: 44),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            button.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)])
    }
}

extension ProfileViewController {
    private func updateProfileDetails(profile: Profile?) {
        guard let profile = profileService.profile else { return }
        nameLabel.text = profile.name
        usernameLabel.text = profile.loginName
        userDescription.text = profile.bio
    }
}
