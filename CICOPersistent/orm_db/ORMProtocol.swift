//
//  CICOORMProtocol.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/7/21.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

public protocol ORMProtocol {
    /// You must choose one primary key name from the codable properties in your class or struct;
    static func cicoORMPrimaryKeyColumnName() -> String

    /// You can define some index column from the codable properties in your class or struct;
    static func cicoORMIndexColumnNameArray() -> [String]?

    /// You can use version number to upgrade database automaticaly
    /// when you add/delete/update any codable property in your class or struct;
    /// What you need to do is just increase this version number.
    /// The default version number is 1;
    static func cicoORMObjectTypeVersion() -> Int
}

public extension ORMProtocol {
    static func cicoORMIndexColumnNameArray() -> [String]? {
        return nil
    }

    static func cicoORMObjectTypeVersion() -> Int {
        return 1
    }
}

public typealias CICOORMCodableProtocol = Codable & ORMProtocol
