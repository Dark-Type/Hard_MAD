//
//  SettingsViewModelProtocol.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//
import Foundation

final class SettingsViewModel: BaseViewModel {
    // MARK: - Dependencies

    private let authService: AuthServiceProtocol
    private let notificationService: NotificationServiceProtocol
    
    // MARK: - Initialization

    init(
        authService: AuthServiceProtocol,
        notificationService: NotificationServiceProtocol
    ) {
        self.authService = authService
        self.notificationService = notificationService
        super.init()
    }
    
    // MARK: - User Profile Methods

    func getUserProfile() async -> UserProfile? {
        return await authService.getCurrentUser()
    }
    
    // MARK: - Notification Methods

    func getNotifications() async -> [NotificationTime] {
        return await notificationService.getNotifications()
    }
    
    func addNotification(time: String) async -> NotificationTime {
        return await notificationService.addNotification(time: time)
    }
    
    func removeNotification(id: UUID) async -> Bool {
        return await notificationService.removeNotification(id: id)
    }
    
    func isNotificationsEnabled() async -> Bool {
        return await notificationService.isNotificationsEnabled()
    }
    
    func setNotificationsEnabled(_ enabled: Bool) async {
        await notificationService.setNotificationsEnabled(enabled)
    }
    
    // MARK: - TouchID Methods

    func isTouchIDEnabled() async -> Bool {
        return await authService.isTouchIDEnabled()
    }
    
    func setTouchIDEnabled(_ enabled: Bool) async {
        await authService.setTouchIDEnabled(enabled)
    }
}
