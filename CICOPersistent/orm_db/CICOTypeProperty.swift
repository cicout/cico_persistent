//
//  CICOTypeProperty.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/7/13.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

class CICOTypeProperty {
    let name: String
    let swiftType: Any.Type
    let sqliteType: CICOSQLiteType
    
    var description: String {
        return "(\(self.name), \(self.swiftType), \(self.sqliteType))"
    }
    
    init(name: String, swiftType: Any.Type, sqliteType: CICOSQLiteType) {
        self.name = name
        self.swiftType = swiftType
        self.sqliteType = sqliteType
    }
}
