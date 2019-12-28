//
//  CICOKVDBService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/6/11.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation
import FMDB

public let kCICOKVDBDefaultPassword = "cico_kv_db_default_password"

private let kJSONTableName = "json_table"
private let kJSONKeyColumnName = "json_key"
private let kJSONDataColumnName = "json_data"
private let kUpdateTimeColumnName = "update_time"

///
/// Key-Value database service;
///
/// You can save any object that conform to codable protocol using string key;
///
open class KVDBService {
    public let fileURL: URL

    private let dbPasswordKey: String?
    private var dbQueue: FMDatabaseQueue?

    deinit {
        print("\(self) deinit")
        self.dbQueue?.close()
    }

    /// Init with database file URL and database encryption password;
    ///
    /// - parameter fileURL: Database file URL;
    /// - parameter password: Database encryption password; It will use default password if not passing this parameter;
    ///             Database won't be encrypted when password is nil;
    ///
    /// - returns: Init object;
    public init(fileURL: URL, password: String? = kCICOKVDBDefaultPassword) {
        self.fileURL = fileURL
        if let password = password {
            self.dbPasswordKey = SecurityAide.md5HashString(password)
        } else {
            self.dbPasswordKey = nil
        }
        self.initDB()
    }

    /// Read object from database using key;
    ///
    /// - parameter objectType: Type of the object, it must conform to codable protocol;
    /// - parameter forKey: Key of the object in database;
    ///
    /// - returns: Read object, nil when no object for this key;
    open func readObject<T: Codable>(_ objectType: T.Type, forKey userKey: String) -> T? {
        guard let jsonKey = self.jsonKey(forUserKey: userKey) else {
            return nil
        }

        guard let jsonData = self.readJSONData(jsonKey: jsonKey) else {
            return nil
        }

        return KVJSONAide.transferJSONDataToObject(jsonData, objectType: objectType)
    }

    /// Write object into database using key;
    ///
    /// Add when it does not exist, update when it exists;
    ///
    /// - parameter object: The object will be saved in database, it must conform to codable protocol;
    /// - parameter forKey: Key of the object in database;
    ///
    /// - returns: Write result;
    open func writeObject<T: Codable>(_ object: T, forKey userKey: String) -> Bool {
        guard let jsonKey = self.jsonKey(forUserKey: userKey) else {
            return false
        }

        guard let jsonData = KVJSONAide.transferObjectToJSONData(object) else {
            return false
        }

        return self.writeJSONData(jsonData, forJSONKey: jsonKey)
    }

    /// Update object in database using key;
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

        self.dbQueue?.inDatabase { (database) in

            var object: T?

            // read
            let querySQL = "SELECT * FROM \(kJSONTableName) WHERE \(kJSONKeyColumnName) = ? LIMIT 1;"
            if let resultSet = database.executeQuery(querySQL, withArgumentsIn: [jsonKey]) {
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
            let updateSQL = """
            REPLACE INTO \(kJSONTableName) (\(kJSONKeyColumnName),
            \(kJSONDataColumnName),
            \(kUpdateTimeColumnName)) VALUES (?, ?, ?);
            """
            result = database.executeUpdate(updateSQL, withArgumentsIn: [jsonKey, newJSONData, updateTime])
            if !result {
                print("[ERROR]: SQL = \(updateSQL)")
            }
        }
    }

    /// Remove object from database using key;
    ///
    /// - parameter forKey: Key of the object in database;
    ///
    /// - returns: Remove result;
    open func removeObject(forKey userKey: String) -> Bool {
        guard let jsonKey = self.jsonKey(forUserKey: userKey) else {
            return false
        }

        return self.removeJSONData(jsonKey: jsonKey)
    }

    /// Remove all objects from database;
    ///
    /// - returns: Remove result;
    open func clearAll() -> Bool {
        self.dbQueue = nil
        let result = FileManagerAide.removeItem(self.fileURL)
        self.dbQueue = FMDatabaseQueue.init(url: self.fileURL)
        return result
    }

    private func initDB() {
        let dirURL = self.fileURL.deletingLastPathComponent()
        let result = FileManagerAide.createDirIfNeeded(dirURL)
        if !result {
            print("[ERROR]: create database dir failed\nurl: \(self.fileURL)")
            return
        }

        guard let dbQueue = FMDatabaseQueue.init(url: self.fileURL) else {
            print("[ERROR]: create database failed\nurl: \(self.fileURL)")
            return
        }

        dbQueue.inDatabase { (database) in
            if let key = self.dbPasswordKey {
                database.setKey(key)
            }

            let createTableSQL = """
            CREATE TABLE IF NOT EXISTS \(kJSONTableName) (\(kJSONKeyColumnName) TEXT NOT NULL,
            \(kJSONDataColumnName) BLOB NOT NULL,
            \(kUpdateTimeColumnName) REAL NOT NULL,
            PRIMARY KEY(\(kJSONKeyColumnName)));
            """
            let result = database.executeUpdate(createTableSQL, withArgumentsIn: [])
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

        return SecurityAide.md5HashString(userKey)
    }

    private func readJSONData(jsonKey: String) -> Data? {
        var jsonData: Data?

        self.dbQueue?.inDatabase { (database) in
            let querySQL = "SELECT * FROM \(kJSONTableName) WHERE \(kJSONKeyColumnName) = ? LIMIT 1;"

            guard let resultSet = database.executeQuery(querySQL, withArgumentsIn: [jsonKey]) else {
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

        self.dbQueue?.inDatabase { (database) in
            let updateTime = Date().timeIntervalSinceReferenceDate
//            print("write time \(updateTime)")
            let updateSQL = """
            REPLACE INTO \(kJSONTableName) (\(kJSONKeyColumnName),
            \(kJSONDataColumnName),
            \(kUpdateTimeColumnName)) VALUES (?, ?, ?);
            """
            result = database.executeUpdate(updateSQL, withArgumentsIn: [jsonKey, jsonData, updateTime])
            if !result {
                print("[ERROR]: SQL = \(updateSQL)")
            }
        }

        return result
    }

    private func removeJSONData(jsonKey: String) -> Bool {
        var result = false

        self.dbQueue?.inDatabase { (database) in
            let deleteSQL = "DELETE FROM \(kJSONTableName) WHERE \(kJSONKeyColumnName) = ?;"
            result = database.executeUpdate(deleteSQL, withArgumentsIn: [jsonKey])
            if !result {
                print("[ERROR]: SQL = \(deleteSQL)")
            }
        }

        return result
    }
}
