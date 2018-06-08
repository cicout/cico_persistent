//
//  CICOSecurityAide.m
//  CICOFoundationKit
//
//  Created by lucky.li on 16/8/26.
//  Copyright © 2016年 cico. All rights reserved.
//

#import "CICOSecurityAide.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <Security/Security.h>

#pragma mark - FUNCTION DECLARATION

OSStatus extractIdentityAndTrust(CFDataRef inPKCS12Data,
                                 CFStringRef password,
                                 SecIdentityRef *outIdentity,
                                 SecTrustRef *outTrust);

#pragma mark -
@implementation CICOSecurityAide

#pragma mark - PUBLIC

#pragma mark - COMMON

+ (NSData *)randomDataOfLength:(size_t)length {
    NSMutableData *data = [NSMutableData dataWithLength:length];
    int result = SecRandomCopyBytes(kSecRandomDefault, length, data.mutableBytes);
    NSAssert(result == 0, @"Unable to generate random bytes.");
    return data;
}

+ (NSString *)hexStringWithData:(NSData *)data {
    NSMutableString *string = [NSMutableString stringWithCapacity:(data.length*2)];
    const unsigned char *bytes = [data bytes];
    for (int i = 0; i < data.length; ++i) {
        [string appendFormat:@"%02x", (unsigned char)bytes[i]];
    }
    return string;
}

