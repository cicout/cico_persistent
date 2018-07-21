//
//  CICOCachePersistentService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/6/7.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

private let kRootDirName = "cico_persistent"

public class CICOCachePersistentService: CICOPersistentService {
    public static let shared: CICOCachePersistentService = {
        let rootDirURL = CICOPathAide.defaultCacheFileURL(withSubPath: kRootDirName)!
        return CICOCachePersistentService.init(rootDirURL: rootDirURL)
    }()
}
