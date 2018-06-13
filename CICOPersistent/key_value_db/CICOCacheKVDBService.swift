//
//  CICOCacheKVDB.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/6/12.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

private let kDBSubPath = "json_db/db.sqlite"

public class CICOCacheKVDBService: CICOKVDBService {
    public static let shared: CICOCacheKVDBService = {
        return CICOCacheKVDBService.init(fileURL: CICOCacheKVDBService.dbFileURL())
    }()
    
    public static func dbFileURL() -> URL {
        return CICOPathAide.defaultCacheFileURL(withSubPath: kDBSubPath)
    }
    
//    public func clearAll() -> Bool {
//        let removeResult = CICOPathAide.removeFile(with: self.rootDirURL)
//        let createResult = CICOPathAide.createDir(with: self.rootDirURL, option: true)
//        return (removeResult && createResult)
//    }
}
