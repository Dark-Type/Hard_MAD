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
        showSettingsScreen()
    }

    private func showSettingsScreen() {
        let viewModel = SettingsViewModel()
        let viewController = SettingsViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
    }
}
