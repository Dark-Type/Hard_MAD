//
//  MockQuestionService.swift
//  Hard_MAD
//
//  Created by dark type on 03.03.2025.
//

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
