@MainActor
final class JournalCoordinator: BaseCoordinator {
    override func start() async {
        showJournalScreen()
    }
    
    private func showJournalScreen() {
        let viewModel = JournalViewModel()
        let viewController = JournalViewController(viewModel: viewModel)
        viewController.onEmotionScreenTapped = { [weak self] in
            self?.showEmotionScreen()
        }
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    private func showEmotionScreen() {
        let viewModel = EmotionViewModel()
        let viewController = EmotionViewController(viewModel: viewModel)
        viewController.onRecordScreenTapped = { [weak self] in
            self?.showRecordScreen()
        }
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func showRecordScreen() {
        let viewModel = RecordViewModel()
        let viewController = RecordViewController(viewModel: viewModel)
        viewController.onJournalScreenTapped = { [weak self] in
            self?.navigationController.popToRootViewController(animated: true)
        }
        navigationController.pushViewController(viewController, animated: true)
    }
}