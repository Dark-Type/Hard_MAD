//
//  KeychainServiceProtocol.swift
//  Hard_MAD
//
//  Created by dark type on 15.05.2025.
//

import Foundation

protocol KeychainServiceProtocol: Sendable {
    func save(_ value: Data, for key: String) throws
    func load(for key: String) throws -> Data?
    func delete(for key: String) throws
}
