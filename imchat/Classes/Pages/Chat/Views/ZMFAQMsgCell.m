//
//  ZMFAQMsgCell.m
//  imchat
//
//  Created by Lilou on 2024/11/25.
//

#import "ZMFAQMsgCell.h"
#import <Masonry.h>
#import <TTTAttributedLabel/TTTAttributedLabel.h>
#import "ZMLikeButton.h"
#define kZMFAQQuestionBtnTagIndex 100

@interface ZMFAQMsgCell () < UIScrollViewDelegate>
@property (nonatomic, strong) ZMLabel *messageLabel;
@property (nonatomic, strong) ZMLikeButton *likeButton;
@property (nonatomic, strong) ZMLikeButton *dislikeButton;
@property (nonatomic, strong) UIScrollView *cardScrollView;
@property (nonatomic, strong) UIView *cardContainerView;
@end

@implementation ZMFAQMsgCell

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
    
    // 创建滚动视图
    self.cardScrollView = [[UIScrollView alloc] init];
    self.cardScrollView.delegate = self;
    self.cardScrollView.showsHorizontalScrollIndicator = NO;
    self.cardScrollView.scrollEnabled = NO;
    self.cardScrollView.pagingEnabled = NO; // 关闭分页
    self.cardScrollView.userInteractionEnabled = YES;
    [self.bubbleView addSubview:self.cardScrollView];
    
    // 创建卡片容器
    self.cardContainerView = [[UIView alloc] init];
    self.cardContainerView.userInteractionEnabled = YES;
    [self.cardScrollView addSubview:self.cardContainerView];
    
    // 创建消息标签
    self.messageLabel = [ZMLabel new];
    self.messageLabel.numberOfLines = 0;
    self.messageLabel.font = ZMFontRes.font_14;
    self.messageLabel.textColor = ZMColorRes.color_18243e;
//    self.messageLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    [self.bubbleView addSubview:self.messageLabel];
    
    // 点赞按钮
    self.likeButton = [ZMLikeButton new];
    [self.likeButton setLiked:YES reversed:NO];
    self.likeButton.textLabel.text = ZMStrRes.like;
    self.likeButton.hidden = YES;
    [self.likeButton addTarget:self action:@selector(likeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.likeButton];
    
    // 不喜欢按钮
    self.dislikeButton = [ZMLikeButton new];
    [self.dislikeButton setLiked:NO reversed:YES];
    self.dislikeButton.hidden = YES;
    self.dislikeButton.textLabel.text = ZMStrRes.unLike;
    [self.dislikeButton addTarget:self action:@selector(dislikeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.dislikeButton];
}

- (void)setupConstraints {

    
    [self.bubbleView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom).offset(kW(8));
        make.right.equalTo(self.contentView.mas_right).offset(-kW(49));
        make.left.equalTo(self.avatarImageView.mas_right).offset(kW(8));
        make.bottom.equalTo(self.likeButton.mas_top).offset(-kW(8));
    }];
    
    // 更新 messageLabel 高度

    [self.messageLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bubbleView).offset(kW(12));
        make.left.equalTo(self.bubbleView).offset(kW(12));
        make.right.equalTo(self.bubbleView).offset(-kW(12));
        make.height.mas_equalTo(self.messageLabel.text.length > 0 ? [ZMCommon getTextHeightForLabel:self.messageLabel] : 0);
    }];
    
    // 卡片滚动视图约束 - 直接跟在 messageLabel 底部
