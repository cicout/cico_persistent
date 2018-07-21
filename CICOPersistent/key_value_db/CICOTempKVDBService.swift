//
//  CICOTempKVDB.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/6/12.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

private let kDBSubPath = "cico_kv_db/db.sqlite"

public class CICOTempKVDBService: CICOKVDBService {
    public static let shared: CICOTempKVDBService = {
        let dbURL = CICOPathAide.defaultTempFileURL(withSubPath: kDBSubPath)!
        return CICOTempKVDBService.init(fileURL: dbURL)
    }()
}
