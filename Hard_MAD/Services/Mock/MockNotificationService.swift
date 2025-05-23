//
//  NotificationServiceProtocol.swift
//  Hard_MAD
//
//  Created by dark type on 03.03.2025.
//

import Foundation

actor MockNotificationService: NotificationServiceProtocol {
    private var notifications: [NotificationTime] = [
        NotificationTime(time: "09:00"),
        NotificationTime(time: "12:30"),
        NotificationTime(time: "18:45")
    ]

    private var notificationsEnabled: Bool = true

    func getNotifications() async -> [NotificationTime] {
        return notifications
    }

    func addNotification(time: String) async -> NotificationTime {
        let notification = NotificationTime(time: time)
        notifications.append(notification)
        return notification
    }

    func removeNotification(id: UUID) async -> Bool {
        if let index = notifications.firstIndex(where: { $0.id == id }) {
            notifications.remove(at: index)
            return true
        }
        return false
    }

    func isNotificationsEnabled() async -> Bool {
        return notificationsEnabled
    }

    func toggleNotifications(_ enabled: Bool) async {
        notificationsEnabled = enabled
    }
}

extension MockNotificationService {
    func configureForUITesting() async {
        notifications = [
            NotificationTime(time: "09:00"),
            NotificationTime(time: "12:30"),
            NotificationTime(time: "18:45")
        ]

        notificationsEnabled = true

        if ProcessInfo.processInfo.environment["UI_TEST_NOTIFICATIONS_ENABLED"] == "false" {
            notificationsEnabled = false
        }

        if ProcessInfo.processInfo.environment["UI_TEST_EMPTY_NOTIFICATIONS"] == "true" {
            notifications = []
        }
    }
}
