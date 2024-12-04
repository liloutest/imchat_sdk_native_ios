//
//  ZMFontResUtil.m
//  imchat
//
//  Created by Lilou on 2024/10/17.
//

#import "ZMFontRes.h"

//UIFontWeight weights[] = {
//    UIFontWeightUltraLight,  // 100
//    UIFontWeightThin,        // 200
//    UIFontWeightLight,       // 300
//    UIFontWeightRegular,     // 400
//    UIFontWeightMedium,      // 500
//    UIFontWeightSemibold     // 600
//};

@implementation ZMFontRes

+ (UIFont *)sysFont:(int)fontSize weight:(UIFontWeight)weight {
    UIFontDescriptor *descriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:@{
        UIFontDescriptorFamilyAttribute: @"PingFang SC",
        UIFontWeightTrait: @(weight)
    }];
    UIFont *font = [UIFont fontWithDescriptor:descriptor size:kW(fontSize)];
//    UIFont *font = [UIFont fontWithName:@"PingFangSC-Regular" size:16.0];
    return font;//[UIFont systemFontOfSize:kW(fontSize) weight:weight];
}

+ (UIFont *) titleFont {
    return [ZMFontRes sysFont:18 weight:500];
//    return [UIFont fontWithName:@"PingFang SC" size:18];
}

+ (UIFont *) chatTimeFont {
    return [ZMFontRes sysFont:10 weight:400];
}

+ (UIFont *) chatNameFont {
    return [ZMFontRes sysFont:12 weight:400];
}

+ (UIFont *)font_8{
    return [ZMFontRes sysFont:8 weight:500];
}

+ (UIFont *)font_10{
    return [ZMFontRes sysFont:10 weight:600];
}

+ (UIFont *)font_12{
    return [ZMFontRes sysFont:12 weight:400];
}

+ (UIFont *)font_14{
    return [ZMFontRes sysFont:14 weight:400];
}
@end
