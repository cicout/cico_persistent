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

open class CICOPersistentService {
    public let rootDirURL: URL
    
    private let kvFileService: CICOKVFileService
    private let kvDBService: CICOKVDBService
    private let ormDBService: CICOORMDBService
    
    deinit {
        print("\(self) deinit")
    }
    
    public init(rootDirURL: URL) {
        self.rootDirURL = rootDirURL
        
        let kvFileDirURL = rootDirURL.appendingPathComponent(kKVFileDirName)
        self.kvFileService = CICOKVFileService.init(rootDirURL: kvFileDirURL)
        
        let kvDBFileURL = rootDirURL.appendingPathComponent(kKVDBFileSubPath)
        self.kvDBService = CICOKVDBService.init(fileURL: kvDBFileURL)
        
        let ormDBFileURL = rootDirURL.appendingPathComponent(kORMDBFileSubPath)
        self.ormDBService = CICOORMDBService.init(fileURL: ormDBFileURL)
    }
    
    open func fileURL(subPath: String) -> URL {
        return self.rootDirURL.appendingPathComponent(subPath)
    }
    
    /*************************
     * UserDefault Persistent
     *************************/
    
    open func objectFromUserDefault(forKey key: String) -> Any? {
        return UserDefaults.standard.object(forKey:key)
    }
    
    open func valueFromUserDefault<T>(_ type: T.Type, forKey key: String) -> T? {
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
    
    open func readKVFileObject<T: Decodable>(_ type: T.Type, forKey userKey: String) -> T? {
        return self.kvFileService.readObject(type, forKey: userKey)
    }
    
    open func writeKVFileObject<T: Encodable>(_ object: T, forKey userKey: String) -> Bool {
        return self.kvFileService.writeObject(object, forKey: userKey)
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
    
    open func readKVDBObject<T: Decodable>(_ type: T.Type, forKey userKey: String) -> T? {
        return self.kvDBService.readObject(type, forKey: userKey)
    }
    
    open func writeKVDBObject<T: Encodable>(_ object: T, forKey userKey: String) -> Bool {
        return self.kvDBService.writeObject(object, forKey: userKey)
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
    
    open func readObject<T: CICOORMCodableProtocol>(ofType objectType: T.Type,
                                                    forPrimaryKey primaryKeyValue: Codable,
                                                    customTableName: String? = nil) -> T? {
        return self.ormDBService.readObject(ofType: objectType,
                                            forPrimaryKey: primaryKeyValue,
                                            customTableName: customTableName)
    }
    
    open func readObjectArray<T: CICOORMCodableProtocol>(ofType objectType: T.Type,
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
    
    open func writeObject<T: CICOORMCodableProtocol>(_ object: T, customTableName: String? = nil) -> Bool {
        return self.ormDBService.writeObject(object, customTableName: customTableName)
    }
    
    open func writeObjectArray<T: CICOORMCodableProtocol>(_ objectArray: [T], customTableName: String? = nil) -> Bool {
        return self.ormDBService.writeObjectArray(objectArray, customTableName: customTableName)
    }
    
    open func removeObject<T: CICOORMCodableProtocol>(ofType objectType: T.Type,
                                                      forPrimaryKey primaryKeyValue: Codable,
                                                      customTableName: String? = nil) -> Bool {
        return self.ormDBService.removeObject(ofType: objectType,
                                              forPrimaryKey: primaryKeyValue,
                                              customTableName: customTableName)
    }
    
    open func removeObjectTable<T: CICOORMCodableProtocol>(ofType objectType: T.Type, customTableName: String? = nil) -> Bool {
        return self.ormDBService.removeObjectTable(ofType: objectType, customTableName: customTableName)
    }
    
    open func clearAllORMDB() -> Bool {
        return self.ormDBService.clearAll()
    }
    
    /**********************
     * Keychain Persistent
     **********************/
    
    // TODO
}
