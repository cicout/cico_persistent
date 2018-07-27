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
import SwiftyJSON

private let kORMTableName = "cico_orm_table_info"
private let kTableNameColumnName = "table_name"
private let kObjectTypeNameColumnName = "object_type_name"
private let kObjectTypeVersionColumnName = "object_type_version"

open class CICOORMDBService {
    public let fileURL: URL
    
    private var dbQueue: FMDatabaseQueue?
    
    deinit {
        print("\(self) deinit")
        self.dbQueue?.close()
    }
    
    public init(fileURL: URL) {
        self.fileURL = fileURL
        self.initDB()
    }
    
    /*******************
     * PUBLIC FUNCTIONS
     *******************/
    
    open func readObject<T: CICOORMCodableProtocol>(ofType objectType: T.Type,
                                                    primaryKeyValue: Codable,
                                                    customTableName: String? = nil) -> T? {
        let tableName = self.tableName(objectType: objectType, customTableName: customTableName)
        let primaryKeyColumnName = T.cicoORMPrimaryKeyColumnName()
        
        return self.pReadObject(ofType: objectType,
                                tableName: tableName,
                                primaryKeyColumnName: primaryKeyColumnName,
                                primaryKeyValue: primaryKeyValue)
    }
    
    open func readObjectArray<T: CICOORMCodableProtocol>(ofType objectType: T.Type,
                                                         whereString: String? = nil,
                                                         orderByName: String? = nil,
                                                         descending: Bool = true,
                                                         limit: Int? = nil,
                                                         customTableName: String? = nil) -> [T]? {
        let tableName = self.tableName(objectType: objectType, customTableName: customTableName)
        
        return self.pReadObjectArray(ofType: objectType,
                                     tableName: tableName,
                                     whereString: whereString,
                                     orderByName: orderByName,
                                     descending: descending,
                                     limit: limit)
    }
    
    open func writeObject<T: CICOORMCodableProtocol>(_ object: T, customTableName: String? = nil) -> Bool {
        let tableName = self.tableName(objectType: T.self, customTableName: customTableName)
        let primaryKeyColumnName = T.cicoORMPrimaryKeyColumnName()
        let indexColumnNameArray = T.cicoORMIndexColumnNameArray()
        let objectTypeVersion = T.cicoORMObjectTypeVersion()
        
        return self.pWriteObject(object,
                                 tableName: tableName,
                                 primaryKeyColumnName: primaryKeyColumnName,
                                 indexColumnNameArray: indexColumnNameArray,
                                 objectTypeVersion: objectTypeVersion)
    }
    
    open func writeObjectArray<T: CICOORMCodableProtocol>(_ objectArray: [T], customTableName: String? = nil) -> Bool {
        let tableName = self.tableName(objectType: T.self, customTableName: customTableName)
        let primaryKeyColumnName = T.cicoORMPrimaryKeyColumnName()
        let indexColumnNameArray = T.cicoORMIndexColumnNameArray()
        let objectTypeVersion = T.cicoORMObjectTypeVersion()
        
        return self.pWriteObjectArray(objectArray,
                                      tableName: tableName,
                                      primaryKeyColumnName: primaryKeyColumnName,
                                      indexColumnNameArray: indexColumnNameArray,
                                      objectTypeVersion: objectTypeVersion)
    }
    
    open func updateObject<T: CICOORMCodableProtocol>(ofType objectType: T.Type,
                                                      primaryKeyValue: Codable,
                                                      customTableName: String? = nil,
                                                      updateClosure: (T?) -> T?,
                                                      completionClosure: ((Bool) -> Void)? = nil) {
        let tableName = self.tableName(objectType: objectType, customTableName: customTableName)
        let primaryKeyColumnName = T.cicoORMPrimaryKeyColumnName()
        let indexColumnNameArray = T.cicoORMIndexColumnNameArray()
        let objectTypeVersion = T.cicoORMObjectTypeVersion()
        
        self.pUpdateObject(ofType: objectType,
                           tableName: tableName,
                           primaryKeyColumnName: primaryKeyColumnName,
                           primaryKeyValue: primaryKeyValue,
                           indexColumnNameArray: indexColumnNameArray,
                           objectTypeVersion: objectTypeVersion,
                           updateClosure: updateClosure,
                           completionClosure: completionClosure)
    }
    
