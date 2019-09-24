//
//  SQLCipherAide.swift
//  CICOPersistent
//
//  Created by lucky.li on 2019/9/19.
//  Copyright © 2019 cico. All rights reserved.
//

import Foundation
import SQLCipher

public enum SQLCipherError: Int, Error {
    case openFailed
    case invalidKey
    case attachFailed
    case exportFailed
    case detachFailed
}

public class SQLCipherAide {
    /// Export database;
    ///
    /// - parameter fromDBPath: Source database path;
    /// - parameter fromDBPassword: Source database password, no password when nil;
    /// - parameter toDBPath: Destination database path;
    /// - parameter toDBPassword: Destination database password, no password when nil;
    ///
    /// - returns: Export result;
    public static func exportDatabase(fromDBPath: String,
                                      fromDBPassword: String?,
                                      toDBPath: String,
                                      toDBPassword: String?) -> Bool {
        var errorPtr: UnsafeMutablePointer<Int8>?

        do {
            var result: Int32 = -1

            var fromDB: OpaquePointer?

            fromDBPath.withCString { (ptr) -> Void in
                result = sqlite3_open(ptr, &fromDB)
            }

            defer {
                sqlite3_close(fromDB)
            }

            guard result == SQLITE_OK else {
                throw SQLCipherError.openFailed
            }

            if let keyData = fromDBPassword?.data(using: .utf8) {
                try keyData.withUnsafeBytesBaseAddress { (ptr, count) in
                    result = sqlite3_key(fromDB, ptr, Int32(count))
                }

                guard result == SQLITE_OK else {
                    throw SQLCipherError.invalidKey
                }
            }

            let toDBName = "toDB"

            let toPassword: String = toDBPassword ?? ""
            let attachSQL: String = "ATTACH DATABASE '\(toDBPath)' AS \(toDBName) KEY '\(toPassword)';"

            attachSQL.withCString { (ptr) -> Void in
                result = sqlite3_exec(fromDB, ptr, nil, nil, &errorPtr)
            }

            guard result == SQLITE_OK else {
                throw SQLCipherError.attachFailed
            }

            let exportSQL: String = "SELECT sqlcipher_export('\(toDBName)');"

            exportSQL.withCString { (ptr) -> Void in
                result = sqlite3_exec(fromDB, ptr, nil, nil, &errorPtr)
            }

            guard result == SQLITE_OK else {
                throw SQLCipherError.exportFailed
            }

            let detachSQL: String = "DETACH DATABASE '\(toDBName)';"

            detachSQL.withCString { (ptr) -> Void in
                result = sqlite3_exec(fromDB, ptr, nil, nil, &errorPtr)
            }

            guard result == SQLITE_OK else {
                throw SQLCipherError.detachFailed
            }

            return true
        } catch {
            if let errorPtr = errorPtr {
                let message = """
                [ERROR]: Export database failed.
                error: \(error)
                error_message: \(String.init(cString: errorPtr))
                """
                print(message)
            } else {
                print("[ERROR]: Export database failed.\nerror: \(error)")
            }
            return false
        }
    }

    /// Encrypt passwordless database;
    ///
    /// - parameter dbPath: Passwordless database path;
    /// - parameter password: Database encryption password;
    ///
    /// - returns: Encrypt result;
    public static func encryptDatabase(dbPath: String, password: String) -> Bool {
        var result = false

        let tmpDBPath = "\(dbPath).tmp.db"

        result = self.exportDatabase(fromDBPath: dbPath,
                                     fromDBPassword: nil,
                                     toDBPath: tmpDBPath,
                                     toDBPassword: password)
        guard result else {
            return result
        }

        result = FileManagerAide.removeItem(dbPath)
        guard result else {
            return result
        }

        result = FileManagerAide.moveItem(from: tmpDBPath, to: dbPath)
        guard result else {
            return result
        }

        return result
    }

    /// Decrypt encrypted database into passwordless;
    ///
    /// - parameter dbPath: Encrypted database path;
    /// - parameter password: Encrypted database password;
    ///
    /// - returns: Decrypt result;
    public static func decryptDatabase(dbPath: String, password: String) -> Bool {
        var result = false

        let tmpDBPath = "\(dbPath).tmp.db"

        result = self.exportDatabase(fromDBPath: dbPath,
                                     fromDBPassword: password,
                                     toDBPath: tmpDBPath,
                                     toDBPassword: nil)
        guard result else {
            return result
        }

        result = FileManagerAide.removeItem(dbPath)
        guard result else {
            return result
        }

        result = FileManagerAide.moveItem(from: tmpDBPath, to: dbPath)
        guard result else {
            return result
        }

        return result
    }

    /// Change encrypted database password;
    ///
    /// - parameter dbPath: Encrypted database path;
    /// - parameter originalPassword: Original password for encrypted database;
    /// - parameter newPassword: New password for encrypted database;
    ///
    /// - returns: Change password result;
    public static func changeDatabasePassword(dbPath: String, originalPassword: String, newPassword: String) -> Bool {
        do {
            var result: Int32 = -1

            var database: OpaquePointer?

            dbPath.withCString { (ptr) -> Void in
                result = sqlite3_open(ptr, &database)
            }

            defer {
                sqlite3_close(database)
            }

            guard result == SQLITE_OK else {
                throw SQLCipherError.openFailed
            }

            if let keyData = originalPassword.data(using: .utf8) {
                try keyData.withUnsafeBytesBaseAddress { (ptr, count) in
                    result = sqlite3_key(database, ptr, Int32(count))
                }

                guard result == SQLITE_OK else {
                    throw SQLCipherError.invalidKey
                }
            }

            if let newKeyData = newPassword.data(using: .utf8) {
                try newKeyData.withUnsafeBytesBaseAddress { (ptr, count) in
                    result = sqlite3_rekey(database, ptr, Int32(count))
                }

                guard result == SQLITE_OK else {
                    throw SQLCipherError.invalidKey
                }
            }

            return true
        } catch {
            print("[ERROR]: Export database failed.\nerror: \(error)")
            return false
        }
    }
}
