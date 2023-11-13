//
//  ImageFeed_8_sprintUITests.swift
//  ImageFeed_8_sprintUITests
//
//  Created by Марат Хасанов on 09.11.2023.
//

import XCTest

final class ImageFeed_8_sprintUITests: XCTestCase {
    //переменная приложения
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        //стопнет тесты, если что-то не так
        continueAfterFailure = false
        
        app.launch() //запускаем прилу
    }
    
    func testAuth() throws {
        //тест авторизации
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["UnsplashWebView"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 3))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText("mvtvr21@yandex.ru")
        webView.swipeUp()
        
        let passwordTextFiel = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextFiel.waitForExistence(timeout: 5))
        
        passwordTextFiel.tap()
        passwordTextFiel.typeText("Mighty59311")
        webView.swipeUp()
        
        let webViewsQuery = webView.descendants(matching: .button).element
        webViewsQuery.buttons["Login"].tap()
            
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
            
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
        
        print(app.debugDescription)
        
    }
    
    func testFeed() throws {
        //тест ленты
        let tablesQuery = app.tables
        
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        sleep(2)
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        
        cellToLike.buttons["like"].tap()
        sleep(2)
        cellToLike.buttons["dislike"].tap()
        sleep(2)
        
        cellToLike.tap()
        sleep(2)
    
        let image = app.scrollViews.images.element(boundBy: 0)
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButtonWhiteButton = app.buttons["nav back button white"]
        navBackButtonWhiteButton.tap()
    }
    
    func testProfile() throws {
        //тест профиля
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        XCTAssertTrue(app.staticTexts["Marat Khasanov"].exists)
        XCTAssertTrue(app.staticTexts["@blanxxty"].exists)
        
        app.buttons["logout button"].tap()
        
        app.alerts["Bye bye!"].scrollViews.otherElements.buttons["Yes"].tap()
    }
}
