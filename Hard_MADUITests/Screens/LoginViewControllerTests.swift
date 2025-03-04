//
//  LoginViewControllerTests.swift
//  Hard_MAD
//
//  Created by dark type on 04.03.2025.
//

import XCTest

class LoginViewControllerTests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false

        app.launchArguments = ["--UITesting"]
        
        print("🧪 Setting up UI test with arguments: \(app.launchArguments)")
    }
    
    // MARK: - Test Normal Login Flow
    
    func testLoginViewControllerBasicElements() throws {
        app.launchEnvironment["UI_TEST_LOGIN_SUCCESS"] = "true"
        app.launchEnvironment["UI_TEST_LOGIN_ERROR"] = "false"
        
        print("🧪 Launch environment: \(app.launchEnvironment)")
        app.launch()
        
        sleep(1)
        
        XCTAssertTrue(app.staticTexts["welcome_label"].exists, "Welcome label should be visible")
        XCTAssertTrue(app.buttons["login_button"].exists, "Login button should be visible")
        
        captureScreenshot(name: "Login Screen")
        
        app.buttons["login_button"].tap()
        
        let loadingView = app.otherElements["loading_view"]
        if loadingView.exists {
            let disappeared = waitForElementToDisappear(loadingView, timeout: 5)
            XCTAssertTrue(disappeared, "Loading indicator should disappear")
        }
        
        sleep(2)
        
        captureScreenshot(name: "After Login")
        
        XCTAssertFalse(app.staticTexts["welcome_label"].exists, "Should navigate away from login screen")
    }
    
    // MARK: - Test Error State
    
    func testLoginViewControllerErrorState() throws {
        app.launchEnvironment["UI_TEST_LOGIN_SUCCESS"] = "false"
        app.launchEnvironment["UI_TEST_LOGIN_ERROR"] = "true"
        
        print("🧪 Launch environment for error test: \(app.launchEnvironment)")
        app.launch()
        
        sleep(1)
        
        XCTAssertTrue(app.staticTexts["welcome_label"].exists, "Welcome label should be visible")
        XCTAssertTrue(app.buttons["login_button"].exists, "Login button should be visible")
        
        app.buttons["login_button"].tap()
        
        let loadingView = app.otherElements["loading_view"]
        if loadingView.exists {
            let disappeared = waitForElementToDisappear(loadingView, timeout: 5)
            XCTAssertTrue(disappeared, "Loading indicator should disappear")
        }
        
        logElementsOnScreen()
        
        let alert = app.alerts.element
        let alertExists = waitForElement(alert, timeout: 5)
        XCTAssertTrue(alertExists, "Error alert should appear")
        
        captureScreenshot(name: "Login Error Alert")
        
        if alert.exists {
            alert.buttons["OK"].tap()
        }
        
        XCTAssertTrue(app.staticTexts["welcome_label"].exists, "Should remain on login screen after error")
        XCTAssertTrue(app.buttons["login_button"].exists, "Login button should still be visible")
    }
    
    // MARK: - Helper Methods
    
    private func waitForElement(_ element: XCUIElement, timeout: TimeInterval) -> Bool {
        let predicate = NSPredicate(format: "exists == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
    
    private func waitForElementToDisappear(_ element: XCUIElement, timeout: TimeInterval) -> Bool {
        let predicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
    
    private func captureScreenshot(name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    private func logElementsOnScreen() {
        print("🧪 Elements on screen:")
        print("  - Buttons: \(app.buttons.count)")
        for i in 0..<min(app.buttons.count, 5) {
            let button = app.buttons.element(boundBy: i)
            print("    [\(i)]: \(button.identifier) - \(button.label)")
        }
        
        print("  - Alerts: \(app.alerts.count)")
        for i in 0..<app.alerts.count {
            let alert = app.alerts.element(boundBy: i)
            print("    [\(i)]: \(alert.identifier) - \(alert.label)")
        }
        
        print("  - StaticTexts: \(app.staticTexts.count)")
        for i in 0..<min(app.staticTexts.count, 5) {
            let text = app.staticTexts.element(boundBy: i)
            print("    [\(i)]: \(text.identifier) - \(text.label)")
        }
    }
}
