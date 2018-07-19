//
//  CICOKVFileService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/6/12.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

open class CICOKVFileService: CICOURLKVFileService {
    public let rootDirURL: URL

    deinit {
        print("\(self) deinit")
    }
    
    public init(rootDirURL: URL) {
        self.rootDirURL = rootDirURL
        
        let result = CICOPathAide.createDir(with: self.rootDirURL, option: false)
        if !result {
            print("[ERROR]: create kv file dir failed\nurl: \(self.rootDirURL)")
            return
        }
    }
    
    open func readObject<T: Decodable>(_ type: T.Type, forKey userKey: String) -> T? {
        guard let jsonKey = self.jsonKey(forUserKey: userKey) else {
            return nil
        }
        
        let fileURL = self.jsonDataFileURL(forJSONKey: jsonKey)
        
        return self.readObject(type, fromFileURL: fileURL)
    }
    
    open func writeObject<T: Encodable>(_ object: T, forKey userKey: String) -> Bool {
        guard let jsonKey = self.jsonKey(forUserKey: userKey) else {
            return false
        }
        
        let fileURL = self.jsonDataFileURL(forJSONKey: jsonKey)
        
        return self.writeObject(object, toFileURL: fileURL)
    }
    
    open func removeObject(forKey userKey: String) -> Bool {
        guard let jsonKey = self.jsonKey(forUserKey: userKey) else {
            return false
        }
        
        let fileURL = self.jsonDataFileURL(forJSONKey: jsonKey)
        
        return self.removeObject(forFileURL: fileURL)
    }
    
    private func jsonKey(forUserKey userKey: String) -> String? {
        guard userKey.count > 0 else {
            return nil
        }
        
        return CICOSecurityAide.md5HashString(with: userKey)
    }
    
    private func jsonDataFileURL(forJSONKey jsonKey: String) -> URL {
        var fileURL = self.rootDirURL
        fileURL.appendPathComponent(jsonKey)
        return fileURL
    }
}
