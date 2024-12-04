//
//  ZMChatToolBtn.m
//  imchat
//
//  Created by Lilou on 2024/10/21.
//

#import "ZMChatToolBtn.h"



@interface ZMChatToolBtn ()
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIButton *imageButton;
@property (nonatomic, copy) ActionBlock actionBlock;
@end

@implementation ZMChatToolBtn

- (instancetype)initWithImageName:(NSString *)imageName action:(ActionBlock)actionBlock {
    self = [super init];
    if (self) {
        
        self.actionBlock = actionBlock;
        
        self.bgView = [UIView new];
        self.bgView.backgroundColor = [UIColor whiteColor];
        self.bgView.layer.cornerRadius = kW(21);
        [self addSubview:self.bgView];
        
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        self.imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.imageButton setImage:[UIImage zm_imageWithName:ZMImageRes.choosePic] forState:UIControlStateNormal];
        [self.imageButton addTarget:self action:@selector(imageButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.imageButton];
        
        [self.imageButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(kW(32), kW(32)));
        }];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
}

- (void)imageButtonTapped {
    if(self.actionBlock){
        self.actionBlock();
    }
}

@end
