//
//  NotificationManagerProtocol.swift
//  Hard_MAD
//
//  Created by dark type on 24.05.2025.
//

import Foundation

protocol NotificationManagerProtocol: Sendable {
    func requestAuthorization() async -> Bool
    func scheduleNotification(for time: NotificationTime) async -> Bool
    func removeScheduledNotification(id: UUID) async
    func removeAllScheduledNotifications() async
}
