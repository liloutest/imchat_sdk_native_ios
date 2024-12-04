//
//  ZMCommon.m
//  imchat
//
//  Created by Lilou on 2024/10/21.
//

#import "ZMCommon.h"
//#import <CommonCrypto/CommonKeyDerivation.h>
#import <CommonCrypto/CommonDigest.h>
#import "SDImageCache.h"

@implementation ZMCommon

+ (BOOL)isHttp:(NSString *)url {
    return [url hasPrefix:@"http"];
}

+ (CGFloat)calculateHeightWithText:(NSString *)text maxWidth:(CGFloat)width font:(UIFont *)font  {
    // 创建临时 label 进行计算
    UILabel *tempLabel = [[UILabel alloc] init];
    tempLabel.numberOfLines = 0;
    tempLabel.textAlignment = NSTextAlignmentLeft;
    tempLabel.lineBreakMode = NSLineBreakByCharWrapping;
    tempLabel.font = font;
    tempLabel.text = text;
    
    // 设置固定宽度
    CGSize maxSize = CGSizeMake(width, CGFLOAT_MAX);
    
    // 使用 systemLayoutSizeFittingSize 计算
    CGSize size = [tempLabel systemLayoutSizeFittingSize:maxSize];
    return ceil(size.height) + 4.0;
}

+ (CGFloat)getTextWidthForLabel:(UILabel *)label {
    // 获取label的文本和字体
    NSString *text = label.text;
    UIFont *font = label.font;

    // 设置一个足够大的宽度限制
    CGSize maxSize = CGSizeMake(CGFLOAT_MAX, label.frame.size.height);

    // 计算文本的实际尺寸
//    CGSize textSize = [text boundingRectWithSize:maxSize
//                                         options:NSStringDrawingUsesLineFragmentOrigin
//                                      attributes:@{NSFontAttributeName: font}
//                                         context:nil].size;
    
    CGSize textSize = [label sizeThatFits:maxSize];

    // 返回文本的宽度
    return textSize.width;
}

+ (CGFloat)getTextHeightForLabel:(UILabel *)label {
    // 获取label的文本和字体
    NSString *text = label.text;
    UIFont *font = label.font;


    CGSize maxSize = CGSizeMake(label.frame.size.width,CGFLOAT_MAX);

    // 计算文本的实际尺寸
//    CGSize textSize = [text boundingRectWithSize:maxSize
//                                         options:NSStringDrawingUsesLineFragmentOrigin
//                                      attributes:@{NSFontAttributeName: font}
//                                         context:nil].size;
    
    CGSize textSize = [label sizeThatFits:maxSize];


    return textSize.height;
}

+ (void)mainExec:(dispatch_block_t)block
{
    if ([NSThread isMainThread]) {
        block();
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            if(block){
                block();
            }
        });
    }
    
}

+ (NSString *)uuid{
    // 生成一个新的 UUID
    NSUUID *uuid = [NSUUID UUID];
    
    // 转换为字符串格式
    NSString *uuidString = [uuid UUIDString];
    
    // 打印 UUID
    NSLog(@"生成的 UUID: %@", uuidString);
    
    return uuidString;
}

+ (NSTimeInterval)zeroZoneTimestamp {
    NSTimeInterval time = [NSDate now].timeIntervalSince1970 * 1000;
    return time;
    
    
    // 获取更精确的毫秒级时间
//    uint64_t absTime = mach_absolute_time();
//    mach_timebase_info_data_t timebase;
//    mach_timebase_info(&timebase);
//    uint64_t nanos = absTime * timebase.numer / timebase.denom;
//    uint64_t millis = nanos / NSEC_PER_MSEC;
}

+ (NSString *)timestampToZeroZoneWithTime:(NSTimeInterval)time {

    // 创建 NSDate 对象
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time / 1000];
    
    // 创建 NSDateFormatter 对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    // 设置地区
    NSLocale *locale = [NSLocale currentLocale];
