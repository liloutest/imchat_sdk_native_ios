#import "UIView+ZMAddon.h"

@implementation UIView (ZMAddon)

- (void)setRoundCorners:(CGFloat)topLeft topRight:(CGFloat)topRight bottomLeft:(CGFloat)bottomLeft bottomRight:(CGFloat)bottomRight {
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    // 左上角
    [path moveToPoint:CGPointMake(0, topLeft)];
    [path addArcWithCenter:CGPointMake(topLeft, topLeft) radius:topLeft startAngle:M_PI endAngle:3 * M_PI / 2 clockwise:YES];
    
    // 右上角
    [path addLineToPoint:CGPointMake(self.bounds.size.width - topRight, 0)];
    [path addArcWithCenter:CGPointMake(self.bounds.size.width - topRight, topRight) radius:topRight startAngle:3 * M_PI / 2 endAngle:0 clockwise:YES];
    
    // 右下角
    [path addLineToPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height - bottomRight)];
    [path addArcWithCenter:CGPointMake(self.bounds.size.width - bottomRight, self.bounds.size.height - bottomRight) radius:bottomRight startAngle:0 endAngle:M_PI / 2 clockwise:YES];
    
    // 左下角
    [path addLineToPoint:CGPointMake(bottomLeft, self.bounds.size.height)];
    [path addArcWithCenter:CGPointMake(bottomLeft, self.bounds.size.height - bottomLeft) radius:bottomLeft startAngle:M_PI / 2 endAngle:M_PI clockwise:YES];
    
    [path closePath];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = path.CGPath;
    self.layer.mask = maskLayer;
}

- (void)setBorderWidth:(CGFloat)top left:(CGFloat)left bottom:(CGFloat)bottom right:(CGFloat)right color:(UIColor *)color {
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0, 0, self.frame.size.width, top);
    topBorder.backgroundColor = color.CGColor;
    
    CALayer *leftBorder = [CALayer layer];
    leftBorder.frame = CGRectMake(0, 0, left, self.frame.size.height);
    leftBorder.backgroundColor = color.CGColor;
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0, self.frame.size.height - bottom, self.frame.size.width, bottom);
    bottomBorder.backgroundColor = color.CGColor;
    
    CALayer *rightBorder = [CALayer layer];
    rightBorder.frame = CGRectMake(self.frame.size.width - right, 0, right, self.frame.size.height);
    rightBorder.backgroundColor = color.CGColor;
    
    [self.layer addSublayer:topBorder];
    [self.layer addSublayer:leftBorder];
    [self.layer addSublayer:bottomBorder];
    [self.layer addSublayer:rightBorder];
}

- (void)setBorderWithEdges:(UIRectEdge)edges width:(CGFloat)width color:(UIColor *)color {
    if (edges & UIRectEdgeTop) {
        CALayer *topBorder = [CALayer layer];
        topBorder.frame = CGRectMake(0, 0, self.frame.size.width, width);
        topBorder.backgroundColor = color.CGColor;
        [self.layer addSublayer:topBorder];
    }
    
    if (edges & UIRectEdgeLeft) {
        CALayer *leftBorder = [CALayer layer];
        leftBorder.frame = CGRectMake(0, 0, width, self.frame.size.height);
        leftBorder.backgroundColor = color.CGColor;
        [self.layer addSublayer:leftBorder];
    }
    
    if (edges & UIRectEdgeBottom) {
        CALayer *bottomBorder = [CALayer layer];
        bottomBorder.frame = CGRectMake(0, self.frame.size.height - width, self.frame.size.width, width);
        bottomBorder.backgroundColor = color.CGColor;
        [self.layer addSublayer:bottomBorder];
    }
    
    if (edges & UIRectEdgeRight) {
        CALayer *rightBorder = [CALayer layer];
        rightBorder.frame = CGRectMake(self.frame.size.width - width, 0, width, self.frame.size.height);
        rightBorder.backgroundColor = color.CGColor;
        [self.layer addSublayer:rightBorder];
    }
}

- (UIViewController *)findViewController {

    UIResponder *responder = self;
    

    while (responder) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
        responder = [responder nextResponder];
    }
    
    return nil;
}

- (UITableView *)findSuperTableView {
    UIResponder *responder = self;
    

    while (responder) {
        if ([responder isKindOfClass:[UITableView class]]) {
            return (UITableView *)responder;
        }
        responder = [responder nextResponder];
    }
    
    return nil;
}

@end
