//
//  SQLCipherTests.swift
//  CICOPersistentTests
//
//  Created by lucky.li on 2019/9/23.
//  Copyright © 2019 cico. All rights reserved.
//
// swiftlint:disable function_body_length

import XCTest
import CICOPersistent

class SQLCipherTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSQLCipher() {
        let url1 = PathAide.docFileURL(withSubPath: "orm_sql_cipher_original.db")
        let url2 = PathAide.docFileURL(withSubPath: "orm_sql_cipher_export_nop2p.db")
        let originalPassword2 = "cico_test_2"
        let password2 = SecurityAide.md5HashString(originalPassword2)
        let url3 = PathAide.docFileURL(withSubPath: "orm_sql_cipher_export_p2nop.db")
        let url4 = PathAide.docFileURL(withSubPath: "orm_sql_cipher_export_p2p.db")
        let originalPassword4 = "cico_test_4"
        let password4 = SecurityAide.md5HashString(originalPassword4)
        let url5 = PathAide.docFileURL(withSubPath: "orm_sql_cipher_encrypt.db")
        let originalPassword5 = "cico_test_5"
        let password5 = SecurityAide.md5HashString(originalPassword5)
        let url6 = PathAide.docFileURL(withSubPath: "orm_sql_cipher_decrypt.db")
        let originalPassword6 = "cico_test_6"
        let password6 = SecurityAide.md5HashString(originalPassword6)

        var result = false

        result = FileManagerAide.removeItem(url1)
        XCTAssert(result, "Clear db failed.")

        result = FileManagerAide.removeItem(url2)
        XCTAssert(result, "Clear db failed.")

        result = FileManagerAide.removeItem(url3)
        XCTAssert(result, "Clear db failed.")

        result = FileManagerAide.removeItem(url4)
        XCTAssert(result, "Clear db failed.")

        result = FileManagerAide.removeItem(url5)
        XCTAssert(result, "Clear db failed.")

        result = FileManagerAide.removeItem(url6)
        XCTAssert(result, "Clear db failed.")

        var ormDBService1: ORMDBService? = ORMDBService.init(fileURL: url1, password: nil)

        // read json
        let jsonString = JSONStringAide.jsonString(name: "default")

        // write array
        var objectArray = [TCodableClass]()
        for index in 0..<10 {
            let object = TCodableClass.init(jsonString: jsonString)
            XCTAssertNotNil(object, "Invalid object.")

            object!.name = "name_\(index)"
            objectArray.append(object!)
        }
        _ = ormDBService1?.writeObjectArray(objectArray)

        ormDBService1 = nil

        // export no password to password
        result = SQLCipherAide.exportDatabase(fromDBPath: url1.path,
                                                  fromDBPassword: nil,
                                                  toDBPath: url2.path,
                                                  toDBPassword: password2)
        XCTAssert(result, "Export failed.")

        let ormDBService2 = ORMDBService.init(fileURL: url2, password: originalPassword2)

        // read array
        let array2 = ormDBService2.readObjectArray(ofType: TCodableClass.self,
                                                   whereString: nil,
                                                   orderByName: "name",
                                                   descending: false,
                                                   limit: 10)
        XCTAssert(array2!.count == 10, "Invalid exported database.")

        // export password to no password
        result = SQLCipherAide.exportDatabase(fromDBPath: url2.path,
                                              fromDBPassword: password2,
                                              toDBPath: url3.path,
                                              toDBPassword: nil)
        XCTAssert(result, "Export failed.")

        let ormDBService3 = ORMDBService.init(fileURL: url3, password: nil)

        // read array
        let array3 = ormDBService3.readObjectArray(ofType: TCodableClass.self,
                                                   whereString: nil,
                                                   orderByName: "name",
                                                   descending: false,
                                                   limit: 10)
        XCTAssert(array3!.count == 10, "Invalid exported database.")

        // export password to password
        result = SQLCipherAide.exportDatabase(fromDBPath: url2.path,
                                              fromDBPassword: password2,
                                              toDBPath: url4.path,
                                              toDBPassword: password4)
        XCTAssert(result, "Export failed.")

        let ormDBService4 = ORMDBService.init(fileURL: url4, password: originalPassword4)

        // read array
        let array4 = ormDBService4.readObjectArray(ofType: TCodableClass.self,
                                                   whereString: nil,
                                                   orderByName: "name",
                                                   descending: false,
                                                   limit: 10)
        XCTAssert(array4!.count == 10, "Invalid exported database.")

        // encrypt db
        result = SQLCipherAide.exportDatabase(fromDBPath: url1.path,
                                              fromDBPassword: nil,
                                              toDBPath: url5.path,
                                              toDBPassword: nil)
        XCTAssert(result, "Export failed.")

        result = SQLCipherAide.encryptDatabase(dbPath: url5.path, password: password5)
        XCTAssert(result, "Export failed.")

