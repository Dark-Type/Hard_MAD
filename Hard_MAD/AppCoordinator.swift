final class AppCoordinator {
    private let window: UIWindow
    private let container: Container
    private var childCoordinators: [Coordinator] = []
    
    init(window: UIWindow, container: Container) {
        self.window = window
        self.container = container
    }
    
    func start() {
        // Check authentication state
        let authService: AuthServiceProtocol = container.resolve()
        
        if authService.isAuthenticated {
            showMainFlow()
        } else {
            showAuthFlow()
        }
        
        window.makeKeyAndVisible()
    }
    
    private func showAuthFlow() {
        let authCoordinator = AuthCoordinator(
            container: container,
            navigationController: UINavigationController()
        )
        childCoordinators.append(authCoordinator)
        
        window.rootViewController = authCoordinator.navigationController
        authCoordinator.start()
    }
    
    private func showMainFlow() {
        let mainCoordinator = MainCoordinator(
            container: container,
            navigationController: UINavigationController()
        )
        childCoordinators.append(mainCoordinator)
        
        window.rootViewController = mainCoordinator.navigationController
        mainCoordinator.start()
    }
}