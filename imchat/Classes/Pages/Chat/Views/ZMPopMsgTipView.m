#import "ZMPopMsgTipView.h"

@interface ZMPopMsgTipView()

// Visual effect view for blurred background
@property (nonatomic, strong) UIVisualEffectView *blurView;
// Container view for content
@property (nonatomic, strong) UIView *contentView;
// Label for displaying text
@property (nonatomic, strong) ZMLabel *textLabel;
// Button with dropdown arrow
@property (nonatomic, strong) UIButton *arrowButton;
// Tap gesture recognizer for dismissal
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@end

@implementation ZMPopMsgTipView

/**
 Initialize the view
 */
- (instancetype)init {
    if (self = [super init]) {
        [self setupUI];
    }
    return self;
}

/**
 Setup UI elements and constraints
 */
- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = YES;
    
    // Setup content container view
    self.contentView = [[UIView alloc] init];
    self.contentView.backgroundColor = [ZMColorRes color_0054fcWithAlpha:0.1];
    self.contentView.layer.masksToBounds = YES;
    self.contentView.alpha = 0.3;
    [self addSubview:self.contentView];
    
    // Add blur effect
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    self.blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    self.blurView.frame = self.bounds;
    self.blurView.alpha = 0;
    [self.contentView addSubview:self.blurView];
    
    // Setup text label
    self.textLabel = [[ZMLabel alloc] init];
    self.textLabel.font = ZMFontRes.font_14;
    self.textLabel.textColor = [UIColor blackColor];
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.numberOfLines = 0;
    [self.contentView addSubview:self.textLabel];
    
    // Setup dropdown arrow button
    self.arrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.arrowButton setImage:[UIImage zm_imageWithName:ZMImageRes.chatCommonArrowDown] forState:UIControlStateNormal];
    [self.contentView addSubview:self.arrowButton];
    
    // Setup constraints
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(kW(12));
        make.centerY.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(kW(8));
        make.bottom.equalTo(self.contentView).offset(-kW(8));
    }];
    
    [self.arrowButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.textLabel.mas_right).offset(kW(8));
        make.centerY.equalTo(self.textLabel);
        make.right.equalTo(self.contentView).offset(-kW(10));
        make.size.mas_equalTo(CGSizeMake(kW(16), kW(16)));
    }];
    
    // Add tap gesture
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
    [self addGestureRecognizer:self.tapGesture];
}

/**
 Layout subviews and set corner radius
 */
- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentView setRoundCorners:12 topRight:12 bottomLeft:12 bottomRight:0];
}

/**
 Show the tip view with text above a specified view
 
 @param text Text to display
 @param inView Parent view to add this tip view
 @param aboveView View to position this tip view above
 @param edge Edge insets for positioning
 */
- (void)showWithText:(NSString *)text inView:(UIView *)inView aboveView:(UIView *)aboveView edge:(UIEdgeInsets)edge {
    [inView addSubview:self];
    [inView bringSubviewToFront:self];
    self.textLabel.text = text;
    
    // Calculate content size
    [self.contentView layoutIfNeeded];
    CGSize contentSize = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];

    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(aboveView).offset(-kW(edge.right));
        make.bottom.equalTo(aboveView.mas_top).offset(-kW(edge.bottom));
        make.width.mas_equalTo(contentSize.width);
        make.height.mas_equalTo(contentSize.height);
    }];
  
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    self.contentView.transform = CGAffineTransformMakeScale(0.5, 0.5);
    self.contentView.alpha = 0;
    
    // Animate showing the tip view
    [UIView animateWithDuration:0.3
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        self.blurView.alpha = 0.8;
        self.contentView.alpha = 1;
        self.contentView.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)showWithText:(NSString *)text inView:(UIView *)inView centerView:(UIView *)centerView edge:(UIEdgeInsets)edge {
    [inView bringSubviewToFront:self];
    self.textLabel.text = text;
    
    // Calculate content size
    [self.contentView layoutIfNeeded];
    CGSize contentSize = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];

    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.mas_equalTo(centerView.mas_centerY);
        make.centerY.equalTo(centerView.mas_centerY);
        make.right.equalTo(inView).offset(-kW(edge.right));
        make.width.mas_equalTo(contentSize.width);
        make.height.mas_equalTo(contentSize.height);
    }];
  
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    self.contentView.transform = CGAffineTransformMakeScale(0.5, 0.5);
    self.contentView.alpha = 0;
    
    // Animate showing the tip view
    [UIView animateWithDuration:0.3
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        self.blurView.alpha = 0.8;
        self.contentView.alpha = 1;
        self.contentView.transform = CGAffineTransformIdentity;
    } completion:nil];
}

/**
 Dismiss the tip view with animation
 */
- (void)dismiss {
    [UIView animateWithDuration:0.2 animations:^{
        self.blurView.alpha = 0;
        self.contentView.alpha = 0;
        self.contentView.transform = CGAffineTransformMakeScale(0.8, 0.8);
    } completion:^(BOOL finished) {
        if (self.dismissBlock) {
            self.dismissBlock();
        }
//        [self removeFromSuperview];
    }];
}

/**
 Handle tap gesture to dismiss
 */
- (void)handleTap {
    [self dismiss];
}

@end
