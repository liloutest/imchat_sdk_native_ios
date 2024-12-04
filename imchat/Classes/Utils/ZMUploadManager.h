#import <Foundation/Foundation.h>
#import "ZMUploadQueueTask.h"
#import "ZMCompleteUploadModel.h"


@protocol ZMUploadManagerDelegate <NSObject>

- (void)uploadTaskDidUpdateProgress:(ZMUploadTask *)task;
- (void)uploadTaskDidFinish:(ZMUploadTask *)task;
- (void)uploadTask:(ZMUploadTask *)task didFailWithError:(NSError *)error;

@end

@interface ZMUploadManager : NSObject

@property (nonatomic, weak) id<ZMUploadManagerDelegate> delegate;

+ (instancetype)sharedManager;

- (void)startTaskWithMsg:(ZMMessage *)msg filePath:(NSString *)filePath type:(ZMUploadFileType)type queue:(NSOperationQueue *)queue completeBlock:(CompleteBlock)completeBlock progressBlock:(ProgressBlock)progressBlock thumbBlock:(ActionBlock)thumbBlock;

- (void)pauseTaskWithMsg:(ZMMessage *)msg;

- (void)resumeTaskWithMsg:(ZMMessage *)msg completeBlock:(CompleteBlock)completeBlock progressBlock:(ProgressBlock)progressBlock thumbBlock:(ActionBlock)thumbBlock;

- (void)retryTaskWithMsg:(ZMMessage *)msg completeBlock:(CompleteBlock)completeBlock progressBlock:(ProgressBlock)progressBlock thumbBlock:(ActionBlock)thumbBlock;


// 添加上传任务
//- (ZMUploadTask *)addUploadTask:(NSString *)filePath fileType:(ZMUploadFileType)fileType;
//
//// 开始上传任务
//- (void)startTask:(NSString *)taskId;
//
//// 暂停上传任务
//- (void)pauseTask:(NSString *)taskId;
//
//// 取消上传任务
//- (void)cancelTask:(NSString *)taskId;
//
//// 重试上传任务
//- (void)retryTask:(NSString *)taskId;
//
//// 获取所有任务
//- (NSArray<ZMUploadTask *> *)allTasks;
//
//// 获取指定状态的任务
//- (NSArray<ZMUploadTask *> *)tasksWithState:(ZMUploadState)state;
//
//// 清除所有已完成任务
//- (void)clearCompletedTasks;

@end 
