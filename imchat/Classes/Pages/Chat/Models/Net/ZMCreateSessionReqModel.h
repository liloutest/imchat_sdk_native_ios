//
//  ZMCreateSessionReqModel.h
//  imchat
//
//  Created by Lilou on 2024/10/23.
//

#import "ZMModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZMCreateSessionReqModel : ZMModel
@property (nonatomic, copy) NSString *device;
@property (nonatomic, copy) NSString *extraInfo;
@property (nonatomic, copy) NSString *headIcon;
@property (nonatomic, copy) NSString *language;
@property (nonatomic, copy) NSString *nickId;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *identityID;
@end

NS_ASSUME_NONNULL_END
