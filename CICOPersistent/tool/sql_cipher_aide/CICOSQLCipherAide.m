//
//  SQLCipherAide.m
//  CICOPersistent
//
//  Created by lucky.li on 2018/11/27.
//  Copyright © 2018 cico. All rights reserved.
//

#import "CICOSQLCipherAide.h"
#import <SQLCipher/sqlite3.h>

@implementation CICOSQLCipherAide

+ (BOOL)exportDatabase:(NSString *)fromDBPath
        fromDBPassword:(nullable NSString *)fromDBPassword
              toDBPath:(NSString *)toDBPath
          toDBPassword:(nullable NSString *)toDBPassword {
    sqlite3 *fromDB = NULL;
    int result = sqlite3_open([fromDBPath fileSystemRepresentation], &fromDB);
    if (SQLITE_OK != result) {
        NSLog(@"[ERROR]: Open database failed.\nfromDBPath = %@", fromDBPath);
        sqlite3_close(fromDB);
        return NO;
    }
    
    if (nil != fromDBPassword) {
        NSData *keyData = [NSData dataWithBytes:[fromDBPassword UTF8String] length:(NSUInteger)strlen([fromDBPassword UTF8String])];
        result = sqlite3_key(fromDB, [keyData bytes], (int)[keyData length]);
        if (SQLITE_OK != result) {
            NSLog(@"[ERROR]: Database set password failed.\nfromDBPath = %@", fromDBPath);
            sqlite3_close(fromDB);
            return NO;
        }
    }
    
    NSString *toDBName = @"toDB";
    
    char *error = NULL;
    
    NSString *attachSQL = nil;
    if (nil == toDBPassword) {
        attachSQL = [NSString stringWithFormat:@"ATTACH DATABASE '%@' AS %@ KEY '';",
                     toDBPath, toDBName];
    } else {
        attachSQL = [NSString stringWithFormat:@"ATTACH DATABASE '%@' AS %@ KEY '%@';",
                     toDBPath, toDBName, toDBPassword];
    }
    result = sqlite3_exec(fromDB, [attachSQL fileSystemRepresentation], NULL, NULL, &error);
    if (SQLITE_OK != result) {
        NSLog(@"[ERROR]: Attach database failed.\ntoDBPath = %@\nerror = %s", toDBPath, error);
        sqlite3_close(fromDB);
        return NO;
    }
    
    NSString *exportSQL = [NSString stringWithFormat:@"SELECT sqlcipher_export('%@');", toDBName];
    result = sqlite3_exec(fromDB, [exportSQL fileSystemRepresentation], NULL, NULL, &error);
    if (SQLITE_OK != result) {
        NSLog(@"[ERROR]: Export database failed.\ntoDBPath = %@\nerror = %s", toDBPath, error);
        sqlite3_close(fromDB);
        return NO;
    }
    
    NSString *detachSQL = [NSString stringWithFormat:@"DETACH DATABASE '%@';", toDBName];
    result = sqlite3_exec(fromDB, [detachSQL fileSystemRepresentation], NULL, NULL, &error);
    if (SQLITE_OK != result) {
        NSLog(@"[ERROR]: Detach database failed.\ntoDBPath = %@\nerror = %s", toDBPath, error);
        sqlite3_close(fromDB);
        return NO;
    }
    
    sqlite3_close(fromDB);
    
    return YES;
}

+ (BOOL)encryptDatabase:(NSString *)dbPath password:(NSString *)password {
    NSString *tmpDBPath = [dbPath stringByAppendingString:@".tmp.db"];
    BOOL result = [self exportDatabase:dbPath fromDBPassword:nil toDBPath:tmpDBPath toDBPassword:password];
    if (!result) {
        return NO;
    }
    
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    result = [fileManager removeItemAtPath:dbPath error:&error];
    if (!result) {
        NSLog(@"[ERROR]: Delete file error!\npath: %@\nerror: %@", dbPath, error);
        return NO;
    }
    
    result = [fileManager moveItemAtPath:tmpDBPath toPath:dbPath error:&error];
    if (!result) {
        NSLog(@"[ERROR]: move file error!\nfrom: %@\nto: %@\nerror: %@", tmpDBPath, dbPath, error);
        return NO;
    }
    
    return result;
}

+ (BOOL)decryptDatabase:(NSString *)dbPath password:(NSString *)password {
    NSString *tmpDBPath = [dbPath stringByAppendingString:@".tmp.db"];
    BOOL result = [self exportDatabase:dbPath fromDBPassword:password toDBPath:tmpDBPath toDBPassword:nil];
    if (!result) {
        return NO;
    }
    
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    result = [fileManager removeItemAtPath:dbPath error:&error];
    if (!result) {
        NSLog(@"[ERROR]: Delete file error!\npath: %@\nerror: %@", dbPath, error);
        return NO;
    }
    
    result = [fileManager moveItemAtPath:tmpDBPath toPath:dbPath error:&error];
    if (!result) {
        NSLog(@"[ERROR]: move file error!\nfrom: %@\nto: %@\nerror: %@", tmpDBPath, dbPath, error);
        return NO;
    }
    
    return result;
}

+ (BOOL)changeDatabasePassword:(NSString *)dbPath
              originalPassword:(NSString *)originalPassword
                   newPassword:(NSString *)newPassword {
    sqlite3 *db = NULL;
    int result = sqlite3_open([dbPath fileSystemRepresentation], &db);
    if (SQLITE_OK != result) {
        NSLog(@"[ERROR]: Open database failed.\ndbPath = %@", dbPath);
        sqlite3_close(db);
        return NO;
    }
    
    NSData *keyData = [NSData dataWithBytes:[originalPassword UTF8String] length:(NSUInteger)strlen([originalPassword UTF8String])];
    result = sqlite3_key(db, [keyData bytes], (int)[keyData length]);
    if (SQLITE_OK != result) {
        NSLog(@"[ERROR]: Database set password failed.\ndbPath = %@", dbPath);
        sqlite3_close(db);
        return NO;
    }
    
    NSData *newKeyData = [NSData dataWithBytes:[newPassword UTF8String] length:(NSUInteger)strlen([newPassword UTF8String])];
    result = sqlite3_rekey(db, [newKeyData bytes], (int)[newKeyData length]);
    if (SQLITE_OK != result) {
        NSLog(@"[ERROR]: Database set password failed.\ndbPath = %@", dbPath);
        sqlite3_close(db);
        return NO;
    }
    
    sqlite3_close(db);
    
    return YES;
}

@end
