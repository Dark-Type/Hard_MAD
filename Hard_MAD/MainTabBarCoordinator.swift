@MainActor
final class MainTabBarCoordinator: BaseCoordinator {
    private var tabBarController: UITabBarController?
    
    override func start() async {
        let tabBarController = UITabBarController()
        
        let homeCoordinator = HomeCoordinator(
            navigationController: UINavigationController(),
            container: container
        )
        
        let profileCoordinator = ProfileCoordinator(
            navigationController: UINavigationController(),
            container: container
        )
        
        let settingsCoordinator = SettingsCoordinator(
            navigationController: UINavigationController(),
            container: container
        )
        
        // Start coordinators
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await homeCoordinator.start() }
            group.addTask { await profileCoordinator.start() }
            group.addTask { await settingsCoordinator.start() }
        }
        
        childCoordinators.append(contentsOf: [
            homeCoordinator,
            profileCoordinator,
            settingsCoordinator
        ])
        
        configureTabBarItems(
            home: homeCoordinator.navigationController,
            profile: profileCoordinator.navigationController,
            settings: settingsCoordinator.navigationController
        )
        
        tabBarController.setViewControllers(
            [
                homeCoordinator.navigationController,
                profileCoordinator.navigationController,
                settingsCoordinator.navigationController
            ],
            animated: false
        )
        
        self.tabBarController = tabBarController
        navigationController.setViewControllers([tabBarController], animated: true)
        navigationController.setNavigationBarHidden(true, animated: false)
    }
    
    private func configureTabBarItems(
        home: UINavigationController,
        profile: UINavigationController,
        settings: UINavigationController
    ) {
        home.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        
        profile.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )
        
        settings.tabBarItem = UITabBarItem(
            title: "Settings",
            image: UIImage(systemName: "gear"),
            selectedImage: UIImage(systemName: "gear")
        )
    }
}