//
//  CICOPathAide.h
//  CICOFoundationKit
//
//  Created by lucky.li on 16/8/31.
//  Copyright © 2016年 cico. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CICOPathAide : NSObject

/// <SandBox>/Document/subPath
+ (NSString *)docPathWithSubPath:(NSString *)subPath;

/// <SandBox>/Document/subPath
+ (NSURL *)docFileURLWithSubPath:(NSString *)subPath;
    
/// <SandBox>/Library/subPath
+ (NSString *)libPathWithSubPath:(NSString *)subPath;

/// <SandBox>/Library/subPath
+ (NSURL *)libFileURLWithSubPath:(NSString *)subPath;
    
/// <SandBox>/Library/Caches/subPath
+ (NSString *)cachePathWithSubPath:(NSString *)subPath;

/// <SandBox>/Library/Caches/subPath
+ (NSURL *)cacheFileURLWithSubPath:(NSString *)subPath;
    
/// <SandBox>/tmp/subPath
+ (NSString *)tempPathWithSubPath:(NSString *)subPath;
    
/// <SandBox>/tmp/subPath
+ (NSURL *)tempFileURLWithSubPath:(NSString *)subPath;

/// <SandBox>/Document/public/subPath
+ (NSString *)defaultPublicPathWithSubPath:(NSString *)subPath;

/// <SandBox>/Document/public/subPath
+ (NSURL *)defaultPublicFileURLWithSubPath:(NSString *)subPath;

/// <SandBox>/Library/private/subPath
+ (NSString *)defaultPrivatePathWithSubPath:(NSString *)subPath;

/// <SandBox>/Library]private/subPath
+ (NSURL *)defaultPrivateFileURLWithSubPath:(NSString *)subPath;

/// <SandBox>/Library/Caches/cache/subPath
+ (NSString *)defaultCachePathWithSubPath:(NSString *)subPath;

/// <SandBox>/Library/Caches/cache/subPath
+ (NSURL *)defaultCacheFileURLWithSubPath:(NSString *)subPath;

/// <SandBox>/tmp/temp/subPath
+ (NSString *)defaultTempPathWithSubPath:(NSString *)subPath;

/// <SandBox>/tmp/temp/subPath
+ (NSURL *)defaultTempFileURLWithSubPath:(NSString *)subPath;
    
@end
