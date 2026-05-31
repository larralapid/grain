import Foundation
import Security

/// Minimal Keychain wrapper for storing the optional, user-supplied Anthropic API key.
/// The key never lives in the app bundle, in UserDefaults, or in the repo.
enum KeychainStore {
    private static let service = "com.grain.ai"

    /// Stores (or, for an empty value, deletes) the secret. Returns `true` on success so callers
    /// can tell the user if the key didn't persist, instead of failing silently.
    @discardableResult
    static func set(_ value: String?, for account: String) -> Bool {
        guard let value, !value.isEmpty else {
            return delete(account)
        }
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        // `AfterFirstUnlock` keeps the key readable for background work after the first unlock
        // post-boot, while still protecting it before the device is ever unlocked.
        if SecItemCopyMatching(query as CFDictionary, nil) == errSecSuccess {
            let attributes: [String: Any] = [
                kSecValueData as String: data,
                kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
            ]
            return SecItemUpdate(query as CFDictionary, attributes as CFDictionary) == errSecSuccess
        } else {
            var insert = query
            insert[kSecValueData as String] = data
            insert[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
            return SecItemAdd(insert as CFDictionary, nil) == errSecSuccess
        }
    }

    static func get(_ account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        return value
    }

    @discardableResult
    static func delete(_ account: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        let status = SecItemDelete(query as CFDictionary)
        // Deleting a key that was never stored is still "no key present" — treat as success.
        return status == errSecSuccess || status == errSecItemNotFound
    }
}

/// Read access to the AI-extraction settings for non-View code (e.g. the coordinator).
/// Toggles are persisted via `@AppStorage` in Settings under these same keys; the key
/// lives in the Keychain.
enum AIConfig {
    private static let apiKeyAccount = "anthropic_api_key"

    /// Master switch: use AI extraction at all (vs. the regex fallback). Defaults on.
    static var aiEnabled: Bool {
        UserDefaults.standard.object(forKey: "ai.enabled") as? Bool ?? true
    }

    /// Opt-in: use the user's own Claude API key for the enhanced tier.
    static var claudeEnabled: Bool {
        UserDefaults.standard.bool(forKey: "ai.claude.enabled")
    }

    static var claudeModel: String {
        UserDefaults.standard.string(forKey: "ai.claude.model") ?? "claude-sonnet-4-6"
    }

    static var claudeAPIKey: String? { KeychainStore.get(apiKeyAccount) }

    @discardableResult
    static func setClaudeAPIKey(_ value: String?) -> Bool { KeychainStore.set(value, for: apiKeyAccount) }

    static var hasClaudeKey: Bool { !(claudeAPIKey ?? "").isEmpty }
}