//    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_Hans_CN"]; // 例如：简体中文 - 中国
    [dateFormatter setLocale:locale];
    
    // 设置时区
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
//    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"]; // 设置为上海时区
    [dateFormatter setTimeZone:timeZone];
    
    
    // 设置日期格式
    [dateFormatter setDateFormat:[ZMCommon isToday:date] ? kZMTime_HHMM : kZMTime_yyyyMMddHHMM]; // 自定义格式
    
    // 格式化日期
    NSString *formattedDate = [dateFormatter stringFromDate:date];
    
    
    // 打印结果
//    NSLog(@"Formatted Date: %@", formattedDate);
    return formattedDate;
}

+ (BOOL)isToday:(NSDate *)date {
    // 获取当前日期
    NSDate *currentDate = [NSDate date];
    
    // 获取当前日期的年、月、日
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *currentComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                                      fromDate:currentDate];
    
    // 获取时间戳对应的日期的年、月、日
    NSDateComponents *timestampComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                                        fromDate:date];
    
    // 比较当前日期和时间戳对应的日期是否相同
    return (currentComponents.year == timestampComponents.year) &&
    (currentComponents.month == timestampComponents.month) &&
    (currentComponents.day == timestampComponents.day);
}


+ (NSString *)md5KeyForURL:(NSString *)urlString {
    const char *str = [urlString UTF8String] ?: "";
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), result);
    
    NSMutableString *md5String = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [md5String appendFormat:@"%02x", result[i]];
    }
    return md5String;
}

+ (CGSize)getMediaFitSize:(CGSize)size {
    CGFloat imgHeight = size.height;
    CGFloat imgWidth = size.width;
    CGFloat rate = imgHeight / imgWidth;
    // 最大宽度， 屏幕一半
    CGFloat maxWidth = SCREEN_WIDTH / 2;
    // 等比例适应
    CGFloat maxHeight = maxWidth * rate;
    if(imgWidth > maxWidth){
        imgWidth = maxWidth;
    }
    if(imgHeight > maxHeight){
        imgHeight = maxHeight;
    }
    return CGSizeMake(imgWidth, imgHeight);
}



#pragma mark - Decrypt

//+(NSData*)aesDecryptCBC(NSString *key, NSString *iv, NSData *cipherText) {
//    // 1. 将密钥和IV转换为 NSData
//    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
//    NSData *ivData = [iv dataUsingEncoding:NSUTF8StringEncoding];
//    
//    // 2. 创建一个缓冲区来存储解密结果
//    size_t bufferSize = cipherText.length + kCCBlockSizeAES128;
//    void *buffer = malloc(bufferSize);
//    
//    size_t numBytesDecrypted = 0;
//    
//    // 3. 调用 CommonCrypto 进行 AES 解密
//    CCCryptorStatus status = CCCrypt(kCCDecrypt,
//                                      kCCAlgorithmAES,
//                                      kCCOptionPKCS7Padding,
//                                      keyData.bytes,
//                                      kCCKeySizeAES128, // 128 位密钥长度
//                                      ivData.bytes,
//                                      cipherText.bytes,
//                                      cipherText.length,
//                                      buffer,
//                                      bufferSize,
//                                      &numBytesDecrypted);
//    
//    if (status == kCCSuccess) {
//        // 成功解密，返回解密结果
//        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted freeWhenDone:YES];
//    } else {
//        // 解密失败，返回 nil
//        free(buffer);
//        return nil;
//    }
//}



