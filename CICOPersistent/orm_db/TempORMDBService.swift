//
//  CICOTempORMDBService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/7/21.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

private let kDBSubPath = "cico_orm_db/db.sqlite"

public class TempORMDBService: ORMDBService {
    public static let shared: TempORMDBService = {
        let dbURL = CICOPathAide.defaultTempFileURL(withSubPath: kDBSubPath)!
        return TempORMDBService.init(fileURL: dbURL)
    }()
}
