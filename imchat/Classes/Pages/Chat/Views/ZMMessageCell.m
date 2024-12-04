//
//  MessageCell.m
//  imchat
//
//  Created by Lilou on 2024/10/16.
//

#import "ZMMessageCell.h"
#import <Masonry.h>
#import "UIImageView+ZMAddon.h"
#import "ZMColorRes.h"
#import "ZMFontRes.h"
#import "UIView+ZMAddon.h"

@implementation ZMMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setConfigInfo{
    
}

- (void)setupViews {
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.numberOfLines = 0;
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLabel.text = @"2024年11月11日";
    self.timeLabel.font = ZMFontRes.chatTimeFont;
    self.timeLabel.textColor = ZMColorRes.chatTimeColor;
    self.timeLabel.hidden = YES;
    [self.contentView addSubview:self.timeLabel];

    
    self.bubbleView = [[UIView alloc] init];
//    self.bubbleView.layer.cornerRadius = 8;
    MASAttachKeys(self.bubbleView);
    self.bubbleView.backgroundColor = ZMColorRes.chatCellBgColor;
    [self.contentView addSubview:self.bubbleView];
    
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor =  ZMColorRes.bgGrayColor;
    self.avatarImageView = [[UIImageView alloc] init];
    self.avatarImageView.layer.cornerRadius = kW(20);
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.tag = 1200;
    MASAttachKeys(self.avatarImageView);
    [self.contentView addSubview:self.avatarImageView];
    
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.textColor = ZMColorRes.chatTimeColor;
    self.nameLabel.font = ZMFontRes.chatNameFont;
    MASAttachKeys(self.nameLabel);
    self.nameLabel.textColor = [ZMColorRes color_979797WithAlpha:1];
    [self.contentView addSubview:self.nameLabel];
    
    self.msgStatusImageView = [[UIImageView alloc] init];
    self.msgStatusImageView.clipsToBounds = YES;
    MASAttachKeys(self.msgStatusImageView);
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.msgStatusImageView addGestureRecognizer:singleTap];
    [self.contentView addSubview:self.msgStatusImageView];
    self.contentView.backgroundColor = self.backgroundColor = ZMColorRes.bgGrayColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
}

- (void)handleSingleTap:(UITapGestureRecognizer *)gesture {
    self.message.sendStatus = ZMMessageSendStatusSending;
//    if([self.message.msgBody.msgBody isEqualToString:@"000"])
//    {
//        NSLog(@"000");
//    }
    [self refreshMsgStatus];
//    self.message.msgBody.sendTime = self.message.msgBody.createTime;
//    self.message.createTime = self.message.msgBody.createTime;
//    self.message.sendTime = self.message.msgBody.sendTime;
    [ZMHttpHelper sendMessage:self.message headers:nil success:^(NSDictionary *response) {
        ZMChatSendMsgRepModel *msgRepModel = [ZMChatSendMsgRepModel modelWithJSON:response];
        NSLog(@"msg_req = %ld",msgRepModel.msgReq);
        self.message.sendStatus = ZMMessageSendStatusUnread;
        self.message.msgBody.createTime = [ZMCommon zeroZoneTimestamp];
        self.message.createTime = self.message.msgBody.createTime;
        self.message.msgBody.msgSeq = msgRepModel.msgReq;
        self.message.msgBody.sendTimeStamp = [ZMCommon zeroZoneTimestamp];
        self.message.sendTimeStamp = self.message.msgBody.sendTimeStamp;
//        self.message
        [[ZMMessageManager sharedInstance] upSortMsg:self.message];
//        [[ZMMessageManager sharedInstance] updateMessage:self.message];
//        [self setNeedsLayout];
        [self refreshMsgStatus];
        
    } failure:^(NSError *error) {
        self.message.sendStatus = ZMMessageSendStatusSendFail;
        self.message.msgBody.createTime = [ZMCommon zeroZoneTimestamp];
        self.message.createTime = self.message.msgBody.createTime;
        self.message.msgBody.sendTimeStamp = [ZMCommon zeroZoneTimestamp];
        self.message.sendTimeStamp = self.message.msgBody.sendTimeStamp;
        [[ZMMessageManager sharedInstance] upSortMsg:self.message];
//        [[ZMMessageManager sharedInstance] updateMessage:self.message];
//        [self setNeedsLayout];
        [self refreshMsgStatus];
    }];
}

