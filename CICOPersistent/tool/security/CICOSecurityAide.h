//
//  CICOSecurityAide.h
//  CICOPersistent
//
//  Created by lucky.li on 16/8/26.
//  Copyright © 2016年 cico. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  1、Common：randomData、hex;
 *  2、Hash：md5、sha1、hmac;
 *  3、Symmetric Encryption：base64、url encode/decode、aes;
 *  4、Asymmetric Encryption：rsa;
 */
@interface CICOSecurityAide : NSObject

#pragma mark - COMMON

/**
 *  Create random data;
 *
 *  @param length Length of byte;
 *
 *  @return Random data;
 */
+ (NSData *)randomDataOfLength:(size_t)length;

/**
 *  Transfer data to hex string in lower case;
 *
 *  @param data Data;
 *
 *  @return Hex string;
 */
+ (NSString *)hexStringWithData:(NSData *)data;

/**
 *  Transfer hex string to data;
 *
 *  @param string Hex string (lower case / upper case);
 *
 *  @return Data;
 */
+ (NSData *)dataWithHexString:(NSString *)string;

#pragma mark - MD5

/**
 *  Transfer data to md5 hash data;
 *
 *  @param sourceData Source data;
 *
 *  @return MD5 hash data;
 */
+ (NSData *)md5HashDataWithData:(NSData *)sourceData;

/**
 *  Transfer data to md5 hash hex string in lower case;
 *
 *  @param sourceData Source data;
 *
 *  @return MD5 hash hex string in lower case;
 *
 *  @see md5HashDataWithData:;
 */
+ (NSString *)md5HashStringWithData:(NSData *)sourceData;

/**
 *  Transfer string to md5 hash data;
 *
 *  @param sourceString Source string, will be transfered to data using utf-8;
 *
 *  @return MD5 hash data;
 *
 *  @see md5HashDataWithData:;
 */
+ (NSData *)md5HashDataWithString:(NSString *)sourceString;

/**
 *  Transfer string to md5 hash hex string in lower case;
 *
 *  @param sourceString Source string, will be transfered to data using utf-8;
 *
 *  @return MD5 hash hex string in lower case;
 *
 *  @see md5HashDataWithData:;
 */
+ (NSString *)md5HashStringWithString:(NSString *)sourceString;

#pragma mark - FILE MD5

/**
 *  Read all data from file url and transfer them to md5 hash data;
 *
 *  @param fileURL File url, all data will be read;
 *
 *  @return MD5 hash data, return nil when no file existed;
 */
+ (NSData *)fileMD5HashDataWithURL:(NSURL *)fileURL;

/**
 *  Read all data from file url and transfer them to md5 hash hex string in lower case;
 *
 *  @param fileURL File url, all data will be read;
 *
 *  @return MD5 hash hex string in lower case, return nil when no file existed;
 *
 *  @see fileMD5HashDataWithURL:;
 */
+ (NSString *)fileMD5HashStringWithURL:(NSURL *)fileURL;

/**
 *  Read some data from file url and transfer them to md5 hash data;
 *
 *  @param fileURL File url;
 *
 *  @return MD5 hash data, return nil when no file existed;
 *
 *  @see fastFileHashDataWithURL:headIgnoreLength:tailIgnoreLength:;
 */
+ (NSData *)fastFileHashDataWithURL:(NSURL *)fileURL;

/**
 *  Read some data from file url and transfer them to md5 hash hex string in lower case;
 *
 *  @param fileURL File url;
 *
 *  @return MD5 hash hex string in lower case, return nil when no file existed;
 *
 *  @see fastFileHashDataWithURL:headIgnoreLength:tailIgnoreLength:;
 */
+ (NSString *)fastFileHashStringWithURL:(NSURL *)fileURL;

/**
 *  Read some data from file url and transfer them to md5 hash data;
 *
 *  File data reading rule:
 *  1.Ignore head and tail if fileSize - headIgnoreLength - tailIgnoreLength >= 1M;
 *  2.Head and tail ignore length will be reset to 0 if fileSize - headIgnoreLength - tailIgnoreLength < 1M;
 *  3.Read all left data if they are less than 4M;
 *  2.Read 1M data from each of the head/middle/tail if left data is greater than or equal to 4M;
 *  3.Join the data read with file size together;
 *  4.Transfer them to md5 hash data;
 *
 *  @param fileURL File url;
 *  @param headIgnoreLength Head length of byte to ignore, it will be reset to 0 if left data is less than 1M;
 *  @param tailIgnoreLength Tail length of byte to ignore, it will be reset to 0 if left data is less than 1M;
 *
 *  @return MD5 hash data, return nil when no file existed;
 */
