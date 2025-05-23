//
//  AppCoordinator.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//
import UIKit

@MainActor
final class AppCoordinator: BaseCoordinator {
    private let window: UIWindow
    private var authCoordinator: AuthCoordinator?
    private var mainCoordinator: MainTabBarCoordinator?
    
    // MARK: — Initializer
    
    init(window: UIWindow, container: Container) {
        self.window = window
        let navigationController = UINavigationController()
        super.init(navigationController: navigationController, container: container)
    }
    
    override func start() {
        let state = container.authService.authenticationState()
        if state == .loggedIn {
            showMainFlow()
        }
        else {
            showAuthFlow()
        }
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

    // MARK: — Flow control
    
    private func showAuthFlow() {
        let authCoordinator = AuthCoordinator(
            navigationController: navigationController,
            container: container
        )
        
        authCoordinator.onAuthComplete = { @MainActor [weak self] in
            self?.showMainFlow()
        }
        self.authCoordinator = authCoordinator
        childCoordinators.append(authCoordinator)
        authCoordinator.start()
    }
    
    private func showMainFlow() {
        if let authCoordinator = authCoordinator {
            childCoordinators.removeAll { $0 === authCoordinator }
            self.authCoordinator = nil
        }
        
        let mainCoordinator = MainTabBarCoordinator(
            navigationController: navigationController,
            container: container
        )
        self.mainCoordinator = mainCoordinator
        childCoordinators.append(mainCoordinator)
        mainCoordinator.start()
    }
}
