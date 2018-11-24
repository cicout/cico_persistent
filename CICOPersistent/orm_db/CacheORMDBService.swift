//
//  CICOCacheORMDBService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/7/21.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

private let kDBSubPath = "cico_orm_db/db.sqlite"

public class CacheORMDBService: ORMDBService {
    public static let shared: CacheORMDBService = {
        let dbURL = CICOPathAide.defaultCacheFileURL(withSubPath: kDBSubPath)
        return CacheORMDBService.init(fileURL: dbURL)
    }()
}
