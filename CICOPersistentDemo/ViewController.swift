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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func testBtnAction(_ sender: Any) {
        self.doTest()
    }
    
    private func doTest() {
        self.test(123)
        self.test(2.5)
        self.test(false)
        self.test("test")
        
        let jsonString = self.jsonString(name: "default")
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            return
        }
        
        if let object = try? self.defaultJSONDecoder().decode(TCodableClass.self, from: jsonData) {
            self.test(object)
        }
        
        if let object2 = try? self.defaultJSONDecoder().decode(TCodableStruct.self, from: jsonData) {
            self.test(object2)
        }
    }
    
    private func test<T: Codable>(_ value: T) {
        print("[ORIGINAL]: \(value)")
        
        let key = "test"
        let result = CICOPublicPersistentService.shared.writeObject(value, forKey: key)
        print("[WRITE]: \(result)")
        
        if let readValue = CICOPublicPersistentService.shared.readObject(T.self, forKey: key) {
            print("[READ]: \(readValue)")
        }
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

