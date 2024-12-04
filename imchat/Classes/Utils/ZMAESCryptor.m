//
//  ZMAESCryptor.m
//  imchat
//
//  Created by Lilou on 2024/11/10.
//

#import "ZMAESCryptor.h"
 
@implementation ZMAESCryptor
#pragma mark - Public Methods for String

+ (NSString *)encrypt:(NSString *)content key:(NSString *)key iv:(NSString *)iv {
    NSData *contentData = [content dataUsingEncoding:NSUTF8StringEncoding];
//    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
//    NSData *ivData = [iv dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData *encryptedData = [self encryptData:contentData key:key iv:iv];
    return [self base64EncodeData:encryptedData];
}

+ (NSString *)decrypt:(NSString *)content key:(NSString *)key iv:(NSString *)iv {
    NSData *contentData = [self base64DecodeString:content];
//    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
//    NSData *ivData = [iv dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData *decryptedData = [self decryptData:contentData key:key iv:iv];
    if (decryptedData) {
        return [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
    }
    return nil;
}

#pragma mark - Public Methods for Binary Data

+ (NSData *)encryptData:(NSData *)data key:(NSString *)key iv:(NSString *)iv {
    return [self AES256Operation:kCCEncrypt data:data key:key iv:iv];
}

+ (NSData *)decryptData:(NSData *)data key:(NSString *)key iv:(NSString *)iv {
    return [self AES256Operation:kCCDecrypt data:data key:key iv:iv];
}


#pragma mark - Private Methods

// AES 加解密核心操作
+ (NSData *)AES256Operation:(CCOperation)operation
                      data:(NSData *)data
                       key:(NSString *)key
                        iv:(NSString *)iv {
    
    @try {
        if (!data || !key) return nil;
        
        NSData *keyStrToData = [key dataUsingEncoding:NSUTF8StringEncoding];
        NSData *ivStrToData = [NSData data];
        if(!iv) {
            uint8_t bytes[16] = {0};
            ivStrToData = [NSData dataWithBytes:bytes length:sizeof(bytes)];
        }
        else{
            ivStrToData = [iv dataUsingEncoding:NSUTF8StringEncoding];
        }

        
        // 标准化密钥和IV长度
        NSMutableData *keyData = [[NSMutableData alloc] initWithData:keyStrToData];
        NSMutableData *ivData = [[NSMutableData alloc] initWithData:ivStrToData];
        
        if (keyData.length < kCCKeySizeAES256) {
            [keyData increaseLengthBy:kCCKeySizeAES256 - keyData.length];
        } else if (keyData.length > kCCKeySizeAES256) {
            keyData.length = kCCKeySizeAES256;
        }
        
        if (ivData.length < kCCBlockSizeAES128) {
            [ivData increaseLengthBy:kCCBlockSizeAES128 - ivData.length];
        } else if (ivData.length > kCCBlockSizeAES128) {
            ivData.length = kCCBlockSizeAES128;
        }
        
        // 设置输出缓冲区
        size_t bufferSize = data.length + kCCBlockSizeAES128;
        void *buffer = malloc(bufferSize);
        if (!buffer) return nil;
        
        size_t numBytesProcessed = 0;
        CCCryptorStatus cryptStatus = CCCrypt(operation,
                                            kCCAlgorithmAES,
                                            kCCOptionPKCS7Padding,
                                            keyData.bytes,
                                            kCCKeySizeAES256 ,
                                            ivData.bytes,
                                            data.bytes,
                                            data.length,
                                            buffer,
                                            bufferSize,
                                            &numBytesProcessed);
        
        if (cryptStatus == kCCSuccess) {
            NSData *originDeData = [NSData dataWithBytesNoCopy:buffer
                                                        length:numBytesProcessed
                                                  freeWhenDone:YES];
            
            return originDeData;
        }
        
        free(buffer);
        return nil;
    } @catch (NSException *exception) {
        [SVProgressHUD showErrorWithStatus:exception.description];
    }
    
    return nil;
}

+ (NSData *)removePaddingFromDecryptedData:(NSData *)data {
    NSUInteger dataLength = data.length;
    if (dataLength == 0) {
        return data;
    }
    
    const uint8_t *bytes = data.bytes;
    // 获取填充字节的值（PKCS7 填充方式的最后一个字节表示填充的字节数）
    uint8_t paddingByte = bytes[dataLength - 1];
    
    if (paddingByte > 0 && paddingByte <= kCCBlockSizeAES128) {
        return [data subdataWithRange:NSMakeRange(0, dataLength - paddingByte)];
    }
    
    return data; // 如果没有填充或填充字节无效，返回原数据
}


#pragma mark - Utility Methods

// Base64 编码
+ (NSString *)base64EncodeData:(NSData *)data {
    return [data base64EncodedStringWithOptions:0];
}

// Base64 解码
+ (NSData *)base64DecodeString:(NSString *)string {
    return [[NSData alloc] initWithBase64EncodedString:string options:0];
}

// 十六进制字符串转NSData
+ (NSData *)dataFromHexString:(NSString *)hexString {
    if (!hexString) return nil;
    
    const char *chars = [hexString UTF8String];
    int i = 0, len = (int)hexString.length;
    
    NSMutableData *data = [NSMutableData dataWithCapacity:len / 2];
    char byteChars[3] = {'\0','\0','\0'};
    unsigned long wholeByte;
    
    while (i < len) {
        byteChars[0] = chars[i++];
        byteChars[1] = chars[i++];
        wholeByte = strtoul(byteChars, NULL, 16);
        [data appendBytes:&wholeByte length:1];
    }
    
    return data;
}

// NSData转十六进制字符串
+ (NSString *)hexStringFromData:(NSData *)data {
    if (!data) return nil;
    
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:data.length * 2];
    const unsigned char *bytes = data.bytes;
    for (NSInteger i = 0; i < data.length; i++) {
        [string appendFormat:@"%02x", bytes[i]];
    }
    return string;
}

