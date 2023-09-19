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
        
        //image
        let profileImage = UIImage(named: "avatar")
        let imageView = UIImageView(image: profileImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        
        //label1
        let labelName = UILabel()
        labelName.text = "Екатерина Новикова"
        labelName.textColor = UIColor(named: "YP White")
        labelName.font = UIFont(name: "SFPro-Bold", size: 23)
        labelName.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(labelName)
        
        labelName.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
        labelName.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        
        //label2
        let labelLogin = UILabel()
        labelLogin.text = "@ecaterina_nov"
        labelLogin.textColor = UIColor(named: "YP Gray")
        labelLogin.font = UIFont(name: "Regular", size: 13)
        labelLogin.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(labelLogin)
        
        labelLogin.topAnchor.constraint(equalTo: labelName.bottomAnchor, constant: 8).isActive = true
        labelLogin.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        
        //label3
        let labelText = UILabel()
        labelText.text = "Hello, Wold!"
        labelText.textColor = UIColor(named: "YP White")
        labelText.font = UIFont(name: "Regular", size: 13)
        labelText.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(labelText)
        
        labelText.topAnchor.constraint(equalTo: labelLogin.bottomAnchor, constant: 8).isActive = true
        labelText.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        
        //button
        let button = UIButton.systemButton(with: UIImage(named: "logout_button") ?? UIImage(), target: self, action: #selector(Self.didTapButton))
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
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
