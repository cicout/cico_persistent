//
//  ORMTableInfoAide.swift
//  CICOPersistent
//
//  Created by lucky.li on 2019/8/26.
//  Copyright © 2019 cico. All rights reserved.
//

import Foundation
import FMDB

private let kORMTableName = "cico_orm_table_info"

class ORMTableInfoAide {
    static func isTableExist(database: FMDatabase, objectTypeName: String, tableName: String) -> Bool {
        if self.readORMTableInfo(database: database, objectTypeName: objectTypeName, tableName: tableName) != nil {
            return true
        } else {
            return false
        }
    }

    static func createORMTableInfoTableIfNotExists(database: FMDatabase) -> Bool {
        let primaryKeyColumnName = ORMTableInfoModel.cicoORMPrimaryKeyColumnName()

        return ORMDBServiceInnerAide.createTableIfNotExists(database: database,
                                                            objectType: ORMTableInfoModel.self,
                                                            tableName: kORMTableName,
                                                            primaryKeyColumnName: primaryKeyColumnName)
    }

    static func readORMTableInfo(database: FMDatabase,
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

    static func writeORMTableInfo(database: FMDatabase, tableInfo: ORMTableInfoModel) -> Bool {
        return ORMDBServiceInnerAide.replaceRecord(database: database,
                                                   tableName: kORMTableName,
                                                   object: tableInfo)
    }

    static func removeORMTableInfo(database: FMDatabase, tableName: String) -> Bool {
        let primaryKeyColumnName = ORMTableInfoModel.cicoORMPrimaryKeyColumnName()
        return ORMDBServiceInnerAide.deleteRecord(database: database,
                                                  tableName: kORMTableName,
                                                  primaryKeyColumnName: primaryKeyColumnName,
                                                  primaryKeyValue: tableName)
    }
}
