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

private let kDefaultTableName = "cico_default_kv_table"

///
/// Key-Value database service;
///
/// You can save any object that conform to codable protocol using string key;
///
open class KVDBService {
    public let fileURL: URL

    private let dbPasswordKey: String?
    private var dbQueue: FMDatabaseQueue?
    private var kvTableService: KVTableService!

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
    public init(fileURL: URL, password: String? = kCICOKVDBDefaultPassword, customTableName: String? = nil) {
        self.fileURL = fileURL

        if let password = password {
            self.dbPasswordKey = SecurityAide.md5HashString(password)
        } else {
            self.dbPasswordKey = nil
        }

        let tableName: String
        if let customTableName = customTableName {
            tableName = customTableName
        } else {
            tableName = kDefaultTableName
        }
        self.kvTableService = KVTableService.init(tableName: tableName)

        self.initDB()
    }

    /// Read object from database using key;
    ///
    /// - parameter objectType: Type of the object, it must conform to codable protocol;
    /// - parameter forKey: Key of the object in database;
    ///
    /// - returns: Read object, nil when no object for this key;
    open func readObject<T: Codable>(_ objectType: T.Type, forKey userKey: String) -> T? {
        return self.kvTableService.readObject(dbQueue: self.dbQueue, objectType: objectType, userKey: userKey)
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
        return self.kvTableService.writeObject(dbQueue: self.dbQueue, object: object, userKey: userKey)
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
        self.kvTableService.updateObject(dbQueue: self.dbQueue,
                                       objectType: objectType,
                                       userKey: userKey,
                                       updateClosure: updateClosure,
                                       completionClosure: completionClosure)
    }

    /// Remove object from database using key;
    ///
    /// - parameter forKey: Key of the object in database;
    ///
    /// - returns: Remove result;
    open func removeObject(forKey userKey: String) -> Bool {
        return self.kvTableService.removeObject(dbQueue: self.dbQueue, userKey: userKey)
    }

    /// Remove all objects from database;
    ///
    /// - returns: Remove result;
    open func clearAll() -> Bool {
        return self.kvTableService.clearAll(dbQueue: self.dbQueue)
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

            let result = self.kvTableService.createTableIfNotExists(database: database)

            if result {
                self.dbQueue = dbQueue
            } else {
                print("[ERROR]: Init KVDBService failed.")
            }
        }
    }
}
