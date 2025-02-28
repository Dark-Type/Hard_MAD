//
//  FontUtils.swift
//  Hard_MAD
//
//  Created by dark type on 28.02.2025.
//

import UIKit

enum FontUtils {
    static func printAvailableFonts() {
        for family in UIFont.familyNames.sorted() {
            print("Family: \(family)")
            for name in UIFont.fontNames(forFamilyName: family) {
                print("   Font: \(name)")
            }
        }
    }
}
