#import "ZMFullScreenTextView.h"

@interface ZMFullScreenTextView() <UITextViewDelegate>

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, assign) CGRect originalRect;
@property (nonatomic, strong) UIButton *downArrowButton;
@property (nonatomic, strong) ZMLabel *countLabel;
@end

@implementation ZMFullScreenTextView

- (instancetype)init {
    if (self = [super init]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = [UIColor clearColor];
    
    // 背景视图
    self.backgroundView = [[UIView alloc] init];
    self.backgroundView.backgroundColor = ZMColorRes.color_f3f5f7;
    [self addSubview:self.backgroundView];
    
    // 文本视图
    self.textView = [[ZMTextView alloc] init];
    self.textView.backgroundColor = ZMColorRes.color_f3f5f7;
    self.textView.font = ZMFontRes.font_14;
    self.textView.returnKeyType = UIReturnKeyNext;
    self.textView.delegate = self;
    self.textView.maxCount = 500;
    [self.backgroundView addSubview:self.textView];
    
    
    self.downArrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.downArrowButton setImage:[UIImage zm_imageWithName:ZMImageRes.chatTextArrorDown] forState:UIControlStateNormal];
    [self.downArrowButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.backgroundView addSubview:self.downArrowButton];
    
    
    [self.downArrowButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backgroundView.mas_safeAreaLayoutGuideTop).offset(kW(12));
        make.left.equalTo(self).offset(kW(16));
        make.size.mas_equalTo(CGSizeMake(kW(24), kW(24)));
    }];
    
    self.countLabel = [[ZMLabel alloc] init];
    self.countLabel.backgroundColor = [UIColor clearColor];
    self.countLabel.textColor = [ZMColorRes color_979797WithAlpha:1];
    self.countLabel.font = ZMFontRes.font_12;
    self.countLabel.textAlignment = NSTextAlignmentRight;
    [self.backgroundView addSubview:self.countLabel];
    
    [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.downArrowButton);
        make.right.equalTo(self.backgroundView).offset(-kW(16));
        make.left.equalTo(self.downArrowButton.mas_right);
    }];
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.downArrowButton.mas_bottom).offset(kW(16));
        make.left.equalTo(self.backgroundView).offset(kW(16));
        make.right.equalTo(self.backgroundView).offset(-kW(16));
        make.bottom.equalTo(self.backgroundView.mas_safeAreaLayoutGuideBottom);
    }];
}

- (void)showWithText:(NSString *)text fromRect:(CGRect)rect {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    
    
    // 保存原始位置
    self.originalRect = rect;
    
    // 计算起始位置（底部正方形）
    CGFloat squareSize = rect.size.width;  // 使用输入框的宽度作为正方形边长
    CGFloat startY = CGRectGetMaxY(rect);  // 从输入框底部开始
    CGRect startRect = CGRectMake(rect.origin.x, startY - squareSize, squareSize, squareSize);
    
    // 设置初始位置
    self.backgroundView.frame = startRect;
    self.textView.text = text;
    
    [self refreshCount];
    
    // 添加弹簧动画效果
    [UIView animateWithDuration:0.5 
                          delay:0 
         usingSpringWithDamping:0.8 
          initialSpringVelocity:0.5 
                        options:UIViewAnimationOptionCurveEaseOut 
                     animations:^{
        self.backgroundColor = ZMColorRes.color_f3f5f7;
        self.backgroundView.frame = self.bounds;
    } completion:^(BOOL finished) {
        if(finished){
            [self.textView becomeFirstResponder];
        }
    }];
}

- (void)dismiss {

    CGFloat squareSize = self.originalRect.size.width;
    CGFloat endY = CGRectGetMaxY(self.originalRect);
    CGRect endRect = CGRectMake(self.originalRect.origin.x, endY - squareSize, squareSize, squareSize);
    
    [UIView animateWithDuration:0.3 
                          delay:0 
                        options:UIViewAnimationOptionCurveEaseIn 
                     animations:^{
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView.frame = endRect;
    } completion:^(BOOL finished) {
        if(finished){
//            [self.textView resignFirstResponder];
            if(self.actionBlock){
                self.actionBlock();
            }
            
            [self removeFromSuperview];
        }
        
    }];
}

- (void)refreshCount{
    self.countLabel.text = [NSString stringWithFormat:@"%lu/500",(unsigned long)self.textView.text.length];
}


- (void) textViewDidChange:(UITextView *)textView {
    [self refreshCount];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
   
    NSUInteger newLength = textView.text.length - range.length + text.length;
    
 
    return newLength <= self.textView.maxCount;
}

@end
