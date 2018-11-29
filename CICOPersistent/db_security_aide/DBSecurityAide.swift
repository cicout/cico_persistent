//
//  DBSecurityAide.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/11/29.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

public class DBSecurityAide {
    static public func exportDatabase(fromDBPath: String,
                                      fromDBPassword: String?,
                                      toDBPath: String,
                                      toDBPassword: String?) -> Bool {
        var realFromPassword: String? = nil
        if let fromDBPassword = fromDBPassword {
            realFromPassword = CICOSecurityAide.md5HashString(with: fromDBPassword)
        }
        
        var realToPassword: String? = nil
        if let toDBPassword = toDBPassword {
            realToPassword = CICOSecurityAide.md5HashString(with: toDBPassword)
        }
        
        let result = CICOSQLCipherAide.exportDatabase(fromDBPath,
                                                      fromDBPassword: realFromPassword,
                                                      toDBPath: toDBPath,
                                                      toDBPassword: realToPassword)
        
        return result
    }
    
    static public func encryptDatabase(dbPath: String, password: String) -> Bool {
        let realPassword = CICOSecurityAide.md5HashString(with: password)
        let result = CICOSQLCipherAide.encryptDatabase(dbPath, password: realPassword)
        return result
    }
    
    static public func decryptDatabase(dbPath: String, password: String) -> Bool {
        let realPassword = CICOSecurityAide.md5HashString(with: password)
        let result = CICOSQLCipherAide.decryptDatabase(dbPath, password: realPassword)
        return result
    }
    
    static public func changeDatabasePassword(dbPath: String, originalPassword: String, newPassword: String) -> Bool {
        let realOriginalPassword = CICOSecurityAide.md5HashString(with: originalPassword)
        let realNewPassword = CICOSecurityAide.md5HashString(with: newPassword)
        let result = CICOSQLCipherAide.changeDatabasePassword(dbPath,
                                                              originalPassword: realOriginalPassword,
                                                              newPassword: realNewPassword)
        return result
    }
}
