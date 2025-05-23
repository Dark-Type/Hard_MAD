//
//  JournalService.swift
//  Hard_MAD
//
//  Created by dark type on 15.05.2025.
//

import Foundation

final class JournalService: JournalServiceProtocol {
    private let dbClient: DatabaseClientProtocol

    init(dbClient: DatabaseClientProtocol) {
        self.dbClient = dbClient
    }

    func fetchRecords() async -> [JournalRecord] {
        do {
            let dtos = try await dbClient.fetchJournalRecords(sorted: .byDateDescending)
            return dtos.map(JournalRecord.init(from:))
        } catch {
            return []
        }
    }

    func saveRecord(_ record: JournalRecord) async {
        do {
            let dto = JournalRecordDTO(from: record)
            try await dbClient.saveJournalRecord(dto)
        } catch {
            print("Failed to save journal record: \(error)")
        }
    }

    func fetchStatistics() async -> JournalStatistics {
        do {
            let records = try await dbClient.fetchJournalRecords(sorted: nil)
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())

            let todayCount = records.filter {
                calendar.startOfDay(for: $0.createdAt) == today
            }.count

            let uniqueDays: Set<Date> = Set(records.map {
                calendar.startOfDay(for: $0.createdAt)
            })

            var streakDays = 0
            var currentDate = today
            while uniqueDays.contains(currentDate) {
                streakDays += 1
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
                currentDate = previousDay
            }

            return JournalStatistics(
                totalCount: records.count,
                todayCount: todayCount,
                streakDays: streakDays
            )
        } catch {
            return JournalStatistics(totalCount: 0, todayCount: 0, streakDays: 0)
        }
    }

    func fetchTodayEmotions() async -> [Emotion] {
        do {
            let records = try await dbClient.fetchJournalRecords(sorted: .byDateDescending)
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())

            return records
                .filter { calendar.startOfDay(for: $0.createdAt) == today }
                .compactMap { Emotion(rawValue: $0.emotionRaw) }
        } catch {
            return []
        }
    }
}
