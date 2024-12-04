#import <UIKit/UIKit.h>
#import "ZMTextView.h"
@protocol ChatInputToolbarDelegate <NSObject>

- (void)didTapSendButton:(NSString *)message msgType:(ZMMessageType)type;
- (void)didTapImageButton;
- (void)didTextChange:(NSString *)text;
@end

@interface ZMChatInputToolbar : UIView

@property (nonatomic, weak) id<ChatInputToolbarDelegate> delegate;
@property (nonatomic, strong) ZMTextView *inputTextView;
- (instancetype)initWithFrame:(CGRect)frame;
- (void)clearInput;

@end
