//
//  HttpHelper.m
//  imchat
//
//  Created by Lilou on 2024/10/15.
//

#import "ZMHttpHelper.h"
#import "ZMNetworkManager.h"
#import "ZMNodeManager.h"
static NSString *baseURL = @"";//@"http://42nz10y3hhah.dreaminglife.cn:20005";
static NSString *ossUrl = @"";//@"http://10.40.92.201:20003";
@implementation ZMHttpHelper

+ (void)getBestNodes:(ActionBlock)httpBlock wsBlock:(ActionBlock)wsBlock ossBlock:(ActionBlock)ossBlock;
{
    
    [[ZMNodeManager sharedManager] getBestNodes:httpBlock wsBlock:wsBlock ossBlock:ossBlock];
    
}



+ (void)configureWithBaseURL:(NSString *)url{
    baseURL = url;
    
}

+ (void)configureWithBaseOssUrl:(NSString *)baseOssUrl{
    ossUrl = baseOssUrl;
}

+ (NSString *)getCurrentOssUrl {
    return ossUrl;
}

+ (void)getHistoryWith:(NSString *)sessionId
                endSeq:(NSInteger)endSeq
              startSeq:(NSInteger)startSeq
               success:(void (^)(NSDictionary *response))success
               failure:(void (^)(NSError *error))failure {
    
    @try {
        NSDictionary *params = @{
            @"seqCondition": @{@"endSeq":@(endSeq),@"startSeq":@(startSeq)},
            @"sessionId": sessionId
        };
        
        NSString *url = [NSString stringWithFormat:@"%@/miner-api/trans/history", baseURL];
        
        [[ZMNetworkManager sharedManager] postRequestWithURL:url
                                                      params:params
                                                     headers:@{@"lbeToken": [ZMMessageManager sharedInstance].token}
                                                     success:^(id responseObject) {
            if (success) {
                success(responseObject[@"data"]);
            }
        } failure:^(NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
    } @catch (NSException *exception) {
        [SVProgressHUD showErrorWithStatus:exception.description];
    } @finally {
        
    }
    
    
}

+ (void)getSessionListWith:(NSInteger)sessionType
                pageNumber:(NSInteger)pageNumber
                showNumber:(NSInteger)showNumber
                   success:(ZMReqSuccessBlock)success
                   failure:(ZMReqFailBlock)failure {
    
    @try {
        NSDictionary *params = @{
            @"pagination": @{@"pageNumber":@(pageNumber),@"showNumber":@(showNumber)},
            @"sessionType": @(sessionType) // 0-当前会话 1-历史会话 2-all
        };
        
        NSString *url = [NSString stringWithFormat:@"%@/miner-api/trans/session-list", baseURL];
        
        [[ZMNetworkManager sharedManager] postRequestWithURL:url
                                                      params:params
                                                     headers:@{@"lbeToken": [ZMMessageManager sharedInstance].token}
                                                     success:^(id responseObject) {
            if (success) {
                success(responseObject[@"data"]);
            }
        } failure:^(NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
    } @catch (NSException *exception) {
        [SVProgressHUD showErrorWithStatus:exception.description];
    } @finally {
        
    }
    
    
}

+ (void)createSessionWith:(ZMCreateSessionReqModel *)reqModel
                  success:(ZMReqSuccessBlock)success
                  failure:(ZMReqFailBlock)failure {
    
    @try {
        NSString *url = [NSString stringWithFormat:@"%@/miner-api/trans/session", baseURL];
        
        [[ZMNetworkManager sharedManager] postRequestWithURL:url
                                                      params:[reqModel modelToJSONObject]
                                                     headers:nil
                                                     success:^(id responseObject) {
            if (success) {
                success(responseObject[@"data"]);
            }
        } failure:^(NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
    } @catch (NSException *exception) {
        [SVProgressHUD showErrorWithStatus:exception.description];
    } @finally {
        
    }
    
    
}

+ (void)sendMessage:(ZMMessage *)msg
            headers:( NSDictionary *_Nullable)headers
                  success:(ZMReqSuccessBlock)success
                  failure:(ZMReqFailBlock)failure {
    
    @try {
        NSInteger newSeq = [[ZMMessageManager sharedInstance] lastSeq];
        if(newSeq == NSNotFound){
            newSeq = 0;
        }
        ZMChatSendMsgReqModel *msgModel = [ZMChatSendMsgReqModel new];
        msgModel.msgBody = msg.msgBody.msgBody;
        msgModel.msgSeq = newSeq + 1;
        msgModel.msgType = msg.msgBody.msgType;
        msgModel.source = 100;
        msgModel.clientMsgID = msg.msgBody.clientMsgId;
        msgModel.sendTime = [NSString stringWithFormat:@"%ld",msg.sendTimeStamp];
        NSString *url = [NSString stringWithFormat:@"%@/miner-api/trans/msg-send", baseURL];
        NSMutableDictionary *dict = @{@"lbeSession":[ZMMessageManager sharedInstance].sessionId,@"lbeToken":[ZMMessageManager sharedInstance].token}.mutableCopy;
        if(headers){
            [dict addEntriesFromDictionary:headers];
        }
        [[ZMNetworkManager sharedManager] postRequestWithURL:url
                                                      params:[msgModel modelToJSONObject]
                                                     headers:dict
                                                     success:^(id responseObject) {
            if (success) {
                success(responseObject[@"data"]);
            }
        } failure:^(NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
    } @catch (NSException *exception) {
        [SVProgressHUD showErrorWithStatus:exception.description];
    } @finally {
        
    }
    
    
}

+ (void)joinSession:(NSDictionary *)params
            headers:(NSDictionary *)headers
                  success:(ZMReqSuccessBlock)success
            failure:(ZMReqFailBlock)failure {
    NSString *url = [NSString stringWithFormat:@"%@/miner-api/trans/session-join", baseURL];
    
    [[ZMNetworkManager sharedManager] postRequestWithURL:url
                                                  params:params
                                                 headers:headers
                                                 success:^(id responseObject) {
        if (success) {
            success(responseObject[@"data"]);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}


+ (void)initMultiUpload:(CGFloat)size 
                   name:(NSString *)name
                headers:(NSDictionary *)headers
                success:(ZMReqSuccessBlock)success
                failure:(ZMReqFailBlock)failure {
    
    @try {
        //http://10.40.91.10:20003
            NSString *url = [NSString stringWithFormat:@"%@/api/multi/initiate-multipart_upload",ossUrl];
        //    NSMutableDictionary *dict = @{@"lbe_session":[ZMMessageManager sharedInstance].sessionId,@"lbeToken":[ZMMessageManager sharedInstance].token}.mutableCopy;
        //    if(headers){
        //        [dict addEntriesFromDictionary:headers];
        //    }
            [[ZMNetworkManager sharedManager] postRequestWithURL:url
                                                          params:@{@"size": @(size),@"name": name, @"contentType":@"application/json"}
                                                         headers:headers
                                                         success:^(id responseObject) {
                if (success) {
                    success(responseObject[@"data"]);
                }
            } failure:^(NSError *error) {
                if (failure) {
                    failure(error);
                }
            }];
    } @catch (NSException *exception) {
        [SVProgressHUD showErrorWithStatus:exception.description];
    } @finally {
        
    }
    

    
}



+ (void)completeMultiUpload:(ZMUploadTask *)task
                headers:(NSDictionary *_Nullable)headers
                success:(ZMReqSuccessBlock)success
                    failure:(ZMReqFailBlock)failure {
    
    @try {
        NSString *url = [NSString stringWithFormat:@"%@/api/multi/complete-multipart-upload",ossUrl];
    //    NSMutableDictionary *dict = @{@"lbe_session":[ZMMessageManager sharedInstance].sessionId,@"lbeToken":[ZMMessageManager sharedInstance].token}.mutableCopy;
    //    if(headers){
    //        [dict addEntriesFromDictionary:headers];
    //    }
        
        NSMutableArray *parts = @[].mutableCopy;
        for(int i = 0; i < task.uploadInfo.node.count; i++) {
            ZMInitUploadRespPartModel *part = task.uploadInfo.node[i];
    //        NSString *newETag = [part.eTag stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            [parts addObject:@{@"partNumber": @(i+1),@"etag": part.eTag}];
        }
        
        [[ZMNetworkManager sharedManager] postRequestWithURL:url
                                                      params:@{@"uploadId": task.uploadInfo.uploadId,@"name": [task.filePath lastPathComponent], @"part":parts}
                                                     headers:headers
                                                     success:^(id responseObject) {
            if (success) {
                success(responseObject[@"data"]);
            }
        } failure:^(NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
    } @catch (NSException *exception) {
        [SVProgressHUD showErrorWithStatus:exception.description];
    } @finally {
        
    }
    

}



+ (void)markMsgAsRead:(NSInteger)seq
            sessionID:(NSString *)sessionID
              headers:(NSDictionary *_Nullable)headers
              success:(ZMReqSuccessBlock)success
              failure:(ZMReqFailBlock)failure {
    
    @try {
        NSDictionary *params = @{
            @"seq": @(seq),
            @"sessionID": sessionID
        };
        
        NSString *url = [NSString stringWithFormat:@"%@/miner-api/trans/mark-msg-as-read", baseURL];
        
        [[ZMNetworkManager sharedManager] postRequestWithURL:url
                                                      params:params
                                                     headers:@{@"lbeToken": [ZMMessageManager sharedInstance].token}
                                                     success:^(id responseObject) {
            if (success) {
                success(responseObject[@"data"]);
            }
        } failure:^(NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
    } @catch (NSException *exception) {
        [SVProgressHUD showErrorWithStatus:exception.description];
    } @finally {
        
    }
    
    
}



+ (void)getTimeoutConfigWithSuccess:(ZMReqSuccessBlock)success
                            failure:(ZMReqFailBlock)failure {
    @try {
        NSDictionary *params = @{
            @"userType": @(2) // 1-B端 2-C端
        };
        
        NSString *url = [NSString stringWithFormat:@"%@/miner-api/trans/timeout-config", baseURL];
        
        [[ZMNetworkManager sharedManager] postRequestWithURL:url
                                                      params:params
                                                     headers:@{@"lbeToken": [ZMMessageManager sharedInstance].token}
                                                     success:^(id responseObject) {
            if (success) {
                success(responseObject[@"data"]);
            }
        } failure:^(NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
    } @catch (NSException *exception) {
        [SVProgressHUD showErrorWithStatus:exception.description];
    } @finally {
        
    }
}




+ (void)getFaq:(ZMMessageGetFaqType)faqType
         faqId:(NSString *)faqId
       headers:(NSDictionary *_Nullable)headers
       success:(ZMReqSuccessBlock)success
       failure:(ZMReqFailBlock)failure {
    @try {
        NSDictionary *params = @{
            @"faqType": @(faqType), // 1-获取知识点 2-获取答案
            @"id": kZMSafeStr(faqId)
        };
        
        NSString *url = [NSString stringWithFormat:@"%@/miner-api/trans/faq", baseURL];
        
        [[ZMNetworkManager sharedManager] postRequestWithURL:url
                                                      params:params
                                                     headers:@{@"lbeToken": [ZMMessageManager sharedInstance].token,@"lbeSession":[ZMMessageManager sharedInstance].sessionId}
                                                     success:^(id responseObject) {
            if (success) {
                success(responseObject[@"data"]);
            }
        } failure:^(NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
    } @catch (NSException *exception) {
        [SVProgressHUD showErrorWithStatus:exception.description];
    } @finally {
        
    }
}



+ (void)serviceSupportSuccess:(ZMReqSuccessBlock)success
                      failure:(ZMReqFailBlock)failure {
    @try {
        
        NSString *url = [NSString stringWithFormat:@"%@/miner-api/trans/service-support", baseURL];
        
        [[ZMNetworkManager sharedManager] postRequestWithURL:url
                                                      params:@{}
                                                     headers:@{@"lbeToken": [ZMMessageManager sharedInstance].token,@"lbeSession":[ZMMessageManager sharedInstance].sessionId}
                                                     success:^(id responseObject) {
            if (success) {
                success(responseObject[@"data"]);
            }
        } failure:^(NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
    } @catch (NSException *exception) {
        [SVProgressHUD showErrorWithStatus:exception.description];
    } @finally {
        
    }
}



+ (void)loginWithUsername:(NSString *)username 
                 password:(NSString *)password 
                  success:(void (^)(NSDictionary *response))success 
                  failure:(void (^)(NSError *error))failure {
    NSDictionary *params = @{
        @"username": username,
        @"password": password
    };
    
    NSString *url = [NSString stringWithFormat:@"%@/login", baseURL];
    
    [[ZMNetworkManager sharedManager] postRequestWithURL:url 
                                                  params:params 
                                                 headers:nil
                                                 success:^(id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

+ (void)getUserInfoWithUserId:(NSString *)userId 
                      success:(void (^)(NSDictionary *userInfo))success 
                      failure:(void (^)(NSError *error))failure {
    NSString *url = [NSString stringWithFormat:@"%@/user/%@", baseURL, userId];
    
    [[ZMNetworkManager sharedManager] getRequestWithURL:url 
                                                 params:nil 
                                                headers:nil
                                                success:^(id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

+ (void)sendMessage:(NSString *)message 
              toUser:(NSString *)receiverId 
             success:(void (^)(NSDictionary *response))success 
             failure:(void (^)(NSError *error))failure {
    NSDictionary *params = @{
        @"message": message,
        @"receiver_id": receiverId
    };
    
    NSString *url = [NSString stringWithFormat:@"%@/send_message", baseURL];
    
    [[ZMNetworkManager sharedManager] postRequestWithURL:url 
                                                  params:params 
                                                 headers:nil
                                                 success:^(id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

+ (void)getChatHistoryWithUserId:(NSString *)userId 
                            page:(NSInteger)page 
                        pageSize:(NSInteger)pageSize 
                         success:(void (^)(NSArray *messages))success 
                         failure:(void (^)(NSError *error))failure {
    NSDictionary *params = @{
        @"user_id": userId,
        @"page": @(page),
        @"page_size": @(pageSize)
    };
    
    NSString *url = [NSString stringWithFormat:@"%@/chat_history", baseURL];
    
    [[ZMNetworkManager sharedManager] getRequestWithURL:url 
                                                 params:params 
                                                headers:nil
                                                success:^(id responseObject) {
        if (success && [responseObject isKindOfClass:[NSArray class]]) {
            success(responseObject);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

+ (void)uploadFile:(NSData *)fileData 
          fileName:(NSString *)fileName 
          mimeType:(NSString *)mimeType 
           success:(void (^)(NSDictionary *response))success 
           failure:(void (^)(NSError *error))failure {
    NSString *tempFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    [fileData writeToFile:tempFilePath atomically:YES];
    
    NSString *url = [NSString stringWithFormat:@"%@/upload", baseURL];
    
    [[ZMNetworkManager sharedManager] uploadFileWithURL:url 
                                               filePath:tempFilePath 
                                                   data:nil
                                                  param:@{@"mime_type": mimeType}
                                               signType:1
                                               progress:nil
                                                success:^(id responseObject) {
        if (success) {
            success(responseObject);
        }
        [[NSFileManager defaultManager] removeItemAtPath:tempFilePath error:nil];
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
        [[NSFileManager defaultManager] removeItemAtPath:tempFilePath error:nil];
    }];
}

@end
