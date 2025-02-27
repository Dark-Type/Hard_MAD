protocol JournalServiceProtocol: Sendable {
    func fetchRecords() async -> [JournalRecord]
    func saveRecord(_ record: JournalRecord) async
}

actor MockJournalService: JournalServiceProtocol {
    private var records: [JournalRecord] = []
    
    func fetchRecords() async -> [JournalRecord] {
        records
    }
    
    func saveRecord(_ record: JournalRecord) async {
        records.append(record)
    }
}