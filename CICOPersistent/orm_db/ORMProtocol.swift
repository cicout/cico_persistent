//
//  CICOORMProtocol.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/7/21.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

public enum CompositeType<T> {
    case single(T)
    case composite([T])
}

public protocol ORMProtocol {
    /// You must choose one primary key name from the codable properties in your class or struct;
    static func ormPrimaryKeyColumnName() -> CompositeType<String>

    /// You can define some index column from the codable properties in your class or struct;
    static func ormIndexColumnNameArray() -> [String]?

    /// You can use version number to upgrade database automaticaly
    /// when you add/delete/update any codable property in your class or struct;
    /// What you need to do is just increase this version number.
    /// The default version number is 1;
    static func ormObjectTypeVersion() -> Int

    /// You can define auto increment for integer primary key;
    /// It works only if the primary key is integer;
    static func ormIntegerPrimaryKeyAutoIncrement() -> Bool
}

public extension ORMProtocol {
    static func ormIndexColumnNameArray() -> [String]? {
        return nil
    }

    static func ormObjectTypeVersion() -> Int {
        return 1
    }

    static func ormIntegerPrimaryKeyAutoIncrement() -> Bool {
        return false
    }
}

public typealias ORMCodableProtocol = Codable & ORMProtocol
