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

private let kORMTableName = "cico_orm_table_name"
private let kTableNameColumnName = "table_name"
private let kObjectTypeNameColumnName = "object_type_name"

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
        
        return self.pWriteObject(object, tableName: tableName, primaryKeyName: primaryKeyName)
    }
    
    open func writeObjectArray<T: CICOORMCodableProtocol>(_ objectArray: [T], customTableName: String? = nil) -> Bool {
        let tableName: String
        if let customTableName = customTableName {
            tableName = customTableName
        } else {
            tableName = "\(T.self)"
        }
        
        let primaryKeyName = T.cicoORMPrimaryKeyName()
        
        return self.pWriteObjectArray(objectArray, tableName: tableName, primaryKeyName: primaryKeyName)
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
    
    private func pWriteObject<T: Codable>(_ object: T, tableName: String, primaryKeyName: String) -> Bool {
        var result = false
        
        let objectType = T.self
//        print("\n[WRITE]:\nobjectTypeName = \(objectType)\ntableName = \(tableName)\nprimaryKeyName = \(primaryKeyName)")
        
        self.dbQueue?.inTransaction({ (db, rollback) in
            // create table if not exist
            let isTableReady = self.createTableIfNotExist(db: db,
                                                          objectType: objectType,
                                                          tableName: tableName,
                                                          primaryKeyName: primaryKeyName)
            
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
    
    private func pWriteObjectArray<T: Codable>(_ objectArray: [T], tableName: String, primaryKeyName: String) -> Bool {
        var result = false
        
        let objectType = T.self
//        print("\n[WRITE]:\nobjectTypeName = \(objectType)\ntableName = \(tableName)\nprimaryKeyName = \(primaryKeyName)")
        
        self.dbQueue?.inTransaction({ (db, rollback) in
            // create table if not exist
            let isTableReady = self.createTableIfNotExist(db: db,
                                                          objectType: objectType,
                                                          tableName: tableName,
                                                          primaryKeyName: primaryKeyName)
            
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
            print("[ERROR]: create database failed\nurl: \(self.fileURL)")
            return
        }
        
        dbQueue.inDatabase { (db) in
            let createTableSQL = "CREATE TABLE IF NOT EXISTS \(kORMTableName) (\(kTableNameColumnName) TEXT NOT NULL, \(kObjectTypeNameColumnName) TEXT NOT NULL, PRIMARY KEY(\(kTableNameColumnName)));"
            let result = db.executeUpdate(createTableSQL, withArgumentsIn: [])
            if result {
                self.dbQueue = dbQueue
            } else {
                print("[ERROR]: create database table failed")
            }
        }
    }
    
    private func isTableExist(db: FMDatabase, objectTypeName: String, tableName: String) -> Bool {
        var exist = false
        
        let querySQL = "SELECT * FROM \(kORMTableName) WHERE \(kTableNameColumnName) = ? LIMIT 1;"
        
//        print("[SQL]: \(querySQL)")
        guard let resultSet = db.executeQuery(querySQL, withArgumentsIn: [tableName]) else {
            return exist
        }
        
        if resultSet.next() {
            if let typeNameValue = resultSet.string(forColumn: kObjectTypeNameColumnName), typeNameValue == objectTypeName {
                exist = true
            } else {
                resultSet.close()
                return exist
            }
        }
        
        resultSet.close()
        
        return exist
    }
    
    private func createTableIfNotExist<T: Codable>(db: FMDatabase, objectType: T.Type, tableName: String, primaryKeyName: String) -> Bool {
        var result = false
        
        let objectTypeName = "\(objectType)"
        
        let exist = self.isTableExist(db: db, objectTypeName: objectTypeName, tableName: tableName)
        if !exist {
            let sqliteTypes = CICOSQLiteTypeDecoder.allTypeProperties(of: objectType)
            //            print("\nsqliteTypes: \(sqliteTypes)")
            
            var createTableSQL = "CREATE TABLE IF NOT EXISTS \(tableName) ("
            var isFirst = true
            sqliteTypes.forEach({ (name, sqliteType) in
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
            let createResult = db.executeUpdate(createTableSQL, withArgumentsIn: [])
            if createResult {
                // insert table name and type name
                let replaceSQL = "REPLACE INTO \(kORMTableName) (\(kTableNameColumnName), \(kObjectTypeNameColumnName)) values (?, ?);"
                print("[SQL]: \(replaceSQL)")
                let replaceResult = db.executeUpdate(replaceSQL, withArgumentsIn: [tableName, objectTypeName])
                if !replaceResult {
                    print("[ERROR]: write database record failed")
                    return result
                }
            } else {
                print("[ERROR]: create database table failed")
                return result
            }
        }
        
        result = true
        return result
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
            print("[ERROR]: write database record failed")
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
            print("[ERROR]: delete database record failed")
        }
        
        return result
    }
    
    private func dropTable(db: FMDatabase,
                           tableName: String) -> Bool {
        var result = false
        
        let dropSQL = "DROP TABLE \(tableName);"
        
//        print("[SQL]: \(dropSQL)")
        result = db.executeUpdate(dropSQL, withArgumentsIn: [])
        if !result {
            print("[ERROR]: drop table failed")
        }
        
        return result
    }
}
