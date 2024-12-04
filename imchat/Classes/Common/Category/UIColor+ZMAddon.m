//
//  UIColor+ZMAddon.m
//  imchat
//
//  Created by Lilou on 2024/10/17.
//

#import "UIColor+ZMAddon.h"

@implementation UIColor (ZMAddon)
+ (UIColor *)colorWithHexString:(NSString *)hex withAlpha:(CGFloat)alpha {
    // 移除空格和换行符，并将字符串转换为大写
    NSString *cleanHexString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];

    // 检查是否以 '#' 开头
    if ([cleanHexString hasPrefix:@"#"]) {
        cleanHexString = [cleanHexString substringFromIndex:1];
    }

    // 检查字符串长度
    if (cleanHexString.length == 3) {
        // 如果是 3 位格式，将其转换为 6 位格式
        NSString *r = [cleanHexString substringWithRange:NSMakeRange(0, 1)];
        NSString *g = [cleanHexString substringWithRange:NSMakeRange(1, 1)];
        NSString *b = [cleanHexString substringWithRange:NSMakeRange(2, 1)];
        cleanHexString = [NSString stringWithFormat:@"%@%@%@%@%@%@", r, r, g, g, b, b];
    }

    // 确保是 6 位格式
    if (cleanHexString.length != 6) {
        return nil; // 如果不是有效的 hex 格式，返回 nil
    }

    // 获取 RGB 值
    unsigned int rgbValue = 0;
    [[NSScanner scannerWithString:cleanHexString] scanHexInt:&rgbValue];

    CGFloat red = ((rgbValue >> 16) & 0xFF) / 255.0;
    CGFloat green = ((rgbValue >> 8) & 0xFF) / 255.0;
    CGFloat blue = (rgbValue & 0xFF) / 255.0;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}
@end
