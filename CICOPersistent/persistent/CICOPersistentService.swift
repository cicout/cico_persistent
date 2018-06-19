//
//  CICOPersistentService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/6/7.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

private let kKVFileDirName = "json_data"
private let kKVDBFileSubPath = "json_db/db.sqlite"

open class CICOPersistentService {
    public let rootDirURL: URL
    
    private let kvFileService: CICOKVFileService
    private let kvdb: CICOKVDBService!
    
    deinit {
        print("CICOBasePersistentService deinit")
    }
    
    public init(rootDirURL: URL) {
        self.rootDirURL = rootDirURL
        
        let kvFileDirURL = CICOPersistentService.kvFileDirURL(rootDirURL: self.rootDirURL)
        self.kvFileService = CICOKVFileService.init(rootDirURL: kvFileDirURL)
        
        let kvdbFileURL = CICOPersistentService.kvdbFileURL(rootDirURL: self.rootDirURL)
        self.kvdb = CICOKVDBService.init(fileURL: kvdbFileURL)
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
    
    static private func kvFileDirURL(rootDirURL: URL) -> URL {
        var fileURL = rootDirURL
        fileURL.appendPathComponent(kKVFileDirName)
        return fileURL
    }

/****************************************
 * Codable Key:Value Database Persistent
 ****************************************/

    open func readKVDBObject<T: Decodable>(_ type: T.Type, forKey userKey: String) -> T? {
        return self.kvdb.readObject(type, forKey: userKey)
    }
    
    open func writeKVDBObject<T: Encodable>(_ object: T, forKey userKey: String) -> Bool {
        return self.kvdb.writeObject(object, forKey: userKey)
    }
    
    open func removeKVDBObject(forKey userKey: String) -> Bool {
        return self.kvdb.removeObject(forKey: userKey)
    }

    static private func kvdbFileURL(rootDirURL: URL) -> URL {
        var fileURL = rootDirURL
        fileURL.appendPathComponent(kKVDBFileSubPath)
        return fileURL
    }
    
/**********************************
 * Codable ORM Database Persistent
 **********************************/

    // TODO
    
/**********************
 * Keychain Persistent
 **********************/
    
    // TODO
}
