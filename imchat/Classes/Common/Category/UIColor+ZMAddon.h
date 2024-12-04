//
//  UIColor+ZMAddon.h
//  imchat
//
//  Created by Lilou on 2024/10/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (ZMAddon)
+ (UIColor *)colorWithHexString:(NSString *)hex withAlpha:(CGFloat)alpha;
@end

NS_ASSUME_NONNULL_END
