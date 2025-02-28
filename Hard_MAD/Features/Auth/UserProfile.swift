//
//  UserProfile.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//

struct UserProfile: Sendable, Equatable {
    let fullName: String

    static let mock = UserProfile(fullName: "Иван Иванов")
}
