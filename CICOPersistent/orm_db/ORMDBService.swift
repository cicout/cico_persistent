//
//  CICOORMDBService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/6/22.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation
import CICOFoundationKit
import FMDB

private let kDefaultKVTableName = "cico_default_kv_table"

///
/// ORM database service;
///
/// You can save any object that conform to codable protocol and ORMProtocol;
///
open class ORMDBService {
    public let fileURL: URL

    private(set) var dbQueue: FMDatabaseQueue?
    let kvTableService: KVTableService

    private let dbPasswordKey: String?

    deinit {
        print("\(self) deinit")
        self.dbQueue?.close()
    }

    /// Init with database file URL and database encryption password;
    ///
    /// - parameter fileURL: Database file URL;
    /// - parameter password: Database encryption password; Database won't be encrypted when password is nil;
    /// - parameter customKVTableName: Key-Value table name; It will use default table name when passing nil;
    ///
    /// - returns: Init object;
    public init(fileURL: URL, password: String? = nil, customKVTableName: String? = nil) {
        self.fileURL = fileURL

        if let password = password {
            self.dbPasswordKey = SecurityAide.md5HashString(password)
        } else {
            self.dbPasswordKey = nil
        }

        let tableName: String
        if let customTableName = customKVTableName {
            tableName = customTableName
        } else {
            tableName = kDefaultKVTableName
        }
        self.kvTableService = KVTableService.init(tableName: tableName)

        self.initDB()
    }

    /// Remove all tables from database;
    ///
    /// - returns: Remove result;
    open func clearAll() -> Bool {
        let result = FileManagerAide.removeItem(self.fileURL)
        self.dbQueue = nil
        self.initDB()
        return result
    }

    private func initDB() {
        let dirURL = self.fileURL.deletingLastPathComponent()
        let result = FileManagerAide.createDirIfNeeded(dirURL)
        if !result {
            print("[ERROR]: create database dir failed")
            return
        }

        guard let dbQueue = FMDatabaseQueue.init(url: self.fileURL) else {
            print("[ERROR]: create database failed")
            return
        }

        dbQueue.inDatabase { (database) in
            if let key = self.dbPasswordKey {
                database.setKey(key)
            }

            let result = ORMTableInfoAide.createORMTableInfoTableIfNotExists(database: database)
            if result {
                self.dbQueue = dbQueue
            }
        }
    }
}
