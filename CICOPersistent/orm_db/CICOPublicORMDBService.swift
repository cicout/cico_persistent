//
//  CICOPublicORMDBService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/7/21.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

private let kDBSubPath = "cico_orm_db/db.sqlite"

public class CICOPublicORMDBService: CICOORMDBService {
    public static let shared: CICOPublicORMDBService = {
        let dbURL = CICOPathAide.defaultPublicFileURL(withSubPath: kDBSubPath)!
        return CICOPublicORMDBService.init(fileURL: dbURL)
    }()
}
