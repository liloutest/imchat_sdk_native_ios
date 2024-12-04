#import "ZMMessageManager.h"
#import "ZMDatabaseManager.h"
#import "ZMFloatChatToolView.h"
#define kZMMessageSyncSp 10

static ZMMessageManager *_instance = nil;

@interface ZMMessageManager ()

@property (nonatomic, strong) NSCache *messageCache;
@property (nonatomic, strong) NSMutableDictionary *userMessagesCache;
@property (nonatomic, strong) NSTimer *msgSyncTimer;
@property (nonatomic, strong) NSTimer *timeoutTipTimer;
@property (nonatomic) NSInteger preSessionMsgSeq;
@property (nonatomic) NSTimeInterval preSessionCreateTime;
@property (nonatomic, strong) ZMMessageSessionItem *latestSession;
@property (nonatomic, strong) NSTimer *longTimeNoReplyTimer;
@end


@implementation ZMMessageManager

+ (instancetype)sharedInstance {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}



- (instancetype)init {
    self = [super init];
    if (self) {
        _messageCache = [[NSCache alloc] init];
        _messageCache.countLimit = 1000;
        _sessionId = @"";
        _token = @"";
        _currentUserId = @"";
        _userMessagesCache = [NSMutableDictionary dictionary];
        _preSessionMsgSeq = _preSessionCreateTime = NSNotFound;
        _startSeq = _endSeq = NSNotFound;
    }
    return self;
}

- (NSMutableArray<ZMMessage *> *)messages {
    if(!_messages){
        _messages = [NSMutableArray array];
    }
    return _messages;
}

// 启动消息同步
- (void)startMsgSync {
    [self startMsgSyncTimer];
}


- (ZMMessageSessionItem *)latestSession {
    // 通过uid 过滤当前用户的按时间降序排序的会话列表，倒序往上取
    if(!_latestSession){
        NSArray<ZMMessageSessionItem *> *sessions = [[ZMDatabaseManager sharedInstance] queryObjectsOfClass:ZMMessageSessionItem.class withWhere:[NSString stringWithFormat:@"uid = '%@' AND createTime < %f",self.currentUserId,self.preSessionCreateTime] orderBy:@"createTime DESC"];

        if(sessions.count > 0){
            _latestSession = sessions.firstObject;
            _preSessionCreateTime = sessions.firstObject.createTime;
//            _preSessionMsgSeq = sessions.firstObject.latestMsg.msgSeq;
        }
        else{
            _latestSession = nil;
//            _preSessionMsgSeq = NSNotFound;
            _preSessionCreateTime = 0;
        }
    }
    return _latestSession;
}

// 从本地DB读取某会话区间MSGBODY数据
- (NSArray<ZMMessageMsgBody *> *)getMsgsBetweenStartSeq:(NSInteger)startSeq endSeq:(NSInteger)endSeq sessionId:(NSString *)sessionId {
    NSArray<ZMMessageMsgBody *> *msgs = [[ZMDatabaseManager sharedInstance] queryObjectsOfClass:ZMMessageMsgBody.class withWhere:[NSString stringWithFormat:@"sessionId = '%@' AND msgSeq >= %ld AND msgSeq <= %ld and msgType != 0",sessionId,startSeq,endSeq] orderBy:@"sendTimeStamp DESC"];
    
    if(msgs.count > 0){
        return msgs;
    }
    return nil;
}

- (void)initCacheLoadMsgs:(ActionBlock)completeBlock {
    NSString *finalSessionId = self.latestSession ? self.latestSession.latestMsg.sessionId : self.sessionId;
    if(finalSessionId.length == 0)return;
    
    
    
    // 设为NO 则 会每次从服务端拉取配合loadAllDatas ; 为YES 则可有本地缓存优先读取，没有在拉取
    NSInteger curSeq = [self getLatestSessionSeq:finalSessionId desc:YES];

    
    // 有历史记录
    NSInteger pageNum = (kZMsgPageNum  - 1);
    if(self.startSeq != NSNotFound && curSeq != NSNotFound){
        _latestSession.latestMsg.msgSeq = self.startSeq;
        pageNum = kZMsgPageNum;
    }
    
    NSInteger end = curSeq;
    __block NSInteger start = end - pageNum; //(self.latestSession  ? _latestSession.latestMsg.msgSeq : self.startSeq) - pageNum;
    
    
    NSArray *cacheMsgs = [self getMsgsBetweenStartSeq:start endSeq:end sessionId:finalSessionId];
    if(cacheMsgs){
        
        [[ZMMessageManager sharedInstance] loadNextMessageHandle:cacheMsgs desc:NO];
        
        self.startSeq = start--;
        self.endSeq = end;
        self.latestSession.latestMsg.msgSeq = start--;
        
        // 刷新页面
        if(completeBlock)completeBlock();
        

        if(end < 0 || start < 0)_latestSession = nil;
        // 当前session无数据， 倒序取上一个sessionList ， 直到都取完为止
        if(!self.latestSession){
//            if(noMoreBlock)noMoreBlock();
        }
        
        return;
    }
}


