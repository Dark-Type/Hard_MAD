@MainActor
final class AnalysisCoordinator: BaseCoordinator {
    override func start() async {
        showAnalysisScreen()
    }
    
    private func showAnalysisScreen() {
        let viewModel = AnalysisViewModel()
        let viewController = AnalysisViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
    }
}