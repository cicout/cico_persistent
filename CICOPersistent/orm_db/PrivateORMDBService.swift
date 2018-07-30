//
//  CICOPrivateORMDBService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/7/21.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

private let kDBSubPath = "cico_orm_db/db.sqlite"

public class PrivateORMDBService: ORMDBService {
    public static let shared: PrivateORMDBService = {
        let dbURL = CICOPathAide.defaultPrivateFileURL(withSubPath: kDBSubPath)!
        return PrivateORMDBService.init(fileURL: dbURL)
    }()
    
    public override func clearAll() -> Bool {
        print("[ERROR]: FORBIDDEN!")
        return false
    }
}
