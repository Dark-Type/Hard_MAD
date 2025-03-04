//
//  SettingsViewControllerTests.swift
//  Hard_MAD
//
//  Created by dark type on 04.03.2025.
//

import XCTest

class SettingsViewControllerTests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["--UITesting", "--directToSettings"]
    }
    
    // MARK: - Test Settings UI Elements (Normal State)
    
    func testSettingsUIElements() throws {
        app.launch()
        
        sleep(1)
        
        logElementsOnScreen()
        
        captureScreenshot(name: "Settings Screen - Normal State")
        

        XCTAssertTrue(app.otherElements["notificationContainer"].exists ||
            app.switches["notificationToggle"].exists,
            "Notification toggle container should be visible")
        XCTAssertTrue(app.otherElements["touchIDContainer"].exists ||
            app.otherElements["touchIDToggle"].exists,
            "Touch ID toggle container should be visible")
        XCTAssertTrue(app.buttons["addNotificationButton"].exists, "Add notification button should be visible")
        XCTAssertTrue(app.otherElements["notificationsStackView"].exists, "Notifications stack view should be visible")
    }
    
    // MARK: - Test Notification Toggle
    
    func testNotificationToggle() throws {
        app.launch()
        
        sleep(1)
        
        let notificationToggle = app.switches["notificationToggle"].exists ?
            app.switches["notificationToggle"] :
            app.switches.element
        
        XCTAssertTrue(notificationToggle.exists, "Notification toggle should be visible")
        
        captureScreenshot(name: "Notification Toggle - Initial State")
        
        notificationToggle.tap()
        sleep(UInt32(0.5))
        
        captureScreenshot(name: "Notification Toggle - After First Tap")
        
        notificationToggle.tap()
        sleep(UInt32(0.5))
        
        captureScreenshot(name: "Notification Toggle - After Second Tap")
    }
    
    // MARK: - Test TouchID Toggle
    
    func testTouchIDToggle() throws {
        app.launch()
        
        sleep(1)
        
        let touchIDToggle = app.otherElements["touchIDToggle"]
        
        XCTAssertTrue(touchIDToggle.exists, "Touch ID toggle should be visible")
        
        captureScreenshot(name: "TouchID Before Toggle")
        
        touchIDToggle.tap()
        sleep(UInt32(0.5))
        
        captureScreenshot(name: "TouchID After Toggle")
        
        touchIDToggle.tap()
        sleep(UInt32(0.5))
        
        captureScreenshot(name: "TouchID After Reverting")
    }
    
    // MARK: - Test Add Notification
    
    func testAddNotification() throws {
        app.launch()
        
        sleep(1)
        
        let addButton = app.buttons["addNotificationButton"]
        XCTAssertTrue(addButton.exists, "Add notification button should be visible")
        
        captureScreenshot(name: "Before Add Notification")
        
        addButton.tap()
        
        sleep(1)
        
        XCTAssertTrue(app.otherElements["timePickerContainerView"].exists ||
            app.datePickers.element.exists,
            "Time picker should appear")
        
        captureScreenshot(name: "Time Picker")
        
        let saveButton = app.buttons["timePickerSaveButton"].exists ?
            app.buttons["timePickerSaveButton"] :
            app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Save")).firstMatch
        
        XCTAssertTrue(saveButton.exists, "Time picker save button should be visible")
        
        saveButton.tap()
        
        sleep(1)
        
        captureScreenshot(name: "After Add Notification")
    }
    
    // MARK: - Test Delete Notification
    
    func testDeleteNotification() throws {
        app.launch()
        
        sleep(1)

        let deleteButtons = findNotificationDeleteButtons()
        
        if deleteButtons.count > 0 {
            captureScreenshot(name: "Before Notification Delete")
            
            deleteButtons[0].tap()
            sleep(1)
            
            captureScreenshot(name: "After Notification Delete")
            
            let updatedDeleteButtons = findNotificationDeleteButtons()
            XCTAssertEqual(updatedDeleteButtons.count, deleteButtons.count - 1, "Should have one less notification after deletion")
        }
        else {
            XCTFail("No notification delete buttons found to test deletion")
        }
    }
    
    // MARK: - Test Empty Notifications State
    
    func testEmptyNotificationsState() throws {
        app.launchEnvironment["UI_TEST_EMPTY_NOTIFICATIONS"] = "true"
        app.launch()
        
        sleep(1)
        
        let deleteButtons = findNotificationDeleteButtons()
        XCTAssertEqual(deleteButtons.count, 0, "No notification delete buttons should exist in empty state")
        
        captureScreenshot(name: "Empty Notifications State")
        
        app.buttons["addNotificationButton"].tap()
        sleep(1)
        
        let saveButton = app.buttons["timePickerSaveButton"].exists ?
            app.buttons["timePickerSaveButton"] :
            app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Save")).firstMatch
        if saveButton.exists {
            saveButton.tap()
            sleep(1)
        }
        
        captureScreenshot(name: "After Adding to Empty List")
        
        let updatedDeleteButtons = findNotificationDeleteButtons()
        XCTAssertGreaterThan(updatedDeleteButtons.count, 0, "Should have at least one notification after adding")
    }
    
    // MARK: - Test TouchID Enabled Initial State
    
    func testTouchIDEnabledInitialState() throws {
        app.launchEnvironment["UI_TEST_TOUCH_ID_ENABLED"] = "true"
        app.launch()
        
        sleep(1)
        
        captureScreenshot(name: "TouchID Enabled Initial State")
        
        let touchIDToggle = app.otherElements["touchIDToggle"]
        if touchIDToggle.exists {
            touchIDToggle.tap()
            sleep(UInt32(0.5))
            captureScreenshot(name: "After Disabling Pre-Enabled TouchID")
        }
    }
    
    // MARK: - Helper Methods
    
    private func findNotificationDeleteButtons() -> [XCUIElement] {
        var deleteButtons: [XCUIElement] = []
        let byIdentifier = app.buttons.matching(NSPredicate(format: "identifier CONTAINS[c] %@", "delete")).allElementsBoundByIndex
        if byIdentifier.count > 0 {
            deleteButtons = byIdentifier
        }
        else if app.buttons.matching(NSPredicate(format: "identifier CONTAINS[c] %@", "notificationDeleteButton")).count > 0 {
            deleteButtons = app.buttons.matching(NSPredicate(format: "identifier CONTAINS[c] %@", "notificationDeleteButton")).allElementsBoundByIndex
        }
        else if app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "Delete")).count > 0 {
            deleteButtons = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "Delete")).allElementsBoundByIndex
        }
        else {
            let notificationViews = app.otherElements.matching(NSPredicate(format: "identifier BEGINSWITH %@", "notificationView_"))
            for i in 0 ..< notificationViews.count {
                let buttons = notificationViews.element(boundBy: i).buttons
                if buttons.count > 0 {
                    deleteButtons.append(buttons.element(boundBy: buttons.count - 1))
                }
            }
        }
        
        return deleteButtons
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
        
        print("  - Static Texts:")
        for text in app.staticTexts.allElementsBoundByIndex {
            print("    \(text.identifier): \"\(text.label)\"")
        }
        
        print("  - Buttons:")
        for button in app.buttons.allElementsBoundByIndex {
            print("    \(button.identifier): \"\(button.label)\", enabled: \(button.isEnabled)")
        }
        
        print("  - Switches:")
        for toggle in app.switches.allElementsBoundByIndex {
            print("    \(toggle.identifier): \"\(toggle.label)\", value: \(toggle.value ?? "unknown")")
        }
        
        print("  - Other Elements:")
        for element in app.otherElements.allElementsBoundByIndex.prefix(15) {
            print("    \(element.identifier)")
        }
    }
}
