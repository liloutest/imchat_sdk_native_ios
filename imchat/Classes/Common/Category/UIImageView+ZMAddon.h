//
//  UIImageView+ZMAddon.h
//  imchat
//
//  Created by Lilou on 2024/10/14.
//

#import <UIKit/UIKit.h>


/**
 @brief Custom Imageview， category , Enhanced image rendering
 */
@interface UIImageView (ZMAddon)

/**
 @brief 
 @param
 @return
 */
- (void)zm_setGifImageWithURL:(nullable NSString *)urlString;
- (void)zm_setImageWithURL:(nullable NSString *)urlString;
- (void)zm_setImageWithURL:(nullable NSString *)urlString placeholderImage:(nullable UIImage *)placeholder;
- (void)zm_setImageWithURL:(nullable NSString *)urlString placeholderImage:(nullable UIImage *)placeholder completion:(nullable void(^)(UIImage * _Nullable image, NSError *_Nullable error))completion;
- (void)zm_setImageWithURL:(nullable NSString *)urlString placeholderImage:(nullable UIImage *)placeholder  encryptKey:(nullable NSString *)key isVideo:(BOOL)isVideo completion:(nullable void(^)(UIImage *_Nullable image, NSError *_Nullable error))completion;
@end

