//
//  MockQuestionService.swift
//  Hard_MAD
//
//  Created by dark type on 03.03.2025.
//

import Foundation

actor MockQuestionService: QuestionServiceProtocol {
    private actor DefaultDataStore {
        private var defaultAnswers: [Int: Set<String>]
        
        init() {
            defaultAnswers = [
                0: ["Прием пищи", "Встреча с друзьями", "Тренировка", "Хобби", "Отдых", "Поездка"],
                1: ["Один", "Друзья", "Семья", "Коллеги", "Партнер", "Питомцы"],
                2: ["Дом", "Работа", "Школа", "Транспорт", "Улица"]
            ]
        }
        
        func getDefaultAnswers(forQuestion index: Int) -> Set<String> {
            return defaultAnswers[index, default: []]
        }
        
        func addDefaultAnswer(_ answer: String, forQuestion index: Int) {
            defaultAnswers[index, default: []].insert(answer)
        }
    }
    
    private static let defaultDataStore = DefaultDataStore()
    
    private var customAnswers: [Int: Set<String>] = [:]
    private var initialized = false
    
    private let defaultQuestions = [
        L10n.Record.Questions.question1,
        L10n.Record.Questions.question2,
        L10n.Record.Questions.question3
    ]
    
    init() {}
    
    private func ensureInitialized() async {
        if !initialized {
            for i in 0 ..< defaultQuestions.count {
                let defaults = await Self.defaultDataStore.getDefaultAnswers(forQuestion: i)
                customAnswers[i] = defaults
            }
            initialized = true
        }
    }
    
    func getAnswers(forQuestion index: Int) async -> [String] {
        await ensureInitialized()
        return Array(customAnswers[index, default: []]).sorted()
    }

    func addCustomAnswer(_ answer: String, forQuestion index: Int) async {
        await ensureInitialized()
        customAnswers[index, default: []].insert(answer)
        
        await Self.defaultDataStore.addDefaultAnswer(answer, forQuestion: index)
    }

    nonisolated func getQuestion(forIndex index: Int) -> String {
        guard index >= 0, index < defaultQuestions.count else {
            return "Unknown Question"
        }
        return defaultQuestions[index]
    }
    
    nonisolated func getQuestionCount() -> Int {
        return defaultQuestions.count
    }
}

extension MockQuestionService {
    func configureForUITesting() async {
        if CommandLine.arguments.contains("--UITesting") {
            initialized = false
            await ensureInitializedForUITesting()
        }
    }
    
    private func ensureInitializedForUITesting() async {
        if !initialized {
            customAnswers = [:]
            
            let emptyRecord = ProcessInfo.processInfo.environment["UI_TEST_RECORD_EMPTY"] == "true"
            
            if emptyRecord {
                customAnswers[0] = []
                customAnswers[1] = []
                customAnswers[2] = []
            } else {
                customAnswers = [
                    0: ["Прием пищи", "Встреча с друзьями", "Тренировка", "Хобби", "Отдых", "Поездка"],
                    1: ["Один", "Друзья", "Семья", "Коллеги", "Партнер", "Питомцы"],
                    2: ["Дом", "Работа", "Школа", "Транспорт", "Улица"]
                ]
            }
            
            initialized = true
        }
    }

    func getQuestionForUITesting(forIndex index: Int) -> String {
        switch index {
        case 0: return L10n.Record.Questions.question1
        case 1: return L10n.Record.Questions.question2
        case 2: return L10n.Record.Questions.question3
        default: return "Question \(index + 1)"
        }
    }
    
    func getAnswersForUITesting(forQuestion index: Int) async -> [String] {
        if CommandLine.arguments.contains("--UITesting") {
            await ensureInitializedForUITesting()
        }
        return Array(customAnswers[index, default: []]).sorted()
    }
}
