//
//  ZMMessage.m
//  imchat
//
//  Created by Lilou on 2024/10/16.
//

#import "ZMMessage.h"

@implementation ZMMessage


+ (NSDictionary *)getColumnMapping {
    return @{@"join_rename": @"join"};
}

+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{
             @"msgBody":[ZMMessageMsgBody class],
             @"join_rename":[ZMMessageJoin class],
             @"createSessionMsg":[ZMMessageCreateSession class],
             @"state":[ZMMessageState class],
             @"agentUserJoinSessionMsg" : [ZMMessageAgentUserJoinSession class],
             @"hasReadReceiptMsg" : [ZMMessageHasReadReceiptMsg class],
             @"endSessionMsg" : [ZMMessageEndSessionMsg class]
             };
}

- (instancetype)initWithText:(NSString *)text type:(ZMMessageType)type isFromUser:(BOOL)isFromUser{
    if(self = [super init]){
        ZMMessageMsgBody *textMsg = [ZMMessageMsgBody new];
        if(type == ZMMessageTypeImg || type == ZMMessageTypeVideo){
//            ZMMessageMsgBodyMediaJson *mediaJson = [ZMMessageMsgBodyMediaJson modelWithJSON:text];
//            mediaJson.resource.url = text;
            textMsg.msgBody = text;//[mediaJson yy_modelToJSONString];
        }
        else{
            textMsg.msgBody = text;
        }
        
        _msgBody = textMsg;
        _msgType = type;
        _isFromSys = isFromUser;
    }
    return self;
}

- (void)setSendStatus:(ZMMessageSendStatus)sendStatus {
//    _sendStatus = sendStatus;
    self.msgBody.sendStatus = sendStatus;
}

- (ZMMessageSendStatus)sendStatus {
    if(self.msgBody.status) {
        return ZMMessageSendStatusReaded;
    }
    return self.msgBody.sendStatus;
}

- (BOOL)isFromSys {
    return  ![self.msgBody.senderUid isEqualToString:[ZMMessageManager sharedInstance].currentUserId];
}


- (CGFloat)height{
//    if(_height != 0)return _height;
    CGFloat h = kW(44);
    switch (self.msgBody.msgType) {
        case ZMMessageTypeJoinServer:
            break;
        case ZMMessageTypeText:
            h = [self textHeight];
            break;
        case ZMMessageTypeImg:

            h = [self imageHeight];
            break;
        case ZMMessageTypeVideo:
            
            h = [self videoHeight];
            break;
        case ZMMessageTypeFaqMsgType:
            h = [self faqHeight];
            break;
        case ZMMessageTypeKnowledgePointMsgType:
            h = [self faqPointsHeight];
            break;
        case ZMMessageTypeKnowledgeAnswerMsgType:
            h = [self faqAnswerHeight];
            break;
        default:
            break;
    }
    
//    self.msgBody.height = h;
//    _height = h;
    return h;
}

- (CGFloat)faqAnswerHeight {
    
    CGFloat timeAddHeight = [self.msgBody showTime] ? kW(8) + kW(15) : 0;
    
    // fixed = 89;
    CGFloat h = kW(55) + timeAddHeight ;
    
    NSInteger cnt = self.msgBody.faqAnswers.count;
    
    __block CGFloat aHeight = 0;
    
    [self.msgBody.faqAnswers enumerateObjectsUsingBlock:^(ZMMessageMsgBodyFaqAnswers * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGSize maxSize = CGSizeMake(SCREEN_WIDTH - kW(130), CGFLOAT_MAX);
        switch (obj.type) {
            case ZMMessageFaqAnswerTypeText:
            {
//                NSDictionary *attributes = @{NSFontAttributeName: ZMFontRes.font_12};

//                CGRect textRect = [obj.content ?: @"" boundingRectWithSize:maxSize
//                                                      options:NSStringDrawingUsesLineFragmentOrigin
//                                                   attributes:attributes
//                                                      context:nil];
                
                CGFloat textH = [ZMCommon calculateHeightWithText:obj.content ?:@"" maxWidth:maxSize.width font:ZMFontRes.font_12] - 4.;
                aHeight += textH;//textRect.size.height;

            }
                break;
            case ZMMessageFaqAnswerTypeImage:
            {
                CGSize picSize = [ZMCommon getMediaFitSize:CGSizeMake(obj.width, obj.height)];
                aHeight += picSize.height;
            }
                break;
            case ZMMessageFaqAnswerTypeHyperMix:
            {
                if(obj.mixContents.count > 0){
                    
                    
//                    NSDictionary *attributes = @{NSFontAttributeName: ZMFontRes.font_12};
//
//                    CGRect textRect = [obj.content ?: @"" boundingRectWithSize:maxSize
//                                                          options:NSStringDrawingUsesLineFragmentOrigin
//                                                       attributes:attributes
//                                                          context:nil];
                    NSString *text = @"";
                    NSArray *contents = [obj.mixContents valueForKey:@"content"];
                    if(contents.count > 0){
                        text = [contents componentsJoinedByString:@""];
                    }
                    CGFloat textH = [ZMCommon calculateHeightWithText:text ?:@"" maxWidth:maxSize.width font:ZMFontRes.font_12] - 4;
                    aHeight += textH;//textRect.size.height;
                    
                }
            }
                break;
            default:
                break;
        }
    }];
    
    CGFloat finalH = h  + aHeight + (cnt > 0 ? kW(4) : kW(12)) +  (cnt > 0 ? (cnt - 1) * kW(8) : 0) ;
    return finalH;
}


