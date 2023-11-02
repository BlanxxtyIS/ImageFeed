//
//  Image_FeedTests.swift
//  Image FeedTests
//
//  Created by Марат Хасанов on 31.10.2023.
//

@testable import ImageFeed_8_sprint
import XCTest

final class ImagesListServiceTests: XCTestCase {
    func testFetchPhotos() {
            let service = ImageListService()
            
            let expectation = self.expectation(description: "Wait for Notification")
            NotificationCenter.default.addObserver(
                forName: ImageListService.didChangeNotification,
                object: nil,
                queue: .main) { _ in
                    expectation.fulfill()
                }
            
        service.fetchPhotosNextPage { result in
            print(result)
        }
            wait(for: [expectation], timeout: 10)
            
            XCTAssertEqual(service.photos.count, 10)
        }
}
