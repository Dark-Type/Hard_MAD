//
//  SettingsCoordinator.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//

import UIKit

@MainActor
final class SettingsCoordinator: BaseCoordinator {
    override func start() async {
        await showSettingsScreen()
    }

    private func showSettingsScreen() async {
        let factory = factoryProvider.getSettingsViewModelFactory()
        let viewModel = await factory.makeViewModel()
        let viewController = SettingsViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
    }
}
