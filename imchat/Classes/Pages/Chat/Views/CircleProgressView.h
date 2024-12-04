//
//  CircleProgressView.h
//  imchat
//
//  Created by Lilou on 2024/11/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CircleProgressView : UIView
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) CAShapeLayer *arrowLayer;
@property (nonatomic, assign) BOOL isPaused;
@end

NS_ASSUME_NONNULL_END
