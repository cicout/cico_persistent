//
//  CICOORMProtocol.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/7/21.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

public protocol CICOORMProtocol {
    static func cicoORMPrimaryKeyName() -> String
}

public typealias CICOORMCodableProtocol = Codable & CICOORMProtocol
