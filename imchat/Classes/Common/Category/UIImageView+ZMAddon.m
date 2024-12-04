//
//  UIImageView+ZMAddon.m
//  imchat
//
//  Created by Lilou on 2024/10/14.
//

#import "UIImageView+ZMAddon.h"
#import <SDWebImage/SDWebImage.h>
#import "ZMAESCryptor.h"
@implementation UIImageView (ZMAddon)
- (void)zm_setGifImageWithURL:(nullable NSString *)urlString {
    
}

- (void)zm_setImageWithURL:(nullable NSString *)urlString {
    [self zm_setImageWithURL:urlString placeholderImage:nil completion:nil];
}

- (void)zm_setImageWithURL:(nullable NSString *)urlString placeholderImage:(nullable UIImage *)placeholder {
    [self zm_setImageWithURL:urlString placeholderImage:placeholder completion:nil];
}

- (void)zm_setImageWithURL:(nullable NSString *)urlString placeholderImage:(nullable UIImage *)placeholder completion:(void(^)(UIImage *image, NSError *error))completion {
    [self sd_setImageWithURL:[NSURL URLWithString:urlString ? urlString : @""]
            placeholderImage:placeholder
                   completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        [ZMCommon mainExec:^{
            if (completion) {
                completion(image ? image : placeholder, error);
            }
        }];
        
    }];
}

- (void)zm_setImageWithURL:(nullable NSString *)urlString placeholderImage:(nullable UIImage *)placeholder  encryptKey:(nullable NSString *)key isVideo:(BOOL)isVideo completion:(nullable void(^)(UIImage *_Nullable image, NSError *_Nullable error))completion {
    
    // 本地文件优先取本地缓存
    if (![urlString hasPrefix:@"http"]) {
        if(isVideo) {
            [ZMCommon thumbnailFromVideoPath:urlString key:key atTime:CMTimeMakeWithSeconds(1.0, 600) completion:^(UIImage *thumbnail, NSError *error) {
                if (thumbnail) {
                    
                    self.image = thumbnail;
                    if (completion) {
                        completion(thumbnail, nil);
                    }
                    
                    
                } else {
                    if(completion){
                        completion(placeholder,nil);
                    }
                }
            }];

        }
        else {
            UIImage *img = [[SDImageCache sharedImageCache] imageFromCacheForKey:urlString];
    //        UIImage *img = [UIImage imageWithContentsOfFile:urlString] ?: placeholder;
            self.image = img ?: placeholder;
            if (completion) {
                completion(img, nil);
            }
        }

        return;
    }
    
    if (!key.length) {
        // 无密钥时走普通流程
//        UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromCacheForKey:urlString];
        [self zm_setImageWithURL:urlString placeholderImage:placeholder completion:completion];
        return;
    }
    
    // 使用密钥创建唯一的缓存key
    NSString *cacheKey = [NSString stringWithFormat:@"%@_%@", urlString, key];
    
    // 先尝试从缓存获取
    UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromCacheForKey:cacheKey];
    if (cachedImage) {
        self.image = cachedImage;
        if (completion) {
            completion(cachedImage, nil);
        }
        return;
    }
    
    // 下载并解密
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSURLSessionDataTask *downloadTask = [session dataTaskWithURL:[NSURL URLWithString:urlString ?: @""] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error || !data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(placeholder, error);
                }
            });
            return;
        }
        
        // 在后台线程进行解密
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // 解密数据

            NSData *decodeBase64Data = [[NSData alloc] initWithBase64EncodedData:data options:0];
            NSData *decryptedData = [ZMAESCryptor decryptData:decodeBase64Data key:key iv:nil];

            
            if (decryptedData) {
                UIImage *decryptedImage = [UIImage imageWithData:decryptedData];
                if([urlString.lowercaseString containsString:@"gif"]){
                    
                    UIImage *fImg = [self showGIFWithImageIO:decryptedData];
                    decryptedImage = fImg;
                }
                if (decryptedImage) {
                    // 缓存解密后的图片
                    [[SDImageCache sharedImageCache] storeImage:decryptedImage forKey:cacheKey completion:nil];
                    
                    // 主线程更新UI
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.image = decryptedImage;
                        if (completion) {
                            completion(decryptedImage ? decryptedImage : placeholder, error);
                        }
                    });
                    return;
                }
                
            }
            [ZMCommon mainExec:^{
                if (completion) {
                    completion(placeholder, error);
                }
            }];
            
        });
    }];
    [downloadTask resume];
    
    
    
    
    
//    [self sd_setImageWithURL:[NSURL URLWithString:urlString ?: @""]
//            placeholderImage:placeholder
//                   options:SDWebImageRetryFailed
//                 progress:nil
//                completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
//                    if (error || !image) {
//                        if (completion) {
//                            completion(image ? image : placeholder, error);
//                        }
//                        return;
//                    }
//                    
//                    // 在后台线程进行解密
//                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                        // 将图片转换为数据
////                        NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
//                        NSData *imageData = UIImagePNGRepresentation(image);
//                        // 解密数据
//                        NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
////                        NSArray *ivs = @[@0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0];
//                        uint8_t bytes[] = {0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0};
//                        NSData *ivs = [NSData dataWithBytes:bytes length:16];
//                        NSData *ivData = [key dataUsingEncoding:NSUTF8StringEncoding];
//                        NSData *decryptedData = [ZMAESCryptor decryptData:imageData key:keyData iv:ivs];
//                        
//                        if (decryptedData) {
//                            UIImage *decryptedImage = [UIImage imageWithData:decryptedData];
//                            if (decryptedImage) {
//                                // 缓存解密后的图片
//                                [[SDImageCache sharedImageCache] storeImage:decryptedImage forKey:cacheKey completion:nil];
//                                
//                                // 主线程更新UI
//                                dispatch_async(dispatch_get_main_queue(), ^{
//                                    self.image = decryptedImage;
//                                    if (completion) {
//                                        completion(decryptedImage ? decryptedImage : placeholder, error);
//                                    }
//                                });
//                            }
//                        }
//                    });
//                }];
}


- (UIImage *)showGIFWithImageIO:(NSData *)gifData {
    @try {
        // 创建图片源
        CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)gifData, NULL);
        if (!source) return nil;
        
        // 获取图片帧数
        size_t count = CGImageSourceGetCount(source);
        NSMutableArray *images = [NSMutableArray array];
        NSTimeInterval duration = 0.0;
        
        // 遍历所有帧
        for (size_t i = 0; i < count; i++) {
            CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
            if (!image) continue;
            
            // 获取每帧时长
            NSDictionary *properties = (__bridge_transfer NSDictionary *)CGImageSourceCopyPropertiesAtIndex(source, i, NULL);
            NSDictionary *gifProperties = properties[(NSString *)kCGImagePropertyGIFDictionary];
            NSNumber *delayTime = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
            duration += delayTime.doubleValue;
            
            // 添加到数组
            [images addObject:[UIImage imageWithCGImage:image]];
            CGImageRelease(image);
        }
        
        CFRelease(source);
        
        // 创建动画图片
        UIImage *animatedImage = [UIImage animatedImageWithImages:images duration:duration];
        
        // 显示
        return animatedImage;
    } @catch (NSException *exception) {
        return nil;
    }
}
@end
