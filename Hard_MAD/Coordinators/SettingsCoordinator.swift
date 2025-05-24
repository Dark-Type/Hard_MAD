//
//  SettingsCoordinator.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//

import UIKit

final class SettingsCoordinator: BaseCoordinator {
    override func start() {
        showSettingsScreen()
    }

    private func showSettingsScreen() {
        let viewModel = makeViewModel()
        let viewController = makeViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
    }
}

extension SettingsCoordinator {
    // MARK: — Factory functions

    func makeViewModel() -> SettingsViewModel {
        SettingsViewModel(authService: container.authService, notificationService: container.notificationService)
    }

    func makeViewController(viewModel: SettingsViewModel) -> SettingsViewController {
        SettingsViewController(viewModel: viewModel)
    }
}
