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
        self.doORMDBTest()
//        self.doKVKeyChainTest()
    }
    
    private func doSecurityTest() {
        if let hash = CICOSecurityAide.md5HashString(with: "") {
            print("hash = \(hash)")
        }
    }
    
    private func doPersistentTest() {
        self.testPersistent(123)
        self.testPersistent(2.5)
        self.testPersistent(false)
        self.testPersistent("test")
        
        let jsonString = self.jsonString(name: "default")
        
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
        
        let jsonString = self.jsonString(name: "default")
        
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
        
        let jsonString = self.jsonString(name: "default")

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
        let jsonString = self.jsonString(name: "default")
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
        
        let jsonString = self.jsonString(name: "default")
        
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
    
    private func jsonString(name: String) -> String {
        guard let path = Bundle.main.path(forResource: name, ofType: "json") else {
            return ""
        }
        
        guard let jsonString = try? String(contentsOfFile: path, encoding: String.Encoding.utf8) else {
            return ""
        }
        
        return jsonString
    }
}

