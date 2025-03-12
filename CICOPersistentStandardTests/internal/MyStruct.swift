//
//  MyStruct.swift
//  CICOAutoCodable
//
//  Created by lucky.li on 2018/8/7.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation
import CICOPersistent

enum MyEnum: String, Codable {
    case one
    case two
}

struct MyStruct: Codable {
    var stringValue: String = "default_string"
    var dateValue: Date?
    var intValue: Int = 0
    var doubleValue: Double = 1.0
    var boolValue: Bool = false
    var enumValue: MyEnum = .one
    var urlValue: URL?
    var arrayValue: [String]?
    var dicValue: [String: String]?
}

extension MyStruct: ORMProtocol {
    static func ormPrimaryKeyColumnName() -> CompositeType<String> {
        return .single("stringValue")
    }
}
