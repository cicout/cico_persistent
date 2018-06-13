//
//  CICOPathAide.m
//  CICOFoundationKit
//
//  Created by lucky.li on 16/8/31.
//  Copyright © 2016年 cico. All rights reserved.
//

#import "CICOPathAide.h"

static NSString * const kDefaultPublicDirName = @"public";
static NSString * const kDefaultPrivateDirName = @"private";
static NSString * const kDefaultCacheDirName = @"cache";
static NSString * const kDefaultTempDirName = @"temp";

@implementation CICOPathAide

#pragma mark - PUBLIC

+ (NSString *)docPathWithSubPath:(NSString *)subPath {
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [docPath stringByAppendingPathComponent:subPath];
    return path;
}
    
+ (NSURL *)docFileURLWithSubPath:(NSString *)subPath {
    NSString *filePath = [self docPathWithSubPath:subPath];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    return fileURL;
}

+ (NSString *)libPathWithSubPath:(NSString *)subPath {
    NSString *libPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [libPath stringByAppendingPathComponent:subPath];
    return path;
}
    
+ (NSURL *)libFileURLWithSubPath:(NSString *)subPath {
    NSString *filePath = [self libPathWithSubPath:subPath];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    return fileURL;
}

+ (NSString *)cachePathWithSubPath:(NSString *)subPath {
    NSString *cachePath=[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path=[cachePath stringByAppendingPathComponent:subPath];
    return path;
}
    
+ (NSURL *)cacheFileURLWithSubPath:(NSString *)subPath {
    NSString *filePath = [self cachePathWithSubPath:subPath];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    return fileURL;
}

+ (NSString *)tempPathWithSubPath:(NSString *)subPath {
    NSString *tmpPath = NSTemporaryDirectory();
    NSString *path = [tmpPath stringByAppendingPathComponent:subPath];
    return path;
}
    
+ (NSURL *)tempFileURLWithSubPath:(NSString *)subPath {
    NSString *filePath = [self tempPathWithSubPath:subPath];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    return fileURL;
}

/// 根据subPath返回沙盒默认PUBLIC目录下该subPath的路径: ~/Document/public/subPath
+ (NSString *)defaultPublicPathWithSubPath:(NSString *)subPath {
    NSString *dir = [self docPathWithSubPath:kDefaultPublicDirName];
    NSString *path = [dir stringByAppendingPathComponent:subPath];
    return path;
}

/// 根据subPath返回沙盒默认PUBLIC目录下该subPath的URL: ~/Document/public/subPath
+ (NSURL *)defaultPublicFileURLWithSubPath:(NSString *)subPath {
    NSString *filePath = [self defaultPublicPathWithSubPath:subPath];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    return fileURL;
}

/// 根据subPath返回沙盒默认PRIVATE目录下该subPath的路径: ~/Library/private/subPath
+ (NSString *)defaultPrivatePathWithSubPath:(NSString *)subPath {
    NSString *dir = [self libPathWithSubPath:kDefaultPrivateDirName];
    NSString *path = [dir stringByAppendingPathComponent:subPath];
    return path;
}

/// 根据subPath返回沙盒默认PRIVATE目录下该subPath的URL: ~/Library]private/subPath
+ (NSURL *)defaultPrivateFileURLWithSubPath:(NSString *)subPath {
    NSString *filePath = [self defaultPrivatePathWithSubPath:subPath];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    return fileURL;
}

/// 根据subPath返回沙盒默认CACHE目录下该subPath的路径: ~/Library/Caches/cache/subPath
+ (NSString *)defaultCachePathWithSubPath:(NSString *)subPath {
    NSString *dir = [self cachePathWithSubPath:kDefaultCacheDirName];
    NSString *path = [dir stringByAppendingPathComponent:subPath];
    return path;
}

/// 根据subPath返回沙盒默认CACHE目录下该subPath的URL: ~/Library/Caches/cache/subPath
+ (NSURL *)defaultCacheFileURLWithSubPath:(NSString *)subPath {
    NSString *filePath = [self defaultCachePathWithSubPath:subPath];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    return fileURL;
}

/// 根据subPath返回沙盒默认TEMP目录下该subPath的路径: ~/tmp/temp/subPath
+ (NSString *)defaultTempPathWithSubPath:(NSString *)subPath {
    NSString *dir = [self tempPathWithSubPath:kDefaultTempDirName];
    NSString *path = [dir stringByAppendingPathComponent:subPath];
    return path;
}

/// 根据subPath返回沙盒默认TEMP目录下该subPath的URL: ~/tmp/temp/subPath
+ (NSURL *)defaultTempFileURLWithSubPath:(NSString *)subPath {
    NSString *filePath = [self defaultTempPathWithSubPath:subPath];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    return fileURL;
}

+ (BOOL)createDirWithPath:(NSString *)dirPath option:(BOOL)deleteFileWithSameName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    BOOL isDir = NO;
    BOOL exist = [fileManager fileExistsAtPath:dirPath isDirectory:&isDir];
    if (exist && !isDir) {// 存在和文件夹同名的文件
        if (!deleteFileWithSameName) {
            return NO;
        }
        BOOL result = [fileManager removeItemAtPath:dirPath error:&error];
        if (!result) {
            NSLog(@"[ERROR]: Delete file error!\npath: %@\nerror: %@", dirPath, error);
            return NO;
        }
        exist = NO;
        isDir = NO;
    }
    if (!exist || (exist && !isDir)) {
        // 创建文件夹
        BOOL result = [fileManager createDirectoryAtPath:dirPath
                             withIntermediateDirectories:YES
                                              attributes:nil
                                                   error:&error];
        if (!result) {
            NSLog(@"[ERROR]: Create dir error!\npath: %@\nerror: %@", dirPath, error);
            return NO;
        }
    }
    return YES;
}
    
+ (BOOL)createDirWithURL:(NSURL *)dirURL option:(BOOL)deleteFileWithSameName {
    NSString *dirPath = [dirURL path];
    return [self createDirWithPath:dirPath option:deleteFileWithSameName];
}
    
+ (BOOL)removeFileWithPath:(NSString *)path {
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager removeItemAtPath:path error:&error];
    if (!result) {
        NSLog(@"[ERROR]: Delete file error!\npath: %@\nerror: %@", path, error);
    }
    
    return result;
}

+ (BOOL)removeFileWithURL:(NSURL *)fileURL {
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager removeItemAtURL:fileURL error:&error];
    if (!result) {
        NSLog(@"[ERROR]: Delete file error!\nfileURL: %@\nerror: %@", fileURL, error);
    }
    
    return result;
}
    
@end
