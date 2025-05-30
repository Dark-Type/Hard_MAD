//
//  DatabaseClientProtocol.swift
//  Hard_MAD
//
//  Created by dark type on 15.05.2025.
//

import CoreData

protocol DatabaseClientProtocol: Actor {
    func fetchJournalRecords(sorted: JournalSortOrder?) async throws -> [JournalRecordDTO]
    func fetchJournalRecord(id: UUID) async throws -> JournalRecordDTO?
    func saveJournalRecord(_ record: JournalRecordDTO) async throws
    func deleteJournalRecord(id: UUID) async throws
    func deleteAllJournalRecords() async throws

    func fetchNotificationTimes() async throws -> [NotificationTimeDTO]
    func fetchNotificationTime(id: UUID) async throws -> NotificationTimeDTO?
    func saveNotificationTime(_ notification: NotificationTimeDTO) async throws
    func deleteNotificationTime(id: UUID) async throws
    func deleteAllNotificationTimes() async throws

    func fetchQuestionAnswers(forQuestion index: Int) async throws -> [String]
    func addQuestionAnswer(_ answer: String, forQuestion index: Int) async throws
    func deleteQuestionAnswer(_ answer: String, forQuestion index: Int) async throws
}