+ (NSData *)dataWithHexString:(NSString *)string {
    if (string.length == 0 || string.length % 2 != 0) {
        NSAssert(NO, @"Hex string to NSData error: invalid hex string!");
        return nil;
    }
    
    string = [string lowercaseString];
    NSMutableData *result = [NSMutableData data];
    unsigned char whole_byte;
    char byte_chars[3] = {0};
    for (int i = 0; i < [string length] / 2; ++i) {
        byte_chars[0] = [string characterAtIndex:i * 2];
        byte_chars[1] = [string characterAtIndex:i * 2 + 1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [result appendBytes:&whole_byte length:1];
    }
    return [result copy];
}

#pragma mark - MD5

+ (NSData *)md5HashDataWithData:(NSData *)sourceData {
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(sourceData.bytes, (CC_LONG)sourceData.length, digest);
    NSData *data = [NSData dataWithBytes:digest length:CC_MD5_DIGEST_LENGTH];
    return data;
}

+ (NSString *)md5HashStringWithData:(NSData *)sourceData {
    NSData *data = [self md5HashDataWithData:sourceData];
    NSString *string = [self hexStringWithData:data];
    return string;
}

+ (NSString *)md5HashStringWithString:(NSString *)sourceString {
    NSData *sourceData = [sourceString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *string = [self md5HashStringWithData:sourceData];
    return string;
}

#pragma mark - SHA1

+ (NSData *)sha1HashDataWithData:(NSData *)sourceData {
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(sourceData.bytes, (CC_LONG)sourceData.length, digest);
    NSData *data = [NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
    return data;
}

+ (NSString *)sha1HashStringWithData:(NSData *)sourceData {
    NSData *data = [self sha1HashDataWithData:sourceData];
    NSString *string = [self hexStringWithData:data];
    return string;
}

+ (NSString *)sha1HashStringWithString:(NSString *)sourceString {
    NSData *sourceData = [sourceString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *string = [self sha1HashStringWithData:sourceData];
    return string;
}

#pragma mark - HMAC

+ (NSData *)hmacWithAlgorithmType:(uint32_t)algorithmType
                          keyData:(NSData *)keyData
                       sourceData:(NSData *)sourceData {
    int length = 0;
    switch (algorithmType) {
        case kCCHmacAlgMD5:{
            length = CC_MD5_DIGEST_LENGTH;
            break;
        }
        case kCCHmacAlgSHA1:{
            length = CC_SHA1_DIGEST_LENGTH;
            break;
        }
        case kCCHmacAlgSHA224:{
            length = CC_SHA224_DIGEST_LENGTH;
            break;
        }
        case kCCHmacAlgSHA256:{
            length = CC_SHA256_DIGEST_LENGTH;
            break;
        }
        case kCCHmacAlgSHA384:{
            length = CC_SHA384_DIGEST_LENGTH;
            break;
        }
        case kCCHmacAlgSHA512:{
            length = CC_SHA512_DIGEST_LENGTH;
            break;
        }
        default:{
            break;
        }
    }
    if (length == 0) {
        return nil;
    }
    unsigned char *result = malloc(length);
    memset(result, 0, length);
    CCHmac(algorithmType,
           [keyData bytes],
           [keyData length],
           [sourceData bytes],
           [sourceData length],
           result);
    NSData *data = [NSData dataWithBytes:result length:length];
    free(result);
    return data;
}

+ (NSData *)hmacWithAlgorithmType:(uint32_t)algorithmType
                        keyString:(NSString *)keyString
                     sourceString:(NSString *)sourceString {
    NSData *keyData = [keyString dataUsingEncoding:NSUTF8StringEncoding];
    NSData *sourceData = [sourceString dataUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [self hmacWithAlgorithmType:algorithmType
                                       keyData:keyData
                                    sourceData:sourceData];
    return data;
}

#pragma mark - BASE64

+ (NSString *)base64EncodeWithData:(NSData *)sourceData {
    NSString *result = [sourceData base64EncodedStringWithOptions:0];
    return result;
}

+ (NSString *)base64EncodeWithString:(NSString *)sourceString {
    NSData *data = [sourceString dataUsingEncoding:NSUTF8StringEncoding];
    return [self base64EncodeWithData:data];
}

+ (NSData *)base64DecodeWithString:(NSString *)base64String {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
    return data;
}

#pragma mark - URL ENCODE/DECODE

+ (NSString *)urlEncodeWithString:(NSString *)sourceString {
    CFStringRef encodedCFString =
    CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                            (__bridge CFStringRef)sourceString,
                                            NULL,
                                            CFSTR("!*'();:@&=+$,/?%#[]"),
                                            kCFStringEncodingUTF8);
    NSString *encodedString = CFBridgingRelease(encodedCFString);
    return encodedString;
}

+ (NSString *)urlDecodeWithString:(NSString *)encodedString {
    CFStringRef sourceCFString =
    CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                            (__bridge CFStringRef)encodedString,
                                                            CFSTR("!*'();:@&=+$,/?%#[]"),
                                                            kCFStringEncodingUTF8);
    NSString *sourceString = CFBridgingRelease(sourceCFString);
    return sourceString;
}

#pragma mark - AES

+ (NSData *)aesEncryptWithKeyData:(NSData *)keyData sourceData:(NSData *)sourceData {
    if (keyData.length != kCCKeySizeAES128 &&
        keyData.length != kCCKeySizeAES192 &&
        keyData.length != kCCKeySizeAES256) {
        return nil;
    }
    
    const char *keyBytes = [keyData bytes];
    NSUInteger dataLength = [sourceData length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    memset(buffer, 0, bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES,
                                          kCCOptionPKCS7Padding|kCCOptionECBMode,
                                          keyBytes,
                                          keyData.length,
                                          NULL /* initialization vector (optional) */,
                                          [sourceData bytes],
                                          dataLength, /* input */
                                          buffer,
                                          bufferSize, /* output */
                                          &numBytesEncrypted);
    NSData *data = nil;
    if (cryptStatus == kCCSuccess) {
        data = [NSData dataWithBytes:buffer length:numBytesEncrypted];
    }
    free(buffer);
    return data;
}

+ (NSData *)aesDecryptWithKeyData:(NSData *)keyData encodedData:(NSData *)encodedData {
    if (keyData.length != kCCKeySizeAES128 &&
        keyData.length != kCCKeySizeAES192 &&
        keyData.length != kCCKeySizeAES256) {
        return nil;
    }
    
    const char *keyBytes = [keyData bytes];
    NSUInteger dataLength = [encodedData length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    memset(buffer, 0, bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES,
                                          kCCOptionPKCS7Padding|kCCOptionECBMode,
                                          keyBytes,
                                          keyData.length,
                                          NULL /* initialization vector (optional) */,
                                          [encodedData bytes],
                                          dataLength, /* input */
                                          buffer,
                                          bufferSize, /* output */
                                          &numBytesDecrypted);
    NSData *data = nil;
    if (cryptStatus == kCCSuccess) {
        data = [NSData dataWithBytes:buffer length:numBytesDecrypted];
    }
    free(buffer);
    return data;
}

#pragma mark - RSA


+ (SecKeyRef)rsaPublicKeyWithCerData:(NSData *)keyData {
    SecKeyRef publicKey = NULL;
    
    CFDataRef publicKeyDataRef = (__bridge CFDataRef)keyData;
    SecCertificateRef certificateRef = SecCertificateCreateWithData(kCFAllocatorDefault, publicKeyDataRef);
    SecPolicyRef policyRef = SecPolicyCreateBasicX509();
    SecTrustRef trustRef = NULL;
    OSStatus status = SecTrustCreateWithCertificates(certificateRef, policyRef, &trustRef);
    NSAssert(status == errSecSuccess, @"SecTrustCreateWithCertificates failed.");
    SecTrustResultType trustResult = 0;
    status = SecTrustEvaluate(trustRef, &trustResult);
    NSAssert(status == errSecSuccess, @"SecTrustEvaluate failed.");
    publicKey = SecTrustCopyPublicKey(trustRef);
    NSAssert(publicKey != NULL, @"SecTrustCopyPublicKey failed.");
    
    if (certificateRef) CFRelease(certificateRef);
    if (policyRef) CFRelease(policyRef);
    if (trustRef) CFRelease(trustRef);
    
    return publicKey;
}

+ (SecKeyRef)rsaPublicKeyWithCerPath:(NSString *)keyPath {
    NSData *data = [NSData dataWithContentsOfFile:keyPath];
    return [self rsaPublicKeyWithCerData:data];
}

+ (SecKeyRef)rsaPrivateKeyWithPassword:(NSString *)password p12KeyData:(NSData *)keyData {
    SecKeyRef privateKey = NULL;
    
    CFDataRef privateKeyDataRef = (__bridge CFDataRef)keyData;
    CFStringRef passwordRef = CFBridgingRetain(password);
    SecIdentityRef myIdentity = NULL;
    SecTrustRef myTrust = NULL;
    OSStatus status = extractIdentityAndTrust(privateKeyDataRef, passwordRef, &myIdentity, &myTrust);
    NSAssert(status == noErr, @"extractIdentityAndTrust failed.");
    SecTrustResultType trustResult = 0;
    status = SecTrustEvaluate(myTrust, &trustResult);
    NSAssert(status == errSecSuccess, @"SecTrustEvaluate failed.");
    status = SecIdentityCopyPrivateKey(myIdentity, &privateKey);
    NSAssert(status == errSecSuccess, @"SecIdentityCopyPrivateKey failed.");
    
    if (passwordRef) CFRelease(passwordRef);
    if (myIdentity) CFRelease(myIdentity);
    if (myTrust) CFRelease(myTrust);
    
    return privateKey;
}

+ (SecKeyRef)rsaPrivateKeyWithPassword:(NSString *)password p12KeyPath:(NSString *)keyPath {
    NSData *data = [NSData dataWithContentsOfFile:keyPath];
    return [self rsaPrivateKeyWithPassword:password p12KeyData:data];
}

+ (NSData *)rsaEncryptWithPublicKey:(SecKeyRef)publicKey sourceData:(NSData *)sourceData {
    size_t sourceBufferSize = [sourceData length];
    size_t publicKeyBufferSize = SecKeyGetBlockSize(publicKey);
    NSMutableData *encryptedData = [NSMutableData dataWithLength:publicKeyBufferSize];
    OSStatus sanityCheck = SecKeyEncrypt(publicKey,
                                         kSecPaddingPKCS1,
                                         (const uint8_t *)[sourceData bytes],
                                         sourceBufferSize,
                                         encryptedData.mutableBytes,
                                         &publicKeyBufferSize);
    NSAssert(sanityCheck == noErr, @"Error encrypting, OSStatus == %d.", (int)sanityCheck);
    [encryptedData setLength:publicKeyBufferSize];

    return [encryptedData copy];
}

+ (NSData *)rsaDecryptWithPrivateKey:(SecKeyRef)privateKey encodedData:(NSData *)encodedData {
    size_t privateKeyBufferSize = SecKeyGetBlockSize(privateKey);
    size_t encryptedBufferSize = [encodedData length];
    NSMutableData *decryptedData = [NSMutableData dataWithLength:encryptedBufferSize];
    OSStatus sanityCheck = SecKeyDecrypt(privateKey,
                                         kSecPaddingPKCS1,
                                         (const uint8_t *) [encodedData bytes],
                                         privateKeyBufferSize,
                                         [decryptedData mutableBytes],
                                         &encryptedBufferSize);
    NSAssert(sanityCheck == noErr, @"Error decrypting, OSStatus == %d.", (int)sanityCheck);
    [decryptedData setLength:encryptedBufferSize];

    return [decryptedData copy];
}

@end

#pragma mark - FUNCTION IMPLEMENTATION

OSStatus extractIdentityAndTrust(CFDataRef inPKCS12Data,
                                 CFStringRef password,
                                 SecIdentityRef *outIdentity,
                                 SecTrustRef *outTrust) {
    const void *keys[] = { kSecImportExportPassphrase };
    const void *values[] = { password };
    CFDictionaryRef optionsDictionary = CFDictionaryCreate(NULL, keys,
                                                           values, 1,
                                                           NULL, NULL);
    
    CFArrayRef items = NULL;
    OSStatus securityError = SecPKCS12Import(inPKCS12Data,
                                             optionsDictionary,
                                             &items);
    
    if (securityError == 0) {
        CFDictionaryRef myIdentityAndTrust = CFArrayGetValueAtIndex (items, 0);
        const void *tempIdentity = NULL;
        tempIdentity = CFDictionaryGetValue(myIdentityAndTrust, kSecImportItemIdentity);
        *outIdentity = (SecIdentityRef)tempIdentity;
        CFRetain(*outIdentity);
        const void *tempTrust = NULL;
        tempTrust = CFDictionaryGetValue (myIdentityAndTrust, kSecImportItemTrust);
        *outTrust = (SecTrustRef)tempTrust;
        CFRetain(*outTrust);
    }
    
    if (optionsDictionary) CFRelease(optionsDictionary);
    if (items) CFRelease(items);
    
    return securityError;
}
