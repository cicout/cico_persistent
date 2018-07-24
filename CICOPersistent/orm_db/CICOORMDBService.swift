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
        let tableName: String
        if let customTableName = customTableName {
            tableName = customTableName
        } else {
            tableName = "\(objectType)"
        }
        
        let primaryKeyName = T.cicoORMPrimaryKeyName()
        
        return self.pReadObject(ofType: objectType,
                                tableName: tableName,
                                primaryKeyName: primaryKeyName,
                                primaryKeyValue: primaryKeyValue)
    }
    
    open func readObjectArray<T: CICOORMCodableProtocol>(ofType objectType: T.Type,
                                                         whereString: String? = nil,
                                                         orderByName: String? = nil,
                                                         descending: Bool = true,
                                                         limit: Int? = nil,
                                                         customTableName: String? = nil) -> [T]? {
        let tableName: String
        if let customTableName = customTableName {
            tableName = customTableName
        } else {
            tableName = "\(objectType)"
        }
        
        return self.pReadObjectArray(ofType: objectType,
                                     tableName: tableName,
                                     whereString: whereString,
                                     orderByName: orderByName,
                                     descending: descending,
                                     limit: limit)
    }
    
    open func writeObject<T: CICOORMCodableProtocol>(_ object: T, customTableName: String? = nil) -> Bool {
        let tableName: String
        if let customTableName = customTableName {
            tableName = customTableName
        } else {
            tableName = "\(T.self)"
        }
        
        let primaryKeyName = T.cicoORMPrimaryKeyName()
        let objectTypeVersion = T.cicoORMObjectTypeVersion()
        
        return self.pWriteObject(object,
                                 tableName: tableName,
                                 primaryKeyName: primaryKeyName,
                                 objectTypeVersion: objectTypeVersion)
    }
    
    open func writeObjectArray<T: CICOORMCodableProtocol>(_ objectArray: [T], customTableName: String? = nil) -> Bool {
        let tableName: String
        if let customTableName = customTableName {
            tableName = customTableName
        } else {
            tableName = "\(T.self)"
        }
        
        let primaryKeyName = T.cicoORMPrimaryKeyName()
        let objectTypeVersion = T.cicoORMObjectTypeVersion()
        
        return self.pWriteObjectArray(objectArray,
                                      tableName: tableName,
                                      primaryKeyName: primaryKeyName,
                                      objectTypeVersion: objectTypeVersion)
    }
    
    open func removeObject<T: CICOORMCodableProtocol>(ofType objectType: T.Type,
                                                      primaryKeyValue: Codable,
                                                      customTableName: String? = nil) -> Bool {
        let tableName: String
        if let customTableName = customTableName {
            tableName = customTableName
        } else {
            tableName = "\(objectType)"
        }
        
        let primaryKeyName = T.cicoORMPrimaryKeyName()
        
        return self.pRemoveObject(ofType: objectType,
                                  tableName: tableName,
                                  primaryKeyName: primaryKeyName,
                                  primaryKeyValue: primaryKeyValue)
    }
    
    open func removeObjectTable<T: CICOORMCodableProtocol>(ofType objectType: T.Type, customTableName: String? = nil) -> Bool {
        let tableName: String
        if let customTableName = customTableName {
            tableName = customTableName
        } else {
            tableName = "\(objectType)"
        }
        
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
                                         primaryKeyName: String,
                                         primaryKeyValue: Codable) -> T? {
        var object: T? = nil
        
        let objectTypeName = "\(objectType)"
//        print("\n[READ]:\nobjectType = \(objectType)\ntableName = \(tableName)\nprimaryKeyName = \(primaryKeyName)\nprimaryKeyValue = \(primaryKeyValue)")
        
        self.dbQueue?.inTransaction({ (db, rollback) in
            guard self.isTableExist(db: db, objectTypeName: objectTypeName, tableName: tableName) else {
                return
            }
            
            let querySQL = "SELECT * FROM \(tableName) WHERE \(primaryKeyName) = ? LIMIT 1;"
            
//            print("[SQL]: \(querySQL)")
            guard let resultSet = db.executeQuery(querySQL, withArgumentsIn: [primaryKeyValue]) else {
                return
            }
            
            if resultSet.next() {
                object = CICOSQLiteRecordDecoder.decodeSQLiteRecord(resultSet: resultSet, type: objectType)
            }
            
            resultSet.close()
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
//        print("\n[READ]:\nobjectType = \(objectType)\ntableName = \(tableName)")
        
        self.dbQueue?.inTransaction({ (db, rollback) in
            guard self.isTableExist(db: db, objectTypeName: objectTypeName, tableName: tableName) else {
                return
            }
            
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
                return
            }
            
            defer {
                resultSet.close()
            }
            
            var objectArray = [T]()
            while resultSet.next() {
                guard let object = CICOSQLiteRecordDecoder.decodeSQLiteRecord(resultSet: resultSet, type: objectType) else {
                    return
                }
                objectArray.append(object)
            }
            array = objectArray
        })
        
        return array
    }
    
    private func pWriteObject<T: Codable>(_ object: T,
                                          tableName: String,
                                          primaryKeyName: String,
                                          objectTypeVersion: Int) -> Bool {
        var result = false
        
        let objectType = T.self
//        print("\n[WRITE]:\nobjectTypeName = \(objectType)\ntableName = \(tableName)\nprimaryKeyName = \(primaryKeyName)")
        
        self.dbQueue?.inTransaction({ (db, rollback) in
            // create table if not exist
            let isTableReady =
                self.fixTableIfNeeded(db: db,
                                      objectType: objectType,
                                      tableName: tableName,
                                      primaryKeyName: primaryKeyName,
                                      objectTypeVersion: objectTypeVersion)
            
            if !isTableReady {
                rollback.pointee = true
                return
            }
            
            // TODO:
            
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
                                               primaryKeyName: String,
                                               objectTypeVersion: Int) -> Bool {
        var result = false
        
        let objectType = T.self
//        print("\n[WRITE]:\nobjectTypeName = \(objectType)\ntableName = \(tableName)\nprimaryKeyName = \(primaryKeyName)")
        
        self.dbQueue?.inTransaction({ (db, rollback) in
            // create table if not exist
            let isTableReady =
                self.fixTableIfNeeded(db: db,
                                      objectType: objectType,
                                      tableName: tableName,
                                      primaryKeyName: primaryKeyName,
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
    
    private func pRemoveObject<T: Codable>(ofType objectType: T.Type,
                                           tableName: String,
                                           primaryKeyName: String,
                                           primaryKeyValue: Codable) -> Bool {
        var result = false
        
        let objectTypeName = "\(objectType)"
//        print("\n[REMOVE]:\nobjectType = \(objectType)\ntableName = \(tableName)\nprimaryKeyName = \(primaryKeyName)")
        
        self.dbQueue?.inTransaction({ (db, rollback) in
            guard self.isTableExist(db: db, objectTypeName: objectTypeName, tableName: tableName) else {
                result = true
                return
            }
            
            result = self.deleteRecord(db: db,
                                       tableName: tableName,
                                       primaryKeyName: primaryKeyName,
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
//        print("\n[REMOVE]:\nobjectType = \(objectType)\ntableName = \(tableName)")
        
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
                                       primaryKeyName: kTableNameColumnName,
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
    
    private func createORMTableInfoTableIfNotExists(db: FMDatabase) -> Bool {
        let createTableSQL =
        "CREATE TABLE IF NOT EXISTS \(kORMTableName) (\(kTableNameColumnName) TEXT NOT NULL, \(kObjectTypeNameColumnName) TEXT NOT NULL, \(kObjectTypeVersionColumnName) INTEGER NOT NULL, PRIMARY KEY(\(kTableNameColumnName)));"
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
                                 primaryKeyName: kTableNameColumnName,
                                 primaryKeyValue: tableName)
    }
    
    private func fixTableIfNeeded<T: Codable>(db: FMDatabase,
                                              objectType: T.Type,
                                              tableName: String,
                                              primaryKeyName: String,
                                              objectTypeVersion: Int) -> Bool {
        var result = false
        
        let objectTypeName = "\(objectType)"
        
        guard let tableInfo = self.readORMTableInfo(db: db, objectTypeName: objectTypeName, tableName: tableName) else {
            result = self.createTable(db: db,
                                      objectType: objectType,
                                      tableName: tableName,
                                      primaryKeyName: primaryKeyName,
                                      objectTypeVersion: objectTypeVersion)
            return result
        }
        
        guard tableInfo.objectTypeVersion >= objectTypeVersion else {
            let columnSet = self.queryTableColumns(db: db, tableName: tableName)
            let sqliteTypeDic = CICOSQLiteTypeDecoder.allTypeProperties(of: objectType)
            let newColumnSet = Set<String>.init(sqliteTypeDic.keys)
            let needAddColumnSet = newColumnSet.subtracting(columnSet)
            
            var failed = false
            for name in needAddColumnSet {
                if let sqliteType = sqliteTypeDic[name] {
                    let alterSQL = "ALTER TABLE \(tableName) ADD COLUMN \(name) \(sqliteType.sqliteType.rawValue)"
                    let alterResult = db.executeUpdate(alterSQL, withArgumentsIn: [])
                    if alterResult {
                        continue
                    }
                }
                
                failed = true
                break
            }
            
            guard !failed else {
                return result
            }
            
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
    
    private func createTable<T: Codable>(db: FMDatabase, objectType: T.Type, tableName: String, primaryKeyName: String, objectTypeVersion: Int) -> Bool {
        var result = false
        
        let objectTypeName = "\(objectType)"
        
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
            
            if name == primaryKeyName {
                createTableSQL.append(" NOT NULL")
            }
        })
        createTableSQL.append(", PRIMARY KEY(\(primaryKeyName))")
        createTableSQL.append(");")
        
        //            print("[SQL]: \(createTableSQL)")
        result = db.executeUpdate(createTableSQL, withArgumentsIn: [])
        if result {
            let tableInfo = CICOORMTableInfoModel.init(tableName: tableName, objectTypeName: objectTypeName, objectTypeVersion: objectTypeVersion)
            result = self.writeORMTableInfo(db: db, tableInfo: tableInfo)
        } else {
            print("[ERROR]: SQL = \(createTableSQL)")
        }

        return result
    }
    
    private func queryTableColumns(db: FMDatabase, tableName: String) -> Set<String> {
        var columnSet = Set<String>.init()
        
        let querySQL = "PRAGMA table_info(\(tableName));"
        
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
                              primaryKeyName: String,
                              primaryKeyValue: Codable) -> Bool {
        var result = false
        
        let deleteSQL = "DELETE FROM \(tableName) WHERE \(primaryKeyName) = ?;"
        
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
}
