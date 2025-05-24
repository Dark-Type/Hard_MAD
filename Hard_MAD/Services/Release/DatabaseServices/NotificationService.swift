//
//  NotificationService.swift
//  Hard_MAD
//
//  Created by dark type on 15.05.2025.
//

import Foundation
import UserNotifications

final class NotificationService: NotificationServiceProtocol {
    private let dbClient: DatabaseClientProtocol
    private let notificationManager: NotificationManager

    private let kNotificationsAllowed = "notificationsAllowed"
    private var notificationsAllowed: Bool {
        get { UserDefaults.standard.bool(forKey: kNotificationsAllowed) }
        set { UserDefaults.standard.set(newValue, forKey: kNotificationsAllowed) }
    }

    init(dbClient: DatabaseClientProtocol) {
        self.dbClient = dbClient
        self.notificationManager = NotificationManager()
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

            let hasPermission = await hasSystemPermission()
            if notificationsAllowed && hasPermission {
                _ = await notificationManager.scheduleNotification(for: notification)
            }

            return notification
        } catch {
            print("Failed to add notification: \(error)")
            return notification
        }
    }

    func removeNotification(id: UUID) async -> Bool {
        do {
            try await dbClient.deleteNotificationTime(id: id)
            await notificationManager.removeScheduledNotification(id: id)
            return true
        } catch {
            print("Failed to remove notification: \(error)")
            return false
        }
    }

    func isNotificationsEnabled() async -> Bool {
        let hasPermission = await hasSystemPermission()
        return notificationsAllowed && hasPermission
    }

    func toggleNotifications(_ enabled: Bool) async -> Bool {
        if enabled {
            let granted = await requestNotificationPermission()
            if granted {
                notificationsAllowed = true
                await scheduleAllNotifications()
                return true
            } else {
                return false
            }
        } else {
            notificationsAllowed = false
            await notificationManager.removeAllScheduledNotifications()
            return false
        }
    }

    func requestNotificationPermission() async -> Bool {
        return await notificationManager.requestAuthorization()
    }

    func hasSystemPermission() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus == .authorized
    }

    private func scheduleAllNotifications() async {
        await notificationManager.removeAllScheduledNotifications()

        let hasPermission = await hasSystemPermission()
        guard hasPermission else { return }

        let notificationTimes = await getNotifications()
        for time in notificationTimes {
            _ = await notificationManager.scheduleNotification(for: time)
        }
    }
}
