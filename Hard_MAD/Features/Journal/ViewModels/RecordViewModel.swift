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

    private let recordBuilder: RecordBuilder
    private let questionService: QuestionServiceProtocol
    
    @Published private(set) var questions: [String] = []
    @Published private(set) var answers: [[String]] = []
    
    var selectedEmotion: Emotion? {
        recordBuilder.selectedEmotion
    }
    
    // MARK: - Initialization

    init(recordBuilder: RecordBuilder, questionService: QuestionServiceProtocol) {
        self.recordBuilder = recordBuilder
        self.questionService = questionService
        super.init()
    }
    
    // MARK: - Lifecycle

    override func initialize() async {
        await loadQuestions()
    }
    
    // MARK: - Public Methods

    func setAnswer(_ answer: String, forQuestion index: Int) {
        recordBuilder.setAnswer(answer, forQuestion: index)
    }
    
    func addCustomAnswer(_ answer: String, forQuestion index: Int) async {
        guard index >= 0, index < answers.count else { return }
        
        await questionService.addCustomAnswer(answer, forQuestion: index)
        
        let updatedAnswers = await questionService.getAnswers(forQuestion: index)
        
        await MainActor.run {
            var newAnswers = self.answers
            newAnswers[index] = updatedAnswers
            self.answers = newAnswers
        }
        
        setAnswer(answer, forQuestion: index)
    }
    
    func buildRecord() -> JournalRecord? {
        recordBuilder.build()
    }
    
    // MARK: - Private Methods

    private func loadQuestions() async {
        var questionsList: [String] = []
        var answersList: [[String]] = []
        
        let questionCount = 3
        
        for i in 0 ..< questionCount {
            let question = questionService.getQuestion(forIndex: i)
            let answerOptions = await questionService.getAnswers(forQuestion: i)
            
            questionsList.append(question)
            answersList.append(answerOptions)
        }
        
        await MainActor.run {
            self.questions = questionsList
            self.answers = answersList
        }
    }
}
