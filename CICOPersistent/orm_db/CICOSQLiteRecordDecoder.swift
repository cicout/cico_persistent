/*
 * Tencent is pleased to support the open source community by making
 * WCDB available.
 *
 * Copyright (C) 2017 THL A29 Limited, a Tencent company.
 * All rights reserved.
 *
 * Licensed under the BSD 3-Clause License (the "License"); you may not use
 * this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 *       https://opensource.org/licenses/BSD-3-Clause
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation
import FMDB
import CICOAutoCodable

class CICOSQLiteRecordDecoder: Decoder {
    private let resultSet: FMResultSet

    static func decodeSQLiteRecord<T: Decodable>(resultSet: FMResultSet, type: T.Type) -> T? {
        let decoder = CICOSQLiteRecordDecoder.init(resultSet: resultSet)
        do {
            let obj = try type.init(from: decoder)
            print("\(obj)")
            return obj
        } catch let error {
            print("[DECODE_SQLITE_RECORD_ERROR]: %@", error)
            return nil
        }
    }
    
    init(resultSet: FMResultSet) {
        self.resultSet = resultSet
    }
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key: CodingKey {
        return KeyedDecodingContainer(CICOSQLiteRecordKeyedDecodingContainer<Key>(with: self))
    }

    var codingPath: [CodingKey] {
        fatalError("[ERROR]: NOT IMPLEMENTED")
    }
    
    var userInfo: [CodingUserInfoKey: Any] {
        fatalError("[ERROR]: NOT IMPLEMENTED")
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        fatalError("[ERROR]: NOT IMPLEMENTED")
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        fatalError("[ERROR]: NOT IMPLEMENTED")
    }
    
    private class CICOSQLiteRecordKeyedDecodingContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
        private let decoder: CICOSQLiteRecordDecoder

        init(with decoder: CICOSQLiteRecordDecoder) {
            self.decoder = decoder
        }

        deinit {
        }

        var codingPath: [CodingKey] {
            fatalError("[ERROR]: NOT IMPLEMENTED")
        }
        
        var allKeys: [Key] {
            fatalError("[ERROR]: NOT IMPLEMENTED")
        }
        
        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type,
                                        forKey key: Key)
            throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
                fatalError("[ERROR]: NOT IMPLEMENTED")
        }
        
        func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
            fatalError("[ERROR]: NOT IMPLEMENTED")
        }
        
        func superDecoder() throws -> Decoder {
            fatalError("[ERROR]: NOT IMPLEMENTED")
        }
        
        func superDecoder(forKey key: Key) throws -> Decoder {
            fatalError("[ERROR]: NOT IMPLEMENTED")
        }
        
        func contains(_ key: Key) -> Bool {
            return true
        }

        func decodeNil(forKey key: Key) throws -> Bool {
            if decoder.resultSet.columnIsNull(key.stringValue) {
                print("(\(key.stringValue), true)")
                return true
            } else {
                print("(\(key.stringValue), false)")
                return false
            }
        }

        func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T: Decodable {
            let s = key.stringValue
            print("decode<T>: \(s)")
            
            if type == Date.self || type == NSDate.self {
                let value = decoder.resultSet.double(forColumn: key.stringValue)
                return Date.init(timeIntervalSinceReferenceDate: value) as! T
            }
            
            let data = decoder.resultSet.data(forColumn: key.stringValue)!
            return T.init(jsonData: data)!
        }
        
        func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
            let s = key.stringValue
            print("decode<Bool>: \(s)")
            
            return decoder.resultSet.bool(forColumn: key.stringValue)
        }
        
        func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
            let s = key.stringValue
            print("decode<Int>: \(s), \(Int(decoder.resultSet.longLongInt(forColumn: key.stringValue)))")
            return Int(decoder.resultSet.longLongInt(forColumn: key.stringValue))
        }
        
        func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
            return Int8(decoder.resultSet.longLongInt(forColumn: key.stringValue))
        }
        
        func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
            return Int16(decoder.resultSet.longLongInt(forColumn: key.stringValue))
        }
        
        func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
            return Int32(decoder.resultSet.longLongInt(forColumn: key.stringValue))
        }
        
        func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
            return decoder.resultSet.longLongInt(forColumn: key.stringValue)
        }
        
        func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
            return UInt(decoder.resultSet.longLongInt(forColumn: key.stringValue))
        }
        
        func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
            return UInt8(decoder.resultSet.longLongInt(forColumn: key.stringValue))
        }
        
        func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
            return UInt16(decoder.resultSet.longLongInt(forColumn: key.stringValue))
        }
        
        func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
            return UInt32(decoder.resultSet.longLongInt(forColumn: key.stringValue))
        }
        
        func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
            return UInt64(decoder.resultSet.longLongInt(forColumn: key.stringValue))
        }
        
        func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
            return Float(decoder.resultSet.double(forColumn: key.stringValue))
        }
        
        func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
            return decoder.resultSet.double(forColumn: key.stringValue)
        }
        
        func decode(_ type: String.Type, forKey key: Key) throws -> String {
            return decoder.resultSet.string(forColumn: key.stringValue)!
        }
    }
}
