//
//  AnalysisViewModelProtocol.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//

import Combine
import UIKit

final class AnalysisViewModel: BaseViewModel {
    // MARK: - Properties

    private let analysisService: AnalysisServiceProtocol
    
    @Published private(set) var weeks: [DateInterval] = []
    @Published private(set) var currentWeekIndex: Int = 0
    @Published private(set) var currentWeekData: AnalysisWeekData?
    
    // MARK: - Initialization

    init(analysisService: AnalysisServiceProtocol) {
        self.analysisService = analysisService
        super.init()
    }
    
    // MARK: - Lifecycle

    override func initialize() async {
        do {
            try await fetchInitialData()
        } catch {
            handleError(error)
        }
    }
    
    // MARK: - Public Methods

    func selectWeek(at index: Int) async {
        guard index >= 0, index < weeks.count else { return }
        
        do {
            try await withLoading { [self] in
                currentWeekIndex = index
                currentWeekData = nil
                
                let weekInterval = weeks[index]
                let midWeekDate = Date(timeInterval: weekInterval.duration / 2, since: weekInterval.start)
                
                currentWeekData = await analysisService.fetchWeeklyData(for: midWeekDate)
            }
        } catch {
            handleError(error)
        }
    }
    
    func fetchInitialData() async throws {
        try await withLoading { [self] in
            weeks = await analysisService.fetchAllWeeks()
            
            if !weeks.isEmpty {
                let today = Date()
                
                let currentWeekIndex = weeks.firstIndex { weekInterval in
                    weekInterval.contains(today)
                } ?? 0
                
                self.currentWeekIndex = currentWeekIndex

                currentWeekData = await analysisService.fetchWeeklyData(
                    for: Date(timeInterval: weeks[currentWeekIndex].duration / 2,
                              since: weeks[currentWeekIndex].start)
                )
            }
        }
    }
    
    // MARK: - Helper Methods

    func getFormattedDateRange(for week: DateInterval) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        formatter.locale = Locale(identifier: "ru_RU")
        
        let startStr = formatter.string(from: week.start)
        let endStr = formatter.string(from: week.end)
        return "\(startStr) - \(endStr)"
    }
}
