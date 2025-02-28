//
//  MainTabBarCoordinator.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//

import UIKit

@MainActor
final class MainTabBarCoordinator: BaseCoordinator {
    private var tabBarController: UITabBarController?
    
    override func start() async {
        let tabBarController = UITabBarController()
        
        let journalCoordinator = JournalCoordinator(
            navigationController: UINavigationController(),
            container: container
        )
        
        let analysisCoordinator = AnalysisCoordinator(
            navigationController: UINavigationController(),
            container: container
        )
        
        let settingsCoordinator = SettingsCoordinator(
            navigationController: UINavigationController(),
            container: container
        )
        
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await journalCoordinator.start() }
            group.addTask { await analysisCoordinator.start() }
            group.addTask { await settingsCoordinator.start() }
        }
        
        childCoordinators = [
            journalCoordinator,
            analysisCoordinator,
            settingsCoordinator
        ]
        
        configureTabBarItems(
            journal: journalCoordinator.navigationController,
            analysis: analysisCoordinator.navigationController,
            settings: settingsCoordinator.navigationController
        )
        
        tabBarController.setViewControllers(
            [
                journalCoordinator.navigationController,
                analysisCoordinator.navigationController,
                settingsCoordinator.navigationController
            ],
            animated: false
        )
        
        self.tabBarController = tabBarController
        
        let tabBar = tabBarController.tabBar
        tabBar.tintColor = .white
        tabBar.unselectedItemTintColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
        tabBar.frame.size.height = 49
        tabBar.backgroundColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
        
        navigationController.setViewControllers([tabBarController], animated: true)
        navigationController.setNavigationBarHidden(true, animated: false)
    }
    
    private func configureTabBarItems(
        journal: UINavigationController,
        analysis: UINavigationController,
        settings: UINavigationController
    ) {
        journal.tabBarItem = UITabBarItem(
            title: L10n.TabBar.journal,
            image: UIImage(named: "journalTabBar"),
            selectedImage: UIImage(named: "journalTabBar")
        )
        
        analysis.tabBarItem = UITabBarItem(
            title: L10n.TabBar.analysis,
            image: UIImage(named: "statsTabBar"),
            selectedImage: UIImage(named: "statsTabBar")
        )
        
        settings.tabBarItem = UITabBarItem(
            title: L10n.TabBar.settings,
            image: UIImage(named: "settingsTabBar"),
            selectedImage: UIImage(named: "settingsTabBar")
        )
    }
}
