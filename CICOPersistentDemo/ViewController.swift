//
//  ViewController.swift
//  CICOPersistentDemo
//
//  Created by lucky.li on 2018/6/7.
//  Copyright © 2018 cico. All rights reserved.
//

import UIKit
import CICOPersistent

class ViewController: UIViewController {
    private var ormDBService: CICOORMDBService?
    
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
//        self.doPersistentTest()
//        self.doKVFileTest()
//        self.doKVDBTest()
        self.doORMDBTest()
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
        
        if let object = try? self.defaultJSONDecoder().decode(TCodableClass.self, from: jsonData) {
            self.testPersistent(object)
        }
        
        if let object2 = try? self.defaultJSONDecoder().decode(TCodableStruct.self, from: jsonData) {
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
        
        if let object = try? self.defaultJSONDecoder().decode(TCodableClass.self, from: jsonData) {
            self.testKVFile(object)
        }
        
        if let object2 = try? self.defaultJSONDecoder().decode(TCodableStruct.self, from: jsonData) {
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

        if let object = try? self.defaultJSONDecoder().decode(TCodableClass.self, from: jsonData) {
            self.testKVDB(object)
        }

        if let object2 = try? self.defaultJSONDecoder().decode(TCodableStruct.self, from: jsonData) {
            self.testKVDB(object2)
        }
    }
    
    private func doORMDBTest() {
        self.ormDBService = CICOORMDBService.init(fileURL: CICOPathAide.docFileURL(withSubPath: "orm.db"))
        
        // read json
        let jsonString = self.jsonString(name: "default")
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("[ERROR]")
            return
        }
        
        // write
//        guard let object = try? self.defaultJSONDecoder().decode(TCodableClass.self, from: jsonData) else {
//            print("[ERROR]")
//            return
//        }
//
//        let _ = self.ormDBService?.writeObject(object, customTableName: "custom_table_name")
        
        // read
//        if let objectX = self.ormDBService?.readObject(ofType: TCodableClass.self, forPrimaryKey: "name", customTableName: "custom_table_name") {
//            print("\(objectX)")
//        }
        
        // write array
        var objectArray = [TCodableClass]()
        for i in 0..<50 {
            guard let object = try? self.defaultJSONDecoder().decode(TCodableClass.self, from: jsonData) else {
                print("[ERROR]")
                return
            }
            object.name = "name_\(i)"
            objectArray.append(object)
        }
        let _ = self.ormDBService?.writeObjectArray(objectArray, customTableName: "custom_table_name")
        
        // read array
        if let arrayX = self.ormDBService?.readObjectArray(ofType: TCodableClass.self, whereString: nil, orderByName: "name", descending: false, limit: 10, customTableName: "custom_table_name") {
            print("\(arrayX)")
        }
        
        // remove object
//        let result = self.ormDBService!.removeObject(ofType: TCodableClass.self, forPrimaryKey: "name_0", customTableName: "custom_table_name")
//        print("result = \(result)")
        
        // remove table
//        let result = self.ormDBService!.removeObjectTable(ofType: TCodableClass.self, customTableName: "custom_table_name")
//        print("result = \(result)")
    }
    
    private func testPersistent<T: Codable>(_ value: T) {
        print("\n[***** START TESTING *****]\n")
        
        print("[ORIGINAL]: \(value)")
        
        let key = "test_\(T.self)"
        
        print("[***** PUBLIC KVFILE *****]")
        
        let result = CICOPublicPersistentService.shared.writeKVFileObject(value, forKey: key)
        print("[WRITE]: \(result)")
        
        if let readValue = CICOPublicPersistentService.shared.readKVFileObject(T.self, forKey: key) {
            print("[READ]: \(readValue)")
        }
        
//        let removeResult = CICOPublicPersistentService.shared.removeKVFileObject(forKey: key)
//        print("[REMOVE]: \(removeResult)")
        
        print("[***** PRIVATE KVFILE *****]")
        
        let result2 = CICOPrivatePersistentService.shared.writeKVFileObject(value, forKey: key)
        print("[WRITE]: \(result2)")
        
        if let readValue2 = CICOPrivatePersistentService.shared.readKVFileObject(T.self, forKey: key) {
            print("[READ]: \(readValue2)")
        }
        
        print("[***** CACHE KVFILE *****]")
        
        let result3 = CICOCachePersistentService.shared.writeKVFileObject(value, forKey: key)
        print("[WRITE]: \(result3)")
        
        if let readValue3 = CICOCachePersistentService.shared.readKVFileObject(T.self, forKey: key) {
            print("[READ]: \(readValue3)")
        }
        
        print("[***** TEMP KVFILE *****]")
        
        let result4 = CICOTempPersistentService.shared.writeKVFileObject(value, forKey: key)
        print("[WRITE]: \(result4)")
        
        if let readValue4 = CICOTempPersistentService.shared.readKVFileObject(T.self, forKey: key) {
            print("[READ]: \(readValue4)")
        }
        
        print("[***** PUBLIC KVDB *****]")
        
        let resultx = CICOPublicPersistentService.shared.writeKVDBObject(value, forKey: key)
        print("[WRITE]: \(resultx)")
        
        if let readValuex = CICOPublicPersistentService.shared.readKVDBObject(T.self, forKey: key) {
            print("[READ]: \(readValuex)")
        }
        
//        let removeResultx = CICOPublicPersistentService.shared.removeKVDBObject(forKey: key)
//        print("[REMOVE]: \(removeResultx)")
        
        print("[***** PRIVATE KVDB *****]")
        
        let result2x = CICOPrivatePersistentService.shared.writeKVDBObject(value, forKey: key)
        print("[WRITE]: \(result2x)")
        
        if let readValue2x = CICOPrivatePersistentService.shared.readKVDBObject(T.self, forKey: key) {
            print("[READ]: \(readValue2x)")
        }
        
        print("[***** CACHE KVDB *****]")
        
        let result3x = CICOCachePersistentService.shared.writeKVDBObject(value, forKey: key)
        print("[WRITE]: \(result3x)")
        
        if let readValue3x = CICOCachePersistentService.shared.readKVDBObject(T.self, forKey: key) {
            print("[READ]: \(readValue3x)")
        }
        
        print("[***** TEMP KVDB *****]")
        
        let result4x = CICOTempPersistentService.shared.writeKVDBObject(value, forKey: key)
        print("[WRITE]: \(result4x)")
        
        if let readValue4x = CICOTempPersistentService.shared.readKVDBObject(T.self, forKey: key) {
            print("[READ]: \(readValue4x)")
        }
        
        print("\n[***** END TESTING *****]\n")
    }
    
