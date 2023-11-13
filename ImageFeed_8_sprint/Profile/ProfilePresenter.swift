//
//  ProfilePresenter.swift
//  ImageFeed_8_sprint
//
//  Created by Марат Хасанов on 13.11.2023.
//

import Foundation
import WebKit

protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerPrototcol? {get set}
    func viewDidLoad()
    func cleanTokenDataAndResetToAuth()
    func getProfileImage()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    private var profileImageService = ProfileImageService.shared
    private var profileService = ProfileSevice.shared
    
    weak var view: ProfileViewControllerPrototcol?
    
    func viewDidLoad() {
        getProfileImage()
        getProfileData()
    }
    
    func cleanTokenDataAndResetToAuth() {
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
        guard let window = UIApplication.shared.windows.first else {fatalError("Error")}
        window.rootViewController = SplashViewController()
        window.makeKeyAndVisible()
    }
    
    func getProfileImage() {
        guard
            let profileImageURL = profileImageService.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        view?.updateAvatar(url: url)
    }
    
    func getProfileData() {
        guard let profile = profileService.profile else { return }
        view?.updateProfile(profile: profile)
    }
}
