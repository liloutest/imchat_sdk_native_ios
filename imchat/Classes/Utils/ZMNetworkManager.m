#import "ZMNetworkManager.h"
#import <AFNetworking/AFNetworking.h>
#import <SystemConfiguration/SystemConfiguration.h>

@interface ZMNetworkManager ()
/// HTTP session manager from AFNetworking
@property (nonatomic, strong) AFHTTPSessionManager *manager;

/// Array of request interceptors
@property (nonatomic, strong) NSMutableArray<id<ZMRequestInterceptor>> *requestInterceptors;

/// Array of response interceptors
@property (nonatomic, strong) NSMutableArray<id<ZMResponseInterceptor>> *responseInterceptors;

/// Dictionary of global HTTP headers
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *globalHeaders;

/// Encryption interceptor
@property (nonatomic, strong) id<ZMEncryptionInterceptor> encryptionInterceptor;

/// Decryption interceptor
@property (nonatomic, strong) id<ZMDecryptionInterceptor> decryptionInterceptor;

/// Flag to allow self-signed SSL certificates
@property (nonatomic, assign) BOOL allowSelfSignedSSLCertificates;

/// Array of tasks
@property (nonatomic, strong) NSMutableArray<NSURLSessionTask *> *tasks;

/// Operation queue for upload tasks
@property (nonatomic, strong) NSOperationQueue *uploadQueue;

/// Operation queue for download tasks
@property (nonatomic, strong) NSOperationQueue *downloadQueue;
@end

@implementation ZMNetworkManager

#pragma mark - Lifecycle

/**
 Returns the shared instance of ZMNetworkManager.
 
 @return The singleton instance of ZMNetworkManager.
 */
+ (instancetype)sharedManager {
    static ZMNetworkManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

/**
 Initializes the ZMNetworkManager instance.
 
 This method sets up the AFHTTPSessionManager, initializes arrays for interceptors,
 and configures the initial security policy.
 
 @return An initialized ZMNetworkManager instance.
 */
- (instancetype)init {
    self = [super init];
    if (self) {
        _manager = [AFHTTPSessionManager manager];
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
        _manager.responseSerializer = [AFJSONResponseSerializer serializer];
        _requestInterceptors = [NSMutableArray array];
        _responseInterceptors = [NSMutableArray array];
        _globalHeaders = [NSMutableDictionary dictionary];
        _encryptionInterceptor = nil;
        _decryptionInterceptor = nil;
        _allowSelfSignedSSLCertificates = YES;
        _tasks = [NSMutableArray array];
        
        [self setupSecurityPolicy];
        [self setupInterceptors];
        
        _uploadQueue = [[NSOperationQueue alloc] init];
        _uploadQueue.maxConcurrentOperationCount = 3; // 限制并发上传数量
        _downloadQueue = [[NSOperationQueue alloc] init];
        _downloadQueue.maxConcurrentOperationCount = 3; // 限制并发下载数量
        
        [self setCustomGlobalHeaders:@{@"lbeSign": @"b184b8e64c5b0004c58b5a3c9af6f3868d63018737e68e2a1ccc61580afbc8f112119431511175252d169f0c64d9995e5de2339fdae5cbddda93b65ce305217700",@"Content-Type":@"application/json",@"lbeIdentity":[ZMMessageManager sharedInstance].identityID ?: @""}.mutableCopy];
    }
    return self;
}

#pragma mark - Public Methods

/**
 Sets the timeout interval for network requests.
 
 @param timeoutInterval The timeout interval in seconds.
 */
- (void)setTimeoutInterval:(NSTimeInterval)timeoutInterval {
    self.manager.requestSerializer.timeoutInterval = timeoutInterval;
}

/**
 Sets global headers to be included in all network requests.
 
 @param headers A dictionary of header field names and values.
 */
- (void)setCustomGlobalHeaders:(NSDictionary<NSString *, NSString *> *)headers {
    [self.globalHeaders removeAllObjects];
    [self.globalHeaders addEntriesFromDictionary:headers];
    
    [self.globalHeaders enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        [self.manager.requestSerializer setValue:obj forHTTPHeaderField:key];
    }];
}

/**
 Sets the encryption interceptor.
 
 @param interceptor An object conforming to the ZMEncryptionInterceptor protocol.
 */
- (void)setEncryptionInterceptor:(id<ZMEncryptionInterceptor>)interceptor {
    _encryptionInterceptor = interceptor;
}

/**
 Sets the decryption interceptor.
 
 @param interceptor An object conforming to the ZMDecryptionInterceptor protocol.
 */
