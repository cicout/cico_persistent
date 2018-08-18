//
//  CICOKVDBService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/6/11.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation
import FMDB

private let kJSONTableName = "json_table"
private let kJSONKeyColumnName = "json_key"
private let kJSONDataColumnName = "json_data"
private let kUpdateTimeColumnName = "update_time"

open class KVDBService {
    public let fileURL: URL
    
    private var dbQueue: FMDatabaseQueue?
    
    deinit {
        print("\(self) deinit")
        self.dbQueue?.close()
    }
    
    public init(fileURL: URL) {
        self.fileURL = fileURL
        self.initDB()
    }
    
    open func readObject<T: Codable>(_ objectType: T.Type, forKey userKey: String) -> T? {
        guard let jsonKey = self.jsonKey(forUserKey: userKey) else {
            return nil
        }
        
        guard let jsonData = self.readJSONData(jsonKey: jsonKey) else {
            return nil
        }
        
        return KVJSONAide.transferJSONDataToObject(jsonData, objectType: objectType)
    }
    
    open func writeObject<T: Codable>(_ object: T, forKey userKey: String) -> Bool {
        guard let jsonKey = self.jsonKey(forUserKey: userKey) else {
            return false
        }
        
        guard let jsonData = KVJSONAide.transferObjectToJSONData(object) else {
            return false
        }
        
        return self.writeJSONData(jsonData, forJSONKey: jsonKey)
    }
    
    open func updateObject<T: Codable>(_ objectType: T.Type,
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
        
        self.dbQueue?.inDatabase { (db) in
            
            var object: T? = nil
            
            // read
            let querySQL = "SELECT * FROM \(kJSONTableName) WHERE \(kJSONKeyColumnName) = ? LIMIT 1;"
            if let resultSet = db.executeQuery(querySQL, withArgumentsIn: [jsonKey]) {
                if resultSet.next(),
                    let jsonData = resultSet.data(forColumn: kJSONDataColumnName) {
                    object = KVJSONAide.transferJSONDataToObject(jsonData, objectType: objectType)
                }
                resultSet.close()
            }

            // update
            guard let newObject = updateClosure(object) else {
                result = true
                return
            }
            
            guard let newJSONData = KVJSONAide.transferObjectToJSONData(newObject) else {
                return
            }
            
            // write
            let updateTime = Date().timeIntervalSinceReferenceDate
            let updateSQL = "REPLACE INTO \(kJSONTableName) (\(kJSONKeyColumnName), \(kJSONDataColumnName), \(kUpdateTimeColumnName)) VALUES (?, ?, ?);"
            result = db.executeUpdate(updateSQL, withArgumentsIn: [jsonKey, newJSONData, updateTime])
            if !result {
                print("[ERROR]: SQL = \(updateSQL)")
            }
        }
    }
    
    open func removeObject(forKey userKey: String) -> Bool {
        guard let jsonKey = self.jsonKey(forUserKey: userKey) else {
            return false
        }
        
        return self.removeJSONData(jsonKey:jsonKey)
    }
    
    open func clearAll() -> Bool {
        self.dbQueue = nil
        let result = CICOFileManagerAide.removeFile(with: self.fileURL)
        self.dbQueue = FMDatabaseQueue.init(url: self.fileURL)
        return result
    }
    
    private func initDB() {
        let dirURL = self.fileURL.deletingLastPathComponent()
        let result = CICOFileManagerAide.createDir(with: dirURL)
        if !result {
            print("[ERROR]: create database dir failed\nurl: \(self.fileURL)")
            return
        }
        
        guard let dbQueue = FMDatabaseQueue.init(url: self.fileURL) else {
            print("[ERROR]: create database failed\nurl: \(self.fileURL)")
            return
        }
        
        dbQueue.inDatabase { (db) in
            let createTableSQL = "CREATE TABLE IF NOT EXISTS \(kJSONTableName) (\(kJSONKeyColumnName) TEXT NOT NULL, \(kJSONDataColumnName) BLOB NOT NULL, \(kUpdateTimeColumnName) REAL NOT NULL, PRIMARY KEY(\(kJSONKeyColumnName)));"
            let result = db.executeUpdate(createTableSQL, withArgumentsIn: [])
            if result {
                self.dbQueue = dbQueue
            } else {
                print("[ERROR]: SQL = \(createTableSQL)")
            }
        }
    }
    
    private func jsonKey(forUserKey userKey: String) -> String? {
        guard userKey.count > 0 else {
            return nil
        }
        
        return CICOSecurityAide.md5HashString(with: userKey)
    }
    
    private func readJSONData(jsonKey: String) -> Data? {
        var jsonData: Data? = nil
        
        self.dbQueue?.inDatabase { (db) in
            let querySQL = "SELECT * FROM \(kJSONTableName) WHERE \(kJSONKeyColumnName) = ? LIMIT 1;"
            
            guard let resultSet = db.executeQuery(querySQL, withArgumentsIn: [jsonKey]) else {
                return
            }
            
            if resultSet.next() {
                jsonData = resultSet.data(forColumn: kJSONDataColumnName)
//                let updateTime = resultSet.double(forColumn: kUpdateTimeColumnName)
//                print("read time \(updateTime)")
            }
            
            resultSet.close()
        }
        
        return jsonData
    }
    
    private func writeJSONData(_ jsonData: Data, forJSONKey jsonKey: String) -> Bool {
        var result = false
        
        self.dbQueue?.inDatabase { (db) in
            let updateTime = Date().timeIntervalSinceReferenceDate
//            print("write time \(updateTime)")
            let updateSQL = "REPLACE INTO \(kJSONTableName) (\(kJSONKeyColumnName), \(kJSONDataColumnName), \(kUpdateTimeColumnName)) VALUES (?, ?, ?);"
            result = db.executeUpdate(updateSQL, withArgumentsIn: [jsonKey, jsonData, updateTime])
            if !result {
                print("[ERROR]: SQL = \(updateSQL)")
            }
        }
        
        return result
    }
    
    private func removeJSONData(jsonKey: String) -> Bool {
        var result = false
        
        self.dbQueue?.inDatabase { (db) in
            let deleteSQL = "DELETE FROM \(kJSONTableName) WHERE \(kJSONKeyColumnName) = ?;"
            result = db.executeUpdate(deleteSQL, withArgumentsIn: [jsonKey])
            if !result {
                print("[ERROR]: SQL = \(deleteSQL)")
            }
        }
        
        return result
    }
}
