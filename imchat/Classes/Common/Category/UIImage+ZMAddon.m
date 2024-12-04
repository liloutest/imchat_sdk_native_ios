//
//  UIImage+ZMAddon.m
//  imchat
//
//  Created by Lilou on 2024/10/17.
//

#import "UIImage+ZMAddon.h"

@implementation UIImage (ZMAddon)
+ (UIImage *)zm_imageWithName:(NSString *)name
{
    NSString *bundlePath = [[NSBundle bundleForClass:[ZMApis class]] pathForResource:@"imchat" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    UIImage *img = [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
    return img;
}

+ (UIImage *)compressImageToSize:(UIImage *)image {
    // 计算图片的宽高比例
    if(!image)return nil;
    
    CGFloat imgHeight = image.size.height;
    CGFloat imgWidth = image.size.width;
    CGFloat rate = imgHeight / imgWidth;
    CGFloat maxWidth = SCREEN_WIDTH / 2;
    CGFloat maxHeight = maxWidth * rate;
    if(imgWidth > maxWidth){
        imgWidth = maxWidth;
    }
    if(imgHeight > maxHeight){
        imgHeight = maxHeight;
    }
    
    
//    CGFloat aspectRatio = image.size.width / image.size.height;
//    
//    CGFloat targetWidth = maxWidth;
//    CGFloat targetHeight = maxHeight;
    
    // 如果宽高比例大于1，说明图片较宽
//    if (image.size.width > image.size.height) {
//        if (image.size.width > maxWidth) {
//            targetWidth = maxWidth;
//            targetHeight = maxWidth / aspectRatio;
//        }
//    } else {
//        if (image.size.height > maxHeight) {
//            targetHeight = maxHeight;
//            targetWidth = maxHeight * aspectRatio;
//        }
//    }
    
    // 调整图片大小
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(imgWidth, imgHeight), NO, 1.0);
    [image drawInRect:CGRectMake(0, 0, imgWidth, imgHeight)];
    UIImage *compressedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return compressedImage;
}
@end
