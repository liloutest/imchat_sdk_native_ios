//
//  ZMInitUploadRespModel.h
//  imchat
//
//  Created by Lilou on 2024/11/6.
//

#import "ZMModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZMInitUploadRespPartModel : ZMResponseModel
@property (nonatomic,copy) NSDictionary *header;
@property (nonatomic) NSInteger size;
@property (nonatomic,copy) NSString *url;
// custom
// 每个分片传成功后， 取response header 里的etag 回写进来 构成完整分片状态， 整体上传完后， 构造tag 列表接口告诉后端 整个完成上传，  <注意细节： 后端6小时有效期机制>
@property (nonatomic,copy) NSString *eTag;
@end

@interface ZMInitUploadRespModel : ZMResponseModel
@property (nonatomic,copy) NSString *uploadId;
@property (nonatomic,strong) NSArray<ZMInitUploadRespPartModel *> *node;
@end

NS_ASSUME_NONNULL_END
