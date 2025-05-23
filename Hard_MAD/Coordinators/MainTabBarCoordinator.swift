//
//  MainTabBarCoordinator.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//

import UIKit

import UIKit

final class MainTabBarCoordinator: BaseCoordinator {
    // MARK: - Properties

    private var tabBarController: UITabBarController?
    private var journalCoordinator: JournalCoordinator!
    private var analysisCoordinator: AnalysisCoordinator!
    private var settingsCoordinator: SettingsCoordinator!

    // MARK: - Lifecycle

    override func start() {
        let tabBarController = UITabBarController()
        self.tabBarController = tabBarController

        journalCoordinator = JournalCoordinator(
            navigationController: UINavigationController(),
            container: container
        )
        analysisCoordinator = AnalysisCoordinator(
            navigationController: UINavigationController(),
            container: container
        )
        settingsCoordinator = SettingsCoordinator(
            navigationController: UINavigationController(),
            container: container
        )

        [journalCoordinator, analysisCoordinator, settingsCoordinator].forEach { $0.start() }

        childCoordinators = [journalCoordinator, analysisCoordinator, settingsCoordinator]

        configureTabBarItems()

        tabBarController.setViewControllers(
            [
                journalCoordinator.navigationController,
                analysisCoordinator.navigationController,
                settingsCoordinator.navigationController
            ],
            animated: false
        )

        styleTabBar(tabBarController.tabBar)

        navigationController.setViewControllers([tabBarController], animated: true)
        navigationController.setNavigationBarHidden(true, animated: false)
    }

    // MARK: - Tab Bar Configuration

    private func configureTabBarItems() {
        journalCoordinator.navigationController.tabBarItem = UITabBarItem(
            title: L10n.TabBar.journal,
            image: UIImage(named: "journalTabBar"),
            selectedImage: UIImage(named: "journalTabBar")
        )

        analysisCoordinator.navigationController.tabBarItem = UITabBarItem(
            title: L10n.TabBar.analysis,
            image: UIImage(named: "statsTabBar"),
            selectedImage: UIImage(named: "statsTabBar")
        )

        settingsCoordinator.navigationController.tabBarItem = UITabBarItem(
            title: L10n.TabBar.settings,
            image: UIImage(named: "settingsTabBar"),
            selectedImage: UIImage(named: "settingsTabBar")
        )
    }

    private func styleTabBar(_ tabBar: UITabBar) {
        tabBar.tintColor = .white
        tabBar.unselectedItemTintColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
        tabBar.backgroundColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
    }
}
