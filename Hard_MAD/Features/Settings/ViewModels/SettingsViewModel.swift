//
//  SettingsViewModelProtocol.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//
import Foundation

@MainActor
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

    func getUserProfile() -> UserProfile? {
        return authService.getCurrentUser()
    }

    // MARK: - Notification Methods

    func getNotifications() async -> [NotificationTime] {
        do {
            return try await withLoading {
                try await notificationService.getNotifications()
            }
        } catch {
            handleError(error)
            return []
        }
    }

    func addNotification(time: String) async -> NotificationTime? {
        do {
            return try await withLoading {
                try await notificationService.addNotification(time: time)
            }
        } catch {
            handleError(error)
            return nil
        }
    }

    func removeNotification(id: UUID) async -> Bool {
        do {
            return try await withLoading {
                try await notificationService.removeNotification(id: id)
            }
        } catch {
            handleError(error)
            return false
        }
    }

    func isNotificationsEnabled() async -> Bool {
        do {
            return try await withLoading {
                await notificationService.isNotificationsEnabled()
            }
        } catch {
            handleError(error)
            return false
        }
    }

    func setNotificationsEnabled(_ enabled: Bool) async {
        do {
            _ = try await withLoading {
                await notificationService.toggleNotifications(enabled)
            }
        } catch {
            handleError(error)
        }
    }

    // MARK: - TouchID Methods

    func isTouchIDEnabled() -> Bool {
        return authService.isTouchIDEnabled()
    }

    func setTouchIDEnabled(_ enabled: Bool) async {
        if enabled {
            do {
                print("TRYING TO AUTHENTICATE")
                try await authService.authenticateWithBiometrics(reason: "Enable biometry for quick login")
                print("AUTHENTICATED")
                authService.setTouchIDEnabled(true)
            } catch {
                print("NOPE")
                authService.setTouchIDEnabled(false)
                handleError(error)
            }
        } else {
            authService.setTouchIDEnabled(false)
        }
    }
}
