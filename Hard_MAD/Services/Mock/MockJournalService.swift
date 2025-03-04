//
//  MockJournalService.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//

import Foundation

actor MockJournalService: JournalServiceProtocol {
    private var records: [JournalRecord] = []
    
    init() {
        Task {
            await setupMockData()
        }
    }
    
    func fetchRecords() async -> [JournalRecord] {
        return records.sorted(by: { $0.createdAt > $1.createdAt })
    }
    
    func saveRecord(_ record: JournalRecord) async {
        records.append(record)
    }
    
    func fetchStatistics() async -> JournalStatistics {
        let totalCount = records.count
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let todayCount = records.filter {
            calendar.startOfDay(for: $0.createdAt) == today
        }.count
        
        var streakDays = 0
        var currentDate = today
        
        while true {
            let dayRecords = records.filter {
                calendar.startOfDay(for: $0.createdAt) == currentDate
            }
            
            if dayRecords.isEmpty {
                break
            }
            
            streakDays += 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
        }
        
        return JournalStatistics(totalCount: totalCount, todayCount: todayCount, streakDays: streakDays)
    }
    
    func fetchTodayEmotions() async -> [Emotion] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let todayRecords = records.filter {
            calendar.startOfDay(for: $0.createdAt) == today
        }
        
        return todayRecords.map { $0.emotion }
    }
    
    private func setupMockData() {
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!
        
        records = [
            JournalRecord(emotion: .happy, note: "", createdAt: today),
            JournalRecord(emotion: .productivity, note: "", createdAt: today),
            JournalRecord(emotion: .anxious, note: "", createdAt: yesterday),
            JournalRecord(emotion: .chill, note: "", createdAt: yesterday),
            JournalRecord(emotion: .burnout, note: "", createdAt: twoDaysAgo),
            JournalRecord(emotion: .tired, note: "", createdAt: twoDaysAgo)
        ]
    }
}

extension JournalRecord {
    init(emotion: Emotion, note: String, createdAt: Date) {
        self.id = UUID()
        self.emotion = emotion
        self.answer0 = ""
        self.answer1 = ""
        self.answer2 = ""
        self.createdAt = createdAt
    }
}

extension MockJournalService {
    func configureForUITesting() async {
        await setupMockDataForUITesting()
    }
    
    private func setupMockDataForUITesting() async {
        if ProcessInfo.processInfo.environment["UI_TEST_JOURNAL_EMPTY"] == "true" {
            records = []
        } else {
            records = [
                JournalRecord(
                    emotion: .happy,
                    answer0: "Work",
                    answer1: "Friends",
                    answer2: "Office"
                ),
                JournalRecord(
                    emotion: .productivity,
                    answer0: "Project completion",
                    answer1: "Colleagues",
                    answer2: "Office"
                ),
                JournalRecord(
                    emotion: .anxious,
                    answer0: "Meeting",
                    answer1: "Boss",
                    answer2: "Conference room"
                ),
                JournalRecord(
                    emotion: .chill,
                    answer0: "Relaxation",
                    answer1: "Family",
                    answer2: "Home"
                ),
                JournalRecord(
                    emotion: .burnout,
                    answer0: "Overwork",
                    answer1: "Alone",
                    answer2: "Office"
                )
            ]
        }
    }
}
