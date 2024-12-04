//
//  ZMUploadQueueTask.m
//  imchat
//
//  Created by Lilou on 2024/11/6.
//

#import "ZMUploadQueueTask.h"
#import "ZMInitUploadRespModel.h"
#import "ZMNetworkManager.h"
#import "SDImageCache.h"
#import <AVFoundation/AVFoundation.h>
#define kZMFileMaxSize (5 * 1024 * 1024)
#define kZMUploadThumbnailPicPathKey ([NSString stringWithFormat:@"img_thumbnail_%@",self.filePath])
#define kZMUploadThumbnailPathKey (self.fileType == ZMUploadFileTypeVideo ? [NSString stringWithFormat:@"%@.jpg",[kZMUploadThumbnailPicPathKey stringByDeletingPathExtension]] : kZMUploadThumbnailPicPathKey)
static NSString *const kZMUploadTasksArchiveKey = @"ZMUploadTasks";
static const NSInteger kMaxRetryCount = 3;
static const NSInteger kDefaultChunkSize = 1024 * 1024; // 1MB per chunk
typedef  void (^ZMThumbnailSuccessBlock)(UIImage *thumbnail);
@interface ZMUploadQueueTask ()
@property (nonatomic, strong) NSBlockOperation *operation;
@property (nonatomic, strong) NSURLSession *uploadSession;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSURLSessionDataTask *> *currentDataTasks;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic) CGFloat fileSize;
@property (nonatomic, strong) __block ZMUploadTask *task;
@property (nonatomic) ZMUploadFileType fileType;
@property (nonatomic, strong) NSData *fileData;
@property (nonatomic, strong) NSFileHandle *fileHandle;
@property (nonatomic, copy) CompleteBlock completeBlock;
@property (nonatomic, copy) ProgressBlock progressBlock;
@property (nonatomic, copy) ActionBlock thumbBlock;
@property (nonatomic, strong) ZMMessage *currentMsg;
@property (nonatomic, strong) NSURLSessionDataTask *uploadTask;
@end

@implementation ZMUploadQueueTask

