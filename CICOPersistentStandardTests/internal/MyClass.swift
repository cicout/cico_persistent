//
//  MyClass.swift
//  CICOAutoCodable
//
//  Created by lucky.li on 2018/8/7.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation
import CICOAutoCodable
import CICOPersistent

enum MyEnum: String, CICOAutoCodable {
    case one
    case two
}

class MyClass: CICOAutoCodable {
    var stringValue: String = "default_string"
    private(set) var dateValue: Date?
    private(set) var intValue: Int = 0
    private(set) var doubleValue: Double = 1.0
    private(set) var boolValue: Bool = false
    private(set) var enumValue: MyEnum = .one
    private(set) var urlValue: URL?
    private(set) var nextValue: MyClass?
    private(set) var arrayValue: [String]?
    private(set) var dicValue: [String: String]?
}

extension MyClass: ORMProtocol {
    static func ormPrimaryKeyColumnName() -> String {
        return "stringValue"
    }
}
