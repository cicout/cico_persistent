//
//  CICOSQLiteRecordEncoder.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/7/19.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

class SQLiteRecordEncoder: Encoder {
    private var typePropertyArray = [TypeProperty]()
    
    static func encodeObjectToSQL<T: Encodable>(object: T, tableName: String) -> (String?, [Any]?) {
        var replaceSQL = "REPLACE INTO \(tableName) ("
        var argumentArray = [Any]()
        
        let typePropertyArray: [TypeProperty]
        let encoder = SQLiteRecordEncoder.init()
        do {
            try object.encode(to: encoder)
            typePropertyArray = encoder.typePropertyArray
        } catch let error {
            assert(false, "error = \(error)")
            return (nil, nil)
        }
        
        var isFirst = true
        typePropertyArray.forEach({ (property) in
            if isFirst {
                isFirst = false
                replaceSQL.append("\(property.name)")
            } else {
                replaceSQL.append(", \(property.name)")
            }
            
            argumentArray.append(property.value)
        })
        replaceSQL.append(") VALUES (")
        for i in 0..<typePropertyArray.count {
            if 0 == i {
                replaceSQL.append("?")
            } else {
                replaceSQL.append(", ?")
            }
        }
        replaceSQL.append(");")
        
        return (replaceSQL, argumentArray)
    }
    
    init() {
    }
    
    func container<KEY>(keyedBy type: KEY.Type) -> KeyedEncodingContainer<KEY> where KEY: CodingKey {
        return KeyedEncodingContainer(CICOSQLiteRecordKeyedEncodingContainer<KEY>.init(encoder: self))
    }

    var codingPath: [CodingKey] {
        fatalError("[ERROR]: NOT IMPLEMENTED")
    }
    
    var userInfo: [CodingUserInfoKey: Any] {
        fatalError("[ERROR]: NOT IMPLEMENTED")
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        fatalError("[ERROR]: NOT IMPLEMENTED")
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        fatalError("[ERROR]: NOT IMPLEMENTED")
    }
    
    private class CICOSQLiteRecordKeyedEncodingContainer<KEY: CodingKey>: KeyedEncodingContainerProtocol {
        private let encoder: SQLiteRecordEncoder
        
        init(encoder: SQLiteRecordEncoder) {
            self.encoder = encoder
        }
        
        var codingPath: [CodingKey] {
            fatalError("[ERROR]: NOT IMPLEMENTED")
        }
        
        func superEncoder() -> Swift.Encoder {
            fatalError("[ERROR]: NOT IMPLEMENTED")
        }
        
        func superEncoder(forKey key: KEY) -> Swift.Encoder {
            fatalError("[ERROR]: NOT IMPLEMENTED")
        }
        
        func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type,
                                        forKey key: KEY) -> KeyedEncodingContainer<NestedKey>
            where NestedKey: CodingKey {
                fatalError("[ERROR]: NOT IMPLEMENTED")
        }
        
        func nestedUnkeyedContainer(forKey key: KEY) -> UnkeyedEncodingContainer {
            fatalError("[ERROR]: NOT IMPLEMENTED")
        }
        
        func encodeNil(forKey key: KEY) throws {
            // do nothing
        }
        
        func encode<T>(_ value: T, forKey key: KEY) throws where T: Encodable {
            if let date = value as? Date {
                try self.encode(date, forKey: key)
                return
            }
            
            if let data = value.toJSONData() {
                let property =
                    TypeProperty.init(name: key.stringValue, swiftType: T.self, sqliteType: T.sqliteType, value: data)
                self.encoder.typePropertyArray.append(property)
            } else {
                assert(false, "encode key = \(key.stringValue), value = \(value)")
            }
        }
        
        func encode(_ value: Bool, forKey key: KEY) throws {
            let property =
                TypeProperty.init(name: key.stringValue, swiftType: Bool.self, sqliteType: Bool.sqliteType, value: value)
            self.encoder.typePropertyArray.append(property)
        }
        
