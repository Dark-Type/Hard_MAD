//
//  SettingsViewModelProtocol.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//
import Foundation

final class SettingsViewModel: BaseViewModel {
    private var container: Container
    private var authService: AuthServiceProtocol?
    private var notificationService: NotificationServiceProtocol?
    
    init(container: Container) {
        self.container = container
    }
    
    private func resolveServices() async {
        if authService == nil {
            authService = await container.resolve()
        }
        
        if notificationService == nil {
            notificationService = await container.resolve()
        }
    }
    
    func getUserProfile() async -> UserProfile? {
        await resolveServices()
        return await authService?.getCurrentUser()
    }
    
    func getNotifications() async -> [NotificationTime] {
        await resolveServices()
        return await notificationService?.getNotifications() ?? []
    }
    
    func addNotification(time: String) async -> NotificationTime {
        await resolveServices()
        if let service = notificationService {
            return await service.addNotification(time: time)
        }
        return NotificationTime(time: time)
    }
    
    func removeNotification(id: UUID) async -> Bool {
        await resolveServices()
        return await notificationService?.removeNotification(id: id) ?? false
    }
    
    func isNotificationsEnabled() async -> Bool {
        await resolveServices()
        return await notificationService?.isNotificationsEnabled() ?? false
    }
    
    func setNotificationsEnabled(_ enabled: Bool) async {
        await resolveServices()
        await notificationService?.setNotificationsEnabled(enabled)
    }
    
    func isTouchIDEnabled() async -> Bool {
        await resolveServices()
        return await authService?.isTouchIDEnabled() ?? false
    }
    
    func setTouchIDEnabled(_ enabled: Bool) async {
        await resolveServices()
        await authService?.setTouchIDEnabled(enabled)
    }
}
