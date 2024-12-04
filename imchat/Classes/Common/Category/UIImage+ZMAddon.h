//
//  UIImage+ZMAddon.h
//  imchat
//
//  Created by Lilou on 2024/10/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (ZMAddon)
+ (UIImage *)zm_imageWithName:(NSString *)name;
+ (UIImage *)compressImageToSize:(UIImage *)image;
@end

NS_ASSUME_NONNULL_END
