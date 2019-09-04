//
//  FileManagerAide.swift
//  CICOPersistent
//
//  Created by lucky.li on 2019/9/3.
//  Copyright © 2019 cico. All rights reserved.
//

import Foundation

public class FileManagerAide {
    public static func fileExists(_ path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }

    public static func fileExists(_ url: URL) -> Bool {
        return self.fileExists(url.path)
    }

    public static func fileExists(_ path: String, isDir: inout Bool) -> Bool {
        var exist: Bool = false
        var isDirOC: ObjCBool = false
        withUnsafeMutablePointer(to: &isDirOC) { (isDirPointer) -> Void in
            exist = FileManager.default.fileExists(atPath: path, isDirectory: isDirPointer)
        }
        isDir = isDirOC.boolValue
        return exist
    }

    public static func fileExists(_ url: URL, isDir: inout Bool) -> Bool {
        return self.fileExists(url.path, isDir: &isDir)
    }

    public static func createDirIfNeeded(_ path: String, deleteFileWithSameName: Bool = false) -> Bool {
        var isDir = false
        let exist = self.fileExists(path, isDir: &isDir)

        if exist {
            if isDir {
                return true
            }

            if !deleteFileWithSameName {
                return false
            }

            let result = self.removeItem(path)
            if !result {
                return false
            }
        }

        do {
            try FileManager.default.createDirectory(atPath: path,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
            return true
        } catch {
            print("[ERROR]: Create dir failed.\npath: \(path)\nerror: \(error)")
            return false
        }
    }

    public static func createDirIfNeeded(_ url: URL, deleteFileWithSameName: Bool = false) -> Bool {
        return self.createDirIfNeeded(url.path, deleteFileWithSameName: deleteFileWithSameName)
    }

    public static func moveItem(from fromPath: String, to toPath: String) -> Bool {
        do {
            try FileManager.default.moveItem(atPath: fromPath, toPath: toPath)
            return true
        } catch {
            print("[ERROR]: Move item failed.\nfrom: \(fromPath)\nto: \(toPath)\nerror: \(error)")
            return false
        }
    }

    public static func moveItem(from fromURL: URL, to toURL: URL) -> Bool {
        return self.moveItem(from: fromURL.path, to: toURL.path)
    }

    public static func copyItem(from fromPath: String, to toPath: String) -> Bool {
        do {
            try FileManager.default.copyItem(atPath: fromPath, toPath: toPath)
            return true
        } catch {
            print("[ERROR]: Copy item failed.\nfrom: \(fromPath)\nto: \(toPath)\nerror: \(error)")
            return false
        }
    }

    public static func copyItem(from fromURL: URL, to toURL: URL) -> Bool {
        return self.copyItem(from: fromURL.path, to: toURL.path)
    }

    public static func removeItem(_ path: String) -> Bool {
        guard self.fileExists(path) else {
            return true
        }

        do {
            try FileManager.default.removeItem(atPath: path)
            return true
        } catch {
            print("[ERROR]: Remove item failed.\npath: \(path)\nerror: \(error)")
            return false
        }
    }

    public static func removeItem(_ url: URL) -> Bool {
        return self.removeItem(url.path)
    }
}
