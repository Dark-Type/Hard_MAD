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
    
    // MARK: - Initialization

    init(container: Container) {
        self.container = container
        super.init()
    }
    
    // MARK: - Lifecycle

    override func initialize() async {
        do {
            try await loadRecords()
        } catch {
            handleError(error)
        }
    }
    
    // MARK: - Public Methods

    func addNewRecord(_ record: JournalRecord) async {
        do {
            try await withLoading { [self] in
                let mockService: JournalServiceProtocol = await container.resolve()
                await mockService.saveRecord(record)

                self.records.append(record)
            }
        } catch {
            handleError(error)
        }
    }
    
    // MARK: - Private Methods

    private func loadRecords() async throws {
        try await withLoading { [self] in
            let mockService: JournalServiceProtocol = await container.resolve()
            self.records = await mockService.fetchRecords()
        }
    }
    
    func getFormattedDate(for record: JournalRecord) -> String {
        formatUTCDate(record.createdAt)
    }
}
