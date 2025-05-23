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
        // TODO: Replace with dbClient logic when question answers become persistent
        let defaults: [[String]] = [
            ["Прием пищи", "Встреча с друзьями", "Тренировка", "Хобби", "Отдых", "Поездка"],
            ["Один", "Друзья", "Семья", "Коллеги", "Партнер", "Питомцы"],
            ["Дом", "Работа", "Школа", "Транспорт", "Улица"]
        ]
        if index < defaults.count {
            return defaults[index]
        }
        return []
    }

    func addCustomAnswer(_ answer: String, forQuestion index: Int) async {
        // TODO: Implement persistence using dbClient for custom answers
    }
}
