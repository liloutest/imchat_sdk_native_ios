//
//  ZMMessage.h
//  imchat
//
//  Created by Lilou on 2024/10/16.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZMModel.h"
@class ZMUploadTask;
NS_ASSUME_NONNULL_BEGIN

@interface ZMMessageState : ZMModel
@property (nonatomic) NSInteger code;
@property (nonatomic, copy) NSString *message;
@end

@interface ZMMessageJoin : ZMModel
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *sessionId;
@property (nonatomic, copy) NSString *token;
@end

@interface ZMMessageMsgBodyMediaJsonItem : ZMModel
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *key;
@end

@interface ZMMessageMsgBodyMediaJson : ZMModel
@property (nonatomic) NSInteger width;
@property (nonatomic) NSInteger height;
@property (nonatomic, strong) ZMMessageMsgBodyMediaJsonItem *thumbnail;
@property (nonatomic, strong) ZMMessageMsgBodyMediaJsonItem *resource;
@end

// == FaqAnswer
@interface ZMMessageMsgBodyFaqAnswerHyperMix : ZMModel
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *url;

@end

@interface ZMMessageMsgBodyFaqAnswers : ZMModel
@property (nonatomic) NSInteger width;
@property (nonatomic) NSInteger height;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, strong) ZMMessageMsgBodyMediaJsonItem *imgContent;
@property (nonatomic) ZMMessageFaqAnswerType type;
@property (nonatomic, copy) NSString *contents;
@property (nonatomic, strong) NSArray<ZMMessageMsgBodyFaqAnswerHyperMix *> *mixContents;
@end
// == FaqAnswer


// == Faq
@interface ZMMessageMsgBodyFaqItem: ZMModel
@property (nonatomic, copy) NSString *fId;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) ZMMessageMsgBodyMediaJsonItem *urlContent;
@property (nonatomic, copy) NSString *knowledgeBaseName;
@end

@interface ZMMessageMsgBodyFaq: ZMModel
@property (nonatomic, copy) NSString *knowledgeBaseTitle;
@property (nonatomic, strong) NSArray<ZMMessageMsgBodyFaqItem *> *knowledgeBaseList;
@end
// == Faq

// == Faq Point
@interface ZMMessageMsgBodyFaqPoint: ZMModel
@property (nonatomic, copy) NSString *fId;
@property (nonatomic, copy) NSString *knowledgePointName;
@end
// == Faq Point

@interface ZMMessageMsgBody : ZMModel
@property (nonatomic, copy) NSString *senderUid;
@property (nonatomic, copy) NSString *receiverUid;
@property (nonatomic) ZMMessageType msgType;
@property (nonatomic, copy) NSString *encKey;
@property (nonatomic, copy) NSString *msgBody;
@property (nonatomic) NSInteger msgSeq;
@property (nonatomic) NSInteger status;
@property (nonatomic) NSInteger createTime;
@property (nonatomic, copy) NSString *clientMsgId;
//@property (nonatomic, copy) NSString *clientMsgID;
@property (nonatomic, copy) NSString *sessionId;
@property (nonatomic, copy) NSString *sendTime;

// custom
//@property (nonatomic) BOOL showTime;
@property (nonatomic) NSInteger sendTimeStamp;
- (BOOL)showTime;
@property (nonatomic) NSInteger thumbHeight;
- (ZMMessageMsgBodyMediaJsonItem *)thumbnail;
- (ZMMessageMsgBodyMediaJsonItem *)resource;
@property (nonatomic) ZMMessageSendStatus sendStatus;
@property (nonatomic) CGFloat height;
@property (nonatomic, strong) ZMUploadTask *task;
@property (nonatomic, strong) NSArray<ZMMessageMsgBodyFaqAnswers *> *faqAnswers;
@property (nonatomic, strong) ZMMessageMsgBodyFaq *faq;
@property (nonatomic, strong) NSArray<ZMMessageMsgBodyFaqPoint *> *faqPoints;
@end


@interface ZMMessageSessionBaisc : ZMModel
@property (nonatomic, copy) NSString *sessionId;
@property (nonatomic, copy) NSString *headIcon;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *devNo;
@property (nonatomic, copy) NSString *language;
@property (nonatomic, copy) NSString *extra;
@property (nonatomic) NSInteger createTime;
@property (nonatomic, strong) ZMMessageMsgBody *latestMsg;
@end

@interface ZMMessageCreateSession : ZMModel
@property (nonatomic, strong) ZMMessageSessionBaisc *sessionBasic;
@end

@interface ZMMessageAgentUserJoinSession : ZMModel
@property (nonatomic, copy) NSString *username;
@end

@interface ZMMessageHasReadReceiptMsg : ZMModel
@property (nonatomic, copy) NSString *sessionID;
@property (nonatomic, strong) NSArray<NSNumber *> *hasReadSeqs;
@end

@interface ZMMessageEndSessionMsg : ZMModel
@property (nonatomic, copy) NSString *sessionID;
@end

@interface ZMMessage : ZMModel
@property (nonatomic) ZMMessageType msgType;
@property (nonatomic,strong) ZMMessageState *state;
@property (nonatomic) NSInteger seq;
@property (nonatomic,strong) ZMMessageJoin *join_rename;
@property (nonatomic,strong) ZMMessageMsgBody *msgBody;
@property (nonatomic,strong) ZMMessageCreateSession *createSessionMsg;
@property (nonatomic,strong) ZMMessageAgentUserJoinSession *agentUserJoinSessionMsg;
@property (nonatomic,strong) ZMMessageHasReadReceiptMsg *hasReadReceiptMsg;
@property (nonatomic,strong) ZMMessageEndSessionMsg *endSessionMsg;

// 定位不同会话数据
@property (nonatomic, copy) NSString *sessionId;
@property (nonatomic, assign) BOOL isFromSys;
// custom
@property (nonatomic) ZMMessageSendStatus sendStatus;
@property (nonatomic) NSInteger createTime;
@property (nonatomic) NSInteger sendTimeStamp;
- (instancetype)initWithText:(NSString *)text type:(ZMMessageType)type isFromUser:(BOOL)isFromUser;
@property (nonatomic) CGFloat height;
//- (CGFloat)height;
//@property (nonatomic) CGFloat mediaHeight;
@end




@interface ZMMessageLatestMsgBody  : ZMModel
@property (nonatomic, copy) NSString *senderUid;
@property (nonatomic, copy) NSString *receiverUid;
@property (nonatomic) ZMMessageType msgType;
@property (nonatomic, copy) NSString *encKey;
@property (nonatomic, copy) NSString *msgBody;
@property (nonatomic) NSInteger msgSeq;
@property (nonatomic) NSInteger status;
@property (nonatomic) NSInteger createTime;
@property (nonatomic, copy) NSString *clientMsgID;
@property (nonatomic, copy) NSString *sessionId;
@property (nonatomic, copy) NSString *sendTime;
@end

// 不能复用已有 ，数据库防止循环引用
@interface ZMMessageSessionItem : ZMModel
@property (nonatomic, copy) NSString *sessionId;
@property (nonatomic, copy) NSString *headIcon;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *devNo;
@property (nonatomic, copy) NSString *language;
@property (nonatomic, copy) NSString *extra;
@property (nonatomic) NSInteger createTime;
@property (nonatomic, strong) ZMMessageLatestMsgBody *latestMsg;
@end

@interface ZMMessageSessionList : ZMModel
@property (nonatomic,strong) NSArray<ZMMessageSessionItem *> *sessionList;
@property (nonatomic) NSInteger total;
@end


NS_ASSUME_NONNULL_END
