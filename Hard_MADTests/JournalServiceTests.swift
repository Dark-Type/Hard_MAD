//
//  JournalServiceTests.swift
//  Hard_MADTests
//
//  Created by dark type on 24.05.2025.
//

@testable import Hard_MAD
import XCTest

// MARK: - Mock Database Client

final actor MockDatabaseClient: DatabaseClientProtocol {
    var mockJournalRecords: [JournalRecordDTO] = []
    var mockNotificationTimes: [NotificationTimeDTO] = []
    var mockQuestionAnswers: [Int: [String]] = [:]
    var shouldThrowError = false
    var saveRecordCalled = false
    var addAnswerAttempted = false
    var fetchRecordsSortOrder: JournalSortOrder?
    
    // MARK: - Journal Records

    func fetchJournalRecords(sorted: JournalSortOrder?) async throws -> [JournalRecordDTO] {
        if shouldThrowError {
            throw DatabaseError.unexpectedError
        }
        
        fetchRecordsSortOrder = sorted
        
        guard let sorted = sorted else {
            return mockJournalRecords
        }
        
        switch sorted {
        case .byDateDescending:
            return mockJournalRecords.sorted { $0.createdAt > $1.createdAt }
        case .byDateAscending:
            return mockJournalRecords.sorted { $0.createdAt < $1.createdAt }
        }
    }
    
    func fetchJournalRecord(id: UUID) async throws -> JournalRecordDTO? {
        if shouldThrowError { throw DatabaseError.unexpectedError }
        return mockJournalRecords.first { $0.id == id }
    }
    
    func saveJournalRecord(_ record: JournalRecordDTO) async throws {
        if shouldThrowError { throw DatabaseError.contextSaveError }
        saveRecordCalled = true
        
        if let index = mockJournalRecords.firstIndex(where: { $0.id == record.id }) {
            mockJournalRecords[index] = record
        } else {
            mockJournalRecords.append(record)
        }
    }
    
    func deleteJournalRecord(id: UUID) async throws {
        if shouldThrowError { throw DatabaseError.unexpectedError }
        mockJournalRecords.removeAll { $0.id == id }
    }
    
    func deleteAllJournalRecords() async throws {
        if shouldThrowError { throw DatabaseError.unexpectedError }
        mockJournalRecords.removeAll()
    }
    
    // MARK: - Notification Times

    func fetchNotificationTimes() async throws -> [NotificationTimeDTO] {
        if shouldThrowError { throw DatabaseError.unexpectedError }
        return mockNotificationTimes.sorted { $0.time < $1.time }
    }
    
    func fetchNotificationTime(id: UUID) async throws -> NotificationTimeDTO? {
        if shouldThrowError { throw DatabaseError.unexpectedError }
        return mockNotificationTimes.first { $0.id == id }
    }
    
    func saveNotificationTime(_ notification: NotificationTimeDTO) async throws {
        if shouldThrowError { throw DatabaseError.contextSaveError }
        if let index = mockNotificationTimes.firstIndex(where: { $0.id == notification.id }) {
            mockNotificationTimes[index] = notification
        } else {
            mockNotificationTimes.append(notification)
        }
    }
    
    func deleteNotificationTime(id: UUID) async throws {
        if shouldThrowError { throw DatabaseError.unexpectedError }
        mockNotificationTimes.removeAll { $0.id == id }
    }
    
    func deleteAllNotificationTimes() async throws {
        if shouldThrowError { throw DatabaseError.unexpectedError }
        mockNotificationTimes.removeAll()
    }
    
    // MARK: - Question Answers

    func fetchQuestionAnswers(forQuestion index: Int) async throws -> [String] {
        if shouldThrowError { throw DatabaseError.unexpectedError }
        return mockQuestionAnswers[index]?.sorted() ?? []
    }
    
    func addQuestionAnswer(_ answer: String, forQuestion index: Int) async throws {
        addAnswerAttempted = true
        if shouldThrowError { throw DatabaseError.contextSaveError }
        
        if mockQuestionAnswers[index] == nil {
            mockQuestionAnswers[index] = []
        }
        if !mockQuestionAnswers[index]!.contains(answer) {
            mockQuestionAnswers[index]!.append(answer)
        }
    }
    
    func deleteQuestionAnswer(_ answer: String, forQuestion index: Int) async throws {
        if shouldThrowError { throw DatabaseError.unexpectedError }
        mockQuestionAnswers[index]?.removeAll { $0 == answer }
    }
    
    // MARK: - Helper Methods

    func setMockRecords(_ records: [JournalRecordDTO]) async {
        mockJournalRecords = records
    }
    
    func setShouldThrowError(_ shouldThrow: Bool) async {
        shouldThrowError = shouldThrow
    }
    
    func getSaveRecordCalled() async -> Bool {
        return saveRecordCalled
    }
    
    func resetSaveRecordCalled() async {
        saveRecordCalled = false
    }
}

