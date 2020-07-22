//
//  DBSecurityAide.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/11/29.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation
import CICOFoundationKit

public class DBSecurityAide {
    /// Export database;
    ///
    /// - parameter fromDBPath: Source database path;
    /// - parameter fromDBPassword: Source database password, no password when nil;
    ///             The password will be transfered to md5 hash;
    /// - parameter toDBPath: Destination database path;
    /// - parameter toDBPassword: Destination database password, no password when nil;
    ///             The password will be transfered to md5 hash;
    ///
    /// - returns: Export result;
    public static func exportDatabase(fromDBPath: String,
                                      fromDBPassword: String?,
                                      toDBPath: String,
                                      toDBPassword: String?) -> Bool {
        var realFromPassword: String?
        if let fromDBPassword = fromDBPassword {
            realFromPassword = SecurityAide.md5HashString(fromDBPassword)
        }

        var realToPassword: String?
        if let toDBPassword = toDBPassword {
            realToPassword = SecurityAide.md5HashString(toDBPassword)
        }

        let result = SQLCipherAide.exportDatabase(fromDBPath: fromDBPath,
                                                  fromDBPassword: realFromPassword,
                                                  toDBPath: toDBPath,
                                                  toDBPassword: realToPassword)

        return result
    }

    /// Encrypt passwordless database;
    ///
    /// - parameter dbPath: Passwordless database path;
    /// - parameter password: Database encryption password;
    ///             The password will be transfered to md5 hash;
    ///
    /// - returns: Encrypt result;
    public static func encryptDatabase(dbPath: String, password: String) -> Bool {
        let realPassword = SecurityAide.md5HashString(password)
        let result = SQLCipherAide.encryptDatabase(dbPath: dbPath, password: realPassword)
        return result
    }

    /// Decrypt encrypted database into passwordless;
    ///
    /// - parameter dbPath: Encrypted database path;
    /// - parameter password: Encrypted database password;
    ///             The password will be transfered to md5 hash;
    ///
    /// - returns: Decrypt result;
    public static func decryptDatabase(dbPath: String, password: String) -> Bool {
        let realPassword = SecurityAide.md5HashString(password)
        let result = SQLCipherAide.decryptDatabase(dbPath: dbPath, password: realPassword)
        return result
    }

    /// Change encrypted database password;
    ///
    /// - parameter dbPath: Encrypted database path;
    /// - parameter originalPassword: Original password for encrypted database;
    ///             The password will be transfered to md5 hash;
    /// - parameter newPassword: New password for encrypted database;
    ///             The password will be transfered to md5 hash;
    ///
    /// - returns: Change password result;
    public static func changeDatabasePassword(dbPath: String, originalPassword: String, newPassword: String) -> Bool {
        let realOriginalPassword = SecurityAide.md5HashString(originalPassword)
        let realNewPassword = SecurityAide.md5HashString(newPassword)
        let result = SQLCipherAide.changeDatabasePassword(dbPath: dbPath,
                                                          originalPassword: realOriginalPassword,
                                                          newPassword: realNewPassword)
        return result
    }
}
