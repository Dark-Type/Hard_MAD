//
//  ProfileService.swift
//  Hard_MAD
//
//  Created by dark type on 15.05.2025.
//

import UIKit

final class ProfileService: ProfileServiceProtocol {
    private let kUserName = "userName"
    private let kProfileImageFilename = "profileImage.png"
    private let keychain: KeychainServiceProtocol

    init(keychain: KeychainServiceProtocol) {
        self.keychain = keychain
    }

    func saveUserName(_ name: String) throws {
        try keychain.save(Data(name.utf8), for: kUserName)
    }

    func loadUserName() -> String? {
        guard let nameData = try? keychain.load(for: kUserName) else { return nil }
        return String(data: nameData, encoding: .utf8)
    }

    func saveUserProfileImage(_ image: UIImage) -> Bool {
        guard let data = image.pngData() else { return false }
        let url = getProfileImageURL()
        let directory = url.deletingLastPathComponent()
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
            try data.write(to: url, options: [.atomic])
            return true
        } catch {
            print("Failed to save image: \(error)")
            return false
        }
    }

    func loadUserProfileImage() -> UIImage? {
        let url = getProfileImageURL()
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        return UIImage(contentsOfFile: url.path)
    }

    private func getProfileImageURL() -> URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent(kProfileImageFilename)
    }
}
