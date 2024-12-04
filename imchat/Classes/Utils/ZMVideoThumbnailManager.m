//
//  ZMVideoThumbnailManager.m
//  imchat
//
//  Created by Lilou on 2024/10/28.
//

#import "ZMVideoThumbnailManager.h"
#import <AVFoundation/AVFoundation.h>
#import <CommonCrypto/CommonDigest.h>
@interface ZMVideoThumbnailManager ()

@property (nonatomic, strong) NSCache *memoryCache;
@property (nonatomic, copy) NSString *diskCachePath;
@property (nonatomic, strong) dispatch_queue_t ioQueue;

@end

@implementation ZMVideoThumbnailManager
+ (instancetype)shared {
    static ZMVideoThumbnailManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ZMVideoThumbnailManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        // 默认配置
        _maxMemoryCount = 100;
        _maxDiskSize = 200 * 1024 * 1024;  // 200MB
        _maxCacheAge = 7 * 24 * 60 * 60;   // 7天
        
        // 初始化内存缓存
        _memoryCache = [[NSCache alloc] init];
        _memoryCache.countLimit = _maxMemoryCount;
        
        // 初始化磁盘缓存路径
        NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        _diskCachePath = [cachePath stringByAppendingPathComponent:@"ZMVideoThumbnails"];
        
        // 创建IO队列
        _ioQueue = dispatch_queue_create("com.videothumbnail.ioqueue", DISPATCH_QUEUE_SERIAL);
        
        // 创建缓存目录
        [self createCacheDirectory];
        
        // 添加内存警告通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                               selector:@selector(clearMemoryCache)
                                                   name:UIApplicationDidReceiveMemoryWarningNotification
                                                 object:nil];
        
        // 添加进入后台通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                               selector:@selector(backgroundCleanDisk)
                                                   name:UIApplicationDidEnterBackgroundNotification
                                                 object:nil];
        
        // 启动时清理过期缓存
        [self cleanExpiredDiskCache];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public Methods

- (void)thumbnailFromVideoPath:(NSString *)videoPath
                      atTime:(CMTime)time
                  completion:(void(^)(UIImage *thumbnail, NSError *error))completion {
    
    @try {
        // 检查文件是否存在
        if (![[NSFileManager defaultManager] fileExistsAtPath:videoPath]) {
            NSError *error = [NSError errorWithDomain:@"VideoThumbnail"
                                               code:-1
                                           userInfo:@{NSLocalizedDescriptionKey: @"视频文件不存在"}];
            completion(nil, error);
            return;
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
            dispatch_async(dispatch_get_main_queue(), ^{
                if (result == AVAssetImageGeneratorSucceeded && cgImage) {
                    UIImage *thumbnail = [UIImage imageWithCGImage:cgImage];
                    completion(thumbnail, nil);
                } else {
                    completion(nil, error);
                }
            });
        }];
    } @catch (NSException *exception) {
        [SVProgressHUD showErrorWithStatus:exception.description];
    } @finally {
        
    }
    
}

- (void)getVideoThumbnail:(NSString *)thumbnail videoURL:(NSString *)videoURL completion:(void(^)(UIImage *thumbnail))completion {
    
    @autoreleasepool {
        if (!videoURL || videoURL.length == 0) {
            if (completion) completion(nil);
            return;
        }
        
        
        
        if(![videoURL containsString:@"http"]) {
            
            @try {
                [self thumbnailFromVideoPath:videoURL atTime:CMTimeMakeWithSeconds(1.0, 600) completion:^(UIImage *thumbnail, NSError *error) {
                    if (thumbnail) {
                        
                        UIImage *thumbImg = [UIImage compressImageToSize:thumbnail];
        
                        if (completion) completion(thumbImg);
                        
                        
                    } else {
                        if (completion) completion(nil);
                        [SVProgressHUD showErrorWithStatus:@"Error generating thumbnail"];
                    }
                }];
                
            } @catch (NSException *exception) {
                [SVProgressHUD showErrorWithStatus:exception.description];
            } @finally {
                
            }
            
            return;
        }
        
        
        
        NSString *cacheKey = [self cacheKeyForURL:thumbnail ?: videoURL];
        
        // 1. 检查内存缓存
        UIImage *memoryImage = [self.memoryCache objectForKey:cacheKey];
        if (memoryImage) {
            if (completion) completion(memoryImage);
            return;
        }
        
        // 2. 检查磁盘缓存
        NSString *diskPath = [self.diskCachePath stringByAppendingPathComponent:cacheKey];
        dispatch_async(self.ioQueue, ^{
            if ([[NSFileManager defaultManager] fileExistsAtPath:diskPath]) {
                NSError *error = nil;
                NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:diskPath error:&error];
                NSDate *modificationDate = attrs[NSFileModificationDate];
                
                if ([[NSDate date] timeIntervalSinceDate:modificationDate] < self.maxCacheAge) {
                    UIImage *diskImage = [UIImage imageWithContentsOfFile:diskPath];
                    if (diskImage) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.memoryCache setObject:diskImage forKey:cacheKey];
                            if (completion) completion(diskImage);
                        });
                        return;
                    }
                }
            }
            
            // 3. 从网络获取
            [self generateThumbnailFromURL:videoURL cacheKey:cacheKey completion:completion];
        });
    }
    
    
}

