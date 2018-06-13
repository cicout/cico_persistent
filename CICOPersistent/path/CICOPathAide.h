//
//  CICOPathAide.h
//  CICOFoundationKit
//
//  Created by lucky.li on 16/8/31.
//  Copyright © 2016年 cico. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CICOPathAide : NSObject

/// 根据subPath返回沙盒Document目录下该subPath的路径: ~/Document/subPath
+ (NSString *)docPathWithSubPath:(NSString *)subPath;

/// 根据subPath返回沙盒Document目录下该subPath的URL: ~/Document/subPath
+ (NSURL *)docFileURLWithSubPath:(NSString *)subPath;
    
/// 根据subPath返回沙盒缓存目录下该subPath的路径: ~/Library/subPath
+ (NSString *)libPathWithSubPath:(NSString *)subPath;

/// 根据subPath返回沙盒缓存目录下该subPath的URL: ~/Library/subPath
+ (NSURL *)libFileURLWithSubPath:(NSString *)subPath;
    
/// 根据subPath返回沙盒缓存目录下该subPath的路径: ~/Library/Caches/subPath
+ (NSString *)cachePathWithSubPath:(NSString *)subPath;

/// 根据subPath返回沙盒缓存目录下该subPath的URL: ~/Library/Caches/subPath
+ (NSURL *)cacheFileURLWithSubPath:(NSString *)subPath;
    
/// 根据subPath返回沙盒tmp目录下该subPath的路径: ~/tmp/subPath
+ (NSString *)tempPathWithSubPath:(NSString *)subPath;
    
/// 根据subPath返回沙盒tmp目录下该subPath的URL: ~/tmp/subPath
+ (NSURL *)tempFileURLWithSubPath:(NSString *)subPath;

/// 根据subPath返回沙盒默认PUBLIC目录下该subPath的路径: ~/Document/public/subPath
+ (NSString *)defaultPublicPathWithSubPath:(NSString *)subPath;

/// 根据subPath返回沙盒默认PUBLIC目录下该subPath的URL: ~/Document/public/subPath
+ (NSURL *)defaultPublicFileURLWithSubPath:(NSString *)subPath;

/// 根据subPath返回沙盒默认PRIVATE目录下该subPath的路径: ~/Library/private/subPath
+ (NSString *)defaultPrivatePathWithSubPath:(NSString *)subPath;

/// 根据subPath返回沙盒默认PRIVATE目录下该subPath的URL: ~/Library]private/subPath
+ (NSURL *)defaultPrivateFileURLWithSubPath:(NSString *)subPath;

/// 根据subPath返回沙盒默认CACHE目录下该subPath的路径: ~/Library/Caches/cache/subPath
+ (NSString *)defaultCachePathWithSubPath:(NSString *)subPath;

/// 根据subPath返回沙盒默认CACHE目录下该subPath的URL: ~/Library/Caches/cache/subPath
+ (NSURL *)defaultCacheFileURLWithSubPath:(NSString *)subPath;

/// 根据subPath返回沙盒默认TEMP目录下该subPath的路径: ~/tmp/temp/subPath
+ (NSString *)defaultTempPathWithSubPath:(NSString *)subPath;

/// 根据subPath返回沙盒默认TEMP目录下该subPath的URL: ~/tmp/temp/subPath
+ (NSURL *)defaultTempFileURLWithSubPath:(NSString *)subPath;

/// 创建文件夹
+ (BOOL)createDirWithPath:(NSString *)dirPath option:(BOOL)deleteFileWithSameName;

/// 创建文件夹
+ (BOOL)createDirWithURL:(NSURL *)dirURL option:(BOOL)deleteFileWithSameName;
    
/// 删除文件夹
+ (BOOL)removeFileWithPath:(NSString *)path;
    
/// 删除文件夹
+ (BOOL)removeFileWithURL:(NSURL *)fileURL;
    
@end
