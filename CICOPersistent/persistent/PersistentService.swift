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

///
/// All persistent functions;
///
/// It lists all persistent functions here;
/// - UserDefault: UserDefaults.standard functions, for simple Key-Value persistent only;
/// - KVFile: Key-Value file service, for all codable objects storing;
/// - KVDB: Key-Value database service, for all codable objects storing;
/// - ORMDB: ORM database service, for all codable objects storing;
/// - KVKeyChain: Key-Value key chain service, for all codable objects storing;
///
open class PersistentService {
    public let rootDirURL: URL
    
    private let kvFileService: KVFileService
    private let kvDBService: KVDBService
    private let ormDBService: ORMDBService
    
    deinit {
        print("\(self) deinit")
    }
    
    /// Init with root directory URL;
    ///
    /// It will use default password for KVFileService/KVDBService/ORMDBService/KVKeyChainService;
    ///
    /// - parameter rootDirURL: The root directory URL for persistent;
    ///
    /// - returns: Init object;
    public init(rootDirURL: URL) {
        self.rootDirURL = rootDirURL
        
        let kvFileDirURL = rootDirURL.appendingPathComponent(kKVFileDirName)
        self.kvFileService = KVFileService.init(rootDirURL: kvFileDirURL)
        
        let kvDBFileURL = rootDirURL.appendingPathComponent(kKVDBFileSubPath)
        self.kvDBService = KVDBService.init(fileURL: kvDBFileURL)
        
        let ormDBFileURL = rootDirURL.appendingPathComponent(kORMDBFileSubPath)
        self.ormDBService = ORMDBService.init(fileURL: ormDBFileURL)
    }
    
    /// File URL in root directory;
    ///
    /// - parameter subPath: Path relative to the root directory path;
    ///
    /// - returns: Full file URL;
    open func fileURL(subPath: String) -> URL {
        return self.rootDirURL.appendingPathComponent(subPath)
    }
    
    /*****************
     * All Persistent
     *****************/
    
    ///
    /// Clear KVFile/KVDB/ORMDB Persistent; UserDefault and KVKeyChain will not be cleared;
    ///
    /// - returns: Remove result;
    open func clearAllPersistent() -> Bool {
        let result0 = self.clearAllKVFile()
        let result1 = self.clearAllKVDB()
        let result2 = self.clearAllORMDB()
        return (result0 && result1 && result2)
    }
    
    /*************************
     * UserDefault Persistent
     *************************/
    
    ///
    /// Read object from UserDefault using key;
    ///
    /// - parameter forKey: Key of the object;
    ///
    /// - returns: Read object, nil when no object for this key;
    open func readObjectFromUserDefault(forKey key: String) -> Any? {
        return UserDefaults.standard.object(forKey:key)
    }
    
    /// Read object from UserDefault using key;
    ///
    /// - parameter objectType: Type of the object;
    /// - parameter forKey: Key of the object;
    ///
    /// - returns: Read object, nil when no object for this key;
    ///
    /// - see: UserDefaults.standard.object(forKey:);
    open func readValueFromUserDefault<T>(_ objectType: T.Type, forKey key: String) -> T? {
        if let value = UserDefaults.standard.object(forKey: key) as? T {
            return value
        } else {
            return nil
        }
    }
    