- (CGFloat)faqPointsHeight {
    NSString *text = @"点击选择以下常见问题获取便捷自助服务";
    
    CGFloat timeAddHeight = [self.msgBody showTime] ? kW(8) + kW(15) : 0;
    
    // fixed = 89;
    CGFloat h = kW(55) + timeAddHeight ;
    
    // tip 高度
    NSDictionary *tipAttributes = @{NSFontAttributeName: ZMFontRes.font_14};


    CGSize maxTipSize = CGSizeMake(kW(246), CGFLOAT_MAX);

    CGRect textTipRect = [text boundingRectWithSize:maxTipSize
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:tipAttributes
                                          context:nil];
    
    __block CGFloat qHeight = 0;
    
    [self.msgBody.faqPoints enumerateObjectsUsingBlock:^(ZMMessageMsgBodyFaqPoint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGSize maxSize = CGSizeMake(SCREEN_WIDTH - kW(130), CGFLOAT_MAX);
        
        CGRect textRect = [obj.knowledgePointName boundingRectWithSize:maxSize
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:@{NSFontAttributeName: ZMFontRes.font_12}
                                                      context:nil];
        qHeight += (textRect.size.height);
        
    }];
    
    CGFloat finalH = h  + textTipRect.size.height  +   qHeight + (self.msgBody.faqPoints.count ) * kW(8)  + kW(16) ;
    return finalH;
}


- (CGFloat)faqHeight {
    NSString *text = self.msgBody.faq.knowledgeBaseTitle ?: @"";
    
    CGFloat timeAddHeight = [self.msgBody showTime] ? kW(8) + kW(15) : 0;
    
    // fixed = 89;
    CGFloat h = kW(55) + timeAddHeight ;
    
    // tip 高度
    NSDictionary *tipAttributes = @{NSFontAttributeName: ZMFontRes.font_14};


    CGSize maxTipSize = CGSizeMake(SCREEN_WIDTH - kW(130), CGFLOAT_MAX);

    CGRect textTipRect = [text boundingRectWithSize:maxTipSize
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:tipAttributes
                                          context:nil];
    
    NSArray<ZMMessageMsgBodyFaqItem *> *cards = [self.msgBody faq].knowledgeBaseList;
    
    CGFloat cardWidth = ((SCREEN_WIDTH - kW(130) - kW(24)) / 3); // 一行三个卡片,左右各留8dp间距
    CGFloat cardHeight = (cardWidth); // 卡片主体高度
    CGFloat cardSpacing = kW(8); // 卡片间距
    
    NSInteger rows = (cards.count + 2) / 3; // 计算需要的行数

    
//    __block CGFloat maxTipHeight = tipHeight;
    
    
//    [cards enumerateObjectsUsingBlock:^(ZMMessageMsgBodyFaqItem * _Nonnull obj, NSUInteger idx, BOOL *stop) {
//        
//        NSDictionary *attributes = @{NSFontAttributeName: ZMFontRes.font_12};
//        
//        CGSize maxSize = CGSizeMake(cardWidth, CGFLOAT_MAX);
//        
//        obj.knowledgeBaseName = @"dfsdfsdfsdfsdfdsfdsfdsfsdfsdfsdfsdf-";
//        
//        CGRect textRect = [obj.knowledgeBaseName boundingRectWithSize:maxSize
//                                                          options:NSStringDrawingUsesLineFragmentOrigin
//                                                       attributes:attributes
//                                                          context:nil];
//        
//        CGFloat textH = [ZMCommon calculateHeightWithText:obj.knowledgeBaseName maxWidth:maxSize.width font:ZMFontRes.font_12];
//        
//        maxTipHeight = MAX(textH/*textRect.size.height*/,maxTipHeight) ;
//
//    }];
    
    CGFloat finalH = h  + (text.length > 0 ?  (textTipRect.size.height + kW(20)) : kW(12)) +   ((cardHeight + cardSpacing) * rows - cardSpacing)  ;//+ kW(24) ;
    return finalH;
}

