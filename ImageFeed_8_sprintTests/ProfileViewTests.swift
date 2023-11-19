//
//  ProfileViewTests.swift
//  ImageFeed_8_sprintTests
//
//  Created by Марат Хасанов on 13.11.2023.
//

import XCTest
@testable import ImageFeed_8_sprint

    
final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ImageFeed_8_sprint.ProfilePresenterProtocol?
    
    var viewDidUpdateAvatar = false
    var viewDidUpdateProfile = false
    
    var profileFullNameLable = UILabel()
    var profileLoginNameLable = UILabel()
    var profileUserNameLable = UILabel()
    var profileDescriptionLable = UILabel()
    
    func updateAvatar(url: URL) {
        viewDidUpdateAvatar = true
    }
    
    func updateProfile(profile: ImageFeed_8_sprint.Profile) {
        viewDidUpdateProfile = true
        profileFullNameLable.text = profile.name
        profileLoginNameLable.text = profile.loginName
        profileUserNameLable.text = profile.username
        profileDescriptionLable.text = profile.bio
    }
}
final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var view: ImageFeed_8_sprint.ProfileViewControllerProtocol?
    
    var viewDidLoadCalled = false
    var cleanTokenDataAndResetToAuthCalled = false
    var getProfileUrlCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func cleanTokenDataAndResetToAuth() {
        cleanTokenDataAndResetToAuthCalled = true
    }
    
    func getProfileImage() {
        getProfileUrlCalled = true
    }
}
    
final class ProfilePresenterTests: XCTestCase {
    
    let viewController = ProfileViewController()
    let presenter = ProfilePresenterSpy()
    
    override func setUpWithError() throws {
        viewController.presenter = presenter
        presenter.view = viewController as? any ProfileViewControllerProtocol
    }
    
    func testViewControllerCallViewDidLoad() {
        
        _ = viewController.view
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testCleanTokenDataAndResetToAuth() {
        
        _ = viewController.view
        presenter.cleanTokenDataAndResetToAuth()
        
        XCTAssertTrue(presenter.cleanTokenDataAndResetToAuthCalled)
    }
    
    func testGetProfileImageUrl() {
        
        _ = viewController.view
        presenter.getProfileImage()
        
        XCTAssertTrue(presenter.getProfileUrlCalled)
    }
}
    
final class ProfileViewControllerTests: XCTestCase {
    
    let viewController = ProfileViewControllerSpy()
    let presenter = ProfilePresenter()
    
    func testUpdateProfileCall() {
        
        let testUser = "test"
        let testProfile = Profile(from: ProfileResult(username: testUser, firstName: testUser, lastName: testUser, bio: testUser))
        
        viewController.updateProfile(profile: testProfile)
        
        XCTAssertTrue(viewController.viewDidUpdateProfile)
        XCTAssertEqual(viewController.profileUserNameLable.text, testProfile.username)
        XCTAssertEqual(viewController.profileFullNameLable.text, testProfile.name)
        XCTAssertEqual(viewController.profileLoginNameLable.text, testProfile.loginName)
        XCTAssertEqual(viewController.profileDescriptionLable.text, testProfile.bio)
    }
    
    func testUpdateAvatarCall() {
        let testUrl = URL(string: "https://www.google.com")!
        
        viewController.updateAvatar(url: testUrl)
        
        XCTAssertTrue(viewController.viewDidUpdateAvatar)
    }
}

