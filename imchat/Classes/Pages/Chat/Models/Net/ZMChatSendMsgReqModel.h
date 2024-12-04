//
//  ZMChatSendMsgReqModel.h
//  imchat
//
//  Created by Lilou on 2024/10/23.
//

#import "ZMResponseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZMChatSendMsgReqModel : ZMResponseModel
@property (nonatomic,copy) NSString *clientMsgID;
@property (nonatomic,copy) NSString *msgBody;
@property (nonatomic) NSInteger msgSeq;
@property (nonatomic) NSInteger msgType;
@property (nonatomic) NSInteger source;
@property (nonatomic, copy) NSString *sendTime;
@end

NS_ASSUME_NONNULL_END
