//
//  ZMServicerStatusCell.m
//  imchat
//
//  Created by Lilou on 2024/10/22.
//

#import "ZMServicerStatusCell.h"

@interface ZMServicerStatusCell ()
@property (nonatomic, strong) ZMLabel *statusLabel;

@end

@implementation ZMServicerStatusCell

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
    
    
    
    self.statusLabel = [[ZMLabel alloc] init];
    self.statusLabel.numberOfLines = 0;
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.text = @"客服007 将为您服务";
    self.statusLabel.backgroundColor = [UIColor whiteColor];
    self.statusLabel.font = ZMFontRes.chatTimeFont;
    self.statusLabel.textColor = [UIColor blackColor];
    self.statusLabel.textInsets = UIEdgeInsetsMake(kW(3), kW(8), kW(3), kW(8));
    self.statusLabel.layer.cornerRadius = kW(4);
    [self.contentView addSubview:self.statusLabel];
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(3, 8, 3, 8));
        make.center.equalTo(self);
    }];
}


- (void)configureWithMessage:(ZMMessage *)message{
    [super configureWithMessage:message];
    
//    CGSize size = [self.statusLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];

    
//    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
////        make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(8, 0, 8, 0));
//        make.center.equalTo(self);
//        make.width.mas_equalTo(kW(size.width));
//        make.height.mas_equalTo(kW(20));
//    }];
    
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
