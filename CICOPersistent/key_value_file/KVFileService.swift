//
//  CICOKVFileService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/6/12.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

///
/// Key-Value file service;
///
/// You can save any object that conform to codable protocol using string key;
/// Each object is stored as a separate file in the root directory according to the key;
///
open class KVFileService {
    public let rootDirURL: URL

    private let urlFileService: URLKVFileService

    deinit {
        print("\(self) deinit")
    }

    /// Init with root directory URL and file encryption password;
    ///
    /// - parameter rootDirURL: The root directory URL for file saving;
    /// - parameter password: File encryption password; It will use default password if not passing this parameter;
    ///             File won't be encrypted when password is nil;
    ///
    /// - returns: Init object;
    public init(rootDirURL: URL, password: String? = kCICOURLKVFileDefaultPassword) {
        self.rootDirURL = rootDirURL
        self.urlFileService = URLKVFileService.init(password: password)

        let result = FileManagerAide.createDirIfNeeded(self.rootDirURL)
        if !result {
            print("[ERROR]: create kv file dir failed\nurl: \(self.rootDirURL)")
            return
        }
    }

    /// Read object using key;
    ///
    /// - parameter objectType: Type of the object, it must conform to codable protocol;
    /// - parameter forKey: Key of the object;
    ///
    /// - returns: Read object, nil when no object for this key;
    open func readObject<T: Codable>(_ objectType: T.Type, forKey userKey: String) -> T? {
        guard let jsonKey = self.jsonKey(forUserKey: userKey) else {
            return nil
        }

        let fileURL = self.jsonDataFileURL(forJSONKey: jsonKey)

        return self.urlFileService.readObject(objectType, fromFileURL: fileURL)
    }

    /// Write object using key;
    ///
    /// Add when it does not exist, update when it exists;
    ///
    /// - parameter object: The object will be saved in file, it must conform to codable protocol;
    /// - parameter forKey: Key of the object;
    ///
    /// - returns: Write result;
    open func writeObject<T: Codable>(_ object: T, forKey userKey: String) -> Bool {
        guard let jsonKey = self.jsonKey(forUserKey: userKey) else {
            return false
        }

        let fileURL = self.jsonDataFileURL(forJSONKey: jsonKey)

        return self.urlFileService.writeObject(object, toFileURL: fileURL)
    }

    /// Update object using key;
    ///
    /// Read the existing object, then call the "updateClosure", and write the object returned by "updateClosure";
    /// It won't update when "updateClosure" returns nil;
    ///
    /// - parameter objectType: Type of the object, it must conform to codable protocol;
    /// - parameter forKey: Key of the object;
    /// - parameter updateClosure: It will be called after reading object from file,
    ///             the read object will be passed as parameter, you can return a new value to update in file;
    ///             It won't be updated to file when you return nil by this closure;
    /// - parameter completionClosure: It will be called when completed, passing update result as parameter;
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
            },
                          completionClosure: completionClosure)
    }

    /// Remove object using key;
    ///
    /// - parameter forKey: Key of the object;
    ///
    /// - returns: Remove result;
    open func removeObject(forKey userKey: String) -> Bool {
        guard let jsonKey = self.jsonKey(forUserKey: userKey) else {
            return false
        }

        let fileURL = self.jsonDataFileURL(forJSONKey: jsonKey)

        return self.urlFileService.removeObject(forFileURL: fileURL)
    }

    /// Remove all objects;
    ///
    /// - returns: Remove result;
    open func clearAll() -> Bool {
        let removeResult = FileManagerAide.removeItem(self.rootDirURL)
        let createResult = FileManagerAide.createDirIfNeeded(self.rootDirURL)
        return (removeResult && createResult)
    }

    private func jsonKey(forUserKey userKey: String) -> String? {
        guard userKey.count > 0 else {
            return nil
        }

        return SecurityAide.md5HashString(userKey)
    }

    private func jsonDataFileURL(forJSONKey jsonKey: String) -> URL {
        var fileURL = self.rootDirURL
        fileURL.appendPathComponent(jsonKey)
        return fileURL
    }
}
