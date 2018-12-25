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

/**
 * Document file path in sand box;
 *
 * It will locate in file path "<SandBox>/Document/subPath";
 *
 * The contents of this directory can be made available to the user through file sharing;
 * The files may be read/wrote/deleted by user;
 *
 * It should only contain imported/exported files here, or debugging use only;
 *
 * @param subPath Path relative to the root directory path;
 *                It will return the root directory path when nil;
 *
 * @return Full file path;
 */
+ (NSString *)docPathWithSubPath:(nullable NSString *)subPath;

/**
 * Document file URL in sand box;
 *
 * It will locate in file path "<SandBox>/Document/subPath";
 *
 * The contents of this directory can be made available to the user through file sharing;
 * The files may be read/wrote/deleted by user;
 *
 * It should only contain imported/exported files here, or debugging use only;
 *
 * @param subPath Path relative to the root directory path;
 *                It will return the root directory URL when nil;
 *
 * @return Full file URL;
 */
+ (NSURL *)docFileURLWithSubPath:(nullable NSString *)subPath;
    
/**
 * Library file path in sand box;
 *
 * It will locate in file path "<SandBox>/Library/subPath";
 *
 * Any file you don’t want exposed to the user can be saved here;
 *
 * It is recommended as default file path;
 *
 * @param subPath Path relative to the root directory path;
 *                It will return the root directory path when nil;
 *
 * @return Full file path;
 */
+ (NSString *)libPathWithSubPath:(nullable NSString *)subPath;

/**
 * Library file URL in sand box;
 *
 * It will locate in file path "<SandBox>/Library/subPath";
 *
 * Any file you don’t want exposed to the user can be saved here;
 *
 * It is recommended as default file URL;
 *
 * @param subPath Path relative to the root directory path;
 *                It will return the root directory URL when nil;
 *
 * @return Full file URL;
 */
+ (NSURL *)libFileURLWithSubPath:(nullable NSString *)subPath;
    
/**
 * Cache file path in sand box;
 *
 * It will locate in file path "<SandBox>/Library/Caches/subPath";
 *
 * All cache files should be placed here;
 *
 * It is recommended for caching;
 *
 * @param subPath Path relative to the root directory path;
 *                It will return the root directory path when nil;
 *
 * @return Full file path;
 */
+ (NSString *)cachePathWithSubPath:(nullable NSString *)subPath;

/**
 * Cache file URL in sand box;
 *
 * It will locate in file path "<SandBox>/Library/Caches/subPath";
 *
 * All cache files should be placed here;
 *
 * It is recommended for caching;
 *
 * @param subPath Path relative to the root directory path;
 *                It will return the root directory URL when nil;
 *
 * @return Full file URL;
 */
+ (NSURL *)cacheFileURLWithSubPath:(nullable NSString *)subPath;
    
/**
 * Temp file path in sand box;
 *
 * It will locate in file path "<SandBox>/tmp/subPath";
 *
 * Use this directory to write temporary files that do not need to persist between launches of your app;
 * Your app should remove files from this directory when they are no longer needed;
 *
 * It is recommended for temporary files;
 *
 * @param subPath Path relative to the root directory path;
 *                It will return the root directory path when nil;
 *
 * @return Full file path;
 */
+ (NSString *)tempPathWithSubPath:(nullable NSString *)subPath;
    
/**
 * Temp file URL in sand box;
 *
 * It will locate in file path "<SandBox>/tmp/subPath";
 *
 * Use this directory to write temporary files that do not need to persist between launches of your app;
 * Your app should remove files from this directory when they are no longer needed;
 *
 * It is recommended for temporary files;
 *
 * @param subPath Path relative to the root directory path;
 *                It will return the root directory URL when nil;
 *
 * @return Full file URL;
 */
+ (NSURL *)tempFileURLWithSubPath:(nullable NSString *)subPath;