// 获取下页消息
- (void)loadNextMsgsCompleteBlock:(ActionBlock)completeBlock noMoreBlock:(ActionBlock)noMoreBlock {
    
    @try {
        NSString *finalSessionId = self.latestSession ? self.latestSession.sessionId : self.sessionId;
        if(finalSessionId.length == 0)return;
        
        
        
        // 设为NO 则 会每次从服务端拉取配合loadAllDatas ; 为YES 则可有本地缓存优先读取，没有在拉取
        NSInteger curSeq = [self getLatestSessionSeq:finalSessionId desc:NO];
        
    //    NSInteger maxSeq = [self getLatestSessionSeq:finalSessionId desc:YES];
        
        // 有历史记录
        NSInteger pageNum = (kZMsgPageNum  - 1);
        if(self.startSeq != NSNotFound && curSeq != NSNotFound){
            _latestSession.latestMsg.msgSeq = self.startSeq;
            pageNum = kZMsgPageNum;
        }
        else{
            // 删除第一次加载 或者切换会话 再次进入 直接获取lastSeq 因为会包含异常状态的消息，纯本地的， 需要读出来
            NSInteger firstLoadSeq = [self lastSeq];
            if(firstLoadSeq != NSNotFound) {
                _latestSession.latestMsg.msgSeq = [self lastSeq];
            }
            
        }
        
        NSInteger tempCurSeq = _latestSession.latestMsg.msgSeq;
        if(tempCurSeq == NSNotFound) {
            tempCurSeq = 0;
        }
//        if([self.latestSession.sessionId isEqualToString:self.sessionId] && tempCurSeq != NSNotFound && tempCurSeq != _latestSession.latestMsg.msgSeq) {
//            tempCurSeq = [self lastSeq];
//        }
//        else {
//            tempCurSeq = _latestSession.latestMsg.msgSeq;
//        }
        
        __block NSInteger start = (self.latestSession  ? tempCurSeq : self.startSeq) - pageNum;
        NSInteger end = start + kZMsgPageNum - 1;

        NSArray *cacheMsgs = [self getMsgsBetweenStartSeq:start endSeq:end sessionId:finalSessionId];
        if(cacheMsgs){
            
            [[ZMMessageManager sharedInstance] loadNextMessageHandle:cacheMsgs desc:NO];
            
            self.startSeq = start--;
            self.endSeq = end;
            self.latestSession.latestMsg.msgSeq = start--;
            
            // 刷新页面
            if(completeBlock)completeBlock();
            
    //        start = (self.latestSession  ? _latestSession.latestMsg.msgSeq : self.startSeq) - kZMsgPageNum ;
    //        end = start + kZMsgPageNum - 1;
            if(end < 0 || start < 0)_latestSession = nil;
            // 当前session无数据， 倒序取上一个sessionList ， 直到都取完为止
            if(!self.latestSession){
                if(noMoreBlock)noMoreBlock();
    //            return;
            }
            
            return;
        }
        else{
            // 获取当前的
            [ZMHttpHelper getHistoryWith:finalSessionId endSeq:end startSeq:start success:^(NSDictionary * _Nonnull response) {
                ZMHistoryRepModel *historyModel = [ZMHistoryRepModel modelWithJSON:response];
                historyModel.content = [[historyModel.content reverseObjectEnumerator] allObjects];
                
                [[ZMMessageManager sharedInstance] loadNextMessageHandle:historyModel.content desc:NO];

                // 有数据， 刷新索引， 继续倒着取历史多少条
                if(historyModel.content.count > 0){
                    self.startSeq = start--;
                    self.endSeq = end;
                    self.latestSession.latestMsg.msgSeq = start--;
                    
                    // 刷新页面
                    if(completeBlock)completeBlock();
                }
                
            } failure:^(NSError * _Nonnull error) {
                if(completeBlock)completeBlock();
            }];
        }
        
    //    NSInteger maxSeq = [self getLatestSessionSeq:finalSessionId desc:YES];
        
    //    if(_startSeq == NSNotFound){
    //        _startSeq = [self getLatestSessionSeq:finalSessionId desc:YES];
    //        if(_startSeq != NSNotFound){
    //            _latestSession.latestMsg.msgSeq = _startSeq;
    //        }
    //    }
        
        return;
        
    //    // 找到历史记录
    //    if(curSeq != NSNotFound){
    ////        _latestSession.latestMsg.msgSeq = curSeq;
    //
    //        // 优先从本地DB缓存读取 N 条 ， 没有的话从Net 拉取
    //        start = (self.latestSession  ? _latestSession.latestMsg.msgSeq : self.startSeq) - kZMsgPageNum ;
    //        end = start + kZMsgPageNum - 1;
    //        if(end < 0 || start < 0)_latestSession = nil;
    //        // 当前session无数据， 倒序取上一个sessionList ， 直到都取完为止
    //        if(!self.latestSession){
    //            if(noMoreBlock)noMoreBlock();
    //            return;
    //        }
    //
    //        NSArray *cacheMsgs = [self getMsgsBetweenStartSeq:start endSeq:end sessionId:finalSessionId];
    //        if(cacheMsgs){
    //            [[ZMMessageManager sharedInstance] loadNextMessageHandle:cacheMsgs];
    //
    //            self.startSeq = start--;
    //            self.endSeq = end;
    //            self.latestSession.latestMsg.msgSeq = start--;
    //
    //            // 刷新页面
    //            if(completeBlock)completeBlock();
    //
    //            return;
    //        }
    //
    //    }
    //    else{
    //        _latestSession.latestMsg.msgSeq++;
    //        start = (self.latestSession  ? _latestSession.latestMsg.msgSeq : self.startSeq) - kZMsgPageNum ;
    //        end = start + kZMsgPageNum - 1;
    //        if(end < 0 || start < 0)_latestSession = nil;
    //        // 当前session无数据， 倒序取上一个sessionList ， 直到都取完为止
    //        if(!self.latestSession){
    //            if(noMoreBlock)noMoreBlock();
    //            return;
    //        }
    //    }
        
    //    __block NSInteger start = (self.latestSession  ? _latestSession.latestMsg.msgSeq : self.startSeq) - kZMsgPageNum ;
    //    NSInteger end = start + kZMsgPageNum - 1;
    //    if(end < 0 || start < 0)_latestSession = nil;
    //    // 当前session无数据， 倒序取上一个sessionList ， 直到都取完为止
    //    if(!self.latestSession){
    //        if(noMoreBlock)noMoreBlock();
    //        return;
    //    }
    //
    //    // 优先从本地DB缓存读取 N 条 ， 没有的话从Net 拉取
    //    NSArray *cacheMsgs = [self getMsgsBetweenStartSeq:start endSeq:end sessionId:finalSessionId];
    //    if(cacheMsgs){
    //        [[ZMMessageManager sharedInstance] loadNextMessageHandle:cacheMsgs];
    //        // 刷新页面
    //        if(completeBlock)completeBlock();
    //    }
    //    else{
            
    //    }
    } @catch (NSException *exception) {
        [SVProgressHUD showErrorWithStatus:exception.description];
    } @finally {
        
    }
    
    
}

