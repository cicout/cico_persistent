//
//  TDoubleStruct.swift
//  CICOPersistentTests
//
//  Created by Ethan.Li on 2020/7/17.
//  Copyright © 2020 cico. All rights reserved.
//

import Foundation

struct TDoubleStruct: Codable {
    var one: Double
    var two: Double
    var three: Double
}

extension TDoubleStruct: CustomStringConvertible {
    var description: String {
        return "<TDoubleStruct>: one = \(self.one), two = \(self.two), three = \(self.three)"
    }
}
