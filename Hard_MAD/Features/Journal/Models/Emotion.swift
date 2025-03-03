//
//  Emotion.swift
//  Hard_MAD
//
//  Created by dark type on 04.03.2025.
//

import UIKit

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

extension Emotion {
    enum EmotionType: String, CaseIterable {
        case redEmotion = "Тревожность"
        case blueEmotion = "Истощение"
        case greenEmotion = "Спокойствие"
        case yellowEmotion = "Позитив"
        
        var color: UIColor {
            switch self {
            case .redEmotion:
                return UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
            case .blueEmotion:
                return UIColor(red: 0.0, green: 0.667, blue: 1.0, alpha: 1.0)
            case .greenEmotion:
                return UIColor(red: 0.0, green: 1.0, blue: 0.333, alpha: 1.0)
            case .yellowEmotion:
                return UIColor(red: 1.0, green: 0.667, blue: 0.0, alpha: 1.0)
            }
        }
        
        var gradientType: (start: UIColor, end: UIColor) {
            switch self {
            case .redEmotion:
                return (
                    UIColor(red: 255/255, green: 85/255, blue: 51/255, alpha: 1.0),
                    UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1.0)
                )
            case .blueEmotion:
                return (
                    UIColor(red: 51/255, green: 221/255, blue: 255/255, alpha: 1.0),
                    UIColor(red: 0/255, green: 170/255, blue: 255/255, alpha: 1.0)
                )
            case .greenEmotion:
                return (
                    UIColor(red: 51/255, green: 255/255, blue: 187/255, alpha: 1.0),
                    UIColor(red: 0/255, green: 255/255, blue: 85/255, alpha: 1.0)
                )
            case .yellowEmotion:
                return (
                    UIColor(red: 255/255, green: 255/255, blue: 51/255, alpha: 1.0),
                    UIColor(red: 255/255, green: 170/255, blue: 0/255, alpha: 1.0)
                )
            }
        }
    }
    
    var emotionType: EmotionType {
        switch self {
        case .anxious:
            return .redEmotion
        case .burnout, .tired:
            return .blueEmotion
        case .chill:
            return .greenEmotion
        case .happy, .productivity:
            return .yellowEmotion
        }
    }
}
