//
//  ZMTimeoutConfigRespModel.h
//  imchat
//
//  Created by Lilou on 2024/11/20.
//

#import "ZMResponseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZMTimeoutConfigRespModel : ZMResponseModel
/// 是否开启
@property (nonatomic) BOOL isOpen;
/// 超时时间(分钟)
@property (nonatomic) NSInteger timeout;
@end

NS_ASSUME_NONNULL_END
