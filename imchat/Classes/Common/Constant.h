//
//  Constant.h
//  imchat
//
//  Created by Lilou on 2024/10/11.
//

#ifndef Constant_h
#define Constant_h

#pragma mark - Screen  -
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define kScaleWidth (SCREEN_WIDTH / 375.0)

#define kScaleHeight (SCREEN_HEIGHT / 667.0)

#define kMargin 16.0

#define kButtonHeight 44.0

#define kFontSize(size) (size * kScaleWidth)

#define kW(width) (width * kScaleWidth)

#define kH(height) height//(height * kScaleWidth)

#define kZMPadding kW(8)

#pragma mark - Notification Name  -

#define kZMNetworkStatusChangeNotification @"kZMNetworkStatusChangeNotification"

#define kZMLanguageDidChangeNotification @"kZMLanguageDidChangeNotification"

/// 消息变化
#define kZMMessageDidChangeNotification @"kZMMessageDidChangeNotification"

/// 滚动条滚动到底部
#define kZMChatListScrollToBottomNotification @"kZMChatListScrollToBottomNotification"

/// 发送进度变化
#define kZMMessageFileUploadDidChangeNotification @"kZMMessageFileUploadDidChangeNotification"

#pragma mark - String

#pragma mark - Other
#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"时间:%s 行号:%d 文件名:%s\t方法名:%s\n%s\n", __TIME__,__LINE__,[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],__func__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String])
#else
#define NSLog(FORMAT, ...) nil
#endif

#define kZMsgPageNum 10

#define kZMTime_yyyyMMddHHMM @"yyyy-MM-dd HH:mm"
#define kZMTime_HHMM @"HH:mm"

#define kZMSafeStr(str) ([NSString stringWithFormat:@"%@",str])


typedef  void (^ZMReqSuccessBlock)(NSDictionary *response);

typedef  void (^ZMReqFailBlock)(NSError *error);

typedef  void (^ActionBlock)(void);


typedef void (^ProgressBlock)(CGFloat progress);

typedef NS_ENUM(NSInteger,ZMMessageGetFaqType) {
    ZMMessageGetFaqTypeGetFaq = 0,
    ZMMessageGetFaqTypeGetKnowledge,
    ZMMessageGetFaqTypeGetAnswer
};

typedef NS_ENUM(NSInteger,ZMMessageFaqAnswerType) {
    ZMMessageFaqAnswerTypeText = 0,
    ZMMessageFaqAnswerTypeImage,
    ZMMessageFaqAnswerTypeHyperMix
};

typedef NS_ENUM(NSInteger,ZMMessageType) {
    ZMMessageTypeJoinServer = 0,
    ZMMessageTypeText,
    ZMMessageTypeImg,
    ZMMessageTypeVideo,
    ZMMessageTypeCreateSessionMsgType,
    ZMMessageTypeAgentUserJoinSessionMsgType,
    ZMMessageTypeHasReadReceiptMsgType,
    ZMMessageTypeKickOffLineMsgType,
    ZMMessageTypeFaqMsgType,
    ZMMessageTypeKnowledgePointMsgType,
    ZMMessageTypeKnowledgeAnswerMsgType,
    ZMMessageTypeEndSessionMsgType
};

typedef NS_ENUM(NSInteger,ZMMessageSendStatus) {
    ZMMessageSendStatusUnread = 0,
    ZMMessageSendStatusReaded,
    ZMMessageSendStatusSending,
    ZMMessageSendStatusSendFail,
    
};

typedef NS_ENUM(NSInteger,IMLangType) {
    IMLangTypeZh = 0,
    IMLangTypeEn,
    IMLangTypeVi
    
};

#define kZMENV 0

#endif /* Constant_h */
