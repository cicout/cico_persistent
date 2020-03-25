//
//  CICOORMDBService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/6/22.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation
import FMDB

/// Write function;
extension ORMDBService {
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
        let autoIncrement = T.cicoORMIntegerPrimaryKeyAutoIncrement()
        let objectType = T.self

        var result = false

        self.dbQueue?.inTransaction({ (database, rollback) in
            // create table if not exist and upgrade table if needed;
            let paramConfig = ParamConfigModel.init(tableName: tableName,
                                                    primaryKeyColumnName: primaryKeyColumnName,
                                                    indexColumnNameArray: indexColumnNameArray,
                                                    objectTypeVersion: objectTypeVersion,
                                                    autoIncrement: autoIncrement)
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
        let autoIncrement = T.cicoORMIntegerPrimaryKeyAutoIncrement()
        let objectType = T.self

        var result = false

        self.dbQueue?.inTransaction({ (database, rollback) in
            // create table if not exist and upgrade table if needed;
            let paramConfig = ParamConfigModel.init(tableName: tableName,
                                                    primaryKeyColumnName: primaryKeyColumnName,
                                                    indexColumnNameArray: indexColumnNameArray,
                                                    objectTypeVersion: objectTypeVersion,
                                                    autoIncrement: autoIncrement)
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
        let autoIncrement = T.cicoORMIntegerPrimaryKeyAutoIncrement()
        let objectTypeName = "\(objectType)"

        var result = false
        defer {
            completionClosure?(result)
        }

        self.dbQueue?.inTransaction({ (database, rollback) in
            var object: T?

            if ORMTableInfoAide.isTableExist(database: database,
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
                                                    objectTypeVersion: objectTypeVersion,
                                                    autoIncrement: autoIncrement)
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
}

/// Private function;
extension ORMDBService {
    /// create table if not exist and upgrade table if needed;
    private func createAndUpgradeTableIfNeeded<T: Codable>(database: FMDatabase,
                                                           objectType: T.Type,
                                                           paramConfig: ParamConfigModel) -> Bool {
        var result = false

        let objectTypeName = "\(objectType)"

        guard let tableInfo = ORMTableInfoAide.readORMTableInfo(database: database,
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

    private func createTableAndIndexs<T: Codable>(database: FMDatabase,
                                                  objectType: T.Type,
                                                  paramConfig: ParamConfigModel) -> Bool {
        var result = false

        // create table;
        result = ORMDBServiceInnerAide.createTableIfNotExists(database: database,
                                                              objectType: objectType,
                                                              tableName: paramConfig.tableName,
                                                              primaryKeyColumnName: paramConfig.primaryKeyColumnName,
                                                              autoIncrement: paramConfig.autoIncrement)
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
        result = ORMTableInfoAide.writeORMTableInfo(database: database, tableInfo: tableInfo)

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
        result = ORMTableInfoAide.writeORMTableInfo(database: database, tableInfo: newTableInfo)

        return result
    }
}
