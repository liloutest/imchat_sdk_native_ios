//
//  ZMFAQAnswerCell.m
//  imchat
//
//  Created by Lilou on 2024/11/25.
//

#import "ZMFAQAnswerCell.h"
#import "Masonry.h"
#import <TTTAttributedLabel/TTTAttributedLabel.h>
#import "ZMLikeButton.h"
#import "ZMMediaGalleryView.h"
#define kZMFAQQuestionBtnTagIndex 100

@interface ZMFAQAnswerCell () <TTTAttributedLabelDelegate>
@property (nonatomic, strong) TTTAttributedLabel *messageLabel;
@property (nonatomic, strong) ZMLikeButton *likeButton;
@property (nonatomic, strong) ZMLikeButton *dislikeButton;
@property (nonatomic, strong) UIView *faqAnswerContainner;

@end

@implementation ZMFAQAnswerCell

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
    self.faqAnswerContainner = [UIView new];
//    self.faqAnswerContainner.delaysContentTouches = NO;
    self.faqAnswerContainner.userInteractionEnabled = YES;
    [self.bubbleView addSubview:self.faqAnswerContainner];
    
    self.messageLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    self.messageLabel.numberOfLines = 0;
    self.messageLabel.delegate = self;
    self.messageLabel.font = ZMFontRes.font_14;
    self.messageLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    self.messageLabel.hidden = YES;
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
    
    
}

- (void)setupConstraints {
    
//    [self.bubbleView mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.nameLabel.mas_bottom).offset(kW(8));
//        make.right.equalTo(self.contentView.mas_right).offset(-kW(49));
//        make.left.equalTo(self.avatarImageView.mas_right).offset(kW(8));
//        make.bottom.equalTo(self.likeButton.mas_top).offset(-kW(8));
//    }];
    
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


    [self.faqAnswerContainner mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.bubbleView).insets(UIEdgeInsetsMake(kW(8), kW(12), kW(8), kW(12)));
    }];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self setupConstraints];
    [self.bubbleView setRoundCorners:0 topRight:12 bottomLeft:12 bottomRight:12];
//    self.contentView.backgroundColor = [UIColor colorWithRed:arc4random() % 255 / 255. green:0.5 blue:0.5 alpha:1];
    
}

- (void)configureWithMessage:(ZMMessage *)message {
    self.message = message;
//    self.messageLabel.text = message.msgBody.msgBody;
    [super configureWithMessage:message];
    
    
    
    if (message.isFromSys) {

    
    }
    
    
    [self parseAttributePartContent];
}