    private func testKVFile<T: Codable>(_ value: T) {
        print("\n[***** START TESTING *****]\n")
        
        print("[ORIGINAL]: \(value)")
        
        let key = "test_\(T.self)"
        
        print("[***** PUBLIC *****]")
        
        let result = CICOPublicKVFileService.shared.writeObject(value, forKey: key)
        print("[WRITE]: \(result)")
        
        if let readValue = CICOPublicKVFileService.shared.readObject(T.self, forKey: key) {
            print("[READ]: \(readValue)")
        }
        
//        let removeResult = CICOPublicKVFileService.shared.removeObject(forKey: key)
//        print("[REMOVE]: \(removeResult)")
        
        print("[***** PRIVATE *****]")
        
        let result2 = CICOPrivateKVFileService.shared.writeObject(value, forKey: key)
        print("[WRITE]: \(result2)")
        
        if let readValue2 = CICOPrivateKVFileService.shared.readObject(T.self, forKey: key) {
            print("[READ]: \(readValue2)")
        }
        
        print("[***** CACHE *****]")
        
        let result3 = CICOCacheKVFileService.shared.writeObject(value, forKey: key)
        print("[WRITE]: \(result3)")
        
        if let readValue3 = CICOCacheKVFileService.shared.readObject(T.self, forKey: key) {
            print("[READ]: \(readValue3)")
        }
        
        print("[***** TEMP *****]")
        
        let result4 = CICOTempKVFileService.shared.writeObject(value, forKey: key)
        print("[WRITE]: \(result4)")
        
        if let readValue4 = CICOTempKVFileService.shared.readObject(T.self, forKey: key) {
            print("[READ]: \(readValue4)")
        }
        
        print("\n[***** END TESTING *****]\n")
    }
    
    private func testKVDB<T: Codable>(_ value: T) {
        print("\n[***** START TESTING *****]\n")
        
        print("[ORIGINAL]: \(value)")
        
        let key = "test_\(T.self)"
        
        print("[***** PUBLIC *****]")
        
        let result = CICOPublicKVDBService.shared.writeObject(value, forKey: key)
        print("[WRITE]: \(result)")
        
        if let readValue = CICOPublicKVDBService.shared.readObject(T.self, forKey: key) {
            print("[READ]: \(readValue)")
        }
        
//        let removeResult = CICOPublicKVDBService.shared.removeObject(forKey: key)
//        print("[REMOVE]: \(removeResult)")
        
        print("[***** PRIVATE *****]")
        
        let result2 = CICOPrivateKVDBService.shared.writeObject(value, forKey: key)
        print("[WRITE]: \(result2)")
        
        if let readValue2 = CICOPrivateKVDBService.shared.readObject(T.self, forKey: key) {
            print("[READ]: \(readValue2)")
        }
        
        print("[***** CACHE *****]")
        
        let result3 = CICOCacheKVDBService.shared.writeObject(value, forKey: key)
        print("[WRITE]: \(result3)")
        
        if let readValue3 = CICOCacheKVDBService.shared.readObject(T.self, forKey: key) {
            print("[READ]: \(readValue3)")
        }
        
        print("[***** TEMP *****]")
        
        let result4 = CICOTempKVDBService.shared.writeObject(value, forKey: key)
        print("[WRITE]: \(result4)")
        
        if let readValue4 = CICOTempKVDBService.shared.readObject(T.self, forKey: key) {
            print("[READ]: \(readValue4)")
        }
        
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
    
    private func defaultJSONDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        return decoder
    }
    
    private func defaultJSONEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        return encoder
    }
}