// 获取历史消息去重
- (void)loadNextMessageHandle:(NSArray<ZMMessageMsgBody *> *)msgs desc:(BOOL)desc {
    if(msgs.count == 0)return;
    
    // 增量更新, 去重
    [msgs enumerateObjectsUsingBlock:^(ZMMessageMsgBody * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(obj.msgBody.length != 0) {
            ZMMessageMsgBody *oldMsgBody = [self removeRepeatMsg:obj];
            ZMMessage *item = [ZMMessage new];
            item.msgBody = obj;
            item.sendStatus = oldMsgBody.sendStatus;
            item.createTime = obj.createTime;
            item.sendTimeStamp = obj.sendTimeStamp;
            item.sessionId = [ZMMessageManager sharedInstance].sessionId;
            
            if(desc){
                [self.messages addObject:item];
            }
            else{
                [self.messages insertObject:item atIndex:0];
            }
            
            [[ZMDatabaseManager sharedInstance] insertObject:obj];
        }
        
    }];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kZMMessageDidChangeNotification object:nil];
}

// 会话去重
- (void)removeRepeatSession:(ZMMessageSessionItem *)session {
    NSArray<ZMMessageSessionItem *> *sessions = [[ZMDatabaseManager sharedInstance] queryObjectsOfClass:ZMMessageSessionItem.class withWhere:[NSString stringWithFormat:@"sessionId = '%@'",session.sessionId] orderBy:@"createTime ASC"];

    if(sessions.count > 0){
        [sessions enumerateObjectsUsingBlock:^(ZMMessageSessionItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj deleteToDB];
            [ZMMessageLatestMsgBody deleteWithWhere:@"sessionId = '%@'",obj.sessionId];
        }];
         
    }
}

