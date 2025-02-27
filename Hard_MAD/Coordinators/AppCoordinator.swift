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
    
    init(window: UIWindow, container: Container) {
        self.window = window
        let navigationController = UINavigationController()
        super.init(navigationController: navigationController, container: container)
    }
    
    override func start() async {
        let authService: AuthServiceProtocol = await container.resolve()
        
        if await authService.isAuthenticated() {
            await showMainFlow()
        } else {
            await showAuthFlow()
        }
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
    private func showAuthFlow() async {
        let authCoordinator = AuthCoordinator(
            navigationController: navigationController,
            container: container
        )
        
        authCoordinator.onAuthComplete = { [weak self] in
            Task { @MainActor [weak self] in
                await self?.showMainFlow()
            }
        }
        
        self.authCoordinator = authCoordinator
        childCoordinators.append(authCoordinator)
        await authCoordinator.start()
    }
    
    private func showMainFlow() async {
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
        await mainCoordinator.start()
    }
}
