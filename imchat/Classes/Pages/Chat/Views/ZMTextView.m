//
//  ZMTextView.m
//  imchat
//
//  Created by Lilou on 2024/10/21.
//

#import "ZMTextView.h"

@interface ZMTextView () <UITextViewDelegate>
@property (nonatomic, strong) UILabel *placeholderLabel;

@end

@implementation ZMTextView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.placeholderLabel = [[UILabel alloc] init];
    self.placeholderLabel.textColor = ZMColorRes.color_ebebeb;
    self.placeholderLabel.font = ZMFontRes.font_14;
    self.placeholderLabel.userInteractionEnabled = NO;
    [self addSubview:self.placeholderLabel];
    [self.placeholderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.left.equalTo(self).offset(kW(12));
        make.right.equalTo(self).offset(-kW(12));
    }];
    
//    self.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidChange)
                                                 name:UITextViewTextDidChangeNotification
                                               object:self];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
//    self.placeholderLabel.center = CGPointMake(self.placeholderLabel.center.x, self.center.y);
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    self.placeholderLabel.text = placeholder;
    [self updatePlaceholderVisibility];
}

- (void)textDidChange {
    [self updatePlaceholderVisibility];
}

- (void)updatePlaceholderVisibility {
    self.placeholderLabel.hidden = self.text.length > 0;
}

- (void)setCursorPosition:(NSUInteger)position {
    if (position > self.text.length) {
        position = self.text.length;
    }
    
    self.selectedRange = NSMakeRange(position, 0);
}


#pragma mark - UITextViewDelegate


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
   
    NSUInteger newLength = textView.text.length - range.length + text.length;
    
 
    return newLength <= self.maxCount;
}

@end
