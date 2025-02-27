//
//  MockJournalService.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//

actor MockJournalService: JournalServiceProtocol {
    private var records: [JournalRecord] = []

    func fetchRecords() async -> [JournalRecord] {
        records
    }

    func saveRecord(_ record: JournalRecord) async {
        records.append(record)
    }
}
