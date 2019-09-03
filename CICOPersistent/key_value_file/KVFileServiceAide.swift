//
//  KVFileServiceAide.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/12/12.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

private let kRootDirName = "cico_kv_file"

///
/// It defines four shared Key-Value file service, you can use them directly;
///
public class KVFileServiceAide {
    /// Public shared Key-Value file service;
    ///
    /// It is convenient for debuging, not recommended for release products;
    ///
    /// - see: PathAide.defaultPublicFileURL(withSubPath:)
    public static let publicService: KVFileService = {
        let rootDirURL = PathAide.defaultPublicFileURL(withSubPath: kRootDirName)
        return KVFileService.init(rootDirURL: rootDirURL)
    }()

    /// Private shared Key-Value file service;
    ///
    /// It is recommended as default;
    ///
    /// - see: PathAide.defaultPrivateFileURL(withSubPath:)
    public static let privateService: KVFileService = {
        let rootDirURL = PathAide.defaultPrivateFileURL(withSubPath: kRootDirName)
        return KVFileService.init(rootDirURL: rootDirURL)
    }()

    /// Cache shared Key-Value file service;
    ///
    /// It is recommended for caching;
    ///
    /// - see: PathAide.defaultCacheFileURL(withSubPath:)
    public static let cacheService: KVFileService = {
        let rootDirURL = PathAide.defaultCacheFileURL(withSubPath: kRootDirName)
        return KVFileService.init(rootDirURL: rootDirURL)
    }()

    /// Temp shared Key-Value file service;
    ///
    /// It is recommended for temporary objects;
    ///
    /// - see: PathAide.defaultTempFileURL(withSubPath:)
    public static let tempService: KVFileService = {
        let rootDirURL = PathAide.defaultTempFileURL(withSubPath: kRootDirName)
        return KVFileService.init(rootDirURL: rootDirURL)
    }()
}
