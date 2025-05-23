//
//  JournalCoordinator.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//

import UIKit

final class JournalCoordinator: BaseCoordinator {
    override func start() {
        showJournalScreen()
    }

    private func showJournalScreen() {
        let viewModel = makeJournalViewModel()
        let viewController = makeJournalViewController(viewModel: viewModel)
        viewController.onNewEntryTapped = { [weak self] in
            await self?.startNewRecord()
        }
        navigationController.setViewControllers([viewController], animated: false)
    }

    private func startNewRecord() {
        let recordBuilder = RecordBuilder()
        showEmotionScreen(recordBuilder: recordBuilder)
    }

    private func showEmotionScreen(recordBuilder: RecordBuilder) {
        let viewController = EmotionViewController(recordBuilder: recordBuilder)
        viewController.onEmotionSelected = { [weak self] in
            guard let self = self else { return }
            await self.showRecordScreen(recordBuilder: recordBuilder)
        }
        navigationController.pushViewController(viewController, animated: true)
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
        guard let journalVC = navigationController.viewControllers.first as? JournalViewController else {
            return
        }

        await journalVC.viewModel.addNewRecord(record)
        navigationController.popToRootViewController(animated: true)
    }
}

extension JournalCoordinator {
    // MARK: — Factory functions

    func makeJournalViewModel() -> JournalViewModel {
        JournalViewModel(journalService: container.journalService)
    }

    func makeJournalViewController(viewModel: JournalViewModel) -> JournalViewController {
        JournalViewController(viewModel: viewModel)
    }

    func makeRecordViewModel(recordBuilder: RecordBuilder) -> RecordViewModel {
        RecordViewModel(recordBuilder: recordBuilder, questionService: container.questionService)
    }

    func makeRecordViewController(viewModel: RecordViewModel) -> RecordViewController {
        RecordViewController(viewModel: viewModel)
    }
}