- (void)refreshMsgStatus {
    switch (self.message.sendStatus) {
        case ZMMessageSendStatusReaded:
            self.msgStatusImageView.image = [UIImage zm_imageWithName:ZMImageRes.chatMsgRead];
            break;
        case ZMMessageSendStatusUnread:
            self.msgStatusImageView.image = [UIImage zm_imageWithName:ZMImageRes.chatMsgUnRead];
            break;
        case ZMMessageSendStatusSending:
            self.msgStatusImageView.image = [UIImage zm_imageWithName:ZMImageRes.chatMsgLoad];
            break;
        case ZMMessageSendStatusSendFail:
            self.msgStatusImageView.userInteractionEnabled = YES;
            self.msgStatusImageView.image = [UIImage zm_imageWithName:ZMImageRes.chatMsgFail];
            break;
        default:
            break;
    }
}

- (void)configureWithMessage:(ZMMessage *)message {
    self.message = message;
    
    self.msgStatusImageView.userInteractionEnabled = NO;
    self.timeLabel.hidden = ![message.msgBody showTime];
    self.timeLabel.text = [ZMCommon timestampToZeroZoneWithTime:message.msgBody.createTime];

    [self refreshMsgStatus];
    
    
    [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(0,kW(8), 0, kW(8)));
        make.left.equalTo(self.contentView).offset(kW(8));
        make.right.equalTo(self.contentView).offset(-kW(8));
        make.top.equalTo(self.contentView).offset(kW(8));
        make.height.mas_equalTo(_timeLabel.hidden ? 0 : kW(15));
    }];
    
    if(message.isFromSys){
        self.nameLabel.text = @"客服机器人";
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        self.avatarImageView.image = [UIImage zm_imageWithName:ZMImageRes.chatSystemAvatar];
//        [self.avatarImageView zm_setImageWithURL:ZMImageRes.chatSystemAvatar placeholderImage:nil];
        [self.avatarImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).offset(kW(16));
            make.top.equalTo(_timeLabel.hidden ? self.contentView.mas_top : self.timeLabel.mas_bottom).offset(kW(8));
            make.size.mas_equalTo(CGSizeMake(kW(40), kW(40)));
        }];
        
    
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.avatarImageView.mas_right).offset(kW(8));
            make.top.equalTo(self.avatarImageView.mas_top);
            make.right.equalTo(self.contentView.mas_right).offset(-kW(16));
        }];
        
        [self.bubbleView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.nameLabel.mas_bottom).offset(kW(8));
//            make.right.equalTo(self.avatarImageView.mas_left).offset(-8);
            make.right.equalTo(self.contentView.mas_right).offset(-kW(50));
            make.left.equalTo(self.avatarImageView.mas_right).offset(kW(8));
            make.bottom.equalTo(self.contentView).offset(-kW(8));
        }];
        
    }else {
        // right
        self.nameLabel.text = [ZMMessageManager sharedInstance].nickName;
        self.nameLabel.textAlignment = NSTextAlignmentRight;
//        self.avatarImageView.image = [UIImage zm_imageWithName:ZMImageRes.chatSystemAvatar];
        [self.avatarImageView zm_setImageWithURL:@"https://img1.baidu.com/it/u=1653751609,236581088&fm=253&app=120&size=w931&n=0&f=JPEG&fmt=auto?sec=1729270800&t=36600cf9ed9f2ffddb3a3bb1ec5bd144" placeholderImage:nil];
        [self.avatarImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView.mas_right).offset(-kW(16));
            make.top.equalTo(_timeLabel.hidden ? self.contentView.mas_top : self.timeLabel.mas_bottom).offset(kW(8));
            make.size.mas_equalTo(CGSizeMake(kW(40), kW(40)));
        }];
        
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).offset(kW(16));
            make.top.equalTo(self.avatarImageView.mas_top);
            make.right.equalTo(self.avatarImageView.mas_left).offset(-kW(8));
        }];
        
        [self.bubbleView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.nameLabel.mas_bottom).offset(kW(8));
            make.left.equalTo(self.contentView.mas_left).offset(kW(50));
            make.right.equalTo(self.avatarImageView.mas_left).offset(-kW(8));
            make.bottom.equalTo(self.contentView).offset(-kW(8));
        }];
    }
}

@end



