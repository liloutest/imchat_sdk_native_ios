//
//  ZMUploadQueueTask.h
//  imchat
//
//  Created by Lilou on 2024/11/6.
//

#import <Foundation/Foundation.h>
#import "ZMInitUploadRespModel.h"
#import "ZMCompleteUploadModel.h"
#import "ZMSingleUploadRespModel.h"
#import "ZMMessage.h"
typedef NS_ENUM(NSInteger, ZMUploadState) {
    ZMUploadStateWaiting,     // 等待上传
    ZMUploadStateUploading,   // 上传中
    ZMUploadStatePaused,      // 暂停
    ZMUploadStateFailed,      // 失败
    ZMUploadStateCompleted    // 完成
};

typedef NS_ENUM(NSInteger, ZMUploadFileType) {
    ZMUploadFileTypeImage,    // 图片
    ZMUploadFileTypeVideo,     // 视频
    ZMUploadFileTypeFile     // 文件
};

typedef void (^CompleteBlock)(ZMCompleteUploadModel * _Nullable model);

NS_ASSUME_NONNULL_BEGIN

@interface ZMUploadTask : ZMModel
@property (nonatomic,strong) ZMInitUploadRespModel *uploadInfo;
@property (nonatomic, copy) NSString *taskId;           // 任务唯一标识
@property (nonatomic, copy) NSString *filePath;         // 文件路径
@property (nonatomic, assign) ZMUploadFileType fileType;// 文件类型
@property (nonatomic, assign) ZMUploadState state;      // 上传状态
@property (nonatomic, assign) CGFloat progress;           // 上传进度
@property (nonatomic, assign) NSInteger retryCount;     // 重试次数
@property (nonatomic, assign) NSInteger chunkSize;      // 分片大小
@property (nonatomic, assign) NSInteger currentChunk;   // 当前分片索引
//@property (nonatomic, assign) NSInteger totalChunks;    // 总分片数
@property (nonatomic, assign) NSInteger currentOffset;
@property (nonatomic, copy) NSString *thumbPath;
@property (nonatomic) NSInteger thumbWidth;
@property (nonatomic) NSInteger thumbHeight;
@property (nonatomic) BOOL isBigFile;
@end

@interface ZMUploadQueueTask : NSObject

// 开始上传任务
- (instancetype)initWithStartTask:(NSString *)filePath msg:(ZMMessage *)msg type:(ZMUploadFileType)type queue:(NSOperationQueue *)queue completeBlock:(CompleteBlock)completeBlock progressBlock:(ProgressBlock)progressBlock thumbBlock:(ActionBlock)thumbBlock;

- (void)pauseTask;

- (void)resumeTaskWithCompleteBlock:(CompleteBlock)completeBlock progressBlock:(ProgressBlock)progressBlock thumbBlock:(ActionBlock)thumbBlock;

- (void)retryTaskWithcompleteBlock:(CompleteBlock)completeBlock progressBlock:(ProgressBlock)progressBlock thumbBlock:(ActionBlock)thumbBlock;
@end

NS_ASSUME_NONNULL_END
