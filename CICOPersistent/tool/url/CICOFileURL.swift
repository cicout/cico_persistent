//
//  CICOURL.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/8/29.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

public enum CICOFileURLType: String, Codable {
    case unknown
    case documents
    case library
    case tmp
}

public struct CICOFileURL: Codable {
    public var fileURL: URL?

    public static func transferPropertyToFileURL(type: CICOFileURLType, relativePath: String) -> URL? {
        switch type {
        case .unknown:
            return nil
        case .documents:
            return CICOPathAide.docFileURL(withSubPath: relativePath)
        case .library:
            return CICOPathAide.libFileURL(withSubPath: relativePath)
        case .tmp:
            return CICOPathAide.tempFileURL(withSubPath: relativePath)
        }
    }

    public static func transferURLToProperty(fileURL: URL?) -> (CICOFileURLType, String) {
        var type = CICOFileURLType.unknown
        var relativePath = ""

        guard let url = fileURL, url.isFileURL else {
            return (type, relativePath)
        }

        let path = url.path
        let docPath = CICOPathAide.docPath(withSubPath: nil)
        let libPath = CICOPathAide.libPath(withSubPath: nil)
        let tmpPath = CICOPathAide.tempPath(withSubPath: nil)

        if path.hasPrefix(docPath) {
            type = .documents
            relativePath = String(path.dropFirst(docPath.count))
        } else if path.hasPrefix(libPath) {
            type = .library
            relativePath = String(path.dropFirst(libPath.count))
        } else if path.hasPrefix(tmpPath) {
            type = .tmp
            relativePath = String(path.dropFirst(tmpPath.count))
        }

        return (type, relativePath)
    }

    public init(type: CICOFileURLType, relativePath: String) {
        self.fileURL = CICOFileURL.transferPropertyToFileURL(type: type, relativePath: relativePath)
    }

    public init(fileURL: URL?) {
        self.fileURL = fileURL
    }
}

extension CICOFileURL {
    enum CodingKeys: String, CodingKey {
        case type
        case relativePath
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(CICOFileURLType.self, forKey: .type)
        let relativePath = try container.decode(String.self, forKey: .relativePath)

        self.fileURL = CICOFileURL.transferPropertyToFileURL(type: type, relativePath: relativePath)
    }

    public func encode(to encoder: Encoder) throws {
        let (type, relativePath) = CICOFileURL.transferURLToProperty(fileURL: self.fileURL)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(relativePath, forKey: .relativePath)
    }
}
