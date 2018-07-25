//
//  CICOSecurityAide.h
//  CICOFoundationKit
//
//  Created by lucky.li on 16/8/26.
//  Copyright © 2016年 cico. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  安全相关API，有以下类型：
 *  1、Common：randomData、hex;
 *  2、Hash：md5、sha1、hmac;
 *  3、对称加密：base64、url encode/decode、aes;
 *  4、非对称加密：rsa;
 */
@interface CICOSecurityAide : NSObject

#pragma mark - COMMON

/**
 *  生成给定长度的随机二进制数据
 *
 *  @param length 给定长度，单位字节（Byte）
 *
 *  @return 随机二进制数据
 */
+ (NSData *)randomDataOfLength:(size_t)length;

/**
 *  二进制转十六进制小写字符串
 *
 *  @param data 二进制数据
 *
 *  @return 十六进制小写字符串
 */
+ (NSString *)hexStringWithData:(NSData *)data;

/**
 *  十六进制字符串转二进制
 *
 *  @param string 十六进制字符串（不区分大小写）
 *
 *  @return 二进制数据
 */
+ (NSData *)dataWithHexString:(NSString *)string;

#pragma mark - MD5

/**
 *  生成MD5数据
 *
 *  @param sourceData 源数据
 *
 *  @return MD5数据
 */
+ (NSData *)md5HashDataWithData:(NSData *)sourceData;

/**
 *  生成MD5十六进制小写字符串
 *
 *  @param sourceData 源数据
 *
 *  @return MD5十六进制小写字符串
 */
+ (NSString *)md5HashStringWithData:(NSData *)sourceData;

/**
 *  源字符串通过UTF8编码转成二进制数据再生成MD5十六进制小写字符串
 *
 *  @param sourceString 源字符串，通过UTF8编码转成二进制数据再生成MD5
 *
 *  @return MD5十六进制小写字符串
 */
+ (NSString *)md5HashStringWithString:(NSString *)sourceString;

#pragma mark - FILE MD5

+ (NSData *)fileMD5HashDataWithURL:(NSURL *)fileURL;

+ (NSString *)fileMD5HashStringWithURL:(NSURL *)fileURL;

+ (NSData *)fastFileHashDataWithURL:(NSURL *)fileURL;

+ (NSString *)fastFileHashStringWithURL:(NSURL *)fileURL;

+ (NSData *)fastFileHashDataWithURL:(NSURL *)fileURL
                   headIgnoreLength:(unsigned long long)headIgnoreLength
                   tailIgnoreLength:(unsigned long long)tailIgnoreLength;

+ (NSString *)fastFileHashStringWithURL:(NSURL *)fileURL
                       headIgnoreLength:(unsigned long long)headIgnoreLength
                       tailIgnoreLength:(unsigned long long)tailIgnoreLength;

#pragma mark - SHA1

/**
 *  生成SHA1数据
 *
 *  @param sourceData 源数据
 *
 *  @return SHA1数据
 */
+ (NSData *)sha1HashDataWithData:(NSData *)sourceData;

/**
 *  生成SHA1十六进制小写字符串
 *
 *  @param sourceData 源数据
 *
 *  @return SHA1十六进制小写字符串
 */
+ (NSString *)sha1HashStringWithData:(NSData *)sourceData;

/**
 *  生成SHA1十六进制小写字符串
 *
 *  @param sourceString 源字符串，通过UTF8编码转成二进制数据
 *
 *  @return SHA1十六进制小写字符串
 */
+ (NSString *)sha1HashStringWithString:(NSString *)sourceString;

#pragma mark - HMAC

/**
 *  生成HMAC-HASH数据
 *
 *  @param algorithmType HASH算法类型，可选择如下类型：
 *  kCCHmacAlgMD5、kCCHmacAlgSHA1、kCCHmacAlgSHA224、kCCHmacAlgSHA256、kCCHmacAlgSHA384、kCCHmacAlgSHA512
 *  @param keyData       加密key数据
 *  @param sourceData    源数据
 *
 *  @return HMAC-HASH数据
 */
+ (NSData *)hmacWithAlgorithmType:(uint32_t)algorithmType
                          keyData:(NSData *)keyData
                       sourceData:(NSData *)sourceData;

