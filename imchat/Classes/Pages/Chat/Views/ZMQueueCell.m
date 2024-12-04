//
//  ZMQueueCell.m
//  imchat
//
//  Created by Lilou on 2024/10/22.
//

#import "ZMQueueCell.h"
#import <TTTAttributedLabel/TTTAttributedLabel.h>
@interface ZMQueueCell ()
@property (nonatomic, strong) TTTAttributedLabel *descLabel;
@end

@implementation ZMQueueCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    [super setupViews];
    self.avatarImageView.hidden = YES;
    self.nameLabel.hidden = YES;
    self.bubbleView.hidden = YES;
    self.descLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    self.descLabel.numberOfLines = 0;
    self.descLabel.textAlignment = NSTextAlignmentCenter;
    NSString *text = @"正在为您努力转接到人工服务中，当前排队人数 1 人，请稍后～ 如您长时间未回复，会话结束";
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:text];
    [mutableAttributedString addAttribute:NSFontAttributeName
                                     value:ZMFontRes.chatTimeFont
                                     range:NSMakeRange(0, mutableAttributedString.length)];
    [mutableAttributedString addAttribute:NSForegroundColorAttributeName
                                    value:[ZMColorRes color_979797WithAlpha:1]
                                    range:NSMakeRange(0, mutableAttributedString.length)];
    NSRange urlRange = [text rangeOfString:@"1"];
    if (urlRange.location != NSNotFound) {
        [mutableAttributedString addAttribute:NSForegroundColorAttributeName
                                        value:[ZMColorRes color_0054fcWithAlpha:1]
                                        range:urlRange];
    }
    
    
    

    [self.descLabel setText:mutableAttributedString];

    [self.contentView addSubview:self.descLabel];
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(0, kW(16), 0, kW(16)));
    }];
}

- (void)configureWithMessage:(ZMMessage *)message{
    [super configureWithMessage:message];
//    self.timeLabel.text = message.text;
//    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.bubbleView).insets(UIEdgeInsetsMake(8, 12, 8, 12));
//    }];
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
