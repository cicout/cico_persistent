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

class CICOSQLiteTypeDecoder: Decoder {
    private var typeDic: [String: CICOTypeProperty] = [:]

    static func allTypeProperties(of type: Decodable.Type) -> [String: CICOTypeProperty] {
        let decoder = CICOSQLiteTypeDecoder()
        _ = try? type.init(from: decoder)
        return decoder.typeDic
    }

    func container<KEY>(keyedBy type: KEY.Type) throws -> KeyedDecodingContainer<KEY> where KEY: CodingKey {
        return KeyedDecodingContainer(CICOTypeKeyedDecodingContainer<KEY>(with: self))
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
    
    private class CICOTypeKeyedDecodingContainer<KEY: CodingKey>: KeyedDecodingContainerProtocol {
        private struct SizedPointer {
            private let pointer: UnsafeMutableRawPointer
            private let size: Int
            init<T>(of type: T.Type = T.self) {
                size = MemoryLayout<T>.size
                pointer = UnsafeMutableRawPointer.allocate(byteCount: size, alignment: 1)
                memset(pointer, 0, size)
            }
            func deallocate() {
                pointer.deallocate()
            }
            func getPointee<T>(of type: T.Type = T.self) -> T {
                return pointer.assumingMemoryBound(to: type).pointee
            }
        }

        private let decoder: CICOSQLiteTypeDecoder

        private var sizedPointers: ContiguousArray<SizedPointer>

        init(with decoder: CICOSQLiteTypeDecoder) {
            self.decoder = decoder
            self.sizedPointers = ContiguousArray<SizedPointer>()
        }

        deinit {
            for sizedPointer in sizedPointers {
                sizedPointer.deallocate()
            }
        }

        var codingPath: [CodingKey] {
            fatalError("[ERROR]: NOT IMPLEMENTED")
        }
        
        var allKeys: [KEY] {
            fatalError("[ERROR]: NOT IMPLEMENTED")
        }
        
        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type,
                                        forKey key: KEY)
            throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
                fatalError("[ERROR]: NOT IMPLEMENTED")
        }
        
        func nestedUnkeyedContainer(forKey key: KEY) throws -> UnkeyedDecodingContainer {
            fatalError("[ERROR]: NOT IMPLEMENTED")
        }
        
        func superDecoder() throws -> Decoder {
            fatalError("[ERROR]: NOT IMPLEMENTED")
        }
        
        func superDecoder(forKey key: KEY) throws -> Decoder {
            fatalError("[ERROR]: NOT IMPLEMENTED")
        }
        
        func contains(_ key: KEY) -> Bool {
            return true
        }

        func decodeNil(forKey key: KEY) throws -> Bool {
            return false
        }

        func decode<T>(_ type: T.Type, forKey key: KEY) throws -> T where T: Decodable {
            if type == Date.self || type == NSDate.self {
                return try self.decode(Date.self, forKey: key) as! T
            }
            
            decoder.typeDic[key.stringValue] =
                CICOTypeProperty.init(name: key.stringValue, swiftType: T.self, sqliteType: T.sqliteType, value: 0)
            let sizedPointer = SizedPointer(of: T.self)
            sizedPointers.append(sizedPointer)
            return sizedPointer.getPointee()
        }
        
        func decode(_ type: Bool.Type, forKey key: KEY) throws -> Bool {
            decoder.typeDic[key.stringValue] =
                CICOTypeProperty.init(name: key.stringValue, swiftType: Bool.self, sqliteType: Bool.sqliteType, value: 0)
            return false
        }
        
        func decode(_ type: Int.Type, forKey key: KEY) throws -> Int {
            decoder.typeDic[key.stringValue] =
                CICOTypeProperty.init(name: key.stringValue, swiftType: Int.self, sqliteType: Int.sqliteType, value: 0)
            return 0
        }
        
        func decode(_ type: Int8.Type, forKey key: KEY) throws -> Int8 {
            decoder.typeDic[key.stringValue] =
                CICOTypeProperty.init(name: key.stringValue, swiftType: Int8.self, sqliteType: Int8.sqliteType, value: 0)
            return 0
        }
        
        func decode(_ type: Int16.Type, forKey key: KEY) throws -> Int16 {
            decoder.typeDic[key.stringValue] =
                CICOTypeProperty.init(name: key.stringValue, swiftType: Int16.self, sqliteType: Int16.sqliteType, value: 0)
            return 0
        }
        
        func decode(_ type: Int32.Type, forKey key: KEY) throws -> Int32 {
            decoder.typeDic[key.stringValue] =
                CICOTypeProperty.init(name: key.stringValue, swiftType: Int32.self, sqliteType: Int32.sqliteType, value: 0)
            return 0
        }
        
        func decode(_ type: Int64.Type, forKey key: KEY) throws -> Int64 {
            decoder.typeDic[key.stringValue] =
                CICOTypeProperty.init(name: key.stringValue, swiftType: Int64.self, sqliteType: Int64.sqliteType, value: 0)
            return 0
        }
        
        func decode(_ type: UInt.Type, forKey key: KEY) throws -> UInt {
            decoder.typeDic[key.stringValue] =
                CICOTypeProperty.init(name: key.stringValue, swiftType: UInt.self, sqliteType: UInt.sqliteType, value: 0)
            return 0
        }
        
        func decode(_ type: UInt8.Type, forKey key: KEY) throws -> UInt8 {
            decoder.typeDic[key.stringValue] =
                CICOTypeProperty.init(name: key.stringValue, swiftType: UInt8.self, sqliteType: UInt8.sqliteType, value: 0)
            return 0
        }
        
        func decode(_ type: UInt16.Type, forKey key: KEY) throws -> UInt16 {
            decoder.typeDic[key.stringValue] =
                CICOTypeProperty.init(name: key.stringValue, swiftType: UInt16.self, sqliteType: UInt16.sqliteType, value: 0)
            return 0
        }
        
        func decode(_ type: UInt32.Type, forKey key: KEY) throws -> UInt32 {
            decoder.typeDic[key.stringValue] =
                CICOTypeProperty.init(name: key.stringValue, swiftType: UInt32.self, sqliteType: UInt32.sqliteType, value: 0)
            return 0
        }
        
        func decode(_ type: UInt64.Type, forKey key: KEY) throws -> UInt64 {
            decoder.typeDic[key.stringValue] =
                CICOTypeProperty.init(name: key.stringValue, swiftType: UInt64.self, sqliteType: UInt64.sqliteType, value: 0)
            return 0
        }
        
        func decode(_ type: Float.Type, forKey key: KEY) throws -> Float {
            decoder.typeDic[key.stringValue] =
                CICOTypeProperty.init(name: key.stringValue, swiftType: Float.self, sqliteType: Float.sqliteType, value: 0)
            return 0
        }
        
        func decode(_ type: Double.Type, forKey key: KEY) throws -> Double {
            decoder.typeDic[key.stringValue] =
                CICOTypeProperty.init(name: key.stringValue, swiftType: Double.self, sqliteType: Double.sqliteType, value: 0)
            return 0
        }
        
        func decode(_ type: String.Type, forKey key: KEY) throws -> String {
            decoder.typeDic[key.stringValue] =
                CICOTypeProperty.init(name: key.stringValue, swiftType: String.self, sqliteType: String.sqliteType, value: 0)
            return ""
        }
        
        func decode(_ type: Date.Type, forKey key: KEY) throws -> Date {
            decoder.typeDic[key.stringValue] =
                CICOTypeProperty.init(name: key.stringValue, swiftType: Date.self, sqliteType: Date.sqliteType, value: 0)
            return Date.init()
        }
    }
}
