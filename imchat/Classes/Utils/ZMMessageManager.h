#import <Foundation/Foundation.h>
#import "ZMMessage.h"
#import "ZMTimeoutConfigRespModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface ZMMessageManager : NSObject

@property (nonatomic, strong) NSMutableArray<ZMMessage *> *messages;

@property (nonatomic, copy) NSString *sessionId;

@property (nonatomic, copy) NSString *currentUserId;

@property (nonatomic, copy) NSString *nickId;

@property (nonatomic, copy) NSString *token;

@property (nonatomic, copy) NSString *nickName;

@property (nonatomic, copy) NSString *identityID;

@property (nonatomic) NSInteger startSeq;

@property (nonatomic) NSInteger endSeq;

@property (nonatomic, strong) ZMTimeoutConfigRespModel *timeoutConfigModel;

+ (instancetype)sharedInstance;
- (void)startMsgSync;
- (void)resetTimeoutTimer;
- (void)initCacheLoadMsgs:(ActionBlock)completeBlock;
- (void)loadNextMsgsCompleteBlock:(ActionBlock)completeBlock noMoreBlock:(ActionBlock)noMoreBlock;
- (void)syncSessionList:(ZMMessageSessionList *)sessions;
- (void)upSortMsg:(ZMMessage *)message;
- (void)addMessage:(ZMMessage *)message;
- (void)deleteMessageWithId:(NSString *)messageId;
- (BOOL)deleteWithModels;
- (void)clearAllDBDatas;
- (void)updateAllMsgRead;
- (void)updateMessage:(ZMMessage *)message;
- (ZMMessage *)sendMsg:(NSString *)message msgType:(ZMMessageType)type;
- (void)markAsReadMsg:(ZMMessage *)message;

- (NSArray *)getMessagesForUserId:(NSString *)userId limit:(NSInteger)limit offset:(NSInteger)offset;
//- (NSDictionary *)getMessageWithId:(NSString *)messageId;
- (NSInteger)lastSeq;
- (NSTimeInterval)lastTimestamp;
- (ZMMessageMsgBody *)getMsgWithMsgSeq:(NSInteger)seq sessionId:(NSString *)sessionId;
- (void)clearCache;
- (void)setCacheLimit:(NSUInteger)limit;

- (NSInteger)getMsgCount;
- (NSInteger)getCurrentUidSessionListCount;
- (void)loadLocalAllMsgs;
- (void)messageHandle:(NSArray<ZMMessageMsgBody *> *)msgs;
- (void)destory;
@end

NS_ASSUME_NONNULL_END
