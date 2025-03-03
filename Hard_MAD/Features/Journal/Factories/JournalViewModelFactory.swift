//
//  JournalViewModelFactory.swift
//  Hard_MAD
//
//  Created by dark type on 03.03.2025.
//

final class JournalViewModelFactory: ViewModelFactory {
    private let container: Container

    init(container: Container) {
        self.container = container
    }

    func makeViewModel() async -> JournalViewModel {
        let journalService: JournalServiceProtocol = await container.resolve()
        return await JournalViewModel(journalService: journalService)
    }
}
