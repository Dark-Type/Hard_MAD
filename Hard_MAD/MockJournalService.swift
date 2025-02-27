actor MockJournalService: JournalServiceProtocol {
    private var records: [JournalRecord] = []
    
    func fetchRecords() async -> [JournalRecord] {
        records
    }
    
    func saveRecord(_ record: JournalRecord) async {
        records.append(record)
    }
}
