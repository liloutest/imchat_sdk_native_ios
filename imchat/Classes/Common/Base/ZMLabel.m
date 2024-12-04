//
//  ZMLabel.m
//  imchat
//
//  Created by Lilou on 2024/10/22.
//

#import "ZMLabel.h"

@implementation ZMLabel


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _textInsets = UIEdgeInsetsZero;
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.textInsets)];
}

- (CGSize)intrinsicContentSize {
    CGSize size = [super intrinsicContentSize];
    size.width += self.textInsets.left + self.textInsets.right;
    size.height += self.textInsets.top + self.textInsets.bottom;
    return size;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize fitSize = [super sizeThatFits:size];
    fitSize.width += self.textInsets.left + self.textInsets.right;
    fitSize.height += self.textInsets.top + self.textInsets.bottom;
    return fitSize;
}
@end
