//
//  AnalysisViewControllerTests.swift
//  Hard_MAD
//
//  Created by dark type on 04.03.2025.
//

import XCTest

class AnalysisViewControllerTests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["--UITesting", "--directToAnalysis"]
    }
    
    // MARK: - Basic UI Elements Tests
    
    func testAnalysisUIElements() throws {
        app.launch()
        
        sleep(2)
        
        logElementsOnScreen()
        
        captureScreenshot(name: "Analysis Screen - Initial State")
        
        let weekSelectorExists = app.otherElements["weekSelectorView"].exists ||
            app.collectionViews.firstMatch.exists
        XCTAssertTrue(weekSelectorExists, "Week selector should be visible")
        
        let navigationDotsExists = app.otherElements["navigationDotsView"].exists ||
            app.otherElements.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "navigationDot_")).count > 0
        XCTAssertTrue(navigationDotsExists, "Navigation dots should be visible")
        
        XCTAssertTrue(app.scrollViews.firstMatch.exists, "Main scroll view should be visible")
    }
    
    // MARK: - Section Navigation Tests
    
    func testNavigationDots() throws {
        app.launch()
        
        sleep(2)
        
        let navigationDotsView = app.otherElements["navigationDotsView"]
        
        XCTAssertTrue(navigationDotsView.exists, "Navigation dots view should be visible")
        
        captureScreenshot(name: "Navigation Dots - Initial State")
        
        let navigationDots = app.otherElements.matching(NSPredicate(format: "identifier BEGINSWITH %@", "navigationDot_"))
        
        if navigationDots.count > 0 {
            for i in 0..<navigationDots.count {
                let dot = navigationDots.element(boundBy: i)
                if dot.exists {
                    dot.tap()
                    sleep(1)
                    captureScreenshot(name: "After tapping navigation dot \(i)")
                }
            }
        } else {
            print("🧪 Could not find navigation dots by identifier, trying alternative approach")
            logElementsOnScreen()
            
            if navigationDotsView.exists {
                let yPositions = [0.2, 0.4, 0.6, 0.8]
                
                for (i, yPosition) in yPositions.enumerated() {
                    let dotCoordinate = navigationDotsView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: yPosition))
                    dotCoordinate.tap()
                    sleep(1)
                    captureScreenshot(name: "After tapping approximate dot position \(i)")
                }
            } else {
                let rightEdgeX = app.windows.element(boundBy: 0).frame.maxX - 10
                let screenHeight = app.windows.element(boundBy: 0).frame.height
                
                let yPositions = [screenHeight * 0.3, screenHeight * 0.4, screenHeight * 0.6, screenHeight * 0.7]
                
                for (i, yPos) in yPositions.enumerated() {
                    app.coordinate(withNormalizedOffset: .zero).withOffset(CGVector(dx: rightEdgeX, dy: yPos)).tap()
                    sleep(1)
                    captureScreenshot(name: "After tapping right edge position \(i)")
                }
                
                XCTFail("Could not find navigation dots view")
            }
        }
    }
    
    // MARK: - Week Selection Tests
    
    func testWeekSelector() throws {
        app.launch()
        
        sleep(2)
        
        let weekCells = app.cells.matching(NSPredicate(format: "identifier BEGINSWITH %@", "weekCell_"))
        
        if weekCells.count > 0 {
            captureScreenshot(name: "Week Selector - Initial State")
            
            let startIndex = weekCells.count > 1 ? 1 : 0
            
            for i in startIndex..<min(startIndex + 3, weekCells.count) {
                weekCells.element(boundBy: i).tap()
                sleep(1)
                captureScreenshot(name: "After selecting week at index \(i)")
            }
            
            if weekCells.count > 1 {
                weekCells.element(boundBy: 0).tap()
                sleep(1)
                captureScreenshot(name: "After returning to first week")
            }
        } else {
            let collectionView = app.collectionViews.firstMatch
            if collectionView.exists {
                let rightEdge = collectionView.coordinate(withNormalizedOffset: CGVector(dx: 0.8, dy: 0.5))
                rightEdge.tap()
                sleep(1)
                captureScreenshot(name: "After tapping right edge of week selector")
                
                let leftEdge = collectionView.coordinate(withNormalizedOffset: CGVector(dx: 0.2, dy: 0.5))
                leftEdge.tap()
                sleep(1)
                captureScreenshot(name: "After tapping left edge of week selector")
            } else {
                XCTFail("Week selector UI elements not found")
            }
        }
    }
    
    // MARK: - Scroll Tests
    
    func testScrolling() throws {
        app.launch()
        
        sleep(2)
        
        XCTAssertTrue(app.scrollViews.firstMatch.exists, "Scroll view should be visible")
        
        captureScreenshot(name: "Before Scrolling")
        
        let scrollView = app.scrollViews.firstMatch
        
        for i in 1...4 {
            scrollView.swipeUp()
            sleep(UInt32(0.5))
            captureScreenshot(name: "After scrolling down \(i)")
        }
        
        for i in 1...4 {
            scrollView.swipeDown()
            sleep(UInt32(0.5))
            captureScreenshot(name: "After scrolling up \(i)")
        }
    }
    
    // MARK: - Empty State Tests
    
    func testEmptyState() throws {
        app.launchEnvironment["UI_TEST_EMPTY_ANALYSIS"] = "true"
        app.launch()
        
        sleep(2)
        
        logElementsOnScreen()
        
        captureScreenshot(name: "Empty Analysis State")
        
        XCTAssertTrue(app.otherElements["emptyStateView"].exists, "Empty state view should be visible")
        
        let emptyMessage = app.staticTexts.element(matching: NSPredicate(format: "label CONTAINS[c] %@", "добавьте эмоции"))
        XCTAssertTrue(emptyMessage.exists, "Empty state message should mention adding emotions")
        
        XCTAssertTrue(app.otherElements["weekSelectorView"].exists, "Week selector should still be visible")
    }
    
    // MARK: - Combined Interaction Test
    
    func testFullInteraction() throws {
        app.launch()
        
        sleep(2)
        
        captureScreenshot(name: "1. Initial State")
        
        let weekCells = app.cells.matching(NSPredicate(format: "identifier BEGINSWITH %@", "weekCell_"))
        if weekCells.count > 1 {
            weekCells.element(boundBy: 1).tap()
            sleep(1)
            captureScreenshot(name: "2. After Selecting Different Week")
        } else {
            let collectionView = app.collectionViews.firstMatch
            if collectionView.exists {
                collectionView.coordinate(withNormalizedOffset: CGVector(dx: 0.8, dy: 0.5)).tap()
                sleep(1)
                captureScreenshot(name: "2. After Attempting Week Change")
            }
        }
        
        app.scrollViews.firstMatch.swipeUp()
        sleep(UInt32(0.5))
        captureScreenshot(name: "3. After First Scroll")
        
        app.scrollViews.firstMatch.swipeUp()
        sleep(UInt32(0.5))
        captureScreenshot(name: "4. After Second Scroll")

        let navigationDots = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "navigationDot_"))
        if navigationDots.count > 2 {
            navigationDots.element(boundBy: 0).tap()
            sleep(1)
            captureScreenshot(name: "5. After Tapping First Dot")
            
            navigationDots.element(boundBy: 2).tap()
            sleep(1)
            captureScreenshot(name: "6. After Tapping Third Dot")
        } else {
            let possibleDotsArea = app.coordinate(withNormalizedOffset: CGVector(dx: 0.95, dy: 0.3))
            possibleDotsArea.tap()
            sleep(1)
            captureScreenshot(name: "5. After Tapping Possible Dot Area (Top)")
            
            let secondPossibleDotArea = app.coordinate(withNormalizedOffset: CGVector(dx: 0.95, dy: 0.7))
            secondPossibleDotArea.tap()
            sleep(1)
            captureScreenshot(name: "6. After Tapping Possible Dot Area (Bottom)")
        }
        
        if weekCells.count > 0 {
            weekCells.element(boundBy: 0).tap()
            sleep(1)
            captureScreenshot(name: "7. After Returning to First Week")
        }
        
        app.scrollViews.firstMatch.swipeUp(velocity: .slow)
        sleep(UInt32(0.5))
        app.scrollViews.firstMatch.swipeUp(velocity: .slow)
        sleep(UInt32(0.5))
        app.scrollViews.firstMatch.swipeUp(velocity: .slow)
        sleep(UInt32(1))
        captureScreenshot(name: "8. At Bottom of Content")
        
        app.scrollViews.firstMatch.swipeDown(velocity: .fast)
        sleep(UInt32(0.5))
        app.scrollViews.firstMatch.swipeDown(velocity: .fast)
        sleep(UInt32(0.5))
        captureScreenshot(name: "9. After Returning to Top")
    }
    
    // MARK: - Helper Methods
    
    private func captureScreenshot(name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    private func logElementsOnScreen() {
        print("🧪 Analysis Screen Elements:")
        
        print("  - Collection Views:")
        for collectionView in app.collectionViews.allElementsBoundByIndex {
            print("    \(collectionView.identifier)")
        }
        
        print("  - Scroll Views:")
        for scrollView in app.scrollViews.allElementsBoundByIndex {
            print("    \(scrollView.identifier)")
        }
        
        print("  - Static Texts:")
        for text in app.staticTexts.allElementsBoundByIndex {
            print("    \(text.identifier): \"\(text.label)\"")
        }
        
        print("  - Buttons:")
        for button in app.buttons.allElementsBoundByIndex {
            print("    \(button.identifier): \"\(button.label)\"")
        }
        
        print("  - Other Elements:")
        for element in app.otherElements.allElementsBoundByIndex.prefix(15) {
            print("    \(element.identifier)")
        }
    }
}
