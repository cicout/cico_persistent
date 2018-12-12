//
//  PersistentServiceAide.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/12/12.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

private let kRootDirName = "cico_persistent"

public class PersistentServiceAide {
    public static let publicService: PersistentService = {
        let rootDirURL = CICOPathAide.defaultPublicFileURL(withSubPath: kRootDirName)
        return PersistentService.init(rootDirURL: rootDirURL)
    }()
    
    public static let privateService: PersistentService = {
        let rootDirURL = CICOPathAide.defaultPrivateFileURL(withSubPath: kRootDirName)
        return PersistentService.init(rootDirURL: rootDirURL)
    }()
    
    public static let cacheService: PersistentService = {
        let rootDirURL = CICOPathAide.defaultCacheFileURL(withSubPath: kRootDirName)
        return PersistentService.init(rootDirURL: rootDirURL)
    }()
    
    public static let tempService: PersistentService = {
        let rootDirURL = CICOPathAide.defaultTempFileURL(withSubPath: kRootDirName)
        return PersistentService.init(rootDirURL: rootDirURL)
    }()
}
