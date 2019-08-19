//
//  CICOTypeProperty.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/7/13.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

class TypeProperty {
    let name: String
    let swiftType: Any.Type
    let sqliteType: SQLiteType
    let value: Any

    var description: String {
        return "name: \(self.name)\nswiftType: \(self.swiftType)\nsqliteType: \(self.sqliteType)\nvalue: \(self.value)"
    }

    init(name: String, swiftType: Any.Type, sqliteType: SQLiteType, value: Any) {
        self.name = name
        self.swiftType = swiftType
        self.sqliteType = sqliteType
        self.value = value
    }
}
