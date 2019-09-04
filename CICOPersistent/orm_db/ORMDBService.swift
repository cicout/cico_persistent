//
//  CICOORMDBService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/6/22.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation
import FMDB

public let kCICOORMDBDefaultPassword = "cico_orm_db_default_password"

///
/// ORM database service;
///
/// You can save any object that conform to codable protocol and ORMProtocol;
///
open class ORMDBService {
    public let fileURL: URL

    private(set) var dbQueue: FMDatabaseQueue?

    private let dbPasswordKey: String?

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
    public init(fileURL: URL, password: String? = kCICOORMDBDefaultPassword) {
        self.fileURL = fileURL
        if let password = password {
            self.dbPasswordKey = CICOSecurityAide.md5HashString(with: password)
        } else {
            self.dbPasswordKey = nil
        }
        self.initDB()
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

extension ORMDBService {
    /// Remove all tables from database;
    ///
    /// - returns: Remove result;
    open func clearAll() -> Bool {
        self.dbQueue = nil
        let result = FileManagerAide.removeItem(self.fileURL)
        self.dbQueue = FMDatabaseQueue.init(url: self.fileURL)
        return result
    }
}
