//
//  ORMDBServiceTests.swift
//  CICOPersistentTests
//
//  Created by lucky.li on 2018/8/4.
//  Copyright © 2018 cico. All rights reserved.
//

import XCTest
import CICOFoundationKit
import CICOPersistent

class ORMDBServiceTests: XCTestCase {
    var service: ORMDBService!
    var jsonString: String!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        let url = PathAide.docFileURL(withSubPath: "cico_persistent_tests/orm_db")
        print("\(url)")
        self.service = ORMDBService.init(fileURL: url)

        //        let customURL = PathAide.docFileURL(withSubPath: "cico_persistent_tests/custom_password_orm_db")
        //        print("\(customURL)")
        //        self.service = ORMDBService.init(fileURL: customURL, password: "cico_test")

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

        DebugAide.showDuration(closure: {
            let writeResult = self.service.writeObject(object!)
            XCTAssert(writeResult, "[FAILED]: write failed")
        }, customKey: "writeObject")

        DebugAide.showDuration(closure: {
            let readObject = self.service.readObject(ofType: TCodableClass.self, primaryKeyValue: .single(object!.name))
            XCTAssertNotNil(readObject, "[FAILED]: read failed")
            XCTAssert(readObject! == object!, "[FAILED]: read object is not equal to original object")
        }, customKey: "readObject")

