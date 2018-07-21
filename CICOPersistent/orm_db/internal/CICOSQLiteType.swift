//
//  CICOsqliteType.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/7/3.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

enum CICOSQLiteType: String {
    case NULL
    case INTEGER
    case REAL
    case TEXT
    case BLOB
}

extension Int8 {
    static var sqliteType: CICOSQLiteType {
        return .INTEGER
    }
}

extension Int16 {
    static var sqliteType: CICOSQLiteType {
        return .INTEGER
    }
}

extension Int32 {
    static var sqliteType: CICOSQLiteType {
        return .INTEGER
    }
}

extension Int64 {
    static var sqliteType: CICOSQLiteType {
        return .INTEGER
    }
}

extension Int {
    static var sqliteType: CICOSQLiteType {
        return .INTEGER
    }
}

extension UInt8 {
    static var sqliteType: CICOSQLiteType {
        return .INTEGER
    }
}

extension UInt16 {
    static var sqliteType: CICOSQLiteType {
        return .INTEGER
    }
}

extension UInt32 {
    static var sqliteType: CICOSQLiteType {
        return .INTEGER
    }
}

extension UInt64 {
    static var sqliteType: CICOSQLiteType {
        return .INTEGER
    }
}

extension UInt {
    static var sqliteType: CICOSQLiteType {
        return .INTEGER
    }
}

extension Bool {
    static var sqliteType: CICOSQLiteType {
        return .INTEGER
    }
}

extension Float {
    static var sqliteType: CICOSQLiteType {
        return .REAL
    }
}

extension Double {
    static var sqliteType: CICOSQLiteType {
        return .REAL
    }
}

extension String {
    static var sqliteType: CICOSQLiteType {
        return .TEXT
    }
}

extension Date {
    static var sqliteType: CICOSQLiteType {
        return .REAL
    }
}

extension Decodable {
    static var sqliteType: CICOSQLiteType {
        return .BLOB
    }
}

extension Encodable {
    static var sqliteType: CICOSQLiteType {
        return .BLOB
    }
}