- (CGFloat)textHeight{
    
    NSString *text = self.msgBody.msgBody ?: @"";
    
    CGFloat timeAddHeight = [self.msgBody showTime] ? kW(8) + kW(15) : 0;
    
    if(text.length == 0)return kW(44);
    
    // fixed = 89;
    CGFloat h = kW(55) + timeAddHeight ;

    NSDictionary *attributes = @{NSFontAttributeName: ZMFontRes.font_14};


    CGSize maxSize = CGSizeMake(kW(246), CGFLOAT_MAX);

    CGRect textRect = [text boundingRectWithSize:maxSize
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:attributes
                                          context:nil];
    
    return h + textRect.size.height ;
    
}

- (CGFloat)imageHeight{
//    _height = 0;
//    NSString *text = self.msgBody.msgBody ?: @"";
//    
//    // fixed = 89;
//    CGFloat h = 55;
//
//    NSDictionary *attributes = @{NSFontAttributeName: ZMFontRes.font_14};
//
//
//    CGSize maxSize = CGSizeMake(kW(246), CGFLOAT_MAX);
//
//    CGRect textRect = [text boundingRectWithSize:maxSize
//                                          options:NSStringDrawingUsesLineFragmentOrigin
//                                       attributes:attributes
//                                          context:nil];
//    
//    return h + textRect.size.height ;
    NSString *text = self.msgBody.msgBody ?: @"";
    
    CGFloat timeAddHeight = [self.msgBody showTime] ? kW(8) + kW(15) : 0;
    
    CGFloat thumbHeight = self.msgBody.thumbHeight;
    
    if(thumbHeight != 0) {
        _height = 0;
    }
    
    if(text.length == 0)return kW(44);
    
    // fixed = 89;
    CGFloat h = kW(55) + timeAddHeight + thumbHeight;
    return _height + h;
}

- (CGFloat)videoHeight{
//    _height = 0;
    NSString *text = self.msgBody.msgBody ?: @"";
    
    CGFloat timeAddHeight = [self.msgBody showTime] ? kW(8) + kW(15) : 0;
    
    if(text.length == 0)return kW(44);
    
    CGFloat thumbHeight = self.msgBody.thumbHeight;
    if(thumbHeight != 0) {
        _height = 0;
    }
    // fixed = 89;
    CGFloat h = kW(55) + timeAddHeight + thumbHeight;
    return _height + h;
    
}

//- (CGFloat)mediaHeight {
//    if(_mediaHeight == 0){
//        return 200;
//    }
//    return _mediaHeight;
//}

// FAQ
//- (CGFloat)height{
//    // fixed = 89;
//    CGFloat h = 89 + 8;
//
//    NSDictionary *attributes = @{NSFontAttributeName: ZMFontRes.font_14};
//
//
//    CGSize maxSize = CGSizeMake(kW(246), CGFLOAT_MAX);
//
//    CGRect textRect = [self.text boundingRectWithSize:maxSize
//                                          options:NSStringDrawingUsesLineFragmentOrigin
//                                       attributes:attributes
//                                          context:nil];
//    CGFloat faqBtnHeight = 5 * 30 ;
//
//    return h + textRect.size.height + faqBtnHeight;
//
//}

// Queue
//- (CGFloat)height{
//    // fixed = 89;
//    CGFloat h = 55;
//
//    NSDictionary *attributes = @{NSFontAttributeName: ZMFontRes.font_14};
//
//
//    CGSize maxSize = CGSizeMake(kW(246), CGFLOAT_MAX);
//
//    CGRect textRect = [self.text boundingRectWithSize:maxSize
//                                          options:NSStringDrawingUsesLineFragmentOrigin
//                                       attributes:attributes
//                                          context:nil];
//
//    return h + textRect.size.height ;
//}

@end

