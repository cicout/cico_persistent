//
//  TAutoIncrement.swift
//  CICOPersistentTests
//
//  Created by lucky.li on 2020/3/25.
//  Copyright © 2020 cico. All rights reserved.
//

import Foundation
import CICOAutoCodable
import CICOPersistent

struct TAutoIncrement: CICOAutoCodable {
    let rowID: Int?
    var stringValue: String

    init(stringValue: String) {
        self.rowID = nil
        self.stringValue = stringValue
    }
}

extension TAutoIncrement: ORMProtocol {
    static func cicoORMPrimaryKeyColumnName() -> String {
        return "rowID"
    }

    static func cicoORMIntegerPrimaryKeyAutoIncrement() -> Bool {
        return true
    }
}
