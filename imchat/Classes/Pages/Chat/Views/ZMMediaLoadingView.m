#import "ZMMediaLoadingView.h"

@interface ZMMediaLoadingView()

@property (nonatomic, strong) UIVisualEffectView *blurView;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) ZMLabel *progressLabel;
@end

@implementation ZMMediaLoadingView

- (instancetype)initWithType:(ZMMediaLoadingType)type {
    self = [super init];
    if (self) {
        
        _blurAlpha = 1.0;
        [self setupViews];
        [self setType:type];
    }
    return self;
}

- (void)setType:(ZMMediaLoadingType)type{
    _type = type;
    self.progressLabel.hidden = YES;
    self.progressLayer.hidden = NO;
    self.layer.borderWidth = 0;
    switch (_type) {
        case ZMMediaLoadingTypePlay:
        {
            self.progressLayer.hidden = YES;
            self.imgView.image = [UIImage zm_imageWithName:ZMImageRes.chatVideoPlay];
            self.layer.borderWidth = 1 ;
        }
            
            break;
        case ZMMediaLoadingTypeCircleProgress:
            self.progressLabel.hidden = NO;
            self.imgView.image = [UIImage new];//[UIImage zm_imageWithName:ZMImageRes.chatVideoPlay];
            break;
        case ZMMediaLoadingTypeUploadPause:
            self.imgView.image = [UIImage zm_imageWithName:ZMImageRes.chatUploadPause];
            break;
        case ZMMediaLoadingTypeUploadFail:
        {
            self.progressLayer.hidden = YES;
            self.imgView.image = [UIImage zm_imageWithName:ZMImageRes.chatUploadFail];
            self.layer.borderWidth = 1 ;
        }
            
            break;
        default:
            break;
    }
}

- (void)setupViews {
    
//    self.clipsToBounds = YES;
//    self.layer.masksToBounds = YES;
    
    // Setup blur effect
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    self.blurView.frame = self.bounds;
    self.blurView.alpha = self.blurAlpha;
    self.blurView.userInteractionEnabled = NO;
    self.blurView.clipsToBounds = YES;
    [self addSubview:self.blurView];
    
    
    // Setup progress layer
    self.progressLayer = [CAShapeLayer layer];
    self.progressLayer.fillColor = [UIColor clearColor].CGColor;
    self.progressLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.progressLayer.lineWidth = kW(2);
    self.progressLayer.lineCap = kCALineCapRound;
//    self.progressLayer.masksToBounds = YES;
    [self.layer addSublayer:self.progressLayer];
    
    // Setup activity indicator
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.activityIndicator.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    self.activityIndicator.userInteractionEnabled = NO;
    self.activityIndicator.hidden = YES;
    [self addSubview:self.activityIndicator];
    
    
    self.imgView = [UIImageView new];

    [self addSubview:self.imgView];
    
    
    self.progressLabel = [ZMLabel new];
    self.progressLabel.textColor = [UIColor whiteColor];
    self.progressLabel.backgroundColor = [UIColor clearColor];
    self.progressLabel.userInteractionEnabled = NO;
    self.progressLabel.font = ZMFontRes.font_8;
    self.progressLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:self.progressLabel];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:tap];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setupLayout];
    self.blurView.frame = self.bounds;
    self.activityIndicator.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
//    self.progressLabel.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    [self updateProgressLayer];
}

- (void)setupLayout{
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    
    
    [self.progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
}

- (void)updateProgressLayer {
    CGFloat size = MIN(self.bounds.size.width, self.bounds.size.height) - 2;//10; // Reduced padding
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center
                                                        radius:size / 2
                                                    startAngle:-M_PI_2
                                                      endAngle:2 * M_PI - M_PI_2
                                                     clockwise:YES];
    self.progressLayer.path = path.CGPath;
    self.progressLayer.strokeEnd = self.progress;
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    self.progressLabel.text = [NSString stringWithFormat:@"%d%%",((int)(_progress * 100))];
    [self updateProgressLayer];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
    if (animated) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation.fromValue = @(self.progress);
        animation.toValue = @(progress);
        animation.duration = 0.25;
        [self.progressLayer addAnimation:animation forKey:@"progressAnimation"];
    }
    [self setProgress:progress];
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = cornerRadius;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.blurView.layer.cornerRadius = cornerRadius;
}

- (void)setIsCircular:(BOOL)isCircular {
    _isCircular = isCircular;
    if (isCircular) {
        self.cornerRadius = MIN(self.bounds.size.width, self.bounds.size.height) / 2;
    }
}

- (void)startAnimating {
    [self.activityIndicator startAnimating];
    self.progressLayer.hidden = YES;
}

- (void)stopAnimating {
    [self.activityIndicator stopAnimating];
    self.progressLayer.hidden = NO;
}

- (void)setBlurAlpha:(CGFloat)alpha {
    _blurAlpha = alpha;
    self.blurView.alpha = alpha;
}


- (void)handleTap {
    [ZMCommon mainExec:^{
        switch (self.type) {
            case ZMMediaLoadingTypeUploadPause:
            {
                self.type = ZMMediaLoadingTypeCircleProgress;
                self.progressLabel.hidden = NO;
                if(self.resumeBlock){
                    self.resumeBlock();
                }
            }
                break;
            case ZMMediaLoadingTypeUploadFail:
            {
                // 重试
                self.type = ZMMediaLoadingTypeCircleProgress;
                self.progressLabel.hidden = YES;
                if(self.failBlock){
                    self.failBlock();
                }
            }
                break;
            case ZMMediaLoadingTypeCircleProgress:
            {
                self.type = ZMMediaLoadingTypeUploadPause;
                self.progressLabel.hidden = YES;
                //
                if(self.pauseBlock){
                    self.pauseBlock();
                }
            }
                break;
            default:
                self.progressLabel.hidden = YES;
                break;
        }
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }];


}

@end
