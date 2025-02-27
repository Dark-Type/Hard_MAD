protocol BaseViewModelProtocol: AnyObject {
    // MARK: - Loading State
    var isLoading: Bool { get set }
    var showLoadingIndicator: ((Bool) -> Void)? { get set }
    
    // MARK: - Error Handling
    var errorMessage: String? { get set }
    var showError: ((String) -> Void)? { get set }
    
    // MARK: - Activity State
    var viewDidLoad: (() -> Void)? { get set }
    var viewWillAppear: (() -> Void)? { get set }
    var viewDidAppear: (() -> Void)? { get set }
    var viewWillDisappear: (() -> Void)? { get set }
    
    // MARK: - Common Date Handling
    var currentDate: Date { get }
    func formatDate(_ date: Date, format: String) -> String
    
    // MARK: - Navigation
    var close: (() -> Void)? { get set }
    var pop: (() -> Void)? { get set }
    
    // MARK: - Lifecycle
    func initialize() async
    func cleanup()
}