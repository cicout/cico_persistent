//
//  CICOTempPersistentService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/6/7.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

private let kRootDirName = "cico_persistent"

public class CICOTempPersistentService: CICOPersistentService {
    public static let shared: CICOTempPersistentService = {
        let rootDirURL = CICOPathAide.defaultTempFileURL(withSubPath: kRootDirName)!
        return CICOTempPersistentService.init(rootDirURL: rootDirURL)
    }()
}
