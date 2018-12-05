//
//  CICOSQLCipherAide.h
//  CICOPersistent
//
//  Created by lucky.li on 2018/11/27.
//  Copyright © 2018 cico. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CICOSQLCipherAide : NSObject

/**
 * Export database;
 *
 * @param fromDBPath Source database path;
 * @param fromDBPassword Source database password, no password when nil;
 * @param toDBPath Destination database path;
 * @param toDBPassword Destination database password, no password when nil;
 *
 * @return Export result;
 */
+ (BOOL)exportDatabase:(NSString *)fromDBPath
        fromDBPassword:(nullable NSString *)fromDBPassword
              toDBPath:(NSString *)toDBPath
          toDBPassword:(nullable NSString *)toDBPassword;

/**
 * Encrypt passwordless database;
 *
 * @param dbPath Passwordless database path;
 * @param password Database encryption password;
 *
 * @return Encrypt result;
 */
+ (BOOL)encryptDatabase:(NSString *)dbPath password:(NSString *)password;

/**
 * Decrypt encrypted database into passwordless;
 *
 * @param dbPath Encrypted database path;
 * @param password Encrypted database password;
 *
 * @return Decrypt result;
 */
+ (BOOL)decryptDatabase:(NSString *)dbPath password:(NSString *)password;

/**
 * Change encrypted database password;
 *
 * @param dbPath Encrypted database path;
 * @param originalPassword Original password for encrypted database;
 * @param newPassword New password for encrypted database;
 *
 * @return Change password result;
 */
+ (BOOL)changeDatabasePassword:(NSString *)dbPath
              originalPassword:(NSString *)originalPassword
                   newPassword:(NSString *)newPassword;

@end

NS_ASSUME_NONNULL_END
