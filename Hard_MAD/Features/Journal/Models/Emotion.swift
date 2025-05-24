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
            return AppColors.Emotion.red
        case .burnout, .tired:
            return AppColors.Emotion.blue
        case .chill:
            return AppColors.Emotion.green
        case .happy, .productivity:
            return AppColors.Emotion.yellow
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
               return L10n.Emotion.Description.burnout
           case .chill:
               return L10n.Emotion.Description.chill
           case .productivity:
               return L10n.Emotion.Description.productivity
           case .anxious:
               return L10n.Emotion.Description.anxious
           case .happy:
               return L10n.Emotion.Description.happy
           case .tired:
               return L10n.Emotion.Description.tired
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
                return AppColors.Emotion.red
            case .blueEmotion:
                return AppColors.Emotion.blue
            case .greenEmotion:
                return AppColors.Emotion.green
            case .yellowEmotion:
                return AppColors.Emotion.yellow
            }
        }
        
        var gradientType: (start: UIColor, end: UIColor) {
            switch self {
            case .redEmotion:
                return (AppColors.Emotion.Red.gradientStart, AppColors.Emotion.Red.gradientEnd)
            case .blueEmotion:
                return (AppColors.Emotion.Blue.gradientStart, AppColors.Emotion.Blue.gradientEnd)
            case .greenEmotion:
                return (AppColors.Emotion.Green.gradientStart, AppColors.Emotion.Green.gradientEnd)
            case .yellowEmotion:
                return (AppColors.Emotion.Yellow.gradientStart, AppColors.Emotion.Yellow.gradientEnd)
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
