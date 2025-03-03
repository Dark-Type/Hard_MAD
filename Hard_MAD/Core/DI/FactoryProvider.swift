//
//  FactoryProvider.swift
//  Hard_MAD
//
//  Created by dark type on 03.03.2025.
//

final class FactoryProvider {
    private let container: Container
    
    private lazy var settingsViewModelFactory = SettingsViewModelFactory(container: container)
    private lazy var loginViewModelFactory = LoginViewModelFactory(container: container)
    private lazy var journalViewModelFactory = JournalViewModelFactory(container: container)
    private lazy var recordViewModelFactory = RecordViewModelFactory(container: container)
    private lazy var analysisViewModelFactory = AnalysisViewModelFactory(container: container)
    
    init(container: Container) {
        self.container = container
    }
    
    func getSettingsViewModelFactory() -> SettingsViewModelFactory {
        return settingsViewModelFactory
    }
    
    func getLoginViewModelFactory() -> LoginViewModelFactory {
        return loginViewModelFactory
    }
    
    func getJournalViewModelFactory() -> JournalViewModelFactory {
        return journalViewModelFactory
    }
    
    func getRecordViewModelFactory() -> RecordViewModelFactory {
        return recordViewModelFactory
    }
    
    func getAnalysisViewModelFactory() -> AnalysisViewModelFactory {
        return analysisViewModelFactory
    }
}
