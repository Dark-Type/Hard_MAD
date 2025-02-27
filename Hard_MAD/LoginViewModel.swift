final class LoginViewModel {
    private let authService: AuthServiceProtocol
    private let networkService: NetworkServiceProtocol
    
    init(
        authService: AuthServiceProtocol,
        networkService: NetworkServiceProtocol
    ) {
        self.authService = authService
        self.networkService = networkService
    }
    
    func login(email: String, password: String) async throws {
        // Implementation
    }
}