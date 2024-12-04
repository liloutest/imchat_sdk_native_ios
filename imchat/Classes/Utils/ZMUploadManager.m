#import "ZMUploadManager.h"

static NSString *const kZMUploadTasksArchiveKey = @"ZMUploadTasks";
static const NSInteger kMaxRetryCount = 3;
static const NSInteger kDefaultChunkSize = 1024 * 1024; // 1MB per chunk

@interface ZMUploadManager () <NSURLSessionDataDelegate>

@property (nonatomic, strong) NSMutableDictionary<NSString *, ZMUploadQueueTask *> *uploadTasks;
@property (nonatomic, strong) NSMutableArray<ZMUploadTask *> *taskQueue;
@property (nonatomic, strong) NSURLSession *uploadSession;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSURLSessionDataTask *> *currentDataTasks;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableData *> *receivedDataDict;
@property (nonatomic, assign) NSInteger maxConcurrentUploads;

@end

@implementation ZMUploadManager

+ (instancetype)sharedManager {
    static ZMUploadManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ZMUploadManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
//        [self loadTasksFromDisk];
//        [self setupNetworkMonitoring];
//        [self setupBackgroundTask];
    }
    return self;
}


- (void)startTaskWithMsg:(ZMMessage *)msg filePath:(NSString *)filePath type:(ZMUploadFileType)type queue:(NSOperationQueue *)queue completeBlock:(CompleteBlock)completeBlock progressBlock:(ProgressBlock)progressBlock thumbBlock:(ActionBlock)thumbBlock {
    ZMUploadQueueTask *task = [[ZMUploadQueueTask alloc] initWithStartTask:filePath msg:msg type:type queue:[NSOperationQueue new] completeBlock:completeBlock progressBlock:progressBlock thumbBlock:thumbBlock];
    [self.uploadTasks setObject:task forKey:[NSString stringWithFormat:@"%@",msg.msgBody.clientMsgId]];
}

- (void)pauseTaskWithMsg:(ZMMessage *)msg {
    
    if(!msg) {
        // 取消所有
        [self.uploadTasks enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, ZMUploadQueueTask * _Nonnull obj, BOOL * _Nonnull stop) {
            [obj pauseTask];
        }];
    }
    else{
        ZMUploadQueueTask *task = [self.uploadTasks objectForKey:[NSString stringWithFormat:@"%@",msg.msgBody.clientMsgId]];
        if(task){
            [task pauseTask];
        }
    }
    
   
}

- (void)resumeTaskWithMsg:(ZMMessage *)msg completeBlock:(CompleteBlock)completeBlock progressBlock:(ProgressBlock)progressBlock thumbBlock:(ActionBlock)thumbBlock {
    ZMUploadQueueTask *task = [self.uploadTasks objectForKey:[NSString stringWithFormat:@"%@",msg.msgBody.clientMsgId]];
    if(task){
        [task resumeTaskWithCompleteBlock:completeBlock progressBlock:progressBlock thumbBlock:thumbBlock];
    }
    else {
        ZMUploadQueueTask *task = [[ZMUploadQueueTask alloc] initWithStartTask:[[ZMCacheManager sharedManager] getSandboxRealPathWithFileName:[msg.msgBody.task.filePath lastPathComponent]] msg:msg type:msg.msgBody.task.fileType queue:[NSOperationQueue new] completeBlock:completeBlock progressBlock:progressBlock thumbBlock:thumbBlock];
        [self.uploadTasks setObject:task forKey:[NSString stringWithFormat:@"%@",msg.msgBody.clientMsgId]];
    }
}

- (void)retryTaskWithMsg:(ZMMessage *)msg completeBlock:(CompleteBlock)completeBlock progressBlock:(ProgressBlock)progressBlock thumbBlock:(ActionBlock)thumbBlock {
    ZMUploadQueueTask *task = [self.uploadTasks objectForKey:[NSString stringWithFormat:@"%@",msg.msgBody.clientMsgId]];
    if(task){
        [task retryTaskWithcompleteBlock:completeBlock progressBlock:progressBlock thumbBlock:thumbBlock];
    }
    else {
        ZMUploadQueueTask *task = [[ZMUploadQueueTask alloc] initWithStartTask:[[ZMCacheManager sharedManager] getSandboxRealPathWithFileName:[msg.msgBody.task.filePath lastPathComponent]] msg:msg type:msg.msgBody.task.fileType queue:[NSOperationQueue new] completeBlock:completeBlock progressBlock:progressBlock thumbBlock:thumbBlock];
        [self.uploadTasks setObject:task forKey:[NSString stringWithFormat:@"%@",msg.msgBody.clientMsgId]];
    }
}

