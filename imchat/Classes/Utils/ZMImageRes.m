//
//  ZMImageResUtil.m
//  imchat
//
//  Created by Lilou on 2024/10/17.
//

#import "ZMImageRes.h"

@implementation ZMImageRes
+ (NSString *)avatar {
    return @"chat_like";
}

+ (NSString *)likeChecked{
    return @"chat_like_checked";
}

+ (NSString *)likeUnChecked{
    return @"chat_like_unchecked";
}

+ (NSString *)unLikeChecked {
    return @"chat_unlike_checked";
}

+ (NSString *)unLikeUnChecked {
    return @"chat_unlike_unchecked";
}

+ (NSString *)choosePic{
    return @"chat_choosePic";
}

+ (NSString *)chatSend{
    return @"chat_send";
}

+ (NSString *)chatMsgRead{
    return @"chat_msg_read";
}

+ (NSString *)chatMsgUnRead{
    return @"chat_msg_unread";
}

+ (NSString *)chatMsgLoad{
    return @"chat_msg_load";
}

+ (NSString *)chatMsgFail{
    return @"chat_msg_fail";
}

+ (NSString *)chatVideoPlay{
    return @"chat_video_play";
}

+ (NSString *)chatVideoPlayBig{
    return @"chat_video_play_big";
}

+ (NSString *)chatMediaFail{
    return @"chat_media_fail";
}

+ (NSString *)chatMediaUpload
{
    return @"chat_media_upload";
}

+ (NSString *)chatMediaDownload{
    return @"chat_media_download";
}

+ (NSString *)chatMediaClose{
    return @"chat_media_close";
}

+ (NSString *)chatTextArrorUp{
    return @"chat_textArrow_up";
}

+ (NSString *)chatTextArrorDown{
    return @"chat_textArrow_down";
}

+ (NSString *)chatNetFail {
    return @"chat_net_fail";
}

+ (NSString *)chatNetLoad {
    return @"chat_net_load";
}

+ (NSString *)chatCommonArrowDown{
    return @"chat_common_arrow_down";
}

+ (NSString *)chatBackBlack {
    return @"chat_back_black";
}

+ (NSString *)chatSystemAvatar {
    return @"chat_system";
}

+ (NSString *)chatFaqAvatar {
    return @"chat_system_avatar";
}

+ (NSString *)chatUploadFail{
    return @"chat_upload_fail";
}

+ (NSString *)chatUploadPause
{
    return @"chat_upload_pause";
}
@end
