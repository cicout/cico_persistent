//
//  CICOFileManagerAide.h
//  CICOPersistent
//
//  Created by lucky.li on 2018/7/28.
//  Copyright © 2018 cico. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CICOFileManagerAide : NSObject

+ (BOOL)createDirWithPath:(NSString *)dirPath;

+ (BOOL)createDirWithPath:(NSString *)dirPath option:(BOOL)deleteFileWithSameName;

+ (BOOL)createDirWithURL:(NSURL *)dirURL;

+ (BOOL)createDirWithURL:(NSURL *)dirURL option:(BOOL)deleteFileWithSameName;

+ (BOOL)moveItemFromPath:(NSString *)fromPath toPath:(NSString *)toPath;

+ (BOOL)moveItemFromURL:(NSURL *)fromURL toURL:(NSURL *)toURL;

+ (BOOL)removeFileWithPath:(NSString *)path;

+ (BOOL)removeFileWithURL:(NSURL *)fileURL;

@end
