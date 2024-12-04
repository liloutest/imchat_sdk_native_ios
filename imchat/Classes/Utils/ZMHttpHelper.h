//
//  HttpHelper.h
//  imchat
//
//  Created by Lilou on 2024/10/15.
//

#import <Foundation/Foundation.h>
#import "ZMCreateSessionReqModel.h"
#import "ZMCreateSessionRepModel.h"
#import "ZMHistoryRepModel.h"
#import "ZMChatSendMsgReqModel.h"
#import "ZMChatSendMsgRepModel.h"
#import "ZMUploadQueueTask.h"
@class ZMMessage;

NS_ASSUME_NONNULL_BEGIN

/**
 * HttpHelper is a utility class that provides static methods for making API calls.
 * It uses ZMNetworkManager to perform the actual network requests.
 */
@interface ZMHttpHelper : NSObject


+ (void)getBestNodes:(ActionBlock)httpBlock wsBlock:(ActionBlock)wsBlock ossBlock:(ActionBlock)ossBlock;

+ (NSString *)getCurrentOssUrl;

/**
 * Configures the base URL for all API calls.
 *
 * @param baseURL The base URL string for the API.
 */
+ (void)configureWithBaseURL:(NSString *)baseURL;

+ (void)configureWithBaseOssUrl:(NSString *)baseOssUrl;


+ (void)createSessionWith:(ZMCreateSessionReqModel *)reqModel
                  success:(ZMReqSuccessBlock)success
                  failure:(ZMReqFailBlock)failure;


+ (void)getHistoryWith:(NSString *)sessionId
                endSeq:(NSInteger)endSeq
              startSeq:(NSInteger)startSeq
               success:(ZMReqSuccessBlock)success
               failure:(ZMReqFailBlock)failure;



+ (void)getSessionListWith:(NSInteger)sessionType
                pageNumber:(NSInteger)pageNumber
                showNumber:(NSInteger)showNumber
                   success:(ZMReqSuccessBlock)success
                   failure:(ZMReqFailBlock)failure;


+ (void)sendMessage:(ZMMessage *)msg
            headers:(NSDictionary *_Nullable)headers
                  success:(ZMReqSuccessBlock)success
                  failure:(ZMReqFailBlock)failure;


+ (void)joinSession:(NSDictionary *)params
            headers:(NSDictionary *)headers
                  success:(ZMReqSuccessBlock)success
                  failure:(ZMReqFailBlock)failure;

+ (void)initMultiUpload:(CGFloat)size name:(NSString *)name 
                headers:(NSDictionary *_Nullable)headers
                success:(ZMReqSuccessBlock)success
                failure:(ZMReqFailBlock)failure;


+ (void)completeMultiUpload:(ZMUploadTask *)task
                headers:(NSDictionary *_Nullable)headers
                success:(ZMReqSuccessBlock)success
                failure:(ZMReqFailBlock)failure;

+ (void)markMsgAsRead:(NSInteger)seq
            sessionID:(NSString *)sessionID
              headers:(NSDictionary *_Nullable)headers
              success:(ZMReqSuccessBlock)success
              failure:(ZMReqFailBlock)failure;


+ (void)getTimeoutConfigWithSuccess:(ZMReqSuccessBlock)success
                            failure:(ZMReqFailBlock)failure;



+ (void)getFaq:(ZMMessageGetFaqType)faqType
         faqId:(NSString *)faqId
       headers:(NSDictionary *_Nullable)headers
       success:(ZMReqSuccessBlock)success
       failure:(ZMReqFailBlock)failure;

+ (void)serviceSupportSuccess:(ZMReqSuccessBlock)success
                      failure:(ZMReqFailBlock)failure;

/**
 * Performs a login request.
 *
 * @param username The user's username.
 * @param password The user's password.
 * @param success A block to be executed when the login is successful. It receives the response dictionary.
 * @param failure A block to be executed when the login fails. It receives an NSError object.
 */
+ (void)loginWithUsername:(NSString *)username 
                 password:(NSString *)password 
                  success:(void (^)(NSDictionary *response))success 
                  failure:(void (^)(NSError *error))failure;

/**
 * Retrieves user information.
 *
 * @param userId The ID of the user whose information is being requested.
 * @param success A block to be executed when the user info is successfully retrieved. It receives a dictionary of user information.
 * @param failure A block to be executed when the request fails. It receives an NSError object.
 */
+ (void)getUserInfoWithUserId:(NSString *)userId 
                      success:(void (^)(NSDictionary *userInfo))success 
                      failure:(void (^)(NSError *error))failure;

/**
 * Sends a message to another user.
 *
 * @param message The content of the message to be sent.
 * @param receiverId The ID of the user who will receive the message.
 * @param success A block to be executed when the message is successfully sent. It receives a response dictionary.
 * @param failure A block to be executed when sending the message fails. It receives an NSError object.
 */
+ (void)sendMessage:(NSString *)message 
              toUser:(NSString *)receiverId 
             success:(void (^)(NSDictionary *response))success 
             failure:(void (^)(NSError *error))failure;

/**
 * Retrieves chat history.
 *
 * @param userId The ID of the user whose chat history is being requested.
 * @param page The page number of the chat history to retrieve.
 * @param pageSize The number of messages to retrieve per page.
 * @param success A block to be executed when the chat history is successfully retrieved. It receives an array of messages.
 * @param failure A block to be executed when the request fails. It receives an NSError object.
 */
+ (void)getChatHistoryWithUserId:(NSString *)userId 
                            page:(NSInteger)page 
                        pageSize:(NSInteger)pageSize 
                         success:(void (^)(NSArray *messages))success 
                         failure:(void (^)(NSError *error))failure;

/**
 * Uploads a file to the server.
 *
 * @param fileData The data of the file to be uploaded.
 * @param fileName The name of the file.
 * @param mimeType The MIME type of the file.
 * @param success A block to be executed when the file is successfully uploaded. It receives a response dictionary.
 * @param failure A block to be executed when the upload fails. It receives an NSError object.
 */
+ (void)uploadFile:(NSData *)fileData 
          fileName:(NSString *)fileName 
          mimeType:(NSString *)mimeType 
           success:(void (^)(NSDictionary *response))success 
           failure:(void (^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
