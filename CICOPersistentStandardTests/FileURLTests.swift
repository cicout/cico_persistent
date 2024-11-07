//
//  CICOURLTests.swift
//  CICOPersistentTests
//
//  Created by lucky.li on 2018/8/29.
//  Copyright © 2018 cico. All rights reserved.
//

import XCTest
import CICOFoundationKit
import CICOAutoCodable
import CICOPersistent

class FileURLTests: XCTestCase {

    func test_CICOURL() {
        self.commonTest(url: PathAide.docFileURL(withSubPath: nil))
        self.commonTest(url: PathAide.docFileURL(withSubPath: "test"))
        self.commonTest(url: PathAide.libFileURL(withSubPath: nil))
        self.commonTest(url: PathAide.libFileURL(withSubPath: "test"))
        self.commonTest(url: PathAide.cacheFileURL(withSubPath: nil))
        self.commonTest(url: PathAide.cacheFileURL(withSubPath: "test"))
        self.commonTest(url: PathAide.tempFileURL(withSubPath: nil))
        self.commonTest(url: PathAide.tempFileURL(withSubPath: "test"))
        self.commonTest(url: URL.init(string: "https://www.cico.com/test")!)
        self.commonTest(url: Bundle.main.bundleURL.appendingPathComponent("test.tmp"))
    }

    private func commonTest(url: URL) {
        let curl = FileURL.init(fileURL: url)
        XCTAssertNotNil(curl, "[FAILED]: Invalid CICOURL.")

        let jsonString = curl.toJSONString()
        XCTAssertNotNil(jsonString, "[FAILED]: CICOURL transfer to json string failed.")

        let curlx = FileURL.init(jsonString: jsonString!)
        XCTAssertNotNil(curlx, "[FAILED]: JSON string transfer back to CICOURL failed.")
        XCTAssert(curlx!.fileURL == curl.fileURL, "[FAILED]: curlx != curl.")
        print("curlx = \(curlx!)")
    }
}
