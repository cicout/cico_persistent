//
//  PersistentService+KVKeyChain.swift
//  CICOPersistent
//
//  Created by lucky.li on 2019/8/26.
//  Copyright © 2019 cico. All rights reserved.
//

import Foundation

/**********************
 * Keychain Persistent
 **********************/

extension PersistentService {
    ///
    /// Read object from KVKeyChainService using key;
    ///
    /// - parameter objectType: Type of the object, it must conform to codable protocol;
    /// - parameter forKey: Key of the object;
    ///
    /// - returns: Read object, nil when no object for this key;
    ///
    /// - see: KVKeyChainService.defaultService.readObject(_:forKey:)
    public func readKVKeyChainObject<T: Codable>(_ objectType: T.Type, forKey userKey: String) -> T? {
        return KVKeyChainService.defaultService.readObject(objectType, forKey: userKey)
    }

    /// Write object into KVKeyChainService using key;
    ///
    /// Add when it does not exist, update when it exists;
    ///
    /// - parameter object: The object will be saved in file, it must conform to codable protocol;
    /// - parameter forKey: Key of the object;
    ///
    /// - returns: Write result;
    ///
    /// - see: KVKeyChainService.defaultService.writeObject(_:forKey:)
    public func writeKVKeyChainObject<T: Codable>(_ object: T, forKey userKey: String) -> Bool {
        return KVKeyChainService.defaultService.writeObject(object, forKey: userKey)
    }

    /// Update object in KVKeyChainService using key;
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
    ///
    /// - see: KVKeyChainService.defaultService.updateObject(_:forKey:updateClosure:completionClosure:)
    public func updateKVKeyChainObject<T: Codable>(_ objectType: T.Type,
                                                   forKey userKey: String,
                                                   updateClosure: (T?) -> T?,
                                                   completionClosure: ((Bool) -> Void)? = nil) {
        KVKeyChainService.defaultService.updateObject(objectType,
                                                      forKey: userKey,
                                                      updateClosure: updateClosure,
                                                      completionClosure: completionClosure)
    }

    /// Remove object from KVKeyChainService using key;
    ///
    /// - parameter forKey: Key of the object;
    ///
    /// - returns: Remove result;
    ///
    /// - see: KVKeyChainService.defaultService.removeObject(forKey:)
    public func removeKVKeyChainObject(forKey userKey: String) -> Bool {
        return KVKeyChainService.defaultService.removeObject(forKey: userKey)
    }
}