- (void)setDecryptionInterceptor:(id<ZMDecryptionInterceptor>)interceptor {
    _decryptionInterceptor = interceptor;
}

/**
 Adds a request interceptor.
 
 @param interceptor An object conforming to the ZMRequestInterceptor protocol.
 */
- (void)addRequestInterceptor:(id<ZMRequestInterceptor>)interceptor {
    [self.requestInterceptors addObject:interceptor];
}

/**
 Adds a response interceptor.
 
 @param interceptor An object conforming to the ZMResponseInterceptor protocol.
 */
- (void)addResponseInterceptor:(id<ZMResponseInterceptor>)interceptor {
    [self.responseInterceptors addObject:interceptor];
}


#pragma mark - Private Methods


- (void)supportProxy:(NSString *)urlString{
    NSDictionary *proxySettings = CFBridgingRelease(CFNetworkCopySystemProxySettings());
    NSArray *proxies = CFBridgingRelease(CFNetworkCopyProxiesForURL((__bridge CFURLRef)[NSURL URLWithString:urlString], (__bridge CFDictionaryRef)proxySettings));
    NSDictionary *settings = [proxies firstObject];
    
    NSString *proxyHost = settings[(NSString *)kCFProxyHostNameKey];
    NSNumber *proxyPort = settings[(NSString *)kCFProxyPortNumberKey];
    
    if (proxyHost && proxyPort) {
        [self.manager.requestSerializer setValue:[NSString stringWithFormat:@"%@:%@", proxyHost, proxyPort] forHTTPHeaderField:@"Proxy-Connection"];
    }
    else {
        [self.manager.requestSerializer setValue:nil forHTTPHeaderField:@"Proxy-Connection"];
    }
}

/**
 Sets up the request and response interceptors.
 
 This method configures the AFHTTPSessionManager to use custom serializers
 that apply the encryption and decryption interceptors.
 */
- (void)setupInterceptors {
    __weak typeof(self) weakSelf = self;
    
    [self.manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    [self.manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    
    [self.manager.requestSerializer setQueryStringSerializationWithBlock:^NSString * _Nonnull(NSURLRequest * _Nonnull request, id  _Nonnull parameters, NSError * _Nullable __autoreleasing * _Nullable error) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:error];
        if (weakSelf.encryptionInterceptor) {
            jsonData = [weakSelf.encryptionInterceptor encryptData:jsonData];
        }
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }];
    
    [self.manager setDataTaskDidReceiveDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSData * _Nonnull data) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)dataTask.response;
        NSData *decryptedData = data;
        if (weakSelf.decryptionInterceptor) {
            decryptedData = [weakSelf.decryptionInterceptor decryptData:data];
        }
        for (id<ZMResponseInterceptor> interceptor in weakSelf.responseInterceptors) {
            [interceptor interceptResponse:response data:decryptedData];
        }
    }];
}

/**
 Handles the successful response, including decryption and JSON parsing.
 
 @param responseObject The raw response object.
 @param success A block to be executed with the processed response.
 */
- (void)handleSuccessResponse:(id)responseObject success:(void (^)(id responseObject))success fail:(void (^)(NSError *error))failure {
    if (self.decryptionInterceptor) {
        responseObject = [self.decryptionInterceptor decryptData:responseObject];
    }
    id jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
    if (success) {
        ZMResponseModel *respModel = [ZMResponseModel modelWithJSON:jsonObject];
        if(respModel.errCode != 0 || respModel.code != 0){
            NSError *customError = [NSError errorWithDomain:respModel.errDlt ?: (respModel.msg ?: @"") code:respModel.errCode ?: respModel.code userInfo:nil];
            if(failure){
                failure(customError);
                [SVProgressHUD showErrorWithStatus:customError.domain];
            }
            return;
        }
        success(jsonObject);
    }
}

/**
 Enables or disables SSL pinning and certificate validation.
 
 @param enabled If YES, SSL pinning and certificate validation will be disabled.
                If NO, the default security policy will be used.
 */
- (void)setAllowSelfSignedSSLCertificates:(BOOL)enabled {
    _allowSelfSignedSSLCertificates = enabled;
    [self setupSecurityPolicy];
}

/**
 Sets up the security policy based on the allowSelfSignedSSLCertificates property.
 */
- (void)setupSecurityPolicy {
    AFSecurityPolicy *securityPolicy;
    
    if (self.allowSelfSignedSSLCertificates) {
        securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        securityPolicy.allowInvalidCertificates = YES;
        securityPolicy.validatesDomainName = NO;
        NSLog(@"Warning: Certificate validation is disabled. This may lead to security risks, use with caution.");
    } else {
        securityPolicy = [AFSecurityPolicy defaultPolicy];
        securityPolicy.allowInvalidCertificates = NO;
        securityPolicy.validatesDomainName = YES;
    }

    self.manager.securityPolicy = securityPolicy;
}