+ (NSData *)fastFileHashDataWithURL:(NSURL *)fileURL
                   headIgnoreLength:(unsigned long long)headIgnoreLength
                   tailIgnoreLength:(unsigned long long)tailIgnoreLength;

/**
 *  Read some data from file url and transfer them to md5 hash hex string in lower case;
 *
 *  @param fileURL File url;
 *  @param headIgnoreLength Head length of byte to ignore, it will be reset to 0 if left data is less than 1M;
 *  @param tailIgnoreLength Tail length of byte to ignore, it will be reset to 0 if left data is less than 1M;
 *
 *  @return MD5 hash hex string in lower case, return nil when no file existed;
 *
 *  @see fastFileHashDataWithURL:headIgnoreLength:tailIgnoreLength:;
 */
+ (NSString *)fastFileHashStringWithURL:(NSURL *)fileURL
                       headIgnoreLength:(unsigned long long)headIgnoreLength
                       tailIgnoreLength:(unsigned long long)tailIgnoreLength;

#pragma mark - SHA1

/**
 *  Transfer data to sha1 hash data;
 *
 *  @param sourceData Source data;
 *
 *  @return SHA1 hash data;
 */
+ (NSData *)sha1HashDataWithData:(NSData *)sourceData;

/**
 *  Transfer data to sha1 hash hex string in lower case;
 *
 *  @param sourceData Source data;
 *
 *  @return SHA1 hash hex string in lower case;
 *
 *  @see sha1HashDataWithData:;
 */
+ (NSString *)sha1HashStringWithData:(NSData *)sourceData;

/**
 *  Transfer string to sha1 hash data;
 *
 *  @param sourceString Source string, will be transfered to data using utf-8;
 *
 *  @return SHA1 hash data;
 *
 *  @see sha1HashDataWithData:;
 */
+ (NSData *)sha1HashDataWithString:(NSString *)sourceString;

/**
 *  Transfer string to sha1 hash hex string in lower case;
 *
 *  @param sourceString Source string, will be transfered to data using utf-8;
 *
 *  @return SHA1 hash hex string in lower case;
 *
 *  @see sha1HashDataWithData:;
 */
+ (NSString *)sha1HashStringWithString:(NSString *)sourceString;

#pragma mark - HMAC

/**
 *  Transfer data to HMAC-HASH hash data;
 *
 *  @param algorithmType Hash algorithm type, you can choose one of below:
 *  kCCHmacAlgMD5、kCCHmacAlgSHA1、kCCHmacAlgSHA224、kCCHmacAlgSHA256、kCCHmacAlgSHA384、kCCHmacAlgSHA512;
 *  @param keyData       Key data;
 *  @param sourceData    Source data;
 *
 *  @return HMAC-HASH data;
 */
+ (NSData *)hmacWithAlgorithmType:(uint32_t)algorithmType
                          keyData:(NSData *)keyData
                       sourceData:(NSData *)sourceData;

/**
 *  Transfer string to HMAC-HASH hash data;
 *
 *  @param algorithmType Hash algorithm type, you can choose one of below:
 *  kCCHmacAlgMD5、kCCHmacAlgSHA1、kCCHmacAlgSHA224、kCCHmacAlgSHA256、kCCHmacAlgSHA384、kCCHmacAlgSHA512;
 *  @param keyString       Key string, will be transfered to data using utf-8;
 *  @param sourceString    Source string, will be transfered to data using utf-8;
 *
 *  @return HMAC-HASH data;
 *
 *  @see hmacWithAlgorithmType:keyData:sourceData;
 */
+ (NSData *)hmacWithAlgorithmType:(uint32_t)algorithmType
                        keyString:(NSString *)keyString
                     sourceString:(NSString *)sourceString;

#pragma mark - BASE64

/**
 *  Encrypt data to base64 string;
 *
 *  @param sourceData Source data;
 *
 *  @return BASE64 string;
 */
+ (NSString *)base64EncodeWithData:(NSData *)sourceData;

