//
//  SceneDelegate.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var appCoordinator: AppCoordinator?
    private var uiTestingCoordinator: UITestingCoordinator?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene,
              let appDelegate = UIApplication.shared.delegate as? AppDelegate
        else {
            return
        }

        let window = UIWindow(windowScene: windowScene)
        self.window = window
        if CommandLine.arguments.contains("--UITesting") {
            print("🧪 Starting in UI Testing mode")

            Task {
                let uiTestingCoordinator = UITestingCoordinator(
                    window: window,
                    container: appDelegate.container
                )
                self.uiTestingCoordinator = uiTestingCoordinator
                await uiTestingCoordinator.start()
            }
        } else {
            Task { @MainActor in
                let appCoordinator = AppCoordinator(
                    window: window,
                    container: appDelegate.container
                )
                self.appCoordinator = appCoordinator
                await appCoordinator.start()
            }
        }
    }
}
