//
//  CICOKVFileService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/6/12.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

open class CICOKVFileService {
    public let rootDirURL: URL

    private let urlFileService: CICOURLKVFileService
    
    deinit {
        print("\(self) deinit")
    }
    
    public init(rootDirURL: URL) {
        self.rootDirURL = rootDirURL
        self.urlFileService = CICOURLKVFileService.init()
        
        let result = CICOPathAide.createDir(with: self.rootDirURL, option: false)
        if !result {
            print("[ERROR]: create kv file dir failed\nurl: \(self.rootDirURL)")
            return
        }
    }
    
    open func readObject<T: Codable>(_ objectType: T.Type, forKey userKey: String) -> T? {
        guard let jsonKey = self.jsonKey(forUserKey: userKey) else {
            return nil
        }
        
        let fileURL = self.jsonDataFileURL(forJSONKey: jsonKey)
        
        return self.urlFileService.readObject(objectType, fromFileURL: fileURL)
    }
    
    open func writeObject<T: Codable>(_ object: T, forKey userKey: String) -> Bool {
        guard let jsonKey = self.jsonKey(forUserKey: userKey) else {
            return false
        }
        
        let fileURL = self.jsonDataFileURL(forJSONKey: jsonKey)
        
        return self.urlFileService.writeObject(object, toFileURL: fileURL)
    }
    
    open func updateObject<T: Codable>(_ objectType: T.Type,
                                       forKey userKey: String,
                                       updateClosure: (T?) -> T?,
                                       completionClosure: ((Bool) -> Void)? = nil) {
        guard let jsonKey = self.jsonKey(forUserKey: userKey) else {
            completionClosure?(false)
            return
        }
        
        let fileURL = self.jsonDataFileURL(forJSONKey: jsonKey)
        
        self.urlFileService
            .updateObject(objectType,
                          fromFileURL: fileURL,
                          updateClosure: { (object) -> T? in
                            return updateClosure(object)
            }) { (result) in
                completionClosure?(result)
        }
    }
    
    open func removeObject(forKey userKey: String) -> Bool {
        guard let jsonKey = self.jsonKey(forUserKey: userKey) else {
            return false
        }
        
        let fileURL = self.jsonDataFileURL(forJSONKey: jsonKey)
        
        return self.urlFileService.removeObject(forFileURL: fileURL)
    }
    
    open func clearAll() -> Bool {
        let removeResult = CICOPathAide.removeFile(with: self.rootDirURL)
        let createResult = CICOPathAide.createDir(with: self.rootDirURL, option: false)
        return (removeResult && createResult)
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
