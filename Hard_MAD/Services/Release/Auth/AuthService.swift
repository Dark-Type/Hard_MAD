//
//  AuthService.swift
//  Hard_MAD
//
//  Created by dark type on 15.05.2025.
//

import AuthenticationServices
import UIKit

final class AuthService: AuthServiceProtocol {
    private let profileService: ProfileServiceProtocol
    private let biometryService: BiometryServiceProtocol

    private let kLoggedIn = "isLoggedIn"
    private var isLoggedIn: Bool {
        get { UserDefaults.standard.bool(forKey: kLoggedIn) }
        set { UserDefaults.standard.set(newValue, forKey: kLoggedIn) }
    }

    init(
        profileService: ProfileServiceProtocol = ProfileService(keychain: KeychainService()),
        biometryService: BiometryServiceProtocol = BiometryService()
    ) {
        self.profileService = profileService
        self.biometryService = biometryService
    }

    func authenticationState() -> AuthState {
        switch (isLoggedIn, biometryService.isBiometryEnabled()) {
        case (false, _): return .notLoggedIn
        case (true, false): return .loggedIn
        case (true, true): return .needsBiometry
        }
    }

    func isAuthenticated() async -> Bool {
        return isLoggedIn
    }

    func loginWithApple(credential: AppleIDCredentialRepresentable) async throws -> UserProfile {
        let fullName = credential.fullName?.formatted() ?? "User"
        try profileService.saveUserName(fullName)
        isLoggedIn = true
        return UserProfile(fullName: fullName, image: profileService.loadUserProfileImage() ?? UIImage(named: "defaultProfileImage"))
    }

    func authenticateWithBiometrics(reason: String = "Unlock with biometrics") async throws {
        try await biometryService.authenticate(reason: reason)
    }

    func logout() throws {
        isLoggedIn = false
        biometryService.setBiometryEnabled(false)
        try? profileService.saveUserName("")
    }

    func getCurrentUser() -> UserProfile? {
        guard isLoggedIn,
              let fullName = profileService.loadUserName()
        else {
            return nil
        }
        return UserProfile(fullName: fullName, image: profileService.loadUserProfileImage() ?? UIImage(named: "defaultProfileImage"))
    }

    func isTouchIDEnabled() -> Bool {
        biometryService.isBiometryEnabled()
    }

    func setTouchIDEnabled(_ enabled: Bool) {
        print("AUTHSERVICE: setTouchIDEnabled \(enabled)")
        biometryService.setBiometryEnabled(enabled)
    }

    func saveUserProfileImage(_ image: UIImage) -> Bool {
        profileService.saveUserProfileImage(image)
    }

    func loadUserProfileImage() -> UIImage? {
        profileService.loadUserProfileImage()
    }
}
import AuthenticationServices

protocol AppleIDCredentialRepresentable {
    var user: String { get }
    var email: String? { get }
    var fullName: PersonNameComponents? { get }
}

extension ASAuthorizationAppleIDCredential: AppleIDCredentialRepresentable {}

struct MockAppleIDCredential: AppleIDCredentialRepresentable {
    var user: String
    var email: String?
    var fullName: PersonNameComponents?
}