- (void)syncSessionList:(ZMMessageSessionList *)sessions {
    if(sessions.sessionList.count > 0){
        [sessions.sessionList enumerateObjectsUsingBlock:^(ZMMessageSessionItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self removeRepeatSession:obj];
            [[ZMDatabaseManager sharedInstance] insertObject:obj];
        }];
        
        NSArray<ZMMessageSessionItem *> *latestSessions = [[ZMDatabaseManager sharedInstance] queryObjectsOfClass:ZMMessageSessionItem.class withWhere:[NSString stringWithFormat:@"uid = '%@'",self.currentUserId] orderBy:@"createTime DESC"];

        if(latestSessions.count > 0){
            self.latestSession = latestSessions.firstObject;
            _preSessionCreateTime = latestSessions.firstObject.createTime;
//            _preSessionMsgSeq = latestSessions.firstObject.latestMsg.msgSeq;
        }
        else {
            self.latestSession = nil;
            _preSessionCreateTime = 0;
//            _preSessionMsgSeq = NSNotFound;
        }
    }
}

- (NSInteger)getLatestSessionSeq:(NSString *)sessionId desc:(BOOL)desc {
    //    NSArray<ZMMessage *> *msgs = [[ZMDatabaseManager sharedInstance] queryObjectsOfClass:ZMMessage.class withWhere:nil];
    NSArray<ZMMessageMsgBody *> *msgs = [[ZMDatabaseManager sharedInstance] queryObjectsOfClass:ZMMessageMsgBody.class withWhere:[NSString stringWithFormat:@"sessionId = '%@' and msgSeq > 0 and (receiverUid != '222' OR receiverUid IS NULL)",sessionId] orderBy:desc ? @"sendTimeStamp DESC" : @"sendTimeStamp ASC"];
    
    if(msgs.count > 0){
        return msgs.firstObject.msgSeq;
    }
    return NSNotFound;
}

- (NSInteger)lastSeq {
//    return  [self getLatestSessionSeq:[ZMMessageManager sharedInstance].sessionId desc:YES];
    NSArray<ZMMessageMsgBody *> *msgs = [[ZMDatabaseManager sharedInstance] queryObjectsOfClass:ZMMessageMsgBody.class withWhere:[NSString stringWithFormat:@"sessionId = '%@' and msgSeq > 0 and (receiverUid != '222' OR receiverUid IS NULL)  and (sendStatus != 3 OR  sendStatus != 2)",[ZMMessageManager sharedInstance].sessionId] orderBy:@"sendTimeStamp DESC"];
    
    if(msgs.count > 0){
        return msgs.firstObject.msgSeq;
    }
    return NSNotFound;
}

- (NSTimeInterval)lastTimestamp {
    NSArray<ZMMessageMsgBody *> *msgs = [[ZMDatabaseManager sharedInstance] queryObjectsOfClass:ZMMessageMsgBody.class withWhere:[NSString stringWithFormat:@"sessionId = '%@'",[ZMMessageManager sharedInstance].sessionId] orderBy:@"sendTimeStamp DESC"];

    if(msgs.count > 0){
        return msgs.firstObject.sendTimeStamp;
    }
    return 0;
}

