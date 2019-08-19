//
//  DBSecurityAide.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/11/29.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

public class DBSecurityAide {
    /// Export database;
    ///
    /// - parameter fromDBPath: Source database path;
    /// - parameter fromDBPassword: Source database password, no password when nil;
    ///             The password will be transfered to md5 hash for KVDBService/ORMDBService using;
    /// - parameter toDBPath: Destination database path;
    /// - parameter toDBPassword: Destination database password, no password when nil;
    ///             The password will be transfered to md5 hash for KVDBService/ORMDBService using;
    ///
    /// - returns: Export result;
    static public func exportDatabase(fromDBPath: String,
                                      fromDBPassword: String?,
                                      toDBPath: String,
                                      toDBPassword: String?) -> Bool {
        var realFromPassword: String?
        if let fromDBPassword = fromDBPassword {
            realFromPassword = CICOSecurityAide.md5HashString(with: fromDBPassword)
        }

        var realToPassword: String?
        if let toDBPassword = toDBPassword {
            realToPassword = CICOSecurityAide.md5HashString(with: toDBPassword)
        }

        let result = CICOSQLCipherAide.exportDatabase(fromDBPath,
                                                      fromDBPassword: realFromPassword,
                                                      toDBPath: toDBPath,
                                                      toDBPassword: realToPassword)

        return result
    }

    /// Encrypt passwordless database;
    ///
    /// - parameter dbPath: Passwordless database path;
    /// - parameter password: Database encryption password;
    ///             The password will be transfered to md5 hash for KVDBService/ORMDBService using;
    ///
    /// - returns: Encrypt result;
    static public func encryptDatabase(dbPath: String, password: String) -> Bool {
        let realPassword = CICOSecurityAide.md5HashString(with: password)
        let result = CICOSQLCipherAide.encryptDatabase(dbPath, password: realPassword)
        return result
    }

    /// Decrypt encrypted database into passwordless;
    ///
    /// - parameter dbPath: Encrypted database path;
    /// - parameter password: Encrypted database password;
    ///             The password will be transfered to md5 hash for KVDBService/ORMDBService using;
    ///
    /// - returns: Decrypt result;
    static public func decryptDatabase(dbPath: String, password: String) -> Bool {
        let realPassword = CICOSecurityAide.md5HashString(with: password)
        let result = CICOSQLCipherAide.decryptDatabase(dbPath, password: realPassword)
        return result
    }

    /// Change encrypted database password;
    ///
    /// - parameter dbPath: Encrypted database path;
    /// - parameter originalPassword: Original password for encrypted database;
    ///             The password will be transfered to md5 hash for KVDBService/ORMDBService using;
    /// - parameter newPassword: New password for encrypted database;
    ///             The password will be transfered to md5 hash for KVDBService/ORMDBService using;
    ///
    /// - returns: Change password result;
    static public func changeDatabasePassword(dbPath: String, originalPassword: String, newPassword: String) -> Bool {
        let realOriginalPassword = CICOSecurityAide.md5HashString(with: originalPassword)
        let realNewPassword = CICOSecurityAide.md5HashString(with: newPassword)
        let result = CICOSQLCipherAide.changeDatabasePassword(dbPath,
                                                              originalPassword: realOriginalPassword,
                                                              newPassword: realNewPassword)
        return result
    }
}
