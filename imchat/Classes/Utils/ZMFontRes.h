//
//  ZMFontResUtil.h
//  imchat
//
//  Created by Lilou on 2024/10/17.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface ZMFontRes : NSObject
@property (nonatomic,strong,class,readonly) UIFont *titleFont;
@property (nonatomic,strong,class,readonly) UIFont *chatTimeFont;
@property (nonatomic,strong,class,readonly) UIFont *chatNameFont;
@property (nonatomic,strong,class,readonly) UIFont *font_8;
@property (nonatomic,strong,class,readonly) UIFont *font_10;
@property (nonatomic,strong,class,readonly) UIFont *font_12;
@property (nonatomic,strong,class,readonly) UIFont *font_14;
@end

NS_ASSUME_NONNULL_END
