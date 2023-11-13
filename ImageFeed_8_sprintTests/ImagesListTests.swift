//
//  ImagesListTests.swift
//  ImageFeed_8_sprintTests
//
//  Created by Марат Хасанов on 13.11.2023.
//

import XCTest
@testable import  ImageFeed_8_sprint

final class ImagesListViewPresenterSpy: ImagesListViewPresenterProtocol {
    var view: ImageFeed_8_sprint.ImagesListViewControllerProtocol?
    
    var viewDidLoadCalled = false
    var updateTableViewAnimatedCalled = false
    var fetchPhotosCalled = false
    
    var calcHeightForRowAtCalled = false
    var calcHeightForRowAtIndex = false
    
    var chekIfNextPageNeededCalled = false
    var chekIfNextPageNeededAtIndex = false
    
    var imagesListCellDidTapLikeCalled = false
    var imagesListCellDidTapLikeAtIndex = false
    
    var returnPhotoCalled = false
    var returnPhotoAtIndex = false
    
    var photosCount = 0
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func updateTableViewAnimated() {
        updateTableViewAnimatedCalled = true
    }
    
    func fetchPhotos() {
        fetchPhotosCalled = true
    }
    
    func calculateHeightForRow(indexPath: IndexPath) -> CGFloat {
        calcHeightForRowAtCalled = true
        if indexPath == IndexPath(row: 1, section: 0) {
            calcHeightForRowAtIndex = true
        }
        return CGFloat(1)
    }
    
    func chekIfNextPageNeeded(indexPath: IndexPath) {
        chekIfNextPageNeededCalled = true
        if indexPath == IndexPath(row: 1, section: 0) {
            chekIfNextPageNeededAtIndex = true
        }
    }
    
    func imagesListCellDidTapLike(_ cell: ImageFeed_8_sprint.ImagesListCell, indexPath: IndexPath) {
        imagesListCellDidTapLikeCalled = true
        if indexPath == IndexPath(row: 1, section: 0) {
            imagesListCellDidTapLikeAtIndex = true
        }
    }
    
    func returnPhoto(indexPath: IndexPath) -> ImageFeed_8_sprint.Photo {
        returnPhotoCalled = true
        if indexPath == IndexPath(row: 1, section: 0) {
            returnPhotoAtIndex = true
        }
        return Photo.init(id: "test", size: CGSize(), createdAt: Date(), welcomeDescription: "test", thumbImageURL: URL(string: "https://www.yandex.ru")!, largeImageURL: URL(string: "https://www.yandex.ru")!, isLiked: false)
    }
}

final class ImagesListViewTests: XCTestCase {
    let viewController = ImagesListViewController()
    let presenter = ImagesListViewPresenterSpy()
    let indexPath = IndexPath(row: 1, section: 0)
    
    override func setUpWithError() throws {
      //viewController.presenter = presenter
      //presenter.view = viewController
    }
    
    func testViewDidLoadCalled() {
        _ = viewController.view
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testUpdateTableViewAnimated() {
        
        _ = viewController.view
        presenter.updateTableViewAnimated()
        
        XCTAssertTrue(presenter.updateTableViewAnimatedCalled)
    }
    
    func testFetchPhotos() {
        
        _ = viewController.view
        presenter.fetchPhotos()
        
        XCTAssertTrue(presenter.fetchPhotosCalled)
    }
    
    func testCalculateHeightForRow() {
        
        _ = viewController.view
        let result = presenter.calculateHeightForRow(indexPath: indexPath)
        
        XCTAssertTrue(presenter.calcHeightForRowAtCalled)
        XCTAssertTrue(presenter.calcHeightForRowAtIndex)
        XCTAssertEqual(result, CGFloat(1))
    }
    
    func testChekIfNextPageNeeded() {
        
        _ = viewController.view
        presenter.chekIfNextPageNeeded(indexPath: indexPath)
        
        XCTAssertTrue(presenter.chekIfNextPageNeededCalled)
        XCTAssertTrue(presenter.chekIfNextPageNeededAtIndex)
    }
    
    func testImagesListCellDidTapLike() {
        
        _ = viewController.view
        presenter.imagesListCellDidTapLike(ImagesListCell(), indexPath: indexPath)
        
        XCTAssertTrue(presenter.imagesListCellDidTapLikeCalled)
        XCTAssertTrue(presenter.imagesListCellDidTapLikeAtIndex)
    }
    
    func testReturnPhoto() {
        
        _ = viewController.view
        let _ = presenter.returnPhoto(indexPath: indexPath)
        
        XCTAssertTrue(presenter.returnPhotoCalled)
        XCTAssertTrue(presenter.returnPhotoAtIndex)
    }
}