        let ormDBService5 = ORMDBService.init(fileURL: url5, password: originalPassword5)

        // read array
        let array5 = ormDBService5.readObjectArray(ofType: TCodableClass.self,
                                                   whereString: nil,
                                                   orderByName: "name",
                                                   descending: false,
                                                   limit: 10)
        XCTAssert(array5!.count == 10, "Invalid exported database.")

        // decrypt db
        result = SQLCipherAide.exportDatabase(fromDBPath: url1.path,
                                              fromDBPassword: nil,
                                              toDBPath: url6.path,
                                              toDBPassword: password6)
        XCTAssert(result, "Export failed.")

        result = SQLCipherAide.decryptDatabase(dbPath: url6.path, password: password6)
        XCTAssert(result, "Export failed.")

        let ormDBService6 = ORMDBService.init(fileURL: url6, password: nil)

        // read array
        let array6 = ormDBService6.readObjectArray(ofType: TCodableClass.self,
                                                   whereString: nil,
                                                   orderByName: "name",
                                                   descending: false,
                                                   limit: 10)
        XCTAssert(array6!.count == 10, "Invalid exported database.")

        // change password
    }

    func testDBSecurity() {
        let url1 = PathAide.docFileURL(withSubPath: "orm_db_security_decrypt.db")
        let url2 = PathAide.docFileURL(withSubPath: "orm_db_security_encrypt.db")
        let password2 = "cico_test_2"
        let url3 = PathAide.docFileURL(withSubPath: "orm_db_security_change_password.db")
        let password3 = "cico_test_3"
        let password3x = "cico_test_3x"

        var result = false

        result = FileManagerAide.removeItem(url1)
        XCTAssert(result, "Clear db failed.")

        result = FileManagerAide.removeItem(url2)
        XCTAssert(result, "Clear db failed.")

        result = FileManagerAide.removeItem(url3)
        XCTAssert(result, "Clear db failed.")

        var ormDBService1: ORMDBService? = ORMDBService.init(fileURL: url1)

        // read json
        let jsonString = JSONStringAide.jsonString(name: "default")

        // write array
        var objectArray = [TCodableClass]()
        for index in 0..<10 {
            let object = TCodableClass.init(jsonString: jsonString)
            XCTAssertNotNil(object, "Invalid object.")

            object!.name = "name_\(index)"
            objectArray.append(object!)
        }
        _ = ormDBService1?.writeObjectArray(objectArray)

        ormDBService1 = nil

        // decrypt
        result = DBSecurityAide.decryptDatabase(dbPath: url1.path, password: kCICOORMDBDefaultPassword)
        XCTAssert(result, "Decrypt database failed.")

        var ormDBService1x: ORMDBService? = ORMDBService.init(fileURL: url1, password: nil)

        // read array
        let array1 = ormDBService1x?.readObjectArray(ofType: TCodableClass.self,
                                                     whereString: nil,
                                                     orderByName: "name",
                                                     descending: false,
                                                     limit: 10)
        XCTAssert(array1!.count == 10, "Invalid database.")

        ormDBService1x = nil

        // encrypt
        result = DBSecurityAide.exportDatabase(fromDBPath: url1.path,
                                               fromDBPassword: nil,
                                               toDBPath: url2.path,
                                               toDBPassword: nil)
        XCTAssert(result, "Export database failed.")

        result = DBSecurityAide.encryptDatabase(dbPath: url2.path, password: password2)
        XCTAssert(result, "Encrypt database failed.")

        var ormDBService2: ORMDBService? = ORMDBService.init(fileURL: url2, password: password2)

        // read array
        let array2 = ormDBService2?.readObjectArray(ofType: TCodableClass.self,
                                                    whereString: nil,
                                                    orderByName: "name",
                                                    descending: false,
                                                    limit: 10)
        XCTAssert(array2!.count == 10, "Invalid database.")

        ormDBService2 = nil

        // change password
        result = DBSecurityAide.exportDatabase(fromDBPath: url2.path,
                                               fromDBPassword: password2,
                                               toDBPath: url3.path,
                                               toDBPassword: password3)
        XCTAssert(result, "Export database failed.")

        result = DBSecurityAide.changeDatabasePassword(dbPath: url3.path,
                                                       originalPassword: password3,
                                                       newPassword: password3x)
        XCTAssert(result, "Change database password failed.")

        var ormDBService3: ORMDBService? = ORMDBService.init(fileURL: url3, password: password3x)

        // read array
        let array3 = ormDBService3?.readObjectArray(ofType: TCodableClass.self,
                                                    whereString: nil,
                                                    orderByName: "name",
                                                    descending: false,
                                                    limit: 10)
        XCTAssert(array3!.count == 10, "Invalid database.")

        ormDBService3 = nil
    }
}