    /// Write value into UserDefault using key;
    ///
    /// - parameter value: The value will be saved in UserDefault;
    /// - parameter forKey: Key of the object;
    ///
    /// - see: UserDefaults.standard.set(_:forKey:);
    open func writeUserDefaultValue(_ value: Any?, forKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    /// Remove object from UserDefault using key;
    ///
    /// - parameter forKey: Key of the object;
    ///
    /// - see: UserDefaults.standard.removeObject(forKey:);
    open func removeUserDefaultValue(forKey key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    /// Synchronize for UserDefaults;
    ///
    /// - see: UserDefaults.standard.synchronize();
    open func synchronizeUserDefault() -> Bool {
        return UserDefaults.standard.synchronize()
    }
    
    /***********************************************
     * Codable Key:Value Independent File Persistent
     ***********************************************/
    
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
    
    /****************************************
     * Codable Key:Value Database Persistent
     ****************************************/
    
    ///
    /// Read object from database of KVDBService using key;
    ///
    /// - parameter objectType: Type of the object, it must conform to codable protocol;
    /// - parameter forKey: Key of the object in database;
    ///
    /// - returns: Read object, nil when no object for this key;
    ///
    /// - see: KVDBService.readObject(_:forKey:)
    open func readKVDBObject<T: Codable>(_ objectType: T.Type, forKey userKey: String) -> T? {
        return self.kvDBService.readObject(objectType, forKey: userKey)
    }
    
    /// Write object into database of KVDBService using key;
    ///
    /// - parameter object: The object will be saved in database, it must conform to codable protocol;
    /// - parameter forKey: Key of the object in database;
    ///
    /// - returns: Write result;
    ///
    /// - see: KVDBService.writeObject(_:forKey:)
    open func writeKVDBObject<T: Codable>(_ object: T, forKey userKey: String) -> Bool {
        return self.kvDBService.writeObject(object, forKey: userKey)
    }
    
    /// Update object in database of KVDBService using key;
    ///
    /// - parameter objectType: Type of the object, it must conform to codable protocol;
    /// - parameter forKey: Key of the object in database;
    /// - parameter updateClosure: It will be called after reading object from database,
    ///             the read object will be passed as parameter, you can return a new value to update in database;
    ///             It won't be updated to database when you return nil by this closure;
    /// - parameter completionClosure: It will be called when completed, passing update result as parameter;
    ///
    /// - see: KVDBService.updateObject(_:forKey:updateClosure:completionClosure:)
    open func updateKVDBObject<T: Codable>(_ objectType: T.Type,
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
    open func removeKVDBObject(forKey userKey: String) -> Bool {
        return self.kvDBService.removeObject(forKey: userKey)
    }
    
    /// Remove all objects from database of KVDBService;
    ///
    /// - returns: Remove result;
    ///
    /// - see: KVDBService.clearAll()
    open func clearAllKVDB() -> Bool {
        return self.kvDBService.clearAll()
    }
    
    /**********************************
     * Codable ORM Database Persistent
     **********************************/
    
    ///
    /// Read object from database of ORMDBService using primary key;
    ///
    /// - parameter objectType: Type of the object, it must conform to codable protocol and ORMProtocol;
    /// - parameter primaryKeyValue: Primary key value of the object in database, it must conform to codable protocol;
    /// - parameter customTableName: One class or struct can be saved in different tables,
    ///             you can define your custom table name here;
    ///             It will use default table name according to the class or struct name when passing nil;
    ///
    /// - returns: Read object, nil when no object for this primary key;
    ///
    /// - see: ORMDBService.readObject(ofType:primaryKeyValue:customTableName:)
    open func readORMDBObject<T: CICOORMCodableProtocol>(ofType objectType: T.Type,
                                                    primaryKeyValue: Codable,
                                                    customTableName: String? = nil) -> T? {
        return self.ormDBService.readObject(ofType: objectType,
                                            primaryKeyValue: primaryKeyValue,
                                            customTableName: customTableName)
    }
    
    /// Read object array from database of ORMDBService using SQL;
    ///
    /// SQL: SELECT * FROM "TableName" WHERE "whereString" ORDER BY "orderByName" DESC/ASC LIMIT "limit";
    ///
    /// - parameter objectType: Type of the object, it must conform to codable protocol and ORMProtocol;
    /// - parameter whereString: Where string for SQL;
    /// - parameter orderByName: Order by name for SQL;
    /// - parameter customTableName: One class or struct can be saved in different tables,
    ///             you can define your custom table name here;
    ///             It will use default table name according to the class or struct name when passing nil;
    ///
    /// - returns: Read object, nil when no object for this primary key;
    ///
    /// - see: ORMDBService.readObjectArray(ofType:whereString:orderByName:descending:limit:customTableName:)
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
    
    /// Write object into database of ORMDBService using primary key;
    ///
    /// - parameter object: The object will be saved in database, it must conform to codable protocol and ORMProtocol;
    /// - parameter customTableName: One class or struct can be saved in different tables,
    ///             you can define your custom table name here;
    ///             It will use default table name according to the class or struct name when passing nil;
    ///
    /// - returns: Write result;
    ///
    /// - see: ORMDBService.writeObject(_:customTableName:)
    open func writeORMDBObject<T: CICOORMCodableProtocol>(_ object: T, customTableName: String? = nil) -> Bool {
        return self.ormDBService.writeObject(object, customTableName: customTableName)
    }
    
    /// Write object array into database of ORMDBService using primary key in one transaction;
    ///
    /// - parameter objectArray: The object array will be saved in database,
    ///             it must conform to codable protocol and ORMProtocol;
    /// - parameter customTableName: One class or struct can be saved in different tables,
    ///             you can define your custom table name here;
    ///             It will use default table name according to the class or struct name when passing nil;
    ///
    /// - returns: Write result;
    ///
    /// - see: ORMDBService.writeObjectArray(_:customTableName:)
    open func writeORMDBObjectArray<T: CICOORMCodableProtocol>(_ objectArray: [T], customTableName: String? = nil) -> Bool {
        return self.ormDBService.writeObjectArray(objectArray, customTableName: customTableName)
    }
    
    /// Update object in database of ORMDBService using primary key;
    ///
    /// - parameter objectType: Type of the object, it must conform to codable protocol;
    /// - parameter primaryKeyValue: Primary key value of the object in database, it must conform to codable protocol;
    /// - parameter customTableName: One class or struct can be saved in different tables,
    ///             you can define your custom table name here;
    ///             It will use default table name according to the class or struct name when passing nil;
    /// - parameter updateClosure: It will be called after reading object from database,
    ///             the read object will be passed as parameter, you can return a new value to update in database;
    ///             It won't be updated to database when you return nil by this closure;
    /// - parameter completionClosure: It will be called when completed, passing update result as parameter;
    ///
    /// - see: ORMDBService.updateObject(ofType:primaryKeyValue:customTableName:updateClosure:completionClosure:)
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
    
    /// Remove object from database of ORMDBService using primary key;
    ///
    /// - parameter objectType: Type of the object, it must conform to codable protocol;
    /// - parameter primaryKeyValue: Primary key value of the object in database, it must conform to codable protocol;
    /// - parameter customTableName: One class or struct can be saved in different tables,
    ///             you can define your custom table name here;
    ///             It will use default table name according to the class or struct name when passing nil;
    ///
    /// - returns: Remove result;
    ///
    /// - see: ORMDBService.removeObject(ofType:primaryKeyValue:customTableName: customTableName)
    open func removeORMDBObject<T: CICOORMCodableProtocol>(ofType objectType: T.Type,
                                                      primaryKeyValue: Codable,
                                                      customTableName: String? = nil) -> Bool {
        return self.ormDBService.removeObject(ofType: objectType,
                                              primaryKeyValue: primaryKeyValue,
                                              customTableName: customTableName)
    }
    
    /// Remove the whole table from database of ORMDBService by table name;
    ///
    /// - parameter objectType: Type of the object, it must conform to codable protocol;
    /// - parameter customTableName: One class or struct can be saved in different tables,
    ///             you can define your custom table name here;
    ///             It will use default table name according to the class or struct name when passing nil;
    ///
    /// - returns: Remove result;
    ///
    /// - see: ORMDBService.removeObjectTable(ofType:customTableName:)
    open func removeORMDBObjectTable<T: CICOORMCodableProtocol>(ofType objectType: T.Type, customTableName: String? = nil) -> Bool {
        return self.ormDBService.removeObjectTable(ofType: objectType, customTableName: customTableName)
    }
    
    /// Remove all tables from database of ORMDBService;
    ///
    /// - returns: Remove result;
    ///
    /// - see: ORMDBService.clearAll()
    open func clearAllORMDB() -> Bool {
        return self.ormDBService.clearAll()
    }
    
    /**********************
     * Keychain Persistent
     **********************/
    
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
