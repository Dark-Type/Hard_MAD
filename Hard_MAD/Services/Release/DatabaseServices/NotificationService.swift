//
//  NotificationService.swift
//  Hard_MAD
//
//  Created by dark type on 15.05.2025.
//

import Foundation

final class NotificationService: NotificationServiceProtocol {
    private let dbClient: DatabaseClientProtocol

    private let kNotificationsAllowed = "notificationsAllowed"
    private var notificationsAllowed: Bool {
        get { UserDefaults.standard.bool(forKey: kNotificationsAllowed) }
        set { UserDefaults.standard.set(newValue, forKey: kNotificationsAllowed) }
    }

    init(dbClient: DatabaseClientProtocol) {
        self.dbClient = dbClient
    }

    func getNotifications() async -> [NotificationTime] {
        do {
            let dtos = try await dbClient.fetchNotificationTimes()
            return dtos.map(NotificationTime.init(from:))
        } catch {
            print("Failed to fetch notifications: \(error)")
            return []
        }
    }

    func addNotification(time: String) async -> NotificationTime {
        let notification = NotificationTime(time: time)
        do {
            let dto = NotificationTimeDTO(from: notification)
            try await dbClient.saveNotificationTime(dto)
            return notification
        } catch {
            print("Failed to add notification: \(error)")
            return notification
        }
    }

    func removeNotification(id: UUID) async -> Bool {
        do {
            try await dbClient.deleteNotificationTime(id: id)
            return true
        } catch {
            print("Failed to remove notification: \(error)")
            return false
        }
    }

    func isNotificationsEnabled() async -> Bool {
        return notificationsAllowed
    }

    func toggleNotifications(_ enabled: Bool) async {
        notificationsAllowed = enabled
    }
}
