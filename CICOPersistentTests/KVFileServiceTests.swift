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
    var fileService: KVFileService!
    var defaultJSONString: String!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let url = CICOPathAide.docFileURL(withSubPath: "cico_persistent_tests/kv_file")!
        self.fileService = KVFileService.init(rootDirURL: url)
        self.defaultJSONString = JSONStringAide.jsonString(name: "default")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        self.fileService = nil
        self.defaultJSONString = nil
    }
    
    func test_Service() {
        XCTAssertNotNil(self.fileService, "[FAILED]: invalid service")
    }
    
    func test_JSONString() {
        XCTAssertNotNil(self.defaultJSONString, "[FAILED]: invalid json string")
    }
    
    func test_Class() {
        let value = TCodableClass.init(jsonString: self.defaultJSONString)
        XCTAssertNotNil(value, "[FAILED]: invalid value")
        
        self.testCommonKVFile(value)
    }
    
    func test_Struct() {
        let value = TCodableStruct.init(jsonString: self.defaultJSONString)
        XCTAssertNotNil(value, "[FAILED]: invalid value")
        
        self.testCommonKVFile(value)
    }
    
    func test_Int() {
        let value: Int = 8
        self.testCommonKVFile(value)
    }
    
    func test_Double() {
        let value: Double = 8.5
        self.testCommonKVFile(value)
    }
    
    func test_Bool() {
        let value: Bool = false
        self.testCommonKVFile(value)
    }
    
    func test_String() {
        let value: String = "test_string"
        self.testCommonKVFile(value)
    }
    
    func test_Date() {
        let value: Date = Date.init()
        self.testCommonKVFile(value)
    }
    
    func test_URL() {
        let value: URL = URL.init(string: "https://www.google.com")!
        self.testCommonKVFile(value)
    }
    
    func test_Class_Update() {
        let key = "test_class_update"
        
        let value = TCodableClass.init(jsonString: self.defaultJSONString)
        XCTAssertNotNil(value, "[FAILED]: invalid value")
        
        self.fileService
            .updateObject(TCodableClass.self,
                          forKey: key,
                          updateClosure: { (readObject) -> TCodableClass? in
                            XCTAssertNil(readObject, "[FAILED]: read not exist object failed")
                            return value
            }) { (result) in
                XCTAssert(result, "[FAILED]: update failed")
        }
        
        self.fileService
            .updateObject(TCodableClass.self,
                          forKey: key,
                          updateClosure: { (readObject) -> TCodableClass? in
                            XCTAssertNotNil(readObject, "[FAILED]: read exist object failed")
                            readObject?.name = "name_updated"
                            return readObject
            }) { (result) in
                XCTAssert(result, "[FAILED]: update failed")
        }
        
        self.fileService
            .updateObject(TCodableClass.self,
                          forKey: key,
                          updateClosure: { (readObject) -> TCodableClass? in
                            XCTAssertNotNil(readObject, "[FAILED]: read exist object failed")
                            return nil
            }) { (result) in
                XCTAssert(result, "[FAILED]: update failed")
        }
        
        let removeResult = self.fileService.removeObject(forKey: key)
        XCTAssert(removeResult, "[FAILED]: remove failed: value = \(value)")
    }
    
    func test_ClearAll() {
        let clearResult = self.fileService.clearAll()
        XCTAssert(clearResult, "[FAILED]: clear failed")
    }
    
    private func testCommonKVFile<T: Codable>(_ value: T) {
        let key = "test_\(T.self)"

        let writeResult = self.fileService.writeObject(value, forKey: key)
        XCTAssert(writeResult, "[FAILED]: write failed: value = \(value)")
        
        let readValue = self.fileService.readObject(T.self, forKey: key)
        XCTAssertNotNil(readValue, "[FAILED]: read failed: value = \(value)")
        
        let removeResult = self.fileService.removeObject(forKey: key)
        XCTAssert(removeResult, "[FAILED]: remove failed: value = \(value)")
    }
}
