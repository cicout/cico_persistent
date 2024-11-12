//
//  PersistentService+KVDB.swift
//  CICOPersistent
//
//  Created by lucky.li on 2019/8/26.
//  Copyright © 2019 cico. All rights reserved.
//

import Foundation

/****************************************
 * Codable Key:Value Database Persistent
 ****************************************/

extension PersistentService {
    ///
    /// Read object from database of KVDBService using key;
    ///
    /// - parameter objectType: Type of the object, it must conform to codable protocol;
    /// - parameter forKey: Key of the object in database;
    ///
    /// - returns: Read object, nil when no object for this key;
    ///
    /// - see: KVDBService.readObject(_:forKey:)
    public func readKVDBObject<T: Codable>(_ objectType: T.Type, forKey userKey: String) -> T? {
        return self.kvDBService.readObject(objectType, forKey: userKey)
    }

    /// Write object into database of KVDBService using key;
    ///
    /// Add when it does not exist, update when it exists;
    ///
    /// - parameter object: The object will be saved in database, it must conform to codable protocol;
    /// - parameter forKey: Key of the object in database;
    ///
    /// - returns: Write result;
    ///
    /// - see: KVDBService.writeObject(_:forKey:)
    public func writeKVDBObject<T: Codable>(_ object: T, forKey userKey: String) -> Bool {
        return self.kvDBService.writeObject(object, forKey: userKey)
    }

    /// Update object in database of KVDBService using key;
    ///
    /// Read the existing object, then call the "updateClosure", and write the object returned by "updateClosure";
    /// It won't update when "updateClosure" returns nil;
    ///
    /// - parameter objectType: Type of the object, it must conform to codable protocol;
    /// - parameter forKey: Key of the object in database;
    /// - parameter updateClosure: It will be called after reading object from database,
    ///             the read object will be passed as parameter, you can return a new value to update in database;
    ///             It won't be updated to database when you return nil by this closure;
    /// - parameter completionClosure: It will be called when completed, passing update result as parameter;
    ///
    /// - see: KVDBService.updateObject(_:forKey:updateClosure:completionClosure:)
    public func updateKVDBObject<T: Codable>(_ objectType: T.Type,
                                             forKey userKey: String,
                                             updateClosure: (T?) -> T?,
                                             completionClosure: ((Bool) -> Void)? = nil) {
        return self.kvDBService.updateObject(objectType,
                                             forKey: userKey,
                                             updateClosure: updateClosure,
                                             completionClosure: completionClosure)
    }

    /// Remove object from database of KVDBService using key;
    ///
    /// - parameter forKey: Key of the object in database;
    ///
    /// - returns: Remove result;
    ///
    /// - see: KVDBService.removeObject(forKey:)
    public func removeKVDBObject(forKey userKey: String) -> Bool {
        return self.kvDBService.removeObject(forKey: userKey)
    }

    /// Remove all objects from database of KVDBService;
    ///
    /// - returns: Remove result;
    ///
    /// - see: KVDBService.clearAll()
    public func clearAllKVDB() -> Bool {
        return self.kvDBService.clearAll()
    }
}
