//
//  AnalysisService.swift
//  Hard_MAD
//
//  Created by dark type on 15.05.2025.
//

import Foundation

final class AnalysisService: AnalysisServiceProtocol {
    private let dbClient: DatabaseClientProtocol

    init(dbClient: DatabaseClientProtocol) {
        self.dbClient = dbClient
    }

    func fetchWeeklyData(for date: Date) async throws -> AnalysisWeekData {
        let calendar = Calendar.current
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: date) else {
            return AnalysisWeekData(
                weekRange: DateInterval(start: date, duration: 0),
                dailyEmotions: [:],
                mostFrequentEmotions: [],
                timeOfDayMoods: [:]
            )
        }

        let allRecordsDTO = try await dbClient.fetchJournalRecords(sorted: nil)
        let allRecords = allRecordsDTO.map(JournalRecord.init(from:))
        let weekRecords = allRecords.filter { weekInterval.contains($0.createdAt) }

        let dailyEmotions = buildDailyEmotions(from: weekRecords, weekInterval: weekInterval, calendar: calendar)
        let mostFrequent = computeMostFrequentEmotions(from: weekRecords)
        let timeOfDayMoods = computeTimeOfDayMoods(from: weekRecords)

        return AnalysisWeekData(
            weekRange: weekInterval,
            dailyEmotions: dailyEmotions,
            mostFrequentEmotions: mostFrequent,
            timeOfDayMoods: timeOfDayMoods
        )
    }

    func fetchAllWeeks() async throws -> [DateInterval] {
        let allRecordsDTO = try await dbClient.fetchJournalRecords(sorted: nil)
        let allRecords = allRecordsDTO.map(JournalRecord.init(from:))
        guard let earliest = allRecords.map({ $0.createdAt }).min() else {
            return []
        }

        let calendar = Calendar.current
        var currentDate = Date()
        var intervals: [DateInterval] = []
        while currentDate >= earliest {
            if let weekInterval = calendar.dateInterval(of: .weekOfYear, for: currentDate) {
                intervals.append(weekInterval)
                guard let previousWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: currentDate) else { break }
                currentDate = previousWeek
            } else {
                break
            }
        }
        return intervals
    }

    // MARK: - Helpers

    private func buildDailyEmotions(from records: [JournalRecord], weekInterval: DateInterval, calendar: Calendar) -> [Date: [JournalRecord]] {
        var dailyEmotions: [Date: [JournalRecord]] = [:]
        let startOfWeek = weekInterval.start
        for dayOffset in 0 ..< 7 {
            if let dayDate = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek) {
                let normalizedDate = calendar.startOfDay(for: dayDate)
                dailyEmotions[normalizedDate] = []
            }
        }
        for record in records {
            let normalizedDay = calendar.startOfDay(for: record.createdAt)
            dailyEmotions[normalizedDay, default: []].append(record)
        }
        return dailyEmotions
    }

    private func computeMostFrequentEmotions(from records: [JournalRecord]) -> [(emotion: Emotion, count: Int)] {
        var emotionCounts = [Emotion: Int]()
        for record in records {
            emotionCounts[record.emotion, default: 0] += 1
        }
        return emotionCounts.sorted { $0.value > $1.value }
            .map { (emotion: $0.key, count: $0.value) }
    }

    private func computeTimeOfDayMoods(from records: [JournalRecord]) -> [TimeOfDay: [EmotionFrequency]] {
        var timeOfDayEmotions = [TimeOfDay: [JournalRecord]]()
        for record in records {
            let timeOfDay = TimeOfDay.from(date: record.createdAt)
            timeOfDayEmotions[timeOfDay, default: []].append(record)
        }
        var timeOfDayMoods: [TimeOfDay: [EmotionFrequency]] = [:]
        for (time, records) in timeOfDayEmotions {
            var emotionCounts = [Emotion: Int]()
            for record in records {
                emotionCounts[record.emotion, default: 0] += 1
            }
            let total = records.count
            let frequencies = emotionCounts.map { emotion, count in
                EmotionFrequency(emotion: emotion, percentage: Double(count) / Double(total))
            }
            timeOfDayMoods[time] = frequencies
        }
        return timeOfDayMoods
    }
}
