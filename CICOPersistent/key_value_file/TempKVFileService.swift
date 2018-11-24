//
//  CICOTempKVFileService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/6/12.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

private let kRootDirName = "cico_kv_file"

public class TempKVFileService: KVFileService {
    public static let shared: TempKVFileService = {
        let rootDirURL = CICOPathAide.defaultTempFileURL(withSubPath: kRootDirName)
        return TempKVFileService.init(rootDirURL: rootDirURL)
    }()
}
