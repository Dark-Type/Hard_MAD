//
//  AnalysisServiceProtocol.swift
//  Hard_MAD
//
//  Created by dark type on 03.03.2025.
//

import Foundation

protocol AnalysisServiceProtocol: Sendable {
    func fetchWeeklyData(for date: Date) async -> AnalysisWeekData
    func fetchAllWeeks() async -> [DateInterval]
}
