//
//  BiometryService.swift
//  Hard_MAD
//
//  Created by dark type on 15.05.2025.
//

import LocalAuthentication

final class BiometryService: BiometryServiceProtocol {
    private let kBiometryEnabled = "isBiometryEnabled"

    private var isEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: kBiometryEnabled) }
        set { UserDefaults.standard.set(newValue, forKey: kBiometryEnabled) }
    }

    func isBiometryEnabled() -> Bool {
        isEnabled
    }

    func setBiometryEnabled(_ enabled: Bool) {
        print("BIOMETRY ENABLED: \(enabled)")
        isEnabled = enabled
    }

    func authenticate(reason: String = "Unlock with biometrics") async throws {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            throw AuthError.biometryUnavailable
        }

        try await withCheckedThrowingContinuation { continuation in
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, _ in
                if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: AuthError.biometryFailed)
                }
            }
        }
    }
}
