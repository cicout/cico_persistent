//
//  PathAide.swift
//  CICOPersistent
//
//  Created by lucky.li on 2019/8/30.
//  Copyright © 2019 cico. All rights reserved.
//

import Foundation

private let kDefaultPublicDirName = "public"
private let kDefaultPrivateDirName = "private"
private let kDefaultCacheDirName = "cache"
private let kDefaultTempDirName = "temp"

public class PathAide {
    /// Document file path in sand box;
    ///
    /// It will locate in file path "{SandBox}/Document/{subPath}";
    ///
    /// The contents of this directory can be made available to the user through file sharing;
    /// The files may be read/wrote/deleted by user;
    ///
    /// It should only contain imported/exported files here, or debugging use only;
    ///
    /// - parameter subPath: Path relative to the root directory;
    ///                It will return the root directory path when nil;
    ///
    /// - returns: Full file path;
    public static func docPath(withSubPath subPath: String? = nil) -> String {
        return self.docFileURL(withSubPath: subPath).path
    }

    /// Document file URL in sand box;
    ///
    /// It will locate in file path "{SandBox}/Document/{subPath}";
    ///
    /// The contents of this directory can be made available to the user through file sharing;
    /// The files may be read/wrote/deleted by user;
    ///
    /// It should only contain imported/exported files here, or debugging use only;
    ///
    /// - parameter subPath: Path relative to the root directory;
    ///                It will return the root directory URL when nil;
    ///
    /// - returns: Full file URL;
    public static func docFileURL(withSubPath subPath: String? = nil) -> URL {
        let docPath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
        var url = URL(fileURLWithPath: docPath)
        if let subPath = subPath, subPath.count > 0 {
            url = url.appendingPathComponent(subPath)
        }
        return url
    }

    /// Library file path in sand box;
    ///
    /// It will locate in file path "{SandBox}/Library/{subPath}";
    ///
    /// Any file you don’t want exposed to the user can be saved here;
    ///
    /// It is recommended as default file path;
    ///
    /// - parameter subPath: Path relative to the root directory;
    ///                It will return the root directory path when nil;
    ///
    /// - returns: Full file path;
    public static func libPath(withSubPath subPath: String? = nil) -> String {
        return self.libFileURL(withSubPath: subPath).path
    }

    /// Library file URL in sand box;
    ///
    /// It will locate in file path "{SandBox}/Library/{subPath}";
    ///
    /// Any file you don’t want exposed to the user can be saved here;
    ///
    /// It is recommended as default file URL;
    ///
    /// - parameter subPath: Path relative to the root directory;
    ///                It will return the root directory URL when nil;
    ///
    /// - returns: Full file URL;
    public static func libFileURL(withSubPath subPath: String? = nil) -> URL {
        let libPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first ?? ""
        var url = URL(fileURLWithPath: libPath)
        if let subPath = subPath, subPath.count > 0 {
            url = url.appendingPathComponent(subPath)
        }
        return url
    }

    /// Cache file path in sand box;
    ///
    /// It will locate in file path "{SandBox}/Library/Caches/{subPath}";
    ///
    /// All cache files should be placed here;
    ///
    /// It is recommended for caching;
    ///
    /// - parameter subPath: Path relative to the root directory;
    ///                It will return the root directory path when nil;
    ///
    /// - returns: Full file path;
    public static func cachePath(withSubPath subPath: String? = nil) -> String {
        return self.cacheFileURL(withSubPath: subPath).path
    }

    /// Cache file URL in sand box;
    ///
    /// It will locate in file path "{SandBox}/Library/Caches/{subPath}";
    ///
    /// All cache files should be placed here;
    ///
    /// It is recommended for caching;
    ///
    /// - parameter subPath: Path relative to the root directory;
    ///                It will return the root directory URL when nil;
    ///
    /// - returns: Full file URL;
    public static func cacheFileURL(withSubPath subPath: String? = nil) -> URL {
        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first ?? ""
        var url = URL(fileURLWithPath: cachePath)
        if let subPath = subPath, subPath.count > 0 {
            url = url.appendingPathComponent(subPath)
        }
        return url
    }

    /// Temp file path in sand box;
    ///
    /// It will locate in file path "{SandBox}/tmp/{subPath}";
    ///
    /// Use this directory to write temporary files that do not need to persist between launches of your app;
    /// Your app should remove files from this directory when they are no longer needed;
    ///
    /// It is recommended for temporary files;
    ///
    /// - parameter subPath: Path relative to the root directory;
    ///                It will return the root directory path when nil;
    ///
    /// - returns: Full file path;
    public static func tempPath(withSubPath subPath: String? = nil) -> String {
        return self.tempFileURL(withSubPath: subPath).path
    }

    /// Temp file URL in sand box;
    ///
    /// It will locate in file path "{SandBox}/tmp/{subPath}";
    ///
    /// Use this directory to write temporary files that do not need to persist between launches of your app;
    /// Your app should remove files from this directory when they are no longer needed;
    ///
    /// It is recommended for temporary files;
    ///
    /// - parameter subPath: Path relative to the root directory;
    ///                It will return the root directory URL when nil;
    ///
    /// - returns: Full file URL;
    public static func tempFileURL(withSubPath subPath: String? = nil) -> URL {
        let tmpPath = NSTemporaryDirectory()
        var url = URL(fileURLWithPath: tmpPath)
        if let subPath = subPath, subPath.count > 0 {
            url = url.appendingPathComponent(subPath)
        }
        return url
    }

