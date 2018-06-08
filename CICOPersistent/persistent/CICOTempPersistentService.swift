//
//  CICOTempPersistentService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/6/7.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

private let kRootDirName = "temp"

public class CICOTempPersistentService: CICOBasePersistentService {
    public static let shared: CICOTempPersistentService = {
        return CICOTempPersistentService.init(rootDirURL: CICOTempPersistentService.tempDirURL())
    }()
    
    public static func tempDirURL() -> URL {
        return CICOPathAide.docFileURL(withSubPath: kRootDirName)
    }
    
    public func clearAll() -> Bool {
        let removeResult = CICOPathAide.removeFile(with: self.rootDirURL)
        let createResult = CICOPathAide.createDir(with: self.rootDirURL, option: true)
        return (removeResult && createResult)
    }
}
