//
//  SecurityAide+MD5.swift
//  CICOPersistent
//
//  Created by lucky.li on 2019/9/7.
//  Copyright © 2019 cico. All rights reserved.
//

import Foundation
import CommonCrypto

private let kBufferLength: Int = 1024 * 1024

private struct FastFileMD5HashParam {
    let url: URL
    let bufferLength: Int
    let readAll: Bool
    let minOffset: UInt64
    let middleOffset: UInt64
    let maxOffset: UInt64
    let usingFileSize: Bool
    let fileSize: UInt64
}

extension SecurityAide {
    // MARK: - MD5

    public static func md5HashData(_ sourceData: Data) -> Data {
        var hashData = Data.init(count: Int(CC_MD5_DIGEST_LENGTH))
        do {
            try hashData.withUnsafeUInt8MutablePointerBaseAddress { (hashBasePtr, _) in
                try sourceData.withUnsafeBytesBaseAddress({ (sourceBasePtr, sourceCount) in
                    CC_MD5(sourceBasePtr, CC_LONG(sourceCount), hashBasePtr)
                })
            }
        } catch {
            print("[ERROR]: Invalid base address pointer.\nerror: \(error)")
        }
        return hashData
    }

    public static func md5HashData(_ sourceString: String) -> Data {
        guard let sourceData = sourceString.data(using: .utf8) else {
            assertionFailure("Invalid source string.")
            print("[ERROR]: Invalid source string.\nstring: \(sourceString)")
            return Data.init()
        }
        return self.md5HashData(sourceData)
    }

    public static func md5HashString(_ sourceData: Data) -> String {
        let hashData = self.md5HashData(sourceData)
        return self.hexString(hashData)
    }

    public static func md5HashString(_ sourceString: String) -> String {
        let hashData = self.md5HashData(sourceString)
        return self.hexString(hashData)
    }

    // MARK: - FILE MD5

    public static func fileMD5HashData(_ url: URL) -> Data? {
        var isDir = false
        let exist = FileManagerAide.fileExists(url, isDir: &isDir)

        guard exist && !isDir else {
            print("[ERROR]: File does not exist.\nurl: \(url)")
            return nil
        }

        var context = CC_MD5_CTX.init()
        withUnsafeMutablePointer(to: &context) { (ptr) -> Void in
            CC_MD5_Init(ptr)
        }

        do {
            let fileHandle = try FileHandle.init(forReadingFrom: url)

            var loop = true
            while loop {
                try autoreleasepool {
                    let data = fileHandle.readData(ofLength: kBufferLength)
                    if data.count <= 0 {
                        loop = false
                    } else {
                        try data.withUnsafeBytesBaseAddress({ (basePtr, count) in
                            withUnsafeMutablePointer(to: &context, { (contextPtr) -> Void in
                                CC_MD5_Update(contextPtr, basePtr, CC_LONG(count))
                            })
                        })
                    }
                }
            }

            fileHandle.closeFile()

            var hashData = Data.init(count: Int(CC_MD5_DIGEST_LENGTH))
            _ = hashData.withUnsafeMutableBytes { (hashPtr) -> Int in
                guard let hashBasePtr = hashPtr.bindMemory(to: UInt8.self).baseAddress else {
                    print("[ERROR]: Invalid data pointer.")
                    return -1
                }
                withUnsafeMutablePointer(to: &context, { (contextPtr) -> Void in
                    CC_MD5_Final(hashBasePtr, contextPtr)
                })
                return 0
            }
            return hashData
        } catch {
            print("[ERROR]: Read file failed.\nurl: \(url)\nerror: \(error)")
            return nil
        }
    }

    public static func fileMD5HashString(_ url: URL) -> String? {
        guard let hashData = self.fileMD5HashData(url) else {
            return nil
        }
        return self.hexString(hashData)
    }

