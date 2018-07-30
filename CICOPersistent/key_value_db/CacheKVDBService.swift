//
//  CICOCacheKVDB.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/6/12.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

private let kDBSubPath = "cico_kv_db/db.sqlite"

public class CacheKVDBService: KVDBService {
    public static let shared: CacheKVDBService = {
        let dbURL = CICOPathAide.defaultCacheFileURL(withSubPath: kDBSubPath)!
        return CacheKVDBService.init(fileURL: dbURL)
    }()
}
