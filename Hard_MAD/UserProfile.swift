struct UserProfile: Sendable, Equatable {
    let fullName: String
    
    static let mock = UserProfile(fullName: "John Doe")
}