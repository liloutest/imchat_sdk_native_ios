#import "ZMChatInputToolbar.h"
#import <Masonry/Masonry.h>
#import "ZMColorRes.h"
#import "ZMTextView.h"
#import "ZMChatToolBtn.h"
#import "ZMFullScreenTextView.h"
@interface ZMChatInputToolbar () <UITextViewDelegate>

@property (nonatomic, strong) ZMChatToolBtn *imageButton;

@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UIButton *upArrowButton;
@end

@implementation ZMChatInputToolbar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.backgroundColor = ZMColorRes.bgGrayColor;
//    self.clipsToBounds = NO;
//    self.layer.masksToBounds = NO;
    self.upArrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.upArrowButton.hidden = YES;
    [self.upArrowButton setImage:[UIImage zm_imageWithName:ZMImageRes.chatTextArrorUp] forState:UIControlStateNormal];
    [self.upArrowButton addTarget:self action:@selector(sendArrowUpTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.upArrowButton];
    
    
    self.imageButton = [[ZMChatToolBtn alloc] initWithImageName:ZMImageRes.choosePic action:^{
        [self imageButtonTapped];
    }];
    [self addSubview:self.imageButton];
    
    self.inputTextView = [[ZMTextView alloc] init];
    self.inputTextView.font = ZMFontRes.font_14;
    self.inputTextView.layer.cornerRadius = 12;
//    self.inputTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    self.inputTextView.layer.borderWidth = 0.5;
    self.inputTextView.delegate = self;
    self.inputTextView.placeholder = @"请输入你想咨询的问题";
    self.inputTextView.text = @"";
    self.inputTextView.maxCount = 500;
    self.inputTextView.textContainerInset = UIEdgeInsetsMake(kW(14), kW(10), kW(14), kW(36));
    self.inputTextView.showsVerticalScrollIndicator = YES;
    self.inputTextView.returnKeyType = UIReturnKeyNext;
    [self addSubview:self.inputTextView];
    
    self.sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.sendButton setImage:[UIImage zm_imageWithName:ZMImageRes.chatSend] forState:UIControlStateNormal];
    [self.sendButton addTarget:self action:@selector(sendButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.sendButton];
        
    [self setupConstraints];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self setBorderWidth:1 left:0 bottom:0 right:0 color:ZMColorRes.color_ebebeb];

}

- (void)setupConstraints {
    [self.upArrowButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kW(12));
        make.left.equalTo(self).offset(kW(16));
        make.size.mas_equalTo(CGSizeMake(kW(24), kW(24)));
    }];
    
    [self.imageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(kW(16));
//        make.centerY.equalTo(self);
        make.bottom.equalTo(self).offset(-kW(12));
        make.size.mas_equalTo(CGSizeMake(kW(42), kW(42)));
    }];
    
    [self.sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.inputTextView).offset(-kW(12));
        make.centerY.equalTo(self.imageButton);
//        make.bottom.equalTo(self).offset(-kW(12));
        make.width.mas_equalTo(kW(24));
        make.height.mas_equalTo(kW(24));
    }];
    
    [self.inputTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imageButton.mas_right).offset(kW(12));
        make.right.equalTo(self.mas_right).offset(-kW(16));
//        make.top.equalTo(self).offset(7);
//        make.centerY.equalTo(self.mas_centerY);
        make.bottom.equalTo(self).offset(-kW(12));
        make.top.equalTo(self).offset(kW(12));
//        make.bottom.equalTo(self).offset(-7);
    }];
}

- (void)imageButtonTapped {
    if ([self.delegate respondsToSelector:@selector(didTapImageButton)]) {
        [self.delegate didTapImageButton];
    }
}

- (void)sendArrowUpTapped{
    ZMFullScreenTextView *fullScreenView = [[ZMFullScreenTextView alloc] init];
    [fullScreenView showWithText:self.inputTextView.text fromRect:self.frame];
    [fullScreenView.textView setCursorPosition:self.inputTextView.selectedRange.location];
    
    __weak ZMFullScreenTextView *weakFullView = fullScreenView;
    fullScreenView.actionBlock = ^{
        self.inputTextView.text = weakFullView.textView.text;
        [self.inputTextView setCursorPosition:weakFullView.textView.selectedRange.location];
        [self.inputTextView becomeFirstResponder];
    };
}

- (void)sendButtonTapped {
    NSString *message = self.inputTextView.text;
    if (message.length > 0) {
        if ([self.delegate respondsToSelector:@selector(didTapSendButton:msgType:)]) {
            [self.delegate didTapSendButton:message msgType:ZMMessageTypeText];
        }
        [self clearInput];
    }
    
    [self.inputTextView resignFirstResponder];
    self.inputTextView.placeholder = @"请输入你想咨询的问题";
    
    self.upArrowButton.hidden = YES;
    if(self.delegate && [self.delegate respondsToSelector:@selector(didTextChange:)]){
        [self.delegate didTextChange:_inputTextView.text];
    }
}

- (void)clearInput {
    self.inputTextView.text = @"";
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView{
    self.inputTextView.placeholder = @"";
}

- (void)textViewDidChange:(UITextView *)textView {
    // 可以在这里添加动态调整高度的逻辑
    NSInteger lineCount = [self.inputTextView lineCountUsingTextKit];
    NSLog(@"文本行数: %ld", (long)lineCount);

    NSInteger maxLineCount = 2;
    if ([self.inputTextView isExceedingLineCount:maxLineCount]) {
        NSLog(@"文本超过了%ld行", (long)maxLineCount);
        self.upArrowButton.hidden = NO;
    } else {
        NSLog(@"文本没有超过%ld行", (long)maxLineCount);
        self.upArrowButton.hidden = YES;
    }
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(didTextChange:)]){
        [self.delegate didTextChange:textView.text];
    }
//    CGFloat bottomInset = self.superview.safeAreaInsets.bottom;
//    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(self.superview).offset(-bottomInset);
//        make.left.right.equalTo(self.superview);
//        make.height.mas_equalTo(6 > 3 ? kW(66) + 120 : kW(66));
//    }];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
//    if ([text isEqualToString:@"\n"]) {
//        [textView resignFirstResponder];
//        [self sendButtonTapped];
//        return NO;
//    }
   
    NSUInteger newLength = textView.text.length - range.length + text.length;
    
 
    return newLength <= self.inputTextView.maxCount;
}

@end
