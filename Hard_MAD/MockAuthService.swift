actor MockAuthService: AuthServiceProtocol {
    private var isLoggedIn = false
    
    func isAuthenticated() async -> Bool {
        // Always return false on app launch for now
        false
    }
    
    func login(email: String, password: String) async throws -> UserProfile {
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // For mock, accept any credentials
        isLoggedIn = true
        return UserProfile.mock
    }
    
    func logout() async throws {
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        isLoggedIn = false
    }
    
    func getCurrentUser() async -> UserProfile? {
        guard isLoggedIn else { return nil }
        return UserProfile.mock
    }
}