//
//  URLKVFileServiceTests.swift
//  CICOPersistentTests
//
//  Created by lucky.li on 2018/8/4.
//  Copyright © 2018 cico. All rights reserved.
//

import XCTest
import CICOPersistent

class URLKVFileServiceTests: XCTestCase {
    var service: URLKVFileService!
    var jsonString: String!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        self.service = URLKVFileService.init()
        self.jsonString = JSONStringAide.jsonString(name: "default")
        
        let dirURL = CICOPathAide.docFileURL(withSubPath: "cico_persistent_tests/url_kv_file")!
        let _ = CICOFileManagerAide.createDir(with: dirURL, option: false)
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
        
        let url = CICOPathAide.docFileURL(withSubPath: "cico_persistent_tests/url_kv_file/\(type(of: value!))")!
        self.commonTest(value, fileURL: url)
    }
    
    func test_Struct() {
        let value = TCodableStruct.init(jsonString: self.jsonString)
        XCTAssertNotNil(value, "[FAILED]: invalid value")
        
        let url = CICOPathAide.docFileURL(withSubPath: "cico_persistent_tests/url_kv_file/\(type(of: value!))")!
        self.commonTest(value, fileURL: url)
    }
    
    func test_Int() {
        let value: Int = 8
        let url = CICOPathAide.docFileURL(withSubPath: "cico_persistent_tests/url_kv_file/\(type(of: value))")!
        self.commonTest(value, fileURL: url)
    }
    
    func test_Double() {
        let value: Double = 8.5
        let url = CICOPathAide.docFileURL(withSubPath: "cico_persistent_tests/url_kv_file/\(type(of: value))")!
        self.commonTest(value, fileURL: url)
    }
    
    func test_Bool() {
        let value: Bool = false
        let url = CICOPathAide.docFileURL(withSubPath: "cico_persistent_tests/url_kv_file/\(type(of: value))")!
        self.commonTest(value, fileURL: url)
    }
    
    func test_String() {
        let value: String = "test_string"
        let url = CICOPathAide.docFileURL(withSubPath: "cico_persistent_tests/url_kv_file/\(type(of: value))")!
        self.commonTest(value, fileURL: url)
    }
    
    func test_Date() {
        let value: Date = Date.init()
        let url = CICOPathAide.docFileURL(withSubPath: "cico_persistent_tests/url_kv_file/\(type(of: value))")!
        self.commonTest(value, fileURL: url)
    }
    
    func test_URL() {
        let value: URL = URL.init(string: "https://www.google.com")!
        let url = CICOPathAide.docFileURL(withSubPath: "cico_persistent_tests/url_kv_file/\(type(of: value))")!
        self.commonTest(value, fileURL: url)
    }
    
    func test_Class_Update() {
        let url = CICOPathAide.docFileURL(withSubPath: "cico_persistent_tests/url_kv_file/test_class_update")!
        
        let value = TCodableClass.init(jsonString: self.jsonString)
        XCTAssertNotNil(value, "[FAILED]: invalid value")
        
        self.service
            .updateObject(TCodableClass.self,
                          fromFileURL: url,
                          updateClosure: { (readObject) -> TCodableClass? in
                            XCTAssertNil(readObject, "[FAILED]: read not exist object failed")
                            return value
            }) { (result) in
                XCTAssert(result, "[FAILED]: update failed")
        }
        
        self.service
            .updateObject(TCodableClass.self,
                          fromFileURL: url,
                          updateClosure: { (readObject) -> TCodableClass? in
                            XCTAssertNotNil(readObject, "[FAILED]: read exist object failed")
                            readObject?.name = "name_updated"
                            return readObject
            }) { (result) in
                XCTAssert(result, "[FAILED]: update failed")
        }
        
        self.service
            .updateObject(TCodableClass.self,
                          fromFileURL: url,
                          updateClosure: { (readObject) -> TCodableClass? in
                            XCTAssertNotNil(readObject, "[FAILED]: read exist object failed")
                            return nil
            }) { (result) in
                XCTAssert(result, "[FAILED]: update failed")
        }
        
        let removeResult = self.service.removeObject(forFileURL: url)
        XCTAssert(removeResult, "[FAILED]: remove failed: value = \(value)")
    }
    
    private func commonTest<T: Codable>(_ value: T, fileURL: URL) {
        let writeResult = self.service.writeObject(value, toFileURL: fileURL)
        XCTAssert(writeResult, "[FAILED]: write failed: value = \(value)")
        
        let readValue = self.service.readObject(T.self, fromFileURL: fileURL)
        XCTAssertNotNil(readValue, "[FAILED]: read failed: value = \(value)")
        
        let removeResult = self.service.removeObject(forFileURL: fileURL)
        XCTAssert(removeResult, "[FAILED]: remove failed: value = \(value)")
    }
}
