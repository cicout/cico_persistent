//
//  CICOPublicKVFileService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/6/12.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

private let kRootDirName = "json_data"

public class CICOPublicKVFileService: CICOKVFileService {
    public static let shared: CICOPublicKVFileService = {
        return CICOPublicKVFileService.init(rootDirURL: CICOPublicKVFileService.publicDirURL())
    }()
    
    public static func publicDirURL() -> URL {
        return CICOPathAide.defaultPublicFileURL(withSubPath: kRootDirName)
    }
}
