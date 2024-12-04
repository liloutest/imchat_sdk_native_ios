//
//  ZMColorResUtil.m
//  imchat
//
//  Created by Lilou on 2024/10/17.
//

#import "ZMColorRes.h"
#import "UIColor+ZMAddon.h"
@implementation ZMColorRes



+ (UIColor *)bgGrayColor {
    return [UIColor colorWithHexString:@"#F3F5F7" withAlpha:1 ];
}

+ (UIColor *)chatTimeColor {
    return [UIColor colorWithHexString:@"#979797" withAlpha:1 ];
}

+ (UIColor *)chatCellBgColor {
    return [UIColor whiteColor];
}

+ (UIColor *)color_979797WithAlpha:(CGFloat)alpha {
    return [UIColor colorWithHexString:@"#979797" withAlpha:alpha];
}

+ (UIColor *)color_0054fc {
    return [UIColor colorWithHexString:@"#0054fc" withAlpha:0.1];
}

+ (UIColor *)color_0054fcWithAlpha:(CGFloat)alpha
{
    return [UIColor colorWithHexString:@"#0054fc" withAlpha:alpha];
}

+ (UIColor *)color_ebebeb{
    return [UIColor colorWithHexString:@"#ebebeb" withAlpha:1 ];
}

+ (UIColor *)color_f3f5f7{
    return [UIColor colorWithHexString:@"#f3f5f7" withAlpha:1 ];
}

+ (UIColor *)color_f3f4f6{
    return [UIColor colorWithHexString:@"#f3f4f7" withAlpha:1 ];
}

+ (UIColor *)color_18243e {
    return [UIColor colorWithHexString:@"#18243e" withAlpha:1 ];
}

+ (UIColor *)color_ff6164WithAlpha:(CGFloat)alpha{
    return [UIColor colorWithHexString:@"#ff6164" withAlpha:alpha];
}


@end
