//
//  SecurityAide+SHA.swift
//  CICOPersistent
//
//  Created by lucky.li on 2019/9/7.
//  Copyright © 2019 cico. All rights reserved.
//

import Foundation
import CommonCrypto

extension SecurityAide {
    public enum SHAType: Int, Codable {
        case SHA1 = 160
        case SHA256 = 256
        case SHA512 = 512
    }

    // MARK: - SHA1

    public static func sha1HashData(_ sourceData: Data) -> Data {
        var hashData = Data.init(count: Int(CC_SHA1_DIGEST_LENGTH))
        do {
            try hashData.withUnsafeUInt8MutablePointerBaseAddress { (hashBasePtr, _) in
                try sourceData.withUnsafeBytesBaseAddress({ (sourceBasePtr, sourceCount) in
                    CC_SHA1(sourceBasePtr, CC_LONG(sourceCount), hashBasePtr)
                })
            }
        } catch {
            print("[ERROR]: Invalid base address pointer.\nerror: \(error)")
        }
        return hashData
    }

    public static func sha1HashData(_ sourceString: String) -> Data {
        guard let sourceData = sourceString.data(using: .utf8) else {
            assertionFailure("Invalid source string.")
            print("[ERROR]: Invalid source string.\nstring: \(sourceString)")
            return Data.init()
        }
        return self.sha1HashData(sourceData)
    }

    public static func sha1HashString(_ sourceData: Data) -> String {
        let hashData = self.sha1HashData(sourceData)
        return self.hexString(hashData)
    }

    public static func sha1HashString(_ sourceString: String) -> String {
        let hashData = self.sha1HashData(sourceString)
        return self.hexString(hashData)
    }

    // MARK: - SHA256

    public static func sha256HashData(_ sourceData: Data) -> Data {
        var hashData = Data.init(count: Int(CC_SHA256_DIGEST_LENGTH))
        do {
            try hashData.withUnsafeUInt8MutablePointerBaseAddress { (hashBasePtr, _) in
                try sourceData.withUnsafeBytesBaseAddress({ (sourceBasePtr, sourceCount) in
                    CC_SHA256(sourceBasePtr, CC_LONG(sourceCount), hashBasePtr)
                })
            }
        } catch {
            print("[ERROR]: Invalid base address pointer.\nerror: \(error)")
        }
        return hashData
    }

    // MARK: - SHA512

    public static func sha512HashData(_ sourceData: Data) -> Data {
        var hashData = Data.init(count: Int(CC_SHA512_DIGEST_LENGTH))
        do {
            try hashData.withUnsafeUInt8MutablePointerBaseAddress { (hashBasePtr, _) in
                try sourceData.withUnsafeBytesBaseAddress({ (sourceBasePtr, sourceCount) in
                    CC_SHA512(sourceBasePtr, CC_LONG(sourceCount), hashBasePtr)
                })
            }
        } catch {
            print("[ERROR]: Invalid base address pointer.\nerror: \(error)")
        }
        return hashData
    }

    // MARK: - SHA FAMILY

    public static func shaHashData(_ sourceData: Data, type: SHAType) -> Data {
        switch type {
        case .SHA1:
            return self.sha1HashData(sourceData)
        case .SHA256:
            return self.sha256HashData(sourceData)
        case .SHA512:
            return self.sha512HashData(sourceData)
        }
    }

    public static func shaHashData(_ sourceString: String, type: SHAType) -> Data {
        guard let sourceData = sourceString.data(using: .utf8) else {
            assertionFailure("Invalid source string.")
            print("[ERROR]: Invalid source string.\nstring: \(sourceString)")
            return Data.init()
        }
        return self.shaHashData(sourceData, type: type)
    }

    public static func shaHashString(_ sourceData: Data, type: SHAType) -> String {
        let hashData = self.shaHashData(sourceData, type: type)
        return self.hexString(hashData)
    }

    public static func shaHashString(_ sourceString: String, type: SHAType) -> String {
        let hashData = self.shaHashData(sourceString, type: type)
        return self.hexString(hashData)
    }
}
