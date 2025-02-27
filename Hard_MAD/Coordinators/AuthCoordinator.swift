//
//  AuthCoordinator.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//

import UIKit

@MainActor
final class AuthCoordinator: BaseCoordinator {
    var onAuthComplete: (@Sendable () async -> Void)?
    
    override func start() async {
        showLogin()
    }
    
    private func showLogin() {
        Task {
            let authService: AuthServiceProtocol = await container.resolve()
            
            let viewModel = LoginViewModel(authService: authService)
            viewModel.onLoginSuccess = { [weak self] in
                guard let self = self else { return }
                await self.onAuthComplete?()
            }
            
            let loginVC = LoginViewController(viewModel: viewModel)
            navigationController.setViewControllers([loginVC], animated: false)
        }
    }
}
