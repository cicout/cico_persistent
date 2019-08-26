//
//  CICOORMDBService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/6/22.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation
import FMDB
import CICOAutoCodable

public let kCICOORMDBDefaultPassword = "cico_orm_db_default_password"

private let kORMTableName = "cico_orm_table_info"

///
/// ORM database service;
///
/// You can save any object that conform to codable protocol and ORMProtocol;
///
open class ORMDBService {
    public let fileURL: URL

    private let dbPasswordKey: String?
    private var dbQueue: FMDatabaseQueue?

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
        let result = CICOFileManagerAide.createDir(with: dirURL)
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

            let result = self.createORMTableInfoTableIfNotExists(database: database)
            if result {
                self.dbQueue = dbQueue
            }
        }
    }
}

/// Public function;
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
    open func readObject<T: CICOORMCodableProtocol>(ofType objectType: T.Type,
                                                    primaryKeyValue: Codable,
                                                    customTableName: String? = nil) -> T? {
        let tableName = ORMDBServiceInnerAide.tableName(objectType: objectType, customTableName: customTableName)
        let primaryKeyColumnName = T.cicoORMPrimaryKeyColumnName()
        let objectTypeName = "\(objectType)"

        var object: T?

        self.dbQueue?.inTransaction({ (database, _) in
            guard self.isTableExist(database: database, objectTypeName: objectTypeName, tableName: tableName) else {
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
    open func readObjectArray<T: CICOORMCodableProtocol>(ofType objectType: T.Type,
                                                         whereString: String? = nil,
                                                         orderByName: String? = nil,
                                                         descending: Bool = true,
                                                         limit: Int? = nil,
                                                         customTableName: String? = nil) -> [T]? {
        let tableName = ORMDBServiceInnerAide.tableName(objectType: objectType, customTableName: customTableName)
        let objectTypeName = "\(objectType)"

        var array: [T]?

        self.dbQueue?.inTransaction({ (database, _) in
            guard self.isTableExist(database: database, objectTypeName: objectTypeName, tableName: tableName) else {
                return
            }

            array = ORMDBServiceInnerAide.readObjectArray(database: database,
                                                          objectType: objectType,
                                                          tableName: tableName,
                                                          whereString: whereString,
                                                          orderByName: orderByName,
                                                          descending: descending,
                                                          limit: limit)
        })

        return array
    }

    /// Write object into database using primary key;
    ///
    /// Add when it does not exist, update when it exists;
    ///
    /// - parameter object: The object will be saved in database, it must conform to codable protocol and ORMProtocol;
    /// - parameter customTableName: One class or struct can be saved in different tables,
    ///             you can define your custom table name here;
    ///             It will use default table name according to the class or struct name when passing nil;
    ///
    /// - returns: Write result;
    open func writeObject<T: CICOORMCodableProtocol>(_ object: T, customTableName: String? = nil) -> Bool {
        let tableName = ORMDBServiceInnerAide.tableName(objectType: T.self, customTableName: customTableName)
        let primaryKeyColumnName = T.cicoORMPrimaryKeyColumnName()
        let indexColumnNameArray = T.cicoORMIndexColumnNameArray()
        let objectTypeVersion = T.cicoORMObjectTypeVersion()
        let objectType = T.self

        var result = false

        self.dbQueue?.inTransaction({ (database, rollback) in
            // create table if not exist and upgrade table if needed;
            let paramConfig = ParamConfigModel.init(tableName: tableName,
                                                    primaryKeyColumnName: primaryKeyColumnName,
                                                    indexColumnNameArray: indexColumnNameArray,
                                                    objectTypeVersion: objectTypeVersion)
            let isTableReady =
                self.createAndUpgradeTableIfNeeded(database: database,
                                                   objectType: objectType,
                                                   paramConfig: paramConfig)

            if !isTableReady {
                rollback.pointee = true
                return
            }

            // replace table record;
            result = ORMDBServiceInnerAide.replaceRecord(database: database, tableName: tableName, object: object)
            if !result {
                rollback.pointee = true
                return
            }
        })

        return result
    }

    /// Write object array into database using primary key in one transaction;
    ///
    /// Add when it does not exist, update when it exists;
    ///
    /// - parameter objectArray: The object array will be saved in database,
    ///             it must conform to codable protocol and ORMProtocol;
    /// - parameter customTableName: One class or struct can be saved in different tables,
    ///             you can define your custom table name here;
    ///             It will use default table name according to the class or struct name when passing nil;
    ///
    /// - returns: Write result;
    open func writeObjectArray<T: CICOORMCodableProtocol>(_ objectArray: [T], customTableName: String? = nil) -> Bool {
        let tableName = ORMDBServiceInnerAide.tableName(objectType: T.self, customTableName: customTableName)
        let primaryKeyColumnName = T.cicoORMPrimaryKeyColumnName()
        let indexColumnNameArray = T.cicoORMIndexColumnNameArray()
        let objectTypeVersion = T.cicoORMObjectTypeVersion()
        let objectType = T.self

        var result = false

        self.dbQueue?.inTransaction({ (database, rollback) in
            // create table if not exist and upgrade table if needed;
            let paramConfig = ParamConfigModel.init(tableName: tableName,
                                                    primaryKeyColumnName: primaryKeyColumnName,
                                                    indexColumnNameArray: indexColumnNameArray,
                                                    objectTypeVersion: objectTypeVersion)
            let isTableReady =
                self.createAndUpgradeTableIfNeeded(database: database,
                                                   objectType: objectType,
                                                   paramConfig: paramConfig)

            if !isTableReady {
                rollback.pointee = true
                return
            }

            for object in objectArray {
                // replace table record;
                result = ORMDBServiceInnerAide.replaceRecord(database: database, tableName: tableName, object: object)
                if !result {
                    rollback.pointee = true
                    return
                }
            }
        })

        return result
    }

    /// Update object in database using primary key;
    ///
    /// Read the existing object, then call the "updateClosure", and write the object returned by "updateClosure";
    /// It won't update when "updateClosure" returns nil;
    ///
    /// - parameter objectType: Type of the object, it must conform to codable protocol;
    /// - parameter primaryKeyValue: Primary key value of the object in database, it must conform to codable protocol;
    /// - parameter customTableName: One class or struct can be saved in different tables,
    ///             you can define your custom table name here;
    ///             It will use default table name according to the class or struct name when passing nil;
    /// - parameter updateClosure: It will be called after reading object from database,
    ///             the read object will be passed as parameter, you can return a new value to update in database;
    ///             It won't be updated to database when you return nil by this closure;
    /// - parameter completionClosure: It will be called when completed, passing update result as parameter;
    open func updateObject<T: CICOORMCodableProtocol>(ofType objectType: T.Type,
                                                      primaryKeyValue: Codable,
                                                      customTableName: String? = nil,
                                                      updateClosure: (T?) -> T?,
                                                      completionClosure: ((Bool) -> Void)? = nil) {
        let tableName = ORMDBServiceInnerAide.tableName(objectType: objectType, customTableName: customTableName)
        let primaryKeyColumnName = T.cicoORMPrimaryKeyColumnName()
        let indexColumnNameArray = T.cicoORMIndexColumnNameArray()
        let objectTypeVersion = T.cicoORMObjectTypeVersion()
        let objectTypeName = "\(objectType)"

        var result = false
        defer {
            completionClosure?(result)
        }

        self.dbQueue?.inTransaction({ (database, rollback) in
            var object: T?

            if self.isTableExist(database: database,
                                 objectTypeName: objectTypeName,
                                 tableName: tableName) {
                object = ORMDBServiceInnerAide.readObject(database: database,
                                                          objectType: objectType,
                                                          tableName: tableName,
                                                          primaryKeyColumnName: primaryKeyColumnName,
                                                          primaryKeyValue: primaryKeyValue)
            }

            guard let newObject = updateClosure(object) else {
                result = true
                return
            }

            // create table if not exist and upgrade table if needed;
            let paramConfig = ParamConfigModel.init(tableName: tableName,
                                                    primaryKeyColumnName: primaryKeyColumnName,
                                                    indexColumnNameArray: indexColumnNameArray,
                                                    objectTypeVersion: objectTypeVersion)
            let isTableReady =
                self.createAndUpgradeTableIfNeeded(database: database,
                                                   objectType: objectType,
                                                   paramConfig: paramConfig)

            if !isTableReady {
                rollback.pointee = true
                return
            }

            result = ORMDBServiceInnerAide.replaceRecord(database: database,
                                                         tableName: tableName,
                                                         object: newObject)
            if !result {
                rollback.pointee = true
            }
        })
    }

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
            guard self.isTableExist(database: database, objectTypeName: objectTypeName, tableName: tableName) else {
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
            guard self.isTableExist(database: database, objectTypeName: objectTypeName, tableName: tableName) else {
                result = true
                return
            }

            result = ORMDBServiceInnerAide.dropTable(database: database, tableName: tableName)
            if !result {
                rollback.pointee = true
                return
            }

            result = self.removeORMTableInfo(database: database, tableName: tableName)
            if !result {
                rollback.pointee = true
                return
            }
        })

        return result
    }

    /// Remove all tables from database;
    ///
    /// - returns: Remove result;
    open func clearAll() -> Bool {
        self.dbQueue = nil
        let result = CICOFileManagerAide.removeFile(with: self.fileURL)
        self.dbQueue = FMDatabaseQueue.init(url: self.fileURL)
        return result
    }
}

/// Database common function;
extension ORMDBService {
    private func createTableAndIndexs<T: Codable>(database: FMDatabase,
                                                  objectType: T.Type,
                                                  paramConfig: ParamConfigModel) -> Bool {
        var result = false

        // create table;
        result = ORMDBServiceInnerAide.createTableIfNotExists(database: database,
                                                   objectType: objectType,
                                                   tableName: paramConfig.tableName,
                                                   primaryKeyColumnName: paramConfig.primaryKeyColumnName)
        if !result {
            return result
        }

        // create indexs;
        if let indexColumnNameArray = paramConfig.indexColumnNameArray {
            for indexColumnName in indexColumnNameArray {
                let indexName = ORMDBServiceInnerAide.indexName(indexColumnName: indexColumnName,
                                                                tableName: paramConfig.tableName)
                result = ORMDBServiceInnerAide.createIndex(database: database,
                                                           indexName: indexName,
                                                           tableName: paramConfig.tableName,
                                                           indexColumnName: indexColumnName)
                if !result {
                    return result
                }
            }
        }

        // save orm table info;
        let objectTypeName = "\(objectType)"
        let tableInfo = ORMTableInfoModel.init(tableName: paramConfig.tableName,
                                               objectTypeName: objectTypeName,
                                               objectTypeVersion: paramConfig.objectTypeVersion)
        result = self.writeORMTableInfo(database: database, tableInfo: tableInfo)

        return result
    }
}

/// ORMTableInfo;
extension ORMDBService {
    private func isTableExist(database: FMDatabase, objectTypeName: String, tableName: String) -> Bool {
        if self.readORMTableInfo(database: database, objectTypeName: objectTypeName, tableName: tableName) != nil {
            return true
        } else {
            return false
        }
    }

    private func createORMTableInfoTableIfNotExists(database: FMDatabase) -> Bool {
        let primaryKeyColumnName = ORMTableInfoModel.cicoORMPrimaryKeyColumnName()

        return ORMDBServiceInnerAide.createTableIfNotExists(database: database,
                                                            objectType: ORMTableInfoModel.self,
                                                            tableName: kORMTableName,
                                                            primaryKeyColumnName: primaryKeyColumnName)
    }

    private func readORMTableInfo(database: FMDatabase,
                                  objectTypeName: String,
                                  tableName: String) -> ORMTableInfoModel? {
        let primaryKeyColumnName = ORMTableInfoModel.cicoORMPrimaryKeyColumnName()

        guard let tableInfo = ORMDBServiceInnerAide.readObject(database: database,
                                                         objectType: ORMTableInfoModel.self,
                                                         tableName: kORMTableName,
                                                         primaryKeyColumnName: primaryKeyColumnName,
                                                         primaryKeyValue: tableName) else {
                                                            return nil
        }

        guard tableInfo.objectTypeName == objectTypeName else {
            return nil
        }

        return tableInfo
    }

    private func writeORMTableInfo(database: FMDatabase, tableInfo: ORMTableInfoModel) -> Bool {
        return ORMDBServiceInnerAide.replaceRecord(database: database,
                                                   tableName: kORMTableName,
                                                   object: tableInfo)
    }

    private func removeORMTableInfo(database: FMDatabase, tableName: String) -> Bool {
        let primaryKeyColumnName = ORMTableInfoModel.cicoORMPrimaryKeyColumnName()
        return ORMDBServiceInnerAide.deleteRecord(database: database,
                                                  tableName: kORMTableName,
                                                  primaryKeyColumnName: primaryKeyColumnName,
                                                  primaryKeyValue: tableName)
    }
}

/// Auto upgrade table;
extension ORMDBService {
    /// create table if not exist and upgrade table if needed;
    private func createAndUpgradeTableIfNeeded<T: Codable>(database: FMDatabase,
                                                           objectType: T.Type,
                                                           paramConfig: ParamConfigModel) -> Bool {
        var result = false

        let objectTypeName = "\(objectType)"

        guard let tableInfo = self.readORMTableInfo(database: database,
                                                    objectTypeName: objectTypeName,
                                                    tableName: paramConfig.tableName) else {
                                                        result = self.createTableAndIndexs(database: database,
                                                                                           objectType: objectType,
                                                                                           paramConfig: paramConfig)
                                                        return result
        }

        guard tableInfo.objectTypeVersion >= paramConfig.objectTypeVersion else {
            result = self.upgradeTableAndIndexs(database: database,
                                                objectType: objectType,
                                                tableName: paramConfig.tableName,
                                                indexColumnNameArray: paramConfig.indexColumnNameArray,
                                                objectTypeVersion: paramConfig.objectTypeVersion)

            return result
        }

        result = true

        return result
    }

    private func upgradeTableAndIndexs<T: Codable>(database: FMDatabase,
                                                   objectType: T.Type,
                                                   tableName: String,
                                                   indexColumnNameArray: [String]?,
                                                   objectTypeVersion: Int) -> Bool {
        var result = false

        // upgrade columns;
        result = ORMDBServiceInnerAide.upgradeTableColumn(database: database,
                                                          objectType: objectType,
                                                          tableName: tableName)
        if !result {
            return result
        }

        // upgrade indexs;
        result = ORMDBServiceInnerAide.upgradeTableIndex(database: database,
                                                         objectType: objectType,
                                                         tableName: tableName,
                                                         indexColumnNameArray: indexColumnNameArray)
        if !result {
            return result
        }

        // update objectTypeVersion;
        let objectTypeName = "\(objectType)"
        let newTableInfo = ORMTableInfoModel.init(tableName: tableName,
                                                  objectTypeName: objectTypeName,
                                                  objectTypeVersion: objectTypeVersion)
        result = self.writeORMTableInfo(database: database, tableInfo: newTableInfo)

        return result
    }
}
