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
    
    open func readObject<T: Codable>(_ type: T.Type, fromFileURL fileURL: URL) -> T? {
        guard let jsonData = self.readJSONData(fromFileURL: fileURL) else {
            return nil
        }
        
        return CICOKVJSONAide.transferJSONDataToObject(jsonData, objectType: type)
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
        
        do {
            self.fileLock.lock()
            let jsonData = try Data.init(contentsOf: fileURL)
            self.fileLock.unlock()
            return jsonData
        } catch let error {
            self.fileLock.unlock()
            print("[READ_JSON_FILE_ERROR]: \(error)")
            return nil
        }
    }
    
    private func writeJSONData(_ jsonData: Data, toFileURL fileURL: URL) -> Bool {
        do {
            self.fileLock.lock()
            try jsonData.write(to: fileURL, options: .atomic)
            self.fileLock.unlock()
            return true
        } catch let error {
            self.fileLock.unlock()
            print("[WRITE_JSON_FILE_ERROR]: \(error)")
            return false
        }
    }
}
