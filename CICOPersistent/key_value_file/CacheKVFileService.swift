//
//  CICOCacheKVFileService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/6/12.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

private let kRootDirName = "cico_kv_file"

public class CacheKVFileService: KVFileService {
    public static let shared: CacheKVFileService = {
        let rootDirURL = CICOPathAide.defaultCacheFileURL(withSubPath: kRootDirName)!
        return CacheKVFileService.init(rootDirURL: rootDirURL)
    }()
}
