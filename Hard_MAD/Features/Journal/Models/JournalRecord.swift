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

enum Emotion: String, Sendable, CaseIterable {
    case burnout = "Выгорание"
    case chill = "Спокойствие"
    case productivity = "Продуктивность"
    case anxious = "Беспокойство"
    case happy = "Счастье"
    case tired = "Усталость"
    
    var color: UIColor {
        switch self {
        case .anxious:
            return UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        case .burnout, .tired:
            return UIColor(red: 0.0, green: 0.667, blue: 1.0, alpha: 1.0)
        case .chill:
            return UIColor(red: 0.0, green: 1.0, blue: 0.333, alpha: 1.0)
        case .happy, .productivity:
            return UIColor(red: 1.0, green: 0.667, blue: 0.0, alpha: 1.0)
        }
    }
    
    var gradientColors: (start: UIColor, end: UIColor) {
        let startColor = color
        let endColor = color.withAlphaComponent(0.0)
        return (startColor, endColor)
    }
    
    var image: UIImage {
        switch self {
        case .burnout:
            return UIImage(named: "burnoutEmotions") ?? UIImage(systemName: "flame.fill")!
        case .chill:
            return UIImage(named: "chillEmotions") ?? UIImage(systemName: "cloud.fill")!
        case .productivity:
            return UIImage(named: "productivityEmotions") ?? UIImage(systemName: "bolt.fill")!
        case .anxious:
            return UIImage(named: "anxiousEmotions") ?? UIImage(systemName: "exclamationmark.triangle.fill")!
        case .happy:
            return UIImage(named: "happinessEmotions") ?? UIImage(systemName: "face.smiling.fill")!
        case .tired:
            return UIImage(named: "tiredEmotions") ?? UIImage(systemName: "moon.zzz.fill")!
        }
    }
    
    var description: String {
        switch self {
        case .burnout:
            return "Чувство истощения, эмоциональное опустошение"
        case .chill:
            return "Состояние покоя и расслабления"
        case .productivity:
            return "Ощущение эффективности и мотивации"
        case .anxious:
            return "Беспокойство и нервное напряжение"
        case .happy:
            return "Чувство радости и удовлетворения"
        case .tired:
            return "Физическая и эмоциональная усталость"
        }
    }
}
