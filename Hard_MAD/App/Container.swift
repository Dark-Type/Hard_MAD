//
//  Container.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//

actor Container {
    private var dependencies: [String: Any] = [:]

    func register<T>(_ type: T.Type, dependency: Any) {
        let key = String(describing: type)
        dependencies[key] = dependency
    }

    func resolve<T>() async -> T {
        let key = String(describing: T.self)
        guard let dependency = dependencies[key] as? T else {
            fatalError("No dependency found for \(key)")
        }
        return dependency
    }
}
