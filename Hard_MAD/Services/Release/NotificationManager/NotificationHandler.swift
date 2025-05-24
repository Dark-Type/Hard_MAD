//
//  NotificationHandler.swift
//  Hard_MAD
//
//  Created by dark type on 24.05.2025.
//

import Foundation
import UserNotifications

enum AppNotificationEvent: String {
    case notificationTapped = "app.notification.tapped"

    var name: Notification.Name {
        return Notification.Name(rawValue)
    }
}

final class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {
    override init() {
        super.init()
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        return [.banner, .sound]
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let identifier = response.notification.request.identifier

        print("User tapped notification: \(identifier)")

        Task.detached { @MainActor in
            NotificationCenter.default.post(
                name: AppNotificationEvent.notificationTapped.name,
                object: nil,
                userInfo: ["notificationId": identifier]
            )
        }
    }
}