- (instancetype)initWithStartTask:(NSString *)filePath msg:(ZMMessage *)msg type:(ZMUploadFileType)type queue:(nonnull NSOperationQueue *)queue completeBlock:(nonnull CompleteBlock)completeBlock progressBlock:(nonnull ProgressBlock)progressBlock thumbBlock:(ActionBlock)thumbBlock {
    
    if (self = [super init]) {
        
        @try {
            if(filePath.length == 0){
                [SVProgressHUD showErrorWithStatus:@"文件路径获取失败"];
                return self;;
            }
            
            _currentMsg = msg;
            _currentDataTasks = @{}.mutableCopy;
            _filePath = [[ZMCacheManager sharedManager] getSandboxRealPathWithFileName:[filePath lastPathComponent]];//[[ZMCacheManager sharedManager] copyFileToSandbox:filePath];
            _fileType = type;
            _completeBlock = completeBlock;
            _progressBlock = progressBlock;
            _thumbBlock = thumbBlock;
            
            if(!_filePath){
                return self;
            }
            
            // 打开文件
            self.fileHandle = [self resetAndOpenFileAtPath:_filePath];//[NSFileHandle fileHandleForReadingAtPath:_filePath];
            if (!self.fileHandle) {
                NSError *error = [NSError errorWithDomain:@"FileUploader"
                                                     code:-1
                                                 userInfo:@{NSLocalizedDescriptionKey: @"无法打开文件"}];
                return self;
            }
            
            @autoreleasepool {
                // 缓存
                if(type == ZMUploadFileTypeImage) {
                    UIImage *localImg = [UIImage imageWithContentsOfFile:_filePath];
                    if(localImg){
                        [[SDImageCache sharedImageCache] storeImage:localImg forKey:filePath completion:nil];
                    }
                }
                
            }
            
            NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.zm.upload"];
            config.discretionary = YES;
            config.sessionSendsLaunchEvents = YES;
            self.uploadSession = [NSURLSession sessionWithConfiguration:config
                                                             delegate:self
                                                        delegateQueue:queue];
            // 拆分子任务, 如果大于5兆
            NSError *err = nil;
            BOOL isOver = [self isOver5MB:_filePath error:err];
            if(!err){
                
                // init task
                if(msg.msgBody.task){
                    // restore
                    self.task = [[ZMUploadTask alloc] init];
                    self.task.uploadInfo = msg.msgBody.task.uploadInfo;
                    self.task.uploadInfo.node = msg.msgBody.task.uploadInfo.node;
                    self.task.taskId = msg.msgBody.task.taskId;
                    self.task.filePath = msg.msgBody.task.filePath;
                    self.task.fileType = msg.msgBody.task.fileType;
                    self.task.state = msg.msgBody.task.state;
                    self.task.progress = msg.msgBody.task.progress;
                    self.task.retryCount = msg.msgBody.task.retryCount;
                    self.task.chunkSize = msg.msgBody.task.chunkSize;
                    self.task.currentChunk = msg.msgBody.task.currentChunk;
                    self.task.currentOffset = msg.msgBody.task.currentOffset;
                    self.task.thumbPath = msg.msgBody.task.thumbPath;
                    self.task.thumbWidth = msg.msgBody.task.thumbWidth;
                    self.task.thumbHeight = msg.msgBody.task.thumbHeight;
                    self.task.isBigFile = msg.msgBody.task.isBigFile;
                    [self saveTasksToDisk:nil];
                    msg.msgBody.task = self.task;
                }
                else{
                    self.task = [[ZMUploadTask alloc] init];
                    self.task.taskId = [[NSUUID UUID] UUIDString];
                    self.task.filePath = self.filePath;
                    self.task.fileType = self.fileType;
                    self.task.state = ZMUploadStateUploading;
                    self.task.progress = 0.0;
                    self.task.retryCount = 0;
                    self.task.isBigFile = isOver;
                    msg.msgBody.task = self.task;
                }
                
                [self saveTasksToDisk:self.task];
                
                if(isOver){
                    // 走大文件切片上传
                    [self multiFileUpload];
                }
                else{
                    // 走单文件上传
                    [self singleFileUpload];
                }
            }
            else{
                [SVProgressHUD showErrorWithStatus:err.description];
            }
        } @catch (NSException *exception) {
            return  self;
        } @finally {
            
        }
        
        
    }
    return self;
}

- (NSFileHandle *)resetAndOpenFileAtPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
     
    NSString *realPath = path;

    if ([fileManager fileExistsAtPath:realPath]) {
        // 尝试获取文件描述符
//        int fd = open([path UTF8String], O_RDONLY);
//        if (fd != -1) {
//            // 强制关闭所有相关的文件描述符
//            close(fd);
//        }
//        
//        // 等待一小段时间确保系统释放资源
//        usleep(1000); // 1毫秒
        
        // 重新打开文件
        return [NSFileHandle fileHandleForReadingAtPath:realPath];
    }

    return nil;
}

- (BOOL)isOver5MB:(NSString *)filePath error:(NSError *)error {

    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
    if (!error) {
        unsigned long long fileSize = [fileAttributes fileSize];
        self.fileSize = fileSize;
        return fileSize > kZMFileMaxSize;
    }
    return NO;
}

