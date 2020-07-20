//
//  ORMDBServiceInnerAide.swift
//  CICOPersistent
//
//  Created by lucky.li on 2019/8/23.
//  Copyright © 2019 cico. All rights reserved.
//

import Foundation
import FMDB

class ORMDBServiceInnerAide {
    static func tableName<T>(objectType: T.Type, customTableName: String? = nil) -> String {
        let tableName: String
        if let customTableName = customTableName {
            tableName = customTableName
        } else {
            tableName = "table_\(objectType)"
        }
        return tableName
    }

    static func indexName(indexColumnName: String, tableName: String) -> String {
        return "index_\(indexColumnName)_of_\(tableName)"
    }
}

extension ORMDBServiceInnerAide {
    static func createTableIfNotExists<T: Codable>(database: FMDatabase,
                                                   objectType: T.Type,
                                                   tableName: String,
                                                   primaryKeyColumnName: String,
                                                   autoIncrement: Bool) -> Bool {
        var result = false

        let sqliteTypeDic = SQLiteTypeDecoder.allTypeProperties(of: objectType)

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
                createTableSQL.append(" PRIMARY KEY")
                if autoIncrement && sqliteType.sqliteType == .INTEGER {
                    createTableSQL.append(" AUTOINCREMENT")
                }
            }
        })
        createTableSQL.append(");")

        result = database.executeUpdate(createTableSQL, withArgumentsIn: [])
        if !result {
            print("[ERROR]: SQL = \(createTableSQL)")
            return result
        }

        return result
    }
}

extension ORMDBServiceInnerAide {
    static func upgradeTableColumn<T: Codable>(database: FMDatabase,
                                               objectType: T.Type,
                                               tableName: String) -> Bool {
        var result = false

        let columnSet = DBAide.queryTableColumns(database: database, tableName: tableName)
        let sqliteTypeDic = SQLiteTypeDecoder.allTypeProperties(of: objectType)
        let newColumnSet = Set<String>.init(sqliteTypeDic.keys)
        let needAddColumnSet = newColumnSet.subtracting(columnSet)

        for columnName in needAddColumnSet {
            let sqliteType = sqliteTypeDic[columnName]!
            result = DBAide.addColumn(database: database,
                                      tableName: tableName,
                                      columnName: columnName,
                                      columnType: sqliteType.sqliteType.rawValue)
            if !result {
                return result
            }
        }

        result = true

        return result
    }

    static func upgradeTableIndex<T: Codable>(database: FMDatabase,
                                              objectType: T.Type,
                                              tableName: String,
                                              indexColumnNameArray: [String]?) -> Bool {
        var result = false

        let indexSet = DBAide.queryTableIndexs(database: database, tableName: tableName)
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
            result = DBAide.createIndex(database: database,
                                        indexName: indexName,
                                        tableName: tableName,
                                        indexColumnName: indexColumnName)
            if !result {
                return result
            }
        }

        let needDeleteIndexSet = indexSet.subtracting(newIndexSet)
        for indexName in needDeleteIndexSet {
            result = DBAide.dropIndex(database: database, indexName: indexName)
            if !result {
                return result
            }
        }

        result = true

        return result
    }
}

extension ORMDBServiceInnerAide {
    static func readObject<T: Codable>(database: FMDatabase,
                                       objectType: T.Type,
                                       tableName: String,
                                       primaryKeyColumnName: String,
                                       primaryKeyValue: Codable) -> T? {
        var object: T?

        let querySQL = "SELECT * FROM \(tableName) WHERE \(primaryKeyColumnName) = ? LIMIT 1;"

        guard let resultSet = database.executeQuery(querySQL, withArgumentsIn: [primaryKeyValue]) else {
            print("[ERROR]: SQL = \(querySQL)")
            return object
        }

        if resultSet.next() {
            object = SQLiteRecordDecoder.decodeSQLiteRecord(resultSet: resultSet, objectType: objectType)
        }

        resultSet.close()

        return object
    }

    static func readObjectArray<T: Codable>(database: FMDatabase,
                                            objectType: T.Type,
                                            tableName: String,
                                            whereString: String? = nil,
                                            orderByName: String? = nil,
                                            descending: Bool = true,
                                            limit: Int? = nil) -> [T]? {
        var array: [T]?

        var querySQL = "SELECT * FROM \(tableName)"
        var argumentArray = [Any]()

        if let whereString = whereString {
            querySQL.append(" WHERE \(whereString)")
        }

        if let orderByName = orderByName {
            querySQL.append(" ORDER BY \(orderByName)")
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

        guard let resultSet = database.executeQuery(querySQL, withArgumentsIn: argumentArray) else {
            print("[ERROR]: SQL = \(querySQL)")
            return array
        }

        defer {
            resultSet.close()
        }

        var tempArray = [T]()
        while resultSet.next() {
            guard let object = SQLiteRecordDecoder.decodeSQLiteRecord(resultSet: resultSet,
                                                                      objectType: objectType) else {
                                                                        return array
            }
            tempArray.append(object)
        }
        array = tempArray

        return array
    }

    static func replaceRecord<T: Codable>(database: FMDatabase, tableName: String, object: T) -> Bool {
        var result = false

        let (sql, arguments) =
            SQLiteRecordEncoder.encodeObjectToSQL(object: object, tableName: tableName)

        guard let replaceSQL = sql, let argumentArray = arguments else {
            return result
        }

        result = database.executeUpdate(replaceSQL, withArgumentsIn: argumentArray)
        if !result {
            print("[ERROR]: SQL = \(replaceSQL)")
        }

        return result
    }

    static func deleteRecord(database: FMDatabase,
                             tableName: String,
                             primaryKeyColumnName: String,
                             primaryKeyValue: Codable) -> Bool {
        var result = false

        let deleteSQL = "DELETE FROM \(tableName) WHERE \(primaryKeyColumnName) = ?;"

        result = database.executeUpdate(deleteSQL, withArgumentsIn: [primaryKeyValue])
        if !result {
            print("[ERROR]: SQL = \(deleteSQL)")
        }

        return result
    }
}
