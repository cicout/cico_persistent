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

///
/// Key-Value database service;
///
/// You can save any object that conform to codable protocol using string key;
///
open class KVDBService {
    public let fileURL: URL

    private let dbPasswordKey: String?
    private var dbQueue: FMDatabaseQueue?
    private var tableService: KVTableService!

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
        var object: T?

        self.dbQueue?.inDatabase({ (database) in
            object = self.tableService.readObject(database: database, objectType: objectType, userKey: userKey)
        })

        return object
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
        var result = false

        self.dbQueue?.inTransaction({ (database, rollback) in
            result = self.tableService.writeObject(database: database, object: object, userKey: userKey)
            if !result {
                rollback.pointee = true
            }
        })

        return result
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
        self.dbQueue?.inTransaction({ (database, rollback) in
            let result = self.tableService.updateObject(database: database,
                                                        objectType: objectType,
                                                        userKey: userKey,
                                                        updateClosure: updateClosure)

            if !result {
                rollback.pointee = true
            }

            completionClosure?(result)
        })
    }

    /// Remove object from database using key;
    ///
    /// - parameter forKey: Key of the object in database;
    ///
    /// - returns: Remove result;
    open func removeObject(forKey userKey: String) -> Bool {
        var result = false

        self.dbQueue?.inDatabase { (database) in
            result = self.tableService.removeObject(database: database, userKey: userKey)
        }

        return result
    }

    /// Remove all objects from database;
    ///
    /// - returns: Remove result;
    open func clearAll() -> Bool {
        var result = false

        self.dbQueue?.inDatabase { (database) in
            result = self.tableService.clearAll(database: database)
        }

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

            let tableService = KVTableService.init(tableName: kJSONTableName)

            let result = tableService.createTableIfNotExists(database: database)

            if result {
                self.dbQueue = dbQueue
                self.tableService = tableService
            } else {
                print("[ERROR]: Init KVDBService failed.")
            }
        }
    }
}
