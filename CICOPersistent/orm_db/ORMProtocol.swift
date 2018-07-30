//
//  CICOORMProtocol.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/7/21.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

public protocol ORMProtocol {
    static func cicoORMPrimaryKeyColumnName() -> String
    static func cicoORMIndexColumnNameArray() -> [String]?
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