@implementation ZMMessageState

@end

@implementation ZMMessageJoin

@end

@implementation ZMMessageMsgBodyMediaJsonItem
- (NSString *)key {
    if(_key.length > 0){
//        if([_key containsString:@":"]){
//            NSRange range = [_key rangeOfString:@":"];
//            @try {
//                _key = [_key substringFromIndex:range.location + 1];
//            } @catch (NSException *exception) {
//                
//            } @finally {
//                
//            }
//            
//        }
    }
    else{
        _key = @"";
    }
    return _key;
}
@end

@implementation ZMMessageMsgBodyMediaJson
+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{
             @"thumbnail":[ZMMessageMsgBodyMediaJsonItem class],
             @"resource":[ZMMessageMsgBodyMediaJsonItem class],
             };
}

- (ZMMessageMsgBodyMediaJsonItem *)thumbnail {
    if(!_thumbnail) {
        _thumbnail = [ZMMessageMsgBodyMediaJsonItem new];
        _thumbnail.key = @"";
        _thumbnail.url = @"";
    }
    return _thumbnail;
}

- (ZMMessageMsgBodyMediaJsonItem *)resource {
    if(!_resource) {
        _resource = [ZMMessageMsgBodyMediaJsonItem new];
        _resource.key = @"";
        _resource.url = @"";
    }
    return _resource;
}
@end

@implementation ZMMessageMsgBodyFaqAnswerHyperMix


@end

@implementation ZMMessageMsgBodyFaqAnswers
//+ (NSDictionary *)modelContainerPropertyGenericClass{
//    return @{
//             @"contents":[ZMMessageMsgBodyFaqAnswerHyperMix class]
//             };
//}

- (NSArray<ZMMessageMsgBodyFaqAnswerHyperMix *> *)mixContents {
    NSArray<ZMMessageMsgBodyFaqAnswerHyperMix *> *item = [NSArray yy_modelArrayWithClass:ZMMessageMsgBodyFaqAnswerHyperMix.class json:self.contents];
    return item;
}

- (ZMMessageMsgBodyMediaJsonItem *)imgContent {
    ZMMessageMsgBodyMediaJsonItem *item = [ZMMessageMsgBodyMediaJsonItem modelWithJSON:self.content];
    return item;
}

- (NSInteger)width {
    if(_width == 0) {
        return kW(200);
    }
    return _width;
}

- (NSInteger)height {
    if(_height == 0) {
        return kW(200);
    }
    return _height;
}
@end


// == Faq
@implementation ZMMessageMsgBodyFaqItem
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"fId" : @"id",
    };
}

- (ZMMessageMsgBodyMediaJsonItem *)urlContent {
    if(!_urlContent) {
        ZMMessageMsgBodyMediaJsonItem *item = [ZMMessageMsgBodyMediaJsonItem modelWithJSON:self.url];
        _urlContent = item;
    }
    return _urlContent;
}
@end

@implementation ZMMessageMsgBodyFaq
+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{
             @"knowledgeBaseList":[ZMMessageMsgBodyFaqItem class]
             };
}

//- (NSString *)knowledgeBaseTitle {
//    if(!_knowledgeBaseTitle)return @"";
//    return _knowledgeBaseTitle;
//}
@end
// == Faq


// == Faq Point
@implementation ZMMessageMsgBodyFaqPoint
     + (NSDictionary *)modelCustomPropertyMapper {
        return @{
            @"fId" : @"id",
        };
    }
@end
// == Faq Point

@implementation ZMMessageMsgBody

- (NSArray<ZMMessageMsgBodyFaqPoint *> *)faqPoints {
    NSArray<ZMMessageMsgBodyFaqPoint *> *retArr = @[];
    if(self.msgType == ZMMessageTypeKnowledgePointMsgType) {
        
        retArr = [NSArray yy_modelArrayWithClass:ZMMessageMsgBodyFaqPoint.class json:self.msgBody];
    }
    return  retArr;
}

- (ZMMessageMsgBodyFaq *)faq {
    ZMMessageMsgBodyFaq *faq = nil;
    if(self.msgType == ZMMessageTypeFaqMsgType) {
        
        faq = [ZMMessageMsgBodyFaq modelWithJSON:self.msgBody];
    }
    return faq;
}

