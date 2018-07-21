//
//  CICOPrivateORMDBService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/7/21.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

private let kDBSubPath = "cico_orm_db/db.sqlite"

public class CICOPrivateORMDBService: CICOORMDBService {
    public static let shared: CICOPrivateORMDBService = {
        let dbURL = CICOPathAide.defaultPrivateFileURL(withSubPath: kDBSubPath)!
        return CICOPrivateORMDBService.init(fileURL: dbURL)
    }()
}