// MARK: - Main Test Class

final class JournalServiceTests: XCTestCase {
    var sut: JournalService!
    var mockDatabaseClient: MockDatabaseClient!
    
    override func setUp() async throws {
        try await super.setUp()
        mockDatabaseClient = MockDatabaseClient()
        sut = JournalService(dbClient: mockDatabaseClient)
    }
    
    override func tearDown() {
        sut = nil
        mockDatabaseClient = nil
        super.tearDown()
    }
    
    // MARK: - Helper Methods

    func createMockRecord(daysAgo: Int, emotion: Emotion = .happy) -> JournalRecordDTO {
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date())!
        
        return JournalRecordDTO(
            id: UUID(),
            emotionRaw: emotion.rawValue,
            answer0: "Test answer 0",
            answer1: "Test answer 1",
            answer2: "Test answer 2",
            createdAt: date
        )
    }
    
    // MARK: - Streak Days Tests

    func testStreakDays_ConsecutiveDays_ReturnsCorrectStreak() async {
        let records = [
            createMockRecord(daysAgo: 0),
            createMockRecord(daysAgo: 1),
            createMockRecord(daysAgo: 2)
        ]
        await mockDatabaseClient.setMockRecords(records)
        
        let statistics = await sut.fetchStatistics()
        
        XCTAssertEqual(statistics.streakDays, 3)
    }
    
    func testStreakDays_BrokenStreak_ReturnsCorrectCount() async {
        let records = [
            createMockRecord(daysAgo: 0),
            createMockRecord(daysAgo: 1),
           
            createMockRecord(daysAgo: 3)
        ]
        await mockDatabaseClient.setMockRecords(records)
        
        let statistics = await sut.fetchStatistics()
        
        XCTAssertEqual(statistics.streakDays, 2)
    }
    
    // MARK: - Today Count Tests

    func testTodayCount_ReturnsCorrectCount() async {
        let records = [
            createMockRecord(daysAgo: 0),
            createMockRecord(daysAgo: 0),
            createMockRecord(daysAgo: 1)
        ]
        await mockDatabaseClient.setMockRecords(records)
        
        let statistics = await sut.fetchStatistics()
        
        XCTAssertEqual(statistics.todayCount, 2)
        XCTAssertEqual(statistics.totalCount, 3)
    }
    
    // MARK: - Save Record Tests

    func testSaveRecord_Success() async {
        let record = JournalRecord(
            emotion: .happy,
            answer0: "Had lunch",
            answer1: "Friends",
            answer2: "Restaurant"
        )
        
        await sut.saveRecord(record)
        
        let wasCalled = await mockDatabaseClient.getSaveRecordCalled()
        XCTAssertTrue(wasCalled)
    }
    
    // MARK: - Sorting Tests

    func testFetchRecords_UsesSorting() async {
        await mockDatabaseClient.setMockRecords([createMockRecord(daysAgo: 0)])
        
        _ = await sut.fetchRecords()
        
        let sortOrder = await mockDatabaseClient.fetchRecordsSortOrder
        XCTAssertEqual(sortOrder, .byDateDescending)
    }
    
    // MARK: - Error Handling Tests

    func testFetchStatistics_DatabaseError_ReturnsZeroStatistics() async {
        await mockDatabaseClient.setShouldThrowError(true)
        
        let statistics = await sut.fetchStatistics()
        
        XCTAssertEqual(statistics.totalCount, 0)
        XCTAssertEqual(statistics.todayCount, 0)
        XCTAssertEqual(statistics.streakDays, 0)
    }
}
