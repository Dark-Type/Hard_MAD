//
//  AppColors.swift
//  Hard_MAD
//
//  Created by dark type on 24.05.2025.
//

import UIKit

enum AppColors {
    enum Surface {
        static let primary = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
        static let secondary = UIColor(red: 44/255, green: 44/255, blue: 46/255, alpha: 1)
        static let tertiary = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
        static let dark = UIColor(red: 26/255, green: 26/255, blue: 26/255, alpha: 1)
        static let darkSecondary = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)
    }

    enum Text {
        static let primary = UIColor.white
        static let secondary = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
    }

    enum Emotion {
        static let red = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        static let blue = UIColor(red: 0.0, green: 0.667, blue: 1.0, alpha: 1.0)
        static let green = UIColor(red: 0.0, green: 1.0, blue: 0.333, alpha: 1.0)
        static let yellow = UIColor(red: 1.0, green: 0.667, blue: 0.0, alpha: 1.0)

        enum Red {
            static let gradientStart = UIColor(red: 255/255, green: 85/255, blue: 51/255, alpha: 1.0)
            static let gradientEnd = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1.0)
        }

        enum Blue {
            static let gradientStart = UIColor(red: 51/255, green: 221/255, blue: 255/255, alpha: 1.0)
            static let gradientEnd = UIColor(red: 0/255, green: 170/255, blue: 255/255, alpha: 1.0)
        }

        enum Green {
            static let gradientStart = UIColor(red: 51/255, green: 255/255, blue: 187/255, alpha: 1.0)
            static let gradientEnd = UIColor(red: 0/255, green: 255/255, blue: 85/255, alpha: 1.0)
        }

        enum Yellow {
            static let gradientStart = UIColor(red: 255/255, green: 255/255, blue: 51/255, alpha: 1.0)
            static let gradientEnd = UIColor(red: 255/255, green: 170/255, blue: 0/255, alpha: 1.0)
        }

        enum Common {
            static let commonColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1).cgColor
        }
    }
}
