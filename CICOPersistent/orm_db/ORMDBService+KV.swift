//
//  ORMDBService+KV.swift
//  CICOPersistent
//
//  Created by Ethan.Li on 2020/3/26.
//  Copyright © 2020 cico. All rights reserved.
//

import Foundation

/// Key-Value table function;
extension ORMDBService {
    /// Read Key-Value object from database using key;
    ///
    /// - parameter objectType: Type of the object, it must conform to codable protocol;
    /// - parameter forKey: Key of the object in database;
    ///
    /// - returns: Read object, nil when no object for this key;
    open func readKVObject<T: Codable>(_ objectType: T.Type, forKey userKey: String) -> T? {
        return self.kvTableService.readObject(dbQueue: self.dbQueue, objectType: objectType, userKey: userKey)
    }

    /// Write Key-Value object into database using key;
    ///
    /// Add when it does not exist, update when it exists;
    ///
    /// - parameter object: The object will be saved in database, it must conform to codable protocol;
    /// - parameter forKey: Key of the object in database;
    ///
    /// - returns: Write result;
    open func writeKVObject<T: Codable>(_ object: T, forKey userKey: String) -> Bool {
        return self.kvTableService.writeObject(dbQueue: self.dbQueue, object: object, userKey: userKey)
    }

    /// Update Key-Value object in database using key;
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
    open func updateKVObject<T: Codable>(_ objectType: T.Type,
                                         forKey userKey: String,
                                         updateClosure: (T?) -> T?,
                                         completionClosure: ((Bool) -> Void)? = nil) {
        self.kvTableService.updateObject(dbQueue: self.dbQueue,
                                       objectType: objectType,
                                       userKey: userKey,
                                       updateClosure: updateClosure,
                                       completionClosure: completionClosure)
    }

    /// Remove Key-Value object from database using key;
    ///
    /// - parameter forKey: Key of the object in database;
    ///
    /// - returns: Remove result;
    open func removeKVObject(forKey userKey: String) -> Bool {
        return self.kvTableService.removeObject(dbQueue: self.dbQueue, userKey: userKey)
    }

    /// Remove all Key-Value objects from database;
    ///
    /// - returns: Remove result;
    open func clearAllKVObjects() -> Bool {
        return self.kvTableService.clearAll(dbQueue: self.dbQueue)
    }
}
