//
//  MessageCell.h
//  imchat
//
//  Created by Lilou on 2024/10/16.
//

#import <UIKit/UIKit.h>

#import "ZMMessage.h"
NS_ASSUME_NONNULL_BEGIN

/// 目前分为 1. FAQ 2.文本 3.时间 4.图片 5.视频 大分类, 已读 ， 消息状态等封装与基类cell
@interface ZMMessageCell : UITableViewCell 
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) ZMMessage *message;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIView *bubbleView;
@property (nonatomic, strong) UIImageView *msgStatusImageView;
- (void)configureWithMessage:(ZMMessage *)message;
- (void)setupViews;
- (void)setConfigInfo;
@end

NS_ASSUME_NONNULL_END
