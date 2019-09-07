//
//  SecurityAideTests.swift
//  CICOPersistentTests
//
//  Created by lucky.li on 2019/9/5.
//  Copyright © 2019 cico. All rights reserved.
//

import XCTest
import CICOPersistent

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

    func testMD5() {
        let text0 = ""
        let hash0 = SecurityAide.md5HashString(text0)
        let hashx0 = CICOSecurityAide.md5HashString(with: text0)
        assert(hash0 == hashx0, "hash0 != hashx0")

        let text1 = "test"
        let hash1 = SecurityAide.md5HashString(text1)
        let hashx1 = CICOSecurityAide.md5HashString(with: text1)
        assert(hash1 == hashx1, "hash1 != hashx1")
    }
}
