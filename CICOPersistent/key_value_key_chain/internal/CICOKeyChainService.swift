//
//  CICOKeyChainService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/7/27.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation
import Security

class CICOKeyChainService {
    let group: String
    let accessibleType: String
    let secClassType: String
    
    deinit {
        print("\(self) deinit")
    }
    
    init(group: String,
         accessibleType: String = kSecAttrAccessibleAlwaysThisDeviceOnly as String,
         secClassType: String = kSecClassGenericPassword as String) {
        self.group = group
        self.accessibleType = accessibleType
        self.secClassType = secClassType
    }
    
    func add(data: Data, genericKey: String, accountKey: String, serviceKey: String) -> Bool {
        var attributeDic = self.baseAttributeDic(genericKey: genericKey, accountKey: accountKey, serviceKey: serviceKey)
        
        attributeDic[kSecValueData as String] = data
        
        let status = SecItemAdd(attributeDic as CFDictionary, nil)
        
        if status == errSecSuccess {
            return true
        } else {
            print("[ERROR]: SecItemAdd failed, status = \(status)")
            return false
        }
    }
    
    func delete(genericKey: String, accountKey: String, serviceKey: String) -> Bool {
        let attributeDic = self.baseAttributeDic(genericKey: genericKey, accountKey: accountKey, serviceKey: serviceKey)

        let status = SecItemDelete(attributeDic as CFDictionary)
        
        if status == errSecSuccess || status == errSecItemNotFound {
            return true
        } else {
            print("[ERROR]: SecItemDelete failed, status = \(status)")
            return false
        }
    }
    
    func update(data: Data, genericKey: String, accountKey: String, serviceKey: String) -> Bool {
        let attributeDic = self.baseAttributeDic(genericKey: genericKey, accountKey: accountKey, serviceKey: serviceKey)
        
        let newAttributeDic: [String: Any] = [kSecValueData as String: data]
        
        let status = SecItemUpdate(attributeDic as CFDictionary, newAttributeDic as CFDictionary)
        
        if status == errSecSuccess {
            return true
        } else {
            print("[ERROR]: SecItemUpdate failed, status = \(status)")
            return false
        }
    }
    
    func query(genericKey: String, accountKey: String, serviceKey: String) -> Data? {
        var attributeDic = self.baseAttributeDic(genericKey: genericKey, accountKey: accountKey, serviceKey: serviceKey)
        
        attributeDic[kSecMatchLimit as String] = kSecMatchLimitOne as String
        attributeDic[kSecReturnData as String] = kSecReturnData as String
        
        var valueRef: CFTypeRef? = nil
        let status = SecItemCopyMatching(attributeDic as CFDictionary, &valueRef)
        
        if status == errSecSuccess {
            let data = valueRef as? Data
            return data
        } else {
            print("[ERROR]: SecItemCopyMatching failed, status = \(status)")
            return nil
        }
    }
    
    private func baseAttributeDic(genericKey: String, accountKey: String, serviceKey: String) -> [String: Any] {
        var attributeDic = [String: Any]()
        attributeDic[kSecAttrAccessGroup as String] = self.group
        attributeDic[kSecAttrAccessible as String] = self.accessibleType
        attributeDic[kSecClass as String] = self.secClassType
        attributeDic[kSecAttrGeneric as String] = genericKey
        attributeDic[kSecAttrAccount as String] = accountKey
        attributeDic[kSecAttrService as String] = serviceKey
        return attributeDic
    }
}
