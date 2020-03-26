//
//  DBAide.swift
//  CICOPersistent
//
//  Created by Ethan.Li on 2020/3/26.
//  Copyright © 2020 cico. All rights reserved.
//

import Foundation
import FMDB

class DBAide {
    static func isTableExist(database: FMDatabase, tableName: String) -> Bool {
        var result = false

        let querySQL = """
        SELECT name FROM SQLITE_MASTER WHERE type = 'table' AND tbl_name = '\(tableName)';
        """

        guard let resultSet = database.executeQuery(querySQL, withArgumentsIn: []) else {
            return result
        }

        if resultSet.next() {
            result = true
        }

        resultSet.close()

        return result
    }

    static func createTableIfNotExists(database: FMDatabase, tableName: String, columnArray: [ColumnModel]) -> Bool {
        var result = false

        guard tableName.count > 0, columnArray.count > 0 else {
            return result
        }

        var createTableSQL = "CREATE TABLE IF NOT EXISTS \(tableName) ("
        var isFirst = true
        columnArray.forEach({ column in
            if isFirst {
                isFirst = false
                createTableSQL.append("\(column.name)")
            } else {
                createTableSQL.append(", \(column.name)")
            }

            createTableSQL.append(" \(column.type.rawValue)")

            if column.isPrimaryKey {
                createTableSQL.append(" NOT NULL PRIMARY KEY")
                if column.isAutoIncrement && column.type == .INTEGER {
                    createTableSQL.append(" AUTOINCREMENT")
                }
            }
        })
        createTableSQL.append(");")

        result = database.executeUpdate(createTableSQL, withArgumentsIn: [])
        if !result {
            print("[ERROR]: SQL = \(createTableSQL)")
        }

        return result
    }

    static func dropTable(database: FMDatabase, tableName: String) -> Bool {
        var result = false

        let dropSQL = "DROP TABLE \(tableName);"

        result = database.executeUpdate(dropSQL, withArgumentsIn: [])
        if !result {
            print("[ERROR]: SQL = \(dropSQL)")
        }

        return result
    }

    static func queryTableColumns(database: FMDatabase, tableName: String) -> Set<String> {
        var columnSet = Set<String>.init()

        let querySQL = "PRAGMA TABLE_INFO(\(tableName));"

        guard let resultSet = database.executeQuery(querySQL, withArgumentsIn: []) else {
            return columnSet
        }

        while resultSet.next() {
            if let name = resultSet.string(forColumn: "name") {
                columnSet.insert(name)
            }
        }

        resultSet.close()

        return columnSet
    }

    static func addColumn(database: FMDatabase, tableName: String, columnName: String, columnType: String) -> Bool {
        let alterSQL = "ALTER TABLE \(tableName) ADD COLUMN \(columnName) \(columnType);"

        let result = database.executeUpdate(alterSQL, withArgumentsIn: [])
        if !result {
            print("[ERROR]: SQL = \(alterSQL)")
        }

        return result
    }

    static func queryTableIndexs(database: FMDatabase, tableName: String) -> Set<String> {
        var indexSet = Set<String>.init()

        let querySQL = """
        SELECT name FROM SQLITE_MASTER WHERE type = 'index' AND tbl_name = '\(tableName)' AND sql IS NOT NULL;
        """

        guard let resultSet = database.executeQuery(querySQL, withArgumentsIn: []) else {
            return indexSet
        }

        while resultSet.next() {
            if let name = resultSet.string(forColumn: "name") {
                indexSet.insert(name)
            }
        }

        resultSet.close()

        return indexSet
    }

    static func createIndex(database: FMDatabase,
                            indexName: String,
                            tableName: String,
                            indexColumnName: String) -> Bool {
        let createIndexSQL = "CREATE INDEX \(indexName) ON \(tableName)(\(indexColumnName));"

        let result = database.executeUpdate(createIndexSQL, withArgumentsIn: [])
        if !result {
            print("[ERROR]: SQL = \(createIndexSQL)")
        }

        return result
    }

    static func dropIndex(database: FMDatabase, indexName: String) -> Bool {
        let dropIndexSQL = "DROP INDEX \(indexName);"

        let result = database.executeUpdate(dropIndexSQL, withArgumentsIn: [])
        if !result {
            print("[ERROR]: SQL = \(dropIndexSQL)")
        }

        return result
    }
}
