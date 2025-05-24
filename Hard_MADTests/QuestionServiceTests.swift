//
//  QuestionServiceTests.swift
//  Hard_MAD
//
//  Created by dark type on 24.05.2025.
//
@testable import Hard_MAD
import XCTest

final class QuestionServiceTests: XCTestCase {
    var sut: QuestionService!
    var mockDatabaseClient: MockDatabaseClient!
    
    override func setUp() async throws {
        try await super.setUp()
        mockDatabaseClient = MockDatabaseClient()
        sut = QuestionService(dbClient: mockDatabaseClient)
    }
    
    override func tearDown() {
        sut = nil
        mockDatabaseClient = nil
        super.tearDown()
    }
    
    // MARK: - Get Question Tests

    func testGetQuestion_ReturnsCorrectQuestions() {
        XCTAssertEqual(sut.getQuestion(forIndex: 0), L10n.Record.Questions.question1)
        XCTAssertEqual(sut.getQuestion(forIndex: 1), L10n.Record.Questions.question2)
        XCTAssertEqual(sut.getQuestion(forIndex: 2), L10n.Record.Questions.question3)
        XCTAssertEqual(sut.getQuestion(forIndex: 99), "Unknown Question")
    }
    
    func testGetQuestionCount_ReturnsThree() {
        XCTAssertEqual(sut.getQuestionCount(), 3)
    }
    
    // MARK: - Get Answers Tests

    func testGetAnswers_ReturnsAnswers() async {
        await mockDatabaseClient.setQuestionAnswers([0: ["Прием пищи", "Тренировка"]])
        
        let answers = await sut.getAnswers(forQuestion: 0)
        
        XCTAssertEqual(answers.count, 2)
        XCTAssertTrue(answers.contains("Прием пищи"))
        XCTAssertTrue(answers.contains("Тренировка"))
    }
    
    func testGetAnswers_DatabaseError_ReturnsEmpty() async {
        await mockDatabaseClient.setShouldThrowError(true)
        
        let answers = await sut.getAnswers(forQuestion: 0)
        
        XCTAssertTrue(answers.isEmpty)
    }
    
    // MARK: - Add Custom Answer Tests

    func testAddCustomAnswer_Success() async {
        let customAnswer = "Custom Activity"
        
        await sut.addCustomAnswer(customAnswer, forQuestion: 0)
        
        let attemptWasMade = await mockDatabaseClient.getAddAnswerAttempted()
        XCTAssertTrue(attemptWasMade)
        
        let answers = await mockDatabaseClient.getQuestionAnswers(forQuestion: 0)
        XCTAssertTrue(answers.contains(customAnswer))
    }
    
    func testAddCustomAnswer_DatabaseError_HandlesGracefully() async {
        await mockDatabaseClient.setShouldThrowError(true)
        
        await sut.addCustomAnswer("Test Answer", forQuestion: 0)
        
        let attemptWasMade = await mockDatabaseClient.getAddAnswerAttempted()
        XCTAssertTrue(attemptWasMade)
    }
}

extension MockDatabaseClient {
    func setQuestionAnswers(_ answers: [Int: [String]]) async {
        mockQuestionAnswers = answers
    }
    
    func getQuestionAnswers(forQuestion index: Int) async -> [String] {
        return mockQuestionAnswers[index] ?? []
    }
    
    func getAddAnswerAttempted() async -> Bool {
        return addAnswerAttempted
    }
}
