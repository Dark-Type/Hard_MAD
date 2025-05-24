//
//  JournalRecordDTO.swift
//  Hard_MAD
//
//  Created by dark type on 15.05.2025.
//

import Foundation

struct JournalRecordDTO: Codable, Identifiable {
    let id: UUID
    let emotionRaw: String
    let answer0: String
    let answer1: String
    let answer2: String
    let createdAt: Date
}

extension JournalRecordDTO {
    init(from record: JournalRecord) {
        self.id = record.id
        self.emotionRaw = record.emotion.rawValue
        self.answer0 = record.answer0
        self.answer1 = record.answer1
        self.answer2 = record.answer2
        self.createdAt = record.createdAt
    }
}
