//
//  QuestionService.swift
//  Hard_MAD
//
//  Created by dark type on 03.03.2025.
//

protocol QuestionServiceProtocol: Sendable {
    func getAnswers(forQuestion index: Int) async -> [String]
    func addCustomAnswer(_ answer: String, forQuestion index: Int) async
    nonisolated func getQuestion(forIndex index: Int) -> String
    nonisolated func getQuestionCount() -> Int
}
