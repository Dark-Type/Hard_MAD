//
//  JournalViewModelProtocol.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//
import UIKit

final class JournalViewModel: BaseViewModel {
    // MARK: - Properties

    private let container: Container
    @Published private(set) var records: [JournalRecord] = []
    @Published private(set) var statistics: JournalStatistics?
    @Published private(set) var todayEmotions: [Emotion] = []
    
    // MARK: - Initialization

    init(container: Container) {
        self.container = container
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
                let service: JournalServiceProtocol = await container.resolve()
                await service.saveRecord(record)
                
                self.records.append(record)
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
            let service: JournalServiceProtocol = await container.resolve()
            self.records = await service.fetchRecords()
        }
    }
    
    private func loadStatistics() async throws {
        try await withLoading { [self] in
            let service: JournalServiceProtocol = await container.resolve()
            self.statistics = await service.fetchStatistics()
        }
    }
    
    private func loadTodayEmotions() async throws {
        let service: JournalServiceProtocol = await container.resolve()
        todayEmotions = await service.fetchTodayEmotions()
    }
    
    func getFormattedDate(for record: JournalRecord) -> String {
        formatUTCDate(record.createdAt)
    }
}
