//
//  RecordViewModel.swift
//  Hard_MAD
//
//  Created by dark type on 03.03.2025.
//
import Combine
import UIKit

final class RecordViewModel: BaseViewModel {
    // MARK: - Properties

    private let container: Container
    private let recordBuilder: RecordBuilder
    
    @Published private(set) var questions: [String] = []
    @Published private(set) var answers: [[String]] = []
    
    var selectedEmotion: Emotion? {
        recordBuilder.selectedEmotion
    }
    
    // MARK: - Initialization

    init(container: Container, recordBuilder: RecordBuilder) {
        self.container = container
        self.recordBuilder = recordBuilder
        super.init()
    }
    
    // MARK: - Lifecycle

    override func initialize() async {
        loadHardcodedData()
    }
    
    // MARK: - Public Methods
    
    func setAnswer(_ answer: String, forQuestion index: Int) {
        recordBuilder.setAnswer(answer, forQuestion: index)
    }
    
    func addCustomAnswer(_ answer: String, forQuestion index: Int) async {
        if index >= 0 && index < answers.count {
            var updatedAnswers = answers[index]
            if !updatedAnswers.contains(answer) {
                updatedAnswers.append(answer)
                var newAnswers = answers
                newAnswers[index] = updatedAnswers
                answers = newAnswers
            }
            
            setAnswer(answer, forQuestion: index)
        }
    }
    
    func buildRecord() -> JournalRecord? {
        recordBuilder.build()
    }
    
    // MARK: - Private Methods

    private func loadHardcodedData() {
        questions = [
            L10n.Record.Questions.question1,
            L10n.Record.Questions.question2,
            L10n.Record.Questions.question3
        ]
        
        answers = [
            ["Прием пищи", "Встреча с друзьями", "Тренировка", "Хобби", "Отдых", "Поездка"],
            ["Один", "Друзья", "Семья", "Коллеги", "Партнер", "Питомцы"],
            ["Дом", "Работа", "Школа", "Транспорт", "Улица"]
        ]
        print(questions)
        print(answers)
    }
}
