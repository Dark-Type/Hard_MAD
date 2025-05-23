//
//  LoginViewModel.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//
import AuthenticationServices

@MainActor
final class AuthViewModel: BaseViewModel {
    private let authService: AuthServiceProtocol
    var onLoginSuccess: () -> Void

    init(authService: AuthServiceProtocol, onLoginSuccess: @escaping () -> Void) {
        self.authService = authService
        self.onLoginSuccess = onLoginSuccess
        super.init()
    }

    func loginWithApple() async {
        let mockCredential = MockAppleIDCredential(
            user: "mock-user-id",
            email: "mockuser@apple.com",
            fullName: {
                var name = PersonNameComponents()
                name.givenName = "Mock"
                name.familyName = "User"
                return name
            }()
        )

        do {
            try await withLoading {
                _ = try await authService.loginWithApple(credential: mockCredential)
            }
            onLoginSuccess()
        } catch {
            handleError(error)
        }
        func loginWithBiometry() async {
            do {
                try await withLoading {
                    try await authService.authenticateWithBiometrics(reason: "Log in")
                }
                onLoginSuccess()
            } catch {
                handleError(error)
            }
        }
    }
}
