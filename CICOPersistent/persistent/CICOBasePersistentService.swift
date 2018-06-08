//
//  CICOBasePersistentService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/6/7.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

private let kJSONDataDirName = "json_data"

open class CICOBasePersistentService {
    public let rootDirURL: URL
    
    private let fileLock = NSLock()
    
    public init(rootDirURL: URL) {
        self.rootDirURL = rootDirURL
        
        CICOPathAide.createDir(with: self.rootDirURL, option: true)
        CICOPathAide.createDir(with: self.jsonDataFileURL(forJSONKey: nil), option: true)
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

/*******************************************
 * Codable Key:Value Independent Persistent
 *******************************************/
    
    open func readObject<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let jsonKey = self.jsonKey(forUserKey: key) else {
            return nil
        }
        
        let fileURL = self.jsonDataFileURL(forJSONKey: jsonKey)
        
        guard let jsonData = self.readJSONData(fileURL: fileURL) else {
            return nil
        }
        
        do {
            let objectArray = try JSONDecoder().decode([T].self, from: jsonData)
            return objectArray.first
        } catch let error {
            print("[JSON_DECODE_ERROR]: \(error)")
            return nil
        }
    }
    
    open func writeObject<T: Encodable>(_ object: T, forKey key: String) -> Bool {
        guard let jsonKey = self.jsonKey(forUserKey: key) else {
            return false
        }
        
        let fileURL = self.jsonDataFileURL(forJSONKey: jsonKey)
        
        do {
            let jsonData = try JSONEncoder().encode([object])
            return self.writeJSONData(jsonData, toFileURL: fileURL)
        } catch let error {
            print("[JSON_ENCODE_ERROR]: \(error)")
            return false
        }
    }

    open func removeObject(forKey key: String) -> Bool {
        guard let jsonKey = self.jsonKey(forUserKey: key) else {
            return false
        }
        
        let fileURL = self.jsonDataFileURL(forJSONKey: jsonKey)
        
        do {
            try FileManager.default.removeItem(at: fileURL)
            return true
        } catch let error {
            print("[REMOVE_JSON_FILE_ERROR]: \(error)")
            return false
        }
    }
    
    private func jsonKey(forUserKey key: String) -> String? {
        guard key.count > 0 else {
            return nil
        }
        
        return CICOSecurityAide.md5HashString(with: key)
    }
    
    private func jsonDataFileURL(forJSONKey key: String?) -> URL {
        var fileURL = self.rootDirURL
        fileURL.appendPathComponent(kJSONDataDirName)
        if let key = key {
            fileURL.appendPathComponent(key)
        }
        return fileURL
    }
    
    private func readJSONData(fileURL: URL) -> Data? {
        do {
            self.fileLock.lock()
            let jsonData = try Data.init(contentsOf: fileURL)
            self.fileLock.unlock()
            return jsonData
        } catch let error {
            self.fileLock.unlock()
            print("[READ_JSON_FILE_ERROR]: \(error)")
            return nil
        }
    }
    
    private func writeJSONData(_ jsonData: Data, toFileURL fileURL: URL) -> Bool {
        do {
            self.fileLock.lock()
            try jsonData.write(to: fileURL, options: .atomic)
            self.fileLock.unlock()
            return true
        } catch let error {
            self.fileLock.unlock()
            print("[WRITE_JSON_FILE_ERROR]: \(error)")
            return false
        }
    }

/****************************************
 * Codable Key:Value Database Persistent
 ****************************************/

/**********************************
 * Codable ORM Database Persistent
 **********************************/

/**********************
 * Keychain Persistent
 **********************/
}
