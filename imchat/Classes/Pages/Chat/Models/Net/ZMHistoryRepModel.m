//
//  ZMHistoryRepModel.m
//  imchat
//
//  Created by Lilou on 2024/10/23.
//

#import "ZMHistoryRepModel.h"

@implementation ZMHistoryItemContent

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
@end

@implementation ZMHistoryRepModel
+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{
             @"content":[ZMMessageMsgBody class],
          
             };
}
@end
