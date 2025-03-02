//
//  AppFont.swift
//  Hard_MAD
//
//  Created by dark type on 28.02.2025.
//

import UIKit

enum AppFont: String {
    case fancy = "Gwen-Trial-Bold"
    case regular = "VelaSansGX-ExtraLight_Regular"
    case fancySmall = "GwenText-Trial-SemiBold"
    case bold = "VelaSansGX-ExtraLight_SemiBold"

    func size(_ size: CGFloat) -> UIFont {
        if let font = UIFont(name: rawValue, size: size) {
            return font
        }

        switch self {
        case .fancy:
            return .systemFont(ofSize: size)
        case .regular:
            return .boldSystemFont(ofSize: size)
        case .fancySmall:
            return .boldSystemFont(ofSize: size)
        case .bold:
            return .boldSystemFont(ofSize: size)
        }
    }
}

extension UIFont {
    static func appFont(_ font: AppFont, size: CGFloat) -> UIFont {
        return font.size(size)
    }
}
