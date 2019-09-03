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
    /// - see: PathAide.defaultPublicFileURL(withSubPath:)
    public static let publicService: PersistentService = {
        let rootDirURL = PathAide.defaultPublicFileURL(withSubPath: kRootDirName)
        return PersistentService.init(rootDirURL: rootDirURL)
    }()

    /// Private shared persistent service;
    ///
    /// It is recommended as default;
    ///
    /// - see: PathAide.defaultPrivateFileURL(withSubPath:)
    public static let privateService: PersistentService = {
        let rootDirURL = PathAide.defaultPrivateFileURL(withSubPath: kRootDirName)
        return PersistentService.init(rootDirURL: rootDirURL)
    }()

    /// Cache shared persistent service;
    ///
    /// It is recommended for caching;
    ///
    /// - see: PathAide.defaultCacheFileURL(withSubPath:)
    public static let cacheService: PersistentService = {
        let rootDirURL = PathAide.defaultCacheFileURL(withSubPath: kRootDirName)
        return PersistentService.init(rootDirURL: rootDirURL)
    }()

    /// Temp shared persistent service;
    ///
    /// It is recommended for temporary objects;
    ///
    /// - see: PathAide.defaultTempFileURL(withSubPath:)
    public static let tempService: PersistentService = {
        let rootDirURL = PathAide.defaultTempFileURL(withSubPath: kRootDirName)
        return PersistentService.init(rootDirURL: rootDirURL)
    }()
}
