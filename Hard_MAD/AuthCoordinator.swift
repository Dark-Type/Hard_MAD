final class AuthCoordinator: Coordinator {
    let navigationController: UINavigationController
    private let container: Container
    
    init(container: Container, navigationController: UINavigationController) {
        self.container = container
        self.navigationController = navigationController
    }
    
    func start() {
        showLogin()
    }
    
    private func showLogin() {
        let authService: AuthServiceProtocol = container.resolve()
        let networkService: NetworkServiceProtocol = container.resolve()
        
        let viewModel = LoginViewModel(
            authService: authService,
            networkService: networkService
        )
        
        let loginVC = LoginViewController(viewModel: viewModel)
        navigationController.setViewControllers([loginVC], animated: false)
    }
}