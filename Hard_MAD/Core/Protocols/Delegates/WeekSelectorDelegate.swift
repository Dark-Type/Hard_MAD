//
//  WeekSelectorDelegate.swift
//  Hard_MAD
//
//  Created by dark type on 03.03.2025.
//

@MainActor
protocol WeekSelectorDelegate: AnyObject {
    func weekSelector(_ selector: WeekSelectorView, didSelectWeekAt index: Int)
}
