
import UIKit

final class JournalCoordinator: BaseCoordinator {
    // MARK: - Properties
    
    private weak var journalViewController: JournalViewController?
    private var currentRecordBuilder: RecordBuilder?
    
    // MARK: - Public Methods
    
    override func start() {
        showJournalScreen()
    }
    
    func startEmotionFlow() async {
        let recordBuilder = RecordBuilder()
        currentRecordBuilder = recordBuilder
        await showEmotionScreen(recordBuilder: recordBuilder)
    }
    
    func handleExternalEmotionRequest() async {
        if hasActiveRecordingFlow {
            cancelRecordingFlow()
        }
        
        await startEmotionFlow()
    }
    
    // MARK: - Private Methods

    private func showJournalScreen() {
        let viewModel = makeJournalViewModel()
        let viewController = makeJournalViewController(viewModel: viewModel)
        
        journalViewController = viewController
        
        navigationController.setViewControllers([viewController], animated: false)
    }

    @MainActor
    private func handleNewEntryRequested() async {
        await startEmotionFlow()
    }

    private func showEmotionScreen(recordBuilder: RecordBuilder) async {
        let viewController = EmotionViewController(recordBuilder: recordBuilder)
        viewController.onEmotionSelected = { [weak self] in
            guard let self = self else { return }
            await self.handleEmotionSelected(recordBuilder: recordBuilder)
        }
        
        navigationController.pushViewController(viewController, animated: true)
    }

    private func handleEmotionSelected(recordBuilder: RecordBuilder) async {
        await showRecordScreen(recordBuilder: recordBuilder)
    }

    private func showRecordScreen(recordBuilder: RecordBuilder) async {
        let viewModel = makeRecordViewModel(recordBuilder: recordBuilder)
        let viewController = makeRecordViewController(viewModel: viewModel)
        viewController.onRecordComplete = { [weak self] record in
            guard let self = self else { return }
            await self.handleRecordCompletion(record)
        }
        navigationController.pushViewController(viewController, animated: true)
    }

    private func handleRecordCompletion(_ record: JournalRecord) async {
        currentRecordBuilder = nil
        
        await updateJournalWithNewRecord(record)
        
        navigationController.popToRootViewController(animated: true)
    }
    
    private func updateJournalWithNewRecord(_ record: JournalRecord) async {
        guard let journalVC = journalViewController else { return }
        await journalVC.viewModel.addNewRecord(record)
    }
    
    // MARK: - Flow Control
    
    var hasActiveRecordingFlow: Bool {
        return currentRecordBuilder != nil
    }
    
    func cancelRecordingFlow() {
        currentRecordBuilder = nil
        navigationController.popToRootViewController(animated: true)
    }
    
    func returnToJournal() {
        currentRecordBuilder = nil
        navigationController.popToRootViewController(animated: true)
    }
}

// MARK: - Factory Methods

extension JournalCoordinator {
    func makeJournalViewModel() -> JournalViewModel {
        JournalViewModel(journalService: container.journalService)
    }

    func makeJournalViewController(viewModel: JournalViewModel) -> JournalViewController {
        let viewController = JournalViewController(viewModel: viewModel)
        
        viewController.onNewEntryTapped = { [weak self] in
            guard let self = self else { return }
            await self.handleNewEntryRequested()
        }
        
        return viewController
    }

    func makeRecordViewModel(recordBuilder: RecordBuilder) -> RecordViewModel {
        RecordViewModel(recordBuilder: recordBuilder, questionService: container.questionService)
    }

    func makeRecordViewController(viewModel: RecordViewModel) -> RecordViewController {
        RecordViewController(viewModel: viewModel)
    }
}
