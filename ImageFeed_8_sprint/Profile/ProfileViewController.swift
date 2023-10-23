//
//  ProfileViewController.swift
//  ImageFeed_8_sprint
//
//  Created by Марат Хасанов on 19.09.2023.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    private let storageToken = OAuth2TokenStorage()
    private let profileService = ProfileSevice.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
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
        loginLabel.font = UIFont(name: "Regular", size: 13)
        loginLabel.translatesAutoresizingMaskIntoConstraints = false
        return loginLabel
    }()
    
    //Создание_Настройка третего лейбла, и его констрейнты
    private let userDescription: UILabel = {
        let textLabel = UILabel()
        textLabel.text = "Hello, Wold!"
        textLabel.textColor = UIColor(named: "YP White")
        textLabel.font = UIFont(name: "Regular", size: 13)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        return textLabel
    }()
    
    //Создание_Настройка кнопки
    private let button: UIButton = {
        let button = UIButton.systemButton(with: UIImage(named: "Exit")!, target: self, action: #selector(Self.didTapButton))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = UIColor(named: "YP Red")
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAllViews()
        setupAllConstaints()
        updateProfileDetails(profile: profileService.profile)
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(forName: ProfileImageService.DidChangeNotification, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self.updateAvatar()
        }
        updateAvatar()
        
    }
    
    @objc private func didTapButton() {
        print("Tab Back Button")
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