- (void)saveTasksToDisk:(ZMUploadTask *)task {
//    NSString *key = [NSString stringWithFormat:@"%@_%@_%@_%@",kZMUploadTasksArchiveKey,[ZMMessageManager sharedInstance].sessionId,[ZMCommon md5KeyForURL:self.task.filePath],[NSString stringWithFormat:@"%ld",self.currentMsg.msgBody.sendTimeStamp]];
//    if(task){
//        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.task];
//        [[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
//    }
//    else{
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
//    }
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    if(!task) {
//        [ZMDatabaseManager sharedInstance] deleteWithModelClass:<#(nonnull Class)#> where:<#(nonnull NSString *)#>
//    }
    self.currentMsg.msgBody.task = task;
    // update db, 方便异常情况还原数据
    [[ZMMessageManager sharedInstance] updateMessage:self.currentMsg];
}

- (void)loadTasksFromDisk {
//    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_%@_%@_%@",kZMUploadTasksArchiveKey,[ZMMessageManager sharedInstance].sessionId,[ZMCommon md5KeyForURL:self.task.filePath],[NSString stringWithFormat:@"%ld",self.currentMsg.msgBody.sendTimeStamp]]];
//    if (data) {
//        self.task = [NSKeyedUnarchiver unarchiveObjectWithData:data];
//    }
}

- (void)pauseTask {
//    NSError *err = nil;
//    [self.fileHandle closeAndReturnError:&err];
    
    if(self.task.state == ZMUploadStateUploading) {
        self.task.state = ZMUploadStatePaused;
        if(self.task.progress == 1){
            self.task.state = ZMUploadStateCompleted;
        }
    }
    [self saveTasksToDisk:self.task];
    [self.uploadTask cancel];
}

- (void)resumeTaskWithCompleteBlock:(CompleteBlock)completeBlock progressBlock:(ProgressBlock)progressBlock thumbBlock:(ActionBlock)thumbBlock {
    [self saveTasksToDisk:self.task];
//    self.completeBlock = completeBlock;
//    self.progressBlock = progressBlock;
//    self.thumbBlock = thumbBlock;
    [self addUploadTask:[[ZMCacheManager sharedManager] getSandboxRealPathWithFileName:self.filePath] task:self.task fileType:self.fileType];
}

- (void)retryTaskWithcompleteBlock:(CompleteBlock)completeBlock progressBlock:(ProgressBlock)progressBlock thumbBlock:(ActionBlock)thumbBlock {
    [self saveTasksToDisk:self.task];
//    self.completeBlock = completeBlock;
//    self.progressBlock = progressBlock;
//    self.thumbBlock = thumbBlock;
//    [self.uploadTask suspend];
    // 已经有启动的分块
    if(self.task.uploadInfo && (self.task.uploadInfo.node.count > 0)) {
        [self addUploadTask:[[ZMCacheManager sharedManager] getSandboxRealPathWithFileName:self.filePath] task:self.task fileType:self.fileType];
        
        // 有缩略图
        
        // 无缩略图 优化处理
    }
    else {
        // 无分块，重启
        NSError *err = nil;
        BOOL isOver = [self isOver5MB:_filePath error:err];
        if(!err){

            [self saveTasksToDisk:self.task];
            
            if(isOver){
                // 走大文件切片上传
                [self multiFileUpload];
            }
            else{
                // 走单文件上传
                [self singleFileUpload];
            }
        }else{
            [SVProgressHUD showErrorWithStatus:err.description];
        }
    }
}

- (void)doMultiFileUpload {
    @try {
//
        
        if(self.task.uploadInfo && self.task.uploadInfo.node.count > 0){
            [self saveTasksToDisk:self.task];
            
            [self addUploadTask:self.filePath task:self.task fileType:self.fileType];
            return;
        }
        
        // 初始化
        [ZMHttpHelper initMultiUpload:self.fileSize name:[self.filePath lastPathComponent] headers:nil success:^(NSDictionary *response) {
            NSLog(@"multiPart = %@",response.description);
            ZMInitUploadRespModel *model = [ZMInitUploadRespModel modelWithJSON:response];
            if(model && model.node.count > 0){
                // 开启切割，串行上传
    //            NSError *error = nil;
    //            NSInteger loc = 0;
                
                // 串行
                self.task.uploadInfo = model;
                [self saveTasksToDisk:self.task];
                
                [self addUploadTask:self.filePath task:self.task fileType:self.fileType];
                
                
    //            self.fileData = [NSData dataWithContentsOfFile:self.filePath options:NSDataReadingMappedIfSafe error:&error];
    //            if (!error) {
    //                NSInteger loc = 0;
    //                // 并行
    ////                for (ZMInitUploadRespPartModel *part in model.node) {
    ////                    NSData *chunkData = [fileData subdataWithRange:NSMakeRange(loc, part.size)];
    ////                    [self addUploadTask:self.filePath data:chunkData fileType:self.fileType];
    ////                }
    //
    //                // 串行
    //                self.task = [[ZMUploadTask alloc] init];
    //                self.task.taskId = [[NSUUID UUID] UUIDString];
    ////                self.task.filePath = ;
    //                self.task.node = model.node;
    //                self.task.fileType = self.fileType;
    //                self.task.state = ZMUploadStateWaiting;
    //                self.task.progress = 0.0;
    //                self.task.retryCount = 0;
    //                self.task.chunkSize = kDefaultChunkSize;
    //                [self addUploadTask:self.filePath task:self.task data:self.fileData fileType:self.fileType];
    //
    //            }
            }
            
        } failure:^(NSError *error) {
            
        }];
    } @catch (NSException *exception) {
        [SVProgressHUD showErrorWithStatus:exception.description];
    } @finally {
        
    }
}

- (void)multiFileUpload {
    
    
    [self generateThumbnail:^(UIImage *thumbnail) {
        
        [[SDImageCache sharedImageCache] storeImage:thumbnail forKey:kZMUploadThumbnailPathKey completion:^{
            NSString *cachePath = [[SDImageCache sharedImageCache] cachePathForKey:kZMUploadThumbnailPathKey];
            if (cachePath) {
                self.task.thumbWidth = thumbnail.size.width;
                self.task.thumbHeight = thumbnail.size.height;
                if(self.thumbBlock){
                    [ZMCommon mainExec:^{
                        self.thumbBlock();
                    }];
                    
                }
                [self uploadThumbnail:cachePath isSingle:NO completeBlock:self.completeBlock];
            }
            else {
                [self doMultiFileUpload];
            }
        }];
    }];

}


- (void)uploadThumbnail:(NSString *)thumbPath isSingle:(BOOL)isSingle completeBlock:(CompleteBlock)completeBlock {
    
    @try {
        [[ZMNetworkManager sharedManager] uploadFileWithURL:[NSString stringWithFormat:@"%@/api/single/fileupload",[ZMHttpHelper getCurrentOssUrl]] filePath:thumbPath data:nil param:nil signType:1 progress:^(NSProgress * _Nonnull uploadProgress) {
            
            
        } success:^(id  _Nonnull responseObject) {
            ZMSingleUploadRespModel *model = [ZMSingleUploadRespModel modelWithJSON:responseObject[@"data"] ?: @{}];

            if(model.paths.count > 0){
                
                self.task.thumbPath = model.paths.firstObject.url;
                [self saveTasksToDisk:self.task];
                
                isSingle ? [self doSingleUpload] : [self doMultiFileUpload];
            }
            
        } failure:^(NSError * _Nonnull error) {
            self.task.progress = 0.0;
            self.task.state = ZMUploadStateFailed;
            [self saveTasksToDisk:self.task];
            if(self.completeBlock){
                [ZMCommon mainExec:^{
                    self.completeBlock(nil);
                }];
                
            }
        }];
    } @catch (NSException *exception) {
        self.task.state = ZMUploadStateFailed;
        [self saveTasksToDisk:self.task];
        [SVProgressHUD showErrorWithStatus:exception.description];
    } @finally {
        
    }
    
}

- (void)doSingleUpload {
    @try {
        // 从最佳的oss 地址上传
       self.uploadTask = [[ZMNetworkManager sharedManager] uploadFileWithURL:[NSString stringWithFormat:@"%@/api/single/fileupload",[ZMHttpHelper getCurrentOssUrl]] filePath:self.filePath data:nil param:nil signType:1 progress:^(NSProgress * _Nonnull uploadProgress) {
            if(self.progressBlock){
                self.task.progress = uploadProgress.fractionCompleted;
                self.task.state = ZMUploadStateUploading;
                [self saveTasksToDisk:self.task];
                [ZMCommon mainExec:^{
                    self.progressBlock(uploadProgress.fractionCompleted);
                }];
                
            }
            
        } success:^(id  _Nonnull responseObject) {
            ZMSingleUploadRespModel *model = [ZMSingleUploadRespModel modelWithJSON:responseObject[@"data"] ?: @{}];
            ZMCompleteUploadModel *completeModel = [ZMCompleteUploadModel new];
            if(model.paths.count > 0){
                ZMMessageMsgBodyMediaJson *mediaJson = [ZMMessageMsgBodyMediaJson new];
                mediaJson.resource.url = model.paths.firstObject.url;
                mediaJson.resource.key = model.paths.firstObject.key;
                mediaJson.thumbnail.url = self.task.thumbPath;
                mediaJson.width = self.task.thumbWidth;
                mediaJson.height = self.task.thumbHeight;
                
    //            completeModel.location = [[NSString alloc] initWithData:[mediaJson yy_modelToJSONData] encoding:NSUTF8StringEncoding];
    //            NSString *unescapedJsonString = [completeModel.location stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
                completeModel.location = [mediaJson yy_modelToJSONString];
    //            completeModel.key = model.paths.firstObject.key;
                self.task.progress = 1.0;
                self.task.state = ZMUploadStateCompleted;
                [self saveTasksToDisk:self.task];
                if(self.completeBlock){
                    [ZMCommon mainExec:^{
                        self.completeBlock(completeModel);
                    }];
                    
                }
            }
            
        } failure:^(NSError * _Nonnull error) {
            self.task.progress = 0.0;
            self.task.state = ZMUploadStateFailed;
            [self saveTasksToDisk:self.task];
            if(self.completeBlock){
                [ZMCommon mainExec:^{
                    self.completeBlock(nil);
                }];
                
            }
        }];
    } @catch (NSException *exception) {
        self.task.state = ZMUploadStateFailed;
        [self saveTasksToDisk:self.task];
        [SVProgressHUD showErrorWithStatus:exception.description];
    } @finally {
        
    }
}


- (void)singleFileUpload {
    
    [self generateThumbnail:^(UIImage *thumbnail) {
        [[SDImageCache sharedImageCache] storeImage:thumbnail forKey:kZMUploadThumbnailPathKey completion:^{
            NSString *cachePath = [[SDImageCache sharedImageCache] cachePathForKey:kZMUploadThumbnailPathKey];
            if (cachePath) {
                self.task.thumbWidth = thumbnail.size.width;
                self.task.thumbHeight = thumbnail.size.height;
                if(self.thumbBlock){
                    [ZMCommon mainExec:^{
                        self.thumbBlock();
                    }];
                    
                }
        //        NSData *thumbImgData = UIImageJPEGRepresentation(cachedImage, 0.6);
                [self uploadThumbnail:cachePath isSingle:YES completeBlock:self.completeBlock];
            }
            else {
                [self doSingleUpload];
            }
        }];
    }];
    

}

- (void)generateThumbnail:(ZMThumbnailSuccessBlock)successBlock {
    // 先上传缩略图
    // 先尝试从缓存获取
//    NSString *cachePath = [[SDImageCache sharedImageCache] cachePathForKey:self.filePath];
//    UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromCacheForKey:self.filePath];
    if(self.task.fileType == ZMUploadFileTypeImage) {
        if(successBlock){
            UIImage *img = [UIImage imageWithContentsOfFile:self.filePath];
            
        //    NSData *thumbImgData = UIImageJPEGRepresentation(img, 0.6);
            UIImage *thumbImg = [UIImage compressImageToSize:img];//[UIImage imageWithData:thumbImgData];
            successBlock(thumbImg);
        }

    }
    else if(self.task.fileType == ZMUploadFileTypeVideo) {
        
        @try {
            
            [ZMCommon thumbnailFromVideoPath:self.filePath key:@"" atTime:CMTimeMakeWithSeconds(1.0, 600) completion:^(UIImage *thumbnail, NSError *error) {
                if (thumbnail) {
                    
                    if(successBlock){
                        successBlock(thumbnail);
                    }
                    
                    
                } else {
                    if(successBlock){
                        successBlock(nil);
                    }
                    [SVProgressHUD showErrorWithStatus:@"Error generating thumbnail"];
                }
            }];
            
            
        } @catch (NSException *exception) {
            [SVProgressHUD showErrorWithStatus:exception.description];
        } @finally {
            
        }
        

    }

}





#pragma mark - Task Management



// 添加每个的上传任务
- (void)addUploadTask:(NSString *)filePath task:(ZMUploadTask *)task fileType:(ZMUploadFileType)fileType {
//    static NSInteger offset = 0;
    
    // 计算分片信息
//    NSError *error = nil;
//    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
//    if (!error) {
//        unsigned long long fileSize = [fileAttributes fileSize];
//        task.totalChunks = (NSInteger)ceil((double)fileSize / task.chunkSize);
//        task.currentChunk = 0;
//    }
    
//    self.uploadTasks[task.taskId] = task;
//    [self.taskQueue addObject:task];
//    [self saveTasksToDisk];
//    
//    [self processNextTask];
//    NSInteger offset = self.task.currentChunk * self.task.uploadInfo
    if(self.task.currentOffset >= self.fileSize){
     
        
//        if(self.task.uploadInfo && self.task.uploadInfo.node.count > 0){
//            if(self.task.uploadInfo.node.lastObject.eTag.length > 0){
//                self.task.progress = 1;
//                self.task.state = ZMUploadStateCompleted;
//                [self saveTasksToDisk:self.task];
//               
//                if(self.completeBlock){
//                    [ZMCommon mainExec:^{
//                        self.completeBlock(nil);
//                    }];
//                    
//                }
//                return;
//            }
//        }
        
        
        // 上传完成
        [ZMHttpHelper completeMultiUpload:self.task headers:nil success:^(NSDictionary *response) {
            ZMCompleteUploadModel *completeModel = [ZMCompleteUploadModel modelWithJSON:response];
            ZMMessageMsgBodyMediaJson *mediaJson = [ZMMessageMsgBodyMediaJson new];
            mediaJson.resource.url = completeModel.location;
            mediaJson.resource.key = completeModel.key;
            mediaJson.thumbnail.url = self.task.thumbPath;
            mediaJson.width = self.task.thumbWidth;
            mediaJson.height = self.task.thumbHeight;
            completeModel.location = [mediaJson yy_modelToJSONString];
            self.task.progress = 1;
            self.task.state = ZMUploadStateCompleted;
            [self saveTasksToDisk:self.task];
           
            if(self.completeBlock){
                [ZMCommon mainExec:^{
                    self.completeBlock(completeModel);
                }];
                
            }
        } failure:^(NSError *error) {
            [self saveTasksToDisk:self.task];
        }];
        return;
    }
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.task.uploadInfo.node[self.task.currentChunk].url]];
    request.HTTPMethod = @"PUT";
    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
