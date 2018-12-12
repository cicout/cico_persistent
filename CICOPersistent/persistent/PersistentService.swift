//
//  CICOPersistentService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/6/7.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

private let kKVFileDirName = "kv_file"
private let kKVDBFileSubPath = "kv_db/db.sqlite"
private let kORMDBFileSubPath = "orm_db/db.sqlite"

open class PersistentService {
    public let rootDirURL: URL
    
    private let kvFileService: KVFileService
    private let kvDBService: KVDBService
    private let ormDBService: ORMDBService
    
    deinit {
        print("\(self) deinit")
    }
    
    public init(rootDirURL: URL) {
        self.rootDirURL = rootDirURL
        
        let kvFileDirURL = rootDirURL.appendingPathComponent(kKVFileDirName)
        self.kvFileService = KVFileService.init(rootDirURL: kvFileDirURL)
        
        let kvDBFileURL = rootDirURL.appendingPathComponent(kKVDBFileSubPath)
        self.kvDBService = KVDBService.init(fileURL: kvDBFileURL)
        
        let ormDBFileURL = rootDirURL.appendingPathComponent(kORMDBFileSubPath)
        self.ormDBService = ORMDBService.init(fileURL: ormDBFileURL)
    }
    
    open func fileURL(subPath: String) -> URL {
        return self.rootDirURL.appendingPathComponent(subPath)
    }
    
    /*****************
     * All Persistent
     *****************/
    
    /*
     * Clear KVFile/KVDB/ORMDB Persistent;
     * UserDefault/KVKeyChain will not be cleared;
     */
    open func clearAllPersistent() -> Bool {
        let result0 = self.clearAllKVFile()
        let result1 = self.clearAllKVDB()
        let result2 = self.clearAllORMDB()
        return (result0 && result1 && result2)
    }
    
    /*************************
     * UserDefault Persistent
     *************************/
    
    open func readObjectFromUserDefault(forKey key: String) -> Any? {
        return UserDefaults.standard.object(forKey:key)
    }
    
    open func readValueFromUserDefault<T>(_ objectType: T.Type, forKey key: String) -> T? {
        if let value = UserDefaults.standard.object(forKey: key) as? T {
            return value
        } else {
            return nil
        }
    }
    
