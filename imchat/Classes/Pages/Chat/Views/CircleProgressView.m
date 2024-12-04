//
//  CircleProgressView.m
//  imchat
//
//  Created by Lilou on 2024/11/14.
//

#import "CircleProgressView.h"

@implementation CircleProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupLayers];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)setupLayers {
    // 背景圆环
    CAShapeLayer *backgroundLayer = [CAShapeLayer layer];
    backgroundLayer.frame = self.bounds;
    backgroundLayer.lineWidth = 5.0;
    backgroundLayer.fillColor = [UIColor clearColor].CGColor;
    backgroundLayer.strokeColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2].CGColor;
    
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
                                                             radius:(CGRectGetWidth(self.bounds) - 4) / 2
                                                         startAngle:-M_PI_2
                                                           endAngle:3 * M_PI_2
                                                          clockwise:YES];
    backgroundLayer.path = circlePath.CGPath;
    [self.layer addSublayer:backgroundLayer];
    
    // 进度层
    self.progressLayer = [CAShapeLayer layer];
    self.progressLayer.frame = self.bounds;
    self.progressLayer.lineWidth = 5.0;
    self.progressLayer.fillColor = [UIColor clearColor].CGColor;
    self.progressLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.progressLayer.path = circlePath.CGPath;
    self.progressLayer.strokeEnd = 0;
    
    // 渐变层
    self.gradientLayer = [CAGradientLayer layer];
    self.gradientLayer.frame = self.bounds;
    
    // 设置渐变色
    self.gradientLayer.colors = @[
        (id)[[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] CGColor],    // 白色
        (id)[[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.8] CGColor]     // 灰白色
    ];
    
    // 设置渐变方向
    self.gradientLayer.startPoint = CGPointMake(0, 0);
    self.gradientLayer.endPoint = CGPointMake(1, 1);
    
    // 使用 progressLayer 作为 mask
    self.gradientLayer.mask = self.progressLayer;
    [self.layer addSublayer:self.gradientLayer];
    
    // 箭头层
    self.arrowLayer = [CAShapeLayer layer];
    self.arrowLayer.frame = self.bounds;
    self.arrowLayer.fillColor = [UIColor clearColor].CGColor;
    self.arrowLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.arrowLayer.lineWidth = 2.0;
    self.arrowLayer.hidden = YES;
    
    // 创建箭头路径
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    CGFloat centerX = CGRectGetMidX(self.bounds);
    CGFloat centerY = CGRectGetMidY(self.bounds);
    [arrowPath moveToPoint:CGPointMake(centerX, centerY - 10)];
    [arrowPath addLineToPoint:CGPointMake(centerX, centerY + 10)];
    [arrowPath moveToPoint:CGPointMake(centerX, centerY - 10)];
    [arrowPath addLineToPoint:CGPointMake(centerX - 5, centerY - 5)];
    [arrowPath moveToPoint:CGPointMake(centerX, centerY - 10)];
    [arrowPath addLineToPoint:CGPointMake(centerX + 5, centerY - 5)];
    
    self.arrowLayer.path = arrowPath.CGPath;
    [self.layer addSublayer:self.arrowLayer];
    
    // 添加旋转动画
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.fromValue = @0;
    rotationAnimation.toValue = @(2 * M_PI);
    rotationAnimation.duration = 4.0;
    rotationAnimation.repeatCount = 1;//HUGE_VALF;
    [self.gradientLayer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    self.progressLayer.strokeEnd = progress;
}

- (void)handleTap {
    self.isPaused = !self.isPaused;
    
    if (self.isPaused) {
        // 暂停状态：显示箭头
        self.gradientLayer.hidden = YES;
        self.arrowLayer.hidden = NO;
        
        // 添加箭头动画
        CABasicAnimation *bounceAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
        bounceAnimation.duration = 0.6;
        bounceAnimation.fromValue = @(0);
        bounceAnimation.toValue = @(-5);
        bounceAnimation.autoreverses = YES;
        bounceAnimation.repeatCount = HUGE_VALF;
        [self.arrowLayer addAnimation:bounceAnimation forKey:@"bounceAnimation"];
    } else {
        // 继续状态：显示进度条
        self.gradientLayer.hidden = NO;
        self.arrowLayer.hidden = YES;
        [self.arrowLayer removeAllAnimations];
    }
}

@end
