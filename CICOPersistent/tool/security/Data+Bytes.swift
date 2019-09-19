//
//  Data+Bytes.swift
//  CICOPersistent
//
//  Created by lucky.li on 2019/9/7.
//  Copyright © 2019 cico. All rights reserved.
//

import Foundation

public enum BaseAddressError: Int, Error {
    case empty = -999
}

extension Data {
    @inlinable public func withUnsafeBytesBaseAddress(_ body: (UnsafeRawPointer, Int) throws -> Void) throws {
        _ = try self.withUnsafeBytes { (ptr) -> Int in
            guard let basePtr = ptr.baseAddress else {
                throw BaseAddressError.empty
            }
            try body(basePtr, ptr.count)
            return 0
        }
    }

    @inlinable public mutating func withUnsafeMutableBytesBaseAddress
        (_ body: (UnsafeMutableRawPointer, Int) throws -> Void) throws {
        _ = try self.withUnsafeMutableBytes { (ptr) -> Int in
            guard let basePtr = ptr.baseAddress else {
                throw BaseAddressError.empty
            }
            try body(basePtr, ptr.count)
            return 0
        }
    }

    @inlinable public func withUnsafePointerBaseAddress<T>
        (type: T.Type,
         _ body: (UnsafePointer<T>, Int) throws -> Void) throws {
        _ = try self.withUnsafeBytes { (ptr) -> Int in
            guard let basePtr = ptr.bindMemory(to: T.self).baseAddress else {
                throw BaseAddressError.empty
            }
            try body(basePtr, ptr.count)
            return 0
        }
    }

    @inlinable public mutating func withUnsafeMutablePointerBaseAddress<T>
        (type: T.Type,
         _ body: (UnsafeMutablePointer<T>, Int) throws -> Void) throws {
        _ = try self.withUnsafeMutableBytes { (ptr) -> Int in
            guard let basePtr = ptr.bindMemory(to: T.self).baseAddress else {
                throw BaseAddressError.empty
            }
            try body(basePtr, ptr.count)
            return 0
        }
    }

    @inlinable public func withUnsafeUInt8PointerBaseAddress
        (_ body: (UnsafePointer<UInt8>, Int) throws -> Void) throws {
        try self.withUnsafePointerBaseAddress(type: UInt8.self, body)
    }

    @inlinable public mutating func withUnsafeUInt8MutablePointerBaseAddress
        (_ body: (UnsafeMutablePointer<UInt8>, Int) throws -> Void) throws {
        try self.withUnsafeMutablePointerBaseAddress(type: UInt8.self, body)
    }
}

@inlinable public func withUnsafeBytesBaseAddress<T>
    (of value: inout T, _ body: (UnsafeRawPointer, Int) throws -> Void) throws {
    try withUnsafeBytes(of: &value) { (ptr) -> Void in
        guard let basePtr = ptr.baseAddress else {
            throw BaseAddressError.empty
        }
        try body(basePtr, ptr.count)
    }
}

@inlinable public func withUnsafeMutableBytesBaseAddress<T>
    (of value: inout T, _ body: (UnsafeMutableRawPointer, Int) throws -> Void) throws {
    try withUnsafeMutableBytes(of: &value) { (ptr) -> Void in
        guard let basePtr = ptr.baseAddress else {
            throw BaseAddressError.empty
        }
        try body(basePtr, ptr.count)
    }
}
