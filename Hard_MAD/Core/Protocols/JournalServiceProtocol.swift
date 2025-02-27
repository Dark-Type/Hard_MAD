//
//  JournalServiceProtocol.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//


protocol JournalServiceProtocol: Sendable {
    func fetchRecords() async -> [JournalRecord]
    func saveRecord(_ record: JournalRecord) async
}

