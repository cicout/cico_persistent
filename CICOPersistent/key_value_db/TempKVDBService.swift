//
//  CICOTempKVDB.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/6/12.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

private let kDBSubPath = "cico_kv_db/db.sqlite"

public class TempKVDBService: KVDBService {
    public static let shared: TempKVDBService = {
        let dbURL = CICOPathAide.defaultTempFileURL(withSubPath: kDBSubPath)!
        return TempKVDBService.init(fileURL: dbURL)
    }()
}
