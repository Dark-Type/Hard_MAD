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

    func getNotifications() async throws -> [NotificationTime] {
        let dtos = try await dbClient.fetchNotificationTimes()
        return dtos.map(NotificationTime.init(from:))
    }

    func addNotification(time: String) async throws -> NotificationTime {
        let notification = NotificationTime(time: time)
        let dto = NotificationTimeDTO(from: notification)
        try await dbClient.saveNotificationTime(dto)
        return notification
    }

    func removeNotification(id: UUID) async throws -> Bool {
        try await dbClient.deleteNotificationTime(id: id)
        return true
    }

    func isNotificationsEnabled() async -> Bool {
        return notificationsAllowed
    }

    func toggleNotifications(_ enabled: Bool) async {
        notificationsAllowed = enabled
    }
}
