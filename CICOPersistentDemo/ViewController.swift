//
//  ViewController.swift
//  CICOPersistentDemo
//
//  Created by lucky.li on 2018/6/7.
//  Copyright © 2018 cico. All rights reserved.
//
// swiftlint:disable function_body_length

import UIKit
import CICOPersistent
import CICOAutoCodable
import FMDB

class ViewController: UIViewController {
    private var ormDBService: ORMDBService?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        print("\(PathAide.docPath(withSubPath: nil))")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func testBtnAction(_ sender: Any) {
//        self.doSecurityTest()
        self.doKVKeyChainTest()
//        self.doSQLCipherTest()
//        self.doDBSecurityTest()
    }

    private func doSecurityTest() {
        let hash = SecurityAide.md5HashString("")
        print("hash = \(hash)")
    }

    private func doKVKeyChainTest() {
        self.testKVKeyChain(123)
        self.testKVKeyChain(2.5)
        self.testKVKeyChain(false)
        self.testKVKeyChain("test")

        let jsonString = JSONStringAide.jsonString(name: "default")

        guard let jsonData = jsonString.data(using: .utf8) else {
            return
        }

        if let object = TCodableClass.init(jsonData: jsonData) {
            self.testKVKeyChain(object)
        }

        if let object2 = TCodableStruct.init(jsonData: jsonData) {
            self.testKVKeyChain(object2)
        }
    }

    private func doSQLCipherTest() {
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

        var ormDBService1: ORMDBService? = ORMDBService.init(fileURL: url1, password: nil)

        // read json
        let jsonString = JSONStringAide.jsonString(name: "default")
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("[ERROR]")
            return
        }

        // write array
        var objectArray = [TCodableClass]()
        for index in 0..<10 {
            guard let object = TCodableClass.init(jsonData: jsonData) else {
                print("[ERROR]")
                return
            }
            object.name = "name_\(index)"
            objectArray.append(object)
        }
        _ = ormDBService1?.writeObjectArray(objectArray)

        ormDBService1 = nil

        // export no password to password
        var result = CICOSQLCipherAide.exportDatabase(url1.path,
                                                      fromDBPassword: nil,
                                                      toDBPath: url2.path,
                                                      toDBPassword: password2)
        print("result = \(result)")

        let ormDBService2 = ORMDBService.init(fileURL: url2, password: originalPassword2)

        // read array
        if let arrayX = ormDBService2.readObjectArray(ofType: TCodableClass.self,
                                                      whereString: nil,
                                                      orderByName: "name",
                                                      descending: false,
                                                      limit: 10) {
            print("[READ]: \(arrayX)")
        }

        // export password to no password
        result = CICOSQLCipherAide.exportDatabase(url2.path,
                                                  fromDBPassword: password2,
                                                  toDBPath: url3.path,
                                                  toDBPassword: nil)
        print("result = \(result)")

        let ormDBService3 = ORMDBService.init(fileURL: url3, password: nil)

        // read array
        if let arrayX = ormDBService3.readObjectArray(ofType: TCodableClass.self,
                                                      whereString: nil,
                                                      orderByName: "name",
                                                      descending: false,
                                                      limit: 10) {
            print("[READ]: \(arrayX)")
        }

        // export password to password
        result = CICOSQLCipherAide.exportDatabase(url2.path,
                                                  fromDBPassword: password2,
                                                  toDBPath: url4.path,
                                                  toDBPassword: password4)
        print("result = \(result)")

        let ormDBService4 = ORMDBService.init(fileURL: url4, password: originalPassword4)

        // read array
        if let arrayX = ormDBService4.readObjectArray(ofType: TCodableClass.self,
                                                      whereString: nil,
                                                      orderByName: "name",
                                                      descending: false,
                                                      limit: 10) {
            print("[READ]: \(arrayX)")
        }

        // encrypt db
        result = CICOSQLCipherAide.exportDatabase(url1.path,
                                                  fromDBPassword: nil,
                                                  toDBPath: url5.path,
                                                  toDBPassword: nil)
        print("result = \(result)")

        result = CICOSQLCipherAide.encryptDatabase(url5.path, password: password5)
        print("result = \(result)")

        let ormDBService5 = ORMDBService.init(fileURL: url5, password: originalPassword5)

        // read array
        if let arrayX = ormDBService5.readObjectArray(ofType: TCodableClass.self,
                                                      whereString: nil,
                                                      orderByName: "name",
                                                      descending: false,
                                                      limit: 10) {
            print("[READ]: \(arrayX)")
        }

        // decrypt db
        result = CICOSQLCipherAide.exportDatabase(url1.path,
                                                  fromDBPassword: nil,
                                                  toDBPath: url6.path,
                                                  toDBPassword: password6)
        print("result = \(result)")

