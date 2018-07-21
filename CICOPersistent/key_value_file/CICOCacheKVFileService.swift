//
//  CICOCacheKVFileService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/6/12.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

private let kRootDirName = "cico_kv_file"

public class CICOCacheKVFileService: CICOKVFileService {
    public static let shared: CICOCacheKVFileService = {
        let rootDirURL = CICOPathAide.defaultCacheFileURL(withSubPath: kRootDirName)!
        return CICOCacheKVFileService.init(rootDirURL: rootDirURL)
    }()
}
