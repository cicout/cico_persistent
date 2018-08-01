//
//  CICOsqliteType.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/7/3.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

enum SQLiteType: String {
    case NULL
    case INTEGER
    case REAL
    case TEXT
    case BLOB
}

extension Int8 {
    static var sqliteType: SQLiteType {
        return .INTEGER
    }
}

extension Int16 {
    static var sqliteType: SQLiteType {
        return .INTEGER
    }
}

extension Int32 {
    static var sqliteType: SQLiteType {
        return .INTEGER
    }
}

extension Int64 {
    static var sqliteType: SQLiteType {
        return .INTEGER
    }
}

extension Int {
    static var sqliteType: SQLiteType {
        return .INTEGER
    }
}

extension UInt8 {
    static var sqliteType: SQLiteType {
        return .INTEGER
    }
}

extension UInt16 {
    static var sqliteType: SQLiteType {
        return .INTEGER
    }
}

extension UInt32 {
    static var sqliteType: SQLiteType {
        return .INTEGER
    }
}

extension UInt64 {
    static var sqliteType: SQLiteType {
        return .INTEGER
    }
}

extension UInt {
    static var sqliteType: SQLiteType {
        return .INTEGER
    }
}

extension Bool {
    static var sqliteType: SQLiteType {
        return .INTEGER
    }
}

extension Float {
    static var sqliteType: SQLiteType {
        return .REAL
    }
}

extension Double {
    static var sqliteType: SQLiteType {
        return .REAL
    }
}

extension String {
    static var sqliteType: SQLiteType {
        return .TEXT
    }
}

extension Date {
    static var sqliteType: SQLiteType {
        return .REAL
    }
}

extension URL {
    static var sqliteType: SQLiteType {
        return .TEXT
    }
}