    open func removeObject<T: CICOORMCodableProtocol>(ofType objectType: T.Type,
                                                      primaryKeyValue: Codable,
                                                      customTableName: String? = nil) -> Bool {
        let tableName = self.tableName(objectType: objectType, customTableName: customTableName)
        let primaryKeyColumnName = T.cicoORMPrimaryKeyColumnName()
        
        return self.pRemoveObject(ofType: objectType,
                                  tableName: tableName,
                                  primaryKeyColumnName: primaryKeyColumnName,
                                  primaryKeyValue: primaryKeyValue)
    }
    
    open func removeObjectTable<T: CICOORMCodableProtocol>(ofType objectType: T.Type, customTableName: String? = nil) -> Bool {
        let tableName = self.tableName(objectType: objectType, customTableName: customTableName)
        
        return self.pRemoveObjectTable(ofType: objectType, tableName: tableName)
    }
    
    open func clearAll() -> Bool {
        self.dbQueue = nil
        let result = CICOPathAide.removeFile(with: self.fileURL)
        self.dbQueue = FMDatabaseQueue.init(url: self.fileURL)
        return result
    }
    
    /********************
     * PRIVATE FUNCTIONS
     ********************/
    
    private func pReadObject<T: Codable>(ofType objectType: T.Type,
                                         tableName: String,
                                         primaryKeyColumnName: String,
                                         primaryKeyValue: Codable) -> T? {
        var object: T? = nil
        
        let objectTypeName = "\(objectType)"
        
        self.dbQueue?.inTransaction({ (db, rollback) in
            guard self.isTableExist(db: db, objectTypeName: objectTypeName, tableName: tableName) else {
                return
            }
            
            object = self.readObject(db: db,
                                     objectType: objectType,
                                     tableName: tableName,
                                     primaryKeyColumnName: primaryKeyColumnName,
                                     primaryKeyValue: primaryKeyValue)
        })
        
        return object
    }
    
    private func pReadObjectArray<T: Codable>(ofType objectType: T.Type,
                                              tableName: String,
                                              whereString: String? = nil,
                                              orderByName: String? = nil,
                                              descending: Bool = true,
                                              limit: Int? = nil) -> [T]? {
        var array: [T]? = nil
        
        let objectTypeName = "\(objectType)"
        
        self.dbQueue?.inTransaction({ (db, rollback) in
            guard self.isTableExist(db: db, objectTypeName: objectTypeName, tableName: tableName) else {
                return
            }
            
            array = self.readObjectArray(db: db,
                                         objectType: objectType,
                                         tableName: tableName,
                                         whereString: whereString,
                                         orderByName: orderByName,
                                         descending: descending,
                                         limit: limit)
        })
        
        return array
    }
    
    private func pWriteObject<T: Codable>(_ object: T,
                                          tableName: String,
                                          primaryKeyColumnName: String,
                                          indexColumnNameArray: [String]?,
                                          objectTypeVersion: Int) -> Bool {
        var result = false
        
        let objectType = T.self
        
        self.dbQueue?.inTransaction({ (db, rollback) in
            // create table if not exist and upgrade table if needed
            let isTableReady =
                self.fixTableIfNeeded(db: db,
                                      objectType: objectType,
                                      tableName: tableName,
                                      primaryKeyColumnName: primaryKeyColumnName,
                                      indexColumnNameArray: indexColumnNameArray,
                                      objectTypeVersion: objectTypeVersion)
            
            if !isTableReady {
                rollback.pointee = true
                return
            }
            
            // replace table record
            result = self.replaceRecord(db: db, tableName: tableName, object: object)
            if !result {
                rollback.pointee = true
                return
            }
        })
        
        return result
    }
    
