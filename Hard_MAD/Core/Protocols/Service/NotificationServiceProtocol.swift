//
//  NotificationServiceProtocol 2.swift
//  Hard_MAD
//
//  Created by dark type on 04.03.2025.
//

import Foundation

protocol NotificationServiceProtocol {
    func getNotifications() async -> [NotificationTime]
    func addNotification(time: String) async -> NotificationTime
    func removeNotification(id: UUID) async -> Bool
    func isNotificationsEnabled() async -> Bool
    func toggleNotifications(_ enabled: Bool) async -> Bool
    func requestNotificationPermission() async -> Bool
    func hasSystemPermission() async -> Bool
}
