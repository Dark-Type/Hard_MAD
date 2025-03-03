//
//  UserProfile.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//
import UIKit

struct UserProfile: Sendable, Equatable {
    let fullName: String
    let image: UIImage?

    static let mock = UserProfile(fullName: "Иван Иванов", image: UIImage(named: "defaultProfileImage"))
}