+ (NSData *)stringToHexData:(NSString *)string {
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    NSMutableData *data = [[NSMutableData alloc] init];
    
    for (int i = 0; i < [myD length]; i++) {
        [data appendBytes:&bytes[i] length:1];
    }
    return data;
}










#pragma mark - File Encryption/Decryption

+ (BOOL)encryptFile:(NSString *)inputPath
         outputPath:(NSString *)outputPath
               key:(NSData *)keyData
                iv:(NSData *)ivData
             error:(NSError **)error {
    
    // 验证输入参数
    if (![self validateInputPath:inputPath outputPath:outputPath key:keyData iv:ivData error:error]) {
        return NO;
    }
    
    // 读取文件数据
    NSData *fileData = [NSData dataWithContentsOfFile:inputPath options:NSDataReadingMappedIfSafe error:error];
    if (!fileData) {
        if (error) {
            *error = [self errorWithCode:ZMAESCryptorErrorFileOperationFailed
                              description:@"无法读取输入文件"];
        }
        return NO;
    }
    
    // 加密数据
    NSData *encryptedData = [self encryptData:fileData key:keyData iv:ivData];
    if (!encryptedData) {
        if (error) {
            *error = [self errorWithCode:ZMAESCryptorErrorEncryptionFailed
                              description:@"加密失败"];
        }
        return NO;
    }
    
    // 写入文件
    BOOL success = [encryptedData writeToFile:outputPath atomically:YES];
    if (!success && error) {
        *error = [self errorWithCode:ZMAESCryptorErrorFileOperationFailed
                          description:@"无法写入输出文件"];
    }
    
    return success;
}

+ (BOOL)decryptFile:(NSString *)inputPath
         outputPath:(NSString *)outputPath
               key:(NSData *)keyData
                iv:(NSData *)ivData
             error:(NSError **)error {
    
    // 验证输入参数
    if (![self validateInputPath:inputPath outputPath:outputPath key:keyData iv:ivData error:error]) {
        return NO;
    }
    
    // 读取加密文件数据
    NSData *encryptedData = [NSData dataWithContentsOfFile:inputPath options:NSDataReadingMappedIfSafe error:error];
    if (!encryptedData) {
        if (error) {
            *error = [self errorWithCode:ZMAESCryptorErrorFileOperationFailed
                              description:@"无法读取加密文件"];
        }
        return NO;
    }
    
    // 解密数据
    NSData *decryptedData = [self decryptData:encryptedData key:keyData iv:ivData];
    if (!decryptedData) {
        if (error) {
            *error = [self errorWithCode:ZMAESCryptorErrorDecryptionFailed
                              description:@"解密失败"];
        }
        return NO;
    }
    
    // 写入解密后的文件
    BOOL success = [decryptedData writeToFile:outputPath atomically:YES];
    if (!success && error) {
        *error = [self errorWithCode:ZMAESCryptorErrorFileOperationFailed
                          description:@"无法写入解密文件"];
    }
    
    return success;
}

