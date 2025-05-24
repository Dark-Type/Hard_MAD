//
//  KeychainService.swift
//  Hard_MAD
//
//  Created by dark type on 15.05.2025.
//

import Foundation
import Security

final class KeychainService: KeychainServiceProtocol {
    func save(_ value: Data, for key: String) throws {
        let query: CFDictionary = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: value
        ] as CFDictionary
        
        SecItemDelete(query)
        let status = SecItemAdd(query, nil)
        guard status == errSecSuccess else {
            throw NSError(domain: "Keychain", code: Int(status))
        }
    }
    
    func load(for key: String) throws -> Data? {
        let query: CFDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ] as CFDictionary
        
        var dataTypeRef: AnyObject?
        let status: OSStatus = SecItemCopyMatching(query, &dataTypeRef)
        
        guard status == errSecSuccess else {
            return nil
        }
        
        return dataTypeRef as? Data
    }
    
    func delete(for key: String) throws {
        let query: CFDictionary = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ] as CFDictionary
        
        SecItemDelete(query)
    }
}
