//
//  AuthCoordinator.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//

import UIKit

@MainActor
final class AuthCoordinator: BaseCoordinator {
    var onAuthComplete: (@MainActor () -> Void)?

    override func start() {
        showLogin()
    }

    private func showLogin() {
        let viewModel = createViewModel()
        let viewController = createViewController(viewModel: viewModel)

        navigationController.setViewControllers([viewController], animated: false)
    }
}

extension AuthCoordinator {
    // MARK: — Factory functions

    func createViewModel() -> AuthViewModel {
        AuthViewModel(authService: container.authService) { [weak self] in
            guard let self = self else { return }
            self.onAuthComplete?()
        }
    }

    func createViewController(viewModel: AuthViewModel) -> UIViewController {
        AuthViewController(viewModel: viewModel, authState: container.authService.authenticationState())
    }
}
