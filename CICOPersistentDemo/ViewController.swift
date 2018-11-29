//
//  ViewController.swift
//  CICOPersistentDemo
//
//  Created by lucky.li on 2018/6/7.
//  Copyright © 2018 cico. All rights reserved.
//

import UIKit
import CICOPersistent
import CICOAutoCodable
import FMDB

class ViewController: UIViewController {
    private var ormDBService: ORMDBService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print("\(CICOPathAide.docPath(withSubPath: nil))")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func testBtnAction(_ sender: Any) {
//        self.doSecurityTest()
//        self.doPersistentTest()
//        self.doKVFileTest()
//        self.doKVDBTest()
//        self.doORMDBTest()
//        self.doKVKeyChainTest()
//        self.testMyClass()
//        self.doSQLCipherTest()
        self.doDBSecurityTest()
    }
    
    private func doSecurityTest() {
        let hash = CICOSecurityAide.md5HashString(with: "")
        print("hash = \(hash)")
    }
    
    private func doPersistentTest() {
        self.testPersistent(123)
        self.testPersistent(2.5)
        self.testPersistent(false)
        self.testPersistent("test")
        
        let jsonString = JSONStringAide.jsonString(name: "default")
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            return
        }
        
        if let object = TCodableClass.init(jsonData: jsonData) {
            self.testPersistent(object)
        }
        
        if let object2 = TCodableStruct.init(jsonData: jsonData) {
            self.testPersistent(object2)
        }
    }
    
    private func doKVFileTest() {
        self.testKVFile(123)
        self.testKVFile(2.5)
        self.testKVFile(false)
        self.testKVFile("test")
        
        let jsonString = JSONStringAide.jsonString(name: "default")
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            return
        }
        
        if let object = TCodableClass.init(jsonData: jsonData) {
            self.testKVFile(object)
        }
        
        if let object2 = TCodableStruct.init(jsonData: jsonData) {
            self.testKVFile(object2)
        }
    }
    
    private func doKVDBTest() {
        self.testKVDB(123)
        self.testKVDB(2.5)
        self.testKVDB(false)
        self.testKVDB("test")
        
        let jsonString = JSONStringAide.jsonString(name: "default")

        guard let jsonData = jsonString.data(using: .utf8) else {
            return
        }

        if let object = TCodableClass.init(jsonData: jsonData) {
            self.testKVDB(object)
        }
        
        if let object2 = TCodableStruct.init(jsonData: jsonData) {
            self.testKVDB(object2)
        }
    }
    
    private func doORMDBTest() {
        self.ormDBService = ORMDBService.init(fileURL: CICOPathAide.docFileURL(withSubPath: "orm.db"))
        
        // read json
        let jsonString = JSONStringAide.jsonString(name: "default")
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("[ERROR]")
            return
        }
        
        // write
        guard let object = TCodableClass.init(jsonData: jsonData) else {
            print("[ERROR]")
            return
        }

        let _ = self.ormDBService?.writeObject(object)
        
        // read
        if let objectX = self.ormDBService?.readObject(ofType: TCodableClass.self, primaryKeyValue: "name") {
            print("[READ]: \(objectX)")
        }
        
        // update
        self.ormDBService?.updateObject(ofType: TCodableClass.self,
                                        primaryKeyValue: "name",
                                        customTableName: nil,
                                        updateClosure: { (object) -> TCodableClass? in
                                            guard let object = object else {
                                                return nil
                                            }
                                            
                                            print("object = \(object)")
                                            object.name = "name_x"
                                            return object
        },
                                        completionClosure: { (result) in
                                            print("result = \(result)")
        })
        
        // write array
        var objectArray = [TCodableClass]()
        for i in 0..<50 {
            guard let object = TCodableClass.init(jsonData: jsonData) else {
                print("[ERROR]")
                return
            }
            object.name = "name_\(i)"
            objectArray.append(object)
        }
        let _ = self.ormDBService?.writeObjectArray(objectArray)
        
        // read array
        if let arrayX = self.ormDBService?.readObjectArray(ofType: TCodableClass.self, whereString: nil, orderByName: "name", descending: false, limit: 10) {
            print("[READ]: \(arrayX)")
        }
        
        // remove object
        let result = self.ormDBService!.removeObject(ofType: TCodableClass.self, primaryKeyValue: "name_0")
        print("result = \(result)")
        
        // remove table
