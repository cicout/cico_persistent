//
//  CICOPublicKVDB.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/6/11.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

private let kDBSubPath = "json_db/db.sqlite"

public class CICOPublicKVDBService: CICOKVDBService {
    public static let shared: CICOPublicKVDBService = {
        return CICOPublicKVDBService.init(fileURL: CICOPublicKVDBService.dbFileURL())
    }()
    
    public static func dbFileURL() -> URL {
        return CICOPathAide.defaultPublicFileURL(withSubPath: kDBSubPath)
    }
}
