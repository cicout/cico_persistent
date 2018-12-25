//
//  ORMDBServiceAide.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/12/12.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

private let kDBSubPath = "cico_orm_db/db.sqlite"

///
/// It defines four shared ORM database service, you can use them directly;
///
public class ORMDBServiceAide {
    /// Public shared ORM database service;
    ///
    /// It is convenient for debuging, not recommended for release products;
    ///
    /// - see: CICOPathAide.defaultPublicFileURL(withSubPath:)
    public static let publicService: ORMDBService = {
        let dbURL = CICOPathAide.defaultPublicFileURL(withSubPath: kDBSubPath)
        return ORMDBService.init(fileURL: dbURL)
    }()
    
    /// Private shared ORM database service;
    ///
    /// It is recommended as default;
    ///
    /// - see: CICOPathAide.defaultPrivateFileURL(withSubPath:)
    public static let privateService: ORMDBService = {
        let dbURL = CICOPathAide.defaultPrivateFileURL(withSubPath: kDBSubPath)
        return ORMDBService.init(fileURL: dbURL)
    }()
    
    /// Cache shared ORM database service;
    ///
    /// It is recommended for caching;
    ///
    /// - see: CICOPathAide.defaultCacheFileURL(withSubPath:)
    public static let cacheService: ORMDBService = {
        let dbURL = CICOPathAide.defaultCacheFileURL(withSubPath: kDBSubPath)
        return ORMDBService.init(fileURL: dbURL)
    }()
    
    /// Temp shared ORM database service;
    ///
    /// It is recommended for temporary objects;
    ///
    /// - see: CICOPathAide.defaultTempFileURL(withSubPath:)
    public static let tempService: ORMDBService = {
        let dbURL = CICOPathAide.defaultTempFileURL(withSubPath: kDBSubPath)
        return ORMDBService.init(fileURL: dbURL)
    }()
}
