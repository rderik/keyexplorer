//
//  main.swift
//  KeyExplorer
//
//  Created by Derik Ramirez on 7/2/19.
//  Copyright © 2019 Derik Ramirez. All rights reserved.
//

import Security
import Foundation

struct User {
    var username: String
    var password: String
}

enum KeychainError: Error {
    case noPassword
    case unexpectedPasswordData
    case unexpectedItemData
    case unhandledError(status: OSStatus)
}

let server = "https://rderik.com"
let user = User(username: "rderik", password: "pass123")

var query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                            kSecAttrServer as String: server,
                            kSecAttrAccount as String: user.username,
                            kSecValueData as String: user.password.data(using: String.Encoding.utf8)!]
puts("Este es el query:\(query)")
var status = SecItemAdd(query as CFDictionary, nil)
if status != errSecSuccess {
    let errmsg = SecCopyErrorMessageString(status, nil)
    print("Veamos: \(errmsg)")
}
print("Succesful save")

// Get the value from keychain
query = [kSecClass as String: kSecClassInternetPassword,
         kSecAttrServer as String: server,
         kSecMatchLimit as String: kSecMatchLimitOne,
         kSecReturnAttributes as String: true,
         kSecReturnData as String: true]

var item: CFTypeRef?
status = SecItemCopyMatching(query as CFDictionary, &item)
guard status != errSecItemNotFound else { throw KeychainError.noPassword }

guard status == errSecSuccess else {
    let errmsg = SecCopyErrorMessageString(status, nil)
    print("Veamos: \(errmsg ?? "" as CFString)")
    throw KeychainError.unhandledError(status: status)
}



guard let existingItem = item as? [String : Any],
    let passwordData = existingItem[kSecValueData as String] as? Data,
    let password = String(data: passwordData, encoding: String.Encoding.utf8),
    let account = existingItem[kSecAttrAccount as String] as? String
    else {
        throw KeychainError.unexpectedPasswordData
}
print("username: \(account), password: \(password)")

