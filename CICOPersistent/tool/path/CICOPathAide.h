//
//  CICOPathAide.h
//  CICOPersistent
//
//  Created by lucky.li on 16/8/31.
//  Copyright © 2016年 cico. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CICOPathAide : NSObject

/// <SandBox>/Document/subPath
+ (NSString *)docPathWithSubPath:(nullable NSString *)subPath;

/// <SandBox>/Document/subPath
+ (NSURL *)docFileURLWithSubPath:(nullable NSString *)subPath;
    
/// <SandBox>/Library/subPath
+ (NSString *)libPathWithSubPath:(nullable NSString *)subPath;

/// <SandBox>/Library/subPath
+ (NSURL *)libFileURLWithSubPath:(nullable NSString *)subPath;
    
/// <SandBox>/Library/Caches/subPath
+ (NSString *)cachePathWithSubPath:(nullable NSString *)subPath;

/// <SandBox>/Library/Caches/subPath
+ (NSURL *)cacheFileURLWithSubPath:(nullable NSString *)subPath;
    
/// <SandBox>/tmp/subPath
+ (NSString *)tempPathWithSubPath:(nullable NSString *)subPath;
    
/// <SandBox>/tmp/subPath
+ (NSURL *)tempFileURLWithSubPath:(nullable NSString *)subPath;

/// <SandBox>/Document/public/subPath
+ (NSString *)defaultPublicPathWithSubPath:(nullable NSString *)subPath;

/// <SandBox>/Document/public/subPath
+ (NSURL *)defaultPublicFileURLWithSubPath:(nullable NSString *)subPath;

/// <SandBox>/Library/private/subPath
+ (NSString *)defaultPrivatePathWithSubPath:(nullable NSString *)subPath;

/// <SandBox>/Library]private/subPath
+ (NSURL *)defaultPrivateFileURLWithSubPath:(nullable NSString *)subPath;

/// <SandBox>/Library/Caches/cache/subPath
+ (NSString *)defaultCachePathWithSubPath:(nullable NSString *)subPath;

/// <SandBox>/Library/Caches/cache/subPath
+ (NSURL *)defaultCacheFileURLWithSubPath:(nullable NSString *)subPath;

/// <SandBox>/tmp/temp/subPath
+ (NSString *)defaultTempPathWithSubPath:(nullable NSString *)subPath;

/// <SandBox>/tmp/temp/subPath
+ (NSURL *)defaultTempFileURLWithSubPath:(nullable NSString *)subPath;
    
@end

NS_ASSUME_NONNULL_END