    open func setUserDefault(_ value: Any?, forKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    open func synchronizeUserDefault() -> Bool {
        return UserDefaults.standard.synchronize()
    }
    
    /***********************************************
     * Codable Key:Value Independent File Persistent
     ***********************************************/
    
    open func readKVFileObject<T: Codable>(_ objectType: T.Type, forKey userKey: String) -> T? {
        return self.kvFileService.readObject(objectType, forKey: userKey)
    }
    
    open func writeKVFileObject<T: Codable>(_ object: T, forKey userKey: String) -> Bool {
        return self.kvFileService.writeObject(object, forKey: userKey)
    }
    

    
    open func updateKVFileObject<T: Codable>(_ objectType: T.Type,
                                             forKey userKey: String,
                                             updateClosure: (T?) -> T?,
                                             completionClosure: ((Bool) -> Void)? = nil) {
        return self.kvFileService.updateObject(objectType,
                                               forKey: userKey,
                                               updateClosure: updateClosure,
                                               completionClosure: completionClosure)
    }
    
    open func removeKVFileObject(forKey userKey: String) -> Bool {
        return self.kvFileService.removeObject(forKey: userKey)
    }
    
    open func clearAllKVFile() -> Bool {
        return self.kvFileService.clearAll()
    }
    
    /****************************************
     * Codable Key:Value Database Persistent
     ****************************************/
    
    open func readKVDBObject<T: Codable>(_ objectType: T.Type, forKey userKey: String) -> T? {
        return self.kvDBService.readObject(objectType, forKey: userKey)
    }
    
    open func writeKVDBObject<T: Codable>(_ object: T, forKey userKey: String) -> Bool {
        return self.kvDBService.writeObject(object, forKey: userKey)
    }
    
    open func updateKVDBObject<T: Codable>(_ objectType: T.Type,
                                           forKey userKey: String,
                                           updateClosure: (T?) -> T?,
                                           completionClosure: ((Bool) -> Void)? = nil) {
        return self.kvDBService.updateObject(objectType,
                                             forKey: userKey,
                                             updateClosure: updateClosure,
                                             completionClosure: completionClosure)
    }
    
    open func removeKVDBObject(forKey userKey: String) -> Bool {
        return self.kvDBService.removeObject(forKey: userKey)
    }
    
    open func clearAllKVDB() -> Bool {
        return self.kvDBService.clearAll()
    }
    
    /**********************************
     * Codable ORM Database Persistent
     **********************************/
    
    open func readORMDBObject<T: CICOORMCodableProtocol>(ofType objectType: T.Type,
                                                    primaryKeyValue: Codable,
                                                    customTableName: String? = nil) -> T? {
        return self.ormDBService.readObject(ofType: objectType,
                                            primaryKeyValue: primaryKeyValue,
                                            customTableName: customTableName)
    }
    
    open func readORMDBObjectArray<T: CICOORMCodableProtocol>(ofType objectType: T.Type,
                                                         whereString: String? = nil,
                                                         orderByName: String? = nil,
                                                         descending: Bool = true,
                                                         limit: Int? = nil,
                                                         customTableName: String? = nil) -> [T]? {
        return self.ormDBService.readObjectArray(ofType: objectType,
                                                 whereString: whereString,
                                                 orderByName: orderByName,
                                                 descending: descending,
                                                 limit: limit,
                                                 customTableName: customTableName)
    }
    
    open func writeORMDBObject<T: CICOORMCodableProtocol>(_ object: T, customTableName: String? = nil) -> Bool {
        return self.ormDBService.writeObject(object, customTableName: customTableName)
    }
    
    open func writeORMDBObjectArray<T: CICOORMCodableProtocol>(_ objectArray: [T], customTableName: String? = nil) -> Bool {
        return self.ormDBService.writeObjectArray(objectArray, customTableName: customTableName)
    }
    
    open func updateORMDBObject<T: CICOORMCodableProtocol>(ofType objectType: T.Type,
                                                      primaryKeyValue: Codable,
                                                      customTableName: String? = nil,
                                                      updateClosure: (T?) -> T?,
                                                      completionClosure: ((Bool) -> Void)? = nil) {
        return self.ormDBService.updateObject(ofType: objectType,
                                              primaryKeyValue: primaryKeyValue,
                                              customTableName: customTableName,
                                              updateClosure: updateClosure,
                                              completionClosure: completionClosure)
    }
    
    open func removeORMDBObject<T: CICOORMCodableProtocol>(ofType objectType: T.Type,
                                                      primaryKeyValue: Codable,
                                                      customTableName: String? = nil) -> Bool {
        return self.ormDBService.removeObject(ofType: objectType,
                                              primaryKeyValue: primaryKeyValue,
                                              customTableName: customTableName)
    }
    
    open func removeORMDBObjectTable<T: CICOORMCodableProtocol>(ofType objectType: T.Type, customTableName: String? = nil) -> Bool {
        return self.ormDBService.removeObjectTable(ofType: objectType, customTableName: customTableName)
    }
    
    open func clearAllORMDB() -> Bool {
        return self.ormDBService.clearAll()
    }
    
    /**********************
     * Keychain Persistent
     **********************/
    
    public func readKVKeyChainObject<T: Codable>(_ objectType: T.Type, forKey userKey: String) -> T? {
        return KVKeyChainService.defaultService.readObject(objectType, forKey: userKey)
    }
    
    public func writeKVKeyChainObject<T: Codable>(_ object: T, forKey userKey: String) -> Bool {
        return KVKeyChainService.defaultService.writeObject(object, forKey: userKey)
    }
    
    public func updateKVKeyChainObject<T: Codable>(_ objectType: T.Type,
                                         forKey userKey: String,
                                         updateClosure: (T?) -> T?,
                                         completionClosure: ((Bool) -> Void)? = nil) {
        KVKeyChainService.defaultService.updateObject(objectType,
                                                          forKey: userKey,
                                                          updateClosure: updateClosure,
                                                          completionClosure: completionClosure)
    }
    
    public func removeKVKeyChainObject(forKey userKey: String) -> Bool {
        return KVKeyChainService.defaultService.removeObject(forKey: userKey)
    }
}
