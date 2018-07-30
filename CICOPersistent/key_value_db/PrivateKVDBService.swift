//
//  CICOPrivateKVDB.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/6/12.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

private let kDBSubPath = "cico_kv_db/db.sqlite"

public class PrivateKVDBService: KVDBService {
    public static let shared: PrivateKVDBService = {
        let dbURL = CICOPathAide.defaultPrivateFileURL(withSubPath: kDBSubPath)!
        return PrivateKVDBService.init(fileURL: dbURL)
    }()
    
    public override func clearAll() -> Bool {
        print("[ERROR]: FORBIDDEN!")
        return false
    }
}
