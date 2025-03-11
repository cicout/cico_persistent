//
//  TCompositeStruct.swift
//  CICOPersistent
//
//  Created by Ethan.Li on 2025/3/11.
//  Copyright © 2025 cico. All rights reserved.
//

import CICOAutoCodable
import CICOPersistent

struct TCompositeStruct: Codable, AutoEquatable {
    var stringID: String
    var intID: Int
    var name: String?
}

extension TCompositeStruct: ORMProtocol {
    static func ormPrimaryKeyColumnName() -> CompositeType<String> {
        return .composite(["stringID", "intID"])
    }
}
