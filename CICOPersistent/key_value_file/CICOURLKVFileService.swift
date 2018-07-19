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
    
    open func readObject<T: Decodable>(_ type: T.Type, fromFileURL fileURL: URL) -> T? {
        guard let jsonData = self.readJSONData(fromFileURL: fileURL) else {
            return nil
        }
        
        do {
            let objectArray = try JSONDecoder().decode([T].self, from: jsonData)
            return objectArray.first
        } catch let error {
            print("[JSON_DECODE_ERROR]: \(error)")
            return nil
        }
    }
    
    open func writeObject<T: Encodable>(_ object: T, fromFileURL fileURL: URL) -> Bool {
        do {
            let jsonData = try JSONEncoder().encode([object])
            return self.writeJSONData(jsonData, toFileURL: fileURL)
        } catch let error {
            print("[JSON_ENCODE_ERROR]: \(error)")
            return false
        }
    }
    
    open func removeObject(fromFileURL fileURL: URL) -> Bool {
        do {
            try FileManager.default.removeItem(at: fileURL)
            return true
        } catch let error {
            print("[REMOVE_JSON_FILE_ERROR]: \(error)")
            return false
        }
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
