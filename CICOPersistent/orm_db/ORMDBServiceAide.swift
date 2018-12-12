//
//  ORMDBServiceAide.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/12/12.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

private let kDBSubPath = "cico_orm_db/db.sqlite"

public class ORMDBServiceAide {
    public static let publicService: ORMDBService = {
        let dbURL = CICOPathAide.defaultPublicFileURL(withSubPath: kDBSubPath)
        return ORMDBService.init(fileURL: dbURL)
    }()
    
    public static let privateService: ORMDBService = {
        let dbURL = CICOPathAide.defaultPrivateFileURL(withSubPath: kDBSubPath)
        return ORMDBService.init(fileURL: dbURL)
    }()
    
    public static let cacheService: ORMDBService = {
        let dbURL = CICOPathAide.defaultCacheFileURL(withSubPath: kDBSubPath)
        return ORMDBService.init(fileURL: dbURL)
    }()
    
    public static let tempService: ORMDBService = {
        let dbURL = CICOPathAide.defaultTempFileURL(withSubPath: kDBSubPath)
        return ORMDBService.init(fileURL: dbURL)
    }()
}
