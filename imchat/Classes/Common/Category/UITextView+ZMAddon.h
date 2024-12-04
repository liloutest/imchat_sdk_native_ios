//
//  UITextView+ZMAddon.h
//  imchat
//
//  Created by Lilou on 2024/10/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITextView (ZMAddon)
- (NSInteger)lineCountUsingTextKit;
- (BOOL)isExceedingLineCount:(NSInteger)maxLineCount;
@end

NS_ASSUME_NONNULL_END
