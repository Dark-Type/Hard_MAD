//
//  MockAuthService.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//

import Foundation

actor MockAuthService: AuthServiceProtocol {
    private var isLoggedIn = false
    private var touchIDEnabled: Bool = false
    
    private var shouldSucceedLogin: Bool = true
    private var shouldShowError: Bool = false
      
    func configureForUITesting(shouldSucceed: Bool = true, shouldShowError: Bool = false) {
        shouldSucceedLogin = shouldSucceed
        self.shouldShowError = shouldShowError
        isLoggedIn = shouldSucceed
    }
      
    func isAuthenticated() async -> Bool {
        return isLoggedIn
    }
    
    func login() async throws -> UserProfile {
        if CommandLine.arguments.contains("--UITesting") {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
               
            if shouldShowError {
                print("🧪 MockAuthService: Throwing login error for UI testing")
                struct LoginError: Error, LocalizedError {
                    var errorDescription: String? { "Login failed. Please try again." }
                }
                throw LoginError()
            }
               
            if shouldSucceedLogin {
                print("🧪 MockAuthService: Login succeeded for UI testing")
                isLoggedIn = true
                return UserProfile.mock
            } else {
                print("🧪 MockAuthService: Login failed (not successful) for UI testing")
                struct AuthError: Error, LocalizedError {
                    var errorDescription: String? { "Authentication failed" }
                }
                throw AuthError()
            }
        }
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

extension MockAuthService {
    func configureForUITesting() async {
        isLoggedIn = true
    }
}