//    [request setValue:task.taskId forHTTPHeaderField:@"X-Upload-Id"];
    [self.task.uploadInfo.node[self.task.currentChunk].header enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if([obj isKindOfClass:NSArray.class]){
            id value = ((NSArray *)obj).firstObject;
            [request setValue:[NSString stringWithFormat:@"%@",value] forHTTPHeaderField:key];
        }
        else if([obj isKindOfClass:NSString.class])
        {
            [request setValue:obj forHTTPHeaderField:key];
        }
        
    }];
//    [request setAllHTTPHeaderFields:task.uploadInfo.node[task.currentChunk].header];
//    [request setValue:@(task.currentChunk).stringValue forHTTPHeaderField:@"X-Chunk-Index"];
//    [request setValue:@(task.totalChunks).stringValue forHTTPHeaderField:@"X-Total-Chunks"];
    
    
    
    [self.fileHandle seekToFileOffset:self.task.currentOffset];
    
    
    NSData *chunkData = [self.fileHandle readDataOfLength:self.task.uploadInfo.node[self.task.currentChunk].size];
    
    // 创建上传任务
    NSURLSession *session = [NSURLSession sharedSession];
    self.uploadTask = [session uploadTaskWithRequest:request
                                                               fromData:chunkData
          
                                                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(!error){
            // 打印响应头
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                NSDictionary *headers = [httpResponse allHeaderFields];
                NSLog(@"Response Headers: %@", headers);
                self.task.uploadInfo.node[self.task.currentChunk].eTag = headers[@"Etag"] ?: @"";
//                self.task.currentOffset += self.task.uploadInfo.node[self.task.currentChunk].size + 1;
                self.task.currentOffset += self.task.uploadInfo.node[self.task.currentChunk].size;
                self.task.currentChunk += 1;
                self.task.progress = (((CGFloat)self.task.currentChunk - 1) / self.task.uploadInfo.node.count);
                NSLog(@"progress = %f",self.task.progress);
                self.task.state = ZMUploadStateUploading;
                [self saveTasksToDisk:self.task];
                [self addUploadTask:self.filePath task:self.task fileType:self.fileType];
            }
        }
        else{
            // 更新task 状态, 终结任务，刷新UI
            if(error.code == -999){
                self.task.state = ZMUploadStatePaused;
                [self saveTasksToDisk:self.task];
                if(self.completeBlock){
                    [ZMCommon mainExec:^{
                        self.completeBlock(nil);
                    }];
                }
            }
            else{
                self.task.state = ZMUploadStateFailed;
                [self saveTasksToDisk:self.task];
                if(self.completeBlock){
                    [ZMCommon mainExec:^{
                        self.completeBlock(nil);
                    }];
                    
                }
            }
            
        }
        
        // 更新UI
        
