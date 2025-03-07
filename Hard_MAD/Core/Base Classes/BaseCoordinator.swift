//
//  BaseCoordinator.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//

import UIKit

@MainActor
class BaseCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    let navigationController: UINavigationController
    let factoryProvider: FactoryProvider
    let container: Container
    
    init(navigationController: UINavigationController, container: Container) {
        self.navigationController = navigationController
        self.container = container
        self.factoryProvider = FactoryProvider(container: container)
    }
    
    func start() async {
        fatalError("Start method should be implemented by child coordinator")
    }
    
    func addChild(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }
    
    func removeChild(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
}