/**
 *  Encrypt string to base64 string;
 *
 *  @param sourceString Source string, will be transfered to data using utf-8;
 *
 *  @return BASE64 string;
 *
 *  @see base64EncodeWithData;
 */
+ (NSString *)base64EncodeWithString:(NSString *)sourceString;

/**
 *  Decrypt base64 string to source data;
 *
 *  @param base64String BASE64 string;
 *
 *  @return Source data;
 */
+ (NSData *)base64DecodeWithString:(NSString *)base64String;

#pragma mark - URL ENCODE/DECODE

/**
 *  Encrypt string to url encoded string;
 *
 *  @param sourceString Source string;
 *
 *  @return URL encoded string;
 */
+ (NSString *)urlEncodeWithString:(NSString *)sourceString;

/**
 *  Decrypt url encoded string to source string;
 *
 *  @param encodedString URL encoded string;
 *
 *  @return Source string;
 */
+ (NSString *)urlDecodeWithString:(NSString *)encodedString;

#pragma mark - AES

/**
 *  Encrypt data using AES;
 *
 *  @param keyData    AES encryption key data, choose type according to data length:
 *  kCCKeySizeAES128、kCCKeySizeAES192、kCCKeySizeAES256
 *  @param sourceData Source data;
 *
 *  @return AES encrypted data;
 */
+ (NSData *)aesEncryptWithKeyData:(NSData *)keyData sourceData:(NSData *)sourceData;

/**
 *  Decrypt data using AES;
 *
 *  @param keyData     AES decryption key data, choose type according to data length:
 *  kCCKeySizeAES128、kCCKeySizeAES192、kCCKeySizeAES256
 *  @param encryptedData AES encrypted data;
 *
 *  @return Source data;
 */
+ (NSData *)aesDecryptWithKeyData:(NSData *)keyData encryptedData:(NSData *)encryptedData;

/**
 *  Encrypt data using AES;
 *
 *  @param keyString    AES encryption key string, will be transfered to data using md5 hash;
 *  @param sourceData   Source data;
 *
 *  @return AES encrypted data;
 */
+ (NSData *)aesEncryptWithKeyString:(NSString *)keyString sourceData:(NSData *)sourceData;

/**
 *  Decrypt data using AES;
 *
 *  @param keyString     AES decryption key string, will be transfered to data using md5 hash;
 *  @param encryptedData AES encrypted data;
 *
 *  @return Source data;
 */
+ (NSData *)aesDecryptWithKeyString:(NSString *)keyString encryptedData:(NSData *)encryptedData;

#pragma mark - RSA

/**
 *  Transfer data to RSA public key;
 *
 *  @param keyData RSA public key data;
 *
 *  @return RSA public key;
 */
+ (SecKeyRef)rsaPublicKeyWithCerData:(NSData *)keyData;

/**
 *  Read RSA public key;
 *
 *  @param keyPath RSA public key file path;
 *
 *  @return RSA public key;
 */
+ (SecKeyRef)rsaPublicKeyWithCerPath:(NSString *)keyPath;

/**
 *  Transfer data to RSA private key;
 *
 *  @param password RSA private key password;
 *  @param keyData  RSA private key data;
 *
 *  @return RSA private key;
 */
+ (SecKeyRef)rsaPrivateKeyWithPassword:(NSString *)password p12KeyData:(NSData *)keyData;

/**
 *  Read RSA private key;
 *
 *  @param password RSA private key password;
 *  @param keyPath  RSA private key file path;
 *
 *  @return RSA private key;
 */
+ (SecKeyRef)rsaPrivateKeyWithPassword:(NSString *)password p12KeyPath:(NSString *)keyPath;

/**
 *  Encrypt data using RSA public key;
 *
 *  @param publicKey  RSA public key;
 *  @param sourceData Source data;
 *
 *  @return RSA encrypted data;
 */
+ (NSData *)rsaEncryptWithPublicKey:(SecKeyRef)publicKey sourceData:(NSData *)sourceData;

/**
 *  Decrypt data using RSA private key;
 *
 *  @param privateKey  RSA private key;
 *  @param encodedData RSA encrypted data;
 *
 *  @return Source data;
 */
+ (NSData *)rsaDecryptWithPrivateKey:(SecKeyRef)privateKey encodedData:(NSData *)encodedData;

@end

NS_ASSUME_NONNULL_END
