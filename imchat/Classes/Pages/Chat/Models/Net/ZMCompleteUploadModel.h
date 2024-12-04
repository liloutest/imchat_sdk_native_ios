//
//  ZMCompleteUploadModel.h
//  imchat
//
//  Created by Lilou on 2024/11/7.
//

#import "ZMResponseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZMCompleteUploadModel : ZMResponseModel
@property (nonatomic,copy) NSString *key;
@property (nonatomic,copy) NSString *etag;
@property (nonatomic,copy) NSString *location;
@end

NS_ASSUME_NONNULL_END