#pragma mark - Private Methods

- (void)generateThumbnailFromURL:(NSString *)videoURL cacheKey:(NSString *)cacheKey completion:(void(^)(UIImage *))completion {
    @autoreleasepool {
        NSURL *url = [NSURL URLWithString:videoURL];
        AVAsset *asset = [AVAsset assetWithURL:url];
        AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        imageGenerator.appliesPreferredTrackTransform = YES;
        
        CMTime time = CMTimeMake(0, 1);
        
        [imageGenerator generateCGImagesAsynchronouslyForTimes:@[[NSValue valueWithCMTime:time]]
                                           completionHandler:^(CMTime requestedTime,
                                                             CGImageRef imageRef,
                                                             CMTime actualTime,
                                                             AVAssetImageGeneratorResult result,
                                                             NSError *error) {
            if (result == AVAssetImageGeneratorSucceeded) {
                UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
                [self cacheThumbnail:thumbnail forKey:cacheKey];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) completion(thumbnail);
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) completion(nil);
                });
            }
        }];
    }
    
}

- (void)cacheThumbnail:(UIImage *)thumbnail forKey:(NSString *)key {
    if (!thumbnail || !key) return;
    
    // 保存到内存缓存
    [self.memoryCache setObject:thumbnail forKey:key];
    
    // 保存到磁盘缓存
    dispatch_async(self.ioQueue, ^{
        NSString *diskPath = [self.diskCachePath stringByAppendingPathComponent:key];
        NSData *imageData = UIImageJPEGRepresentation(thumbnail, 0.8);
        [imageData writeToFile:diskPath atomically:YES];
        
        // 检查缓存大小
        [self checkDiskSize];
    });
}

#pragma mark - Cache Management

- (void)clearMemoryCache {
    [self.memoryCache removeAllObjects];
}

- (void)clearDiskCache {
    dispatch_async(self.ioQueue, ^{
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:self.diskCachePath error:&error];
        [self createCacheDirectory];
    });
}

- (void)clearAllCache {
    [self clearMemoryCache];
    [self clearDiskCache];
}

- (void)cleanExpiredDiskCache {
    dispatch_async(self.ioQueue, ^{
        NSError *error = nil;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *contents = [fileManager contentsOfDirectoryAtPath:self.diskCachePath error:&error];
        
        NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-self.maxCacheAge];
        
        for (NSString *fileName in contents) {
            NSString *filePath = [self.diskCachePath stringByAppendingPathComponent:fileName];
            NSDictionary *attrs = [fileManager attributesOfItemAtPath:filePath error:nil];
            NSDate *modificationDate = attrs[NSFileModificationDate];
            
            if ([[modificationDate laterDate:expirationDate] isEqualToDate:expirationDate]) {
                [fileManager removeItemAtPath:filePath error:nil];
            }
        }
    });
}

- (void)checkDiskSize {
    NSUInteger size = [self getDiskCacheSize];
    if (size > self.maxDiskSize) {
        NSError *error = nil;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *contents = [fileManager contentsOfDirectoryAtPath:self.diskCachePath error:&error];
        
        // 按修改时间排序
        NSArray *sortedFiles = [contents sortedArrayUsingComparator:^NSComparisonResult(NSString *path1, NSString *path2) {
            NSString *fullPath1 = [self.diskCachePath stringByAppendingPathComponent:path1];
            NSString *fullPath2 = [self.diskCachePath stringByAppendingPathComponent:path2];
            
            NSDictionary *attrs1 = [fileManager attributesOfItemAtPath:fullPath1 error:nil];
            NSDictionary *attrs2 = [fileManager attributesOfItemAtPath:fullPath2 error:nil];
            
            NSDate *date1 = attrs1[NSFileModificationDate];
            NSDate *date2 = attrs2[NSFileModificationDate];
            
            return [date1 compare:date2];
        }];
        
        // 删除最旧的文件，直到大小符合要求
        for (NSString *fileName in sortedFiles) {
            if ([self getDiskCacheSize] <= self.maxDiskSize) {
                break;
            }
            
            NSString *filePath = [self.diskCachePath stringByAppendingPathComponent:fileName];
            [fileManager removeItemAtPath:filePath error:nil];
        }
    }
}

- (void)backgroundCleanDisk {
    UIApplication *application = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    [self cleanExpiredDiskCache];
    [self checkDiskSize];
    
    [application endBackgroundTask:bgTask];
    bgTask = UIBackgroundTaskInvalid;
}

#pragma mark - Helper Methods

- (NSString *)cacheKeyForURL:(NSString *)urlString {
    const char *str = [urlString UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), result);
    
    NSMutableString *md5String = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [md5String appendFormat:@"%02x", result[i]];
    }
    return md5String;
}

- (void)createCacheDirectory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:self.diskCachePath]) {
        [fileManager createDirectoryAtPath:self.diskCachePath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    }
}

- (NSUInteger)getDiskCacheSize {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:self.diskCachePath error:nil];
    NSUInteger size = 0;
    
    for (NSString *fileName in contents) {
        NSString *filePath = [self.diskCachePath stringByAppendingPathComponent:fileName];
        NSDictionary *attrs = [fileManager attributesOfItemAtPath:filePath error:nil];
        size += [attrs fileSize];
    }
    
    return size;
}
@end
