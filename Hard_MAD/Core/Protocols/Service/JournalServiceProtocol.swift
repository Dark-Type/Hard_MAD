//
//  JournalServiceProtocol.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//

protocol JournalServiceProtocol: Sendable {
    func fetchRecords() async throws -> [JournalRecord]
    func saveRecord(_ record: JournalRecord) async throws
    func fetchStatistics() async throws -> JournalStatistics
    func fetchTodayEmotions() async throws -> [Emotion]
}
