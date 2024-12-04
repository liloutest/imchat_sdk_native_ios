//
//  ChatViewController.h
//  imchat
//
//  Created by Lilou on 2024/10/10.
//

#import <UIKit/UIKit.h>
#import "ZMBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZMChatViewController : ZMBaseViewController
@property (nonatomic, copy) NSString *nickId;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *merchantId;
@end

NS_ASSUME_NONNULL_END
