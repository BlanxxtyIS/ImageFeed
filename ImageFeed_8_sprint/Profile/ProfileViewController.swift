//
//  ProfileViewController.swift
//  ImageFeed_8_sprint
//
//  Created by Марат Хасанов on 19.09.2023.
//

import UIKit

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Создание_Настройка картинки и его констрейны
        let profileImage = UIImage(named: "avatar")
        let imageView = UIImageView(image: profileImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        
        //Создание_Настройка Лейлбла под картинкой и его констрейнты
        let labelName = UILabel()
        labelName.text = "Екатерина Новикова"
        labelName.textColor = UIColor(named: "YP White")
        labelName.font = UIFont(name: "SFPro", size: 23)
        labelName.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        labelName.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(labelName)
        
        labelName.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
        labelName.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        
        //Создание_Настройка лейбла, под первым лейблом и его констрейнты
        let labelLogin = UILabel()
        labelLogin.text = "@ecaterina_nov"
        labelLogin.textColor = UIColor(named: "YP Gray")
        labelLogin.font = UIFont(name: "Regular", size: 13)
        labelLogin.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(labelLogin)
        
        labelLogin.topAnchor.constraint(equalTo: labelName.bottomAnchor, constant: 8).isActive = true
        labelLogin.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        
        //Создание_Настройка третего лейбла, и его констрейнты
        let labelText = UILabel()
        labelText.text = "Hello, Wold!"
        labelText.textColor = UIColor(named: "YP White")
        labelText.font = UIFont(name: "Regular", size: 13)
        labelText.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(labelText)
        
        labelText.topAnchor.constraint(equalTo: labelLogin.bottomAnchor, constant: 8).isActive = true
        labelText.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        
        //Создание_Настройка кнопки
        let button = UIButton.systemButton(with: UIImage(named: "Exit") ?? UIImage(), target: self, action: #selector(Self.didTapButton))
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        button.widthAnchor.constraint(equalToConstant: 44).isActive = true
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.tintColor = UIColor.red
        button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        button.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
    }
    @objc private func didTapButton() {
        for view in view.subviews {
            if view is UILabel {
                view.removeFromSuperview()
            }
        }
    }

}