    private func pWriteObjectArray<T: Codable>(_ objectArray: [T],
                                               tableName: String,
                                               primaryKeyColumnName: String,
                                               indexColumnNameArray: [String]?,
                                               objectTypeVersion: Int) -> Bool {
        var result = false
        
        let objectType = T.self
        
        self.dbQueue?.inTransaction({ (db, rollback) in
            // create table if not exist and upgrade table if needed
            let isTableReady =
                self.fixTableIfNeeded(db: db,
                                      objectType: objectType,
                                      tableName: tableName,
                                      primaryKeyColumnName: primaryKeyColumnName,
                                      indexColumnNameArray: indexColumnNameArray,
                                      objectTypeVersion: objectTypeVersion)
            
            if !isTableReady {
                rollback.pointee = true
                return
            }
            
            for object in objectArray {
                // replace table record
                result = self.replaceRecord(db: db, tableName: tableName, object: object)
                if !result {
                    rollback.pointee = true
                    return
                }
            }
        })
        
        return result
    }
    
    private func pUpdateObject<T: Codable>(ofType objectType: T.Type,
                                           tableName: String,
                                           primaryKeyColumnName: String,
                                           primaryKeyValue: Codable,
                                           indexColumnNameArray: [String]?,
                                           objectTypeVersion: Int,
                                           updateClosure: (T?) -> T?,
                                           completionClosure: ((Bool) -> Void)?) {
        let objectTypeName = "\(objectType)"
        
        self.dbQueue?.inTransaction({ (db, rollback) in
            var object: T? = nil
            
            let tableExist = self.isTableExist(db: db, objectTypeName: objectTypeName, tableName: tableName)
            if tableExist {
                object = self.readObject(db: db,
                                         objectType: objectType,
                                         tableName: tableName,
                                         primaryKeyColumnName: primaryKeyColumnName,
                                         primaryKeyValue: primaryKeyValue)
            }
            
            guard let newObject = updateClosure(object) else {
                completionClosure?(true)
                return
            }
            
            if !tableExist {
                // create table if not exist and upgrade table if needed
                let isTableReady =
                    self.fixTableIfNeeded(db: db,
                                          objectType: objectType,
                                          tableName: tableName,
                                          primaryKeyColumnName: primaryKeyColumnName,
                                          indexColumnNameArray: indexColumnNameArray,
                                          objectTypeVersion: objectTypeVersion)
                
                if !isTableReady {
                    rollback.pointee = true
                    return
                }
            }
            
            let result = self.replaceRecord(db: db, tableName: tableName, object: newObject)
            if !result {
                rollback.pointee = true
            }
        })
    }
    
