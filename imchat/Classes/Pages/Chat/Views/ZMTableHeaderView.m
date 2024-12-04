#import "ZMTableHeaderView.h"
#import <Masonry/Masonry.h>
#import "AFNetworkReachabilityManager.h"
@interface ZMTableHeaderView()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation ZMTableHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.backgroundColor = [ZMColorRes color_ff6164WithAlpha:0.1];
    self.hidden = YES;
    
    self.iconImageView = [[UIImageView alloc] init];
    self.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.iconImageView.image = [UIImage zm_imageWithName:ZMImageRes.chatNetFail];
    [self addSubview:self.iconImageView];
    
    self.textLabel = [[UILabel alloc] init];
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.font = ZMFontRes.font_12;
    self.textLabel.text = @"网络不可用，请检查你的网络";
    self.textLabel.textColor = [ZMColorRes color_979797WithAlpha:1];
    [self addSubview:self.textLabel];
    
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if(status == AFNetworkReachabilityStatusNotReachable || status == AFNetworkReachabilityStatusUnknown){
            [self showWithAnimation];
        }
        else{
            [self hideWithAnimation];
        }
    }];
    
    [self setupConstraints];
    
   
}

- (void)setupConstraints {
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self.textLabel.mas_left).offset(-kW(8));
        make.width.height.equalTo(@kW(16));
    }];
    
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self).offset(kW(24));
        make.centerY.equalTo(self);
    }];
}

- (void)layoutSubviews{
    [super layoutSubviews];
//    [self mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.equalTo(self.superview);
//        make.top.equalTo(self.findViewController.view);
//        make.height.mas_equalTo(kW(40));
//    }];
}

- (void)showWithAnimation {
    self.alpha = 0;
    self.transform = CGAffineTransformMakeTranslation(0, -self.frame.size.height);
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformIdentity;
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.superview);
            make.top.equalTo(self.findViewController.view.mas_safeAreaLayoutGuideTop);
            make.height.mas_equalTo(kW(40));
        }];
//                    self.frame = CGRectMake(0, 0, self.frame.size.width, 40);
    } completion:^(BOOL finished) {
        if (finished) {

            self.hidden = NO;
            
        }
    }];
}

- (void)hideWithAnimation {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
        self.transform = CGAffineTransformMakeTranslation(0, -self.frame.size.height);
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.superview);
            make.top.equalTo(self.findViewController.view.mas_safeAreaLayoutGuideTop);
            make.height.mas_equalTo(kW(0));
        }];
        
//        self.frame = CGRectMake(0, 0, self.frame.size.width, 0);
    } completion:^(BOOL finished) {
        if (finished) {
            
            self.hidden = YES;
        }
    }];
}

@end