        DebugAide.showDuration(closure: {
            let removeResult = self.service.removeObject(ofType: TCodableClass.self,
                                                         primaryKeyValue: .single(object!.name))
            XCTAssert(removeResult, "[FAILED]: remove failed")
        }, customKey: "removeObject")
    }

    func test_Struct() {
        let object = TCodableStruct.init(jsonString: self.jsonString)
        XCTAssertNotNil(object, "[FAILED]: invalid object")

        DebugAide.showDuration(closure: {
            let writeResult = self.service.writeObject(object!)
            XCTAssert(writeResult, "[FAILED]: write failed")
        }, customKey: "writeObject")

        DebugAide.showDuration(closure: {
            let readObject = self.service.readObject(ofType: TCodableStruct.self,
                                                     primaryKeyValue: .single(object!.name))
            XCTAssertNotNil(readObject, "[FAILED]: read failed")
            XCTAssert(readObject! == object!, "[FAILED]: read object is not equal to original object")
        }, customKey: "readObject")

        DebugAide.showDuration(closure: {
            let removeResult = self.service.removeObject(ofType: TCodableStruct.self,
                                                         primaryKeyValue: .single(object!.name))
            XCTAssert(removeResult, "[FAILED]: remove failed")
        }, customKey: "removeObject")
    }

    func test_Class_Array() {
        var objectArray = [TCodableClass]()
        for index in 0..<50 {
            let object = TCodableClass.init(jsonString: self.jsonString)
            XCTAssertNotNil(object, "[FAILED]: invalid object")
            object!.name = "name_\(index)"
            objectArray.append(object!)
        }

        let writeResult = self.service.writeObjectArray(objectArray)
        XCTAssert(writeResult, "[FAILED]: write failed")

        DebugAide.showDuration(closure: {
            let readObjectArray =
            self.service
                .readObjectArray(ofType: TCodableClass.self,
                                 whereString: nil,
                                 orderByName: "name",
                                 descending: true,
                                 limit: 10)
            XCTAssertNotNil(readObjectArray, "[FAILED]: read failed")
            XCTAssert(readObjectArray!.count > 1, "[FAILED]: read failed")

            let object0 = readObjectArray![0]
            let object1 = readObjectArray![1]
            XCTAssertNotNil(object0.name, "[FAILED]: read failed")
            XCTAssertNotNil(object1.name, "[FAILED]: read failed")
            XCTAssert(object0.name! > object1.name!, "[FAILED]: read failed")
        }, customKey: "readObjectArray")

        DebugAide.showDuration(closure: {
            let removeResult = self.service.removeObjects(ofType: TCodableClass.self,
                                                          whereString: "name LIKE 'name_%'")
            XCTAssert(removeResult, "[FAILED]: remove failed")
        }, customKey: "removeObjects")
    }

    func test_Class_updateObject() {
        let key = "test_class_update"
        let updatedKey = "updated"

        let object = TCodableClass.init(jsonString: self.jsonString)
        XCTAssertNotNil(object, "[FAILED]: invalid object")
        object!.name = key

        self.service
            .updateObject(ofType: TCodableClass.self,
                          primaryKeyValue: .single(object!.name),
                          customTableName: nil,
                          updateClosure: { (readObject) -> TCodableClass? in
                XCTAssertNil(readObject, "[FAILED]: read not exist object failed")
                return object
            },
                          completionClosure: { (result) in
                XCTAssert(result, "[FAILED]: update failed")
            })

        self.service
            .updateObject(ofType: TCodableClass.self,
                          primaryKeyValue: .single(object!.name),
                          customTableName: nil,
                          updateClosure: { (readObject) -> TCodableClass? in
                XCTAssertNotNil(readObject, "[FAILED]: read exist object failed")
                readObject!.name = updatedKey
                return readObject
            },
                          completionClosure: { (result) in
                XCTAssert(result, "[FAILED]: update failed")
            })

        self.service
            .updateObject(ofType: TCodableClass.self,
                          primaryKeyValue: .single(object!.name),
                          customTableName: nil,
                          updateClosure: { (readObject) -> TCodableClass? in
                XCTAssertNotNil(readObject, "[FAILED]: read exist object failed")
                return nil
            },
                          completionClosure: { (result) in
                XCTAssert(result, "[FAILED]: update failed")
            })

        let removeResult = self.service.removeObject(ofType: TCodableClass.self, primaryKeyValue: .single(object!.name))
        XCTAssert(removeResult, "[FAILED]: remove failed")

        let removeResult2 = self.service.removeObject(ofType: TCodableClass.self, primaryKeyValue: .single(updatedKey))
        XCTAssert(removeResult2, "[FAILED]: remove failed")
    }

    func test_where() {
        var objectArray = [TCodableClass]()
        for index in 0..<10 {
            let object = TCodableClass.init(jsonString: self.jsonString)
            XCTAssertNotNil(object, "[FAILED]: invalid object")
            object!.name = "name_\(index)"
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

        let object = TCodableStruct.init(jsonString: self.jsonString)
        XCTAssertNotNil(object, "[FAILED]: invalid object")

        DebugAide.showDuration(closure: {
            let writeResult = self.service.writeObject(object!)
            XCTAssert(writeResult, "[FAILED]: write failed")
        }, customKey: "writeObject")
    }

    func test_performance() {
        let url1 = PathAide.docFileURL(withSubPath: "cico_persistent_tests/encrypted_orm_db")
        DebugAide.showDuration(closure: {
            _ = ORMDBService.init(fileURL: url1, password: "cico_test")
        }, customKey: "encrypted_orm_db")

        let url2 = PathAide.docFileURL(withSubPath: "cico_persistent_tests/unencrypted_orm_db")
        DebugAide.showDuration(closure: {
            _ = ORMDBService.init(fileURL: url2, password: nil)
        }, customKey: "unencrypted_orm_db")

        XCTAssert(true, "Done!")
    }

    func test_auto_increment() {
        var objectArray = [TAutoIncrement].init()
        for index in 0..<10 {
            let object = TAutoIncrement.init(stringValue: "test_\(index)")
            objectArray.append(object)
        }
        let writeResult = self.service.writeObjectArray(objectArray)
        XCTAssert(writeResult, "[FAILED]: write failed")

        let readObjectArray =
        self.service
            .readObjectArray(ofType: TAutoIncrement.self,
                             whereString: nil,
                             orderByName: "rowID",
                             descending: true,
                             limit: 10)
        XCTAssertNotNil(readObjectArray, "[FAILED]: read failed")
        XCTAssert(readObjectArray!.count == 10, "[FAILED]: read failed")

        let object0 = readObjectArray![0]
        let object9 = readObjectArray![9]
        XCTAssertNotNil(object0.rowID, "[FAILED]: read failed")
        XCTAssertNotNil(object9.rowID, "[FAILED]: read failed")
        print("[#]: object0.rowID = \(object0.rowID!), object9.rowID = \(object9.rowID!)")
        XCTAssert(object0.rowID! - object9.rowID! == 9, "[FAILED]: read failed")
    }
}