    private func pRemoveObject<T: Codable>(ofType objectType: T.Type,
                                           tableName: String,
                                           primaryKeyColumnName: String,
                                           primaryKeyValue: Codable) -> Bool {
        var result = false
        
        let objectTypeName = "\(objectType)"
        
        self.dbQueue?.inTransaction({ (db, rollback) in
            guard self.isTableExist(db: db, objectTypeName: objectTypeName, tableName: tableName) else {
                result = true
                return
            }
            
            result = self.deleteRecord(db: db,
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
    
    private func pRemoveObjectTable<T: Codable>(ofType objectType: T.Type, tableName: String) -> Bool {
        var result = false
        
        let objectTypeName = "\(objectType)"
        
        self.dbQueue?.inTransaction({ (db, rollback) in
            guard self.isTableExist(db: db, objectTypeName: objectTypeName, tableName: tableName) else {
                result = true
                return
            }
            
            result = self.dropTable(db: db, tableName: tableName)
            if !result {
                rollback.pointee = true
                return
            }
            
            result = self.deleteRecord(db: db,
                                       tableName: kORMTableName,
                                       primaryKeyColumnName: kTableNameColumnName,
                                       primaryKeyValue: tableName)
            if !result {
                rollback.pointee = true
                return
            }
        })
        
        return result
    }
    
    private func initDB() {
        let dirURL = self.fileURL.deletingLastPathComponent()
        let result = CICOPathAide.createDir(with: dirURL, option: false)
        if !result {
            print("[ERROR]: create database dir failed")
            return
        }
        
        guard let dbQueue = FMDatabaseQueue.init(url: self.fileURL) else {
            print("[ERROR]: create database failed")
            return
        }
        
        dbQueue.inDatabase { (db) in
            let result = self.createORMTableInfoTableIfNotExists(db: db)
            if result {
                self.dbQueue = dbQueue
            }
        }
    }
    
    private func tableName<T>(objectType: T.Type, customTableName: String? = nil) -> String {
        let tableName: String
        if let customTableName = customTableName {
            tableName = customTableName
        } else {
            tableName = "table_\(objectType)"
        }
        return tableName
    }
    
    private func indexName(indexColumnName: String, tableName: String) -> String {
        return "index_\(indexColumnName)_of_\(tableName)"
    }
    
    private func createORMTableInfoTableIfNotExists(db: FMDatabase) -> Bool {
        let createTableSQL =
        "CREATE TABLE IF NOT EXISTS \(kORMTableName) (\(kTableNameColumnName) TEXT NOT NULL, \(kObjectTypeNameColumnName) TEXT NOT NULL, \(kObjectTypeVersionColumnName) INTEGER NOT NULL, PRIMARY KEY(\(kTableNameColumnName)));"
        
         //        print("[SQL]: \(createTableSQL)")
        let result = db.executeUpdate(createTableSQL, withArgumentsIn: [])
        if !result  {
            print("[ERROR]: SQL = \(createTableSQL)")
        }
        
        return result
    }
    
    private func readORMTableInfo(db: FMDatabase, objectTypeName: String, tableName: String) -> CICOORMTableInfoModel? {
        var tableInfo: CICOORMTableInfoModel? = nil
        
        let querySQL = "SELECT * FROM \(kORMTableName) WHERE \(kTableNameColumnName) = ? LIMIT 1;"
        
        //        print("[SQL]: \(querySQL)")
        guard let resultSet = db.executeQuery(querySQL, withArgumentsIn: [tableName]) else {
            return tableInfo
        }
        
        if resultSet.next() {
            if let objectTypeNameValue = resultSet.string(forColumn: kObjectTypeNameColumnName),
                objectTypeNameValue == objectTypeName {
                let objectTypeVersion: Int = resultSet.long(forColumn: kObjectTypeVersionColumnName)
                let temp = CICOORMTableInfoModel.init(tableName: tableName,
                                                      objectTypeName: objectTypeNameValue,
                                                      objectTypeVersion: objectTypeVersion)
                tableInfo = temp
            }
        }
        
        resultSet.close()
        
        return tableInfo
    }
    
    private func writeORMTableInfo(db: FMDatabase, tableInfo: CICOORMTableInfoModel) -> Bool {
        var result = false
        
        let replaceSQL = "REPLACE INTO \(kORMTableName) (\(kTableNameColumnName), \(kObjectTypeNameColumnName), \(kObjectTypeVersionColumnName)) values (?, ?, ?);"
        let argumentArray: [Any] = [tableInfo.tableName, tableInfo.objectTypeName, tableInfo.objectTypeVersion]
        
        //        print("[SQL]: \(replaceSQL)")
        result = db.executeUpdate(replaceSQL, withArgumentsIn: argumentArray)
        if !result {
            print("[ERROR]: SQL = \(replaceSQL)")
        }
        
        return result
    }
    
    private func removeORMTableInfo(db: FMDatabase, tableName: String) -> Bool {
        return self.deleteRecord(db: db,
                                 tableName: kORMTableName,
                                 primaryKeyColumnName: kTableNameColumnName,
                                 primaryKeyValue: tableName)
    }
    
    private func fixTableIfNeeded<T: Codable>(db: FMDatabase,
                                              objectType: T.Type,
                                              tableName: String,
                                              primaryKeyColumnName: String,
                                              indexColumnNameArray: [String]?,
                                              objectTypeVersion: Int) -> Bool {
        var result = false
        
        let objectTypeName = "\(objectType)"
        
        guard let tableInfo = self.readORMTableInfo(db: db, objectTypeName: objectTypeName, tableName: tableName) else {
            result = self.createTableAndIndexs(db: db,
                                               objectType: objectType,
                                               tableName: tableName,
                                               primaryKeyColumnName: primaryKeyColumnName,
                                               indexColumnNameArray: indexColumnNameArray,
                                               objectTypeVersion: objectTypeVersion)
            return result
        }
        
        guard tableInfo.objectTypeVersion >= objectTypeVersion else {
            // upgrade column
            let columnSet = self.queryTableColumns(db: db, tableName: tableName)
            let sqliteTypeDic = CICOSQLiteTypeDecoder.allTypeProperties(of: objectType)
            let newColumnSet = Set<String>.init(sqliteTypeDic.keys)
            let needAddColumnSet = newColumnSet.subtracting(columnSet)
            
            for columnName in needAddColumnSet {
                let sqliteType = sqliteTypeDic[columnName]!
                result = self.addColumn(db: db,
                                        tableName: tableName,
                                        columnName: columnName,
                                        columnType: sqliteType.sqliteType.rawValue)
                if !result {
                    return result
                }
            }
            
            // upgrade indexs
            let indexSet = self.queryTableIndexs(db: db, tableName: tableName)
            let newIndexSet: Set<String>
            let newIndexDic: [String: String]
            if let indexColumnNameArray = indexColumnNameArray {
                var tempSet = Set<String>.init()
                var tempIndexDic = [String: String]()
                indexColumnNameArray.forEach { (indexColumnName) in
                    let indexName = self.indexName(indexColumnName: indexColumnName, tableName: tableName)
                    tempSet.insert(indexName)
                    tempIndexDic[indexName] = indexColumnName
                }
                newIndexSet = tempSet
                newIndexDic = tempIndexDic
            } else {
                newIndexSet = Set<String>.init()
                newIndexDic = [String: String]()
            }
            
            let needAddIndexSet = newIndexSet.subtracting(indexSet)
            for indexName in needAddIndexSet {
                let indexColumnName = newIndexDic[indexName]!
                result = self.createIndex(db: db,
                                          indexName: indexName,
                                          tableName: tableName,
                                          indexColumnName: indexColumnName)
                if !result {
                    return result
                }
            }
            
            let needDeleteIndexSet = indexSet.subtracting(newIndexSet)
            for indexName in needDeleteIndexSet {
                result = self.dropIndex(db: db, indexName: indexName)
                if !result {
                    return result
                }
            }
            
            // update objectTypeVersion
            let newTableInfo = CICOORMTableInfoModel.init(tableName: tableName,
                                                          objectTypeName: objectTypeName,
                                                          objectTypeVersion: objectTypeVersion)
            result = self.writeORMTableInfo(db: db, tableInfo: newTableInfo)
            
            return result
        }
        
        result = true
        
        return result
    }
    
    private func isTableExist(db: FMDatabase, objectTypeName: String, tableName: String) -> Bool {
        if let _ = self.readORMTableInfo(db: db, objectTypeName: objectTypeName, tableName: tableName) {
            return true
        } else {
            return false
        }
    }
    
    private func createTableAndIndexs<T: Codable>(db: FMDatabase,
                                                  objectType: T.Type,
                                                  tableName: String,
                                                  primaryKeyColumnName: String,
                                                  indexColumnNameArray: [String]?,
                                                  objectTypeVersion: Int) -> Bool {
        var result = false
        
        let objectTypeName = "\(objectType)"
        
        // create table
        
        let sqliteTypeDic = CICOSQLiteTypeDecoder.allTypeProperties(of: objectType)
        //            print("\nsqliteTypes: \(sqliteTypes)")
        
        var createTableSQL = "CREATE TABLE IF NOT EXISTS \(tableName) ("
        var isFirst = true
        sqliteTypeDic.forEach({ (name, sqliteType) in
            if isFirst {
                isFirst = false
                createTableSQL.append("\(name)")
            } else {
                createTableSQL.append(", \(name)")
            }
            
            createTableSQL.append(" \(sqliteType.sqliteType.rawValue)")
            
            if name == primaryKeyColumnName {
                createTableSQL.append(" NOT NULL")
            }
        })
        createTableSQL.append(", PRIMARY KEY(\(primaryKeyColumnName))")
        createTableSQL.append(");")
        
        //            print("[SQL]: \(createTableSQL)")
        result = db.executeUpdate(createTableSQL, withArgumentsIn: [])
        if !result {
            print("[ERROR]: SQL = \(createTableSQL)")
            return result
        }
        
        // create index
        if let indexColumnNameArray = indexColumnNameArray {
            for indexColumnName in indexColumnNameArray {
                let indexName = self.indexName(indexColumnName: indexColumnName, tableName: tableName)
                result = self.createIndex(db: db, indexName: indexName, tableName: tableName, indexColumnName: indexColumnName)
                if !result {
                    return result
                }
            }
        }
        
        // save table info
        let tableInfo = CICOORMTableInfoModel.init(tableName: tableName, objectTypeName: objectTypeName, objectTypeVersion: objectTypeVersion)
        result = self.writeORMTableInfo(db: db, tableInfo: tableInfo)
        
        return result
    }
    
    private func queryTableColumns(db: FMDatabase, tableName: String) -> Set<String> {
        var columnSet = Set<String>.init()
        
        let querySQL = "PRAGMA TABLE_INFO(\(tableName));"
        
        guard let resultSet = db.executeQuery(querySQL, withArgumentsIn: []) else {
            return columnSet
        }
        
        while resultSet.next() {
            if let name = resultSet.string(forColumn: "name") {
                columnSet.insert(name)
            }
        }
        
        resultSet.close()
        
        //        print("\(columnSet)")
        
        return columnSet
    }
    
    private func queryTableIndexs(db: FMDatabase, tableName: String) -> Set<String> {
        var indexSet = Set<String>.init()
        
        let querySQL = "SELECT name FROM SQLITE_MASTER WHERE type = 'index' AND tbl_name = '\(tableName)' AND sql IS NOT NULL;"
        
        guard let resultSet = db.executeQuery(querySQL, withArgumentsIn: []) else {
            return indexSet
        }
        
        while resultSet.next() {
            if let name = resultSet.string(forColumn: "name") {
                indexSet.insert(name)
            }
        }
        
        resultSet.close()
        
        //        print("\(indexSet)")
        
        return indexSet
    }
    
    private func readObject<T: Codable>(db: FMDatabase,
                                        objectType: T.Type,
                                        tableName: String,
                                        primaryKeyColumnName: String,
                                        primaryKeyValue: Codable) -> T? {
        var object: T? = nil
        
        let querySQL = "SELECT * FROM \(tableName) WHERE \(primaryKeyColumnName) = ? LIMIT 1;"
        
        //            print("[SQL]: \(querySQL)")
        guard let resultSet = db.executeQuery(querySQL, withArgumentsIn: [primaryKeyValue]) else {
            print("[ERROR]: SQL = \(querySQL)")
            return object
        }
        
        if resultSet.next() {
            object = CICOSQLiteRecordDecoder.decodeSQLiteRecord(resultSet: resultSet, type: objectType)
        }
        
        resultSet.close()
        
        return object
    }
    
    private func readObjectArray<T: Codable>(db: FMDatabase,
                                             objectType: T.Type,
                                             tableName: String,
                                             whereString: String? = nil,
                                             orderByName: String? = nil,
                                             descending: Bool = true,
                                             limit: Int? = nil) -> [T]? {
        var array: [T]? = nil
        
        let objectTypeName = "\(objectType)"
        
        var querySQL = "SELECT * FROM \(tableName)"
        var argumentArray = [Any]()
        
        if let whereString = whereString {
            querySQL.append(" \(whereString)")
        }
        
        if let orderByName = orderByName {
            querySQL.append(" ORDER BY '\(orderByName)'")
            if descending {
                querySQL.append(" DESC")
            } else {
                querySQL.append(" ASC")
            }
        }
        
        if let limit = limit {
            querySQL.append(" LIMIT ?")
            argumentArray.append(limit)
        }
        
        querySQL.append(";")
        
        //            print("[SQL]: \(querySQL)")
        guard let resultSet = db.executeQuery(querySQL, withArgumentsIn: argumentArray) else {
            print("[ERROR]: SQL = \(querySQL)")
            return array
        }
        
        defer {
            resultSet.close()
        }
        
        var tempArray = [T]()
        while resultSet.next() {
            guard let object = CICOSQLiteRecordDecoder.decodeSQLiteRecord(resultSet: resultSet, type: objectType) else {
                return array
            }
            tempArray.append(object)
        }
        array = tempArray
        
        return array
    }
    
    private func replaceRecord<T: Codable>(db: FMDatabase, tableName: String, object: T) -> Bool {
        var result = false
        
        let (sql, arguments) =
            CICOSQLiteRecordEncoder.encodeObjectToSQL(object: object, tableName: tableName)
        
        guard let replaceSQL = sql, let argumentArray = arguments else {
            return result
        }
        
        //        print("[SQL]: \(replaceSQL)")
        result = db.executeUpdate(replaceSQL, withArgumentsIn: argumentArray)
        if !result {
            print("[ERROR]: SQL = \(replaceSQL)")
        }
        
        return result
    }
    
    private func deleteRecord(db: FMDatabase,
                              tableName: String,
                              primaryKeyColumnName: String,
                              primaryKeyValue: Codable) -> Bool {
        var result = false
        
        let deleteSQL = "DELETE FROM \(tableName) WHERE \(primaryKeyColumnName) = ?;"
        
        //        print("[SQL]: \(deleteSQL)")
        result = db.executeUpdate(deleteSQL, withArgumentsIn: [primaryKeyValue])
        if !result {
            print("[ERROR]: SQL = \(deleteSQL)")
        }
        
        return result
    }
    
    private func dropTable(db: FMDatabase, tableName: String) -> Bool {
        var result = false
        
        let dropSQL = "DROP TABLE \(tableName);"
        
        //        print("[SQL]: \(dropSQL)")
        result = db.executeUpdate(dropSQL, withArgumentsIn: [])
        if !result {
            print("[ERROR]: SQL = \(dropSQL)")
        }
        
        return result
    }
    
    private func addColumn(db: FMDatabase, tableName: String, columnName: String, columnType: String) -> Bool {
        let alterSQL = "ALTER TABLE \(tableName) ADD COLUMN \(columnName) \(columnType);"
        
        //print("[SQL]: \(alterSQL)")
        let result = db.executeUpdate(alterSQL, withArgumentsIn: [])
        if !result {
            print("[ERROR]: SQL = \(alterSQL)")
        }
        
        return result
    }
    
    private func createIndex(db: FMDatabase, indexName: String, tableName: String, indexColumnName: String) -> Bool {
        let createIndexSQL = "CREATE INDEX \(indexName) ON \(tableName)(\(indexColumnName));"
        
        //print("[SQL]: \(createIndexSQL)")
        let result = db.executeUpdate(createIndexSQL, withArgumentsIn: [])
        if !result {
            print("[ERROR]: SQL = \(createIndexSQL)")
        }
        
        return result
    }
    
    private func dropIndex(db: FMDatabase, indexName: String) -> Bool {
        let dropIndexSQL = "DROP INDEX \(indexName);"
        
        //print("[SQL]: \(dropIndexSQL)")
        let result = db.executeUpdate(dropIndexSQL, withArgumentsIn: [])
        if !result {
            print("[ERROR]: SQL = \(dropIndexSQL)")
        }
        
        return result
    }
}
