//
//  ZMTextMsgCellTableViewCell.m
//  imchat
//
//  Created by Lilou on 2024/10/16.
//

#import "ZMTextMsgCell.h"
#import "Masonry.h"
#import "ZMColorRes.h"

@interface ZMTextMsgCell ()
@property (nonatomic, strong) UILabel *messageLabel;

@end

@implementation ZMTextMsgCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    [super setupViews];
    self.messageLabel = [[UILabel alloc] init];
    self.messageLabel.numberOfLines = 0;
    self.messageLabel.font = ZMFontRes.font_14;
    self.messageLabel.textAlignment = NSTextAlignmentLeft;
    [self.bubbleView addSubview:self.messageLabel];
}
//
- (void)layoutSubviews{
    [super layoutSubviews];
//    self.contentView.backgroundColor = self.backgroundColor = ZMColorRes.bgGrayColor;
    [self.bubbleView setRoundCorners:self.message.isFromSys ? 0 : kW(12) topRight:self.message.isFromSys ? kW(12) : 0 bottomLeft:kW(12) bottomRight:kW(12)];

    
}


- (void)configureWithMessage:(ZMMessage *)message{
    self.message = message;
    self.messageLabel.text = message.msgBody.msgBody;
    [super configureWithMessage:message];
    
    
    NSDictionary *attributes = @{NSFontAttributeName: ZMFontRes.font_14};


    CGSize maxSize = CGSizeMake(kW(246), CGFLOAT_MAX);

    CGRect textRect = [self.messageLabel.text boundingRectWithSize:maxSize
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:attributes
                                          context:nil];
    
    if(message.isFromSys){
        
        self.msgStatusImageView.hidden = YES;
        
        if(textRect.size.height <= kW(30)){
            [self.bubbleView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.nameLabel.mas_bottom).offset(kW(8));
                make.width.mas_equalTo([ZMCommon getTextWidthForLabel:self.messageLabel] + (kW(24)));
                make.left.equalTo(self.avatarImageView.mas_right).offset(kW(8));
                make.bottom.equalTo(self.contentView).offset(-kW(8));
            }];
            
            
        }
        else{
            [self.bubbleView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.nameLabel.mas_bottom).offset(kW(8));
                make.right.equalTo(self.contentView.mas_right).offset(-kW(50));
                make.left.equalTo(self.avatarImageView.mas_right).offset(kW(8));
                make.bottom.equalTo(self.contentView).offset(-kW(8));
            }];
            
        }
        
        [self.msgStatusImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.bubbleView);
            make.left.equalTo(self.bubbleView.mas_right).offset(kW(8));
        }];
        [self.messageLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.bubbleView).insets(UIEdgeInsetsMake(kW(8), kW(12), kW(8), kW(12)));
        }];
        
        [self.avatarImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).offset(kW(16));
            make.top.equalTo(self.timeLabel.hidden ? self.contentView.mas_top : self.timeLabel.mas_bottom).offset(kW(8));
            make.size.mas_equalTo(CGSizeMake(kW(40), kW(40)));
        }];
        
        self.bubbleView.backgroundColor = ZMColorRes.chatCellBgColor;
        
    }else {
        // right
        self.msgStatusImageView.hidden = NO;
        self.bubbleView.backgroundColor = ZMColorRes.color_0054fc;
        if(textRect.size.height <= kW(30)){
            [self.bubbleView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.nameLabel.mas_bottom).offset(kW(8));
                make.width.mas_equalTo([ZMCommon getTextWidthForLabel:self.messageLabel] + (kW(24)));
                make.right.equalTo(self.avatarImageView.mas_left).offset(-(kW(8)));
                make.bottom.equalTo(self.contentView).offset(-kW(8));
            }];
        }
        else{
            [self.bubbleView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.nameLabel.mas_bottom).offset(kW(8));
                make.right.equalTo(self.avatarImageView.mas_left).offset(-(kW(8)));
                make.left.equalTo(self.contentView.mas_left).offset(kW(50));
                make.bottom.equalTo(self.contentView).offset(-kW(8));
            }];
        }
        
        [self.messageLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.bubbleView).insets(UIEdgeInsetsMake(kW(8), kW(12), kW(8), kW(12)));
        }];
        [self.msgStatusImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.bubbleView);
            make.right.equalTo(self.bubbleView.mas_left).offset(-kW(8));
        }];
        
        [self.avatarImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView.mas_right).offset(-kW(16));
            make.top.equalTo(self.timeLabel.hidden ? self.contentView.mas_top : self.timeLabel.mas_bottom).offset(kW(8));
            make.size.mas_equalTo(CGSizeMake(kW(40), kW(40)));
        }];
        
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
