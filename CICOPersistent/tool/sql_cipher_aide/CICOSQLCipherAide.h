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

+ (BOOL)exportDatabase:(NSString *)fromDBPath
        fromDBPassword:(nullable NSString *)fromDBPassword
              toDBPath:(NSString *)toDBPath
          toDBPassword:(nullable NSString *)toDBPassword;

+ (BOOL)encryptDatabase:(NSString *)dbPath password:(NSString *)password;

+ (BOOL)decryptDatabase:(NSString *)dbPath password:(NSString *)password;

+ (BOOL)changeDatabasePassword:(NSString *)dbPath
              originalPassword:(NSString *)originalPassword
                   newPassword:(NSString *)newPassword;

@end

NS_ASSUME_NONNULL_END