//        if (error) {
//            [self cleanup];
//            if (self.completionBlock) {
//                self.completionBlock(NO, nil, error);
//            }
//            return;
//        }
        
//        // 更新进度
//        self.currentChunk++;
//        if (self.progressBlock) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                float progress = (float)self.currentChunk / self.totalChunks;
//                self.progressBlock(progress);
//            });
//        }
        
//        // 上传下一个分片
//        [self uploadNextChunk];
    }];
    
    [self.uploadTask resume];
    
    
    
//    NSData *chunkData = [data subdataWithRange:NSMakeRange(offset, task.node[task.currentChunk].size)];
//    NSURLSessionDataTask *dataTask = [self.uploadSession uploadTaskWithRequest:request fromData:data completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        if(!error){
//            offset += task.node[task.currentChunk].size;
//            task.currentChunk++;
//            [self addUploadTask:self.filePath task:task data:data fileType:self.fileType];
//        }
//    }];
//    NSURLSessionDataTask *dataTask = [self.uploadSession uploadTaskWithRequest:request fromData:data];
//    dataTask.taskDescription = task.taskId;
//    self.currentDataTasks[task.taskId] = dataTask;
//    [dataTask resume];
    
//    return task;
}


#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
//
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    static NSInteger offset1 = 0;
    if(!error){
        offset1 += self.task.uploadInfo.node[self.task.currentChunk].size;
        self.task.currentChunk++;
        [self addUploadTask:self.filePath task:self.task fileType:self.fileType];
    }
}


