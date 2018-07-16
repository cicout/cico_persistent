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

private let kJSONORMTableName = "json_orm_table_name"
private let kTableNameColumnName = "table_name"
private let kClassNameColumnName = "class_name"

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
    
    open func readObject<T: Codable>(ofType objectType: T.Type, forPrimaryKey key: String, customTableName: String? = nil) -> T? {
        var object: T? = nil
        
        let typeName = "\(objectType)"
        var tableName = typeName
        if let customTableName = customTableName {
            tableName = customTableName
        }
        print("typeName: \(typeName),   tableName: \(tableName)")
        
        self.dbQueue?.inTransaction({ (db, rollback) in
            guard isTableExist(db: db, tableName: tableName, typeName: typeName) else {
                return
            }
            
            let sqliteTypes = CICOSQLiteTypeDecoder.allSQLiteTypes(of: objectType)
            print("\nsqliteTypes: \(sqliteTypes)")
            
            let primaryKeyName = "name"
            let querySQL = "SELECT * FROM \(tableName) WHERE \(primaryKeyName) = ? LIMIT 1;"
            
            guard let resultSet = db.executeQuery(querySQL, withArgumentsIn: [key]) else {
                return
            }
            
            if resultSet.next() {
                object = CICOSQLiteRecordDecoder.decodeSQLiteRecord(resultSet: resultSet, type: objectType)
            }
            
            resultSet.close()
        })
        
        return object
    }
    
    open func readObjectArray<T: Codable>(ofType type: T.Type,
                                          orderBy: String? = nil,
                                          limit: Int? = nil,
                                          customTableName: String? = nil) -> [T]? {
        return nil
    }
    
    open func writeObject<T: Codable>(_ object: T, customTableName: String? = nil) -> Bool {
        var result = false
        
        guard let jsonData = object.toJSONData() else {
            return result
        }
        
        guard let json = self.json(fromJSONData: jsonData) else {
            return result
        }
        
        let objectType = T.self
        let typeName = "\(objectType)"
        var tableName = typeName
        if let customTableName = customTableName {
            tableName = customTableName
        }
        print("typeName: \(typeName),   tableName: \(tableName)")
        
        self.dbQueue?.inTransaction({ (db, rollback) in
            // create table if not exist
            let primaryKeyName = "name"
            let isTableReady = self.createTableIfNotExist(objectType: objectType,
                                                          primaryKeyName: primaryKeyName,
                                                          db: db,
                                                          tableName: tableName,
                                                          typeName: typeName)
            if !isTableReady {
                rollback.pointee = true
                return
            }
            
            // replace table record
            result = self.replaceRecord(json: json, db: db, tableName: tableName)
            if !result {
                rollback.pointee = true
            }
        })
        
        return result
    }
    
    open func writeObjectArray<T: Codable>(_ object: [T], customTableName: String? = nil) -> Bool {
        return false
    }
    
    open func removeObject<T: Codable>(_ object: T, customTableName: String? = nil) -> Bool {
        return false
    }
    
    open func removeObjectArray<T: Codable>(_ object: [T], customTableName: String? = nil) -> Bool {
        return false
    }
    
    open func removeObjectTable<T: Codable>(ofType type: T.Type, customTableName: String? = nil) -> Bool {
        return false
    }
    
    open func removeAll() -> Bool {
        return false
    }
    
    private func initDB() {
        let dirURL = self.fileURL.deletingLastPathComponent()
        let result = CICOPathAide.createDir(with: dirURL, option: false)
        if !result {
            print("[ERROR]: create database dir failed\nurl: \(self.fileURL)")
            return
        }
        
        guard let dbQueue = FMDatabaseQueue.init(url: self.fileURL) else {
            print("[ERROR]: create database failed\nurl: \(self.fileURL)")
            return
        }
        
        dbQueue.inDatabase { (db) in
            let createTableSQL = "CREATE TABLE IF NOT EXISTS \(kJSONORMTableName) (\(kTableNameColumnName) TEXT NOT NULL, \(kClassNameColumnName) TEXT NOT NULL, PRIMARY KEY(\(kTableNameColumnName)));"
            let result = db.executeUpdate(createTableSQL, withArgumentsIn: [])
            if result {
                self.dbQueue = dbQueue
            } else {
                print("[ERROR]: create database table failed\nurl: \(self.fileURL)")
            }
        }
    }

    private func json(fromJSONData jsonData: Data) -> JSON? {
        do {
            let json = try JSON.init(data: jsonData)
            return json
        } catch let error {
            print("[ERROR]: invalid json data\nerror: \(error)")
            return nil
        }
    }
    
    private func isTableExist(db: FMDatabase, tableName: String, typeName: String) -> Bool {
        var exist = false
        
        let querySQL = "SELECT * FROM \(kJSONORMTableName) WHERE \(kTableNameColumnName) = ? LIMIT 1;"
        
        guard let resultSet = db.executeQuery(querySQL, withArgumentsIn: [tableName]) else {
            return exist
        }
        
        if resultSet.next() {
            if let typeNameValue = resultSet.string(forColumn: kClassNameColumnName), typeNameValue == typeName {
                exist = true
            } else {
                resultSet.close()
                return exist
            }
        }
        
        resultSet.close()
        
        return exist
    }
    
    private func createTableIfNotExist(objectType: Decodable.Type, primaryKeyName: String, db: FMDatabase, tableName: String, typeName: String) -> Bool {
        var result = false
        
        let exist = self.isTableExist(db: db, tableName: tableName, typeName: typeName)
        if !exist {
            let sqliteTypes = CICOSQLiteTypeDecoder.allSQLiteTypes(of: objectType)
            print("\nsqliteTypes: \(sqliteTypes)")
            
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
            
            print("[CREATE_TABLE_SQL]: \(createTableSQL)")
            let createResult = db.executeUpdate(createTableSQL, withArgumentsIn: [])
            if createResult {
                // insert table name and type name
                let replaceSQL = "REPLACE INTO \(kJSONORMTableName) (\(kTableNameColumnName), \(kClassNameColumnName)) values (?, ?);"
                let replaceResult = db.executeUpdate(replaceSQL, withArgumentsIn: [tableName, typeName])
                if !replaceResult {
                    print("[ERROR]: write database record failed\nurl: \(self.fileURL)")
                    return result
                }
            } else {
                print("[ERROR]: create database table failed\nurl: \(self.fileURL)")
                return result
            }
        }
        
        result = true
        return result
    }
    
    private func replaceRecord(json: JSON, db: FMDatabase, tableName: String) -> Bool {
        var result = false
        
        guard let dic = json.dictionary, dic.count > 0 else {
            return result
        }
        
        let propertyNameArray = dic.map() {$0.key}
        var propertyValueArray = [Any]()
        
        var replaceSQL = "REPLACE INTO \(tableName) ("
        var isFirst = true
        propertyNameArray.forEach({ (name) in
            if isFirst {
                isFirst = false
                replaceSQL.append("\(name)")
            } else {
                replaceSQL.append(", \(name)")
            }
            
            let propertyValue: Any
            let jsonValue = json[name]
            if jsonValue.type == .dictionary || jsonValue.type == .array {
                do {
                    propertyValue = try jsonValue.rawData()
                } catch let error {
                    print("[ERROR]: invalid data\n\(error)")
                    return
                }
            } else {
                propertyValue = jsonValue.rawValue
            }
            propertyValueArray.append(propertyValue)
        })
        replaceSQL.append(") VALUES (")
        for i in 0..<propertyNameArray.count {
            if 0 == i {
                replaceSQL.append("?")
            } else {
                replaceSQL.append(", ?")
            }
        }
        replaceSQL.append(");")
        
        print("[REPLACE_SQL]: \(replaceSQL)")
        let replaceResult = db.executeUpdate(replaceSQL, withArgumentsIn: propertyValueArray)
        if !replaceResult {
            print("[ERROR]: write database record failed\nurl: \(self.fileURL)")
            return result
        }
        
        result = true
        return result
    }
}
