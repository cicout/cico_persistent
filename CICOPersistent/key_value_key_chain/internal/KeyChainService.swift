//
//  CICOKeyChainService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/7/27.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation
import Security

class KeyChainService {
    private var accessGroup: String?
    private let accessibleType: String
    private let secClassType: String

    deinit {
        print("\(self) deinit")
    }

    init(accessGroup: String? = nil,
         accessibleType: String = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly as String,
         secClassType: String = kSecClassGenericPassword as String) {
        self.accessGroup = accessGroup
        self.accessibleType = accessibleType
        self.secClassType = secClassType
    }

    func add(data: Data, genericKey: String, accountKey: String, serviceKey: String) -> Bool {
        var queryDic = self.baseQueryDic(genericKey: genericKey, accountKey: accountKey, serviceKey: serviceKey)

        queryDic[kSecValueData as String] = data

        let status = SecItemAdd(queryDic as CFDictionary, nil)

        if status == errSecSuccess {
            return true
        } else {
            print("[ERROR]: SecItemAdd failed, status = \(status)")
            return false
        }
    }

    func delete(genericKey: String, accountKey: String, serviceKey: String) -> Bool {
        let queryDic = self.baseQueryDic(genericKey: genericKey, accountKey: accountKey, serviceKey: serviceKey)

        let status = SecItemDelete(queryDic as CFDictionary)

        if status == errSecSuccess || status == errSecItemNotFound {
            return true
        } else {
            print("[ERROR]: SecItemDelete failed, status = \(status)")
            return false
        }
    }

    func update(data: Data, genericKey: String, accountKey: String, serviceKey: String) -> Bool {
        let queryDic = self.baseQueryDic(genericKey: genericKey, accountKey: accountKey, serviceKey: serviceKey)

        let newqueryDic: [String: Any] = [kSecValueData as String: data]

        let status = SecItemUpdate(queryDic as CFDictionary, newqueryDic as CFDictionary)

        if status == errSecSuccess {
            return true
        } else {
            print("[ERROR]: SecItemUpdate failed, status = \(status)")
            return false
        }
    }

    func query(genericKey: String, accountKey: String, serviceKey: String) -> Data? {
        var queryDic = self.baseQueryDic(genericKey: genericKey, accountKey: accountKey, serviceKey: serviceKey)

        queryDic[kSecMatchLimit as String] = kSecMatchLimitOne
        queryDic[kSecReturnData as String] = kCFBooleanTrue

        var valueRef: CFTypeRef?
        let status = SecItemCopyMatching(queryDic as CFDictionary, &valueRef)

        if status == errSecSuccess {
            return valueRef as? Data
        } else if status == errSecItemNotFound {
            return nil
        } else {
            print("[ERROR]: SecItemCopyMatching failed, status = \(status)")
            return nil
        }
    }

    private func baseQueryDic(genericKey: String, accountKey: String, serviceKey: String) -> [String: Any] {
        var queryDic = [String: Any]()

        if let accessGroup = self.accessGroup {
            queryDic[kSecAttrAccessGroup as String] = accessGroup
        }

        queryDic[kSecAttrAccessible as String] = self.accessibleType
        queryDic[kSecClass as String] = self.secClassType
        queryDic[kSecAttrGeneric as String] = genericKey
        queryDic[kSecAttrAccount as String] = accountKey
        queryDic[kSecAttrService as String] = serviceKey

        return queryDic
    }
}
