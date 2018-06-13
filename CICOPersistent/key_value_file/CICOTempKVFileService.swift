//
//  CICOTempKVFileService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/6/12.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

private let kRootDirName = "json_data"

public class CICOTempKVFileService: CICOKVFileService {
    public static let shared: CICOTempKVFileService = {
        return CICOTempKVFileService.init(rootDirURL: CICOTempKVFileService.tempDirURL())
    }()
    
    public static func tempDirURL() -> URL {
        return CICOPathAide.defaultTempFileURL(withSubPath: kRootDirName)
    }
    
    public func clearAll() -> Bool {
        let removeResult = CICOPathAide.removeFile(with: self.rootDirURL)
        let createResult = CICOPathAide.createDir(with: self.rootDirURL, option: true)
        return (removeResult && createResult)
    }
}
