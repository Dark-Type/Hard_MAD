//
//  ProfileServiceProtocol.swift
//  Hard_MAD
//
//  Created by dark type on 15.05.2025.
//


import UIKit

protocol ProfileServiceProtocol: Sendable {
    func saveUserName(_ name: String) throws
    func loadUserName() -> String?
    func saveUserProfileImage(_ image: UIImage) -> Bool
    func loadUserProfileImage() -> UIImage?
}
