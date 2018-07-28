//
//  CICOKVAide.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/7/28.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation
import CICOAutoCodable

class CICOKVJSONAide {
    static func transferJSONDataToObject<T: Codable>(_ jsonData: Data, objectType: T.Type) -> T? {
        let objectArray = [T].init(jsonData: jsonData)
        return objectArray?.first
    }
    
    static func transferObjectToJSONData<T: Codable>(_ object: T) -> Data? {
        return [object].toJSONData()
    }
}
