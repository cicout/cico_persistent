//
//  SecurityAideTests.swift
//  CICOPersistentTests
//
//  Created by lucky.li on 2019/9/5.
//  Copyright © 2019 cico. All rights reserved.
//

import XCTest
import CICOPersistent

private let kText0: String = ""
private let kText0MD5: String = "d41d8cd98f00b204e9800998ecf8427e"
private let kText0SHA1: String = "da39a3ee5e6b4b0d3255bfef95601890afd80709"
private let kText0SHA256: String = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
private let kText0SHA512: String =
"cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce" +
"47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e"

private let kText1: String = "test"
private let kText1MD5: String = "098f6bcd4621d373cade4e832627b4f6"
private let kText1SHA1: String = "a94a8fe5ccb19ba61c4c0873d391e987982fbbd3"
private let kText1SHA256: String = "9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08"
private let kText1SHA512: String =
"ee26b0dd4af7e749aa1a8ee3c10ae9923f618980772e473f8819a5d4940e0db2" +
"7ac185f8a0e1d5f84f88bc887fd67b143732c304cc5fa9ad8e6f57f50028a8ff"

class SecurityAideTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testHex() {
        let data = SecurityAide.randomData(10)

        let hexString = SecurityAide.hexString(data)

        let hexData = SecurityAide.hexData(hexString)
        XCTAssertNotNil(hexData, "hexData == nil")

        let hexStringX = SecurityAide.hexString(hexData!)
        assert(hexString == hexStringX, "hexString != hexStringX")

        let xhexString = "0x\(hexString)"

        let xhexData = SecurityAide.hexData(xhexString)
        XCTAssertNotNil(xhexData, "xhexData == nil")

        let xhexStringX = SecurityAide.hexString(xhexData!)
        assert(hexString == xhexStringX, "hexString != xhexStringX")
    }

    func testBase64() {
        let text = "test"
        let base64 = SecurityAide.base64EncodedString(text)
        let decoded = SecurityAide.base64DecodedData(base64)
        XCTAssertNotNil(decoded, "Base64 decode failed.")
        let textx = String.init(data: decoded!, encoding: .utf8)
        XCTAssertNotNil(textx, "Base64 decode failed.")
        XCTAssert(textx! == text, "textx != text")
    }

    func testURLEncode() {
        let text = "test"
        let encoded = SecurityAide.urlEncodedString(text)
        XCTAssertNotNil(encoded, "URL encode failed.")
        let decoded = SecurityAide.urlDecodedString(encoded!)
        XCTAssertNotNil(decoded, "URL decode failed.")
        XCTAssert(decoded! == text, "URL encode/decode failed.")

        let text1 = "测试"
        let encoded1 = SecurityAide.urlEncodedString(text1)
        XCTAssertNotNil(encoded1, "URL encode failed.")
        let decoded1 = SecurityAide.urlDecodedString(encoded1!)
        XCTAssertNotNil(decoded1, "URL decode failed.")
        XCTAssert(decoded1! == text1, "URL encode/decode failed.")
    }

    func testMD5() {
        let hash0 = SecurityAide.md5HashString(kText0)
        assert(hash0 == kText0MD5, "Invalid md5 hash.")

        let hash1 = SecurityAide.md5HashString(kText1)
        assert(hash1 == kText1MD5, "Invalid md5 hash.")
    }

    func testFileMD5() {
        let text = kText1
        let textMD5 = kText1MD5
        let data = text.data(using: .utf8)
        XCTAssertNotNil(data, "Invalid data.")
        let fileURL = PathAide.docFileURL(withSubPath: "test.data")
        let result = FileManagerAide.removeItem(fileURL)
        XCTAssert(result, "Remove file failed.")
        try? data!.write(to: fileURL, options: .atomic)

        let fileMD5 = SecurityAide.fileMD5HashString(fileURL)
        XCTAssertNotNil(fileMD5, "Invalid file md5.")
        XCTAssert(fileMD5! == textMD5, "Invalid file md5.")

        let fastFileMD5 = SecurityAide.fastFileMD5HashString(fileURL, usingFileSize: false)
        XCTAssertNotNil(fastFileMD5, "Invalid file md5.")
        XCTAssert(fastFileMD5! == textMD5, "Invalid file md5.")

        let fastFileMD50 = SecurityAide.fastFileMD5HashString(fileURL, usingFileSize: true)
        XCTAssertNotNil(fastFileMD50, "Invalid file md5.")
        XCTAssert(fastFileMD50! != textMD5, "Invalid file md5.")
    }

    func testSHA() {
        let sha1Hash0 = SecurityAide.sha1HashString(kText0)
        assert(sha1Hash0 == kText0SHA1, "Invalid SHA1 hash.")

        let sha256Hash0 = SecurityAide.shaHashString(kText0, type: .SHA256)
        assert(sha256Hash0 == kText0SHA256, "Invalid SHA256 hash.")

        let sha512Hash0 = SecurityAide.shaHashString(kText0, type: .SHA512)
        assert(sha512Hash0 == kText0SHA512, "Invalid SHA512 hash.")

        let sha1Hash1 = SecurityAide.sha1HashString(kText1)
        assert(sha1Hash1 == kText1SHA1, "Invalid SHA1 hash.")

        let sha256Hash1 = SecurityAide.shaHashString(kText1, type: .SHA256)
        assert(sha256Hash1 == kText1SHA256, "Invalid SHA256 hash.")

        let sha512Hash1 = SecurityAide.shaHashString(kText1, type: .SHA512)
        assert(sha512Hash1 == kText1SHA512, "Invalid SHA512 hash.")
    }

    func testAES() {
        let password = "test_key"

        let text = "test"
        let data = text.data(using: .utf8)
        XCTAssertNotNil(data, "Invalid data.")

        let aes128EncryptedData = SecurityAide.aesEncrypt(data!, type: .AES128, password: password)
        XCTAssertNotNil(aes128EncryptedData, "Invalid AES128 encryption.")

        let aes128DecryptedData = SecurityAide.aesDecrypt(aes128EncryptedData!, type: .AES128, password: password)
        XCTAssertNotNil(aes128DecryptedData, "Invalid AES128 decryption.")

        let aes128DecryptedString = String.init(data: aes128DecryptedData!, encoding: .utf8)
        XCTAssert(aes128DecryptedString == text, "Invalid AES128.")

        let aes256EncryptedData = SecurityAide.aesEncrypt(data!, type: .AES256, password: password)
        XCTAssertNotNil(aes256EncryptedData, "Invalid AES256 encryption.")

        let aes256DecryptedData = SecurityAide.aesDecrypt(aes256EncryptedData!, type: .AES256, password: password)
        XCTAssertNotNil(aes256DecryptedData, "Invalid AES256 decryption.")

        let aes256DecryptedString = String.init(data: aes256DecryptedData!, encoding: .utf8)
        XCTAssert(aes256DecryptedString == text, "Invalid AES256.")
    }
}
