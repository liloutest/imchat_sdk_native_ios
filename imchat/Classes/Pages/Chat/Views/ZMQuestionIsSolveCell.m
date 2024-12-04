//
//  ZMQuestionIsSolveCell.m
//  imchat
//
//  Created by Lilou on 2024/10/22.
//

#import "ZMQuestionIsSolveCell.h"
#import <Masonry.h>
#import "UIImageView+ZMAddon.h"
#import "ZMColorRes.h"
#import "ZMFontRes.h"
#import "UIView+ZMAddon.h"

@interface ZMQuestionIsSolveCell ()
@property (nonatomic, strong) ZMLabel *messageLabel;
@property (nonatomic, strong) ZMLabel *solveLabel;
@property (nonatomic, strong) ZMLabel *unSolveLabel;
@property (nonatomic, strong) UIView *bgView;

@end

@implementation ZMQuestionIsSolveCell

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
    
    
    self.bgView = [UIView new];
    self.bgView.backgroundColor = [UIColor whiteColor];
    self.bgView.layer.cornerRadius = kW(16);
    [self.contentView addSubview:self.bgView];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(0, kW(48), 0, kW(48)));
    }];
    
    self.messageLabel = [[ZMLabel alloc] init];
    self.messageLabel.numberOfLines = 0;
    self.messageLabel.textAlignment = NSTextAlignmentCenter;
    self.messageLabel.text = @"您的问题是否得到解决";
    self.messageLabel.font = ZMFontRes.font_14;
    self.messageLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:self.messageLabel];
    [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bgView.mas_top).offset(kW(20));
        make.left.equalTo(self.bgView.mas_left).offset(kW(8));
        make.right.equalTo(self.bgView.mas_right).offset(-kW(8));
    }];
    
    self.solveLabel = [[ZMLabel alloc] init];
    self.solveLabel.numberOfLines = 0;
    self.solveLabel.textAlignment = NSTextAlignmentCenter;
    self.solveLabel.text = @"已解决";
    self.solveLabel.backgroundColor = ZMColorRes.color_0054fc;
    self.solveLabel.font = ZMFontRes.font_12;
    self.solveLabel.clipsToBounds = YES;
    self.solveLabel.layer.cornerRadius = kW(16);
    self.solveLabel.userInteractionEnabled = YES;
    self.solveLabel.textColor = [UIColor blackColor];
//    self.solveLabel.textInsets = UIEdgeInsetsMake(8, 37, 8, 37);
    [self.contentView addSubview:self.solveLabel];
    UITapGestureRecognizer *solveTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSolveTap:)];
    [self.solveLabel addGestureRecognizer:solveTap];
    [self.solveLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.bgView.mas_bottom).offset(-kW(20));
        make.left.equalTo(self.bgView.mas_left).offset(kW(20));
        make.width.mas_equalTo(kW(109));
        make.height.mas_equalTo(kW(32));
    }];
    
    self.unSolveLabel = [[ZMLabel alloc] init];
    self.unSolveLabel.numberOfLines = 0;
    self.unSolveLabel.userInteractionEnabled = YES;
    self.unSolveLabel.backgroundColor = ZMColorRes.color_0054fc;
    self.unSolveLabel.textAlignment = NSTextAlignmentCenter;
    self.unSolveLabel.text = @"未解决";
    self.unSolveLabel.clipsToBounds = YES;
    self.unSolveLabel.font = ZMFontRes.font_12;
    self.unSolveLabel.textColor = [UIColor blackColor];
    self.unSolveLabel.layer.cornerRadius = kW(16);
    UITapGestureRecognizer *unSolveTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleUnSolveTap:)];
    [self.unSolveLabel addGestureRecognizer:unSolveTap];
//    self.unSolveLabel.textInsets = UIEdgeInsetsMake(8, 8, 8, 8);
    [self.contentView addSubview:self.unSolveLabel];
    
    [self.unSolveLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.bgView.mas_bottom).offset(-kW(20));
        make.right.equalTo(self.bgView.mas_right).offset(-kW(20));
        make.width.mas_equalTo(kW(109));
        make.height.mas_equalTo(kW(32));
    }];
}

- (void)setupConstraints {

}

- (void)handleSolveTap:(UITapGestureRecognizer *)tap
{
    if(self.solveBlock){
        self.solveBlock(self.message, YES);
    }
}

- (void)handleUnSolveTap:(UITapGestureRecognizer *)tap
{
    if(self.solveBlock){
        self.solveBlock(self.message, NO);
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setupConstraints];
    
}

- (void)configureWithMessage:(ZMMessage *)message{
    [super configureWithMessage:message];
    self.message = message;
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
