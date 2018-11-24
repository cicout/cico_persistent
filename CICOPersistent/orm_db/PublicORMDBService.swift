//
//  CICOPublicORMDBService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/7/21.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

private let kDBSubPath = "cico_orm_db/db.sqlite"

public class PublicORMDBService: ORMDBService {
    public static let shared: PublicORMDBService = {
        let dbURL = CICOPathAide.defaultPublicFileURL(withSubPath: kDBSubPath)
        return PublicORMDBService.init(fileURL: dbURL)
    }()
    
    public override func clearAll() -> Bool {
        print("[ERROR]: FORBIDDEN!")
        return false
    }
}