/// 解析富文本结构器内容
- (void)parseAttributePartContent {
    [self.faqAnswerContainner.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    __block NSInteger imgIndex = 0;
    [self.message.msgBody.faqAnswers enumerateObjectsUsingBlock:^(ZMMessageMsgBodyFaqAnswers * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *lastView = self.faqAnswerContainner.subviews.lastObject;
        
        switch (obj.type) {
            case ZMMessageFaqAnswerTypeText:
            {
                ZMAlignLabel *textLabel  = [ZMAlignLabel new];
                textLabel.numberOfLines = 0;
                textLabel.textAlignment = NSTextAlignmentLeft;
                textLabel.font = ZMFontRes.font_12;
                textLabel.text = obj.content ?: @"";
                textLabel.lineBreakMode = NSLineBreakByCharWrapping;
                textLabel.textColor = ZMColorRes.color_18243e;
//                textLabel.backgroundColor = [UIColor redColor];
//                textLabel.textInsets = UIEdgeInsetsZero;
//                [textLabel sizeToFit];
                [self.faqAnswerContainner addSubview:textLabel];
                
//                NSDictionary *attributes = @{NSFontAttributeName: ZMFontRes.font_12};


                CGSize maxSize = CGSizeMake(SCREEN_WIDTH - kW(130), CGFLOAT_MAX);

//                CGRect textRect = [textLabel.text boundingRectWithSize:maxSize
//                                                      options:NSStringDrawingUsesLineFragmentOrigin
//                                                   attributes:attributes
//                                                      context:nil];
                
                
                CGFloat textH = [ZMCommon calculateHeightWithText:textLabel.text maxWidth:maxSize.width font:textLabel.font] - 4.;
                
                
                [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(lastView ? lastView.mas_bottom : self.faqAnswerContainner.mas_top).offset(lastView ? kW(8) : 0);
                    make.left.right.equalTo(self.faqAnswerContainner);
                    make.height.mas_equalTo(textH);//textRect.size.height);
                }];
            }
                break;
            case ZMMessageFaqAnswerTypeImage:
            {
                UIImageView *imageView = [UIImageView new];
                imageView.layer.cornerRadius = kW(8);
                imageView.clipsToBounds = YES;
                imageView.userInteractionEnabled = YES;
                imageView.tag = imgIndex;
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                [self.faqAnswerContainner addSubview:imageView];
                UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTap:)];
                [imageView addGestureRecognizer:imageTap];
                CGSize picSize = [ZMCommon getMediaFitSize:CGSizeMake(obj.width, obj.height)];
                [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(lastView ? lastView.mas_bottom : self.faqAnswerContainner.mas_top).offset(lastView ? kW(8) : 0);
                    make.left.right.equalTo(self.faqAnswerContainner);
                    make.height.mas_equalTo(picSize.height);
                    make.width.mas_equalTo(picSize.width);
                }];
                
//                [imageView zm_setImageWithURL:@"https://pic.rmb.bdstatic.com/ffa3d007d8eb9015fb4a2ef20303d69b.jpeg" placeholderImage:nil encryptKey:@"" isVideo:NO completion:^(UIImage * _Nullable image, NSError * _Nullable error) {
//                    
//                }];
                
                [imageView zm_setImageWithURL:obj.imgContent.url placeholderImage:nil encryptKey:obj.imgContent.key isVideo:NO completion:^(UIImage * _Nullable image, NSError * _Nullable error) {
                    
                }];
                imgIndex++;
            }
                break;
            case ZMMessageFaqAnswerTypeHyperMix:
            {
                if(obj.mixContents.count > 0){
                    TTTAttributedLabel *descLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
                    descLabel.numberOfLines = 0;
                    descLabel.delegate = self;
                    descLabel.userInteractionEnabled = YES;
                    descLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
                    descLabel.lineBreakMode = NSLineBreakByCharWrapping;
                    descLabel.textAlignment = NSTextAlignmentLeft;
                    
                    NSString *text = @"";
                    NSArray *contents = [obj.mixContents valueForKey:@"content"];
                    if(contents.count > 0){
                        text = [contents componentsJoinedByString:@""];
                    }
   
                    __block NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:text];
                    [mutableAttributedString addAttribute:NSFontAttributeName
                                                     value:ZMFontRes.font_12
                                                     range:NSMakeRange(0, mutableAttributedString.length)];
                    [mutableAttributedString addAttribute:NSForegroundColorAttributeName
                                                    value:[UIColor blackColor]
                                                    range:NSMakeRange(0, mutableAttributedString.length)];
                    descLabel.linkAttributes = @{(NSString *)kCTForegroundColorAttributeName: (id)[ZMColorRes color_0054fcWithAlpha:1].CGColor};
                    descLabel.activeLinkAttributes = @{(NSString *)kCTForegroundColorAttributeName: (id)[ZMColorRes color_0054fcWithAlpha:1].CGColor};
                    [obj.mixContents enumerateObjectsUsingBlock:^(ZMMessageMsgBodyFaqAnswerHyperMix * _Nonnull subObj, NSUInteger idx, BOOL * _Nonnull stop) {
                        
                        if(subObj.url.length > 0){
                            NSRange urlRange = [text rangeOfString:subObj.content];
                            if (urlRange.location != NSNotFound) {
                                [mutableAttributedString addAttribute:NSForegroundColorAttributeName
                                                                value:[ZMColorRes color_0054fcWithAlpha:1]
                                                                range:urlRange];
                                [descLabel addLinkToURL:[NSURL URLWithString:subObj.url]
                                                  withRange:urlRange];
                            }
                        }
                        
                    }];
                    
                
//                    [descLabel setText:mutableAttributedString];
                    
                    descLabel.attributedText = mutableAttributedString;
                    
                    [self.faqAnswerContainner addSubview:descLabel];
                    
//                    NSDictionary *attributes = @{NSFontAttributeName: ZMFontRes.font_12};


                    CGSize maxSize = CGSizeMake(SCREEN_WIDTH - kW(130), CGFLOAT_MAX);

//                    CGRect textRect = [descLabel.text boundingRectWithSize:maxSize
//                                                          options:NSStringDrawingUsesLineFragmentOrigin
//                                                       attributes:attributes
//                                                          context:nil];
                    
                    CGFloat textH = [ZMCommon calculateHeightWithText:descLabel.text maxWidth:maxSize.width font:ZMFontRes.font_12] - 4;

                    [descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(lastView ? lastView.mas_bottom : self.faqAnswerContainner.mas_top).offset(lastView ? kW(8) : 0);
                        make.left.right.equalTo(self.faqAnswerContainner);
                        make.height.mas_equalTo(textH);//textRect.size.height);
                    }];
                }
            }
                break;
            default:
                break;
        }
    }];
}

- (void)handleImageTap:(UITapGestureRecognizer *)gesture {
    
    [self.findViewController.view endEditing:YES];
    ZMMediaGalleryView *galleryView = [[ZMMediaGalleryView alloc] initWithMediaMsgs:[ZMMessageManager sharedInstance].messages currentMsg:self.message imgContentIndex:(int)gesture.view.tag];
    galleryView.delegate = self;
    [galleryView showInView:self.findViewController.view];
    
}

#pragma mark - TTTAttributedLabelDelegate

//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    UIView *hitView = [super hitTest:point withEvent:event];
//    if ([hitView isKindOfClass:[TTTAttributedLabel class]]) {
//        return hitView;
//    }
//    return [super hitTest:point withEvent:event];
//}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
//shouldReceiveTouch:(UITouch *)touch {
//    if ([touch.view isKindOfClass:[TTTAttributedLabel class]]) {
//        return NO;  // 不让 TableView 的手势识别器处理 TTTAttributedLabel 的触摸
//    }
//    return YES;
//}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch {
    // 检查触摸的视图是否是 TTTAttributedLabel
    if ([touch.view isKindOfClass:[TTTAttributedLabel class]]) {
        TTTAttributedLabel *label = (TTTAttributedLabel *)touch.view;
        CGPoint location = [touch locationInView:label];
        
        // 获取点击位置的链接
        TTTAttributedLabelLink *link = [label linkAtPoint:location];
        if (link && link.result.resultType == NSTextCheckingTypeLink) {
            NSURL *url = link.result.URL;
            // 检查 URL 是否可以打开
            if (url && [[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                    if (success) {
                        NSLog(@"URL was opened successfully.");
                    } else {
                        NSLog(@"Failed to open URL.");
                    }
                }];
            }
            return NO;
        }
    }
    return YES;
}

//- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
//    if ([[UIApplication sharedApplication] canOpenURL:url]) {
//        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
//            if (success) {
//                NSLog(@"URL was opened successfully.");
//            } else {
//                NSLog(@"Failed to open URL.");
//            }
//        }];
//    } else {
//        NSLog(@"Cannot open URL: %@", url);
//    }
//}


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
