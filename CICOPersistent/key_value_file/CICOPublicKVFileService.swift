//
//  CICOPublicKVFileService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/6/12.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

private let kRootDirName = "cico_kv_file"

public class CICOPublicKVFileService: CICOKVFileService {
    public static let shared: CICOPublicKVFileService = {
        let rootDirURL = CICOPathAide.defaultPublicFileURL(withSubPath: kRootDirName)!
        return CICOPublicKVFileService.init(rootDirURL: rootDirURL)
    }()
    
    public override func clearAll() -> Bool {
        print("[ERROR]: FORBIDDEN!")
        return false
    }
}
