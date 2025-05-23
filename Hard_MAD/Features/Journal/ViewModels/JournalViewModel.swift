//
//  JournalViewModelProtocol.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//
import UIKit

final class JournalViewModel: BaseViewModel {
    // MARK: - Properties

    private let journalService: JournalServiceProtocol
    @Published private(set) var records: [JournalRecord] = []
    @Published private(set) var statistics: JournalStatistics?
    @Published private(set) var todayEmotions: [Emotion] = []
    
    // MARK: - Initialization

    init(journalService: JournalServiceProtocol) {
        self.journalService = journalService
        super.init()
    }
    
    // MARK: - Lifecycle

    override func initialize() async {
        do {
            try await loadRecords()
            try await loadStatistics()
            try await loadTodayEmotions()
        } catch {
            handleError(error)
        }
    }
    
    // MARK: - Public Methods

    func addNewRecord(_ record: JournalRecord) async {
        do {
            try await withLoading { [self] in
                try await journalService.saveRecord(record)
                
                self.records = [record] + self.records
                try await self.loadStatistics()
                try await self.loadTodayEmotions()
            }
        } catch {
            handleError(error)
        }
    }
    
    // MARK: - Private Methods

    private func loadRecords() async throws {
        try await withLoading { [self] in
            self.records = try await journalService.fetchRecords()
        }
    }
    
    private func loadStatistics() async throws {
        try await withLoading { [self] in
            self.statistics = try await journalService.fetchStatistics()
        }
    }
    
    private func loadTodayEmotions() async throws {
        todayEmotions = try await journalService.fetchTodayEmotions()
    }
    
    func getFormattedDate(for record: JournalRecord) -> String {
        formatUTCDate(record.createdAt)
    }
}
