//
//  AnalysisWeekData.swift
//  Hard_MAD
//
//  Created by dark type on 03.03.2025.
//

import UIKit

struct AnalysisWeekData: Sendable {
    let weekRange: DateInterval
    let dailyEmotions: [Date: [JournalRecord]]
    let mostFrequentEmotions: [(emotion: Emotion, count: Int)]
    let timeOfDayMoods: [TimeOfDay: [EmotionFrequency]]
    
    var weekDisplayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        formatter.locale = Locale(identifier: "ru_RU")
        
        let startStr = formatter.string(from: weekRange.start)
        let endStr = formatter.string(from: weekRange.end)
        return "\(startStr) - \(endStr)"
    }
    
    func emotionsByGroup() -> [UIColor: Int] {
        var result = [UIColor: Int]()
        
        for (_, records) in dailyEmotions {
            for record in records {
                let color = record.emotion.color
                result[color, default: 0] += 1
            }
        }
        
        return result
    }
}