//    [self.cardScrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.messageLabel.mas_bottom).offset(kW(12));
//        make.left.equalTo(self.bubbleView).offset(kW(12));
//        make.right.equalTo(self.bubbleView).offset(-kW(12));
//        make.height.mas_equalTo(kW(140));
////        make.bottom.equalTo(self.bubbleView).offset(-kW(12)); // 确保滚动视图到气泡底部有间距
//    }];
    
    [self.cardScrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.messageLabel.mas_bottom).offset(self.messageLabel.text.length > 0 ? kW(8) : 0);
        make.left.equalTo(self.bubbleView).offset(kW(12));
        make.right.equalTo(self.bubbleView).offset(-kW(12));
        make.height.mas_equalTo(self.cardScrollView.contentSize.height + kW(16));
    }];
    
    // 点赞按钮约束
    [self.likeButton mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.bubbleView.mas_bottom).offset(kW(8));
        make.left.equalTo(self.bubbleView);
        make.size.mas_equalTo(CGSizeMake(kW(60), kW(0)));
        make.bottom.equalTo(self.contentView).offset(-kW(8));
    }];
    
    // 不喜欢按钮约束
    [self.dislikeButton mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.bubbleView.mas_bottom).offset(kW(8));
        make.left.equalTo(self.likeButton.mas_right).offset(kW(20));
        make.size.mas_equalTo(CGSizeMake(kW(60), kW(0)));
        make.bottom.equalTo(self.contentView).offset(-kW(8));
    }];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self setupConstraints];
    [self.bubbleView setRoundCorners:0 topRight:12 bottomLeft:12 bottomRight:12];
    
}

- (void)configureWithMessage:(ZMMessage *)message {
    if(message.msgType == ZMMessageTypeFaqMsgType)
    {
        NSLog(@"f");
    }
    self.message = message;
    self.messageLabel.text = message.msgBody.faq.knowledgeBaseTitle;
    [super configureWithMessage:message];
    
    
    if (message.isFromSys) {
        // 设置主消息文本
//        self.messageLabel.text = message.msgBody.msgBody;

        // 配置卡片
        [self setupCards:message];
    }
    
//    [self.messageLabel setLinkAttributes:@{NSForegroundColorAttributeName: ZMColorRes.color_0054fc}];
}

- (CGFloat)calculateLabelHeightWithText:(NSString *)text
                                  font:(UIFont *)font
                              maxWidth:(CGFloat)maxWidth {
    // 创建段落样式
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    // 可以设置行距
    paragraphStyle.lineSpacing = 4.0;
    
    // 属性字典
    NSDictionary *attributes = @{
        NSFontAttributeName: font,
        NSParagraphStyleAttributeName: paragraphStyle
    };
    
    // 计算文字大小
    CGSize maxSize = CGSizeMake(maxWidth, CGFLOAT_MAX);
    CGSize size = [text boundingRectWithSize:maxSize
                                    options:NSStringDrawingUsesLineFragmentOrigin |
                                           NSStringDrawingUsesFontLeading
                                 attributes:attributes
                                    context:nil].size;
    
    // 计算额外需要的空间
    CGFloat extraSpace = font.lineHeight - (font.ascender + fabs(font.descender));
    
    // 向上取整并添加额外空间
    return ceil(size.height + extraSpace);
}

