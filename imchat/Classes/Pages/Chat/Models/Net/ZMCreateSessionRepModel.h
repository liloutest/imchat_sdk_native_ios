//
//  ZMCreateSessionRepModel.h
//  imchat
//
//  Created by Lilou on 2024/10/23.
//

#import "ZMResponseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZMCreateSessionRepModel : ZMResponseModel
@property (nonatomic, copy) NSString *sessionId;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *uid;
@end

NS_ASSUME_NONNULL_END
