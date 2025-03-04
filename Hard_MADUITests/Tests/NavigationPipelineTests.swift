//
//  NavigationPipelineTests.swift
//  Hard_MAD
//
//  Created by dark type on 04.03.2025.
//

import XCTest

class NavigationPipelineTests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["--UITesting"]
        
        app.launchEnvironment["UI_TEST_LOGIN_SUCCESS"] = "true"
    }
    
    func testFullNavigationPipeline() throws {
        app.launch()
        
        sleep(2)
        
        captureScreenshot(name: "1-LoginScreen")
        
        if app.buttons["login_button"].exists {
            app.buttons["login_button"].tap()
            sleep(2)
        }
        
        captureScreenshot(name: "2-JournalScreen")
        XCTAssertTrue(app.buttons["newEntryButton"].exists, "Should be on Journal screen")
        XCTAssertTrue(app.tabBars.firstMatch.exists, "Tab bar should be visible")
        
        app.buttons["newEntryButton"].tap()
        sleep(2)
        
        captureScreenshot(name: "3-EmotionScreen")
        XCTAssertFalse(app.tabBars.firstMatch.isVisible, "Tab bar should be hidden on emotion screen")
        
        let emotionCells = app.cells.matching(NSPredicate(format: "identifier BEGINSWITH %@", "emotionCell_"))
        if emotionCells.count > 0 {
            emotionCells.element(boundBy: 0).tap()
            sleep(1)
            
            if app.buttons["continueButton"].exists {
                app.buttons["continueButton"].tap()
            } else if app.otherElements["emotionBottomView"].exists {
                app.otherElements["emotionBottomView"].tap()
            } else {
                let bottomCenter = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.95))
                bottomCenter.tap()
            }
            
            sleep(2)
            
            captureScreenshot(name: "4-RecordScreen")
            XCTAssertFalse(app.tabBars.firstMatch.isVisible, "Tab bar should be hidden on record screen")
            
            answerRecordQuestions()
            sleep(1)
            
            if app.buttons["saveButton"].exists && app.buttons["saveButton"].isEnabled {
                app.buttons["saveButton"].tap()
                sleep(2)
            } else {
                let savePosition = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9))
                savePosition.tap()
                sleep(2)
            }
            
            captureScreenshot(name: "5-BackToJournalScreen")
            XCTAssertTrue(app.tabBars.firstMatch.exists, "Tab bar should be visible again")
            
            sleep(3)
            
            if !app.staticTexts["Analysis"].exists && app.tabBars.buttons["analysisTab"].exists {
                app.tabBars.buttons["analysisTab"].tap()
                sleep(2)
            } else if !app.staticTexts["Analysis"].exists {
                app.tabBars.buttons.element(boundBy: 1).tap()
                sleep(2)
            }
            
            captureScreenshot(name: "6-AnalysisScreen")
            
            let analysisElements = [
                app.otherElements["weekSelectorView"],
                app.otherElements["navigationDotsView"],
                app.otherElements["dailyEmotionsView"],
                app.otherElements["weeklyEmotionsView"]
            ]
            
            XCTAssertTrue(analysisElements.contains { $0.exists }, "Should show Analysis screen elements")
            if app.tabBars.buttons["settingsTab"].exists {
                app.tabBars.buttons["settingsTab"].tap()
                sleep(2)
            } else {
                app.tabBars.buttons.element(boundBy: 2).tap()
                sleep(2)
            }
            
            captureScreenshot(name: "7-SettingsScreen")

            let settingsElements = app.cells.count > 0 || app.switches.count > 0 || app.buttons["logoutButton"].exists
            XCTAssertTrue(settingsElements, "Should show Settings screen elements")

            if app.tabBars.buttons["journalTab"].exists {
                app.tabBars.buttons["journalTab"].tap()
                sleep(1)
            } else {
                app.tabBars.buttons.element(boundBy: 0).tap()
                sleep(1)
            }
            
            captureScreenshot(name: "8-BackToJournalAgain")
            XCTAssertTrue(app.buttons["newEntryButton"].exists, "Should be back on Journal screen")
        } else {
            XCTFail("No emotion cells found on emotion screen")
        }
    }
    
    private func answerRecordQuestions() {
        let questionViews = app.otherElements.matching(NSPredicate(format: "identifier BEGINSWITH %@", "questionView_"))
        
        if questionViews.count > 0 {
            for i in 0..<questionViews.count {
                let answerCells = app.cells.matching(NSPredicate(format: "identifier BEGINSWITH %@", "answerCell_\(i)_"))
                if answerCells.count > 0 {
                    answerCells.element(boundBy: 0).tap()
                    sleep(UInt32(0.3))
                }
            }
        } else {
            let cells = app.cells
            if cells.count > 0 {
                for i in 0..<min(cells.count, 3) {
                    cells.element(boundBy: i).tap()
                    sleep(UInt32(0.3))
                }
            } else {
                let heights = [0.4, 0.6, 0.8]
                for height in heights {
                    app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: height)).tap()
                    sleep(UInt32(0.3))
                }
            }
        }
    }
    
    private func captureScreenshot(name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}

extension XCUIElement {
    var isVisible: Bool {
        guard exists && !frame.isEmpty else { return false }
        return XCUIApplication().windows.element(boundBy: 0).frame.contains(frame)
    }
}
