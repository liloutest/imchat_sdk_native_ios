//
//  ZMTimeMsgCell.m
//  imchat
//
//  Created by Lilou on 2024/10/17.
//

#import "ZMTimeMsgCell.h"
#import "Masonry.h"
#import "ZMColorRes.h"
#import "ZMFontRes.h"
@interface ZMTimeMsgCell ()
//@property (nonatomic, strong) UILabel *timeLabel;
@end

@implementation ZMTimeMsgCell


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
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.numberOfLines = 0;
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLabel.text = @"2024年11月11日";
    self.timeLabel.font = ZMFontRes.chatTimeFont;
    self.timeLabel.textColor = ZMColorRes.chatTimeColor;
    [self.contentView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(kW(8), 0, kW(8), 0));
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
