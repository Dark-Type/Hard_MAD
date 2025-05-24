//
//  AnalysisServiceTests.swift
//  Hard_MAD
//
//  Created by dark type on 24.05.2025.
//

@testable import Hard_MAD
import XCTest

// MARK: - Analysis Service Tests

final class AnalysisServiceTests: XCTestCase {
    var sut: AnalysisService!
    var mockDatabaseClient: MockDatabaseClient!
    
    override func setUp() async throws {
        try await super.setUp()
        mockDatabaseClient = MockDatabaseClient()
        sut = AnalysisService(dbClient: mockDatabaseClient)
    }
    
    override func tearDown() {
        sut = nil
        mockDatabaseClient = nil
        super.tearDown()
    }
    
    // MARK: - Helper Methods
    
    func createMockRecord(
        daysAgo: Int = 0,
        hoursAgo: Int = 0,
        emotion: Emotion = .happy
    ) -> JournalRecordDTO {
        let calendar = Calendar.current
        var date = Date()
        
        if daysAgo > 0 {
            date = calendar.date(byAdding: .day, value: -daysAgo, to: date)!
        }
        
        if hoursAgo > 0 {
            date = calendar.date(byAdding: .hour, value: -hoursAgo, to: date)!
        }
        
        return JournalRecordDTO(
            id: UUID(),
            emotionRaw: emotion.rawValue,
            answer0: "Test answer 0",
            answer1: "Test answer 1",
            answer2: "Test answer 2",
            createdAt: date
        )
    }
    
    func createRecordForTimeOfDay(_ timeOfDay: TimeOfDay, emotion: Emotion = .happy) -> JournalRecordDTO {
        let calendar = Calendar.current
        let today = Date()
        
        let hour: Int
        switch timeOfDay {
        case .earlyMorning:
            hour = 6
        case .morning:
            hour = 10
        case .day:
            hour = 14
        case .evening:
            hour = 19
        case .lateEvening:
            hour = 23
        }
        
        let dateWithTime = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: today)!
        
