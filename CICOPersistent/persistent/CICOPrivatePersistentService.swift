//
//  CICOPrivatePersistentService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/6/7.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

private let kRootDirName = "private"

public class CICOPrivatePersistentService: CICOBasePersistentService {
    public static let shared: CICOPrivatePersistentService = {
        return CICOPrivatePersistentService.init(rootDirURL: CICOPrivatePersistentService.privateDirURL())
    }()
    
    public static func privateDirURL() -> URL {
        return CICOPathAide.libFileURL(withSubPath: kRootDirName)
    }
}
