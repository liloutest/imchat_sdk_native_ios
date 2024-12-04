#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (ZMAddon)

/**
 设置视图的指定角为圆角
 
 @param topLeft 左上角的圆角半径
 @param topRight 右上角的圆角半径
 @param bottomLeft 左下角的圆角半径
 @param bottomRight 右下角的圆角半径
 */
- (void)setRoundCorners:(CGFloat)topLeft topRight:(CGFloat)topRight bottomLeft:(CGFloat)bottomLeft bottomRight:(CGFloat)bottomRight;
/**
 Sets borders for specified edges of the view.

 @param top Width of the top border.
 @param left Width of the left border.
 @param bottom Width of the bottom border.
 @param right Width of the right border.
 @param color Color of the border.
 */
- (void)setBorderWidth:(CGFloat)top left:(CGFloat)left bottom:(CGFloat)bottom right:(CGFloat)right color:(UIColor *)color;

/**
 Sets borders for specified edges of the view.

 @param edges The edges to set borders for (can be combined, e.g., UIRectEdgeTop | UIRectEdgeLeft).
 @param width Width of the border.
 @param color Color of the border.
 */
- (void)setBorderWithEdges:(UIRectEdge)edges width:(CGFloat)width color:(UIColor *)color;

- (UIViewController *)findViewController;

- (UITableView *)findSuperTableView;
@end

NS_ASSUME_NONNULL_END
