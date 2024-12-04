#import <UIKit/UIKit.h>

/**
 * A popup message tip view that displays text with animation
 */
@interface ZMPopMsgTipView : UIView

/**
 * Block to be executed when the tip view is dismissed
 */
@property (nonatomic, copy) void(^dismissBlock)(void);

/**
 * Show the tip view with text above a specified view
 *
 * @param text Text to display in the tip view
 * @param inView Parent view to add this tip view
 * @param aboveView View to position this tip view above
 * @param edge Edge insets for positioning relative to aboveView
 */
- (void)showWithText:(NSString *)text inView:(UIView *)inView aboveView:(UIView *)aboveView edge:(UIEdgeInsets)edge;

- (void)showWithText:(NSString *)text inView:(UIView *)inView centerView:(UIView *)centerView edge:(UIEdgeInsets)edge;

/**
 * Dismiss the tip view with animation
 */
- (void)dismiss;

@end
