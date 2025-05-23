//
//  QuestionService.swift
//  Hard_MAD
//
//  Created by dark type on 15.05.2025.
//

import Foundation

final class QuestionService: QuestionServiceProtocol {
    private let dbClient: DatabaseClientProtocol

    init(dbClient: DatabaseClientProtocol) {
        self.dbClient = dbClient
    }

    func getQuestion(forIndex index: Int) -> String {
        switch index {
        case 0: return L10n.Record.Questions.question1
        case 1: return L10n.Record.Questions.question2
        case 2: return L10n.Record.Questions.question3
        default: return "Unknown Question"
        }
    }

    nonisolated func getQuestionCount() -> Int {
        return 3
    }

    func getAnswers(forQuestion index: Int) async -> [String] {
        do {
            let answers = try await dbClient.fetchQuestionAnswers(forQuestion: index)

            return answers
        } catch {
            return []
        }
    }

    func addCustomAnswer(_ answer: String, forQuestion index: Int) async {
        do {
            try await dbClient.addQuestionAnswer(answer, forQuestion: index)
        } catch {
            print("QuestionService: Failed to add custom answer: \(error)")
        }
    }
}
