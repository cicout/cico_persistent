//
//  KVFileServiceTests.swift
//  CICOPersistentTests
//
//  Created by lucky.li on 2018/8/2.
//  Copyright © 2018 cico. All rights reserved.
//

import XCTest
import CICOPersistent

class KVFileServiceTests: XCTestCase {
    var service: KVFileService!
    var jsonString: String!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        let url = CICOPathAide.docFileURL(withSubPath: "cico_persistent_tests/kv_file")
        self.service = KVFileService.init(rootDirURL: url)
        self.jsonString = JSONStringAide.jsonString(name: "default")
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()

        self.service = nil
        self.jsonString = nil
    }

    func test_Service() {
        XCTAssertNotNil(self.service, "[FAILED]: invalid service")
    }

    func test_JSONString() {
        XCTAssertNotNil(self.jsonString, "[FAILED]: invalid json string")
    }

    func test_Class() {
        let value = TCodableClass.init(jsonString: self.jsonString)
        XCTAssertNotNil(value, "[FAILED]: invalid value")

        self.commonTest(value)
    }

    func test_Struct() {
        let value = TCodableStruct.init(jsonString: self.jsonString)
        XCTAssertNotNil(value, "[FAILED]: invalid value")

        self.commonTest(value)
    }

    func test_Int() {
        let value: Int = 8
        self.commonTest(value)
    }

    func test_Double() {
        let value: Double = 8.5
        self.commonTest(value)
    }

    func test_Bool() {
        let value: Bool = false
        self.commonTest(value)
    }

    func test_String() {
        let value: String = "test_string"
        self.commonTest(value)
    }

    func test_Date() {
        let value: Date = Date.init()
        self.commonTest(value)
    }

    func test_URL() {
        let value: URL = URL.init(string: "https://www.google.com")!
        self.commonTest(value)
    }

    func test_Class_updateObject() {
        let key = "test_class_update"

        let value = TCodableClass.init(jsonString: self.jsonString)
        XCTAssertNotNil(value, "[FAILED]: invalid value")

        self.service
            .updateObject(TCodableClass.self,
                          forKey: key,
                          updateClosure: { (readObject) -> TCodableClass? in
                            XCTAssertNil(readObject, "[FAILED]: read not exist object failed")
                            return value
            },
                          completionClosure: { (result) in
                            XCTAssert(result, "[FAILED]: update failed")
            })

        self.service
            .updateObject(TCodableClass.self,
                          forKey: key,
                          updateClosure: { (readObject) -> TCodableClass? in
                            XCTAssertNotNil(readObject, "[FAILED]: read exist object failed")
                            readObject?.name = "name_updated"
                            return readObject
            },
                          completionClosure: { (result) in
                            XCTAssert(result, "[FAILED]: update failed")
            })

        self.service
            .updateObject(TCodableClass.self,
                          forKey: key,
                          updateClosure: { (readObject) -> TCodableClass? in
                            XCTAssertNotNil(readObject, "[FAILED]: read exist object failed")
                            return nil
            },
                          completionClosure: { (result) in
                            XCTAssert(result, "[FAILED]: update failed")
            })

        let removeResult = self.service.removeObject(forKey: key)
        XCTAssert(removeResult, "[FAILED]: remove failed: value = \(value!)")
    }

    func test_clearAll() {
        let clearResult = self.service.clearAll()
        XCTAssert(clearResult, "[FAILED]: clear failed")
    }

    private func commonTest<T: Codable & Equatable>(_ value: T) {
        let key = "test_\(T.self)"

        let writeResult = self.service.writeObject(value, forKey: key)
        XCTAssert(writeResult, "[FAILED]: write failed: value = \(value)")

        let readValue = self.service.readObject(T.self, forKey: key)
        XCTAssertNotNil(readValue, "[FAILED]: read failed: value = \(value)")
        XCTAssert(readValue! == value, "[FAILED]: read value is not equal to original value")

        let removeResult = self.service.removeObject(forKey: key)
        XCTAssert(removeResult, "[FAILED]: remove failed: value = \(value)")
    }
}
