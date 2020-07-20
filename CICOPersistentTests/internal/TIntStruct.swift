//
//  TIntStruct.swift
//  CICOPersistentTests
//
//  Created by Ethan.Li on 2020/7/17.
//  Copyright © 2020 cico. All rights reserved.
//

import Foundation

struct TIntStruct: Codable {
    var one: Int
    var two: Int32
    var three: Int64
}

extension TIntStruct: CustomStringConvertible {
    var description: String {
        return "<TIntStruct>: one = \(self.one), two = \(self.two), three = \(self.three)"
    }
}
