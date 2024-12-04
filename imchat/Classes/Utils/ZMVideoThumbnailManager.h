//
//  ZMVideoThumbnailManager.h
//  imchat
//
//  Created by Lilou on 2024/10/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZMVideoThumbnailManager : NSObject
@property (nonatomic, assign) NSUInteger maxMemoryCount;      // 内存最大缓存数量
@property (nonatomic, assign) NSUInteger maxDiskSize;         // 磁盘最大缓存大小（bytes）
@property (nonatomic, assign) NSTimeInterval maxCacheAge;     // 缓存最大时间（秒）

+ (instancetype)shared;
- (void)getVideoThumbnail:(NSString *)thumbnail videoURL:(NSString *)videoURL completion:(void(^)(UIImage *thumbnail))completion;
- (void)clearMemoryCache;
- (void)clearDiskCache;
- (void)clearAllCache;
- (NSUInteger)getDiskCacheSize;
@end

NS_ASSUME_NONNULL_END
