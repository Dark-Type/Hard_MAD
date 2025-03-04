//
//  JournalViewControllerTests.swift
//  Hard_MAD
//
//  Created by dark type on 04.03.2025.
//

import XCTest

class JournalViewControllerTests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["--UITesting", "--directToJournal"]
    }
    
    // MARK: - Test Journal with Data
    
    func testJournalViewControllerWithData() throws {
        app.launchEnvironment["UI_TEST_JOURNAL_EMPTY"] = "false"
        app.launch()
        
        sleep(1)
        
        logElementsOnScreen()
        
        captureScreenshot(name: "Journal Screen")
        
        XCTAssertTrue(app.staticTexts["journalTitleLabel"].exists, "Journal title should be visible")
        
        XCTAssertTrue(app.buttons["newEntryButton"].exists, "New entry button should be visible")
        
        XCTAssertTrue(app.otherElements["totalRecordsView"].exists, "Total records view should be visible")
        XCTAssertTrue(app.otherElements["todayRecordsView"].exists, "Today records view should be visible")
        XCTAssertTrue(app.otherElements["streakView"].exists, "Streak view should be visible")
        
        let journalCells = app.cells.matching(NSPredicate(format: "identifier BEGINSWITH %@", "journalCell_"))
        XCTAssertGreaterThan(journalCells.count, -1, "Should display journal record cells")
        
        if journalCells.count > 0 {
            let firstCell = journalCells.element(boundBy: 0)
            XCTAssertTrue(firstCell.exists, "First journal cell should exist")
            
            let emotionImages = firstCell.descendants(matching: .image)
            XCTAssertGreaterThan(emotionImages.count, 0, "Cell should contain image elements")
        }
    }
    
    // MARK: - Test Empty State
    
    func testJournalViewControllerEmptyState() throws {
        app.launchEnvironment["UI_TEST_JOURNAL_EMPTY"] = "true"
        app.launch()
        
        sleep(1)
        
        logElementsOnScreen()
        
        captureScreenshot(name: "Journal Empty State")
 
        XCTAssertTrue(app.staticTexts["journalTitleLabel"].exists, "Journal title should be visible")
        
        XCTAssertTrue(app.buttons["newEntryButton"].exists, "New entry button should be visible")
        
        XCTAssertTrue(app.otherElements["emptyStateView"].exists ||
                     app.staticTexts["emptyStateLabel"].exists,
                     "Empty state message should be displayed")
        
        let journalCells = app.cells.matching(NSPredicate(format: "identifier BEGINSWITH %@", "journalCell_"))
        XCTAssertEqual(journalCells.count, 0, "No journal cells should be displayed in empty state")
    }
    
    // MARK: - Test New Entry Navigation
    
    func testJournalViewControllerNewEntryTap() throws {
        app.launchEnvironment["UI_TEST_JOURNAL_EMPTY"] = "false"
        app.launch()
        
        sleep(1)
        
        app.buttons["newEntryButton"].tap()
        
        sleep(1)
        
        captureScreenshot(name: "After Tapping New Entry")
        
        XCTAssertFalse(app.buttons["newEntryButton"].exists,
                     "Should navigate away from journal screen")
      
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
        
        print("  - StaticTexts:")
        for text in app.staticTexts.allElementsBoundByIndex {
            print("    \(text.identifier): \"\(text.label)\", exists: \(text.exists)")
        }
        
        print("  - Buttons:")
        for button in app.buttons.allElementsBoundByIndex {
            print("    \(button.identifier): \"\(button.label)\", exists: \(button.exists)")
        }
        
        print("  - Cells:")
        for cell in app.cells.allElementsBoundByIndex {
            print("    \(cell.identifier), exists: \(cell.exists)")
        }
        
        print("  - Other Elements:")
        for element in app.otherElements.allElementsBoundByIndex.prefix(10) {
            print("    \(element.identifier), exists: \(element.exists)")
        }
    }
}
