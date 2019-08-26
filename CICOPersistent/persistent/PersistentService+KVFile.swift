//
//  PersistentService+KVFile.swift
//  CICOPersistent
//
//  Created by lucky.li on 2019/8/26.
//  Copyright © 2019 cico. All rights reserved.
//

import Foundation

/***********************************************
 * Codable Key:Value Independent File Persistent
 ***********************************************/

extension PersistentService {
    ///
    /// Read object from KVFileService using key;
    ///
    /// - parameter objectType: Type of the object, it must conform to codable protocol;
    /// - parameter forKey: Key of the object;
    ///
    /// - returns: Read object, nil when no object for this key;
    ///
    /// - see: KVFileService.readObject(_:forKey:)
    open func readKVFileObject<T: Codable>(_ objectType: T.Type, forKey userKey: String) -> T? {
        return self.kvFileService.readObject(objectType, forKey: userKey)
    }

    /// Write object into KVFileService using key;
    ///
    /// - parameter object: The object will be saved in file, it must conform to codable protocol;
    /// - parameter forKey: Key of the object;
    ///
    /// - returns: Write result;
    ///
    /// - see: KVFileService.writeObject(_:forKey:)
    open func writeKVFileObject<T: Codable>(_ object: T, forKey userKey: String) -> Bool {
        return self.kvFileService.writeObject(object, forKey: userKey)
    }

    /// Update object in KVFileService using key;
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
    /// - see: KVFileService.updateObject(_:forKey:updateClosure:completionClosure:)
    open func updateKVFileObject<T: Codable>(_ objectType: T.Type,
                                             forKey userKey: String,
                                             updateClosure: (T?) -> T?,
                                             completionClosure: ((Bool) -> Void)? = nil) {
        return self.kvFileService.updateObject(objectType,
                                               forKey: userKey,
                                               updateClosure: updateClosure,
                                               completionClosure: completionClosure)
    }

    /// Remove object from KVFileService using key;
    ///
    /// - parameter forKey: Key of the object;
    ///
    /// - returns: Remove result;
    ///
    /// - see: KVFileService.removeObject(forKey:)
    open func removeKVFileObject(forKey userKey: String) -> Bool {
        return self.kvFileService.removeObject(forKey: userKey)
    }

    /// Remove all objects in KVFileService;
    ///
    /// - returns: Remove result;
    ///
    /// - see: KVFileService.clearAll()
    open func clearAllKVFile() -> Bool {
        return self.kvFileService.clearAll()
    }
}
