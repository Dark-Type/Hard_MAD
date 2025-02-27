//
//  Coordinator.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//


import UIKit

@MainActor
protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get }
    var container: Container { get }
    
    func start() async
}


