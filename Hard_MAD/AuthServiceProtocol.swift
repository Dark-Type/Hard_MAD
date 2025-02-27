protocol AuthServiceProtocol: Sendable {
    func isAuthenticated() async -> Bool
    func login(email: String, password: String) async throws -> UserProfile
    func logout() async throws
    func getCurrentUser() async -> UserProfile?
}