    /// Default public file path in sand box;
    ///
    /// It will locate in file path "{SandBox}/Document/public/{subPath}";
    ///
    /// The contents of this directory can be made available to the user through file sharing;
    /// The files may be read/wrote/deleted by user;
    ///
    /// It should only contain imported/exported files here, or debugging use only;
    ///
    /// - parameter subPath: Path relative to the root directory;
    ///                It will return the root directory path when nil;
    ///
    /// - returns: Full file path;
    public static func defaultPublicPath(withSubPath subPath: String? = nil) -> String {
        return self.defaultPublicFileURL(withSubPath: subPath).path
    }

    /// Default public file URL in sand box;
    ///
    /// It will locate in file path "{SandBox}/Document/public/{subPath}";
    ///
    /// The contents of this directory can be made available to the user through file sharing;
    /// The files may be read/wrote/deleted by user;
    ///
    /// It should only contain imported/exported files here, or debugging use only;
    ///
    /// - parameter subPath: Path relative to the root directory;
    ///                It will return the root directory URL when nil;
    ///
    /// - returns: Full file URL;
    public static func defaultPublicFileURL(withSubPath subPath: String? = nil) -> URL {
        var fileURL = self.docFileURL(withSubPath: kDefaultPublicDirName)
        if let subPath = subPath, subPath.count > 0 {
            fileURL = fileURL.appendingPathComponent(subPath)
        }
        return fileURL
    }

    /// Default private file path in sand box;
    ///
    /// It will locate in file path "{SandBox}/Library/private/{subPath}";
    ///
    /// Any file you don’t want exposed to the user can be saved here;
    ///
    /// It is recommended as default file path;
    ///
    /// - parameter subPath: Path relative to the root directory;
    ///                It will return the root directory URL when nil;
    ///
    /// - returns: Full file path;
    public static func defaultPrivatePath(withSubPath subPath: String?) -> String {
        return self.defaultPrivateFileURL(withSubPath: subPath).path
    }

    /// Default private file URL in sand box;
    ///
    /// It will locate in file path "{SandBox}/Library/private/{subPath}";
    ///
    /// Any file you don’t want exposed to the user can be saved here;
    ///
    /// It is recommended as default file URL;
    ///
    /// - parameter subPath: Path relative to the root directory;
    ///                It will return the root directory URL when nil;
    ///
    /// - returns: Full file URL;
    public static func defaultPrivateFileURL(withSubPath subPath: String?) -> URL {
        var fileURL = self.libFileURL(withSubPath: kDefaultPrivateDirName)
        if let subPath = subPath, subPath.count > 0 {
            fileURL = fileURL.appendingPathComponent(subPath)
        }
        return fileURL
    }

    /// Default cache file path in sand box;
    ///
    /// It will locate in file path "{SandBox}/Library/Caches/cache/{subPath}";
    ///
    /// All cache files should be placed here;
    ///
    /// It is recommended for caching;
    ///
    /// - parameter subPath: Path relative to the root directory;
    ///                It will return the root directory path when nil;
    ///
    /// - returns: Full file path;
    public static func defaultCachePath(withSubPath subPath: String? = nil) -> String {
        return self.defaultCacheFileURL(withSubPath: subPath).path
    }

    /// Default cache file URL in sand box;
    ///
    /// It will locate in file path "{SandBox}/Library/Caches/cache/{subPath}";
    ///
    /// All cache files should be placed here;
    ///
    /// It is recommended for caching;
    ///
    /// - parameter subPath: Path relative to the root directory;
    ///                It will return the root directory URL when nil;
    ///
    /// - returns: Full file URL;
    public static func defaultCacheFileURL(withSubPath subPath: String? = nil) -> URL {
        var fileURL = self.cacheFileURL(withSubPath: kDefaultCacheDirName)
        if let subPath = subPath, subPath.count > 0 {
            fileURL = fileURL.appendingPathComponent(subPath)
        }
        return fileURL
    }

    /// Default temp file path in sand box;
    ///
    /// It will locate in file path "{SandBox}/tmp/temp/{subPath}";
    ///
    /// Use this directory to write temporary files that do not need to persist between launches of your app;
    /// Your app should remove files from this directory when they are no longer needed;
    ///
    /// It is recommended for temporary files;
    ///
    /// - parameter subPath: Path relative to the root directory;
    ///                It will return the root directory path when nil;
    ///
    /// - returns: Full file path;
    public static func defaultTempPath(withSubPath subPath: String? = nil) -> String {
        return self.defaultTempFileURL(withSubPath: subPath).path
    }

    /// Default temp file URL in sand box;
    ///
    /// It will locate in file path "{SandBox}/tmp/temp/{subPath}";
    ///
    /// Use this directory to write temporary files that do not need to persist between launches of your app;
    /// Your app should remove files from this directory when they are no longer needed;
    ///
    /// It is recommended for temporary files;
    ///
    /// - parameter subPath: Path relative to the root directory;
    ///                It will return the root directory URL when nil;
    ///
    /// - returns: Full file URL;
    public static func defaultTempFileURL(withSubPath subPath: String? = nil) -> URL {
        var fileURL = self.tempFileURL(withSubPath: kDefaultTempDirName)
        if let subPath = subPath, subPath.count > 0 {
            fileURL = fileURL.appendingPathComponent(subPath)
        }
        return fileURL
    }
}
