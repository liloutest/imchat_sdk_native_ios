#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZMTableHeaderView : UIView

@property (nonatomic, strong, readonly) UIImageView *iconImageView;
@property (nonatomic, strong, readonly) UILabel *textLabel;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)showWithAnimation;
- (void)hideWithAnimation;

@end

NS_ASSUME_NONNULL_END
