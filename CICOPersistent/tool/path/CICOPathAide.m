//
//  CICOPathAide.m
//  CICOPersistent
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

+ (NSString *)defaultPublicPathWithSubPath:(NSString *)subPath {
    NSString *dir = [self docPathWithSubPath:kDefaultPublicDirName];
    NSString *path = [dir stringByAppendingPathComponent:subPath];
    return path;
}

+ (NSURL *)defaultPublicFileURLWithSubPath:(NSString *)subPath {
    NSString *filePath = [self defaultPublicPathWithSubPath:subPath];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    return fileURL;
}

+ (NSString *)defaultPrivatePathWithSubPath:(NSString *)subPath {
    NSString *dir = [self libPathWithSubPath:kDefaultPrivateDirName];
    NSString *path = [dir stringByAppendingPathComponent:subPath];
    return path;
}

+ (NSURL *)defaultPrivateFileURLWithSubPath:(NSString *)subPath {
    NSString *filePath = [self defaultPrivatePathWithSubPath:subPath];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    return fileURL;
}

+ (NSString *)defaultCachePathWithSubPath:(NSString *)subPath {
    NSString *dir = [self cachePathWithSubPath:kDefaultCacheDirName];
    NSString *path = [dir stringByAppendingPathComponent:subPath];
    return path;
}

+ (NSURL *)defaultCacheFileURLWithSubPath:(NSString *)subPath {
    NSString *filePath = [self defaultCachePathWithSubPath:subPath];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    return fileURL;
}

+ (NSString *)defaultTempPathWithSubPath:(NSString *)subPath {
    NSString *dir = [self tempPathWithSubPath:kDefaultTempDirName];
    NSString *path = [dir stringByAppendingPathComponent:subPath];
    return path;
}

+ (NSURL *)defaultTempFileURLWithSubPath:(NSString *)subPath {
    NSString *filePath = [self defaultTempPathWithSubPath:subPath];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    return fileURL;
}
    
@end
