//
//  MockAuthService.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//

actor MockAuthService: AuthServiceProtocol {
   
    
    private var isLoggedIn = false
    private var touchIDEnabled: Bool = false
    func isAuthenticated() async -> Bool {
        false
    }
    
    func login() async throws -> UserProfile {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        isLoggedIn = true
        return UserProfile.mock
    }
    
    func logout() async throws {
        try? await Task.sleep(nanoseconds: 500_000_000)
        isLoggedIn = false
    }
    
    func getCurrentUser() async -> UserProfile? {
        guard isLoggedIn else { return nil }
        return UserProfile.mock
    }
    func isTouchIDEnabled() async -> Bool {
        return touchIDEnabled
    }
    
    func setTouchIDEnabled(_ enabled: Bool) async {
        touchIDEnabled = enabled
    }
}
