//
//  ORMDBServiceTests.swift
//  CICOPersistentTests
//
//  Created by lucky.li on 2018/8/4.
//  Copyright © 2018 cico. All rights reserved.
//

import XCTest
import CICOPersistent

class ORMDBServiceTests: XCTestCase {
    var service: ORMDBService!
    var jsonString: String!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
//        let url = CICOPathAide.docFileURL(withSubPath: "cico_persistent_tests/orm_db")!
//        print("\(url)")
//        self.service = ORMDBService.init(fileURL: url)
        
        let customURL = CICOPathAide.docFileURL(withSubPath: "cico_persistent_tests/custom_password_orm_db")!
//        print("\(customURL)")
        self.service = ORMDBService.init(fileURL: customURL, password: "cico_test")
        
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
        let object = TCodableClass.init(jsonString: self.jsonString)
        XCTAssertNotNil(object, "[FAILED]: invalid object")
        
        let writeResult = self.service.writeObject(object!)
        XCTAssert(writeResult, "[FAILED]: write failed")
        
        let readObject = self.service.readObject(ofType: TCodableClass.self, primaryKeyValue: object!.name)
        XCTAssertNotNil(readObject, "[FAILED]: read failed")
        XCTAssert(readObject! == object!, "[FAILED]: read object is not equal to original object")
        
        let removeResult = self.service.removeObject(ofType: TCodableClass.self, primaryKeyValue: object!.name)
        XCTAssert(removeResult, "[FAILED]: write failed")
    }
    
    func test_Struct() {
        let object = TCodableStruct.init(jsonString: self.jsonString)
        XCTAssertNotNil(object, "[FAILED]: invalid object")
        
        let writeResult = self.service.writeObject(object!)
        XCTAssert(writeResult, "[FAILED]: write failed")
        
        let readObject = self.service.readObject(ofType: TCodableStruct.self, primaryKeyValue: object!.name)
        XCTAssertNotNil(readObject, "[FAILED]: read failed")
        XCTAssert(readObject! == object!, "[FAILED]: read object is not equal to original object")
        
        let removeResult = self.service.removeObject(ofType: TCodableStruct.self, primaryKeyValue: object!.name)
        XCTAssert(removeResult, "[FAILED]: write failed")
    }
    
    func test_Class_Array() {
        var objectArray = [TCodableClass]()
        for i in 0..<50 {
            let object = TCodableClass.init(jsonString: self.jsonString)
            XCTAssertNotNil(object, "[FAILED]: invalid object")
            object!.name = "name_\(i)"
            objectArray.append(object!)
        }
        let writeResult = self.service.writeObjectArray(objectArray)
        XCTAssert(writeResult, "[FAILED]: write failed")
        
        let readObjectArray = self.service.readObjectArray(ofType: TCodableClass.self, whereString: nil, orderByName: "name", descending: true, limit: 10)
        XCTAssertNotNil(readObjectArray, "[FAILED]: read failed")
        XCTAssert(readObjectArray!.count > 1, "[FAILED]: read failed")
        
        let object0 = readObjectArray![0]
        let object1 = readObjectArray![1]
        XCTAssertNotNil(object0.name, "[FAILED]: read failed")
        XCTAssertNotNil(object1.name, "[FAILED]: read failed")
        XCTAssert(object0.name! > object1.name!, "[FAILED]: read failed")
    }
    
    func test_Class_updateObject() {
        let key = "test_class_update"
        let updatedKey = "updated"
        
        let object = TCodableClass.init(jsonString: self.jsonString)
        XCTAssertNotNil(object, "[FAILED]: invalid object")
        object!.name = key
        
        self.service
            .updateObject(ofType: TCodableClass.self,
                          primaryKeyValue: key,
                          customTableName: nil,
                          updateClosure: { (readObject) -> TCodableClass? in
                            XCTAssertNil(readObject, "[FAILED]: read not exist object failed")
                            return object
            }) { (result) in
                XCTAssert(result, "[FAILED]: update failed")
        }
        
        self.service
            .updateObject(ofType: TCodableClass.self,
                          primaryKeyValue: key,
                          customTableName: nil,
                          updateClosure: { (readObject) -> TCodableClass? in
                            XCTAssertNotNil(readObject, "[FAILED]: read exist object failed")
                            readObject!.name = updatedKey
                            return readObject
            }) { (result) in
                XCTAssert(result, "[FAILED]: update failed")
        }
        
        self.service
            .updateObject(ofType: TCodableClass.self,
                          primaryKeyValue: key,
                          customTableName: nil,
                          updateClosure: { (readObject) -> TCodableClass? in
                            XCTAssertNotNil(readObject, "[FAILED]: read exist object failed")
                            return nil
            }) { (result) in
                XCTAssert(result, "[FAILED]: update failed")
        }
        
        let removeResult = self.service.removeObject(ofType: TCodableClass.self, primaryKeyValue: key)
        XCTAssert(removeResult, "[FAILED]: remove failed")
        
        let removeResult2 = self.service.removeObject(ofType: TCodableClass.self, primaryKeyValue: updatedKey)
        XCTAssert(removeResult2, "[FAILED]: remove failed")
    }
    
    func test_where() {
        var objectArray = [TCodableClass]()
        for i in 0..<10 {
            let object = TCodableClass.init(jsonString: self.jsonString)
            XCTAssertNotNil(object, "[FAILED]: invalid object")
            object!.name = "name_\(i)"
            objectArray.append(object!)
        }
        let writeResult = self.service.writeObjectArray(objectArray)
        XCTAssert(writeResult, "[FAILED]: write failed")
        
        let readObjectArray =
            self.service
                .readObjectArray(ofType: TCodableClass.self,
                                 whereString: "name = 'name_5'",
                                 orderByName: "name",
                                 descending: false,
                                 limit: 10)
        XCTAssertNotNil(readObjectArray, "[FAILED]: read failed")
    }
    
    func test_Class_removeObjectTable() {
        let removeResult = self.service.removeObjectTable(ofType: TCodableClass.self)
        XCTAssert(removeResult, "[FAILED]: remove failed")
    }
    
    func test_clearAll() {
        let clearResult = self.service.clearAll()
        XCTAssert(clearResult, "[FAILED]: clear failed")
    }
}
