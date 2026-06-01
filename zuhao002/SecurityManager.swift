//
//  SecurityManager.swift
//  zuhao002
//
//  Created by andy 正道 on 2026/5/20.
//

import Foundation
import CommonCrypto

class SecurityManager: ObservableObject {
    static let shared = SecurityManager()
    
    @Published var isUnlocked: Bool = true
    @Published var isPasswordEnabled: Bool = false
    
    private let passwordKey = "app_lock_password_hash"
    private let enabledKey = "app_lock_enabled_flag"
    
    init() {
        self.isPasswordEnabled = UserDefaults.standard.bool(forKey: enabledKey)
        // If password lock is enabled, start as standard locked.
        if isPasswordEnabled {
            self.isUnlocked = false
        } else {
            self.isUnlocked = true
        }
    }
    
    func checkAppLockState() {
        if isPasswordEnabled {
            if isUnlocked { isUnlocked = false }
        } else {
            if !isUnlocked { isUnlocked = true }
        }
    }
    
    // Hash function using SHA256
    private func sha256(_ string: String) -> String {
        guard let data = string.data(using: .utf8) else { return "" }
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return hash.map { String(format: "%02hhx", $0) }.joined()
    }
    
    func setPassword(_ passcode: String) -> Bool {
        guard passcode.count >= 4 else { return false }
        let hashed = sha256(passcode)
        UserDefaults.standard.set(hashed, forKey: passwordKey)
        UserDefaults.standard.set(true, forKey: enabledKey)
        self.isPasswordEnabled = true
        self.isUnlocked = true
        return true
    }
    
    func disablePassword() {
        UserDefaults.standard.removeObject(forKey: passwordKey)
        UserDefaults.standard.set(false, forKey: enabledKey)
        self.isPasswordEnabled = false
        self.isUnlocked = true
    }
    
    func verifyPassword(_ passcode: String) -> Bool {
        let hashedInput = sha256(passcode)
        if let storedHash = UserDefaults.standard.string(forKey: passwordKey) {
            let matches = (storedHash == hashedInput)
            if matches {
                self.isUnlocked = true
            }
            return matches
        }
        return false
    }

    // MARK: - Pattern (gesture) convenience wrappers
    func setPattern(_ pattern: [Int]) -> Bool {
        let str = pattern.map { String($0) }.joined(separator: ",")
        return setPassword(str)
    }

    func verifyPattern(_ pattern: [Int]) -> Bool {
        let str = pattern.map { String($0) }.joined(separator: ",")
        return verifyPassword(str)
    }
}