- (NSArray<ZMMessageMsgBodyFaqAnswers *> *)faqAnswers {
    NSArray<ZMMessageMsgBodyFaqAnswers *> *retArr = @[];
    if(self.msgType == ZMMessageTypeKnowledgeAnswerMsgType) {
        
        retArr = [NSArray yy_modelArrayWithClass:ZMMessageMsgBodyFaqAnswers.class json:self.msgBody];
    }
    return  retArr;
}


- (NSInteger)thumbHeight {
    if(_thumbHeight == 0) {
        
        _thumbHeight =  [ZMCommon getMediaFitSize:CGSizeMake([ZMMessageMsgBodyMediaJson modelWithJSON:self.msgBody].width, [ZMMessageMsgBodyMediaJson modelWithJSON:self.msgBody].height)].height;
    }
    return _thumbHeight;
}

- (ZMMessageMsgBodyMediaJsonItem *)thumbnail {
    
    if(self.msgType == ZMMessageTypeImg || self.msgType == ZMMessageTypeVideo){
        return [ZMMessageMsgBodyMediaJson modelWithJSON:self.msgBody].thumbnail;
    }
    return nil;
}

- (ZMMessageMsgBodyMediaJsonItem *)resource {
    if(self.msgType == ZMMessageTypeImg || self.msgType == ZMMessageTypeVideo){
//        id  tes =  [ZMMessageMsgBodyMediaJson modelWithJSON:self.msgBody];
        return [ZMMessageMsgBodyMediaJson modelWithJSON:self.msgBody].resource;
    }
    return nil;
}

//+ (NSDictionary *)modelCustomPropertyMapper {
//    return @{
//        @"createTime": @"create_time",
//        @"msgBody": @"msg_body",
//        @"msgSeq": @"msg_seq",
//        @"msgType": @"msg_type",
//        @"receiverUid": @"receiver_uid",
//        @"senderUid": @"sender_uid",
//        @"status": @"status",
//    };
//}

//+ (NSArray<NSString *> *)modelPropertyBlacklist {
//    return @[@"showTime"];
//}

- (NSString *)encKey {
    if(!_encKey) {
        _encKey = @"";
    }
    return _encKey;
}

//- (NSString *)clientMsgId {
//    if(!_clientMsgId){
//        _clientMsgId = _clientMsgID;
//    }
//    return _clientMsgId;
//}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"clientMsgId" : @"clientMsgID",
    };
}

- (NSInteger)sendTimeStamp {
    if(_sendTimeStamp == 0 ) {
        _sendTimeStamp = _sendTime.integerValue;
        if(_sendTimeStamp == 0){
            _sendTimeStamp = _createTime;
        }
    }
    return _sendTimeStamp;
}

- (BOOL)showTime {


    __block NSInteger index = 0;
    if([ZMMessageManager sharedInstance].messages.count > 0){
        [[ZMMessageManager sharedInstance].messages enumerateObjectsUsingBlock:^(ZMMessage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if(obj.msgBody.sendTimeStamp == self.sendTimeStamp){
                index = idx - 1;
                *stop = YES;
                return;
            }
        }];
        
        if(index > 0) {
            ZMMessage *preMsg = [[ZMMessageManager sharedInstance].messages objectAtIndex:index];
            
            if(preMsg){
                if(((self.sendTimeStamp / 1000) - (preMsg.sendTimeStamp / 1000)) >= 180){
//                    if([self.msgBody isEqualToString:@"Sdf"]){
//                        NSLog(@"%@\n",preMsg.msgBody.msgBody);
//                    }
                    
                    return YES;
                }
            }
        }
        
        
    }
    
    return NO;
}

@end

@implementation ZMMessageAgentUserJoinSession

@end

@implementation ZMMessageHasReadReceiptMsg

@end

@implementation ZMMessageEndSessionMsg

@end

@implementation ZMMessageSessionBaisc
+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{
             @"latestMsg":[ZMMessageMsgBody class]

             };
}
@end


@implementation ZMMessageCreateSession
+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{
             @"sessionBasic":[ZMMessageSessionBaisc class]

             };
}
@end



@implementation ZMMessageLatestMsgBody


@end

@implementation ZMMessageSessionItem
+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{
             @"latestMsg":[ZMMessageLatestMsgBody class]

             };
}

- (void)setSessionId:(NSString *)sessionId {
    _sessionId = sessionId;
    if(self.latestMsg.sessionId.length == 0) {
        self.latestMsg.sessionId = sessionId;
    }
}

@end

@implementation ZMMessageSessionList
+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{
             @"sessionList":[ZMMessageSessionItem class]

             };
}
@end