+ (void)thumbnailFromVideoPath:(NSString *)videoPath
                           key:(NSString *)key
                      atTime:(CMTime)time
                  completion:(void(^)(UIImage *thumbnail, NSError *error))completion {
    
    @try {
        // 没有路径返回
        if(!videoPath) {
            if (completion) {
                completion(nil, nil);
            }
            return;
        }
        
        NSString *keyPath = [NSString stringWithFormat:@"%@.jpg",[NSString stringWithFormat:@"img_thumbnail_%@",[videoPath stringByDeletingPathExtension]]];
        // 先尝试从缓存获取
        UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromCacheForKey:keyPath];
        if (cachedImage) {
            
            if (completion) {
                completion(cachedImage, nil);
            }
            return;
        }
        else {
            NSString *cacheKey = [NSString stringWithFormat:@"%@%@", videoPath, key.length > 0 ? [NSString stringWithFormat:@"_%@",key] : @""];
            
            // 先尝试从缓存获取
            UIImage *httpCachedImage = [[SDImageCache sharedImageCache] imageFromCacheForKey:cacheKey];
            if (httpCachedImage) {
                if (completion) {
                    completion(httpCachedImage, nil);
                }
                return;
            }
        }
        
        // 检查文件是否存在
        if(![videoPath hasPrefix:@"http"]){
            if (![[NSFileManager defaultManager] fileExistsAtPath:[[ZMCacheManager sharedManager] getSandboxRealPathWithFileName:[videoPath lastPathComponent]]]) {
                NSError *error = [NSError errorWithDomain:@"VideoThumbnail"
                                                   code:-1
                                               userInfo:@{NSLocalizedDescriptionKey: @"视频文件不存在"}];
                completion(nil, error);
                return;
            }
        }
        
        
        NSURL *url = [NSURL fileURLWithPath:videoPath isDirectory:NO];
        NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey: @YES};
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:options];
        
        if (!asset) {
            NSError *error = [NSError errorWithDomain:@"VideoThumbnail"
                                               code:-2
                                           userInfo:@{NSLocalizedDescriptionKey: @"无法创建 AVAsset"}];
            completion(nil, error);
            return;
        }
        
        AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        generator.maximumSize = CGSizeMake(800, 800);
        generator.requestedTimeToleranceBefore = kCMTimeZero;
        generator.requestedTimeToleranceAfter = kCMTimeZero;
        generator.appliesPreferredTrackTransform = YES;
        
        [generator generateCGImagesAsynchronouslyForTimes:@[[NSValue valueWithCMTime:time]]
                                      completionHandler:^(CMTime requestedTime,
                                                        CGImageRef cgImage,
                                                        CMTime actualTime,
                                                        AVAssetImageGeneratorResult result,
                                                        NSError *error) {
            if(cgImage){
                CGImageRetain(cgImage);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                

                @try {
                    if (result == AVAssetImageGeneratorSucceeded && cgImage) {
                        
                        UIImage *thumbnail = [UIImage imageWithCGImage:cgImage];
                        UIImage *thumbImg = [UIImage compressImageToSize:thumbnail];
                        CGImageRelease(cgImage);
                        [[SDImageCache sharedImageCache] storeImage:thumbnail forKey:keyPath completion:^{
                            NSString *cachePath = [[SDImageCache sharedImageCache] cachePathForKey:keyPath];
                            if(cachePath){
                                completion(thumbImg, nil);
                            }
                            
                            
                        }];
                        
                    } else {
                        completion(nil, error);
                    }
                } @catch (NSException *exception) {
                    [SVProgressHUD showErrorWithStatus:exception.description];
                    if(completion){
                        completion(nil, error);
                    }
                }
                
            });
        }];
    } @catch (NSException *exception) {
        [SVProgressHUD showErrorWithStatus:exception.description];
    } @finally {
        
    }
    
}


+ (BOOL)compareTimeOverMinutes:(NSTimeInterval)timeInterval {
    if(timeInterval == 0)return NO;
    NSTimeInterval nowTime = [ZMCommon zeroZoneTimestamp];
    NSInteger minus = ((nowTime - timeInterval) / 1000) / 60;
    if(minus > 0 && [ZMMessageManager sharedInstance].timeoutConfigModel && [ZMMessageManager sharedInstance].timeoutConfigModel.isOpen) {
        return minus >= [ZMMessageManager sharedInstance].timeoutConfigModel.timeout;
    }
    return NO;
}

// 添加这个新方法来创建纯色图片
+ (UIImage *)createImageWithColor:(UIColor *)color size:(CGSize)size {
    if(size.width == 0 || size.height == 0) return nil;
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:size.height / kW(4)];
    [color setFill];
    [roundedRect fill];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end
