//
//  KVDBServiceAide.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/12/12.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation
import CICOFoundationKit

private let kDBSubPath = "cico_kv_db/db.sqlite"

///
/// It defines four shared Key-Value database service, you can use them directly;
///
public class KVDBServiceAide {
    /// Public shared Key-Value database service;
    ///
    /// It is convenient for debuging, not recommended for release products;
    ///
    /// - see: PathAide.defaultPublicFileURL(withSubPath:)
    public static let publicService: KVDBService = {
        let dbURL = PathAide.defaultPublicFileURL(withSubPath: kDBSubPath)
        return KVDBService.init(fileURL: dbURL)
    }()

    /// Private shared Key-Value database service;
    ///
    /// It is recommended as default;
    ///
    /// - see: PathAide.defaultPrivateFileURL(withSubPath:)
    public static let privateService: KVDBService = {
        let dbURL = PathAide.defaultPrivateFileURL(withSubPath: kDBSubPath)
        return KVDBService.init(fileURL: dbURL)
    }()

    /// Cache shared Key-Value database service;
    ///
    /// It is recommended for caching;
    ///
    /// - see: PathAide.defaultCacheFileURL(withSubPath:)
    public static let cacheService: KVDBService = {
        let dbURL = PathAide.defaultCacheFileURL(withSubPath: kDBSubPath)
        return KVDBService.init(fileURL: dbURL)
    }()

    /// Temp shared Key-Value database service;
    ///
    /// It is recommended for temporary objects;
    ///
    /// - see: PathAide.defaultTempFileURL(withSubPath:)
    public static let tempService: KVDBService = {
        let dbURL = PathAide.defaultTempFileURL(withSubPath: kDBSubPath)
        return KVDBService.init(fileURL: dbURL)
    }()
}