#pragma mark - Large File Processing

+ (BOOL)encryptLargeFile:(NSString *)inputPath
              outputPath:(NSString *)outputPath
                    key:(NSData *)keyData
                     iv:(NSData *)ivData
                progress:(void(^)(float progress))progressBlock
                  error:(NSError **)error {
    
    // 验证输入参数
    if (![self validateInputPath:inputPath outputPath:outputPath key:keyData iv:ivData error:error]) {
        return NO;
    }
    
    // 获取文件大小
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:inputPath error:error];
    if (!attributes) {
        if (error) {
            *error = [self errorWithCode:ZMAESCryptorErrorFileOperationFailed
                              description:@"无法获取文件信息"];
        }
        return NO;
    }
    
    unsigned long long fileSize = [attributes fileSize];
    
    // 创建文件句柄
    NSFileHandle *inputHandle = [NSFileHandle fileHandleForReadingAtPath:inputPath];
    if (!inputHandle) {
        if (error) {
            *error = [self errorWithCode:ZMAESCryptorErrorFileOperationFailed
                              description:@"无法打开输入文件"];
        }
        return NO;
    }
    
    // 创建输出文件
    [[NSFileManager defaultManager] createFileAtPath:outputPath contents:nil attributes:nil];
    NSFileHandle *outputHandle = [NSFileHandle fileHandleForWritingAtPath:outputPath];
    if (!outputHandle) {
        [inputHandle closeFile];
        if (error) {
            *error = [self errorWithCode:ZMAESCryptorErrorFileOperationFailed
                              description:@"无法创建输出文件"];
        }
        return NO;
    }
    
    BOOL success = YES;
    const NSInteger blockSize = 1024 * 1024; // 1MB blocks
    unsigned long long processedSize = 0;
    
    @try {
        while (YES) {
            @autoreleasepool {
                // 读取数据块
                NSData *block = [inputHandle readDataOfLength:blockSize];
                if (block.length == 0) break;
                
                // 加密数据块
                NSData *encryptedBlock = [self encryptData:block key:keyData iv:ivData];
                if (!encryptedBlock) {
                    if (error) {
                        *error = [self errorWithCode:ZMAESCryptorErrorEncryptionFailed
                                          description:@"数据块加密失败"];
                    }
                    success = NO;
                    break;
                }
                
                // 写入加密数据
                [outputHandle writeData:encryptedBlock];
                
                // 更新进度
                processedSize += block.length;
                if (progressBlock) {
                    float progress = (float)processedSize / fileSize;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        progressBlock(progress);
                    });
                }
            }
        }
    }
    @catch (NSException *exception) {
        success = NO;
        if (error) {
            *error = [self errorWithCode:ZMAESCryptorErrorUnknown
                              description:exception.description];
        }
    }
    @finally {
        [inputHandle closeFile];
        [outputHandle closeFile];
    }
    
    // 如果失败则删除输出文件
    if (!success) {
        [[NSFileManager defaultManager] removeItemAtPath:outputPath error:nil];
    }
    
    return success;
}

+ (BOOL)decryptLargeFile:(NSString *)inputPath
              outputPath:(NSString *)outputPath
                    key:(NSData *)keyData
                     iv:(NSData *)ivData
                progress:(void(^)(float progress))progressBlock
                  error:(NSError **)error {
    
    // 实现类似 encryptLargeFile 的逻辑，但使用解密操作
    // ... 类似的实现，只是将加密改为解密
    return YES;
}

#pragma mark - Validation Methods

