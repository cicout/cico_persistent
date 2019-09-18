//
//  CICOURLKVFileService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/7/19.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

public let kCICOURLKVFileDefaultPassword = "cico_url_kv_file_default_password"

///
/// URL Key-Value file service;
///
/// You can save any object that conform to codable protocol using file URL key;
/// Each object is stored as a separate file according to the file URL;
/// It is useful for custom file and directory structure;
///
open class URLKVFileService {
    private let passwordData: Data?
    private let fileLock = NSLock()

    deinit {
        print("\(self) deinit")
    }

    /// Init with file encryption password;
    ///
    /// - parameter password: File encryption password; It will use default password if not passing this parameter;
    ///             File won't be encrypted when password is nil;
    ///
    /// - returns: Init object;
    public init(password: String? = kCICOURLKVFileDefaultPassword) {
        if let password = password {
            self.passwordData = SecurityAide.md5HashData(password)
        } else {
            self.passwordData = nil
        }
    }

    /// Read object using file URL;
    ///
    /// - parameter objectType: Type of the object, it must conform to codable protocol;
    /// - parameter fromFileURL: File URL where the object is saved;
    ///
    /// - returns: Read object, nil when no object for this key;
    open func readObject<T: Codable>(_ objectType: T.Type, fromFileURL fileURL: URL) -> T? {
        self.fileLock.lock()
        defer {
            self.fileLock.unlock()
        }

        guard let jsonData = self.readJSONData(fromFileURL: fileURL) else {
            return nil
        }

        return KVJSONAide.transferJSONDataToObject(jsonData, objectType: objectType)
    }

    /// Write object using file URL;
    ///
    /// Add when it does not exist, update when it exists;
    ///
    /// - parameter object: The object will be saved in file, it must conform to codable protocol;
    /// - parameter toFileURL: File URL where the object is saved;
    ///
    /// - returns: Write result;
    open func writeObject<T: Codable>(_ object: T, toFileURL fileURL: URL) -> Bool {
        guard let jsonData = KVJSONAide.transferObjectToJSONData(object) else {
            return false
        }

        self.fileLock.lock()
        defer {
            self.fileLock.unlock()
        }

        return self.writeJSONData(jsonData, toFileURL: fileURL)
    }

    /// Update object using file URL;
    ///
    /// Read the existing object, then call the "updateClosure", and write the object returned by "updateClosure";
    /// It won't update when "updateClosure" returns nil;
    ///
    /// - parameter objectType: Type of the object, it must conform to codable protocol;
    /// - parameter fromFileURL: File URL where the object is saved;
    /// - parameter updateClosure: It will be called after reading object from file,
    ///             the read object will be passed as parameter, you can return a new value to update in file;
    ///             It won't be updated to file when you return nil by this closure;
    /// - parameter completionClosure: It will be called when completed, passing update result as parameter;
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

        var object: T?

        // read
        if let jsonData = self.readJSONData(fromFileURL: fileURL) {
            object = KVJSONAide.transferJSONDataToObject(jsonData, objectType: objectType)
        }

        // update
        guard let newObject = updateClosure(object) else {
            result = true
            return
        }

        guard let newJSONData = KVJSONAide.transferObjectToJSONData(newObject) else {
            return
        }

        // write
        result = self.writeJSONData(newJSONData, toFileURL: fileURL)
    }

    /// Remove object using file URL;
    ///
    /// - parameter forFileURL: File URL where the object is saved;;
    ///
    /// - returns: Remove result;
    open func removeObject(forFileURL fileURL: URL) -> Bool {
        self.fileLock.lock()
        defer {
            self.fileLock.unlock()
        }

        return FileManagerAide.removeItem(fileURL)
    }

    private func readJSONData(fromFileURL fileURL: URL) -> Data? {
        let exist = FileManagerAide.fileExists(fileURL)

        guard exist else {
            return nil
        }

        do {
            let encryptedData = try Data.init(contentsOf: fileURL)
            guard let jsonData = self.decryptDataIfNeeded(encryptedData: encryptedData) else {
                print("[ERROR]: Decrypt data failed.")
                return nil
            }
            return jsonData
        } catch let error {
            print("[READ_JSON_FILE_ERROR]: \(error)")
            return nil
        }
    }

    private func writeJSONData(_ jsonData: Data, toFileURL fileURL: URL) -> Bool {
        do {
            guard let encryptedData = self.encryptDataIfNeeded(sourceData: jsonData) else {
                print("[ERROR]: Encrypt data failed.")
                return false
            }
            try encryptedData.write(to: fileURL, options: .atomic)
            return true
        } catch let error {
            print("[WRITE_JSON_FILE_ERROR]: \(error)")
            return false
        }
    }

    private func encryptDataIfNeeded(sourceData: Data) -> Data? {
        if let passwordData = self.passwordData {
            return SecurityAide.aesEncrypt(sourceData, type: .AES128, keyData: passwordData)
        } else {
            return sourceData
        }
    }

    private func decryptDataIfNeeded(encryptedData: Data) -> Data? {
        if let passwordData = self.passwordData {
            return SecurityAide.aesDecrypt(encryptedData, type: .AES128, keyData: passwordData)
        } else {
            return encryptedData
        }
    }
}
