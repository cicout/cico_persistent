//
//  SecurityAide+HMAC.swift
//  CICOPersistent
//
//  Created by lucky.li on 2019/9/7.
//  Copyright © 2019 cico. All rights reserved.
//

import Foundation
import CommonCrypto

extension SecurityAide {
    public enum HMACType: Int, Codable {
        case md5 = 128
        case sha1 = 160
        case sha224 = 224
        case sha256 = 256
        case sha384 = 384
        case sha512 = 512

        func digetLength() -> Int {
            return self.rawValue
        }

        func hmacAlgorithm() -> CCHmacAlgorithm {
            switch self {
            case .md5:
                return CCHmacAlgorithm(kCCHmacAlgMD5)
            case .sha1:
                return CCHmacAlgorithm(kCCHmacAlgSHA1)
            case .sha224:
                return CCHmacAlgorithm(kCCHmacAlgSHA224)
            case .sha256:
                return CCHmacAlgorithm(kCCHmacAlgSHA256)
            case .sha384:
                return CCHmacAlgorithm(kCCHmacAlgSHA384)
            case .sha512:
                return CCHmacAlgorithm(kCCHmacAlgSHA512)
            }
        }
    }

    // MARK: - HMAC

    public static func hmacHashData(sourceData: Data, keyData: Data, type: HMACType) -> Data {
        var hashData = Data.init(count: type.digetLength())

        do {
            try hashData.withUnsafeUInt8MutablePointerBaseAddress { (hashBasePtr) in
                try sourceData.withUnsafeBytesBaseAddress({ (sourceBasePtr) in
                    try keyData.withUnsafeBytesBaseAddress({ (keyBasePtr) in
                        CCHmac(type.hmacAlgorithm(),
                               keyBasePtr,
                               keyData.count,
                               sourceBasePtr,
                               sourceData.count,
                               hashBasePtr)
                    })
                })
            }
        } catch {
            print("[ERROR]: Invalid base address pointer.\nerror: \(error)")
        }

        return hashData
    }

    public static func hmacHashData(sourceString: String, keyString: String, type: HMACType) -> Data {
        guard let sourceData = sourceString.data(using: .utf8),
            let keyData = keyString.data(using: .utf8) else {
                print("[ERROR]: Invalid param string.")
                return Data.init()
        }
        return self.hmacHashData(sourceData: sourceData, keyData: keyData, type: type)
    }

    public static func hmacHashString(sourceString: String, keyString: String, type: HMACType) -> String {
        let hashData = self.hmacHashData(sourceString: sourceString, keyString: keyString, type: type)
        return self.hexString(hashData)
    }
}
