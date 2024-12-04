//
//  ZMColorResUtil.h
//  imchat
//
//  Created by Lilou on 2024/10/17.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface ZMColorRes : NSObject
@property (nonatomic,strong,class,readonly) UIColor *bgGrayColor;
@property (nonatomic,strong,class,readonly) UIColor *chatTimeColor;
@property (nonatomic,strong,class,readonly) UIColor *chatCellBgColor;
@property (nonatomic,strong,class,readonly) UIColor *color_0054fc;
@property (nonatomic,strong,class,readonly) UIColor *color_ebebeb;
@property (nonatomic,strong,class,readonly) UIColor *color_f3f5f7;
@property (nonatomic,strong,class,readonly) UIColor *color_f3f4f6;
@property (nonatomic,strong,class,readonly) UIColor *color_18243e;

+ (UIColor *)color_0054fcWithAlpha:(CGFloat)alpha;

+ (UIColor *)color_ff6164WithAlpha:(CGFloat)alpha;

+ (UIColor *)color_979797WithAlpha:(CGFloat)alpha;
@end

NS_ASSUME_NONNULL_END