extension ORMDBServiceTests {
    func test_Composite() {
        let object = TCompositeStruct.init(jsonString: self.jsonString)
        XCTAssertNotNil(object, "[FAILED]: invalid object")

        DebugAide.showDuration(closure: {
            let writeResult = self.service.writeObject(object!)
            XCTAssert(writeResult, "[FAILED]: write failed")
        }, customKey: "writeObject")

        let keyValues: [Any] = [object!.stringID, object!.intID]

        DebugAide.showDuration(closure: {
            let readObject = self.service.readObject(ofType: TCompositeStruct.self,
                                                     primaryKeyValue: .composite(keyValues))
            XCTAssertNotNil(readObject, "[FAILED]: read failed")
            XCTAssert(readObject! == object!, "[FAILED]: read object is not equal to original object")
        }, customKey: "readObject")

        let updatedName = "updated_name"

        DebugAide.showDuration(closure: {
            self.service
                .updateObject(ofType: TCompositeStruct.self,
                              primaryKeyValue: .composite(keyValues),
                              updateClosure: { (readObject) -> TCompositeStruct? in
                    XCTAssertNotNil(readObject, "[FAILED]: read exist object failed")
                    var newObject = readObject
                    newObject!.name = updatedName
                    return newObject
                },
                              completionClosure: { (result) in
                    XCTAssert(result, "[FAILED]: update failed")
                })
        }, customKey: "updateObject")

        DebugAide.showDuration(closure: {
            let readObject = self.service.readObject(ofType: TCompositeStruct.self,
                                                     primaryKeyValue: .composite(keyValues))
            XCTAssertNotNil(readObject, "[FAILED]: read failed")
            XCTAssert(readObject!.name == updatedName, "[FAILED]: read object name is not updated")
        }, customKey: "readObject")

        DebugAide.showDuration(closure: {
            let removeResult = self.service.removeObject(ofType: TCompositeStruct.self,
                                                         primaryKeyValue: .composite(keyValues))
            XCTAssert(removeResult, "[FAILED]: remove failed")
        }, customKey: "removeObject")
    }

    func test_Composite_Array() {
        var objects = [TCompositeStruct]()
        for index in 0..<50 {
            var object = TCompositeStruct.init(jsonString: self.jsonString)
            XCTAssertNotNil(object, "[FAILED]: invalid object")
            object!.stringID = "string_id_\(index)"
            object!.intID = index
            object!.name = "name_\(index)"
            objects.append(object!)
        }

        let writeResult = self.service.writeObjectArray(objects)
        XCTAssert(writeResult, "[FAILED]: write failed")

        DebugAide.showDuration(closure: {
            let readObjects =
            self.service
                .readObjectArray(ofType: TCompositeStruct.self,
                                 whereString: nil,
                                 orderByName: "name",
                                 descending: true,
                                 limit: 10)
            XCTAssertNotNil(readObjects, "[FAILED]: read failed")
            XCTAssert(readObjects!.count > 1, "[FAILED]: read failed")

            let object0 = readObjects![0]
            let object1 = readObjects![1]
            XCTAssertNotNil(object0.name, "[FAILED]: read failed")
            XCTAssertNotNil(object1.name, "[FAILED]: read failed")
            XCTAssert(object0.name! > object1.name!, "[FAILED]: read failed")
        }, customKey: "readObjects")

        DebugAide.showDuration(closure: {
            let removeResult = self.service.removeObjects(ofType: TCompositeStruct.self,
                                                          whereString: "name LIKE 'name_%'")
            XCTAssert(removeResult, "[FAILED]: remove failed")
        }, customKey: "removeObjects")
    }
}
