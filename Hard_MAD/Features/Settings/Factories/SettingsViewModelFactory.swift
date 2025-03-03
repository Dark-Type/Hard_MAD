//
//  SettingsViewModelFactory.swift
//  Hard_MAD
//
//  Created by dark type on 03.03.2025.
//

final class SettingsViewModelFactory: ViewModelFactory {
    private let container: Container

    init(container: Container) {
        self.container = container
    }

    func makeViewModel() async -> SettingsViewModel {
        let authService: AuthServiceProtocol = await container.resolve()
        let notificationService: NotificationServiceProtocol = await container.resolve()

        return await SettingsViewModel(
            authService: authService,
            notificationService: notificationService
        )
    }
}
