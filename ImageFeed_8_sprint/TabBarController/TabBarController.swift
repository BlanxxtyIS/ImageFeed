//
//  TabBarController.swift
//  ImageFeed_8_sprint
//
//  Created by Марат Хасанов on 23.10.2023.
//

import Foundation
import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarView()
        setupTabBarItems()
    }
}
    
extension TabBarController {
    private func setupTabBarView() {
        tabBar.barStyle = .black
        tabBar.tintColor = .ypWhite
        tabBar.backgroundColor = .ypBlack
    }
    
    private func setupTabBarItems() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let imagesListPresenter = ImagesListViewPresenter()
        let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController")
        guard let imagesListViewController = imagesListViewController as? ImagesListViewController else { return }
        imagesListPresenter.view = imagesListViewController
        imagesListViewController.presenter = imagesListPresenter
        setupTabBarItemImage(for: imagesListViewController, image: "tab_editorial_active")
        
 
        let profilePresenter = ProfilePresenter()
        let profileViewController = storyboard.instantiateViewController(withIdentifier: "ProfileViewController")
        guard let profileViewController = profileViewController as? ProfileViewController else { return }
        profilePresenter.view = profileViewController as? any ProfileViewControllerProtocol
        profileViewController.presenter = profilePresenter
        setupTabBarItemImage(for: profileViewController, image: "tab_profile_active")
        
        viewControllers = [imagesListViewController, profileViewController]
        selectedIndex = 0
    }
    
    private func setupTabBarItemImage(for viewController: UIViewController, image: String) {
        viewController.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: image), selectedImage: nil)
    }
}

extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        selectedViewController = viewController
    }
}
