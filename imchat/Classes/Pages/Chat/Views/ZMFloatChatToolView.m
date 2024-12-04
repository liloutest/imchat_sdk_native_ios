//
//  ZMFloatChatToolView.m
//  imchat
//
//  Created by Lilou on 2024/11/20.
//

#import "ZMFloatChatToolView.h"
#import "ZMPopMsgTipView.h"
@interface ZMFloatChatToolView()
@property (nonatomic,strong) ZMPopMsgTipView *popMsgTipView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UIView *containerView;
@end

@implementation ZMFloatChatToolView

+ (instancetype)shared {
    static ZMFloatChatToolView *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
        [sharedManager setupUI];
    });
    return sharedManager;
}


- (void)setupUI {
    
    self.userInteractionEnabled = NO;
    // 标题标签（人工客服）
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = @"人工客服";
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.font = ZMFontRes.font_14;
    self.titleLabel.backgroundColor = [UIColor whiteColor];
    self.titleLabel.layer.cornerRadius = kW(22);
    self.titleLabel.layer.masksToBounds = YES;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleServiceTap:)];
    [self.titleLabel addGestureRecognizer:tap];
    [self addSubview:self.titleLabel];
    
    // 容器视图
    self.containerView = [[UIView alloc] init];
    self.containerView.clipsToBounds = YES;
    self.containerView.backgroundColor = ZMColorRes.color_ebebeb;
    [self addSubview:self.containerView];
    
    // 提示文本
    self.tipLabel = [[UILabel alloc] init];
//    self.tipLabel.text = @"您已超过N分钟末回复";
    self.tipLabel.textAlignment = NSTextAlignmentCenter;
    self.tipLabel.adjustsFontSizeToFitWidth = YES;
    self.tipLabel.textColor = [ZMColorRes color_979797WithAlpha:1];
    self.tipLabel.font = ZMFontRes.font_12;
    self.tipLabel.numberOfLines = 0;
    [self.containerView addSubview:self.tipLabel];
    
    // 布局
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(kW(16));
        make.bottom.equalTo(self.containerView.mas_top).offset(-kW(12));
        make.height.mas_equalTo(kW(42));
        make.width.mas_equalTo(kW(80));
    }];
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(kW(0));
        make.left.right.bottom.equalTo(self);
    }];
    
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.containerView).insets(UIEdgeInsetsMake(0, kW(12), 0, kW(12)));
    }];
    
}

//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    CGPoint p = [self convertPoint:point toView:self.titleLabel];
//    if(p.x >= kW(10) && p.x <= (kW(100)) && p.y >= 0 && p.y <= (kW(80))){
//        return self.titleLabel;
//    }
//    return  [self.findSuperTableView hitTest:point withEvent:event];
////    return nil;
//}
//
//- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
//    return YES;
//}

- (void)handleServiceTap:(UITapGestureRecognizer *)gesture {
    NSLog(@"sdfsdffds");
//    [self.findViewController.view endEditing:YES];
//    
//    
//    [ZMHttpHelper serviceSupportSuccess:^(NSDictionary *response) {
//        
//    } failure:^(NSError *error) {
//       // 错误码处理 20000 客服封禁 B端； 20001 : 消息类型错误 toast ; 20002 : 会话不存在 createsession ; 20003 会话结束 createsession ; 20004 不是当前会话拥有者 toast Web 端测试的脏数据过滤
//        switch (error.code) {
//            case 20001:
//            case 20004:
//            {
//                [SVProgressHUD showErrorWithStatus:error.description];
//            }
//                break;
//            case 20002:
//            case 20003:
//            {
//                
//            }
//                break;
//            default:
//                break;
//        }
//    }];
}

- (void)setTipText:(NSString *)text {
    self.tipLabel.text = text;
    
    // 计算文本高度
//    CGFloat maxWidth = UIScreen.mainScreen.bounds.size.width - 16 * 2 - 12 * 2; // 屏幕宽度减去左右边距和内边距
//    CGSize size = [text boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
//                                    options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
//                                 attributes:@{NSFontAttributeName: self.tipLabel.font}
//                                    context:nil].size;
//    
//    // 更新约束
//    [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo(size.height + 24); // 文本高度加上上下内边距
//    }];
//    
//    // 强制立即更新布局
//    [self layoutIfNeeded];
}

- (void)showInView:(UIView *)inView aboveView:(UIView *)aboveView {
    [inView addSubview:self];
    [inView bringSubviewToFront:self];


    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.equalTo(aboveView.mas_top);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(kW(96));
    }];

}

- (void)showTimeoutTip:(NSInteger)minutes {
    self.hidden = NO;
    [self setTipText:[NSString stringWithFormat:@"您已超过%ld分钟末回复",(long)minutes]];
    [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(kW(42));
    }];
}

- (void)hideTimeoutTip {
    [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(kW(0));
    }];
}

- (void)showPopMsgTip:(NSString *)text {
    if(!self.popMsgTipView) {
        self.popMsgTipView = [[ZMPopMsgTipView alloc] init];
        self.popMsgTipView.tag = 110;
        self.popMsgTipView.dismissBlock = self.dismissPopMsgTipBlock;
        [self addSubview:self.popMsgTipView];
    }
    [self.popMsgTipView showWithText:text inView:self centerView:self.titleLabel edge:UIEdgeInsetsMake(0, 0, kW(12), kW(16))];
}

- (void)hidePopMsgTip {
    [self.popMsgTipView dismiss];
}

- (void)dismiss {
    
}


@end
