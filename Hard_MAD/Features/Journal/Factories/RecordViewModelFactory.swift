//
//  RecordViewModelFactory.swift
//  Hard_MAD
//
//  Created by dark type on 03.03.2025.
//

final class RecordViewModelFactory: ViewModelFactory {
    private let container: Container

    init(container: Container) {
        self.container = container
    }

    func makeViewModel(recordBuilder: RecordBuilder) async -> RecordViewModel {
        let questionService: QuestionServiceProtocol = await container.resolve()
        return await RecordViewModel(
            recordBuilder: recordBuilder,
            questionService: questionService
        )
    }
}
