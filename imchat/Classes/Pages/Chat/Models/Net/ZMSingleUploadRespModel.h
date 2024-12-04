//
//  ZMSingleUploadRespModel.h
//  imchat
//
//  Created by Lilou on 2024/11/8.
//

#import "ZMResponseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZMSingleUploadItemModel : ZMResponseModel
@property (nonatomic,copy) NSString *url;
@property (nonatomic,copy) NSString *key;
@end

@interface ZMSingleUploadRespModel : ZMResponseModel
@property (nonatomic,strong) NSArray<ZMSingleUploadItemModel *> *paths;
@end

NS_ASSUME_NONNULL_END
