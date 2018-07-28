//
//  CICOFileManagerAide.m
//  CICOPersistent
//
//  Created by lucky.li on 2018/7/28.
//  Copyright © 2018 cico. All rights reserved.
//

#import "CICOFileManagerAide.h"

@implementation CICOFileManagerAide

+ (BOOL)createDirWithPath:(NSString *)dirPath option:(BOOL)deleteFileWithSameName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    BOOL isDir = NO;
    
    BOOL exist = [fileManager fileExistsAtPath:dirPath isDirectory:&isDir];
    if (exist && !isDir) {
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

+ (BOOL)moveItemFromPath:(NSString *)fromPath toPath:(NSString *)toPath {
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager moveItemAtPath:fromPath toPath:toPath error:&error];
    if (!result) {
        NSLog(@"[ERROR]: move file error!\nfrom: %@\nto: %@\nerror: %@", fromPath, toPath, error);
    }
    return result;
}

+ (BOOL)moveItemFromURL:(NSURL *)fromURL toURL:(NSURL *)toURL {
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager moveItemAtURL:fromURL toURL:toURL error:&error];
    if (!result) {
        NSLog(@"[ERROR]: move file error!\nfrom: %@\nto: %@\nerror: %@", fromURL, toURL, error);
    }
    return result;
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
