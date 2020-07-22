//
//  ViewController.swift
//  CICOPersistentDemo
//
//  Created by lucky.li on 2018/6/7.
//  Copyright © 2018 cico. All rights reserved.
//

import UIKit
import CICOFoundationKit
import CICOAutoCodable
import CICOPersistent
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
        self.doKVKeyChainTest()
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
