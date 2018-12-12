//
//  KVDBServiceAide.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/12/12.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

private let kDBSubPath = "cico_kv_db/db.sqlite"

public class KVDBServiceAide {
    public static let publicService: KVDBService = {
        let dbURL = CICOPathAide.defaultPublicFileURL(withSubPath: kDBSubPath)
        return KVDBService.init(fileURL: dbURL)
    }()
    
    public static let privateService: KVDBService = {
        let dbURL = CICOPathAide.defaultPrivateFileURL(withSubPath: kDBSubPath)
        return KVDBService.init(fileURL: dbURL)
    }()
    
    public static let cacheService: KVDBService = {
        let dbURL = CICOPathAide.defaultCacheFileURL(withSubPath: kDBSubPath)
        return KVDBService.init(fileURL: dbURL)
    }()
    
    public static let tempService: KVDBService = {
        let dbURL = CICOPathAide.defaultTempFileURL(withSubPath: kDBSubPath)
        return KVDBService.init(fileURL: dbURL)
    }()
}
