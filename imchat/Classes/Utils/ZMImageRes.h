//
//  ZMImageResUtil.h
//  imchat
//
//  Created by Lilou on 2024/10/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZMImageRes : NSObject
@property (nonatomic,copy,class,readonly) NSString *avatar;
@property (nonatomic,copy,class,readonly) NSString *likeChecked;
@property (nonatomic,copy,class,readonly) NSString *likeUnChecked;
@property (nonatomic,copy,class,readonly) NSString *unLikeChecked;
@property (nonatomic,copy,class,readonly) NSString *unLikeUnChecked;
@property (nonatomic,copy,class,readonly) NSString *choosePic;
@property (nonatomic,copy,class,readonly) NSString *chatSend;
@property (nonatomic,copy,class,readonly) NSString *chatMsgRead;
@property (nonatomic,copy,class,readonly) NSString *chatMsgUnRead;
@property (nonatomic,copy,class,readonly) NSString *chatMsgFail;
@property (nonatomic,copy,class,readonly) NSString *chatMsgLoad;
@property (nonatomic,copy,class,readonly) NSString *chatVideoPlay;
@property (nonatomic,copy,class,readonly) NSString *chatVideoPlayBig;
@property (nonatomic,copy,class,readonly) NSString *chatMediaFail;
@property (nonatomic,copy,class,readonly) NSString *chatMediaUpload;
@property (nonatomic,copy,class,readonly) NSString *chatMediaClose;
@property (nonatomic,copy,class,readonly) NSString *chatMediaDownload;
@property (nonatomic,copy,class,readonly) NSString *chatTextArrorUp;
@property (nonatomic,copy,class,readonly) NSString *chatTextArrorDown;
@property (nonatomic,copy,class,readonly) NSString *chatNetFail;
@property (nonatomic,copy,class,readonly) NSString *chatNetLoad;
@property (nonatomic,copy,class,readonly) NSString *chatCommonArrowDown;
@property (nonatomic,copy,class,readonly) NSString *chatBackBlack;
@property (nonatomic,copy,class,readonly) NSString *chatSystemAvatar;
@property (nonatomic,copy,class,readonly) NSString *chatFaqAvatar;
@property (nonatomic,copy,class,readonly) NSString *chatUploadFail;
@property (nonatomic,copy,class,readonly) NSString *chatUploadPause;
@end

NS_ASSUME_NONNULL_END
