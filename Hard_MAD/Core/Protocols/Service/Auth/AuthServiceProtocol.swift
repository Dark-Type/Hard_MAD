//
//  AuthServiceProtocol.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//
import AuthenticationServices
import UIKit

protocol AuthServiceProtocol: AnyObject, Sendable {
    func authenticationState() -> AuthState
    func isAuthenticated() async -> Bool
    func isTouchIDEnabled() -> Bool
    func setTouchIDEnabled(_ enabled: Bool)

    func loginWithApple(credential: AppleIDCredentialRepresentable) async throws -> UserProfile
    func authenticateWithBiometrics(reason: String) async throws

    func logout() throws

    func getCurrentUser() -> UserProfile?
    func saveUserProfileImage(_ image: UIImage) -> Bool
    func loadUserProfileImage() -> UIImage?
}
