//
//  AnalysisCoordinator.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//

import UIKit

@MainActor
final class AnalysisCoordinator: BaseCoordinator {
    override func start() async {
        await showAnalysisScreen()
    }

    private func showAnalysisScreen() async {
        let factory = factoryProvider.getAnalysisViewModelFactory()
        let viewModel = await factory.makeViewModel()
        let viewController = AnalysisViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
    }
}
