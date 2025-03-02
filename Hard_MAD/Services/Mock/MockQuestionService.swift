//
//  MockQuestionService.swift
//  Hard_MAD
//
//  Created by dark type on 03.03.2025.
//

enum QuestionMockData {
    nonisolated(unsafe) static var defaultAnswers: [Int: Set<String>] = [
        0: ["Happy", "Excited", "Peaceful", "Content"],
        1: ["Family", "Work", "Health", "Personal Growth", "Relationships"],
        2: ["Accomplished", "Challenged", "Motivated", "Grateful", "Inspired"]
    ]

    static func getDefaultQuestion(forIndex index: Int) -> String {
        switch index {
        case 0:
            return "How do you feel?"
        case 1:
            return "What area of life does this relate to?"
        case 2:
            return "What's your emotional state?"
        default:
            return "Question \(index + 1)"
        }
    }
}

final class MockQuestionService: QuestionServiceProtocol {
    func getAnswers(forQuestion index: Int) -> [String] {
        
        return Array(QuestionMockData.defaultAnswers[index] ?? [])
    }

    func addCustomAnswer(_ answer: String, forQuestion index: Int) {
        QuestionMockData.defaultAnswers[index, default: []].insert(answer)
    }

    func getQuestion(forIndex index: Int) -> String {
        return QuestionMockData.getDefaultQuestion(forIndex: index)
    }
}
