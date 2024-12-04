//
//  UITextView+ZMAddon.m
//  imchat
//
//  Created by Lilou on 2024/10/22.
//

#import "UITextView+ZMAddon.h"

@implementation UITextView (ZMAddon)

//- (BOOL)isExceedingLineCount:(NSInteger)maxLineCount {
//    return [self currentLineCount] > maxLineCount;
//}
//
//- (NSInteger)currentLineCount {
//    CGFloat contentHeight = self.contentSize.height;
//    CGFloat lineHeight = self.font.lineHeight;
//    CGFloat topInset = self.textContainerInset.top;
//    CGFloat bottomInset = self.textContainerInset.bottom;
//    
//    NSInteger lineCount = (NSInteger)((contentHeight - topInset - bottomInset) / lineHeight);
//    return lineCount;
//}

- (NSInteger)lineCountUsingTextKit {
    if (self.text.length == 0) {
        return 0;
    }

    NSLayoutManager *layoutManager = self.layoutManager;
    NSTextContainer *textContainer = self.textContainer;
    NSTextStorage *textStorage = self.textStorage;

    [layoutManager ensureLayoutForTextContainer:textContainer];

    NSRange glyphRange = [layoutManager glyphRangeForTextContainer:textContainer];
    NSRange characterRange = [layoutManager characterRangeForGlyphRange:glyphRange actualGlyphRange:nil];

    NSInteger lineCount = 0;
    NSInteger index = characterRange.location;
    NSInteger maxIndex = NSMaxRange(characterRange);

    while (index < maxIndex) {
        NSRange lineRange;
        [layoutManager lineFragmentRectForGlyphAtIndex:index effectiveRange:&lineRange];
        index = NSMaxRange(lineRange);
        lineCount++;
    }

    return lineCount;
}

- (BOOL)isExceedingLineCount:(NSInteger)maxLineCount {
    return [self lineCountUsingTextKit] > maxLineCount;
}
@end
