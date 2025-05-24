//
//  BiometryServiceProtocol.swift
//  Hard_MAD
//
//  Created by dark type on 15.05.2025.
//

protocol BiometryServiceProtocol: Sendable {
    func isBiometryEnabled() -> Bool
    func setBiometryEnabled(_ enabled: Bool)
    func authenticate(reason: String) async throws
}