        result = CICOSQLCipherAide.decryptDatabase(url6.path, password: password6)
        print("result = \(result)")

        let ormDBService6 = ORMDBService.init(fileURL: url6, password: nil)

        // read array
        if let arrayX = ormDBService6.readObjectArray(ofType: TCodableClass.self,
                                                      whereString: nil,
                                                      orderByName: "name",
                                                      descending: false,
                                                      limit: 10) {
            print("[READ]: \(arrayX)")
        }
    }

    private func doDBSecurityTest() {
        let url1 = PathAide.docFileURL(withSubPath: "orm_db_security_decrypt.db")
        let url2 = PathAide.docFileURL(withSubPath: "orm_db_security_encrypt.db")
        let password2 = "cico_test_2"
        let url3 = PathAide.docFileURL(withSubPath: "orm_db_security_change_password.db")
        let password3 = "cico_test_3"
        let password3x = "cico_test_3x"

        var ormDBService1: ORMDBService? = ORMDBService.init(fileURL: url1)

        // read json
        let jsonString = JSONStringAide.jsonString(name: "default")
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("[ERROR]")
            return
        }

        // write array
        var objectArray = [TCodableClass]()
        for index in 0..<10 {
            guard let object = TCodableClass.init(jsonData: jsonData) else {
                print("[ERROR]")
                return
            }
            object.name = "name_\(index)"
            objectArray.append(object)
        }
        _ = ormDBService1?.writeObjectArray(objectArray)

        ormDBService1 = nil

        // decrypt
        var result = DBSecurityAide.decryptDatabase(dbPath: url1.path, password: kCICOORMDBDefaultPassword)
        print("result = \(result)")

        var ormDBService1x: ORMDBService? = ORMDBService.init(fileURL: url1, password: nil)

        // read array
        if let arrayX = ormDBService1x?.readObjectArray(ofType: TCodableClass.self,
                                                        whereString: nil,
                                                        orderByName: "name",
                                                        descending: false,
                                                        limit: 10) {
            print("[READ]: \(arrayX)")
        }

        ormDBService1x = nil

        // encrypt
        result = DBSecurityAide.exportDatabase(fromDBPath: url1.path,
                                               fromDBPassword: nil,
                                               toDBPath: url2.path,
                                               toDBPassword: nil)
        print("result = \(result)")

        result = DBSecurityAide.encryptDatabase(dbPath: url2.path, password: password2)
        print("result = \(result)")

        var ormDBService2: ORMDBService? = ORMDBService.init(fileURL: url2, password: password2)

        // read array
        if let arrayX = ormDBService2?.readObjectArray(ofType: TCodableClass.self,
                                                       whereString: nil,
                                                       orderByName: "name",
                                                       descending: false,
                                                       limit: 10) {
            print("[READ]: \(arrayX)")
        }

        ormDBService2 = nil

        // change password
        result = DBSecurityAide.exportDatabase(fromDBPath: url2.path,
                                               fromDBPassword: password2,
                                               toDBPath: url3.path,
                                               toDBPassword: password3)
        print("result = \(result)")

        result = DBSecurityAide.changeDatabasePassword(dbPath: url3.path,
                                                       originalPassword: password3,
                                                       newPassword: password3x)
        print("result = \(result)")

        var ormDBService3: ORMDBService? = ORMDBService.init(fileURL: url3, password: password3x)

        // read array
        if let arrayX = ormDBService3?.readObjectArray(ofType: TCodableClass.self,
                                                       whereString: nil,
                                                       orderByName: "name",
                                                       descending: false,
                                                       limit: 10) {
            print("[READ]: \(arrayX)")
        }

        ormDBService3 = nil
    }

    private func testKVKeyChain<T: Codable>(_ value: T) {
        print("\n[***** START TESTING *****]\n")

        print("[ORIGINAL]: \(value)")

        let key = "test_\(T.self)"

        let result = KVKeyChainService.defaultService.writeObject(value, forKey: key)
        print("[WRITE]: \(result)")

        if let readValue = KVKeyChainService.defaultService.readObject(T.self, forKey: key) {
            print("[READ]: \(readValue)")
        }

        KVKeyChainService
            .defaultService
            .updateObject(T.self,
                          forKey: key,
                          updateClosure: { (object) -> T? in
                            if let object = object {
                                print("[UPDATE CLOSURE]: object = \(object)")
                            }
                            return nil
            },
                          completionClosure: { (result) in
                            print("[UPDATE]: \(result)")
            })

        let removeResult = KVKeyChainService.defaultService.removeObject(forKey: key)
        print("[REMOVE]: \(removeResult)")

        print("\n[***** END TESTING *****]\n")
    }
}
