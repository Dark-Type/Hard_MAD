//
//  NotificationManager.swift
//  Hard_MAD
//
//  Created by Dark-Type on 23.05.2025.
//

import Foundation
import UserNotifications

final actor NotificationManager {
    func requestAuthorization() async -> Bool {
        do {
            let options: UNAuthorizationOptions = [.alert, .sound, .badge]
            return try await UNUserNotificationCenter.current().requestAuthorization(options: options)
        } catch {
            print("Failed to request notification authorization: \(error)")
            return false
        }
    }
    
    func scheduleNotification(for time: NotificationTime) async -> Bool {
        let components = createDateComponents(from: time.time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let content = UNMutableNotificationContent()
        content.title = "Emotion Check-in"
        content.body = "Time to record your emotions. Open the app to get started."
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: time.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            return true
        } catch {
            print("Failed to schedule notification: \(error)")
            return false
        }
    }
    
    func removeScheduledNotification(id: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [id.uuidString]
        )
    }
    
    func removeAllScheduledNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    private func createDateComponents(from timeString: String) -> DateComponents {
        var components = DateComponents()
        
        let timeParts = timeString.split(separator: ":")
        if timeParts.count == 2,
           let hour = Int(timeParts[0]),
           let minute = Int(timeParts[1])
        {
            components.hour = hour
            components.minute = minute
        }
        
        return components
    }
}
