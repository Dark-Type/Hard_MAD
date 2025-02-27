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
        navigationController.setViewControllers([tabBarController], animated: true)
        navigationController.setNavigationBarHidden(true, animated: false)
    }
    
    private func configureTabBarItems(
        journal: UINavigationController,
        analysis: UINavigationController,
        settings: UINavigationController
    ) {
        journal.tabBarItem = UITabBarItem(
            title: "Journal",
            image: UIImage(systemName: "book"),
            selectedImage: UIImage(systemName: "book.fill")
        )
        
        analysis.tabBarItem = UITabBarItem(
            title: "Analysis",
            image: UIImage(systemName: "chart.bar"),
            selectedImage: UIImage(systemName: "chart.bar.fill")
        )
        
        settings.tabBarItem = UITabBarItem(
            title: "Settings",
            image: UIImage(systemName: "gear"),
            selectedImage: UIImage(systemName: "gear")
        )
    }
}