/**
 * Default public file path in sand box;
 *
 * It will locate in file path "<SandBox>/Document/public/subPath";
 *
 * The contents of this directory can be made available to the user through file sharing;
 * The files may be read/wrote/deleted by user;
 *
 * It should only contain imported/exported files here, or debugging use only;
 *
 * @param subPath Path relative to the root directory path;
 *                It will return the root directory path when nil;
 *
 * @return Full file path;
 */
+ (NSString *)defaultPublicPathWithSubPath:(nullable NSString *)subPath;

/**
 * Default public file URL in sand box;
 *
 * It will locate in file path "<SandBox>/Document/public/subPath";
 *
 * The contents of this directory can be made available to the user through file sharing;
 * The files may be read/wrote/deleted by user;
 *
 * It should only contain imported/exported files here, or debugging use only;
 *
 * @param subPath Path relative to the root directory path;
 *                It will return the root directory URL when nil;
 *
 * @return Full file URL;
 */
+ (NSURL *)defaultPublicFileURLWithSubPath:(nullable NSString *)subPath;

/**
 * Default private file path in sand box;
 *
 * It will locate in file path "<SandBox>/Library/private/subPath";
 *
 * Any file you don’t want exposed to the user can be saved here;
 *
 * It is recommended as default file path;
 *
 * @param subPath Path relative to the root directory path;
 *                It will return the root directory URL when nil;
 *
 * @return Full file path;
 */
+ (NSString *)defaultPrivatePathWithSubPath:(nullable NSString *)subPath;

/**
 * Default private file URL in sand box;
 *
 * It will locate in file path "<SandBox>/Library/private/subPath";
 *
 * Any file you don’t want exposed to the user can be saved here;
 *
 * It is recommended as default file URL;
 *
 * @param subPath Path relative to the root directory path;
 *                It will return the root directory URL when nil;
 *
 * @return Full file URL;
 */
+ (NSURL *)defaultPrivateFileURLWithSubPath:(nullable NSString *)subPath;

/**
 * Default cache file path in sand box;
 *
 * It will locate in file path "<SandBox>/Library/Caches/cache/subPath";
 *
 * All cache files should be placed here;
 *
 * It is recommended for caching;
 *
 * @param subPath Path relative to the root directory path;
 *                It will return the root directory path when nil;
 *
 * @return Full file path;
 */
+ (NSString *)defaultCachePathWithSubPath:(nullable NSString *)subPath;

/**
 * Default cache file URL in sand box;
 *
 * It will locate in file path "<SandBox>/Library/Caches/cache/subPath";
 *
 * All cache files should be placed here;
 *
 * It is recommended for caching;
 *
 * @param subPath Path relative to the root directory path;
 *                It will return the root directory URL when nil;
 *
 * @return Full file URL;
 */
+ (NSURL *)defaultCacheFileURLWithSubPath:(nullable NSString *)subPath;

/**
 * Default temp file path in sand box;
 *
 * It will locate in file path "<SandBox>/tmp/temp/subPath";
 *
 * Use this directory to write temporary files that do not need to persist between launches of your app;
 * Your app should remove files from this directory when they are no longer needed;
 *
 * It is recommended for temporary files;
 *
 * @param subPath Path relative to the root directory path;
 *                It will return the root directory path when nil;
 *
 * @return Full file path;
 */
+ (NSString *)defaultTempPathWithSubPath:(nullable NSString *)subPath;

/**
 * Default temp file URL in sand box;
 *
 * It will locate in file path "<SandBox>/tmp/temp/subPath";
 *
 * Use this directory to write temporary files that do not need to persist between launches of your app;
 * Your app should remove files from this directory when they are no longer needed;
 *
 * It is recommended for temporary files;
 *
 * @param subPath Path relative to the root directory path;
 *                It will return the root directory URL when nil;
 *
 * @return Full file URL;
 */
+ (NSURL *)defaultTempFileURLWithSubPath:(nullable NSString *)subPath;
    
@end

NS_ASSUME_NONNULL_END
