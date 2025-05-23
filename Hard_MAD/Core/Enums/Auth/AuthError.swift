//
//  AuthError.swift
//  Hard_MAD
//
//  Created by dark type on 15.05.2025.
//

import Foundation

enum AuthError: Error, LocalizedError {
    case appleSignInFailed
    case biometryFailed
    case biometryUnavailable
    case loginMethodNotSupported
    case keychainError
    case unknown

    var errorDescription: String? {
        switch self {
        case .appleSignInFailed:
            return "Apple Sign-In failed."
        case .biometryFailed:
            return "Biometric authentication failed."
        case .biometryUnavailable:
            return "Biometric authentication is unavailable on this device."
        case .loginMethodNotSupported:
            return "Please use Apple Sign In to login."
        case .keychainError:
            return "Keychain operation failed."
        case .unknown:
            return "Unknown authentication error."
        }
    }
}
