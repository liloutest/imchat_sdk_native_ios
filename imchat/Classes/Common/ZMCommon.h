//
//  ZMCommon.h
//  imchat
//
//  Created by Lilou on 2024/10/21.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface ZMCommon : NSObject

+ (BOOL)isHttp:(NSString *)url;

+ (CGFloat)calculateHeightWithText:(NSString *)text maxWidth:(CGFloat)width font:(UIFont *)font;

+ (CGFloat)getTextWidthForLabel:(UILabel *)label;

+ (CGFloat)getTextHeightForLabel:(UILabel *)label;

+ (void)mainExec:(dispatch_block_t)block;

+ (NSString *)uuid;

+ (NSTimeInterval)zeroZoneTimestamp;
+ (NSString *)timestampToZeroZoneWithTime:(NSTimeInterval)time;

+ (NSString *)md5KeyForURL:(NSString *)urlString;

+ (CGSize)getMediaFitSize:(CGSize)size;

+ (void)thumbnailFromVideoPath:(NSString *)videoPath
                           key:(NSString *)key
                        atTime:(CMTime)time
                    completion:(void(^)(UIImage *thumbnail, NSError *error))completion;

+ (BOOL)compareTimeOverMinutes:(NSTimeInterval)timeInterval;

+ (UIImage *)createImageWithColor:(UIColor *)color size:(CGSize)size;
@end

NS_ASSUME_NONNULL_END
