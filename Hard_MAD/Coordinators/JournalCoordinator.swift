//
//  JournalCoordinator.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//

import UIKit

final class JournalCoordinator: BaseCoordinator {
    override func start() async {
        await showJournalScreen()
    }
    
    private func showJournalScreen() async {
        let factory = factoryProvider.getJournalViewModelFactory()
        let viewModel = await factory.makeViewModel()
        let viewController = JournalViewController(viewModel: viewModel)
        viewController.onNewEntryTapped = { [weak self] in
            await self?.startNewRecord()
        }
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    private func startNewRecord() async {
        let recordBuilder = RecordBuilder()
        await showEmotionScreen(recordBuilder: recordBuilder)
    }
    
    private func showEmotionScreen(recordBuilder: RecordBuilder) async {
        let viewController = EmotionViewController(recordBuilder: recordBuilder)
        viewController.onEmotionSelected = { [weak self] in
            guard let self = self else { return }
            await self.showRecordScreen(recordBuilder: recordBuilder)
        }
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func showRecordScreen(recordBuilder: RecordBuilder) async {
        let factory = factoryProvider.getRecordViewModelFactory()
        let viewModel = await factory.makeViewModel(recordBuilder: recordBuilder)
        let viewController = RecordViewController(viewModel: viewModel)
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
