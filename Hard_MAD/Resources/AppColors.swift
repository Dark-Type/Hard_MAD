//
//  AppColors.swift
//  Hard_MAD
//
//  Created by dark type on 24.05.2025.
//

import UIKit

enum AppColors {
    enum Surface {
        static let primary = UIColor(named: "surface-primary")!
        static let secondary = UIColor(named: "surface-secondary")!
        static let tertiary = UIColor(named: "surface-tertiary")!
        static let dark = UIColor(named: "surface-dark")!
        static let darkSecondary = UIColor(named: "surface-dark-secondary")!
    }

    enum Text {
        static let primary = UIColor(named: "text-primary")!
        static let secondary = UIColor(named: "text-secondary")!
    }

    enum Emotion {
        static let red = UIColor(named: "emotion-red")!
        static let blue = UIColor(named: "emotion-blue")!
        static let green = UIColor(named: "emotion-green")!
        static let yellow = UIColor(named: "emotion-yellow")!

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
