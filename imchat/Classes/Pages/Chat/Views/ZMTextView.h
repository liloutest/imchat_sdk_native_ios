//
//  ZMTextView.h
//  imchat
//
//  Created by Lilou on 2024/10/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZMTextView : UITextView
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic) int maxCount;
- (void)setCursorPosition:(NSUInteger)position;
@end

NS_ASSUME_NONNULL_END
