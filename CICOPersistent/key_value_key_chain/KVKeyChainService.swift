//
//  CICOKVKeyChainService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/7/27.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation
import CICOAutoCodable

private let kDefaultEncryptionkey = "cico_kv_key_chain_default_encryption_key"
private let kGenericKey = "cico_kv_generic_key"
private let kAccountKey = "cico_kv_account_key"

public class KVKeyChainService {
    public static let defaultService: KVKeyChainService = {
        if let key = Bundle.main.bundleIdentifier {
            return KVKeyChainService.init(encryptionKey: key)
        } else {
            return KVKeyChainService.init(encryptionKey: kDefaultEncryptionkey)
        }
    } ()
    
    private let encryptionKeyData: Data
    private let keyChainService: KeyChainService
    private let lock = NSLock()
    
    deinit {
        print("\(self) deinit")
    }
    
    init(encryptionKey: String, accessGroup: String? = nil) {
        self.encryptionKeyData = CICOSecurityAide.md5HashData(with: encryptionKey)
        self.keyChainService = KeyChainService.init(accessGroup: accessGroup)
    }
    
    public func readObject<T: Codable>(_ objectType: T.Type, forKey userKey: String) -> T? {
        guard let jsonKey = self.jsonKey(forUserKey: userKey) else {
            return nil
        }
        
        self.lock.lock()
        defer {
            self.lock.unlock()
        }
        
        guard let encryptedData = self.keyChainService.query(genericKey: kGenericKey, accountKey: kAccountKey, serviceKey: jsonKey) else {
            return nil
        }
        
        let jsonData = self.decryptData(encryptedData: encryptedData)

        return KVJSONAide.transferJSONDataToObject(jsonData, objectType: objectType)
    }
    
    public func writeObject<T: Codable>(_ object: T, forKey userKey: String) -> Bool {
        guard let jsonKey = self.jsonKey(forUserKey: userKey) else {
            return false
        }
        
        guard let jsonData = KVJSONAide.transferObjectToJSONData(object) else {
            return false
        }
        
        let encryptedData = self.encryptData(sourceData: jsonData)
        
        self.lock.lock()
        defer {
            self.lock.unlock()
        }
        
        if let _ = self.keyChainService.query(genericKey: kGenericKey, accountKey: kAccountKey, serviceKey: jsonKey) {
            return self.keyChainService.update(data: encryptedData, genericKey: kGenericKey, accountKey: kAccountKey, serviceKey: jsonKey)
        } else {
            return self.keyChainService.add(data: encryptedData, genericKey: kGenericKey, accountKey: kAccountKey, serviceKey: jsonKey)
        }
    }
    
    public func updateObject<T: Codable>(_ objectType: T.Type,
                                           forKey userKey: String,
                                           updateClosure: (T?) -> T?,
                                           completionClosure: ((Bool) -> Void)? = nil) {
        var result = false
        defer {
            completionClosure?(result)
        }
        
        guard let jsonKey = self.jsonKey(forUserKey: userKey) else {
            return
        }
        
        self.lock.lock()
        defer {
            self.lock.unlock()
        }
        
        var object: T? = nil
        var exist = false
        
        // read
        if let encryptedData = self.keyChainService.query(genericKey: kGenericKey, accountKey: kAccountKey, serviceKey: jsonKey) {
            exist = true
            let jsonData = self.decryptData(encryptedData: encryptedData)
            object = KVJSONAide.transferJSONDataToObject(jsonData, objectType: objectType)
        }
        
        // update
        guard let newObject = updateClosure(object) else {
            result = true
            return
        }
        
        guard let newJSONData = KVJSONAide.transferObjectToJSONData(newObject) else {
            return
        }
        
        let newEncryptedData = self.encryptData(sourceData: newJSONData)
        
        // write
        if exist {
            result = self.keyChainService.update(data: newEncryptedData, genericKey: kGenericKey, accountKey: kAccountKey, serviceKey: jsonKey)
        } else {
            result = self.keyChainService.add(data: newEncryptedData, genericKey: kGenericKey, accountKey: kAccountKey, serviceKey: jsonKey)
        }
    }
    
    public func removeObject(forKey userKey: String) -> Bool {
        guard let jsonKey = self.jsonKey(forUserKey: userKey) else {
            return false
        }

        return self.keyChainService.delete(genericKey: kGenericKey, accountKey: kAccountKey, serviceKey: jsonKey)
    }

    private func jsonKey(forUserKey userKey: String) -> String? {
        guard userKey.count > 0 else {
            return nil
        }
        
        return CICOSecurityAide.md5HashString(with: userKey)
    }
    
    private func encryptData(sourceData: Data) -> Data {
        return CICOSecurityAide.aesEncrypt(withKeyData: self.encryptionKeyData, sourceData: sourceData)
    }
    
    private func decryptData(encryptedData: Data) -> Data {
        return CICOSecurityAide.aesDecrypt(withKeyData: self.encryptionKeyData, encryptedData: encryptedData)
    }
}
