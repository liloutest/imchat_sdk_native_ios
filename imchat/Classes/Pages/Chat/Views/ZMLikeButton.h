#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZMLikeButton : UIControl

@property (nonatomic, strong, readonly) UIImageView *iconImageView;
@property (nonatomic, strong, readonly) UILabel *textLabel;
@property (nonatomic) BOOL isChecked;
- (void)setLiked:(BOOL)liked reversed:(BOOL)reversed;
@end

NS_ASSUME_NONNULL_END
