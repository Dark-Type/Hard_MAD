//
//  SettingsViewModelProtocol.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//

import Foundation
import LocalAuthentication
import UIKit

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

    // MARK: - Profile Image Methods

    func saveProfileImage(_ image: UIImage) async -> Bool {
        do {
            let authService = self.authService
            return try await withLoading {
                authService.saveUserProfileImage(image)
            }
        } catch {
            handleError(error)
            return false
        }
    }

    func loadProfileImage() -> UIImage? {
        return authService.loadUserProfileImage()
    }

    // MARK: - Notification Methods

    func getNotifications() async -> [NotificationTime] {
        do {
            let service = self.notificationService
            return try await withLoading {
                await service.getNotifications()
            }
        } catch {
            handleError(error)
            return []
        }
    }

    func addNotification(time: String) async -> NotificationTime? {
        do {
            let service = self.notificationService
            let timeToAdd = time
            return try await withLoading {
                await service.addNotification(time: timeToAdd)
            }
        } catch {
            handleError(error)
            return nil
        }
    }

    func removeNotification(id: UUID) async -> Bool {
        do {
            let service = self.notificationService
            let idToRemove = id
            return try await withLoading {
                await service.removeNotification(id: idToRemove)
            }
        } catch {
            handleError(error)
            return false
        }
    }

    func isNotificationsEnabled() async -> Bool {
        do {
            let service = self.notificationService
            return try await withLoading {
                await service.isNotificationsEnabled()
            }
        } catch {
            handleError(error)
            return false
        }
    }

    func setNotificationsEnabled(_ enabled: Bool) async -> Bool {
        do {
            let service = self.notificationService
            let shouldEnable = enabled
            return try await withLoading {
                await service.toggleNotifications(shouldEnable)
            }
        } catch {
            handleError(error)
            return false
        }
    }

    // MARK: - TouchID Methods

    func isTouchIDEnabled() -> Bool {
        return authService.isTouchIDEnabled()
    }

    func isBiometryAvailable() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    func getBiometryType() -> String {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            switch context.biometryType {
            case .faceID:
                return "Face ID"
            case .touchID:
                return "Touch ID"
            default:
                return "Biometry"
            }
        }

        return "Biometry"
    }

    func setTouchIDEnabled(_ enabled: Bool) async -> Bool {
        if !enabled {
            authService.setTouchIDEnabled(false)
            return false
        }

        guard isBiometryAvailable() else {
            return false
        }

        do {
            let auth = self.authService
            return try await withLoading {
                try await auth.authenticateWithBiometrics(reason: "Enable biometry for quick login")
                self.authService.setTouchIDEnabled(true)
                return true
            }
        } catch {
            authService.setTouchIDEnabled(false)
            handleError(error)
            return false
        }
    }
}
