//
//  ZMHistoryRepModel.h
//  imchat
//
//  Created by Lilou on 2024/10/23.
//

#import "ZMResponseModel.h"

@class ZMMessageMsgBody;

NS_ASSUME_NONNULL_BEGIN

@interface ZMHistoryItemContent : ZMResponseModel
//@property (nonatomic) NSInteger create_time;
//@property (nonatomic, copy) NSString *msg_body;
//@property (nonatomic) NSInteger msg_seq;
//@property (nonatomic) NSInteger msg_type;
//@property (nonatomic, copy) NSString *receiver_uid;
//@property (nonatomic, copy) NSString *sender_uid;
//@property (nonatomic) NSInteger status;
/// 客户端自定义消息ID
@property (nonatomic, copy) NSString *clientMsgID;
@property (nonatomic, copy) NSString *senderUid;
@property (nonatomic, copy) NSString *receiverUid;
@property (nonatomic) ZMMessageType msgType;
@property (nonatomic, copy) NSString *encKey;
@property (nonatomic, copy) NSString *msgBody;
@property (nonatomic) NSInteger msgSeq;
/// 0-未读， 1-已读
@property (nonatomic) NSInteger status;
@property (nonatomic) NSInteger createTime;
@property (nonatomic) NSInteger sendTime;
@end


@interface ZMHistoryRepModel : ZMResponseModel
//@property (nonatomic, strong) NSArray<ZMHistoryItemContent *> *content;
@property (nonatomic, strong) NSArray<ZMMessageMsgBody *> *content;
/// 该会话总的消息数
@property (nonatomic) NSInteger total;
@end



NS_ASSUME_NONNULL_END
