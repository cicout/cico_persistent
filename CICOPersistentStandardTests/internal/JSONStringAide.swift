//
//  JSONStringAide.swift
//  CICOPersistentTests
//
//  Created by lucky.li on 2018/8/4.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

class JSONStringAide {
    static func jsonString(name: String) -> String {
        let bundle = Bundle.init(for: JSONStringAide.self)

        guard let path = bundle.path(forResource: name, ofType: "json") else {
            return ""
        }

        guard let jsonString = try? String(contentsOfFile: path, encoding: String.Encoding.utf8) else {
            return ""
        }

        return jsonString
    }
}
