//
//  CICOPrivateKVDB.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/6/12.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

private let kDBSubPath = "json_db/db.sqlite"

public class CICOPrivateKVDBService: CICOKVDBService {
    public static let shared: CICOPrivateKVDBService = {
        return CICOPrivateKVDBService.init(fileURL: CICOPrivateKVDBService.dbFileURL())
    }()
    
    public static func dbFileURL() -> URL {
        return CICOPathAide.defaultPrivateFileURL(withSubPath: kDBSubPath)
    }
}
