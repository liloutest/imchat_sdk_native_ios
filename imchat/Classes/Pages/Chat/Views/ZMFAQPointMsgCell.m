//
//  ZMFAQPointMsgCell.m
//  imchat
//
//  Created by Lilou on 2024/10/16.
//

#import "ZMFAQPointMsgCell.h"
#import <Masonry.h>
#import <TTTAttributedLabel/TTTAttributedLabel.h>
#import "ZMLikeButton.h"

#define kZMFAQQuestionBtnTagIndex 100

@interface ZMFAQPointMsgCell () <TTTAttributedLabelDelegate>
@property (nonatomic, strong) TTTAttributedLabel *messageLabel;
@property (nonatomic, strong) ZMLikeButton *likeButton;
@property (nonatomic, strong) ZMLikeButton *dislikeButton;
@property (nonatomic, strong) UIView *questionContainerView;
@property (nonatomic, strong) UIView *containner;

@end

@implementation ZMFAQPointMsgCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
//        [self setupViews];
//        [self setupConstraints];
    }
    return self;
}

- (void)setupViews {
    
    [super setupViews];
//    self.containner = [UIView new];
//    [self.contentView addSubview:self.containner];
    
    self.messageLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    self.messageLabel.numberOfLines = 0;
    self.messageLabel.delegate = self;
    self.messageLabel.font = ZMFontRes.font_14;
    self.messageLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    [self.bubbleView addSubview:self.messageLabel];
    
    self.likeButton = [ZMLikeButton new];
    self.likeButton.hidden = YES;
    [self.likeButton setLiked:YES reversed:NO];
    self.likeButton.textLabel.text = ZMStrRes.like;
    [self.likeButton addTarget:self action:@selector(likeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.likeButton];
    
    self.dislikeButton = [ZMLikeButton new];
    self.dislikeButton.hidden = YES;
    [self.dislikeButton setLiked:NO reversed:YES];
    self.dislikeButton.textLabel.text = ZMStrRes.unLike;
    [self.dislikeButton addTarget:self action:@selector(dislikeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.dislikeButton];
    
    self.questionContainerView = [UIView new];
    [self.bubbleView addSubview:self.questionContainerView];
    
}

- (void)setupConstraints {
    
    
    [self.messageLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.bubbleView).insets(UIEdgeInsetsMake(8, 8, 8, 8));
        make.top.equalTo(self.bubbleView.mas_top).offset(kW(12));
        make.left.equalTo(self.bubbleView).offset(kW(12));
        make.right.equalTo(self.bubbleView).offset(-kW(12));
//        make.size.mas_equalTo(CGSizeMake(kW(60), kW(32)));
    }];
    
    
    [self.likeButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-kW(8));
        make.left.equalTo(self.bubbleView);
        make.size.mas_equalTo(CGSizeMake(kW(60), kW(0)));
    }];
    
    [self.dislikeButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-kW(8));
        make.left.equalTo(self.likeButton.mas_right).offset(kW(20));
        make.size.mas_equalTo(CGSizeMake(kW(60), kW(0)));
    }];
    
//    [self.bubbleView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.height.equalTo(self.contentView).offset(-8);
//    }];


}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self setupConstraints];
    [self.bubbleView setRoundCorners:0 topRight:12 bottomLeft:12 bottomRight:12];
//    self.contentView.backgroundColor = [UIColor colorWithRed:arc4random() % 255 / 255. green:0.5 blue:0.5 alpha:1];
    
}

- (void)configureWithMessage:(ZMMessage *)message {
    self.message = message;
    self.messageLabel.text = @"点击选择以下常见问题获取便捷自助服务";//message.msgBody.msgBody; 固定
    [super configureWithMessage:message];
    
    
    
    if (message.isFromSys) {

        
        
    
    }
    
    [self.messageLabel setLinkAttributes:@{NSForegroundColorAttributeName: [UIColor blueColor]}];
    
    // configure question views
    [self setupQuestionViews:message];
}