    public static func fastFileMD5HashData(_ url: URL,
                                           ignoreHeadLength: UInt64 = 0,
                                           ignoreTailLength: UInt64 = 0,
                                           usingFileSize: Bool = true) -> Data? {
        var isDir = false
        let exist = FileManagerAide.fileExists(url, isDir: &isDir)
        guard exist && !isDir else {
            print("[ERROR]: File does not exist.\nurl: \(url)")
            return nil
        }

        let fileSize = self.fileSize(url)
        guard fileSize > 0 else {
            print("[ERROR]: Empty file.\nurl: \(url)")
            return nil
        }

        let fixedIgnoreHeadLength: UInt64
        let fixedIgnoreTailLength: UInt64
        if ignoreHeadLength + ignoreTailLength > 0 && Int64(fileSize - ignoreHeadLength + ignoreTailLength) < 1 {
            fixedIgnoreHeadLength = 0
            fixedIgnoreTailLength = 0
        } else {
            fixedIgnoreHeadLength = ignoreHeadLength
            fixedIgnoreTailLength = ignoreTailLength
        }

        let readableFileSize = fileSize - fixedIgnoreHeadLength - fixedIgnoreTailLength
        let readAll: Bool = (readableFileSize < 4 * kBufferLength) ? true : false
        let minOffset: UInt64 = fixedIgnoreHeadLength
        let middleOffset: UInt64
        let maxOffset: UInt64
        if readAll {
            middleOffset = 0
            maxOffset = 0
        } else {
            middleOffset = fixedIgnoreHeadLength + (readableFileSize - UInt64(kBufferLength)) / 2
            maxOffset = fileSize - fixedIgnoreHeadLength - UInt64(kBufferLength)
        }

        let param = FastFileMD5HashParam.init(url: url,
                                              bufferLength: kBufferLength,
                                              readAll: readAll,
                                              minOffset: minOffset,
                                              middleOffset: middleOffset,
                                              maxOffset: maxOffset,
                                              usingFileSize: usingFileSize,
                                              fileSize: fileSize)

        return self.fastFileMD5HashData(param: param)
    }

    public static func fastFileMD5HashString(_ url: URL,
                                             ignoreHeadLength: UInt64 = 0,
                                             ignoreTailLength: UInt64 = 0,
                                             usingFileSize: Bool = true) -> String? {
        guard let hashData = self.fastFileMD5HashData(url,
                                                      ignoreHeadLength: ignoreHeadLength,
                                                      ignoreTailLength: ignoreTailLength,
                                                      usingFileSize: usingFileSize) else {
                                                        return nil
        }
        return self.hexString(hashData)
    }

    // MARK: - PRIVATE

    private static func fastFileMD5HashData(param: FastFileMD5HashParam) -> Data? {
        var context = CC_MD5_CTX.init()
        withUnsafeMutablePointer(to: &context) { (ptr) -> Void in
            CC_MD5_Init(ptr)
        }

        do {
            let fileHandle = try FileHandle.init(forReadingFrom: param.url)

            fileHandle.seek(toFileOffset: param.minOffset)

            var readTimes = 0
            var loop = true
            while loop {
                try autoreleasepool {
                    let data = self.readFileData(fileHandle: fileHandle, param: param)
                    if data.count > 0 {
                        try data.withUnsafeBytesBaseAddress({ (basePtr, count) in
                            withUnsafeMutablePointer(to: &context, { (contextPtr) -> Void in
                                CC_MD5_Update(contextPtr, basePtr, CC_LONG(count))
                            })
                        })
                    }

                    if data.count < param.bufferLength {
                        loop = false
                    } else if !param.readAll {
                        readTimes += 1
                        if readTimes == 1 {
                            fileHandle.seek(toFileOffset: param.middleOffset)
                        } else if readTimes == 2 {
                            fileHandle.seek(toFileOffset: param.maxOffset)
                        } else {
                            loop = false
                        }
                    }
                }
            }

            fileHandle.closeFile()

            try self.addFileSizeIfNeeded(context: &context, param: param)

            var hashData = Data.init(count: Int(CC_MD5_DIGEST_LENGTH))
            try hashData.withUnsafeUInt8MutablePointerBaseAddress { (basePtr, _) in
                withUnsafeMutablePointer(to: &context, { (contextPtr) -> Void in
                    CC_MD5_Final(basePtr, contextPtr)
                })
            }
            return hashData
        } catch {
            print("[ERROR]: Read file failed.\nurl: \(param.url)\nerror: \(error)")
            return nil
        }
    }

    private static func readFileData(fileHandle: FileHandle, param: FastFileMD5HashParam) -> Data {
        var readLength = param.bufferLength
        let currentOffset = fileHandle.offsetInFile
        if currentOffset >= param.maxOffset {
            readLength = Int(param.maxOffset + UInt64(param.bufferLength) - currentOffset)
        } else {
            readLength = param.bufferLength
        }

        let data = fileHandle.readData(ofLength: readLength)
        return data
    }

    private static func addFileSizeIfNeeded(context: inout CC_MD5_CTX, param: FastFileMD5HashParam) throws {
        if param.usingFileSize {
            var fileSize = param.fileSize
            try withUnsafeBytes(of: &fileSize) { (ptr) -> Void in
                guard let basePtr = ptr.baseAddress else {
                    throw BaseAddressError.empty
                }
                withUnsafeMutablePointer(to: &context, { (contextPtr) -> Void in
                    CC_MD5_Update(contextPtr, basePtr, CC_LONG(ptr.count))
                })
            }
        }
    }

    private static func fileSize(_ url: URL) -> UInt64 {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path) as NSDictionary
            return attributes.fileSize()
        } catch {
            print("[ERROR]: Read file attributes failed.\nerror: \(error)")
            return 0
        }
    }
}