- (ZMMessageMsgBody *)getMsgWithMsgSeq:(NSInteger)seq sessionId:(nonnull NSString *)sessionId {
    NSArray<ZMMessageMsgBody *> *msgs = [[ZMDatabaseManager sharedInstance] queryObjectsOfClass:ZMMessageMsgBody.class withWhere:[NSString stringWithFormat:@"sessionId = '%@' and msgSeq = %ld",sessionId,seq] orderBy:@"sendTimeStamp DESC"];

    if(msgs.count > 0){
        return msgs.firstObject;
    }
    return nil;
}


- (void)loadLocalAllMsgs {
    NSArray<ZMMessage *> *allMsgs = [[ZMDatabaseManager sharedInstance] loadAllDatas];
    self.messages = allMsgs.mutableCopy;
    [[NSNotificationCenter defaultCenter] postNotificationName:kZMMessageDidChangeNotification object:nil];
}

- (ZMMessageMsgBody *)removeRepeatMsg:(ZMMessageMsgBody *)msgBody {
    NSArray<ZMMessageMsgBody *> *msgs = [[ZMDatabaseManager sharedInstance] queryObjectsOfClass:ZMMessageMsgBody.class withWhere:[NSString stringWithFormat:@"sessionId = '%@' AND clientMsgId = '%@'",[ZMMessageManager sharedInstance].sessionId,msgBody.clientMsgId ?: @""] orderBy:@"sendTimeStamp ASC"];

    if(msgs.count > 0){
        [msgs enumerateObjectsUsingBlock:^(ZMMessageMsgBody * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj deleteToDB];
            
            // 消息处理, 只取本地没有的insert
//            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"msgBody.sendTime = %d and msgBody.msgSeq = %d",obj.sendTime,obj.msgSeq];
//            
//
//            // 使用谓词过滤数组
//            NSArray<ZMMessage *> *filteredModels = [self.messages filteredArrayUsingPredicate:predicate];
//            
//            [filteredModels enumerateObjectsUsingBlock:^(ZMMessage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                [self.messages removeObject:obj];
//            }];
            
//            for(ZMMessage *message in self.messages){
//                if(message.sendTime == obj.sendTime && msgBody.msgSeq == obj.msgSeq){
//                    [self.messages removeObject:message];
//                }
//            }
            // 优化
            [self.messages enumerateObjectsUsingBlock:^(ZMMessage * _Nonnull message, NSUInteger idx, BOOL * _Nonnull stop) {
                if(message.sendTimeStamp == obj.sendTimeStamp && msgBody.msgSeq == obj.msgSeq){
                    [self.messages removeObject:message];
                }
            }];
//            [self.messages removeObject:obj];
        }];
        
        return msgs.firstObject;
//        [msgs.firstObject deleteToDB];
    }
    return nil;
}

- (void)messageHandle:(NSArray<ZMMessageMsgBody *> *)msgs{
    if(msgs.count == 0)return;

    // 消息处理, 只取本地没有的insert
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sendTimeStamp > %d", [self lastTimestamp]];
    

    // 使用谓词过滤数组
    NSArray<ZMMessageMsgBody *> *filteredModels = [msgs filteredArrayUsingPredicate:predicate];
    
    
    // 只增量更新, 去重
    [filteredModels enumerateObjectsUsingBlock:^(ZMMessageMsgBody * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(obj.msgBody.length != 0) {
            ZMMessageMsgBody *oldMsgBody = [self removeRepeatMsg:obj];
            ZMMessage *item = [ZMMessage new];
            item.msgBody = obj;
            item.sendStatus = oldMsgBody.sendStatus;
            item.createTime = obj.createTime;
            item.sendTimeStamp = obj.sendTimeStamp;
            item.sessionId = [ZMMessageManager sharedInstance].sessionId;
            
            [self.messages addObject:item];
            [[ZMDatabaseManager sharedInstance] insertObject:item];
        }
        
    }];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kZMMessageDidChangeNotification object:nil];
}

