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
    
    // MARK: - Loaded State Test
    
    func testSettingsViewWithData() throws {
        app.launchEnvironment["UI_TEST_LONG_USER_NAME"] = "Бабанов Алексей Михайлович, БУ"
        app.launch()
        
        sleep(1)
        
        logElementsOnScreen()
        captureScreenshot(name: "Settings - 1. Initial State")
        
        XCTAssertTrue(app.otherElements["notificationContainer"].exists ||
            app.switches["notificationToggle"].exists,
            "Notification toggle container should be visible")
        XCTAssertTrue(app.otherElements["touchIDContainer"].exists ||
            app.otherElements["touchIDToggle"].exists,
            "Touch ID toggle container should be visible")
        XCTAssertTrue(app.buttons["addNotificationButton"].exists, "Add notification button should be visible")
        XCTAssertTrue(app.otherElements["notificationsStackView"].exists, "Notifications stack view should be visible")
        
        verifyNoLabelsTruncated()
    
        let notificationToggle = app.switches["notificationToggle"].exists ?
            app.switches["notificationToggle"] :
            app.switches.element
        
        if notificationToggle.exists {
            captureScreenshot(name: "Settings - 2. Before Toggle Notification")
            
            notificationToggle.tap()
            sleep(UInt32(0.5))
            captureScreenshot(name: "Settings - After Toggle Notification")
            
            notificationToggle.tap()
            sleep(UInt32(0.5))
            captureScreenshot(name: "Settings - After Resetting Notification")
            
            verifyNoLabelsTruncated()
        }
        
        let touchIDToggle = app.otherElements["touchIDToggle"]
        
        if touchIDToggle.exists {
            captureScreenshot(name: "Settings - 3. Before Toggle TouchID")
            
            touchIDToggle.tap()
            sleep(UInt32(0.5))
            captureScreenshot(name: "Settings - After Toggle TouchID")
            
            touchIDToggle.tap()
            sleep(UInt32(0.5))
            captureScreenshot(name: "Settings - After Resetting TouchID")
            
            verifyNoLabelsTruncated()
        }
        
        let addButton = app.buttons["addNotificationButton"]
        XCTAssertTrue(addButton.exists, "Add notification button should be visible")
        
        captureScreenshot(name: "Settings - 4. Before Add Notification")
        
        addButton.tap()
        sleep(1)
        
        XCTAssertTrue(app.otherElements["timePickerContainerView"].exists ||
            app.datePickers.element.exists,
            "Time picker should appear")
        
        captureScreenshot(name: "Settings - Time Picker")
        
        let saveButton = app.buttons["timePickerSaveButton"].exists ?
            app.buttons["timePickerSaveButton"] :
            app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Save")).firstMatch
        
        XCTAssertTrue(saveButton.exists, "Time picker save button should be visible")
        
        saveButton.tap()
        sleep(1)
        
        captureScreenshot(name: "Settings - After Add Notification")
        
        verifyNoLabelsTruncated()
        
        let deleteButtons = findNotificationDeleteButtons()
        
        if deleteButtons.count > 0 {
            captureScreenshot(name: "Settings - 5. Before Delete Notification")
            
            deleteButtons[0].tap()
            sleep(1)
            
            captureScreenshot(name: "Settings - After Delete Notification")
            
            let updatedDeleteButtons = findNotificationDeleteButtons()
            XCTAssertEqual(updatedDeleteButtons.count, deleteButtons.count - 1,
                           "Should have one less notification after deletion")
            
            verifyNoLabelsTruncated()
        }
        
        print("✅ Settings view with data: All UI elements, interactions, and truncation checks passed")
    }
    
    // MARK: - Empty State Test
    
    func testSettingsViewEmptyState() throws {
        app.launchEnvironment["UI_TEST_LONG_USER_NAME"] = "Бабанов Алексей Михайлович, БУ"
        app.launchEnvironment["UI_TEST_EMPTY_NOTIFICATIONS"] = "true"
        app.launchEnvironment["UI_TEST_TOUCH_ID_ENABLED"] = "true"
        
        app.launch()
        sleep(1)
        
        logElementsOnScreen()
        captureScreenshot(name: "Settings Empty - 1. Initial State")
        
        XCTAssertTrue(app.otherElements["notificationContainer"].exists ||
            app.switches["notificationToggle"].exists,
            "Notification toggle container should be visible")
        XCTAssertTrue(app.otherElements["touchIDContainer"].exists ||
            app.otherElements["touchIDToggle"].exists,
            "Touch ID toggle container should be visible")
        XCTAssertTrue(app.buttons["addNotificationButton"].exists, "Add notification button should be visible")
        
        let deleteButtons = findNotificationDeleteButtons()
        XCTAssertEqual(deleteButtons.count, 0, "No notification delete buttons should exist in empty state")
        
        verifyNoLabelsTruncated()
        
        let touchIDToggle = app.otherElements["touchIDToggle"]
        
        if touchIDToggle.exists {
            captureScreenshot(name: "Settings Empty - 2. Before Toggle Pre-Enabled TouchID")
            
            touchIDToggle.tap()
            sleep(UInt32(0.5))
            captureScreenshot(name: "Settings Empty - After Disabling Pre-Enabled TouchID")
            
            verifyNoLabelsTruncated()
        }
        
        let addButton = app.buttons["addNotificationButton"]
        XCTAssertTrue(addButton.exists, "Add notification button should be visible in empty state")
        
        captureScreenshot(name: "Settings Empty - 3. Before Add Notification")
        
        addButton.tap()
        sleep(1)
        
        XCTAssertTrue(app.otherElements["timePickerContainerView"].exists ||
            app.datePickers.element.exists,
            "Time picker should appear in empty state")
        
        captureScreenshot(name: "Settings Empty - Time Picker")
        
        let saveButton = app.buttons["timePickerSaveButton"].exists ?
            app.buttons["timePickerSaveButton"] :
            app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Save")).firstMatch
        
        XCTAssertTrue(saveButton.exists, "Time picker save button should be visible")
        
        saveButton.tap()
        sleep(1)
        
        captureScreenshot(name: "Settings Empty - After Adding First Notification")
        
        let updatedDeleteButtons = findNotificationDeleteButtons()
        XCTAssertGreaterThan(updatedDeleteButtons.count, 0,
                             "Should have at least one notification after adding to empty list")
        
        verifyNoLabelsTruncated()
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
    
    private func getAllSettingsLabels() -> [XCUIElement] {
        let labels = [
            app.staticTexts["settingsTitleLabel"],
            app.staticTexts["fullNameLabel"],
            app.staticTexts["notificationLabel"],
            app.staticTexts["touchIDLabel"]
        ]
        
        return labels.filter { $0.exists }
    }
    
    private func isLabelTextTruncated(_ label: XCUIElement) -> Bool {
        return label.label.contains("...")
    }
    
    private func verifyNoLabelsTruncated() {
        for label in getAllSettingsLabels() {
            XCTAssertFalse(isLabelTextTruncated(label),
                           "Label '\(label.identifier)' appears to be truncated with text: '\(label.label)'")
            
            let frame = label.frame
            print("📏 Label: \(label.identifier), Text: '\(label.label)', Frame: \(frame.origin.x),\(frame.origin.y),\(frame.width),\(frame.height)")
        }
        
        let addButton = app.buttons["addNotificationButton"]
        if addButton.exists {
            XCTAssertFalse(isLabelTextTruncated(addButton),
                           "Button '\(addButton.identifier)' text appears to be truncated")
            
            let frame = addButton.frame
            print("📏 Button: addNotificationButton, Text: '\(addButton.label)', Frame: \(frame.origin.x),\(frame.origin.y),\(frame.width),\(frame.height)")
        }
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
