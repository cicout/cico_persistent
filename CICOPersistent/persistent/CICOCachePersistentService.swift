//
//  CICOCachePersistentService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/6/7.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

private let kRootDirName = "cache"

public class CICOCachePersistentService: CICOBasePersistentService {
    public static let shared: CICOCachePersistentService = {
        return CICOCachePersistentService.init(rootDirURL: CICOCachePersistentService.cacheDirURL())
    }()
    
    public static func cacheDirURL() -> URL {
        return CICOPathAide.docFileURL(withSubPath: kRootDirName)
    }
    
    public func clearAll() -> Bool {
        let removeResult = CICOPathAide.removeFile(with: self.rootDirURL)
        let createResult = CICOPathAide.createDir(with: self.rootDirURL, option: true)
        return (removeResult && createResult)
    }
}
