//
//  CICOJSONORMDBService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/6/22.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation
import FMDB
import SwiftyJSON

private let kJSONORMTableName = "json_orm_table_name"
private let kTableNameColumnName = "table_name"
private let kClassNameColumnName = "class_name"

open class CICOJSONORMDBService {
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
    
    open func readJSON(tableName: String, primaryKeyName: String, primaryKey: String) -> Data? {
        return nil
    }
    
    open func readJSONArray(tableName: String, orderBy: String? = nil, limit: Int? = nil) -> Data? {
        return nil
    }
    
    open func writeJSON(jsonData: Data, tableName: String, className: String, primaryKeyName: String) -> Bool {
        var result = false
        
        guard let json = self.json(fromJSONData: jsonData) else {
            return result
        }
        
        self.dbQueue?.inTransaction({ (db, rollback) in
            // query table exist
            let querySQL = "SELECT * FROM \(kJSONORMTableName) WHERE \(kTableNameColumnName) = ? LIMIT 1;"
            
            guard let resultSet = db.executeQuery(querySQL, withArgumentsIn: [tableName]) else {
                return
            }
            
            var tableExist = false
            if resultSet.next() {
                if let classNameValue = resultSet.string(forColumn: kClassNameColumnName), classNameValue == className {
                    tableExist = true
                } else {
                    resultSet.close()
                    return
                }
            }
            
            resultSet.close()
            
            // create table if not exist
            if !tableExist {
                // TODO: creat real table
                guard let dic = json.dictionary, dic.count > 0 else {
                    return
                }
                
                let propertyNameArray = dic.map() {$0.key}
                
                var createTableSQL = "CREATE TABLE IF NOT EXISTS \(tableName) ("
                var isFirst = true
                propertyNameArray.forEach({ (name) in
                    if isFirst {
                        isFirst = false
                        createTableSQL.append("\(name)")
                    } else {
                        createTableSQL.append(", \(name)")
                    }
                    
                    
                    
                    let jsonValue = json[name]
                    if jsonValue.type == .dictionary || jsonValue.type == .array {
                        createTableSQL.append(" BLOB")
                    } else if jsonValue.type == .string {
                        createTableSQL.append(" TEXT")
                    } else if jsonValue.type == .number {
                        createTableSQL.append(" REAL")
                    } else if jsonValue.type == .bool {
                        createTableSQL.append(" INTEGER")
                    } else {
                        print("[ERROR]: invalid type")
                        return
                    }
                    
                    if name == primaryKeyName {
                        createTableSQL.append(" NOT NULL")
                    }
                })
                createTableSQL.append(", PRIMARY KEY(\(primaryKeyName))")
                createTableSQL.append(");")
                
                print("[CREATE_TABLE_SQL]: \(createTableSQL)")
                let createResult = db.executeUpdate(createTableSQL, withArgumentsIn: [])
                if createResult {
                    // insert table name and class name
                    let replaceSQL = "REPLACE INTO \(kJSONORMTableName) (\(kTableNameColumnName), \(kClassNameColumnName)) values (?, ?);"
                    let replaceResult = db.executeUpdate(replaceSQL, withArgumentsIn: [tableName, className])
                    if !replaceResult {
                        print("[ERROR]: write database record failed\nurl: \(self.fileURL)")
                        return
                    }
                } else {
                    print("[ERROR]: create database table failed\nurl: \(self.fileURL)")
                    return
                }
            }
            
            // TODO: replace table record
            guard let dic = json.dictionary, dic.count > 0 else {
                return
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
                    // TODO: null/unknown
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
                return
            }
        })
        
        return result
    }
    
    open func removeJSON(jsonData: Data, tableName: String, primaryKeyName: String) -> Bool {
        return false
    }
    
    open func removeTable(tableName: String) -> Bool {
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
}
