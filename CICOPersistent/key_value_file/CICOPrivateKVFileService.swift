//
//  CICOPrivateKVFileService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/6/12.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

private let kRootDirName = "cico_kv_file"

public class CICOPrivateKVFileService: CICOKVFileService {
    public static let shared: CICOPrivateKVFileService = {
        let rootDirURL = CICOPathAide.defaultPrivateFileURL(withSubPath: kRootDirName)!
        return CICOPrivateKVFileService.init(rootDirURL: rootDirURL)
    }()
    
    public override func clearAll() -> Bool {
        print("[ERROR]: FORBIDDEN!")
        return false
    }
}
