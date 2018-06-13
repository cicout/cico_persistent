//
//  CICOTempPersistentService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/6/7.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

public class CICOTempPersistentService: CICOPersistentService {
    public static let shared: CICOTempPersistentService = {
        return CICOTempPersistentService.init(rootDirURL: CICOTempPersistentService.tempDirURL())
    }()
    
    public static func tempDirURL() -> URL {
        return CICOPathAide.defaultTempFileURL(withSubPath: nil)
    }
    
    // TODO
//    public func clearAll() -> Bool {
//        let removeResult = CICOPathAide.removeFile(with: self.rootDirURL)
//        let createResult = CICOPathAide.createDir(with: self.rootDirURL, option: true)
//        return (removeResult && createResult)
//    }
}
