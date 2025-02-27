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
