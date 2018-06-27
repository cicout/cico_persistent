//
//  CICOORMDBService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/6/22.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation
import FMDB

open class CICOORMDBService {
    public let fileURL: URL
    
    private var dbQueue: FMDatabaseQueue?
    
    deinit {
        print("\(self) deinit")
        self.dbQueue?.close()
    }
    
    init(fileURL: URL) {
        self.fileURL = fileURL
        self.initDB()
    }
    
    open func readObject<T: Decodable>(ofType type: T.Type, forPrimaryKey key: String, customTableName: String? = nil) -> T? {
        return nil
    }
    
    open func readObjectArray<T: Decodable>(ofType type: T.Type,
                                            orderBy: String? = nil,
                                            limit: Int? = nil,
                                            customTableName: String? = nil) -> [T]? {
        return nil
    }
    
    open func writeObject<T: Encodable>(_ object: T, customTableName: String? = nil) -> Bool {
        return false
    }
    
    open func writeObjectArray<T: Encodable>(_ object: [T], customTableName: String? = nil) -> Bool {
        return false
    }
    
    open func removeObject<T: Encodable>(_ object: T, customTableName: String? = nil) -> Bool {
        return false
    }
    
    open func removeObjectArray<T: Encodable>(_ object: [T], customTableName: String? = nil) -> Bool {
        return false
    }
    
    open func removeObjectTable<T: Encodable>(ofType type: T.Type, customTableName: String? = nil) -> Bool {
        return false
    }
    
    open func removeAll() -> Bool {
        return false
    }
    
    private func initDB() {
        let dirURL = self.fileURL.deletingLastPathComponent()
        let result = CICOPathAide.createDir(with: dirURL, option: false)
        if !result {
            print("[ERROR]: create database dir failed\nurl: \(self.fileURL)")
            return
        }
        
        guard let dbQueue = FMDatabaseQueue.init(url: self.fileURL) else {
            print("[ERROR]: create database failed\nurl: \(self.fileURL)")
            return
        }
        
        self.dbQueue = dbQueue
    }
    
}
