//
//  SecurityAide.swift
//  CICOPersistent
//
//  Created by lucky.li on 2019/9/5.
//  Copyright © 2019 cico. All rights reserved.
//

import Foundation
import Security

public class SecurityAide {
    // MARK: - RANDOM DATA

    public static func randomData(_ count: Int) -> Data {
        var data = Data.init(count: count)
        do {
            try data.withUnsafeMutableBytesBaseAddress { (basePtr) in
                let result = SecRandomCopyBytes(kSecRandomDefault, count, basePtr)
                if 0 != result {
                    print("[ERROR]: Copy random bytes failed.")
                }
            }
        } catch {
            print("[ERROR]: Invalid base address pointer.\nerror: \(error)")
        }
        return data
    }

    // MARK: - HEX

    public static func hexString(_ data: Data) -> String {
        return data.map { String.init(format: "%02x", $0) }.joined()
    }

    public static func hexData(_ hexString: String) -> Data? {
        var fixedHexString = hexString
        if fixedHexString.hasPrefix("0x") {
            fixedHexString = String(fixedHexString.dropFirst(2))
        }

        guard fixedHexString.count > 0, fixedHexString.count % 2 == 0 else {
            return nil
        }

        let length = fixedHexString.count / 2
        var data = Data(capacity: length)

        for index in 0 ..< length {
            let min = fixedHexString.index(fixedHexString.startIndex, offsetBy: index * 2)
            let max = fixedHexString.index(min, offsetBy: 2)
            let bytes = fixedHexString[min..<max]
            if var byte = UInt8(bytes, radix: 16) {
                data.append(&byte, count: 1)
            } else {
                return nil
            }
        }

        return data
    }

    // MARK: - BASE64

    public static func base64EncodedString(_ sourceData: Data) -> String {
        return sourceData.base64EncodedString()
    }

    public static func base64EncodedString(_ sourceString: String) -> String {
        guard let sourceData = sourceString.data(using: .utf8) else {
            print("[ERROR]: Invalid source string.\nstring: \(sourceString)")
            return ""
        }
        return self.base64EncodedString(sourceData)
    }

    public static func base64DecodedData(_ base64String: String) -> Data? {
        return Data.init(base64Encoded: base64String)
    }

    // MARK: - URL ENCODE/DECODE

    public static func urlEncodedString(_ sourceString: String) -> String? {
        return sourceString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }

    public static func urlDecodedString(_ encodedString: String) -> String? {
        return encodedString.removingPercentEncoding
    }
}
