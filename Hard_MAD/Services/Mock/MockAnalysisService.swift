//
//  MockAnalysisService.swift
//  Hard_MAD
//
//  Created by dark type on 03.03.2025.
//

import UIKit

actor MockAnalysisService: AnalysisServiceProtocol {
    private var journalRecords: [JournalRecord] = []
    
    init() {
        Task {
            await generateMockRecords()
        }
    }
    
    func fetchWeeklyData(for date: Date) async -> AnalysisWeekData {
        let calendar = Calendar.current
        let weekInterval = calendar.dateInterval(of: .weekOfYear, for: date)!
        
        let weekRecords = journalRecords.filter { weekInterval.contains($0.createdAt) }
        
        var dailyEmotions = [Date: [JournalRecord]]()
        
        let startOfWeek = weekInterval.start
        for dayOffset in 0..<7 {
            if let dayDate = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek) {
                let components = calendar.dateComponents([.year, .month, .day], from: dayDate)
                if let normalizedDate = calendar.date(from: components) {
                    dailyEmotions[normalizedDate] = []
                }
            }
        }
        
        for record in weekRecords {
            let components = calendar.dateComponents([.year, .month, .day], from: record.createdAt)
            if let dayDate = calendar.date(from: components) {
                dailyEmotions[dayDate, default: []].append(record)
            }
        }
        
        var emotionCounts = [Emotion: Int]()
        for record in weekRecords {
            emotionCounts[record.emotion, default: 0] += 1
        }
        let mostFrequent = emotionCounts.sorted { $0.value > $1.value }
            .map { (emotion: $0.key, count: $0.value) }
        
        var timeOfDayEmotions = [TimeOfDay: [JournalRecord]]()
        for record in weekRecords {
            let timeOfDay = TimeOfDay.from(date: record.createdAt)
            var records = timeOfDayEmotions[timeOfDay] ?? []
            records.append(record)
            timeOfDayEmotions[timeOfDay] = records
        }
        
        var timeOfDayMoods = [TimeOfDay: [EmotionFrequency]]()
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
        
        return AnalysisWeekData(
            weekRange: weekInterval,
            dailyEmotions: dailyEmotions,
            mostFrequentEmotions: mostFrequent,
            timeOfDayMoods: timeOfDayMoods
        )
    }
    
    func fetchAllWeeks() async -> [DateInterval] {
        guard let earliest = journalRecords.map({ $0.createdAt }).min()
        else {
            return []
        }
              
        let calendar = Calendar.current
            
        var currentDate = Date()
        var intervals: [DateInterval] = []
            
        while currentDate >= earliest {
            if let weekInterval = calendar.dateInterval(of: .weekOfYear, for: currentDate) {
                intervals.append(weekInterval)
       
                currentDate = calendar.date(byAdding: .weekOfYear, value: -1, to: currentDate)!
            } else {
                break
            }
        }
            
        return intervals
    }
    
    private func generateMockRecords() {
        var records: [JournalRecord] = []
        let calendar = Calendar.current
        let now = Date()
        
        for dayOffset in 0..<28 {
            let day = calendar.date(byAdding: .day, value: -dayOffset, to: now)!
            
            let recordsCount = Int.random(in: 1...3)
            for _ in 0..<recordsCount {
                let hour = Int.random(in: 5...23)
                let minute = Int.random(in: 0...59)
                var components = calendar.dateComponents([.year, .month, .day], from: day)
                components.hour = hour
                components.minute = minute
                let recordDate = calendar.date(from: components)!
                
                let emotion = Emotion.allCases.randomElement()!
                
                let record = JournalRecord(
                    emotion: emotion,
                    note: "Record from \(dayOffset) days ago",
                    createdAt: recordDate
                )
                
                records.append(record)
            }
        }
        
        journalRecords = records
    }
}

extension MockAnalysisService {
    private func generateMockRecordsForUITesting() async {
        var records: [JournalRecord] = []
        let calendar = Calendar.current
        let now = Date()
        
        for weekOffset in 0..<3 {
            for dayOffset in 0..<7 {
                let totalDaysAgo = (weekOffset * 7) + dayOffset
                let day = calendar.date(byAdding: .day, value: -totalDaysAgo, to: now)!
                
                let recordsCount = (totalDaysAgo % 3) + 1
                for recordIndex in 0..<recordsCount {
                    let hour = 8 + (recordIndex * 4)
                    let components = calendar.dateComponents([.year, .month, .day], from: day)
                    var recordComponents = components
                    recordComponents.hour = hour
                    recordComponents.minute = 0
                    let recordDate = calendar.date(from: recordComponents)!
                    
                    let emotionIndex = (totalDaysAgo + recordIndex) % Emotion.allCases.count
                    let emotion = Emotion.allCases[emotionIndex]
                    
                    let record = JournalRecord(
                        emotion: emotion,
                        note: "Record from \(dayOffset) days ago",
                        createdAt: recordDate
                    )
                    
                    records.append(record)
                }
            }
        }
        
        journalRecords = records
    }

    func configureForUITesting(empty: Bool = false) async {
        if empty {
            journalRecords = []
        } else {
            await generateMockRecordsForUITesting()
        }
    }
}