- (void)upSortMsg:(ZMMessage *)message {
    [self.messages removeObject:message];
    [self.messages addObject:message];
    [self updateMessage:message];
    [[NSNotificationCenter defaultCenter] postNotificationName:kZMMessageDidChangeNotification object:nil];
}

- (ZMMessage *)sendMsg:(NSString *)message msgType:(ZMMessageType)type {
    if(message.length == 0) return nil;
    
    ZMMessage *msg = [[ZMMessage alloc] initWithText:message type:type  isFromUser:NO];
    msg.sendStatus = ZMMessageSendStatusSending;
    msg.sessionId = [ZMMessageManager sharedInstance].sessionId;
    msg.msgBody.msgType = type;
    msg.msgType = type;
    msg.msgBody.sessionId = msg.sessionId;
    msg.msgBody.senderUid = [ZMMessageManager sharedInstance].currentUserId;
    msg.msgBody.createTime = [ZMCommon zeroZoneTimestamp];
    msg.msgBody.sendTimeStamp = msg.msgBody.createTime;
    msg.createTime = msg.msgBody.createTime;
    msg.sendTimeStamp = msg.msgBody.sendTimeStamp;
    msg.msgBody.clientMsgId = [NSString stringWithFormat:@"%@-%ld",[ZMCommon uuid],msg.sendTimeStamp];
    NSInteger newSeq = [[ZMMessageManager sharedInstance] lastSeq];
    if(newSeq == NSNotFound){
        newSeq = 0;
    }
    msg.msgBody.msgSeq = newSeq + 1;
    [[ZMMessageManager sharedInstance] addMessage:msg];
    
    [[ZMFloatChatToolView shared] hideTimeoutTip];
    return msg;
}

- (void)markAsReadMsg:(ZMMessage *)message {
    [ZMHttpHelper markMsgAsRead:message.msgBody.msgSeq sessionID:self.sessionId headers:nil success:^(NSDictionary *response) {
//        ZMResponseModel *model = [ZMResponseModel modelWithJSON:response];
        //
    } failure:^(NSError *error) {
        
    }];
}


- (void)addMessage:(ZMMessage *)message {
//    NSMutableDictionary *mutableDict = [messageDict mutableCopy];
//    mutableDict[@"userId"] = self.currentUserId;
    [[ZMDatabaseManager sharedInstance] insertObject:message];
//    // 更新缓存
//    NSString *messageId = mutableDict[@"id"];
//    [self.messageCache setObject:mutableDict forKey:messageId];
//    [self updateUserMessagesCache:mutableDict];
    
    [_messages addObject:message];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kZMMessageDidChangeNotification object:nil];
}

- (void)updateAllMsgRead{
    [[ZMDatabaseManager sharedInstance] updateAllMsgRead];
    [self.messages enumerateObjectsUsingBlock:^(ZMMessage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.msgBody.status = 1;
        obj.sendStatus = obj.msgBody.sendStatus = ZMMessageSendStatusReaded;
    }];
}

- (BOOL)deleteWithModels {
    return  [[ZMDatabaseManager sharedInstance] deleteWithModelClass:ZMMessage.class where:nil];
}

- (void)clearAllDBDatas{
    [[ZMDatabaseManager sharedInstance] dropAllTables];
}

- (void)deleteMessageWithId:(NSString *)messageId {
    NSString *condition = [NSString stringWithFormat:@"id = '%@' AND userId = '%@'", messageId, self.currentUserId];
//    [[ZMDatabaseManager sharedInstance] deleteObjectFromTable:@"messages" whereCondition:condition];
    
    // 更新缓存
    [self.messageCache removeObjectForKey:messageId];
    [self removeMessageFromUserMessagesCache:messageId];
}

- (void)updateMessage:(ZMMessage *)message {

//    NSString *messageId = messageDict[@"id"];
    [[ZMDatabaseManager sharedInstance] updateObject:message];
//    NSString *condition = [NSString stringWithFormat:@"id = '%@' AND userId = '%@'", messageId, self.currentUserId];
//    [[ZMDatabaseManager sharedInstance] updateObject:messageDict inTable:@"messages" whereCondition:condition];
    
    // 更新缓存
//    [self.messageCache setObject:messageDict forKey:messageId];
//    [self updateUserMessagesCache:messageDict];
}

