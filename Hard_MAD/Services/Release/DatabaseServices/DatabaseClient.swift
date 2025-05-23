//
//  DatabaseClient.swift
//  Hard_MAD
//
//  Created by dark type on 15.05.2025.
//

import CoreData
import Foundation

final actor DatabaseClient: DatabaseClientProtocol {
    // In a real implementation, you would inject NSPersistentContainer or similar.
    // For now, all methods throw "not implemented"

    // MARK: - Journal Records

    func fetchJournalRecords(sorted: JournalSortOrder?) async throws -> [JournalRecordDTO] {
        // TODO: Implement CoreData fetch with mapping to DTO
        []
    }

    func fetchJournalRecord(id: UUID) async throws -> JournalRecordDTO? {
        // TODO: Implement CoreData fetch by id with mapping to DTO
        nil
    }

    func saveJournalRecord(_ record: JournalRecordDTO) async throws {
        // TODO: Implement CoreData insert/update logic
    }

    func deleteJournalRecord(id: UUID) async throws {
        // TODO: Implement CoreData delete by id
    }

    func deleteAllJournalRecords() async throws {
        // TODO: Implement CoreData batch delete
    }

    // MARK: - Notifications

    func fetchNotificationTimes() async throws -> [NotificationTimeDTO] {
        // TODO: Implement CoreData fetch for notifications
        []
    }

    func fetchNotificationTime(id: UUID) async throws -> NotificationTimeDTO? {
        // TODO: Implement CoreData fetch notification by id
        nil
    }

    func saveNotificationTime(_ notification: NotificationTimeDTO) async throws {
        // TODO: Implement CoreData insert/update for notification
    }

    func deleteNotificationTime(id: UUID) async throws {
        // TODO: Implement CoreData delete notification by id
    }

    func deleteAllNotificationTimes() async throws {
        // TODO: Implement CoreData batch delete for notifications
    }
}
