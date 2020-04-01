//
//  CICOORMTableInfoModel.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/7/24.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation
import CICOAutoCodable

struct ORMTableInfoModel: CICOAutoCodable {
    let tableName: String
    let objectTypeName: String
    let objectTypeVersion: Int

    init(tableName: String, objectTypeName: String, objectTypeVersion: Int) {
        self.tableName = tableName
        self.objectTypeName = objectTypeName
        self.objectTypeVersion = objectTypeVersion
    }
}

extension ORMTableInfoModel {
    enum CodingKeys: String, CodingKey {
        case tableName = "table_name"
        case objectTypeName = "object_type_name"
        case objectTypeVersion = "object_type_version"
    }
}

extension ORMTableInfoModel: ORMProtocol {
    static func ormPrimaryKeyColumnName() -> String {
        return CodingKeys.tableName.stringValue
    }
}
