//
//  GradientColors.swift
//  Hard_MAD
//
//  Created by dark type on 28.02.2025.
//

import UIKit

enum GradientColors {
    enum Corner {
        case first
        case second
        case third
        case fourth

        var color: UIColor {
            switch self {
            case .first:
                return UIColor(named: "firstCorner") ?? .clear
            case .second:
                return UIColor(named: "secondCorner") ?? .clear
            case .third:
                return UIColor(named: "thirdCorner") ?? .clear
            case .fourth:
                return UIColor(named: "fourthCorner") ?? .clear
            }
        }
    }

    static func getColors() -> [UIColor] {
        return [
            Corner.first.color,
            Corner.second.color,
            Corner.third.color,
            Corner.fourth.color
        ]
    }
}
