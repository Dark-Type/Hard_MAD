final class Container {
    private var dependencies: [String: Any] = [:]
    
    // MARK: - Registration
    
    func register<T>(_ type: T.Type, dependency: Any) {
        let key = String(describing: type)
        dependencies[key] = dependency
    }
    
    // MARK: - Resolution
    
    func resolve<T>() -> T {
        let key = String(describing: T.self)
        guard let dependency = dependencies[key] as? T else {
            fatalError("Dependency '\(T.self)' not found. Did you forget to register it?")
        }
        return dependency
    }
    
    // MARK: - Optional Resolution
    
    func optional<T>() -> T? {
        let key = String(describing: T.self)
        return dependencies[key] as? T
    }
}