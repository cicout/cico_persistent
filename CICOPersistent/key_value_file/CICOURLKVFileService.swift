//
//  CICOURLKVFileService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/7/19.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

open class CICOURLKVFileService {
    private let fileLock = NSLock()
    
    deinit {
        print("\(self) deinit")
    }
    
    public init() {}
    
    open func readObject<T: Codable>(_ objectType: T.Type, fromFileURL fileURL: URL) -> T? {
        self.fileLock.lock()
        defer {
            self.fileLock.unlock()
        }
        
        guard let jsonData = self.readJSONData(fromFileURL: fileURL) else {
            return nil
        }
        
        return CICOKVJSONAide.transferJSONDataToObject(jsonData, objectType: objectType)
    }
    
    open func writeObject<T: Codable>(_ object: T, toFileURL fileURL: URL) -> Bool {
        guard let jsonData = CICOKVJSONAide.transferObjectToJSONData(object) else {
            return false
        }
        
        self.fileLock.lock()
        defer {
            self.fileLock.unlock()
        }
        
        return self.writeJSONData(jsonData, toFileURL: fileURL)
    }
    
    open func updateObject<T: Codable>(_ objectType: T.Type,
                                       fromFileURL fileURL: URL,
                                       updateClosure: (T?) -> T?,
                                       completionClosure: ((Bool) -> Void)? = nil) {
        var result = false
        defer {
            completionClosure?(result)
        }
        
        self.fileLock.lock()
        defer {
            self.fileLock.unlock()
        }
        
        var object: T? = nil
        
        // read
        if let jsonData = self.readJSONData(fromFileURL: fileURL) {
            object = CICOKVJSONAide.transferJSONDataToObject(jsonData, objectType: objectType)
        }
        
        // update
        guard let newObject = updateClosure(object) else {
            result = true
            return
        }
        
        guard let newJSONData = CICOKVJSONAide.transferObjectToJSONData(newObject) else {
            return
        }
        
        // write
        result = self.writeJSONData(newJSONData, toFileURL: fileURL)
    }
    
    open func removeObject(forFileURL fileURL: URL) -> Bool {
        self.fileLock.lock()
        defer {
            self.fileLock.unlock()
        }
        
        return CICOPathAide.removeFile(with: fileURL)
    }

    private func readJSONData(fromFileURL fileURL: URL) -> Data? {
        let exist = FileManager.default.fileExists(atPath: fileURL.path)
        
        guard exist else {
            return nil
        }
        
        do {
            let jsonData = try Data.init(contentsOf: fileURL)
            return jsonData
        } catch let error {
            print("[READ_JSON_FILE_ERROR]: \(error)")
            return nil
        }
    }
    
    private func writeJSONData(_ jsonData: Data, toFileURL fileURL: URL) -> Bool {
        do {
            try jsonData.write(to: fileURL, options: .atomic)
            return true
        } catch let error {
            print("[WRITE_JSON_FILE_ERROR]: \(error)")
            return false
        }
    }
}