@end


@implementation ZMUploadTask

// 重写删除方法，实现级联删除
//+ (void)onDidDeleteObject:(NSObject *)entity {
//    ZMUploadTask *model = (ZMUploadTask *)entity;
//    if (model.uploadInfo) {
//        // 删除关联的子模型
////        [[LKDBHelper getUsingLKDBHelper] deleteToDBWithModel:model.subModel];
//        [model.uploadInfo deleteToDB];
//    }
//}

//- (void)setUploadInfo:(ZMInitUploadRespModel *)uploadInfo
//{
//    _uploadInfo = uploadInfo;
////    if(!uploadInfo) {
//        [uploadInfo deleteToDB];
////    }
//
//    
//}

// 定义关联关系
//+ (NSDictionary *)getTableMapping {
//    return @{
//        @"uploadInfo": [ZMInitUploadRespModel class]
//    };
//}


- (void)setProgress:(CGFloat)progress {
    
    if(_progress != progress) {
        // 如果相关状态有变化， 做对应逻辑和UI处理
        _progress = progress;
        
        // 发送通知
        if(self.taskId && self.filePath){
            [[NSNotificationCenter defaultCenter] postNotificationName:kZMMessageFileUploadDidChangeNotification object:self userInfo:nil];

        }
    }
    
}
@end
