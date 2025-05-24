//
//  AnalysisCoordinator.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//

import UIKit

final class AnalysisCoordinator: BaseCoordinator {
    override func start() {
        showAnalysisScreen()
    }

    private func showAnalysisScreen() {
        let viewModel = makeViewModel()
        let viewController = makeViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
    }
}

extension AnalysisCoordinator {
    // MARK: — Factory functions

    func makeViewModel() -> AnalysisViewModel {
        AnalysisViewModel(analysisService: container.analysisService)
    }

    func makeViewController(viewModel: AnalysisViewModel) -> AnalysisViewController {
        AnalysisViewController(viewModel: viewModel)
    }
}
