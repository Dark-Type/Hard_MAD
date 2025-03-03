//
//  AuthServiceProtocol.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//

protocol AuthServiceProtocol: Sendable {
    func isAuthenticated() async -> Bool
    func login() async throws -> UserProfile
    func logout() async throws
    func getCurrentUser() async -> UserProfile?
    func isTouchIDEnabled() async -> Bool
    func setTouchIDEnabled(_ enabled: Bool) async
}
