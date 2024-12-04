//
//  ZMAESCryptor.h
//  imchat
//
//  Created by Lilou on 2024/11/10.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h>

// 定义错误域和错误码
typedef NS_ENUM(NSInteger, ZMAESCryptorErrorCode) {
    ZMAESCryptorErrorInvalidInput = 1001,
    ZMAESCryptorErrorInvalidKeyOrIV = 1002,
    ZMAESCryptorErrorEncryptionFailed = 1003,
    ZMAESCryptorErrorDecryptionFailed = 1004,
    ZMAESCryptorErrorFileOperationFailed = 1005,
    ZMAESCryptorErrorOutOfMemory = 1006,
    ZMAESCryptorErrorUnknown = 1999
};

NS_ASSUME_NONNULL_BEGIN

@interface ZMAESCryptor : NSObject
// 字符串加解密
+ (NSString *)encrypt:(NSString *)content key:(NSString *)key iv:(NSString *)iv;
+ (NSString *)decrypt:(NSString *)content key:(NSString *)key iv:(NSString *)iv;

// 二进制数据加解密
+ (NSData *)encryptData:(NSData *)data key:(NSString *)key iv:(NSString *)iv;
+ (NSData *)decryptData:(NSData *)data key:(NSString *)key iv:(NSString *)iv;



// 文件加解密方法
+ (BOOL)encryptFile:(NSString *)inputPath
         outputPath:(NSString *)outputPath
               key:(NSData *)keyData
                iv:(NSData *)ivData
             error:(NSError **)error;

+ (BOOL)decryptFile:(NSString *)inputPath
         outputPath:(NSString *)outputPath
               key:(NSData *)keyData
                iv:(NSData *)ivData
             error:(NSError **)error;

// 大文件分块加解密方法
+ (BOOL)encryptLargeFile:(NSString *)inputPath
              outputPath:(NSString *)outputPath
                    key:(NSData *)keyData
                     iv:(NSData *)ivData
                progress:(void(^)(float progress))progressBlock
                  error:(NSError **)error;

+ (BOOL)decryptLargeFile:(NSString *)inputPath
              outputPath:(NSString *)outputPath
                    key:(NSData *)keyData
                     iv:(NSData *)ivData
                progress:(void(^)(float progress))progressBlock
                  error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
