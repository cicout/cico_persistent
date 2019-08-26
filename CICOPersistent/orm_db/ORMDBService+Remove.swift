//
//  ORMDBService+Remove.swift
//  CICOPersistent
//
//  Created by lucky.li on 2019/8/26.
//  Copyright © 2019 cico. All rights reserved.
//

import Foundation
import FMDB

/// Remove function;
extension ORMDBService {
    /// Remove object from database using primary key;
    ///
    /// - parameter objectType: Type of the object, it must conform to codable protocol;
    /// - parameter primaryKeyValue: Primary key value of the object in database, it must conform to codable protocol;
    /// - parameter customTableName: One class or struct can be saved in different tables,
    ///             you can define your custom table name here;
    ///             It will use default table name according to the class or struct name when passing nil;
    ///
    /// - returns: Remove result;
    open func removeObject<T: CICOORMCodableProtocol>(ofType objectType: T.Type,
                                                      primaryKeyValue: Codable,
                                                      customTableName: String? = nil) -> Bool {
        let tableName = ORMDBServiceInnerAide.tableName(objectType: objectType, customTableName: customTableName)
        let primaryKeyColumnName = T.cicoORMPrimaryKeyColumnName()
        let objectTypeName = "\(objectType)"

        var result = false

        self.dbQueue?.inTransaction({ (database, rollback) in
            guard ORMTableInfoAide.isTableExist(database: database,
                                                objectTypeName: objectTypeName,
                                                tableName: tableName) else {
                                                    result = true
                                                    return
            }

            result = ORMDBServiceInnerAide.deleteRecord(database: database,
                                                        tableName: tableName,
                                                        primaryKeyColumnName: primaryKeyColumnName,
                                                        primaryKeyValue: primaryKeyValue)
            if !result {
                rollback.pointee = true
                return
            }
        })

        return result
    }

    /// Remove the whole table from database by table name;
    ///
    /// - parameter objectType: Type of the object, it must conform to codable protocol;
    /// - parameter customTableName: One class or struct can be saved in different tables,
    ///             you can define your custom table name here;
    ///             It will use default table name according to the class or struct name when passing nil;
    ///
    /// - returns: Remove result;
    open func removeObjectTable<T: CICOORMCodableProtocol>(ofType objectType: T.Type,
                                                           customTableName: String? = nil) -> Bool {
        let tableName = ORMDBServiceInnerAide.tableName(objectType: objectType, customTableName: customTableName)
        let objectTypeName = "\(objectType)"

        var result = false

        self.dbQueue?.inTransaction({ (database, rollback) in
            guard ORMTableInfoAide.isTableExist(database: database,
                                                objectTypeName: objectTypeName,
                                                tableName: tableName) else {
                                                    result = true
                                                    return
            }

            result = ORMDBServiceInnerAide.dropTable(database: database, tableName: tableName)
            if !result {
                rollback.pointee = true
                return
            }

            result = ORMTableInfoAide.removeORMTableInfo(database: database, tableName: tableName)
            if !result {
                rollback.pointee = true
                return
            }
        })

        return result
    }
}
