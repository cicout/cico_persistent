//
//  SQLiteRecordDecoder.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/7/24.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation
import FMDB
import CICOAutoCodable

enum SQLiteRecordDecoderError: Error {
    case invalidData
}

class SQLiteRecordDecoder: Decoder {
    private let resultSet: FMResultSet

    static func decodeSQLiteRecord<T: Decodable>(resultSet: FMResultSet, objectType: T.Type) -> T? {
        let decoder = SQLiteRecordDecoder.init(resultSet: resultSet)
        do {
            let obj = try objectType.init(from: decoder)
            return obj
        } catch let error {
            print("[DECODE_SQLITE_RECORD_ERROR]: %@", error)
            return nil
        }
    }

    init(resultSet: FMResultSet) {
        self.resultSet = resultSet
    }

    func container<KEY>(keyedBy type: KEY.Type) throws -> KeyedDecodingContainer<KEY> where KEY: CodingKey {
        return KeyedDecodingContainer(CICOSQLiteRecordKeyedDecodingContainer<KEY>(with: self))
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

    private class CICOSQLiteRecordKeyedDecodingContainer<KEY: CodingKey>: KeyedDecodingContainerProtocol {
        private let decoder: SQLiteRecordDecoder

        init(with decoder: SQLiteRecordDecoder) {
            self.decoder = decoder
        }

        deinit {
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
            if decoder.resultSet.columnIsNull(key.stringValue) {
                return true
            } else {
                return false
            }
        }

        func decode<T>(_ objectType: T.Type, forKey key: KEY) throws -> T where T: Decodable {
            if objectType == Date.self || objectType == NSDate.self {
                guard let value = try self.decode(Date.self, forKey: key) as? T else {
                    throw SQLiteRecordDecoderError.invalidData
                }
                return value
            } else if objectType == URL.self || objectType == NSURL.self {
                guard let value = try self.decode(URL.self, forKey: key) as? T else {
                    throw SQLiteRecordDecoderError.invalidData
                }
                return value
            }

            guard let data = decoder.resultSet.data(forColumn: key.stringValue) else {
                throw SQLiteRecordDecoderError.invalidData
            }

            guard let value = KVJSONAide.transferJSONDataToObject(data, objectType: objectType) else {
                throw SQLiteRecordDecoderError.invalidData
            }

            return value
        }

        func decode(_ type: Bool.Type, forKey key: KEY) throws -> Bool {
            return decoder.resultSet.bool(forColumn: key.stringValue)
        }

        func decode(_ type: Int.Type, forKey key: KEY) throws -> Int {
            return Int(decoder.resultSet.longLongInt(forColumn: key.stringValue))
        }

        func decode(_ type: Int8.Type, forKey key: KEY) throws -> Int8 {
            return Int8(decoder.resultSet.longLongInt(forColumn: key.stringValue))
        }

        func decode(_ type: Int16.Type, forKey key: KEY) throws -> Int16 {
            return Int16(decoder.resultSet.longLongInt(forColumn: key.stringValue))
        }

        func decode(_ type: Int32.Type, forKey key: KEY) throws -> Int32 {
            return Int32(decoder.resultSet.longLongInt(forColumn: key.stringValue))
        }

        func decode(_ type: Int64.Type, forKey key: KEY) throws -> Int64 {
            return decoder.resultSet.longLongInt(forColumn: key.stringValue)
        }

        func decode(_ type: UInt.Type, forKey key: KEY) throws -> UInt {
            return UInt(decoder.resultSet.longLongInt(forColumn: key.stringValue))
        }

        func decode(_ type: UInt8.Type, forKey key: KEY) throws -> UInt8 {
            return UInt8(decoder.resultSet.longLongInt(forColumn: key.stringValue))
        }

        func decode(_ type: UInt16.Type, forKey key: KEY) throws -> UInt16 {
            return UInt16(decoder.resultSet.longLongInt(forColumn: key.stringValue))
        }

        func decode(_ type: UInt32.Type, forKey key: KEY) throws -> UInt32 {
            return UInt32(decoder.resultSet.longLongInt(forColumn: key.stringValue))
        }

        func decode(_ type: UInt64.Type, forKey key: KEY) throws -> UInt64 {
            return UInt64(decoder.resultSet.longLongInt(forColumn: key.stringValue))
        }

        func decode(_ type: Float.Type, forKey key: KEY) throws -> Float {
            return Float(decoder.resultSet.double(forColumn: key.stringValue))
        }

        func decode(_ type: Double.Type, forKey key: KEY) throws -> Double {
            return decoder.resultSet.double(forColumn: key.stringValue)
        }

        func decode(_ type: String.Type, forKey key: KEY) throws -> String {
            guard let text = decoder.resultSet.string(forColumn: key.stringValue) else {
                throw SQLiteRecordDecoderError.invalidData
            }

            return text
        }

        func decode(_ type: Date.Type, forKey key: KEY) throws -> Date {
            let value = decoder.resultSet.double(forColumn: key.stringValue)
            return Date.init(timeIntervalSinceReferenceDate: value)
        }

        func decode(_ type: URL.Type, forKey key: KEY) throws -> URL {
            guard let urlString = decoder.resultSet.string(forColumn: key.stringValue) else {
                throw SQLiteRecordDecoderError.invalidData
            }

            guard let url = URL.init(string: urlString) else {
                throw SQLiteRecordDecoderError.invalidData
            }

            return url
        }
    }
}