- (NSInteger)getMsgCount {
    return  [[ZMDatabaseManager sharedInstance] count:ZMMessage.class withWhere:[NSString stringWithFormat:@"sessionId = '%@'",[ZMMessageManager sharedInstance].sessionId]];
}

- (NSInteger)getCurrentUidSessionListCount {
    NSArray<ZMMessageSessionItem *> *sessions = [[ZMDatabaseManager sharedInstance] queryObjectsOfClass:ZMMessageSessionItem.class withWhere:[NSString stringWithFormat:@"uid = '%@'",self.currentUserId] orderBy:@"createTime DESC"];
//    [self getMsgCount];
    NSArray<ZMMessageLatestMsgBody *> *latests = [[ZMDatabaseManager sharedInstance] queryObjectsOfClass:ZMMessageLatestMsgBody.class withWhere:[NSString stringWithFormat:@"sessionId = '%@'",self.sessionId] orderBy:@"createTime DESC"];
    if(latests.count > 0)return sessions.count;
    return 0;
}

- (NSArray *)getMessagesForUserId:(NSString *)userId limit:(NSInteger)limit offset:(NSInteger)offset {
//    NSArray *cachedMessages = [self.userMessagesCache objectForKey:userId];
//    if (cachedMessages && offset < cachedMessages.count) {
//        NSInteger endIndex = MIN(offset + limit, cachedMessages.count);
//        return [cachedMessages subarrayWithRange:NSMakeRange(offset, endIndex - offset)];
//    }
    
    NSString *uid = userId;
    if(!uid) {
        uid = self.currentUserId;
    }
    
    NSString *condition = [NSString stringWithFormat:@"sender_uid = '%@'", uid];
//    NSString *orderBy = @"timestamp DESC";
//    NSArray *messages = [[ZMDatabaseManager sharedInstance] getObjectsFromTable:@"messages" 
//                                                                 whereCondition:condition 
//                                                                        orderBy:orderBy 
//                                                                          limit:limit 
//                                                                         offset:offset];
    
    NSArray *messages = [[ZMDatabaseManager sharedInstance] queryObjectsOfClass:NSObject.class withWhere:condition orderBy:nil];
    
    // 更新用户消息缓存
    [self.userMessagesCache setObject:messages forKey:userId];
    
    return messages;
}

//- (NSDictionary *)getMessageWithId:(NSString *)messageId {
//    NSDictionary *cachedMessage = [self.messageCache objectForKey:messageId];
//    if (cachedMessage) {
//        return cachedMessage;
//    }
//    
//    NSString *condition = [NSString stringWithFormat:@"id = '%@' AND userId = '%@'", messageId, self.currentUserId];
//    NSArray *results = [[ZMDatabaseManager sharedInstance] getObjectsFromTable:@"messages" whereCondition:condition limit:1 offset:0];
//    NSDictionary *message = results.firstObject;
//    
//    if (message) {
//        [self.messageCache setObject:message forKey:messageId];
//    }
//    
//    return message;
//}

- (void)clearCache {
    [self.messageCache removeAllObjects];
    [self.userMessagesCache removeAllObjects];
}

- (void)setCacheLimit:(NSUInteger)limit {
    self.messageCache.countLimit = limit;
}

#pragma mark - Helper methods

- (void)updateUserMessagesCache:(NSDictionary *)message {
    NSString *userId = message[@"userId"];
    NSMutableArray *userMessages = [self.userMessagesCache objectForKey:userId];
    if (!userMessages) {
        userMessages = [NSMutableArray array];
        [self.userMessagesCache setObject:userMessages forKey:userId];
    }
    [userMessages addObject:message];
    [userMessages sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        return [obj2[@"timestamp"] compare:obj1[@"timestamp"]];
    }];
}

- (void)removeMessageFromUserMessagesCache:(NSString *)messageId {
    [self.userMessagesCache enumerateKeysAndObjectsUsingBlock:^(NSString *userId, NSMutableArray *messages, BOOL *stop) {
        NSUInteger index = [messages indexOfObjectPassingTest:^BOOL(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
            return [obj[@"id"] isEqualToString:messageId];
        }];
        if (index != NSNotFound) {
            [messages removeObjectAtIndex:index];
            *stop = YES;
        }
    }];
}

#pragma mark - Timeout Config

