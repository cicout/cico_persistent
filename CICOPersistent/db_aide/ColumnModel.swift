//
//  ColumnModel.swift
//  CICOPersistent
//
//  Created by Ethan.Li on 2020/3/26.
//  Copyright © 2020 cico. All rights reserved.
//

import Foundation

struct ColumnModel {
    let name: String
    let type: SQLiteType
    let isPrimaryKey: Bool
    let isAutoIncrement: Bool

    init(name: String,
         type: SQLiteType,
         isPrimaryKey: Bool = false,
         isAutoIncrement: Bool = false) {
        self.name = name
        self.type = type
        self.isPrimaryKey = isPrimaryKey
        self.isAutoIncrement = isAutoIncrement
    }
}
