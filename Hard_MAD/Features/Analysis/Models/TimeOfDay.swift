//
//  TimeOfDay.swift
//  Hard_MAD
//
//  Created by dark type on 03.03.2025.
//

import Foundation

enum TimeOfDay: String, CaseIterable {
    case earlyMorning = "Раннее утро"
    case morning = "Утро"
    case day = "День"
    case evening = "Вечер"
    case lateEvening = "Поздний вечер"

    static func from(date: Date) -> TimeOfDay {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)

        switch hour {
        case 5..<8: return .earlyMorning
        case 8..<12: return .morning
        case 12..<17: return .day
        case 17..<21: return .evening
        default: return .lateEvening
        }
    }
}
