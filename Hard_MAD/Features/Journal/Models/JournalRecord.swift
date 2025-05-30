//
//  JournalRecord.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//
import UIKit

struct JournalRecord: Sendable {
    let id: UUID
    let emotion: Emotion
    let answer0: String
    let answer1: String
    let answer2: String
    let createdAt: Date

    init(emotion: Emotion, answer0: String, answer1: String, answer2: String) {
        self.id = UUID()
        self.emotion = emotion
        self.answer0 = answer0
        self.answer1 = answer1
        self.answer2 = answer2
        self.createdAt = Date()
    }
}
extension JournalRecord {
    init(from dto: JournalRecordDTO) {
        self.id = dto.id
        self.emotion = Emotion(rawValue: dto.emotionRaw) ?? .happy 
        self.answer0 = dto.answer0
        self.answer1 = dto.answer1
        self.answer2 = dto.answer2
        self.createdAt = dto.createdAt
    }
}