/**
 Checks if a proxy is set and stops network services if one is detected.
 
 @return YES if a proxy is detected, NO otherwise.
 */
- (BOOL)checkAndHandleProxySettings {
    NSDictionary *proxySettings = (__bridge NSDictionary *)CFNetworkCopySystemProxySettings();
    NSArray *proxies = (__bridge NSArray *)CFNetworkCopyProxiesForURL((__bridge CFURLRef)[NSURL URLWithString:@"http://www.example.com"], (__bridge CFDictionaryRef)proxySettings);
    NSDictionary *settings = [proxies firstObject];
    
    NSString *proxyType = settings[(NSString *)kCFProxyTypeKey];
    
    if ([proxyType isEqualToString:(NSString *)kCFProxyTypeHTTP] ||
        [proxyType isEqualToString:(NSString *)kCFProxyTypeHTTPS] ||
        [proxyType isEqualToString:(NSString *)kCFProxyTypeSOCKS]) {
        
        [self stopNetworkServices];
        
        NSLog(@"Warning: Proxy settings detected. Network services have been stopped for security reasons.");
        return YES;
    }
    
    return NO;
}

/**
 Stops all network services and resets the AFHTTPSessionManager.
 
 This method is called when a proxy is detected to prevent potential security risks.
 */
- (void)stopNetworkServices {
    [self.manager.operationQueue cancelAllOperations];
    [self.manager invalidateSessionCancelingTasks:YES resetSession:YES];
    self.manager = [AFHTTPSessionManager manager];
    // Additional cleanup or reset logic can be added here
}

#pragma mark - Task Management

- (void)cancelTask:(NSURLSessionTask *)task {
    [task cancel];
    [self.tasks removeObject:task];
}

- (void)cancelAllTasks {
    [self.tasks enumerateObjectsUsingBlock:^(NSURLSessionTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
        [task cancel];
    }];
    [self.tasks removeAllObjects];
}

- (void)suspendAllTasks {
    [self.uploadQueue setSuspended:YES];
    [self.downloadQueue setSuspended:YES];
}

- (void)resumeAllTasks {
    [self.uploadQueue setSuspended:NO];
    [self.downloadQueue setSuspended:NO];
}

- (void)cancelAllUploadAndDownloadTasks {
    [self.uploadQueue cancelAllOperations];
    [self.downloadQueue cancelAllOperations];
}

#pragma mark - Network Requests

- (NSURLSessionDataTask *)getRequestWithURL:(NSString *)urlString
                                     params:(NSDictionary *)params
                                    headers:(NSDictionary *)headers
                                    success:(void (^)(id responseObject))success
                                    failure:(void (^)(NSError *error))failure {
    
    @try {
        NSMutableURLRequest *request = [self.manager.requestSerializer requestWithMethod:@"GET" URLString:[[NSURL URLWithString:urlString relativeToURL:self.manager.baseURL] absoluteString] parameters:params error:nil];
        if(headers){
            [headers enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                [request setValue:obj  forHTTPHeaderField:key];
            }];
        }
        [self.requestInterceptors enumerateObjectsUsingBlock:^(id<ZMRequestInterceptor>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj interceptRequest:request];
        }];
        
        [self supportProxy:urlString];
        
        __block NSURLSessionDataTask *task = [self.manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            [self.tasks removeObject:task];
            [self.responseInterceptors enumerateObjectsUsingBlock:^(id<ZMResponseInterceptor>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj interceptResponse:response data:responseObject];
            }];
            if (error) {
                if (failure) {
                    failure(error);
                }
            } else {
                [self handleSuccessResponse:responseObject success:success fail:failure];
            }
        }];
        
        [self.tasks addObject:task];
        [task resume];
        return task;
    } @catch (NSException *exception) {
        [SVProgressHUD showErrorWithStatus:exception.description];
        return nil;
    } @finally {
        
    }

    return nil;
}

