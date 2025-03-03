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
        Task {
            await container.register(AuthServiceProtocol.self, dependency: MockAuthService())
            await container.register(JournalServiceProtocol.self, dependency: MockJournalService())
            await container.register(QuestionServiceProtocol.self, dependency: MockQuestionService())
            await container.register(AnalysisServiceProtocol.self, dependency: MockAnalysisService())
            await container.register(NotificationServiceProtocol.self, dependency: MockNotificationService())
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
}
