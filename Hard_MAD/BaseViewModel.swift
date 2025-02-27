class BaseViewModel {
    // MARK: - Published Properties
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    // MARK: - Callbacks
    var showLoadingIndicator: ((Bool) -> Void)?
    var showError: ((String) -> Void)?
    
    // MARK: - Date Formatting
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()
    
    // MARK: - Initialization
    init() {}
    
    // MARK: - Lifecycle Methods
    func initialize() async {
        // Override in subclasses
    }
    
    func cleanup() {
        // Override in subclasses
    }
    
    // MARK: - Loading State Management
    func withLoading<T>(_ operation: () async throws -> T) async throws -> T {
        do {
            setLoading(true)
            let result = try await operation()
            setLoading(false)
            return result
        } catch {
            setLoading(false)
            throw error
        }
    }
    
    private func setLoading(_ isLoading: Bool) {
        self.isLoading = isLoading
        showLoadingIndicator?(isLoading)
    }
    
    // MARK: - Error Handling
    func handleError(_ error: Error) {
        self.error = error
        showError?(error.localizedDescription)
    }
    
    // MARK: - Date Formatting
    func formatUTCDate(_ date: Date = Date()) -> String {
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: date)
    }
    
    func parseUTCDate(_ dateString: String) -> Date? {
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.date(from: dateString)
    }
    
    // MARK: - Common Validation Methods
    func validateRequired(_ text: String?) -> Bool {
        guard let text = text else { return false }
        return !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func validateEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}