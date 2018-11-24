//
//  CICOPublicKVDB.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/6/11.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

private let kDBSubPath = "cico_kv_db/db.sqlite"

public class PublicKVDBService: KVDBService {
    public static let shared: PublicKVDBService = {
        let dbURL = CICOPathAide.defaultPublicFileURL(withSubPath: kDBSubPath)
        return PublicKVDBService.init(fileURL: dbURL)
    }()
    
    public override func clearAll() -> Bool {
        print("[ERROR]: FORBIDDEN!")
        return false
    }
}
