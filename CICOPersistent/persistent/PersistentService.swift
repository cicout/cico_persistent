//
//  CICOPersistentService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/6/7.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

private let kKVFileDirName = "kv_file"
private let kKVDBFileSubPath = "kv_db/db.sqlite"
private let kORMDBFileSubPath = "orm_db/db.sqlite"

///
/// All persistent functions;
///
/// It lists all persistent functions here;
/// - UserDefault: UserDefaults.standard functions, for simple Key-Value persistent only;
/// - KVFile: Key-Value file service, for all codable objects storing;
/// - KVDB: Key-Value database service, for all codable objects storing;
/// - ORMDB: ORM database service, for all codable objects storing;
/// - KVKeyChain: Key-Value key chain service, for all codable objects storing;
///
open class PersistentService {
    public let rootDirURL: URL

    private(set) var kvFileService: KVFileService
    private(set) var kvDBService: KVDBService
    private(set) var ormDBService: ORMDBService

    deinit {
        print("\(self) deinit")
    }

    /// Init with root directory URL;
    ///
    /// It will use default password for KVFileService/KVDBService/ORMDBService/KVKeyChainService;
    ///
    /// - parameter rootDirURL: The root directory URL for persistent;
    ///
    /// - returns: Init object;
    public init(rootDirURL: URL) {
        self.rootDirURL = rootDirURL

        let kvFileDirURL = rootDirURL.appendingPathComponent(kKVFileDirName)
        self.kvFileService = KVFileService.init(rootDirURL: kvFileDirURL)

        let kvDBFileURL = rootDirURL.appendingPathComponent(kKVDBFileSubPath)
        self.kvDBService = KVDBService.init(fileURL: kvDBFileURL)

        let ormDBFileURL = rootDirURL.appendingPathComponent(kORMDBFileSubPath)
        self.ormDBService = ORMDBService.init(fileURL: ormDBFileURL)
    }

    /// File URL in root directory;
    ///
    /// - parameter subPath: Path relative to the root directory path;
    ///
    /// - returns: Full file URL;
    open func fileURL(subPath: String) -> URL {
        return self.rootDirURL.appendingPathComponent(subPath)
    }

    /*****************
     * All Persistent
     *****************/

    ///
    /// Clear KVFile/KVDB/ORMDB Persistent; UserDefault and KVKeyChain will not be cleared;
    ///
    /// - returns: Remove result;
    open func clearAllPersistent() -> Bool {
        let result0 = self.clearAllKVFile()
        let result1 = self.clearAllKVDB()
        let result2 = self.clearAllORMDB()
        return (result0 && result1 && result2)
    }
}
