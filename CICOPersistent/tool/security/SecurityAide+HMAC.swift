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
        case MD5 = 128
        case SHA1 = 160
        case SHA224 = 224
        case SHA256 = 256
        case SHA384 = 384
        case SHA512 = 512

        func digetLength() -> Int {
            return self.rawValue
        }

        func hmacAlgorithm() -> CCHmacAlgorithm {
            switch self {
            case .MD5:
                return CCHmacAlgorithm(kCCHmacAlgMD5)
            case .SHA1:
                return CCHmacAlgorithm(kCCHmacAlgSHA1)
            case .SHA224:
                return CCHmacAlgorithm(kCCHmacAlgSHA224)
            case .SHA256:
                return CCHmacAlgorithm(kCCHmacAlgSHA256)
            case .SHA384:
                return CCHmacAlgorithm(kCCHmacAlgSHA384)
            case .SHA512:
                return CCHmacAlgorithm(kCCHmacAlgSHA512)
            }
        }
    }

    // MARK: - HMAC
    
    /// Transfer data to HMAC hash data;
    ///
    /// - Parameter sourceData: Source data;
    /// - Parameter keyData: Key data;
    /// - Parameter type: HMAC hash algorithm type;
    ///
    /// - returns: HMAC hash data;
    public static func hmacHashData(sourceData: Data, keyData: Data, type: HMACType) -> Data {
        var hashData = Data.init(count: type.digetLength())

        do {
            try hashData.withUnsafeUInt8MutablePointerBaseAddress { (hashBasePtr, _) in
                try sourceData.withUnsafeBytesBaseAddress({ (sourceBasePtr, sourceCount) in
                    try keyData.withUnsafeBytesBaseAddress({ (keyBasePtr, keyCount) in
                        CCHmac(type.hmacAlgorithm(),
                               keyBasePtr,
                               keyCount,
                               sourceBasePtr,
                               sourceCount,
                               hashBasePtr)
                    })
                })
            }
        } catch {
            print("[ERROR]: Invalid base address pointer.\nerror: \(error)")
        }

        return hashData
    }
    
    /// Transfer string to HMAC hash data;
    ///
    /// - Parameter sourceString: Source string, will be transfered to data using utf-8;
    /// - Parameter keyString: Key string, will be transfered to data using utf-8;
    /// - Parameter type: HMAC hash algorithm type;
    ///
    /// - returns: HMAC hash data;
    public static func hmacHashData(sourceString: String, keyString: String, type: HMACType) -> Data {
        guard let sourceData = sourceString.data(using: .utf8),
            let keyData = keyString.data(using: .utf8) else {
                print("[ERROR]: Invalid param string.")
                return Data.init()
        }
        return self.hmacHashData(sourceData: sourceData, keyData: keyData, type: type)
    }
    
    /// Transfer string to HMAC hash hex string in lower case;
    ///
    /// - Parameter sourceString: Source string, will be transfered to data using utf-8;
    /// - Parameter keyString: Key string, will be transfered to data using utf-8;
    /// - Parameter type: HMAC hash algorithm type;
    ///
    /// - returns: HMAC hash hex string in lower case;
    public static func hmacHashString(sourceString: String, keyString: String, type: HMACType) -> String {
        let hashData = self.hmacHashData(sourceString: sourceString, keyString: keyString, type: type)
        return self.hexString(hashData)
    }
}