- (void)setTimeoutConfigModel:(ZMTimeoutConfigRespModel *)timeoutConfigModel {
    _timeoutConfigModel = timeoutConfigModel;
    if(_timeoutConfigModel.isOpen && _timeoutConfigModel.timeout > 0) {
        // 先看看本地客服消息有没有超时的，有就提醒，没有走定时器提醒， 之后再按最后一次客服的websocket 消息重置定时器
        if([self checkTimeoutTip]){
            [self startTimeoutTimer];
        }
    }
    else{
        // 没有取到配置或是关闭的
        [self destoryTimeoutTimer];
    }
}

- (void)startTimeoutTimer {
    if(self.timeoutConfigModel.timeout > 0) {
        [self destoryTimeoutTimer];
        _timeoutTipTimer =  [NSTimer scheduledTimerWithTimeInterval:self.timeoutConfigModel.timeout * 60 target:self selector:@selector(checkTimeoutTip) userInfo:nil repeats:YES];
        [_timeoutTipTimer  setFireDate:[NSDate distantPast]];
        [[NSRunLoop currentRunLoop] addTimer:_timeoutTipTimer forMode:NSRunLoopCommonModes];
    }
    else {
        [self destoryTimeoutTimer];
    }
}

- (void)resetTimeoutTimer {
    [self startTimeoutTimer];
}

- (BOOL)checkTimeoutTip {
    NSArray<ZMMessageMsgBody *> *msgs = [[ZMDatabaseManager sharedInstance] queryObjectsOfClass:ZMMessageMsgBody.class withWhere:[NSString stringWithFormat:@"sessionId = '%@'",self.sessionId] orderBy:@"sendTimeStamp DESC"];

    if(msgs.count > 0){
        
        if(![msgs.firstObject.senderUid isEqualToString:self.currentUserId]) {
            // 比较时间
            BOOL isTimeout = [ZMCommon compareTimeOverMinutes:msgs.firstObject.sendTimeStamp];
            // 显示tip
            if(isTimeout) {
                [[ZMFloatChatToolView shared] showTimeoutTip:self.timeoutConfigModel.timeout];
            }
            else {
                [[ZMFloatChatToolView shared] hideTimeoutTip];
            }
        }
    }
    else {
        [[ZMFloatChatToolView shared] hideTimeoutTip];
    }
    return NO;
}

- (void)destoryTimeoutTimer {
    [self.timeoutTipTimer invalidate];
    self.timeoutTipTimer = nil;
}

#pragma mark - Msg Sync

- (void)startMsgSyncTimer {
    if(_msgSyncTimer)return;
    _msgSyncTimer =  [NSTimer scheduledTimerWithTimeInterval:kZMMessageSyncSp target:self selector:@selector(msgSync) userInfo:nil repeats:YES];
    [_msgSyncTimer  setFireDate:[NSDate distantPast]];
    [[NSRunLoop currentRunLoop] addTimer:_msgSyncTimer forMode:NSRunLoopCommonModes];
}

- (void)destoryMsgSyncTimer {
    [self.msgSyncTimer invalidate];
    self.msgSyncTimer = nil;
}


- (void)msgSync {
    if(self.sessionId.length > 0) {
        NSInteger newSeq = [[ZMMessageManager sharedInstance] lastSeq];
        [ZMHttpHelper getHistoryWith:self.sessionId endSeq:1000 startSeq:newSeq + 1 success:^(NSDictionary * _Nonnull response) {
            ZMHistoryRepModel *historyModel = [ZMHistoryRepModel modelWithJSON:response];
            
            [[ZMMessageManager sharedInstance] messageHandle:historyModel.content];

            
        } failure:^(NSError * _Nonnull error) {
            
        }];
    }
    
}

- (void)destory {
    [self destoryMsgSyncTimer];
    self.preSessionMsgSeq = self.preSessionCreateTime = NSNotFound;
    self.latestSession = nil;
    [self.messages removeAllObjects];
    _sessionId = @"";
    _token = @"";
    _currentUserId = @"";
    _identityID = @"";
    _nickName = @"";
    _userMessagesCache = [NSMutableDictionary dictionary];
    _startSeq = _endSeq = NSNotFound;
}


- (void)dealloc {
    [self destoryMsgSyncTimer];
    [self destoryTimeoutTimer];
}

@end
