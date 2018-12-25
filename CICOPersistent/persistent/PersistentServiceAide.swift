//
//  PersistentServiceAide.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/12/12.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

private let kRootDirName = "cico_persistent"

///
/// It defines four shared persistent service, you can use them directly;
///
public class PersistentServiceAide {
    /// Public shared persistent service;
    ///
    /// It is convenient for debuging, not recommended for release products;
    ///
    /// - see: CICOPathAide.defaultPublicFileURL(withSubPath:)
    public static let publicService: PersistentService = {
        let rootDirURL = CICOPathAide.defaultPublicFileURL(withSubPath: kRootDirName)
        return PersistentService.init(rootDirURL: rootDirURL)
    }()
    
    /// Private shared persistent service;
    ///
    /// It is recommended as default;
    ///
    /// - see: CICOPathAide.defaultPrivateFileURL(withSubPath:)
    public static let privateService: PersistentService = {
        let rootDirURL = CICOPathAide.defaultPrivateFileURL(withSubPath: kRootDirName)
        return PersistentService.init(rootDirURL: rootDirURL)
    }()
    
    /// Cache shared persistent service;
    ///
    /// It is recommended for caching;
    ///
    /// - see: CICOPathAide.defaultCacheFileURL(withSubPath:)
    public static let cacheService: PersistentService = {
        let rootDirURL = CICOPathAide.defaultCacheFileURL(withSubPath: kRootDirName)
        return PersistentService.init(rootDirURL: rootDirURL)
    }()
    
    /// Temp shared persistent service;
    ///
    /// It is recommended for temporary objects;
    ///
    /// - see: CICOPathAide.defaultTempFileURL(withSubPath:)
    public static let tempService: PersistentService = {
        let rootDirURL = CICOPathAide.defaultTempFileURL(withSubPath: kRootDirName)
        return PersistentService.init(rootDirURL: rootDirURL)
    }()
}
