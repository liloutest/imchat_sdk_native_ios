//
//  ZMFloatChatToolView.h
//  imchat
//
//  Created by Lilou on 2024/11/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZMFloatChatToolView : UIView

@property (nonatomic, copy) void(^dismissPopMsgTipBlock)(void);

+ (instancetype)shared;

- (void)showInView:(UIView *)inView aboveView:(UIView *)aboveView;

- (void)showTimeoutTip:(NSInteger)minutes;

- (void)hideTimeoutTip;

- (void)showPopMsgTip:(NSString *)text;

- (void)hidePopMsgTip;

- (void)dismiss;
@end

NS_ASSUME_NONNULL_END
