//
//  EmotionViewControllerTests.swift
//  Hard_MAD
//
//  Created by dark type on 04.03.2025.
//

import XCTest

class EmotionViewControllerDirectTests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["--UITesting", "--directToEmotion"]
    }
    
    // MARK: - Test Basic UI Elements
    
    func testEmotionViewControllerBasicElements() throws {
        app.launch()
        
        sleep(1)
        
        logElementsOnScreen()
        
        captureScreenshot(name: "Direct Emotion Screen")
        
        XCTAssertTrue(app.buttons["emotionBackButton"].exists, "Back button should be visible")
        XCTAssertTrue(app.otherElements["emotionGridContainer"].exists, "Emotion grid container should be visible")
        XCTAssertTrue(app.collectionViews["emotionsCollectionView"].exists, "Emotions collection view should be visible")
        XCTAssertTrue(app.otherElements["emotionBottomView"].exists, "Bottom view should be visible")
        
        let emotionCells = app.cells.matching(NSPredicate(format: "identifier BEGINSWITH %@", "emotionCell_"))
        XCTAssertGreaterThan(emotionCells.count, 0, "Should display emotion cells")
        XCTAssertEqual(emotionCells.count, 16, "Should display 16 emotion cells")
    }
    
    // MARK: - Test Emotion Selection and Bottom View Interaction
    
    func testEmotionSelectionAndBottomView() throws {
        app.launch()
        
        sleep(1)
        
        let bottomView = app.otherElements["emotionBottomView"]
        XCTAssertTrue(bottomView.exists, "Bottom view should exist")
     
        logCells()
        
        let emotionCells = app.cells.matching(NSPredicate(format: "identifier BEGINSWITH %@", "emotionCell_"))
        if emotionCells.count > 0 {
            let firstEmotionCell = emotionCells.element(boundBy: 0)
            firstEmotionCell.tap()
            
            sleep(1)
            
            XCTAssertEqual(bottomView.value as? String, "active", "Bottom view should be active after selecting emotion")
            
            bottomView.tap()

            sleep(1)
            
            XCTAssertFalse(app.collectionViews["emotionsCollectionView"].exists, "Should navigate away from emotion screen")
            
    
            captureScreenshot(name: "After Emotion Selection")
        } else {
            XCTFail("No emotion cells found with proper identifiers")
        }
    }
    
    // MARK: - Test Preselected Emotion
    
    func testEmotionScreenWithPreselectedEmotion() throws {
        app.launchEnvironment["UI_TEST_EMOTION_NAME"] = "happy"
        app.launch()
        
        sleep(1)
        
        captureScreenshot(name: "Emotion Screen with Preselected Emotion")
        
        let bottomView = app.otherElements["emotionBottomView"]
        XCTAssertEqual(bottomView.value as? String, "active", "Bottom view should be active with preselected emotion")
    }
    
    // MARK: - Helper Methods
    
    private func waitForElement(_ element: XCUIElement, timeout: TimeInterval) -> Bool {
        let predicate = NSPredicate(format: "exists == true")
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
        
        print("  - Buttons:")
        for button in app.buttons.allElementsBoundByIndex {
            print("    \(button.identifier): \"\(button.label)\", exists: \(button.exists)")
        }
        
        print("  - Collection Views:")
        for collectionView in app.collectionViews.allElementsBoundByIndex {
            print("    \(collectionView.identifier), exists: \(collectionView.exists)")
        }
        
        print("  - Other Elements:")
        for element in app.otherElements.allElementsBoundByIndex.prefix(10) {
            print("    \(element.identifier), label: \"\(element.label)\", value: \(element.value ?? "nil"), exists: \(element.exists)")
        }
    }
    
    private func logCells() {
        print("🧪 Cells on screen:")
        for cell in app.cells.allElementsBoundByIndex {
            print("    \(cell.identifier), exists: \(cell.exists)")
        }
    }
    
    private func waitForElementToDisappear(_ element: XCUIElement, timeout: TimeInterval) -> Bool {
        let predicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
}
