import Foundation
import Security

/// Small generic-password store for secrets such as the Steam Web API key.
enum Keychain {
  private static let service = "br.com.wanmind.padpilot"

  static func get(_ account: String) -> String? {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account,
      kSecReturnData as String: true,
      kSecMatchLimit as String: kSecMatchLimitOne,
    ]
    var item: CFTypeRef?
    guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess, let data = item as? Data else { return nil }
    return String(data: data, encoding: .utf8)
  }

  /// Stores [value], or deletes the entry when it's nil.
  @discardableResult
  static func set(_ account: String, _ value: String?) -> Bool {
    let base: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account,
    ]
    SecItemDelete(base as CFDictionary)
    guard let value, let data = value.data(using: .utf8) else { return true }
    var item = base
    item[kSecValueData as String] = data
    return SecItemAdd(item as CFDictionary, nil) == errSecSuccess
  }
}
