//
//  KVDBServiceAide.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/12/12.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

private let kDBSubPath = "cico_kv_db/db.sqlite"

///
/// It defines four shared Key-Value database service, you can use them directly;
///
public class KVDBServiceAide {
    /// Public shared Key-Value database service;
    ///
    /// It is convenient for debuging, not recommended for release products;
    ///
    /// - see: CICOPathAide.defaultPublicFileURL(withSubPath:)
    public static let publicService: KVDBService = {
        let dbURL = CICOPathAide.defaultPublicFileURL(withSubPath: kDBSubPath)
        return KVDBService.init(fileURL: dbURL)
    }()

    /// Private shared Key-Value database service;
    ///
    /// It is recommended as default;
    ///
    /// - see: CICOPathAide.defaultPrivateFileURL(withSubPath:)
    public static let privateService: KVDBService = {
        let dbURL = CICOPathAide.defaultPrivateFileURL(withSubPath: kDBSubPath)
        return KVDBService.init(fileURL: dbURL)
    }()

    /// Cache shared Key-Value database service;
    ///
    /// It is recommended for caching;
    ///
    /// - see: CICOPathAide.defaultCacheFileURL(withSubPath:)
    public static let cacheService: KVDBService = {
        let dbURL = CICOPathAide.defaultCacheFileURL(withSubPath: kDBSubPath)
        return KVDBService.init(fileURL: dbURL)
    }()

    /// Temp shared Key-Value database service;
    ///
    /// It is recommended for temporary objects;
    ///
    /// - see: CICOPathAide.defaultTempFileURL(withSubPath:)
    public static let tempService: KVDBService = {
        let dbURL = CICOPathAide.defaultTempFileURL(withSubPath: kDBSubPath)
        return KVDBService.init(fileURL: dbURL)
    }()
}
