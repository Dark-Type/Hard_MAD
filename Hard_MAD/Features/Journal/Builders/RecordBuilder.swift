//
//  RecordBuilder.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//
import Foundation

@MainActor
final class RecordBuilder {
    private(set) var selectedEmotion: Emotion?
    private(set) var answers: [String?] = [nil, nil, nil]

    func setEmotion(_ emotion: Emotion) {
        selectedEmotion = emotion
    }

    func setAnswer(_ answer: String, forQuestion index: Int) {
        guard index >= 0, index < 3 else { return }
        answers[index] = answer
    }

    func build() -> JournalRecord? {
        guard let emotion = selectedEmotion,
              let answer0 = answers[0],
              let answer1 = answers[1],
              let answer2 = answers[2],
              !answer0.isEmpty,
              !answer1.isEmpty,
              !answer2.isEmpty
        else {
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

extension RecordBuilder {
    func configureForUITesting() {
        if CommandLine.arguments.contains("--UITesting") {
            let isRecordEmpty = ProcessInfo.processInfo.environment["UI_TEST_RECORD_EMPTY"] == "true"

            if !isRecordEmpty {
                setAnswer("Test answer for question 1", forQuestion: 0)
                setAnswer("Test answer for question 2", forQuestion: 1)
                setAnswer("Test answer for question 3", forQuestion: 2)
            }

            if let emotionName = ProcessInfo.processInfo.environment["UI_TEST_RECORD_EMOTION"],
               !emotionName.isEmpty
            {
                if let emotion = mapStringToEmotion(emotionName) {
                    setEmotion(emotion)
                } else {
                    setEmotion(.happy)
                }
            }
        }
    }

    private func mapStringToEmotion(_ name: String) -> Emotion? {
        let lowercaseName = name.lowercased()

        if let emotion = Emotion.allCases.first(where: { $0.rawValue.lowercased() == lowercaseName }) {
            return emotion
        }

        switch lowercaseName {
        case "burnout": return .burnout
        case "chill": return .chill
        case "productivity": return .productivity
        case "anxious": return .anxious
        case "happy": return .happy
        case "tired": return .tired
        default: return nil
        }
    }

    func buildForUITesting() -> JournalRecord? {
        if CommandLine.arguments.contains("--UITesting") {
            let isRecordEmpty = ProcessInfo.processInfo.environment["UI_TEST_RECORD_EMPTY"] == "true"

            if isRecordEmpty {
                return nil
            }

            let record = JournalRecord(
                emotion: selectedEmotion ?? .happy,
                answer0: answers[0] ?? "Test answer 1",
                answer1: answers[1] ?? "Test answer 2",
                answer2: answers[2] ?? "Test answer 3"
            )

            return record
        }

        return build()
    }
}
