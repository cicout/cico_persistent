//
//  CICOCachePersistentService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/6/7.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

private let kRootDirName = "cico_persistent"

public class CachePersistentService: PersistentService {
    public static let shared: CachePersistentService = {
        let rootDirURL = CICOPathAide.defaultCacheFileURL(withSubPath: kRootDirName)
        return CachePersistentService.init(rootDirURL: rootDirURL)
    }()
}
