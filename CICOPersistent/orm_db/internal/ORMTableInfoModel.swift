//
//  CICOORMTableInfoModel.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/7/24.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

class ORMTableInfoModel {
    let tableName: String
    let objectTypeName: String
    let objectTypeVersion: Int
    
    deinit {}
    
    init(tableName: String, objectTypeName: String, objectTypeVersion: Int) {
        self.tableName = tableName
        self.objectTypeName = objectTypeName
        self.objectTypeVersion = objectTypeVersion
    }
}
