//
//  KVTableService.swift
//  CICOPersistent
//
//  Created by Ethan.Li on 2020/3/26.
//  Copyright © 2020 cico. All rights reserved.
//

import Foundation
import CICOFoundationKit
import FMDB

private let kJSONKeyColumnName = "json_key"
private let kJSONDataColumnName = "json_data"
private let kUpdateTimeColumnName = "update_time"

class KVTableService {
    let tableName: String

    deinit {
        print("\(self) deinit")
    }

    init(tableName: String) {
        self.tableName = tableName
    }

    func createTableIfNotExists(database: FMDatabase) -> Bool {
        let isTableExist = DBAide.isTableExist(database: database, tableName: self.tableName)

        guard !isTableExist else {
            return true
        }

        let columnArray: [ColumnModel] = [
            ColumnModel.init(name: kJSONKeyColumnName, type: .TEXT, isPrimaryKey: true),
            ColumnModel.init(name: kJSONDataColumnName, type: .BLOB),
            ColumnModel.init(name: kUpdateTimeColumnName, type: .REAL)
        ]

        return DBAide.createTableIfNotExists(database: database, tableName: self.tableName, columnArray: columnArray)
    }

    func readObject<T: Codable>(database: FMDatabase, objectType: T.Type, userKey: String) -> T? {
        guard let jsonKey = self.jsonKey(forUserKey: userKey) else {
            return nil
        }

        guard let jsonData = self.readJSONData(database: database, jsonKey: jsonKey) else {
            return nil
        }

        return KVJSONAide.transferJSONDataToObject(jsonData, objectType: objectType)
    }

    func writeObject<T: Codable>(database: FMDatabase, object: T, userKey: String) -> Bool {
        guard let jsonKey = self.jsonKey(forUserKey: userKey) else {
            return false
        }

        guard let jsonData = KVJSONAide.transferObjectToJSONData(object) else {
            return false
        }

        return self.writeJSONData(database: database, jsonData: jsonData, jsonKey: jsonKey)
    }

    func updateObject<T: Codable>(database: FMDatabase,
                                  objectType: T.Type,
                                  userKey: String,
                                  updateClosure: (T?) -> T?) -> Bool {
        var result = false

        var object: T?

        // read
        object = self.readObject(database: database, objectType: objectType, userKey: userKey)

        // update
        guard let newObject = updateClosure(object) else {
            result = true
            return result
        }

        // write
        result = self.writeObject(database: database, object: newObject, userKey: userKey)

        return result
    }

    func removeObject(database: FMDatabase, userKey: String) -> Bool {
        guard let jsonKey = self.jsonKey(forUserKey: userKey) else {
            return false
        }

        return self.removeJSONData(database: database, jsonKey: jsonKey)
    }

    func clearAll(database: FMDatabase) -> Bool {
        let result = DBAide.dropTable(database: database, tableName: self.tableName)
        return result
    }

    private func jsonKey(forUserKey userKey: String) -> String? {
        guard userKey.count > 0 else {
            return nil
        }

        return SecurityAide.md5HashString(userKey)
    }

    private func readJSONData(database: FMDatabase, jsonKey: String) -> Data? {
        var jsonData: Data?

        let querySQL = "SELECT * FROM \(self.tableName) WHERE \(kJSONKeyColumnName) = ? LIMIT 1;"

        guard let resultSet = database.executeQuery(querySQL, withArgumentsIn: [jsonKey]) else {
            return jsonData
        }

        if resultSet.next() {
            jsonData = resultSet.data(forColumn: kJSONDataColumnName)
        }

        resultSet.close()

        return jsonData
    }

    private func writeJSONData(database: FMDatabase, jsonData: Data, jsonKey: String) -> Bool {
        var result = false

        result = self.createTableIfNotExists(database: database)
        if !result {
            return result
        }

        let updateTime = Date().timeIntervalSinceReferenceDate
        let updateSQL = """
        REPLACE INTO \(self.tableName) (\(kJSONKeyColumnName),
        \(kJSONDataColumnName),
        \(kUpdateTimeColumnName)) VALUES (?, ?, ?);
        """
        result = database.executeUpdate(updateSQL, withArgumentsIn: [jsonKey, jsonData, updateTime])
        if !result {
            print("[ERROR]: SQL = \(updateSQL)")
        }

        return result
    }

    private func removeJSONData(database: FMDatabase, jsonKey: String) -> Bool {
        var result = false

        let deleteSQL = "DELETE FROM \(self.tableName) WHERE \(kJSONKeyColumnName) = ?;"
        result = database.executeUpdate(deleteSQL, withArgumentsIn: [jsonKey])
        if !result {
            print("[ERROR]: SQL = \(deleteSQL)")
        }

        return result
    }
}

extension KVTableService {
    func readObject<T: Codable>(dbQueue: FMDatabaseQueue?, objectType: T.Type, userKey: String) -> T? {
        var object: T?

        dbQueue?.inDatabase({ (database) in
            object = self.readObject(database: database, objectType: objectType, userKey: userKey)
        })

        return object
    }

    func writeObject<T: Codable>(dbQueue: FMDatabaseQueue?, object: T, userKey: String) -> Bool {
        var result = false

        dbQueue?.inTransaction({ (database, rollback) in
            result = self.writeObject(database: database, object: object, userKey: userKey)
            if !result {
                rollback.pointee = true
            }
        })

        return result
    }

    func updateObject<T: Codable>(dbQueue: FMDatabaseQueue?,
                                  objectType: T.Type,
                                  userKey: String,
                                  updateClosure: (T?) -> T?,
                                  completionClosure: ((Bool) -> Void)? = nil) {
        dbQueue?.inTransaction({ (database, rollback) in
            let result = self.updateObject(database: database,
                                           objectType: objectType,
                                           userKey: userKey,
                                           updateClosure: updateClosure)

            if !result {
                rollback.pointee = true
            }

            completionClosure?(result)
        })
    }

    func removeObject(dbQueue: FMDatabaseQueue?, userKey: String) -> Bool {
        var result = false

        dbQueue?.inDatabase { (database) in
            result = self.removeObject(database: database, userKey: userKey)
        }

        return result
    }

    func clearAll(dbQueue: FMDatabaseQueue?) -> Bool {
        var result = false

        dbQueue?.inDatabase { (database) in
            result = self.clearAll(database: database)
            if !result {
                return
            }

            result = self.createTableIfNotExists(database: database)
        }

        return result
    }
}
