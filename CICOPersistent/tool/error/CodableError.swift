//
//  CodableError.swift
//  CICOPersistent
//
//  Created by lucky.li on 2019/12/28.
//  Copyright © 2019 cico. All rights reserved.
//

import Foundation

public enum CodableError: Int, Error {
    case decodeFailed = -800
    case encodeFailed = -801
}
