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
        await showLogin()
    }

    private func showLogin() async {
        let factory = factoryProvider.getLoginViewModelFactory()
        let viewModel = await factory.makeViewModel()
        viewModel.onLoginSuccess = { [weak self] in
            guard let self = self else { return }
            await self.onAuthComplete?()
        }

        let loginVC = LoginViewController(viewModel: viewModel)
        navigationController.setViewControllers([loginVC], animated: false)
    }
}
