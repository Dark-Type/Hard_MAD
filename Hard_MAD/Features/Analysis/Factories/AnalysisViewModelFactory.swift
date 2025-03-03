//
//  AnalysisViewModelFactory.swift
//  Hard_MAD
//
//  Created by dark type on 03.03.2025.
//

actor AnalysisViewModelFactory: ViewModelFactory {
    private let container: Container

    init(container: Container) {
        self.container = container
    }

    func makeViewModel() async -> AnalysisViewModel {
        let analysisService: AnalysisServiceProtocol = await container.resolve()
        return await AnalysisViewModel(analysisService: analysisService)
    }
}