+ (BOOL)validateInputPath:(NSString *)inputPath
              outputPath:(NSString *)outputPath
                    key:(NSData *)keyData
                     iv:(NSData *)ivData
                  error:(NSError **)error {
    
    // 检查路径
    if (!inputPath.length || !outputPath.length) {
        if (error) {
            *error = [self errorWithCode:ZMAESCryptorErrorInvalidInput
                              description:@"无效的文件路径"];
        }
        return NO;
    }
    
    // 检查输入文件是否存在
    if (![[NSFileManager defaultManager] fileExistsAtPath:inputPath]) {
        if (error) {
            *error = [self errorWithCode:ZMAESCryptorErrorFileOperationFailed
                              description:@"输入文件不存在"];
        }
        return NO;
    }
    
    // 检查密钥和IV
    if (!keyData || keyData.length != kCCKeySizeAES128 ||
        !ivData || ivData.length != kCCBlockSizeAES128) {
        if (error) {
            *error = [self errorWithCode:ZMAESCryptorErrorInvalidKeyOrIV
                              description:@"无效的密钥或IV"];
        }
        return NO;
    }
    
    return YES;
}

#pragma mark - Error Handling

+ (NSError *)errorWithCode:(ZMAESCryptorErrorCode)code description:(NSString *)description {
    return [NSError errorWithDomain:@"com.zmaescryptor.error"
                             code:code
                         userInfo:@{NSLocalizedDescriptionKey: description}];
}




@end


/**
 
 
 // 1. 二进制数据加密
 NSData *originalData = [@"Hello World" dataUsingEncoding:NSUTF8StringEncoding];
 NSString *key = @"1234567890123456";
 NSString *iv = @"1234567890123456";

 NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
 NSData *ivData = [iv dataUsingEncoding:NSUTF8StringEncoding];

 // 加密
 NSData *encryptedData = [AESCryptor encryptData:originalData key:keyData iv:ivData];

 // 解密
 NSData *decryptedData = [AESCryptor decryptData:encryptedData key:keyData iv:ivData];

 // 2. 使用十六进制密钥加密二进制数据
 NSString *hexKey = @"31323334353637383930313233343536";
 NSString *hexIV = @"31323334353637383930313233343536";

 // 加密
 NSData *encryptedDataWithHex = [AESCryptor encryptData:originalData
                                               hexKey:hexKey
                                                hexIV:hexIV];

 // 解密
 NSData *decryptedDataWithHex = [AESCryptor decryptData:encryptedDataWithHex
                                               hexKey:hexKey
                                                hexIV:hexIV];

 // 3. 文件加密示例
 - (void)encryptFile:(NSString *)inputPath outputPath:(NSString *)outputPath {
     NSData *fileData = [NSData dataWithContentsOfFile:inputPath];
     if (!fileData) {
         NSLog(@"读取文件失败");
         return;
     }
     
     NSString *key = @"1234567890123456";
     NSString *iv = @"1234567890123456";
     
     NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
     NSData *ivData = [iv dataUsingEncoding:NSUTF8StringEncoding];
     
     NSData *encryptedData = [AESCryptor encryptData:fileData key:keyData iv:ivData];
     
     if (encryptedData) {
         BOOL success = [encryptedData writeToFile:outputPath atomically:YES];
         NSLog(@"文件加密%@", success ? @"成功" : @"失败");
     }
 }

 // 4. 大文件分块加密示例
 - (void)encryptLargeFile:(NSString *)inputPath outputPath:(NSString *)outputPath {
     NSFileHandle *inputHandle = [NSFileHandle fileHandleForReadingAtPath:inputPath];
     NSFileHandle *outputHandle = [NSFileHandle fileHandleForWritingAtPath:outputPath];
     
     if (!inputHandle || !outputHandle) {
         NSLog(@"打开文件失败");
         return;
     }
     
     NSString *key = @"1234567890123456";
     NSString *iv = @"1234567890123456";
     
     NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
     NSData *ivData = [iv dataUsingEncoding:NSUTF8StringEncoding];
     
     const NSInteger blockSize = 1024 * 1024; // 1MB blocks
     
     while (YES) {
         @autoreleasepool {
             NSData *block = [inputHandle readDataOfLength:blockSize];
             if (block.length == 0) break;
             
             NSData *encryptedBlock = [AESCryptor encryptData:block key:keyData iv:ivData];
             if (encryptedBlock) {
                 [outputHandle writeData:encryptedBlock];
             }
         }
     }
     
     [inputHandle closeFile];
     [outputHandle closeFile];
 }
 
 
 */
