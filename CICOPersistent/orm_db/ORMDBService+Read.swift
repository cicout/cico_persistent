//
//  ORMDBService+Read.swift
//  CICOPersistent
//
//  Created by lucky.li on 2019/8/26.
//  Copyright © 2019 cico. All rights reserved.
//

import Foundation
import FMDB

/// Read function;
extension ORMDBService {
    /// Read object from database using primary key;
    ///
    /// - parameter objectType: Type of the object, it must conform to codable protocol and ORMProtocol;
    /// - parameter primaryKeyValue: Primary key value of the object in database, it must conform to codable protocol;
    /// - parameter customTableName: One class or struct can be saved in different tables,
    ///             you can define your custom table name here;
    ///             It will use default table name according to the class or struct name when passing nil;
    ///
    /// - returns: Read object, nil when no object for this primary key;
    public func readObject<T: ORMCodableProtocol, K>(ofType objectType: T.Type = T.self,
                                                     primaryKeyValue: CompositeType<K>,
                                                     customTableName: String? = nil) -> T? {
        let tableName = ORMDBServiceInnerAide.tableName(objectType: objectType, customTableName: customTableName)
        let primaryKeyColumnName = T.ormPrimaryKeyColumnName()
        let objectTypeName = "\(objectType)"

        var object: T?

        self.dbQueue?.inTransaction({ (database, _) in
            guard ORMTableInfoAide.isTableExist(database: database,
                                                objectTypeName: objectTypeName,
                                                tableName: tableName) else {
                return
            }

            object = ORMDBServiceInnerAide.readObject(database: database,
                                                      objectType: objectType,
                                                      tableName: tableName,
                                                      primaryKeyColumnName: primaryKeyColumnName,
                                                      primaryKeyValue: primaryKeyValue)
        })

        return object
    }

    /// Read object array from database using SQL;
    ///
    /// SQL: SELECT * FROM "TableName" WHERE "whereString" ORDER BY "orderByName" DESC/ASC LIMIT "limit";
    ///
    /// - parameter objectType: Type of the object, it must conform to codable protocol and ORMProtocol;
    /// - parameter whereString: Where string for SQL;
    /// - parameter orderByName: Order by name for SQL;
    /// - parameter customTableName: One class or struct can be saved in different tables,
    ///             you can define your custom table name here;
    ///             It will use default table name according to the class or struct name when passing nil;
    ///
    /// - returns: Read object, nil when no object for this primary key;
    public func readObjects<T: ORMCodableProtocol>(ofType objectType: T.Type = T.self,
                                                   whereString: String? = nil,
                                                   orderByName: String? = nil,
                                                   descending: Bool = true,
                                                   limit: Int? = nil,
                                                   customTableName: String? = nil) -> [T] {
        let tableName = ORMDBServiceInnerAide.tableName(objectType: objectType, customTableName: customTableName)
        let objectTypeName = "\(objectType)"

        var array = [T]()

        self.dbQueue?.inTransaction({ (database, _) in
            guard ORMTableInfoAide.isTableExist(database: database,
                                                objectTypeName: objectTypeName,
                                                tableName: tableName) else {
                return
            }

            array = ORMDBServiceInnerAide.readObjects(database: database,
                                                      objectType: objectType,
                                                      tableName: tableName,
                                                      whereString: whereString,
                                                      orderByName: orderByName,
                                                      descending: descending,
                                                      limit: limit)
        })

        return array
    }

    /// Read object array from database using SQL;
    ///
    /// - parameter objectType: Type of the object, it must conform to codable protocol and ORMProtocol;
    /// - parameter sqlString: SQL string;
    /// - parameter customTableName: One class or struct can be saved in different tables,
    ///             you can define your custom table name here;
    ///             It will use default table name according to the class or struct name when passing nil;
    ///
    /// - returns: Read object, nil when no object for this primary key;
    public func readObjects<T: ORMCodableProtocol>(ofType objectType: T.Type = T.self,
                                                   sqlString: String,
                                                   arguments: [Any] = [],
                                                   customTableName: String? = nil) -> [T] {
        let tableName = ORMDBServiceInnerAide.tableName(objectType: objectType, customTableName: customTableName)
        let objectTypeName = "\(objectType)"

        var array = [T]()

        self.dbQueue?.inTransaction({ (database, _) in
            guard ORMTableInfoAide.isTableExist(database: database,
                                                objectTypeName: objectTypeName,
                                                tableName: tableName) else {
                return
            }

            array = ORMDBServiceInnerAide.readObjects(database: database,
                                                      sqlString: sqlString,
                                                      arguments: arguments)
        })

        return array
    }
}