- (NSURLSessionDataTask *)postRequestWithURL:(NSString *)urlString
                                      params:(NSDictionary *)params
                                     headers:(NSDictionary *)headers
                                     success:(void (^)(id responseObject))success
                                     failure:(void (^)(NSError *error))failure {
    @try {
        NSMutableURLRequest *request = [self.manager.requestSerializer requestWithMethod:@"POST" URLString:[[NSURL URLWithString:urlString relativeToURL:self.manager.baseURL] absoluteString] parameters:params error:nil];
        NSLog(@"request = %@\nheader = %@\nparams = %@",request,self.globalHeaders,params);
        if(headers){
            [headers enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                [request setValue:obj  forHTTPHeaderField:key];
            }];
            
            NSLog(@"%@",request.allHTTPHeaderFields);
        }
        [self.requestInterceptors enumerateObjectsUsingBlock:^(id<ZMRequestInterceptor>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj interceptRequest:request];
        }];
        
        [self supportProxy:urlString];
        
        __block NSURLSessionDataTask *task = [self.manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            [self.tasks removeObject:task];
            NSLog(@"response = %@",response);
            [self.responseInterceptors enumerateObjectsUsingBlock:^(id<ZMResponseInterceptor>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj interceptResponse:response data:responseObject];
            }];
            [SVProgressHUD dismiss];
            if (error) {
                if (failure) {
                    failure(error);
                }
            } else {
                [self handleSuccessResponse:responseObject success:success fail:failure];
            }
        }];
        
        [self.tasks addObject:task];
        [task resume];
        return task;
    } @catch (NSException *exception) {
        [SVProgressHUD showErrorWithStatus:exception.description];
        return nil;
    } @finally {
        
    }
    return nil;
}

- (NSURLSessionDataTask *)uploadFileWithURL:(NSString *)urlString
                                   filePath:(NSString *)filePath
                                       data:(NSData *)data
                                      param:(NSDictionary *)param
                                   signType:(NSInteger)signType
                                   progress:(void (^)(NSProgress *uploadProgress))progress
                                    success:(void (^)(id responseObject))success
                                    failure:(void (^)(NSError *error))failure {
    
    @try {
        
        if(!param){
            param = @{}.mutableCopy;
        }
        [param setValue:@(signType) forKey:@"sign_type"];
    //    [self.globalHeaders setValue:@"multipart/form-data" forKey:@"Content-Type"];
    //    [param setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    //    [self.globalHeaders setValue:[NSString stringWithFormat:@"%@",[ZMMessageManager sharedInstance].token] forKey:@"token"];
    //    [self.globalHeaders setValue:@"multipart/form-data" forKey:@"Content-Type"];
        NSURLSessionDataTask *dataTask = [self.manager POST:urlString parameters:param headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            
            if(filePath){
                NSURL *fileURL = [NSURL fileURLWithPath:filePath];
                [formData appendPartWithFileURL:fileURL name:@"file" error:nil];
            }
            else {
                if(data) {
                    [formData appendPartWithFormData:data name:@"file"];
                }
            }
            
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            if (progress) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    progress(uploadProgress);
                });
            }
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self handleSuccessResponse:responseObject success:success fail:failure];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (failure) {
                failure(error);
            }
        }];
        
        [self.uploadQueue addOperationWithBlock:^{
            [dataTask resume];
        }];
        return dataTask;
    } @catch (NSException *exception) {
        [SVProgressHUD showErrorWithStatus:exception.description];
        return nil;
    } @finally {
        
    }
    
    return nil;
}

- (NSURLSessionUploadTask *)addUploadTaskWithURL:(NSString *)urlString
                                        filePath:(NSString *)filePath
                                           param:(NSDictionary *)param
                                        progress:(void (^)(NSProgress *uploadProgress))progress
                                         success:(void (^)(id responseObject))success
                                         failure:(void (^)(NSError *error))failure {
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    
    NSURLSessionUploadTask *uploadTask = [self.manager uploadTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]
                                                                    fromFile:fileURL
                                                                    progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                progress(uploadProgress);
            });
        }
    }
                                                           completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            if (failure) {
                failure(error);
            }
        } else {
            if (success) {
                success(responseObject);
            }
        }
    }];
    
    [self.uploadQueue addOperationWithBlock:^{
        [uploadTask resume];
    }];
    
    return uploadTask;
}

- (NSURLSessionDownloadTask *)addDownloadTaskWithURL:(NSString *)urlString
                                            filePath:(NSString *)filePath
                                            progress:(void (^)(NSProgress *downloadProgress))progress
                                             success:(void (^)(NSURL *fileURL))success
                                             failure:(void (^)(NSError *error))failure {
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDownloadTask *downloadTask = [self.manager downloadTaskWithRequest:request
                                                                          progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                progress(downloadProgress);
            });
        }
    }
                                                                       destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    }
                                                                 completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error) {
            if (failure) {
                failure(error);
            }
        } else {
            if (success) {
                success(filePath);
            }
        }
    }];
    
    [self.downloadQueue addOperationWithBlock:^{
        [downloadTask resume];
    }];
    
    return downloadTask;
}



@end
