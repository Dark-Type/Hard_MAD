//
//  NavigationDotsDelegate.swift
//  Hard_MAD
//
//  Created by dark type on 03.03.2025.
//

import UIKit

@MainActor
protocol NavigationDotsDelegate: AnyObject {
    func navigationDots(_ view: SectionNavigationDotsView, didSelectSectionAt index: Int)
}
