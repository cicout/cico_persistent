//
//  KVFileServiceAide.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/12/12.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

private let kRootDirName = "cico_kv_file"

public class KVFileServiceAide {
    public static let publicService: KVFileService = {
        let rootDirURL = CICOPathAide.defaultPublicFileURL(withSubPath: kRootDirName)
        return KVFileService.init(rootDirURL: rootDirURL)
    }()
    
    public static let privateService: KVFileService = {
        let rootDirURL = CICOPathAide.defaultPrivateFileURL(withSubPath: kRootDirName)
        return KVFileService.init(rootDirURL: rootDirURL)
    }()
    
    public static let cacheService: KVFileService = {
        let rootDirURL = CICOPathAide.defaultCacheFileURL(withSubPath: kRootDirName)
        return KVFileService.init(rootDirURL: rootDirURL)
    }()
    
    public static let tempService: KVFileService = {
        let rootDirURL = CICOPathAide.defaultTempFileURL(withSubPath: kRootDirName)
        return KVFileService.init(rootDirURL: rootDirURL)
    }()
}
