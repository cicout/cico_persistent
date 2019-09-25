//
//  SecurityAide+AES.swift
//  CICOPersistent
//
//  Created by lucky.li on 2019/9/7.
//  Copyright © 2019 cico. All rights reserved.
//

import Foundation
import CommonCrypto

private enum AESError: Int, Error {
    case encryptFailed = -999
    case decryptFailed = -998
}

extension SecurityAide {
    public enum AESType: Int, Codable {
        case AES128 = 128
        case AES256 = 256
    }

    // MARK: - AES

    /// Encrypt data using AES;
    ///
    /// - Parameter sourceData: Source data;
    /// - Parameter type: AES128 or AES256;
    /// - Parameter keyData: AES encryption key data;
    /// keyData.count == 16 for AES128; keyData.count == 32 for AES256;
    /// - Parameter options: AES encryption options, CCOptions(kCCOptionPKCS7Padding|kCCOptionECBMode) for default;
    ///
    /// - returns: AES encrypted data;
    public static func aesEncrypt(_ sourceData: Data,
                                  type: AESType,
                                  keyData: Data,
                                  options: CCOptions = CCOptions(kCCOptionPKCS7Padding|kCCOptionECBMode)) -> Data? {
        guard keyData.count * 8 == type.rawValue else {
            print("[ERROR]: Invalid key length.")
            return nil
        }

        let encryptedLength: Int = sourceData.count + kCCBlockSizeAES128
        var encryptedData = Data.init(count: encryptedLength)
        var numBytesEncrypted: Int = 0

        do {
            try encryptedData.withUnsafeUInt8MutablePointerBaseAddress { (encryptedPtr, encryptedCount) in
                try sourceData.withUnsafeBytesBaseAddress({ (sourcePtr, sourceCount) in
                    try keyData.withUnsafeBytesBaseAddress({ (keyPtr, keyCount) in

                        let result = CCCrypt(CCOperation(kCCEncrypt),
                                             CCAlgorithm(kCCAlgorithmAES),
                                             options,
                                             keyPtr,
                                             keyCount,
                                             nil,
                                             sourcePtr,
                                             sourceCount,
                                             encryptedPtr,
                                             encryptedCount,
                                             &numBytesEncrypted)
                        guard result == kCCSuccess else {
                            print("[ERROR]: AES encrypt failed.\nresult: \(result)")
                            throw AESError.encryptFailed
                        }
                    })
                })
            }
        } catch {
            print("[ERROR]: AES encrypt failed.\nerror: \(error)")
            return nil
        }

        let finalEncryptedData = encryptedData.prefix(numBytesEncrypted)

        return finalEncryptedData
    }

    /// Decrypt data using AES;
    ///
    /// - Parameter encryptedData: AES encrypted data;
    /// - Parameter type: AES128 or AES256;
    /// - Parameter keyData: AES encryption key data;
    /// keyData.count == 16 for AES128; keyData.count == 32 for AES256;
    /// - Parameter options: AES decryption options, CCOptions(kCCOptionPKCS7Padding|kCCOptionECBMode) for default;
    ///
    /// - returns: Source data;
    public static func aesDecrypt(_ encryptedData: Data,
                                  type: AESType,
                                  keyData: Data,
                                  options: CCOptions = CCOptions(kCCOptionPKCS7Padding|kCCOptionECBMode)) -> Data? {
        guard keyData.count * 8 == type.rawValue else {
            print("[ERROR]: Invalid key length.")
            return nil
        }

        let decryptedLength: Int = encryptedData.count + kCCBlockSizeAES128
        var decryptedData = Data.init(count: decryptedLength)
        var numBytesDecrypted: Int = 0

        do {
            try decryptedData.withUnsafeUInt8MutablePointerBaseAddress { (decryptedPtr, decryptedCount) in
                try encryptedData.withUnsafeBytesBaseAddress({ (encryptedPtr, encryptedCount) in
                    try keyData.withUnsafeBytesBaseAddress({ (keyPtr, keyCount) in

                        let result = CCCrypt(CCOperation(kCCDecrypt),
                                             CCAlgorithm(kCCAlgorithmAES),
                                             options,
                                             keyPtr,
                                             keyCount,
                                             nil,
                                             encryptedPtr,
                                             encryptedCount,
                                             decryptedPtr,
                                             decryptedCount,
                                             &numBytesDecrypted)
                        guard result == kCCSuccess else {
                            print("[ERROR]: AES decrypt failed.\nresult: \(result)")
                            throw AESError.decryptFailed
                        }
                    })
                })
            }
        } catch {
            print("[ERROR]: AES encrypt failed.\nerror: \(error)")
            return nil
        }

        let finalDecryptedData = decryptedData.prefix(numBytesDecrypted)

        return finalDecryptedData
    }

    /// Encrypt data using AES;
    /// - Parameter sourceData: Source data;
    /// - Parameter type: AES128 or AES256;
    /// - Parameter password: AES encryption key string, will be transfered to hash data;
    /// MD5 hash for AES128; SHA256 hash for AES256;
    /// - Parameter options: AES decryption options, CCOptions(kCCOptionPKCS7Padding|kCCOptionECBMode) for default;
    ///
    /// - returns: AES encrypted data;
    public static func aesEncrypt(_ sourceData: Data,
                                  type: AESType,
                                  password: String,
                                  options: CCOptions = CCOptions(kCCOptionPKCS7Padding|kCCOptionECBMode)) -> Data? {
        let keyData: Data
        switch type {
        case .AES128:
            keyData = self.md5HashData(password)
        case .AES256:
            keyData = self.shaHashData(password, type: .SHA256)
        }
        return self.aesEncrypt(sourceData, type: type, keyData: keyData, options: options)
    }

    /// Decrypt data using AES;
    /// - Parameter encryptedData: AES encrypted data;
    /// - Parameter type: AES128 or AES256;
    /// - Parameter password: AES encryption key string, will be transfered to hash data;
    /// MD5 hash for AES128; SHA256 hash for AES256;
    /// - Parameter options: AES decryption options, CCOptions(kCCOptionPKCS7Padding|kCCOptionECBMode) for default;
    ///
    /// - reurns: Source data;
    public static func aesDecrypt(_ encryptedData: Data,
                                  type: AESType,
                                  password: String,
                                  options: CCOptions = CCOptions(kCCOptionPKCS7Padding|kCCOptionECBMode)) -> Data? {
        let keyData: Data
        switch type {
        case .AES128:
            keyData = self.md5HashData(password)
        case .AES256:
            keyData = self.shaHashData(password, type: .SHA256)
        }
        return self.aesDecrypt(encryptedData, type: type, keyData: keyData, options: options)
    }
}