- (void)setupQuestionViews:(ZMMessage *)message {
    [self.questionContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if(message.msgBody.faqPoints.count == 0)return;

    __block CGFloat qHeight = 0;
    
    @try {
        [message.msgBody.faqPoints enumerateObjectsUsingBlock:^(ZMMessageMsgBodyFaqPoint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            UIView *lastView = self.questionContainerView.subviews.lastObject;
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
            [btn setTitle:obj.knowledgePointName forState:UIControlStateNormal];
            [btn setTitleColor:[ZMColorRes color_0054fcWithAlpha:1] forState:UIControlStateNormal];
            btn.titleLabel.textAlignment = NSTextAlignmentLeft;
            btn.titleLabel.font = ZMFontRes.font_12;
            btn.titleLabel.numberOfLines = 0;
            
//            btn.titleLabel.backgroundColor = ZMColorRes.color_18243e;
//            CGSize buttonSize = [btn sizeThatFits:CGSizeMake(kW(100), CGFLOAT_MAX)];
            CGSize maxSize = CGSizeMake(SCREEN_WIDTH - kW(130), CGFLOAT_MAX);
            
            CGRect textRect = [obj.knowledgePointName boundingRectWithSize:maxSize
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{NSFontAttributeName: ZMFontRes.font_12}
                                                          context:nil];
//            btn.frame = CGRectMake(0, idx * buttonSize.height + kW(8) , buttonSize.width, buttonSize.height);
            btn.frame = CGRectMake(0, /*idx == 0 ? kW(8) : qHeight idx * textRect.size.height + (idx + 1) * kW(8)*/ lastView ? lastView.frame.origin.y + lastView.frame.size.height + kW(8): kW(8), textRect.size.width, textRect.size.height);
            
            btn.tag = idx + kZMFAQQuestionBtnTagIndex;
            [btn addTarget:self action:@selector(questionButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [self.questionContainerView addSubview:btn];
            
            qHeight += btn.frame.size.height + (idx + 1) * kW(8);
        }];
    } @catch (NSException *exception) {
        [SVProgressHUD showErrorWithStatus:exception.description];
    }
    
    
//    self.questionContainerView.backgroundColor = [UIColor redColor];
    [self.questionContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.messageLabel.mas_bottom).offset(kW(0));
        make.left.equalTo(self.bubbleView).offset(kW(12));
        make.right.equalTo(self.bubbleView).offset(-kW(12));
        make.height.mas_equalTo(@(qHeight + kW(16)));
    }];
    
    [self.bubbleView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom).offset(kW(8));
        make.right.equalTo(self.contentView.mas_right).offset(-kW(49));
        make.left.equalTo(self.avatarImageView.mas_right).offset(kW(8));
        make.bottom.equalTo(self.likeButton.mas_top).offset(-kW(8));
    }];

}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
//    [[UIApplication shhandleOpenURL:url options:@{} completionHandler:nil];
}


#pragma mark - Button action

- (void)questionButtonTapped:(UIButton *)btn {
//    if(self.questionBlock){
//        self.questionBlock(self.message, (int)btn.tag - kZMFAQQuestionBtnTagIndex);
//    }
    ZMMessageMsgBodyFaqPoint *item = self.message.msgBody.faqPoints[(int)btn.tag - kZMFAQQuestionBtnTagIndex];
    @try {
        [ZMHttpHelper getFaq:ZMMessageGetFaqTypeGetAnswer faqId:item.fId headers:nil success:^(NSDictionary *response) {
            
        } failure:^(NSError *error) {
            
        }];
    } @catch (NSException *exception) {
        [SVProgressHUD showErrorWithStatus:exception.description];
    }
}


- (void)likeButtonTapped {
    [self.likeButton setLiked:!self.likeButton.isChecked reversed:NO];
    if(self.likeEventBlock){
        self.likeEventBlock(self.message, YES);
    }
}

- (void)dislikeButtonTapped {
    [self.dislikeButton setLiked:!self.dislikeButton.isChecked reversed:YES];

    if(self.likeEventBlock){
        self.likeEventBlock(self.message, NO);
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
