//
//  ZMStrRes.m
//  imchat
//
//  Created by Lilou on 2024/10/18.
//

#import "ZMStrRes.h"
#import "ZMLanguageManager.h"
@implementation ZMStrRes
+ (NSString *)like{
    return [[ZMLanguageManager sharedInstance] localizedStringForKey:@"like"];
}

+ (NSString *)unLike{
    return [[ZMLanguageManager sharedInstance] localizedStringForKey:@"unLike"];
}
@end
