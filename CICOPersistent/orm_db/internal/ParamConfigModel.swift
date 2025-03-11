//
//  ParamConfigModel.swift
//  CICOPersistent
//
//  Created by lucky.li on 2019/8/23.
//  Copyright © 2019 cico. All rights reserved.
//

import Foundation

struct ParamConfigModel {
    let tableName: String
    let primaryKeyColumnName: CompositeType<String>
    let indexColumnNameArray: [String]?
    let objectTypeVersion: Int
    let autoIncrement: Bool
}
