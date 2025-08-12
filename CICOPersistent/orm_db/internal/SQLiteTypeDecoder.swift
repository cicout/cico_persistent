//
//  SQLiteTypeDecoder.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/7/19.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

private class Factory<T> {
    private let pointer: UnsafeMutableRawPointer

    init() {
        let size = MemoryLayout<T>.size
        self.pointer = UnsafeMutableRawPointer.allocate(byteCount: size, alignment: 1)
        memset(pointer, 0, size)
    }

    deinit {
//        print("\(self) deinit")
        self.pointer.deallocate()
    }

    func instance() -> T {
        return self.pointer.assumingMemoryBound(to: T.self).pointee
    }
}

enum SQLiteTypeDecoderError: Error {
    case invalidData
}

class SQLiteTypeDecoder: Decoder {
    private var typeDic: [String: TypeProperty] = [:]

    static func allTypeProperties(of type: Decodable.Type) -> [String: TypeProperty] {
        let decoder = SQLiteTypeDecoder()
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
        private let decoder: SQLiteTypeDecoder

        private var factorys: [Any] = [Any].init()

        init(with decoder: SQLiteTypeDecoder) {
            self.decoder = decoder
        }

        deinit {}

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
                guard let value = try self.decode(Date.self, forKey: key) as? T else {
                    throw SQLiteTypeDecoderError.invalidData
                }
                return value
            } else if type == URL.self || type == NSURL.self {
                guard let value = try self.decode(URL.self, forKey: key) as? T else {
                    throw SQLiteTypeDecoderError.invalidData
                }
                return value
            }

            decoder.typeDic[key.stringValue] =
                TypeProperty.init(name: key.stringValue, swiftType: T.self, sqliteType: .BLOB, value: 0)

            let factory = Factory<T>.init()
            self.factorys.append(factory)
            return factory.instance()
        }

        func decode(_ type: Bool.Type, forKey key: KEY) throws -> Bool {
            decoder.typeDic[key.stringValue] =
                TypeProperty.init(name: key.stringValue, swiftType: Bool.self, sqliteType: Bool.sqliteType, value: 0)
            return false
        }

        func decode(_ type: Int.Type, forKey key: KEY) throws -> Int {
            decoder.typeDic[key.stringValue] =
                TypeProperty.init(name: key.stringValue, swiftType: Int.self, sqliteType: Int.sqliteType, value: 0)
            return 0
        }

        func decode(_ type: Int8.Type, forKey key: KEY) throws -> Int8 {
            decoder.typeDic[key.stringValue] =
                TypeProperty.init(name: key.stringValue, swiftType: Int8.self, sqliteType: Int8.sqliteType, value: 0)
            return 0
        }

        func decode(_ type: Int16.Type, forKey key: KEY) throws -> Int16 {
            decoder.typeDic[key.stringValue] =
                TypeProperty.init(name: key.stringValue, swiftType: Int16.self, sqliteType: Int16.sqliteType, value: 0)
            return 0
        }

        func decode(_ type: Int32.Type, forKey key: KEY) throws -> Int32 {
            decoder.typeDic[key.stringValue] =
                TypeProperty.init(name: key.stringValue, swiftType: Int32.self, sqliteType: Int32.sqliteType, value: 0)
            return 0
        }

        func decode(_ type: Int64.Type, forKey key: KEY) throws -> Int64 {
            decoder.typeDic[key.stringValue] =
                TypeProperty.init(name: key.stringValue, swiftType: Int64.self, sqliteType: Int64.sqliteType, value: 0)
            return 0
        }

        func decode(_ type: UInt.Type, forKey key: KEY) throws -> UInt {
            decoder.typeDic[key.stringValue] =
                TypeProperty.init(name: key.stringValue, swiftType: UInt.self, sqliteType: UInt.sqliteType, value: 0)
            return 0
        }

        func decode(_ type: UInt8.Type, forKey key: KEY) throws -> UInt8 {
            decoder.typeDic[key.stringValue] =
                TypeProperty.init(name: key.stringValue, swiftType: UInt8.self, sqliteType: UInt8.sqliteType, value: 0)
            return 0
        }

        func decode(_ type: UInt16.Type, forKey key: KEY) throws -> UInt16 {
            decoder.typeDic[key.stringValue] =
                TypeProperty
                    .init(name: key.stringValue,
                          swiftType: UInt16.self,
                          sqliteType: UInt16.sqliteType,
                          value: 0)
            return 0
        }

        func decode(_ type: UInt32.Type, forKey key: KEY) throws -> UInt32 {
            decoder.typeDic[key.stringValue] =
                TypeProperty
                    .init(name: key.stringValue,
                          swiftType: UInt32.self,
                          sqliteType: UInt32.sqliteType,
                          value: 0)
            return 0
        }

        func decode(_ type: UInt64.Type, forKey key: KEY) throws -> UInt64 {
            decoder.typeDic[key.stringValue] =
                TypeProperty
                    .init(name: key.stringValue,
                          swiftType: UInt64.self,
                          sqliteType: UInt64.sqliteType,
                          value: 0)
            return 0
        }

        func decode(_ type: Float.Type, forKey key: KEY) throws -> Float {
            decoder.typeDic[key.stringValue] =
                TypeProperty
                    .init(name: key.stringValue,
                          swiftType: Float.self,
                          sqliteType: Float.sqliteType,
                          value: 0)
            return 0
        }

        func decode(_ type: Double.Type, forKey key: KEY) throws -> Double {
            decoder.typeDic[key.stringValue] =
                TypeProperty
                    .init(name: key.stringValue,
                          swiftType: Double.self,
                          sqliteType: Double.sqliteType,
                          value: 0)
            return 0
        }

        func decode(_ type: String.Type, forKey key: KEY) throws -> String {
            decoder.typeDic[key.stringValue] =
                TypeProperty
                    .init(name: key.stringValue,
                          swiftType: String.self,
                          sqliteType: String.sqliteType,
                          value: 0)
            return ""
        }

        func decode(_ type: Date.Type, forKey key: KEY) throws -> Date {
            decoder.typeDic[key.stringValue] =
                TypeProperty
                    .init(name: key.stringValue,
                          swiftType: Date.self,
                          sqliteType: Date.sqliteType,
                          value: 0)
            return Date.init()
        }

        func decode(_ type: URL.Type, forKey key: KEY) throws -> URL {
            decoder.typeDic[key.stringValue] =
                TypeProperty
                    .init(name: key.stringValue,
                          swiftType: URL.self,
                          sqliteType: URL.sqliteType,
                          value: 0)
            return URL.init(fileURLWithPath: "/")
        }
    }
}