- (void)setupCards:(ZMMessage *)message {
    // 清除现有的卡片视图
    [self.cardContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSArray<ZMMessageMsgBodyFaqItem *> *cards = [message.msgBody faq].knowledgeBaseList;
    if(cards.count == 0)return;
    
    CGFloat contentWidth = (SCREEN_WIDTH - kW(130));
    
    CGFloat cardWidth = (contentWidth - kW(24)) / 3; // 一行三个卡片,左右各留8dp间距
    CGFloat cardHeight = (cardWidth); // 卡片主体高度
    CGFloat cardSpacing = kW(8); // 卡片间距
    
    NSInteger rows = (cards.count + 2) / 3; // 计算需要的行数
    CGFloat totalHeight = (cardHeight + cardSpacing) * rows;
    
    self.cardContainerView.frame = CGRectMake(0, 0, contentWidth, totalHeight);
    
    // 创建卡片视图
    [cards enumerateObjectsUsingBlock:^(ZMMessageMsgBodyFaqItem * _Nonnull obj, NSUInteger idx, BOOL *stop) {
        NSInteger row = idx / 3;    // 当前行
        NSInteger col = idx % 3;    // 当前列
        
        // 创建卡片容器
        CGFloat x =  (cardWidth + cardSpacing) * col;
        CGFloat y = (cardHeight + cardSpacing) * row ;
        
        UIView *cardContainer = [[UIView alloc] initWithFrame:CGRectMake(x, y, cardWidth, cardHeight )];
        cardContainer.backgroundColor = ZMColorRes.color_f3f4f6;
        cardContainer.layer.cornerRadius = kW(8);
        cardContainer.userInteractionEnabled = YES;
        
        // 创建卡片主体
        UIView *cardView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cardWidth, cardHeight)];
//        cardView.userInteractionEnabled = YES;
    
        // 添加图标
        UIImageView *iconView = [[UIImageView alloc] init];
//        iconView.userInteractionEnabled = YES;
        [iconView zm_setImageWithURL:obj.urlContent.url placeholderImage:[UIImage zm_imageWithName:ZMImageRes.chatFaqAvatar] encryptKey:obj.urlContent.key isVideo:NO completion:^(UIImage * _Nullable image, NSError * _Nullable error) {
                    
        }];
        [cardView addSubview:iconView];
//        obj.knowledgeBaseName = @"dfsdfsdfsdfsdfdsfdsfdsfsdfsdfsdfsdf-";
        // 添加tip标签
        ZMAlignLabel *tipLabel = [[ZMAlignLabel alloc] init];
        tipLabel.text = obj.knowledgeBaseName;
        tipLabel.font = ZMFontRes.font_10;
        tipLabel.numberOfLines = 2;
//        tipLabel.backgroundColor = [UIColor redColor];
        tipLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        tipLabel.textColor = [UIColor blackColor];
        tipLabel.textAlignment = NSTextAlignmentCenter;
//        tipLabel.userInteractionEnabled = YES;
        [cardView addSubview:tipLabel];
        [tipLabel sizeToFit];

        CGSize maxSize = CGSizeMake(cardWidth - kW(8), CGFLOAT_MAX);
        
        CGRect textRect = [tipLabel.text boundingRectWithSize:maxSize
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:@{NSFontAttributeName: tipLabel.font}
                                                      context:nil];
        
        CGFloat textH = textRect.size.height > 20 ? 35 : 20; //[ZMCommon calculateHeightWithText:tipLabel.text maxWidth:maxSize.width font:tipLabel.font];

        // 设置约束
        [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(cardView);
            make.centerX.equalTo(cardView);
            make.size.mas_equalTo(CGSizeMake(kW(24), kW(24)));
        }];
        
        
        [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(iconView.mas_bottom).offset(kW(4));
            make.left.equalTo(cardView.mas_left).offset(kW(4));
            make.right.equalTo(cardView.mas_right).offset(-kW(4));
            make.height.mas_equalTo(textH);
        }];
        
        // 添加点击事件
        cardContainer.tag = idx;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cardTapped:)];
        [cardContainer addGestureRecognizer:tap];
        [cardContainer addSubview:cardView];
        
        [cardView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(cardWidth, kW(24) + kW(4) + textH));
            make.center.equalTo(cardContainer);
        }];
        
        
//        cardContainer.backgroundColor = [UIColor redColor];
        
        [self.cardContainerView addSubview:cardContainer];
        
        
        [cardContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.cardContainerView).offset(y);
            make.left.equalTo(self.cardContainerView).offset(x);
            make.size.mas_equalTo(CGSizeMake(cardWidth,cardHeight));
        }];

    }];
    

    self.cardScrollView.contentSize = CGSizeMake(contentWidth, self.cardContainerView.frame.size.height);

    
}

- (void)cardTapped:(UITapGestureRecognizer *)gesture {
//    if (self.questionBlock) {
//        self.questionBlock(self.message, (int)gesture.view.tag);
//    }
    @try {
        [ZMHttpHelper getFaq:ZMMessageGetFaqTypeGetKnowledge faqId:self.message.msgBody.faq.knowledgeBaseList[(int)gesture.view.tag].fId headers:nil success:^(NSDictionary *response) {
            
        } failure:^(NSError *error) {
            
        }];
    } @catch (NSException *exception) {
        [SVProgressHUD showErrorWithStatus:exception.description];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = scrollView.frame.size.width;
    NSInteger currentPage = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
//    self.pageControl.currentPage = currentPage;
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
//    [[UIApplication shhandleOpenURL:url options:@{} completionHandler:nil];
}


#pragma mark - Button action

- (void)questionButtonTapped:(UIButton *)btn {
    if(self.questionBlock){
        self.questionBlock(self.message, (int)btn.tag - kZMFAQQuestionBtnTagIndex);
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
