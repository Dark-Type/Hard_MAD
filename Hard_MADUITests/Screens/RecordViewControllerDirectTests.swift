//
//  RecordViewControllerTests.swift
//  Hard_MAD
//
//  Created by dark type on 04.03.2025.
//

import XCTest

class RecordViewControllerDirectTests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["--UITesting", "--directToEmotion"]
    }
    
    // MARK: - Test Normal Record Flow
    
    func testRecordViewControllerWithData() throws {
        app.launchEnvironment["UI_TEST_EMOTION_NAME"] = "happy"
        app.launch()
        
        sleep(1)
        
        let bottomView = app.otherElements["emotionBottomView"]
        XCTAssertTrue(bottomView.exists, "Bottom view should exist")
        
        captureScreenshot(name: "Emotion Screen - Pre-selected")
        
        bottomView.tap()
        
        sleep(2)
        
        logElementsOnScreen()
        
        captureScreenshot(name: "Record Screen - Initial State")
        
        XCTAssertTrue(app.buttons["backButton"].exists, "Back button should be visible")
        XCTAssertTrue(app.staticTexts["recordTitleLabel"].exists, "Title should be visible")
        XCTAssertTrue(app.buttons["saveButton"].exists, "Save button should be visible")
        
        let allAnswerCells = app.cells.matching(NSPredicate(format: "identifier BEGINSWITH 'answerCell_'"))
        
        var answersByQuestion: [Int: [XCUIElement]] = [:]
        for cell in allAnswerCells.allElementsBoundByIndex {
            if let questionNum = extractQuestionNumberFromIdentifier(cell.identifier) {
                if answersByQuestion[questionNum] == nil {
                    answersByQuestion[questionNum] = []
                }
                answersByQuestion[questionNum]?.append(cell)
            }
        }
        
        print("🧪 Found answers for \(answersByQuestion.count) questions")
        for (questionNum, cells) in answersByQuestion {
            if cells.count > 0 {
                print("🧪 Selecting answer for question \(questionNum)")
                cells[0].tap()
                sleep(UInt32(0.5))
                captureScreenshot(name: "After answering question \(questionNum)")
            }
        }
        
        let questionViews = app.otherElements.matching(NSPredicate(format: "identifier BEGINSWITH 'questionView_'"))
        if answersByQuestion.count < questionViews.count {
            for i in 0 ..< questionViews.count {
                if answersByQuestion[i] == nil || answersByQuestion[i]?.isEmpty == true {
                    let plusCell = app.cells["plusCell_\(i)"]
                    if plusCell.exists {
                        print("🧪 Adding custom answer for question \(i)")
                        plusCell.tap()
                        sleep(UInt32(0.5))
                        
                        let textField = app.textFields["answerTextField_\(i)"]
                        if textField.exists {
                            textField.tap()
                            textField.typeText("Custom answer for question \(i)")
                            textField.typeText("\n")
                            sleep(UInt32(0.5))
                        }
                    }
                }
            }
        }

        sleep(1)
        captureScreenshot(name: "All Questions Answered")
        
        let saveButton = app.buttons["saveButton"]
        let isEnabled = saveButton.isEnabled
        print("🧪 Save button enabled: \(isEnabled)")
        
        if !isEnabled {
            let remainingCells = app.cells.matching(NSPredicate(format: "identifier BEGINSWITH 'answerCell_'"))
            for cell in remainingCells.allElementsBoundByIndex {
                cell.tap()
                sleep(UInt32(0.3))
            }
            
            sleep(1)
            print("🧪 Save button enabled after additional taps: \(saveButton.isEnabled)")
        }
        
        XCTAssertTrue(saveButton.isEnabled, "Save button should be enabled after answering all questions")
        
        saveButton.tap()
        
        sleep(3)
        
        captureScreenshot(name: "After Record Completion")
        
        XCTAssertTrue(app.buttons["newEntryButton"].exists ||
            app.staticTexts["journalTitleLabel"].exists,
            "Should navigate to journal screen after saving")
    }
    
    // MARK: - Test Navigation
    
    func testRecordViewNavigationBack() throws {
        app.launchEnvironment["UI_TEST_EMOTION_NAME"] = "happy"
        app.launch()
        
        sleep(1)
        
        app.otherElements["emotionBottomView"].tap()
        
        sleep(1)
        
        XCTAssertTrue(app.buttons["backButton"].exists, "Back button should be visible")
        XCTAssertTrue(app.staticTexts["recordTitleLabel"].exists, "Record title should be visible")
        
        captureScreenshot(name: "Record Screen")
        
        app.buttons["backButton"].tap()
        
        sleep(1)
        
        XCTAssertTrue(app.collectionViews.element.exists, "Should return to emotion screen")
        XCTAssertTrue(app.otherElements["emotionBottomView"].exists, "Bottom view should be visible")
        
        captureScreenshot(name: "Back to Emotion Screen")
    }
    
    // MARK: - Helper Methods
    
    private func extractQuestionNumberFromIdentifier(_ identifier: String) -> Int? {
        let components = identifier.components(separatedBy: "_")
        if components.count >= 2, let questionNum = Int(components[1]) {
            return questionNum
        }
        return nil
    }
    
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
    
    private func waitForElementToDisappear(_ element: XCUIElement, timeout: TimeInterval) -> Bool {
        let predicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
    
    private func logElementsOnScreen() {
        print("🧪 Elements on screen:")
        
        print("  - Buttons:")
        for button in app.buttons.allElementsBoundByIndex {
            print("    \(button.identifier): \"\(button.label)\", enabled: \(button.isEnabled)")
        }
        
        print("  - Static Texts:")
        for text in app.staticTexts.allElementsBoundByIndex.prefix(15) {
            print("    \(text.identifier): \"\(text.label)\"")
        }
        
        print("  - Other Elements:")
        for element in app.otherElements.allElementsBoundByIndex.prefix(15) {
            print("    \(element.identifier)")
        }
        
        print("  - Collection Views:")
        for cv in app.collectionViews.allElementsBoundByIndex {
            print("    \(cv.identifier), cells: \(cv.cells.count)")
        }
        
        print("  - Text Fields:")
        for tf in app.textFields.allElementsBoundByIndex {
            print("    \(tf.identifier)")
        }
        
        print("  - Cells:")
        for cell in app.cells.allElementsBoundByIndex.prefix(20) {
            print("    \(cell.identifier)")
        }
    }
}
