//
//  CICOURLTests.swift
//  CICOPersistentTests
//
//  Created by lucky.li on 2018/8/29.
//  Copyright © 2018 cico. All rights reserved.
//

import XCTest
import CICOPersistent
import CICOAutoCodable

class CICOFileURLTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_CICOURL() {
        self.commonTest(url: CICOPathAide.docFileURL(withSubPath: nil))
        self.commonTest(url: CICOPathAide.docFileURL(withSubPath: "test"))
        self.commonTest(url: CICOPathAide.libFileURL(withSubPath: nil))
        self.commonTest(url: CICOPathAide.libFileURL(withSubPath: "test"))
        self.commonTest(url: CICOPathAide.cacheFileURL(withSubPath: nil))
        self.commonTest(url: CICOPathAide.cacheFileURL(withSubPath: "test"))
        self.commonTest(url: CICOPathAide.tempFileURL(withSubPath: nil))
        self.commonTest(url: CICOPathAide.tempFileURL(withSubPath: "test"))
    }
    
    private func commonTest(url: URL) {
        let curl = CICOFileURL.init(fileURL: url)
        XCTAssertNotNil(curl, "[FAILED]: Invalid CICOURL.")
        
        let jsonString = curl.toJSONString()
        XCTAssertNotNil(jsonString, "[FAILED]: CICOURL transfer to json string failed.")
        
        let curlx = CICOFileURL.init(jsonString: jsonString!)
        XCTAssertNotNil(curlx, "[FAILED]: JSON string transfer back to CICOURL failed.")
        XCTAssert(curlx!.fileURL! == curl.fileURL!, "[FAILED]: curlx != curl.")
    }
}
