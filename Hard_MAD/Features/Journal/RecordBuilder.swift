//
//  RecordBuilder.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//


@MainActor
final class RecordBuilder {
    private(set) var selectedEmotion: Emotion?
    private(set) var answers: [String?] = [nil, nil, nil]
    
    func setEmotion(_ emotion: Emotion) {
        selectedEmotion = emotion
    }
    
    func setAnswer(_ answer: String, forQuestion index: Int) {
        guard index >= 0 && index < 3 else { return }
        answers[index] = answer
    }
    
    func build() -> JournalRecord? {
        guard let emotion = selectedEmotion,
              let answer0 = answers[0],
              let answer1 = answers[1],
              let answer2 = answers[2],
              !answer0.isEmpty,
              !answer1.isEmpty,
              !answer2.isEmpty else {
            return nil
        }
        return JournalRecord(
            emotion: emotion,
            answer0: answer0,
            answer1: answer1,
            answer2: answer2
        )
    }
}