- (void)setup {
    self.uploadTasks = [NSMutableDictionary dictionary];
//    self.taskQueue = [NSMutableArray array];
//    self.currentDataTasks = [NSMutableDictionary dictionary];
//    self.receivedDataDict = [NSMutableDictionary dictionary];
//    self.maxConcurrentUploads = 9;
//    
//    self.operationQueue = [[NSOperationQueue alloc] init];
//    self.operationQueue.maxConcurrentOperationCount = self.maxConcurrentUploads;
//    
////    NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.zm.upload"];
//    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
//    config.discretionary = YES;
//    config.sessionSendsLaunchEvents = YES;
//    self.uploadSession = [NSURLSession sessionWithConfiguration:config
//                                                     delegate:self
//                                                delegateQueue:self.operationQueue];
}
//
//#pragma mark - Task Management
//
//// 添加每个的上传任务
//- (ZMUploadTask *)addUploadTask:(NSString *)filePath fileType:(ZMUploadFileType)fileType {
//    ZMUploadTask *task = [[ZMUploadTask alloc] init];
//    task.taskId = [[NSUUID UUID] UUIDString];
//    task.filePath = filePath;
//    task.fileType = fileType;
//    task.state = ZMUploadStateWaiting;
//    task.progress = 0.0;
//    task.retryCount = 0;
//    task.chunkSize = kDefaultChunkSize;
//    
//    // 计算分片信息
//    NSError *error = nil;
//    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
//    if (!error) {
//        unsigned long long fileSize = [fileAttributes fileSize];
////        task.totalChunks = (NSInteger)ceil((double)fileSize / task.chunkSize);
//        task.currentChunk = 0;
//    }
//    
//    self.uploadTasks[task.taskId] = task;
//    [self.taskQueue addObject:task];
//    [self saveTasksToDisk];
//    
//    [self processNextTask];
//    
//    return task;
//}
//
//- (void)startTask:(NSString *)taskId {
//    ZMUploadTask *task = self.uploadTasks[taskId];
//    if (task && task.state != ZMUploadStateUploading) {
//        task.state = ZMUploadStateWaiting;
//        [self processNextTask];
//    }
//}
//
//- (void)pauseTask:(NSString *)taskId {
//    ZMUploadTask *task = self.uploadTasks[taskId];
//    if (task && task.state == ZMUploadStateUploading) {
//        task.state = ZMUploadStatePaused;
//        [self.currentDataTasks[taskId] cancel];
//        [self saveTasksToDisk];
//        [self processNextTask];
//    }
//}
//
//- (void)cancelTask:(NSString *)taskId {
//    ZMUploadTask *task = self.uploadTasks[taskId];
//    if (task) {
//        if (task.state == ZMUploadStateUploading) {
//            [self.currentDataTasks[taskId] cancel];
//        }
//        [self.uploadTasks removeObjectForKey:taskId];
//        [self.taskQueue removeObject:task];
//        [self saveTasksToDisk];
//        [self processNextTask];
//    }
//}
//
//- (void)retryTask:(NSString *)taskId {
//    ZMUploadTask *task = self.uploadTasks[taskId];
//    if (task && task.state == ZMUploadStateFailed && task.retryCount < kMaxRetryCount) {
//        task.retryCount++;
//        task.state = ZMUploadStateWaiting;
//        [self processNextTask];
//    }
//}
//
//#pragma mark - Upload Process
//
//- (void)processNextTask {
//    NSInteger currentUploading = [self.currentDataTasks count];
//    if (currentUploading >= self.maxConcurrentUploads) return;
//    
//    NSInteger availableSlots = self.maxConcurrentUploads - currentUploading;
//    
//    NSArray *waitingTasks = [self.taskQueue filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(ZMUploadTask *task, NSDictionary *bindings) {
//        return task.state == ZMUploadStateWaiting;
//    }]];
//    
//    for (NSInteger i = 0; i < MIN(availableSlots, waitingTasks.count); i++) {
//        ZMUploadTask *task = waitingTasks[i];
//        [self uploadTask:task];
//    }
//}
//
//- (void)uploadTask:(ZMUploadTask *)task {
////    task.state = ZMUploadStateUploading;
////    
////    NSError *error = nil;
////    NSData *fileData = [NSData dataWithContentsOfFile:task.filePath options:NSDataReadingMappedIfSafe error:&error];
////    if (error) {
////        [self handleUploadError:error forTask:task];
////        return;
////    }
////    
////    NSInteger startOffset = task.currentChunk * task.chunkSize;
////    NSInteger length = MIN(task.chunkSize, fileData.length - startOffset);
////    NSData *chunkData = [fileData subdataWithRange:NSMakeRange(startOffset, length)];
////    
////    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:task.uploadUrl]];
////    request.HTTPMethod = @"POST";
////    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
////    [request setValue:task.taskId forHTTPHeaderField:@"X-Upload-Id"];
////    [request setValue:@(task.currentChunk).stringValue forHTTPHeaderField:@"X-Chunk-Index"];
//////    [request setValue:@(task.totalChunks).stringValue forHTTPHeaderField:@"X-Total-Chunks"];
////    
////    NSURLSessionDataTask *dataTask = [self.uploadSession uploadTaskWithRequest:request fromData:chunkData];
////    dataTask.taskDescription = task.taskId;
////    self.currentDataTasks[task.taskId] = dataTask;
////    [dataTask resume];
//}
//
//#pragma mark - NSURLSessionDataDelegate
//
//- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
//    didReceiveData:(NSData *)data {
//    NSString *taskId = dataTask.taskDescription;
//    NSMutableData *receivedData = self.receivedDataDict[taskId];
//    if (!receivedData) {
//        receivedData = [NSMutableData data];
//        self.receivedDataDict[taskId] = receivedData;
//    }
//    [receivedData appendData:data];
//}
//
//- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
//didCompleteWithError:(nullable NSError *)error {
////    NSString *taskId = task.taskDescription;
////    ZMUploadTask *uploadTask = self.uploadTasks[taskId];
////    NSMutableData *receivedData = self.receivedDataDict[taskId];
////    
////    [self.currentDataTasks removeObjectForKey:taskId];
////    [self.receivedDataDict removeObjectForKey:taskId];
////    
////    if (error) {
////        [self handleUploadError:error forTask:uploadTask];
////    } else {
////        NSError *jsonError;
////        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:receivedData
////                                                               options:0
////                                                                 error:&jsonError];
////        if (jsonError) {
////            [self handleUploadError:jsonError forTask:uploadTask];
////            return;
////        }
////        
////        uploadTask.currentChunk++;
////        uploadTask.progress = (float)uploadTask.currentChunk / uploadTask.totalChunks;
////        
////        if ([self.delegate respondsToSelector:@selector(uploadTaskDidUpdateProgress:)]) {
////            [self.delegate uploadTaskDidUpdateProgress:uploadTask];
////        }
////        
////        if (uploadTask.currentChunk < uploadTask.totalChunks) {
////            [self uploadTask:uploadTask];
////        } else {
////            uploadTask.state = ZMUploadStateCompleted;
////            if ([self.delegate respondsToSelector:@selector(uploadTaskDidFinish:)]) {
////                [self.delegate uploadTaskDidFinish:uploadTask];
////            }
////            [self saveTasksToDisk];
////        }
////    }
////    
////    [self processNextTask];
//}
//
//#pragma mark - Persistence
//
//- (void)saveTasksToDisk {
//    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.uploadTasks];
//    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kZMUploadTasksArchiveKey];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//}
//
//- (void)loadTasksFromDisk {
//    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kZMUploadTasksArchiveKey];
//    if (data) {
//        self.uploadTasks = [NSKeyedUnarchiver unarchiveObjectWithData:data];
//        [self.taskQueue addObjectsFromArray:self.uploadTasks.allValues];
//    }
//}
//
//#pragma mark - Network Monitoring
//
//- (void)setupNetworkMonitoring {
//    // 使用 Reachability 监听网络状态
////    [[NSNotificationCenter defaultCenter] addObserver:self
////                                           selector:@selector(handleNetworkChange:)
////                                               name:kReachabilityChangedNotification
////                                             object:nil];
//}
//
//- (void)handleNetworkChange:(NSNotification *)notification {
////    if ([AFne]) {
////        [self processNextTask];
////    } else {
////        if (self.isUploading) {
////            [self pauseTask:self.currentDataTask.taskDescription];
////        }
////    }
//}
//
//#pragma mark - Background Task
//
//- (void)setupBackgroundTask {
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                           selector:@selector(applicationDidEnterBackground:)
//                                               name:UIApplicationDidEnterBackgroundNotification
//                                             object:nil];
//}
//
//- (void)applicationDidEnterBackground:(NSNotification *)notification {
//    UIApplication *application = [UIApplication sharedApplication];
//    __block UIBackgroundTaskIdentifier backgroundTask = [application beginBackgroundTaskWithExpirationHandler:^{
//        [application endBackgroundTask:backgroundTask];
//        backgroundTask = UIBackgroundTaskInvalid;
//    }];
//}
//
//#pragma mark - Helper Methods
//
//- (void)handleUploadError:(NSError *)error forTask:(ZMUploadTask *)task {
//    task.state = ZMUploadStateFailed;
//    if ([self.delegate respondsToSelector:@selector(uploadTask:didFailWithError:)]) {
//        [self.delegate uploadTask:task didFailWithError:error];
//    }
//    [self saveTasksToDisk];
//}
//
//- (ZMUploadTask *)taskForSessionTask:(NSURLSessionTask *)sessionTask {
//    NSString *taskId = sessionTask.taskDescription;
//    return self.uploadTasks[taskId];
//}
//
//#pragma mark - Public Methods
//
//- (NSArray<ZMUploadTask *> *)allTasks {
//    return self.uploadTasks.allValues;
//}
//
//- (NSArray<ZMUploadTask *> *)tasksWithState:(ZMUploadState)state {
//    return [self.uploadTasks.allValues filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(ZMUploadTask *task, NSDictionary *bindings) {
//        return task.state == state;
//    }]];
//}
//
//- (void)clearCompletedTasks {
//    NSArray *completedTasks = [self tasksWithState:ZMUploadStateCompleted];
//    [completedTasks enumerateObjectsUsingBlock:^(ZMUploadTask *task, NSUInteger idx, BOOL *stop) {
//        [self.uploadTasks removeObjectForKey:task.taskId];
//        [self.taskQueue removeObject:task];
//    }];
//    [self saveTasksToDisk];
//}

@end 
