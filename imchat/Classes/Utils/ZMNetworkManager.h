#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Protocol for intercepting and modifying network requests before they are sent.
 */
@protocol ZMRequestInterceptor <NSObject>
@optional
- (void)interceptRequest:(NSMutableURLRequest *)request;
@end

/**
 * Protocol for intercepting and processing network responses after they are received.
 */
@protocol ZMResponseInterceptor <NSObject>
@optional
- (void)interceptResponse:(NSURLResponse *)response data:(NSData *)data;
@end

/**
 * Protocol for encrypting data before it is sent in a network request.
 */
@protocol ZMEncryptionInterceptor <NSObject>
@optional
- (NSData *)encryptData:(NSData *)data;
@end

/**
 * Protocol for decrypting data after it is received in a network response.
 */
@protocol ZMDecryptionInterceptor <NSObject>
@optional
- (NSData *)decryptData:(NSData *)data;
@end

/**
 * ZMNetworkManager is a singleton class that manages network operations.
 * It provides methods for making HTTP requests, uploading and downloading files,
 * and supports request/response interception and data encryption/decryption.
 */
@interface ZMNetworkManager : NSObject

/**
 * Returns the shared instance of ZMNetworkManager.
 *
 * @return The singleton instance of ZMNetworkManager.
 */
+ (instancetype)sharedManager;

/**
 * Sets the timeout interval for network requests.
 *
 * @param timeoutInterval The timeout interval in seconds.
 */
- (void)setTimeoutInterval:(NSTimeInterval)timeoutInterval;

/**
 * Sets global headers to be included in all network requests.
 *
 * @param headers A dictionary of header field names and values.
 */
- (void)setCustomGlobalHeaders:(NSDictionary<NSString *, NSString *> *)headers;

/**
 * Adds a request interceptor.
 *
 * @param interceptor An object conforming to the ZMRequestInterceptor protocol.
 */
- (void)addRequestInterceptor:(id<ZMRequestInterceptor>)interceptor;

/**
 * Adds a response interceptor.
 *
 * @param interceptor An object conforming to the ZMResponseInterceptor protocol.
 */
- (void)addResponseInterceptor:(id<ZMResponseInterceptor>)interceptor;

/**
 * Sets the encryption interceptor.
 *
 * @param interceptor An object conforming to the ZMEncryptionInterceptor protocol.
 */
- (void)setEncryptionInterceptor:(id<ZMEncryptionInterceptor>)interceptor;

/**
 * Sets the decryption interceptor.
 *
 * @param interceptor An object conforming to the ZMDecryptionInterceptor protocol.
 */
- (void)setDecryptionInterceptor:(id<ZMDecryptionInterceptor>)interceptor;

/**
 * Enables or disables SSL pinning and certificate validation.
 * This should be used carefully, especially in production environments.
 *
 * @param enabled If YES, SSL pinning and certificate validation will be disabled.
 *                If NO, the default security policy will be used.
 */
- (void)setAllowSelfSignedSSLCertificates:(BOOL)enabled;

/**
 * Checks if a proxy is set and stops network services if one is detected.
 *
 * @return YES if a proxy is detected, NO otherwise.
 */
- (BOOL)checkAndHandleProxySettings;

/**
 * Cancels a specific network task.
 *
 * @param task The NSURLSessionTask to be cancelled.
 */
- (void)cancelTask:(NSURLSessionTask *)task;

/**
 * Cancels all ongoing network tasks.
 */
- (void)cancelAllTasks;

/**
 * Suspends all ongoing upload and download tasks.
 */
- (void)suspendAllTasks;

/**
 * Resumes all suspended upload and download tasks.
 */
- (void)resumeAllTasks;

/**
 * Cancels all ongoing upload and download tasks.
 */
- (void)cancelAllUploadAndDownloadTasks;

/**
 * Performs a GET request and returns the associated task.
 *
 * @param urlString The URL string for the request.
 * @param params The parameters to be included in the request.
 * @param success A block to be executed when the request succeeds.
 * @param failure A block to be executed when the request fails.
 * @return The NSURLSessionDataTask associated with the request.
 */
- (NSURLSessionDataTask *)getRequestWithURL:(NSString *)urlString
                                     params:(NSDictionary *)params
                                    headers:(NSDictionary *)headers
                                    success:(void (^)(id responseObject))success
                                    failure:(void (^)(NSError *error))failure;

/**
 * Performs a POST request and returns the associated task.
 *
 * @param urlString The URL string for the request.
 * @param params The parameters to be included in the request body.
 * @param success A block to be executed when the request succeeds.
 * @param failure A block to be executed when the request fails.
 * @return The NSURLSessionDataTask associated with the request.
 */
- (NSURLSessionDataTask *)postRequestWithURL:(NSString *)urlString
                                      params:(NSDictionary *)params
                                     headers:(NSDictionary *)headers
                                     success:(void (^)(id responseObject))success
                                     failure:(void (^)(NSError *error))failure;


/**
 Uploads a file.
 
 @param urlString The URL string for the upload request.
 @param filePath The local path of the file to be uploaded.
 @param param Additional parameters to be included in the request.
 @param progress A block to be executed to track the upload progress.
 @param success A block to be executed when the upload succeeds.
 @param failure A block to be executed when the upload fails.
 @return The NSURLSessionDataTask associated with the request.
 */
- (NSURLSessionDataTask *)uploadFileWithURL:(NSString *)urlString
                                   filePath:(NSString *)filePath
                                       data:(NSData *)data
                                      param:(NSDictionary *)param
                                   signType:(NSInteger)signType
                                   progress:(void (^)(NSProgress *uploadProgress))progress
                                    success:(void (^)(id responseObject))success
                                    failure:(void (^)(NSError *error))failure;

/**
 * Adds a file upload task to the queue.
 *
 * @param urlString The URL string for the upload request.
 * @param filePath The local path of the file to be uploaded.
 * @param param Additional parameters to be included in the request.
 * @param progress A block to be executed to track the upload progress.
 * @param success A block to be executed when the upload succeeds.
 * @param failure A block to be executed when the upload fails.
 * @return The NSURLSessionUploadTask associated with the request.
 */
- (NSURLSessionUploadTask *)addUploadTaskWithURL:(NSString *)urlString
                                        filePath:(NSString *)filePath
                                           param:(NSDictionary *)param
                                        progress:(void (^)(NSProgress *uploadProgress))progress
                                         success:(void (^)(id responseObject))success
                                         failure:(void (^)(NSError *error))failure;

/**
 * Adds a file download task to the queue.
 *
 * @param urlString The URL string of the file to be downloaded.
 * @param filePath The local path where the downloaded file should be saved.
 * @param progress A block to be executed to track the download progress.
 * @param success A block to be executed when the download succeeds.
 * @param failure A block to be executed when the download fails.
 * @return The NSURLSessionDownloadTask associated with the request.
 */
- (NSURLSessionDownloadTask *)addDownloadTaskWithURL:(NSString *)urlString
                                            filePath:(NSString *)filePath
                                            progress:(void (^)(NSProgress *downloadProgress))progress
                                             success:(void (^)(NSURL *fileURL))success
                                             failure:(void (^)(NSError *error))failure;



@end

NS_ASSUME_NONNULL_END
