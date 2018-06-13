//
//  CICOPrivateKVFileService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/6/12.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

private let kRootDirName = "json_data"

public class CICOPrivateKVFileService: CICOKVFileService {
    public static let shared: CICOPrivateKVFileService = {
        return CICOPrivateKVFileService.init(rootDirURL: CICOPrivateKVFileService.privateDirURL())
    }()
    
    public static func privateDirURL() -> URL {
        return CICOPathAide.defaultPrivateFileURL(withSubPath: kRootDirName)
    }
}
