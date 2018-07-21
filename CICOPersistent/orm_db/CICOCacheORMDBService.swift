//
//  CICOCacheORMDBService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/7/21.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

private let kDBSubPath = "cico_orm_db/db.sqlite"

public class CICOCacheORMDBService: CICOORMDBService {
    public static let shared: CICOCacheORMDBService = {
        let dbURL = CICOPathAide.defaultCacheFileURL(withSubPath: kDBSubPath)!
        return CICOCacheORMDBService.init(fileURL: dbURL)
    }()
}
