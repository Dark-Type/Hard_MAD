//
//  LoginViewModel.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//

@MainActor
final class LoginViewModel: BaseViewModel {
    private let authService: AuthServiceProtocol
    var onLoginSuccess: (@Sendable () async -> Void)?
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
        super.init()
    }
    
    func login() async {
        do {
            try await withLoading {
                _ = try await self.authService.login()
            }
            await onLoginSuccess?()
        } catch {
            handleError(error)
        }
    }
}
