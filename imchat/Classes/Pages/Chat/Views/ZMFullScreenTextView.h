#import <UIKit/UIKit.h>
#import "ZMTextView.h"

@interface ZMFullScreenTextView : UIView

@property (nonatomic, strong) ZMTextView *textView;

@property (nonatomic, strong) ActionBlock actionBlock;

// 显示全屏视图的方法
- (void)showWithText:(NSString *)text fromRect:(CGRect)rect;

// 关闭全屏视图的方法
- (void)dismiss;

@end