        func encode(_ value: Int, forKey key: KEY) throws {
            let property =
                TypeProperty.init(name: key.stringValue, swiftType: Int.self, sqliteType: Int.sqliteType, value: value)
            self.encoder.typePropertyArray.append(property)
        }

        func encode(_ value: Int8, forKey key: KEY) throws {
            let property =
                TypeProperty.init(name: key.stringValue, swiftType: Int8.self, sqliteType: Int8.sqliteType, value: value)
            self.encoder.typePropertyArray.append(property)
        }
        
        func encode(_ value: Int16, forKey key: KEY) throws {
            let property =
                TypeProperty.init(name: key.stringValue, swiftType: Int16.self, sqliteType: Int16.sqliteType, value: value)
            self.encoder.typePropertyArray.append(property)
        }
        
        func encode(_ value: Int32, forKey key: KEY) throws {
            let property =
                TypeProperty.init(name: key.stringValue, swiftType: Int32.self, sqliteType: Int32.sqliteType, value: value)
            self.encoder.typePropertyArray.append(property)
        }
        
        func encode(_ value: Int64, forKey key: KEY) throws {
            let property =
                TypeProperty.init(name: key.stringValue, swiftType: Int64.self, sqliteType: Int64.sqliteType, value: value)
            self.encoder.typePropertyArray.append(property)
        }
        
        func encode(_ value: UInt, forKey key: KEY) throws {
            let property =
                TypeProperty.init(name: key.stringValue, swiftType: UInt.self, sqliteType: UInt.sqliteType, value: value)
            self.encoder.typePropertyArray.append(property)
        }
        
        func encode(_ value: UInt8, forKey key: KEY) throws {
            let property =
                TypeProperty.init(name: key.stringValue, swiftType: UInt8.self, sqliteType: UInt8.sqliteType, value: value)
            self.encoder.typePropertyArray.append(property)
        }
        
        func encode(_ value: UInt16, forKey key: KEY) throws {
            let property =
                TypeProperty.init(name: key.stringValue, swiftType: UInt16.self, sqliteType: UInt16.sqliteType, value: value)
            self.encoder.typePropertyArray.append(property)
        }
        
        func encode(_ value: UInt32, forKey key: KEY) throws {
            let property =
                TypeProperty.init(name: key.stringValue, swiftType: UInt32.self, sqliteType: UInt32.sqliteType, value: value)
            self.encoder.typePropertyArray.append(property)
        }
        
        func encode(_ value: UInt64, forKey key: KEY) throws {
            let property =
                TypeProperty.init(name: key.stringValue, swiftType: UInt64.self, sqliteType: UInt64.sqliteType, value: value)
            self.encoder.typePropertyArray.append(property)
        }
        
        func encode(_ value: Float, forKey key: KEY) throws {
            let property =
                TypeProperty.init(name: key.stringValue, swiftType: Float.self, sqliteType: Float.sqliteType, value: value)
            self.encoder.typePropertyArray.append(property)
        }
        
        func encode(_ value: Double, forKey key: KEY) throws {
            let property =
                TypeProperty.init(name: key.stringValue, swiftType: Double.self, sqliteType: Double.sqliteType, value: value)
            self.encoder.typePropertyArray.append(property)
        }
        
        func encode(_ value: String, forKey key: KEY) throws {
            let property =
                TypeProperty.init(name: key.stringValue, swiftType: String.self, sqliteType: String.sqliteType, value: value)
            self.encoder.typePropertyArray.append(property)
        }
        
        func encode(_ value: Date, forKey key: KEY) throws {
            let time = value.timeIntervalSinceReferenceDate
            let property =
                TypeProperty.init(name: key.stringValue, swiftType: Date.self, sqliteType: Date.sqliteType, value: time)
            self.encoder.typePropertyArray.append(property)
        }
    }
}