        return JournalRecordDTO(
            id: UUID(),
            emotionRaw: emotion.rawValue,
            answer0: "Test answer 0",
            answer1: "Test answer 1",
            answer2: "Test answer 2",
            createdAt: dateWithTime
        )
    }
    
    // MARK: - Emotion Frequency Tests
    
    func testFetchWeeklyData_EmotionFrequency_CalculatesCorrectly() async throws {
        let records = [
            createMockRecord(daysAgo: 0, emotion: .happy),
            createMockRecord(daysAgo: 0, emotion: .happy),
            createMockRecord(daysAgo: 1, emotion: .anxious),
            createMockRecord(daysAgo: 2, emotion: .happy),
            createMockRecord(daysAgo: 3, emotion: .tired)
        ]
        await mockDatabaseClient.setMockRecords(records)
        
        let weekData = try await sut.fetchWeeklyData(for: Date())
        
        XCTAssertEqual(weekData.mostFrequentEmotions.count, 3)
        
        let mostFrequent = weekData.mostFrequentEmotions[0]
        XCTAssertEqual(mostFrequent.emotion, .happy)
        XCTAssertEqual(mostFrequent.count, 3)
        
        let secondMostFrequent = weekData.mostFrequentEmotions[1]
        XCTAssertEqual(secondMostFrequent.count, 1)
        
        let leastFrequent = weekData.mostFrequentEmotions[2]
        XCTAssertEqual(leastFrequent.count, 1)
    }
    
    func testFetchWeeklyData_NoRecords_ReturnsEmptyFrequency() async throws {
        await mockDatabaseClient.setMockRecords([])
        
        let weekData = try await sut.fetchWeeklyData(for: Date())
        
        XCTAssertTrue(weekData.mostFrequentEmotions.isEmpty)
    }
    
    // MARK: - Daily Grouping Tests
    
    func testFetchWeeklyData_DailyGrouping_GroupsByDayCorrectly() async throws {
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        let records = [
            createMockRecord(daysAgo: 0, emotion: .happy),
            createMockRecord(daysAgo: 0, emotion: .anxious),
            createMockRecord(daysAgo: 1, emotion: .tired),
            createMockRecord(daysAgo: 7, emotion: .chill)
        ]
        await mockDatabaseClient.setMockRecords(records)
        
        let weekData = try await sut.fetchWeeklyData(for: today)
        
        let todayNormalized = calendar.startOfDay(for: today)
        let yesterdayNormalized = calendar.startOfDay(for: yesterday)
        
        XCTAssertEqual(weekData.dailyEmotions.count, 7)
        
        XCTAssertEqual(weekData.dailyEmotions[todayNormalized]?.count, 2)
        
        XCTAssertEqual(weekData.dailyEmotions[yesterdayNormalized]?.count, 1)
        
        let totalRecordsInWeek = weekData.dailyEmotions.values.reduce(0) { $0 + $1.count }
        XCTAssertEqual(totalRecordsInWeek, 3)
    }
    
    func testFetchWeeklyData_DailyGrouping_InitializesAllDaysOfWeek() async throws {
        await mockDatabaseClient.setMockRecords([])
        
        let weekData = try await sut.fetchWeeklyData(for: Date())
        
        XCTAssertEqual(weekData.dailyEmotions.count, 7)
        
        for (_, records) in weekData.dailyEmotions {
            XCTAssertEqual(records.count, 0)
        }
    }
    
    // MARK: - Time of Day Tests
    
    func testFetchWeeklyData_TimeOfDay_GroupsCorrectly() async throws {
        let records = [
            createRecordForTimeOfDay(.earlyMorning, emotion: .tired),
            createRecordForTimeOfDay(.earlyMorning, emotion: .tired),
            createRecordForTimeOfDay(.morning, emotion: .happy),
            createRecordForTimeOfDay(.day, emotion: .productivity),
            createRecordForTimeOfDay(.evening, emotion: .chill),
            createRecordForTimeOfDay(.lateEvening, emotion: .anxious)
        ]
        await mockDatabaseClient.setMockRecords(records)
        
        let weekData = try await sut.fetchWeeklyData(for: Date())
        
        XCTAssertEqual(weekData.timeOfDayMoods.count, 5)
        
        let earlyMorningMoods = weekData.timeOfDayMoods[.earlyMorning]!
        XCTAssertEqual(earlyMorningMoods.count, 1)
        XCTAssertEqual(earlyMorningMoods[0].emotion, .tired)
        XCTAssertEqual(earlyMorningMoods[0].percentage, 1.0, accuracy: 0.001)
        
        let morningMoods = weekData.timeOfDayMoods[.morning]!
        XCTAssertEqual(morningMoods.count, 1)
        XCTAssertEqual(morningMoods[0].emotion, .happy)
        XCTAssertEqual(morningMoods[0].percentage, 1.0, accuracy: 0.001)
    }
    
    func testFetchWeeklyData_TimeOfDay_CalculatesPercentagesCorrectly() async throws {
        let records = [
            createRecordForTimeOfDay(.morning, emotion: .happy),
            createRecordForTimeOfDay(.morning, emotion: .happy),
            createRecordForTimeOfDay(.morning, emotion: .anxious),
            createRecordForTimeOfDay(.morning, emotion: .tired)
        ]
        await mockDatabaseClient.setMockRecords(records)
        
        let weekData = try await sut.fetchWeeklyData(for: Date())
        
        let morningMoods = weekData.timeOfDayMoods[.morning]!
        XCTAssertEqual(morningMoods.count, 3)
        
        let happyFrequency = morningMoods.first { $0.emotion == .happy }!
        XCTAssertEqual(happyFrequency.percentage, 0.5, accuracy: 0.001)
        
        let anxiousFrequency = morningMoods.first { $0.emotion == .anxious }!
        XCTAssertEqual(anxiousFrequency.percentage, 0.25, accuracy: 0.001)
        
        let tiredFrequency = morningMoods.first { $0.emotion == .tired }!
        XCTAssertEqual(tiredFrequency.percentage, 0.25, accuracy: 0.001)
    }
    
    func testFetchWeeklyData_TimeOfDay_EmptyPeriods() async throws {
        let records = [
            createRecordForTimeOfDay(.morning, emotion: .happy)
        ]
        await mockDatabaseClient.setMockRecords(records)
        
        let weekData = try await sut.fetchWeeklyData(for: Date())
        
        XCTAssertEqual(weekData.timeOfDayMoods.count, 1)
        XCTAssertNotNil(weekData.timeOfDayMoods[.morning])
        XCTAssertNil(weekData.timeOfDayMoods[.earlyMorning])
        XCTAssertNil(weekData.timeOfDayMoods[.day])
        XCTAssertNil(weekData.timeOfDayMoods[.evening])
        XCTAssertNil(weekData.timeOfDayMoods[.lateEvening])
    }
    
    // MARK: - FetchAllWeeks Tests
    
    func testFetchAllWeeks_ReturnsWeekIntervals() async throws {
        let records = [
            createMockRecord(daysAgo: 0),
            createMockRecord(daysAgo: 7),
            createMockRecord(daysAgo: 14),
            createMockRecord(daysAgo: 21)
        ]
        await mockDatabaseClient.setMockRecords(records)
        
        let weeks = try await sut.fetchAllWeeks()
        
        XCTAssertGreaterThanOrEqual(weeks.count, 4)
        
        for i in 0 ..< (weeks.count - 1) {
            XCTAssertGreaterThan(weeks[i].start, weeks[i + 1].start)
        }
    }
    
    func testFetchAllWeeks_NoRecords_ReturnsEmpty() async throws {
        // Given
        await mockDatabaseClient.setMockRecords([])
        
        // When
        let weeks = try await sut.fetchAllWeeks()
        
        // Then
        XCTAssertTrue(weeks.isEmpty)
    }
    
    // MARK: - Error Handling Tests
    
    func testFetchWeeklyData_DatabaseError_ThrowsError() async {
        await mockDatabaseClient.setShouldThrowError(true)
        
        do {
            _ = try await sut.fetchWeeklyData(for: Date())
            XCTFail("Should have thrown an error")
        } catch {}
    }
    
    func testFetchAllWeeks_DatabaseError_ThrowsError() async {
        await mockDatabaseClient.setShouldThrowError(true)
        
        do {
            _ = try await sut.fetchAllWeeks()
            XCTFail("Should have thrown an error")
        } catch {}
    }
    
    // MARK: - Edge Cases
    
    func testFetchWeeklyData_InvalidDate_ReturnsEmptyData() async throws {
        await mockDatabaseClient.setMockRecords([])
        let calendar = Calendar.current
        
        let distantDate = calendar.date(byAdding: .year, value: -100, to: Date())!
        
        let weekData = try await sut.fetchWeeklyData(for: distantDate)
        
        XCTAssertTrue(weekData.mostFrequentEmotions.isEmpty)
        XCTAssertTrue(weekData.timeOfDayMoods.isEmpty)
        XCTAssertEqual(weekData.dailyEmotions.count, 7)
    }
}
