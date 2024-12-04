#import "ZMLikeButton.h"
#import "UIView+ZMAddon.h"

@interface ZMLikeButton()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, assign) BOOL isLiked;

@end

@implementation ZMLikeButton

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = kW(16);
    self.backgroundColor = [UIColor whiteColor];
    self.iconImageView = [[UIImageView alloc] init];
    self.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.iconImageView];
    
    self.textLabel = [[UILabel alloc] init];
    self.textLabel.font = ZMFontRes.font_12;
    [self addSubview:self.textLabel];
    
    [self setLiked:NO reversed:NO];
    
    [self setupConstraints];
}

- (void)setupConstraints {
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(kZMPadding);
        make.centerY.equalTo(self);
        make.width.height.equalTo(@kW(16));
    }];
    
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImageView.mas_right).offset(kW(4));
        make.centerY.equalTo(self);
//        make.right.equalTo(self).offset(-8);
    }];
}

- (void)setLiked:(BOOL)liked reversed:(BOOL)reversed {
    self.isLiked = liked;
    UIImage *image = [UIImage zm_imageWithName:!reversed ? (liked ? ZMImageRes.likeChecked : ZMImageRes.likeUnChecked) : (liked ? ZMImageRes.unLikeChecked : ZMImageRes.unLikeUnChecked)] ;
    self.iconImageView.image = image;
    
    if (liked) {
        
        self.textLabel.textColor = [ZMColorRes color_979797WithAlpha:1];
    } else {

        self.textLabel.textColor = [UIColor blackColor];
    }
}

- (BOOL)isChecked{
    return self.isLiked;
}


- (void)layoutSubviews {
    [super layoutSubviews];
//    [self setRoundCorners:10 topRight:10 bottomLeft:10 bottomRight:10];
//    [self setRoundCorners:20 topRight:20 bottomLeft:20 bottomRight:20];
    
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
}

@end