//        let resultX = self.ormDBService!.removeObjectTable(ofType: TCodableClass.self)
//        print("result = \(resultX)")
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
        let url1 = CICOPathAide.docFileURL(withSubPath: "orm_sql_cipher_original.db")
        let url2 = CICOPathAide.docFileURL(withSubPath: "orm_sql_cipher_export_nop2p.db")
        let originalPassword2 = "cico_test_2"
        let password2 = CICOSecurityAide.md5HashString(with: originalPassword2)
        let url3 = CICOPathAide.docFileURL(withSubPath: "orm_sql_cipher_export_p2nop.db")
        let url4 = CICOPathAide.docFileURL(withSubPath: "orm_sql_cipher_export_p2p.db")
        let originalPassword4 = "cico_test_4"
        let password4 = CICOSecurityAide.md5HashString(with: originalPassword4)
        let url5 = CICOPathAide.docFileURL(withSubPath: "orm_sql_cipher_encrypt.db")
        let originalPassword5 = "cico_test_5"
        let password5 = CICOSecurityAide.md5HashString(with: originalPassword5)
        let url6 = CICOPathAide.docFileURL(withSubPath: "orm_sql_cipher_decrypt.db")
        let originalPassword6 = "cico_test_6"
        let password6 = CICOSecurityAide.md5HashString(with: originalPassword6)
        
        var ormDBService1: ORMDBService? = ORMDBService.init(fileURL: url1, password: nil)
        
        // read json
        let jsonString = JSONStringAide.jsonString(name: "default")
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("[ERROR]")
            return
        }
        
        // write array
        var objectArray = [TCodableClass]()
        for i in 0..<10 {
            guard let object = TCodableClass.init(jsonData: jsonData) else {
                print("[ERROR]")
                return
            }
            object.name = "name_\(i)"
            objectArray.append(object)
        }
        let _ = ormDBService1?.writeObjectArray(objectArray)
        
        ormDBService1 = nil
        
        // export no password to password
        var result = CICOSQLCipherAide.exportDatabase(url1.path,
                                                      fromDBPassword: nil,
                                                      toDBPath: url2.path,
                                                      toDBPassword: password2)
        print("result = \(result)")
        
        let ormDBService2 = ORMDBService.init(fileURL: url2, password: originalPassword2)
        
        // read array
        if let arrayX = ormDBService2.readObjectArray(ofType: TCodableClass.self, whereString: nil, orderByName: "name", descending: false, limit: 10) {
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
        if let arrayX = ormDBService3.readObjectArray(ofType: TCodableClass.self, whereString: nil, orderByName: "name", descending: false, limit: 10) {
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
        if let arrayX = ormDBService4.readObjectArray(ofType: TCodableClass.self, whereString: nil, orderByName: "name", descending: false, limit: 10) {
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
        if let arrayX = ormDBService5.readObjectArray(ofType: TCodableClass.self, whereString: nil, orderByName: "name", descending: false, limit: 10) {
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
        if let arrayX = ormDBService6.readObjectArray(ofType: TCodableClass.self, whereString: nil, orderByName: "name", descending: false, limit: 10) {
            print("[READ]: \(arrayX)")
        }
    }
    
    private func doDBSecurityTest() {
        let url1 = CICOPathAide.docFileURL(withSubPath: "orm_db_security_decrypt.db")
        let url2 = CICOPathAide.docFileURL(withSubPath: "orm_db_security_encrypt.db")
        let password2 = "cico_test_2"
        let url3 = CICOPathAide.docFileURL(withSubPath: "orm_db_security_change_password.db")
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
        for i in 0..<10 {
            guard let object = TCodableClass.init(jsonData: jsonData) else {
                print("[ERROR]")
                return
            }
            object.name = "name_\(i)"
            objectArray.append(object)
        }
        let _ = ormDBService1?.writeObjectArray(objectArray)
        
        ormDBService1 = nil
        
        // decrypt
        var result = DBSecurityAide.decryptDatabase(dbPath: url1.path, password: kCICOORMDBDefaultPassword)
        print("result = \(result)")
        
        var ormDBService1x: ORMDBService? = ORMDBService.init(fileURL: url1, password: nil)
        
        // read array
        if let arrayX = ormDBService1x?.readObjectArray(ofType: TCodableClass.self, whereString: nil, orderByName: "name", descending: false, limit: 10) {
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
        if let arrayX = ormDBService2?.readObjectArray(ofType: TCodableClass.self, whereString: nil, orderByName: "name", descending: false, limit: 10) {
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
        if let arrayX = ormDBService3?.readObjectArray(ofType: TCodableClass.self, whereString: nil, orderByName: "name", descending: false, limit: 10) {
            print("[READ]: \(arrayX)")
        }
        
        ormDBService3 = nil
    }
    
    private func testPersistent<T: Codable>(_ value: T) {
        print("\n[***** START TESTING *****]\n")
        
        print("[ORIGINAL]: \(value)")
        
        let key = "test_\(T.self)"
        
        print("[***** PUBLIC KVFILE *****]")
        
        let result = PublicPersistentService.shared.writeKVFileObject(value, forKey: key)
        print("[WRITE]: \(result)")
        
        if let readValue = PublicPersistentService.shared.readKVFileObject(T.self, forKey: key) {
            print("[READ]: \(readValue)")
        }
        
//        let removeResult = PublicPersistentService.shared.removeKVFileObject(forKey: key)
//        print("[REMOVE]: \(removeResult)")
        
        print("[***** PRIVATE KVFILE *****]")
        
        let result2 = PrivatePersistentService.shared.writeKVFileObject(value, forKey: key)
        print("[WRITE]: \(result2)")
        
        if let readValue2 = PrivatePersistentService.shared.readKVFileObject(T.self, forKey: key) {
            print("[READ]: \(readValue2)")
        }
        
        print("[***** CACHE KVFILE *****]")
        
        let result3 = CachePersistentService.shared.writeKVFileObject(value, forKey: key)
        print("[WRITE]: \(result3)")
        
        if let readValue3 = CachePersistentService.shared.readKVFileObject(T.self, forKey: key) {
            print("[READ]: \(readValue3)")
        }
        
        print("[***** TEMP KVFILE *****]")
        
        let result4 = TempPersistentService.shared.writeKVFileObject(value, forKey: key)
        print("[WRITE]: \(result4)")
        
        if let readValue4 = TempPersistentService.shared.readKVFileObject(T.self, forKey: key) {
            print("[READ]: \(readValue4)")
        }
        
        print("[***** PUBLIC KVDB *****]")
        
        let resultx = PublicPersistentService.shared.writeKVDBObject(value, forKey: key)
        print("[WRITE]: \(resultx)")
        
        if let readValuex = PublicPersistentService.shared.readKVDBObject(T.self, forKey: key) {
            print("[READ]: \(readValuex)")
        }
        
//        let removeResultx = PublicPersistentService.shared.removeKVDBObject(forKey: key)
//        print("[REMOVE]: \(removeResultx)")
        
        print("[***** PRIVATE KVDB *****]")
        
        let result2x = PrivatePersistentService.shared.writeKVDBObject(value, forKey: key)
        print("[WRITE]: \(result2x)")
        
        if let readValue2x = PrivatePersistentService.shared.readKVDBObject(T.self, forKey: key) {
            print("[READ]: \(readValue2x)")
        }
        
        print("[***** CACHE KVDB *****]")
        
        let result3x = CachePersistentService.shared.writeKVDBObject(value, forKey: key)
        print("[WRITE]: \(result3x)")
        
        if let readValue3x = CachePersistentService.shared.readKVDBObject(T.self, forKey: key) {
            print("[READ]: \(readValue3x)")
        }
        
        print("[***** TEMP KVDB *****]")
        
        let result4x = TempPersistentService.shared.writeKVDBObject(value, forKey: key)
        print("[WRITE]: \(result4x)")
        
        if let readValue4x = TempPersistentService.shared.readKVDBObject(T.self, forKey: key) {
            print("[READ]: \(readValue4x)")
        }
        
        print("\n[***** END TESTING *****]\n")
    }
    
    private func testKVFile<T: Codable>(_ value: T) {
        print("\n[***** START TESTING *****]\n")
        
        print("[ORIGINAL]: \(value)")
        
        let key = "test_\(T.self)"
        
        print("[***** PUBLIC *****]")
        
        let result = PublicKVFileService.shared.writeObject(value, forKey: key)
        print("[WRITE]: \(result)")
        
        if let readValue = PublicKVFileService.shared.readObject(T.self, forKey: key) {
            print("[READ]: \(readValue)")
        }
        
//        let removeResult = PublicKVFileService.shared.removeObject(forKey: key)
//        print("[REMOVE]: \(removeResult)")
        
        print("[***** PRIVATE *****]")
        
        let result2 = PrivateKVFileService.shared.writeObject(value, forKey: key)
        print("[WRITE]: \(result2)")
        
        if let readValue2 = PrivateKVFileService.shared.readObject(T.self, forKey: key) {
            print("[READ]: \(readValue2)")
        }
        
        print("[***** CACHE *****]")
        
        let result3 = CacheKVFileService.shared.writeObject(value, forKey: key)
        print("[WRITE]: \(result3)")
        
        if let readValue3 = CacheKVFileService.shared.readObject(T.self, forKey: key) {
            print("[READ]: \(readValue3)")
        }
        
        print("[***** TEMP *****]")
        
        let result4 = TempKVFileService.shared.writeObject(value, forKey: key)
        print("[WRITE]: \(result4)")
        
        if let readValue4 = TempKVFileService.shared.readObject(T.self, forKey: key) {
            print("[READ]: \(readValue4)")
        }
        
        print("\n[***** END TESTING *****]\n")
    }
    
    private func testKVDB<T: Codable>(_ value: T) {
        print("\n[***** START TESTING *****]\n")
        
        print("[ORIGINAL]: \(value)")
        
        let key = "test_\(T.self)"
        
        print("[***** PUBLIC *****]")
        
        let result = PublicKVDBService.shared.writeObject(value, forKey: key)
        print("[WRITE]: \(result)")
        
        if let readValue = PublicKVDBService.shared.readObject(T.self, forKey: key) {
            print("[READ]: \(readValue)")
        }
        
//        let removeResult = PublicKVDBService.shared.removeObject(forKey: key)
//        print("[REMOVE]: \(removeResult)")
        
        print("[***** PRIVATE *****]")
        
        let result2 = PrivateKVDBService.shared.writeObject(value, forKey: key)
        print("[WRITE]: \(result2)")
        
        if let readValue2 = PrivateKVDBService.shared.readObject(T.self, forKey: key) {
            print("[READ]: \(readValue2)")
        }
        
        print("[***** CACHE *****]")
        
        let result3 = CacheKVDBService.shared.writeObject(value, forKey: key)
        print("[WRITE]: \(result3)")
        
        if let readValue3 = CacheKVDBService.shared.readObject(T.self, forKey: key) {
            print("[READ]: \(readValue3)")
        }
        
        print("[***** TEMP *****]")
        
        let result4 = TempKVDBService.shared.writeObject(value, forKey: key)
        print("[WRITE]: \(result4)")
        
        if let readValue4 = TempKVDBService.shared.readObject(T.self, forKey: key) {
            print("[READ]: \(readValue4)")
        }
        
        print("\n[***** END TESTING *****]\n")
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
            }) { (result) in
                print("[UPDATE]: \(result)")
        }
        
        let removeResult = KVKeyChainService.defaultService.removeObject(forKey: key)
        print("[REMOVE]: \(removeResult)")
        
        print("\n[***** END TESTING *****]\n")
    }
    
    private func testMyClass() {
//        let myJSONString = JSONStringAide.jsonString(name: "my")
//        let key = "test_my_class"
        
        /** //KVFileService
        // Initialization
        //```swift
        let url = CICOPathAide.defaultPrivateFileURL(withSubPath: "cico_persistent_tests/kv_file")!
        let service = KVFileService.init(rootDirURL: url)
        //```
        // Read
        //```swift
        let readValue = service.readObject(MyClass.self, forKey: key)
        //```
        // Write
        //```swift
        let value = MyClass.init(jsonString: myJSONString)!
        let writeResult = service.writeObject(value, forKey: key)
        //```
        // Remove
        //```swift
        let removeResult = service.removeObject(forKey: key)
        //```
        // Update
        //It is a read-update-write sequence function during one lock.
        //```swift
        service
            .updateObject(MyClass.self,
                          forKey: key,
                          updateClosure: { (readObject) -> MyClass? in
                            readObject?.stringValue = "updated_string"
                            return readObject
            }) { (result) in
                print("result = \(result)")
        }
        //```
        // ClearAll
        //```swift
        let clearResult = service.clearAll()
        //```
        **/
        
        /** //URLKVFileService
        let url = CICOPathAide.defaultPrivateFileURL(withSubPath: "cico_persistent_tests/url_kv_file/test_my_class")!
        let dirURL = CICOPathAide.defaultPrivateFileURL(withSubPath: "cico_persistent_tests/url_kv_file")!
        let _ = CICOFileManagerAide.createDir(with: dirURL)
        // Initialization
        //```swift
        let service = URLKVFileService.init()
        //```
        // Read
        //```swift
        let readValue = service.readObject(MyClass.self, fromFileURL: url)
        //```
        // Write
        //```swift
        let value = MyClass.init(jsonString: myJSONString)!
        let writeResult = service.writeObject(value, toFileURL: url)
        //```
        // Remove
        //```swift
        let removeResult = service.removeObject(forFileURL: url)
        //```
        // Update
        //It is a read-update-write sequence function during one lock.
        //```swift
        service
            .updateObject(MyClass.self,
                          fromFileURL: url,
                          updateClosure: { (readObject) -> MyClass? in
                            readObject?.stringValue = "updated_string"
                            return readObject
            }) { (result) in
                print("result = \(result)")
        }
        //```
        **/
        
        /** //KVDBService
        // Initialization
        //```swift
        let url = CICOPathAide.defaultPrivateFileURL(withSubPath: "cico_persistent_tests/kv.db")!
        let service = KVDBService.init(fileURL: url)
        //```
        // Read
        //```swift
        let readValue = service.readObject(MyClass.self, forKey: key)
        //```
        // Write
        //```swift
        let value = MyClass.init(jsonString: myJSONString)!
        let writeResult = service.writeObject(value, forKey: key)
        //```
        // Remove
        //```swift
        let removeResult = service.removeObject(forKey: key)
        //```
        // Update
        //It is a read-update-write sequence function during one lock.
        //```swift
        service
            .updateObject(MyClass.self,
                          forKey: key,
                          updateClosure: { (readObject) -> MyClass? in
                            readObject?.stringValue = "updated_string"
                            return readObject
            }) { (result) in
                print("result = \(result)")
        }
        //```
        // ClearAll
        //```swift
        let clearResult = service.clearAll()
        //```
        **/
        
        /** //ORMDBService
        let primaryKey = "string"
        // Initialization
        //```swift
        let url = CICOPathAide.defaultPrivateFileURL(withSubPath: "cico_persistent_tests/orm.db")!
        let service = ORMDBService.init(fileURL: url)
        //```
        // Read
        //```swift
        let readObject = service.readObject(ofType: MyClass.self, primaryKeyValue: primaryKey)
        //```
        // Read Array
        //```
        let readObjectArray = service.readObjectArray(ofType: MyClass.self, whereString: nil, orderByName: "stringValue", descending: false, limit: 10)
        //```
        // Write
        //```swift
        let value = MyClass.init(jsonString: myJSONString)!
        let writeResult = service.writeObject(value)
        //```
        // Write Array
        //```
        var objectArray = [MyClass]()
        for i in 0..<20 {
            let object = MyClass.init(jsonString: myJSONString)!
            object.stringValue = "string_\(i)"
            objectArray.append(object)
        }
        let writeResult2 = service.writeObjectArray(objectArray)
        //```
        // Remove
        //```swift
        let removeResult = service.removeObject(ofType: MyClass.self, primaryKeyValue: primaryKey)
        //```
        // Remove Object Table
        //```
        let removeResult2 = service.removeObjectTable(ofType: MyClass.self)
        //```
        // Update
        //It is a read-update-write sequence function during one lock.
        //```swift
        service
            .updateObject(ofType: MyClass.self,
                          primaryKeyValue: primaryKey,
                          customTableName: nil,
                          updateClosure: { (readObject) -> MyClass? in
                            readObject?.stringValue = "updated_string"
                            return readObject
            }) { (result) in
                print("result = \(result)")
        }
        //```
        // ClearAll
        //```swift
        let clearResult = service.clearAll()
        //```
        **/
        
        /** //KVKeyChainService
        // Initialization
        //```swift
        let service = KVKeyChainService.init(encryptionKey: "test_encryption_key")
        // You can also use KVKeyChainService.defaultService instead
        //```
        // Read
        //```swift
        let readValue = KVKeyChainService.defaultService.readObject(MyClass.self, forKey: key)
        //```
        // Write
        //```swift
        let value = MyClass.init(jsonString: myJSONString)!
        let result = KVKeyChainService.defaultService.writeObject(value, forKey: key)
        //```
        // Remove
        //```swift
        let removeResult = KVKeyChainService.defaultService.removeObject(forKey: key)
        //```
        // Update
        //It is a read-update-write sequence function during one lock.
        //```swift
        KVKeyChainService
            .defaultService
            .updateObject(MyClass.self,
                          forKey: key,
                          updateClosure: { (readObject) -> MyClass? in
                            readObject?.stringValue = "updated_string"
                            return readObject
            }) { (result) in
                print("result = \(result)")
        }
        //```
        **/
    }
}