/**
 *  生成HMAC-HASH数据
 *
 *  @param algorithmType HASH算法类型，可选择如下类型：
 *  kCCHmacAlgMD5、kCCHmacAlgSHA1、kCCHmacAlgSHA224、kCCHmacAlgSHA256、kCCHmacAlgSHA384、kCCHmacAlgSHA512
 *  @param keyString     加密key字符串，通过UTF8编码转成二进制数据
 *  @param sourceString  源字符串，通过UTF8编码转成二进制数据
 *
 *  @return HMAC-HASH数据
 */
+ (NSData *)hmacWithAlgorithmType:(uint32_t)algorithmType
                        keyString:(NSString *)keyString
                     sourceString:(NSString *)sourceString;

#pragma mark - BASE64

/**
 *  二进制数据转BASE64
 *
 *  @param sourceData 源数据
 *
 *  @return BASE64
 */
+ (NSString *)base64EncodeWithData:(NSData *)sourceData;

/**
 *  字符串转BASE64
 *
 *  @param sourceString 源字符串，通过UTF8编码转成二进制数据
 *
 *  @return BASE64
 */
+ (NSString *)base64EncodeWithString:(NSString *)sourceString;

/**
 *  BASE64转二进制数据
 *
 *  @param base64String BASE64
 *
 *  @return 二进制源数据
 */
+ (NSData *)base64DecodeWithString:(NSString *)base64String;

#pragma mark - URL ENCODE/DECODE

/**
 *  URL ENCODE
 *
 *  @param sourceString 源数据
 *
 *  @return URL-ENCODE加密数据
 */
+ (NSString *)urlEncodeWithString:(NSString *)sourceString;

/**
 *  URL DECODE
 *
 *  @param encodedString URL-ENCODE加密数据
 *
 *  @return 源数据
 */
+ (NSString *)urlDecodeWithString:(NSString *)encodedString;

#pragma mark - AES

/**
 *  AES加密
 *
 *  @param keyData    密码数据，可选择如下长度：
 *  kCCKeySizeAES128、kCCKeySizeAES192、kCCKeySizeAES256
 *  @param sourceData 源数据
 *
 *  @return AES加密数据
 */
+ (NSData *)aesEncryptWithKeyData:(NSData *)keyData sourceData:(NSData *)sourceData;

/**
 *  AES解密
 *
 *  @param keyData     密码数据，可选择如下长度：
 *  kCCKeySizeAES128、kCCKeySizeAES192、kCCKeySizeAES256
 *  @param encodedData AES加密数据
 *
 *  @return 源数据
 */
+ (NSData *)aesDecryptWithKeyData:(NSData *)keyData encodedData:(NSData *)encodedData;

#pragma mark - RSA

/**
 *  读取RSA公钥
 *
 *  @param keyData RSA公钥证书二进制数据
 *
 *  @return RSA公钥
 */
+ (SecKeyRef)rsaPublicKeyWithCerData:(NSData *)keyData;

/**
 *  读取RSA公钥
 *
 *  @param keyPath RSA公钥证书路径
 *
 *  @return RSA公钥
 */
+ (SecKeyRef)rsaPublicKeyWithCerPath:(NSString *)keyPath;

/**
 *  读取RSA私钥
 *
 *  @param password 密码
 *  @param keyData  RSA私钥二进制数据
 *
 *  @return RSA私钥
 */
+ (SecKeyRef)rsaPrivateKeyWithPassword:(NSString *)password p12KeyData:(NSData *)keyData;

/**
 *  读取RSA私钥
 *
 *  @param password 密码
 *  @param keyPath  RSA私钥路径
 *
 *  @return RSA私钥
 */
+ (SecKeyRef)rsaPrivateKeyWithPassword:(NSString *)password p12KeyPath:(NSString *)keyPath;

/**
 *  RSA加密
 *
 *  @param publicKey  RSA公钥
 *  @param sourceData 源数据
 *
 *  @return RSA加密数据
 */
+ (NSData *)rsaEncryptWithPublicKey:(SecKeyRef)publicKey sourceData:(NSData *)sourceData;

/**
 *  RSA解密
 *
 *  @param privateKey  RSA私钥
 *  @param encodedData RSA加密数据
 *
 *  @return 源数据
 */
+ (NSData *)rsaDecryptWithPrivateKey:(SecKeyRef)privateKey encodedData:(NSData *)encodedData;

@end
