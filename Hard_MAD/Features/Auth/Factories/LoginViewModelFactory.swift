//
//  LoginViewModelFactory.swift
//  Hard_MAD
//
//  Created by dark type on 03.03.2025.
//

final class LoginViewModelFactory: ViewModelFactory {
    private let container: Container

    init(container: Container) {
        self.container = container
    }

    func makeViewModel() async -> LoginViewModel {
        let authService: AuthServiceProtocol = await container.resolve()
        return await LoginViewModel(authService: authService)
    }
}
