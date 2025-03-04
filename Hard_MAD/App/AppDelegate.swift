//
//  AppDelegate.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    let container = Container()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        if !CommandLine.arguments.contains("--UITesting") {
            Task {
                await configureForNormalUse()
            }
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }

    private func configureForNormalUse() async {
        await container.register(AuthServiceProtocol.self, dependency: MockAuthService())
        await container.register(NotificationServiceProtocol.self, dependency: MockNotificationService())

        let factoryProvider = FactoryProvider(container: container)
        await container.register(FactoryProvider.self, dependency: factoryProvider)
    }
}
