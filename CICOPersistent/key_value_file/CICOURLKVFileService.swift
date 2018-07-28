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
        guard let jsonData = self.readJSONData(fromFileURL: fileURL) else {
            return nil
        }
        
        return CICOKVJSONAide.transferJSONDataToObject(jsonData, objectType: objectType)
    }
    
    open func writeObject<T: Codable>(_ object: T, toFileURL fileURL: URL) -> Bool {
        guard let jsonData = CICOKVJSONAide.transferObjectToJSONData(object) else {
            return false
        }
        
        return self.writeJSONData(jsonData, toFileURL: fileURL)
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
        
        self.fileLock.lock()
        defer {
            self.fileLock.unlock()
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
        self.fileLock.lock()
        defer {
            self.fileLock.unlock()
        }
        
        do {
            try jsonData.write(to: fileURL, options: .atomic)
            return true
        } catch let error {
            print("[WRITE_JSON_FILE_ERROR]: \(error)")
            return false
        }
    }
}
