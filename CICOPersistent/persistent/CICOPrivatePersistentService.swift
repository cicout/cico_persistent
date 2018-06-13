//
//  CICOPrivatePersistentService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/6/7.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

public class CICOPrivatePersistentService: CICOPersistentService {
    public static let shared: CICOPrivatePersistentService = {
        return CICOPrivatePersistentService.init(rootDirURL: CICOPrivatePersistentService.privateDirURL())
    }()
    
    public static func privateDirURL() -> URL {
        return CICOPathAide.defaultPrivateFileURL(withSubPath: nil)
    }
}
