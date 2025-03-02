//
//  QuestionService.swift
//  Hard_MAD
//
//  Created by dark type on 03.03.2025.
//


protocol QuestionServiceProtocol: Sendable {
    func getAnswers(forQuestion index: Int) -> [String]
    func addCustomAnswer(_ answer: String, forQuestion index: Int)
    func getQuestion(forIndex index: Int) -> String
}


