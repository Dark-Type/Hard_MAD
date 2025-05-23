//
//  NotificationServiceProtocol 2.swift
//  Hard_MAD
//
//  Created by dark type on 04.03.2025.
//

import Foundation

protocol NotificationServiceProtocol: Sendable {
    func getNotifications() async throws-> [NotificationTime]
    func addNotification(time: String) async throws-> NotificationTime
    func removeNotification(id: UUID) async throws -> Bool
    func isNotificationsEnabled() async  -> Bool
    func toggleNotifications(_ enabled: Bool) async
}
