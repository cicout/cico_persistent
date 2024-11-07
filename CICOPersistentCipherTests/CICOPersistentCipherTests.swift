//
//  CICOPersistentCipherTests.swift
//  CICOPersistentCipherTests
//
//  Created by Ethan.Li on 2024/11/7.
//  Copyright © 2024 cico. All rights reserved.
//

import XCTest
import CICOFoundationKit
import CICOAutoCodable
import CICOPersistent
@testable import CICOPersistentCipher

final class CICOPersistentCipherTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_performance() {
        let url1 = PathAide.docFileURL(withSubPath: "cico_persistent_tests/encrypted_kv_db_2")
        DebugAide.showDuration(closure: {
            _ = KVDBService.init(fileURL: url1, password: "cico_test")
        }, customKey: "encrypted_kv_db_2")

        let url2 = PathAide.docFileURL(withSubPath: "cico_persistent_tests/unencrypted_kv_db_2")
        DebugAide.showDuration(closure: {
            _ = KVDBService.init(fileURL: url2, password: nil)
        }, customKey: "unencrypted_kv_db_2")

        let url3 = PathAide.docFileURL(withSubPath: "cico_persistent_tests/encrypted_orm_db_2")
        DebugAide.showDuration(closure: {
            _ = ORMDBService.init(fileURL: url3, password: "cico_test")
        }, customKey: "encrypted_orm_db_2")

        let url4 = PathAide.docFileURL(withSubPath: "cico_persistent_tests/unencrypted_orm_db_2")
        DebugAide.showDuration(closure: {
            _ = ORMDBService.init(fileURL: url4, password: nil)
        }, customKey: "unencrypted_orm_db_2")

        XCTAssert(true, "Done!")
    }

}
