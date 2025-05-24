//
//  MockNotificationManager.swift
//  Hard_MAD
//
//  Created by dark type on 24.05.2025.
//

@testable import Hard_MAD
import UserNotifications
import XCTest

// MARK: - Mock Notification Manager

final actor MockNotificationManager: NotificationManagerProtocol {
    var requestAuthorizationResult = false
    var scheduleNotificationResult = false
    var scheduleNotificationCalled = false
    var removeNotificationCalled = false
    var removeAllNotificationsCalled = false
    var scheduledNotifications: [UUID] = []
    
    func requestAuthorization() async -> Bool {
        return requestAuthorizationResult
    }
    
    func scheduleNotification(for time: NotificationTime) async -> Bool {
        scheduleNotificationCalled = true
        if scheduleNotificationResult {
            scheduledNotifications.append(time.id)
        }
        return scheduleNotificationResult
    }
    
    func removeScheduledNotification(id: UUID) async {
        removeNotificationCalled = true
        scheduledNotifications.removeAll { $0 == id }
    }
    
    func removeAllScheduledNotifications() async {
        removeAllNotificationsCalled = true
        scheduledNotifications.removeAll()
    }
    
    func setResults(auth: Bool, schedule: Bool) {
        requestAuthorizationResult = auth
        scheduleNotificationResult = schedule
    }
    
    func reset() {
        requestAuthorizationResult = false
        scheduleNotificationResult = false
        scheduleNotificationCalled = false
        removeNotificationCalled = false
        removeAllNotificationsCalled = false
        scheduledNotifications.removeAll()
    }
    
    func getScheduleNotificationCalled() -> Bool {
        return scheduleNotificationCalled
    }
    
    func getRemoveNotificationCalled() -> Bool {
        return removeNotificationCalled
    }
    
    func getRemoveAllNotificationsCalled() -> Bool {
        return removeAllNotificationsCalled
    }
    
    func getScheduledNotifications() -> [UUID] {
        return scheduledNotifications
    }
}

// MARK: - Notification Service Tests

final class NotificationServiceTests: XCTestCase {
    var sut: NotificationService!
    var mockDatabaseClient: MockDatabaseClient!
    var mockNotificationManager: MockNotificationManager!
    
    override func setUp() async throws {
        try await super.setUp()
        mockDatabaseClient = MockDatabaseClient()
        mockNotificationManager = MockNotificationManager()
        sut = NotificationService(
            dbClient: mockDatabaseClient,
            notificationManager: mockNotificationManager
        )
        
        UserDefaults.standard.removeObject(forKey: "notificationsAllowed")
        await mockNotificationManager.reset()
    }
    
    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "notificationsAllowed")
        super.tearDown()
    }
    
    // MARK: - Add/Delete Notification Tests
    
    func testAddNotification_WithPermissions_SchedulesNotification() async {
        UserDefaults.standard.set(true, forKey: "notificationsAllowed")
        sut.mockSystemPermission = true
        await mockNotificationManager.setResults(auth: true, schedule: true)
        
        let notification = await sut.addNotification(time: "09:00")
        
        XCTAssertEqual(notification.time, "09:00")
        
        let scheduleWasCalled = await mockNotificationManager.getScheduleNotificationCalled()
        XCTAssertTrue(scheduleWasCalled)
        
        let scheduledCount = await mockNotificationManager.getScheduledNotifications().count
        XCTAssertEqual(scheduledCount, 1)
    }
    
    func testAddNotification_WithoutPermissions_DoesNotSchedule() async {
        UserDefaults.standard.set(true, forKey: "notificationsAllowed")
        sut.mockSystemPermission = false
        
        let notification = await sut.addNotification(time: "09:00")
        
        XCTAssertEqual(notification.time, "09:00")
        
        let scheduleWasCalled = await mockNotificationManager.getScheduleNotificationCalled()
        XCTAssertFalse(scheduleWasCalled)
    }
    
    func testRemoveNotification_Success() async {
        let notificationId = UUID()
        let mockTime = NotificationTimeDTO(id: notificationId, time: "09:00")
        await mockDatabaseClient.setMockNotificationTimes([mockTime])
        
        let result = await sut.removeNotification(id: notificationId)
        
        XCTAssertTrue(result)
        
        let removeWasCalled = await mockNotificationManager.getRemoveNotificationCalled()
        XCTAssertTrue(removeWasCalled)
    }
    
    // MARK: - Notification Eligibility Tests
    
    func testIsNotificationsEnabled_WithBothPermissions_ReturnsTrue() async {
        UserDefaults.standard.set(true, forKey: "notificationsAllowed")
        sut.mockSystemPermission = true
        
        let isEnabled = await sut.isNotificationsEnabled()
        
        XCTAssertTrue(isEnabled)
    }
    
    func testIsNotificationsEnabled_WithoutSystemPermission_ReturnsFalse() async {
        UserDefaults.standard.set(true, forKey: "notificationsAllowed")
        sut.mockSystemPermission = false
        
        let isEnabled = await sut.isNotificationsEnabled()
        
        XCTAssertFalse(isEnabled)
    }
    
    func testToggleNotifications_Enable_SchedulesExistingNotifications() async {
        let mockTimes = [NotificationTimeDTO(id: UUID(), time: "09:00")]
        await mockDatabaseClient.setMockNotificationTimes(mockTimes)
        await mockNotificationManager.setResults(auth: true, schedule: true)
        sut.mockSystemPermission = true
        
        let result = await sut.toggleNotifications(true)
        
        XCTAssertTrue(result)
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "notificationsAllowed"))
        
        let scheduledCount = await mockNotificationManager.getScheduledNotifications().count
        XCTAssertEqual(scheduledCount, 1)
    }
    
    func testToggleNotifications_Disable_RemovesAllNotifications() async {
        UserDefaults.standard.set(true, forKey: "notificationsAllowed")
     
        let result = await sut.toggleNotifications(false)
        
        XCTAssertFalse(result)
        XCTAssertFalse(UserDefaults.standard.bool(forKey: "notificationsAllowed"))
        
        let removeAllWasCalled = await mockNotificationManager.getRemoveAllNotificationsCalled()
        XCTAssertTrue(removeAllWasCalled)
    }
}

// MARK: - Extension for Mock Database Client

extension MockDatabaseClient {
    func setMockNotificationTimes(_ times: [NotificationTimeDTO]) async {
        mockNotificationTimes = times
    }
}
