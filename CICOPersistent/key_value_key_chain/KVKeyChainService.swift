//
//  CICOKVKeyChainService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/7/27.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation
import CICOFoundationKit
import CICOAutoCodable

private let kDefaultPassword = "cico_kv_key_chain_default_password"
private let kGenericKey = "cico_kv_generic_key"
private let kAccountKey = "cico_kv_account_key"

///
/// Key-Value key chain service;
///
/// You can save any object that conform to codable protocol using string key;
/// Each object will be encrypted by AES256 before saving to the key chain;
///
public class KVKeyChainService {
    /// Default Key-Value key chain service using default password
    public static let defaultService: KVKeyChainService = {
        if let password = Bundle.main.bundleIdentifier {
            return KVKeyChainService.init(password: password)
        } else {
            return KVKeyChainService.init(password: kDefaultPassword)
        }
    }()

    private let passwordData: Data
    private let keyChainService: KeyChainService
    private let lock = NSLock()

    deinit {
        print("\(self) deinit")
    }

    /// Init with password and accessGroup;
    ///
    /// - parameter password: Data encryption password; It is used for AES256 encryption;
    /// - parameter accessGroup: The access group for key chain; Default is nil;
    ///             Two or more apps that are in the same group—for example,
    ///             because they share a common keychain access group entitlement—can therefore share keychain items;
    ///             You should config your access group in
    ///             "Your Target--Capabilities--Keychain Sharing--Keychain Groups" before you use it;
    ///
    /// - returns: Init object;
    ///
    /// - see: kSecAttrAccessGroup
    public init(password: String, accessGroup: String? = nil) {
        self.passwordData = SecurityAide.shaHashData(password, type: .SHA256)
        self.keyChainService = KeyChainService.init(accessGroup: accessGroup)
    }

    /// Read object using key;
    ///
    /// - parameter objectType: Type of the object, it must conform to codable protocol;
    /// - parameter forKey: Key of the object;
    ///
    /// - returns: Read object, nil when no object for this key;
    public func readObject<T: Codable>(_ objectType: T.Type, forKey userKey: String) -> T? {
        guard let jsonKey = self.jsonKey(forUserKey: userKey) else {
            return nil
        }

        self.lock.lock()
        defer {
            self.lock.unlock()
        }

        guard let encryptedData =
            self.keyChainService.query(genericKey: kGenericKey,
                                       accountKey: kAccountKey,
                                       serviceKey: jsonKey) else {
            return nil
        }

        guard let jsonData = self.decryptData(encryptedData: encryptedData) else {
            print("[ERROR]: Decrypt data failed.")
            return nil
        }

        return KVJSONAide.transferJSONDataToObject(jsonData, objectType: objectType)
    }

    /// Write object using key;
    ///
    /// Add when it does not exist, update when it exists;
    ///
    /// - parameter object: The object will be saved in file, it must conform to codable protocol;
    /// - parameter forKey: Key of the object;
    ///
    /// - returns: Write result;
    public func writeObject<T: Codable>(_ object: T, forKey userKey: String) -> Bool {
        guard let jsonKey = self.jsonKey(forUserKey: userKey) else {
            return false
        }

        guard let jsonData = KVJSONAide.transferObjectToJSONData(object) else {
            return false
        }

        guard let encryptedData = self.encryptData(sourceData: jsonData) else {
            print("[ERROR]: Encrypt data failed.")
            return false
        }

        self.lock.lock()
        defer {
            self.lock.unlock()
        }

        if self.keyChainService.query(genericKey: kGenericKey,
                                      accountKey: kAccountKey,
                                      serviceKey: jsonKey) != nil {
            return self.keyChainService.update(data: encryptedData,
                                               genericKey: kGenericKey,
                                               accountKey: kAccountKey,
                                               serviceKey: jsonKey)
        } else {
            return self.keyChainService.add(data: encryptedData,
                                            genericKey: kGenericKey,
                                            accountKey: kAccountKey,
                                            serviceKey: jsonKey)
        }
    }

    /// Update object using key;
    ///
    /// Read the existing object, then call the "updateClosure", and write the object returned by "updateClosure";
    /// It won't update when "updateClosure" returns nil;
    ///
    /// - parameter objectType: Type of the object, it must conform to codable protocol;
    /// - parameter forKey: Key of the object;
    /// - parameter updateClosure: It will be called after reading object from file,
    ///             the read object will be passed as parameter, you can return a new value to update in file;
    ///             It won't be updated to file when you return nil by this closure;
    /// - parameter completionClosure: It will be called when completed, passing update result as parameter;
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

        var object: T?
        var exist = false

        // read
        if let encryptedData = self.keyChainService.query(genericKey: kGenericKey,
                                                          accountKey: kAccountKey,
                                                          serviceKey: jsonKey),
            let jsonData = self.decryptData(encryptedData: encryptedData) {
            exist = true
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

        guard let newEncryptedData = self.encryptData(sourceData: newJSONData) else {
            print("[ERROR]: Encrypt data failed.")
            return
        }

        // write
        if exist {
            result = self.keyChainService.update(data: newEncryptedData,
                                                 genericKey: kGenericKey,
                                                 accountKey: kAccountKey,
                                                 serviceKey: jsonKey)
        } else {
            result = self.keyChainService.add(data: newEncryptedData,
                                              genericKey: kGenericKey,
                                              accountKey: kAccountKey,
                                              serviceKey: jsonKey)
        }
    }

    /// Remove object using key;
    ///
    /// - parameter forKey: Key of the object;
    ///
    /// - returns: Remove result;
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

        return SecurityAide.md5HashString(userKey)
    }

    private func encryptData(sourceData: Data) -> Data? {
        return SecurityAide.aesEncrypt(sourceData, type: .AES256, keyData: self.passwordData)
    }

    private func decryptData(encryptedData: Data) -> Data? {
        return SecurityAide.aesDecrypt(encryptedData, type: .AES256, keyData: self.passwordData)
    }
}
