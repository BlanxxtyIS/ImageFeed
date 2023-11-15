//
//  ImageFeed_8_sprintUITests.swift
//  ImageFeed_8_sprintUITests
//
//  Created by Марат Хасанов on 09.11.2023.
//

import XCTest

final class ImageFeed_8_sprintUITests: XCTestCase {
    enum Constraints {
      static let email = "@yandex.ru"
      static let password = ""
      static let name = "Marat Khasanov"
      static let login = "@Blanxxty"
    }
    //переменная приложения
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        //стопнет тесты, если что-то не так
        continueAfterFailure = false
        
        app.launch() //запускаем прилу
    }
    
    func testAuth() throws {
        XCTAssertTrue(app.buttons["Authenticate"].waitForExistence(timeout: 3))
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 3))
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 3))
        loginTextField.tap()
        loginTextField.typeText(Constraints.email)
        webView.tap()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 3))
        passwordTextField.tap()
        passwordTextField.typeText(Constraints.password)
        webView.tap()
        sleep(3)
        
        XCTAssertTrue(webView.buttons["Login"].waitForExistence(timeout: 3))
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
        
    }
    
    func testFeed() throws {
        XCTAssertTrue(app.tabBars.buttons.element(boundBy: 0).waitForExistence(timeout: 4))
        
        let tableQuery = app.tables
        let cell = tableQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 3))
        cell.swipeDown()
        sleep(2)
        
        let cellTwo = tableQuery.children(matching: .cell).element(boundBy: 1)
        XCTAssertTrue(cellTwo.waitForExistence(timeout: 3))
        XCTAssertTrue(cellTwo.buttons["LikeButton"].waitForExistence(timeout: 1))
        cellTwo.buttons["LikeButton"].tap()
        sleep(3)
        cellTwo.buttons["LikeButton"].tap()
        sleep(3)
        
        cellTwo.tap()
        sleep(3)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        
        XCTAssertTrue(app.buttons["BackButton"].waitForExistence(timeout: 3))
        app.buttons["BackButton"].tap()
    }
    
    func testProfile() throws {
        XCTAssertTrue(app.tabBars.buttons.element(boundBy: 1).waitForExistence(timeout: 3))
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        XCTAssertTrue(app.buttons["LogoutButton"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts[Constraints.name].exists)
        XCTAssertTrue(app.staticTexts[Constraints.login].exists)
        
        app.buttons["LogoutButton"].tap()
        
        XCTAssertTrue(app.alerts["Alert"].waitForExistence(timeout: 3))
        app.alerts["Alert"].buttons["Да"].tap()
        
        XCTAssertTrue(app.buttons["Authenticate"].waitForExistence(timeout: 3))
    }
}
