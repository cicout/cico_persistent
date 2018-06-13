//
//  CICOPublicPersistentService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/6/7.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

public class CICOPublicPersistentService: CICOPersistentService {
    public static let shared: CICOPublicPersistentService = {
        return CICOPublicPersistentService.init(rootDirURL: CICOPublicPersistentService.publicDirURL())
    }()
    
    public static func publicDirURL() -> URL {
        return CICOPathAide.defaultPublicFileURL(withSubPath: nil)
    }
}
