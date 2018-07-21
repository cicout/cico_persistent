//
//  CICOTempORMDBService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/7/21.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

private let kDBSubPath = "cico_orm_db/db.sqlite"

public class CICOTempORMDBService: CICOORMDBService {
    public static let shared: CICOTempORMDBService = {
        let dbURL = CICOPathAide.defaultTempFileURL(withSubPath: kDBSubPath)!
        return CICOTempORMDBService.init(fileURL: dbURL)
    }()
}
