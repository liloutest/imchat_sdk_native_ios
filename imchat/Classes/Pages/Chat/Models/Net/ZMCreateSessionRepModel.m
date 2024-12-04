//
//  ZMCreateSessionRepModel.m
//  imchat
//
//  Created by Lilou on 2024/10/23.
//

#import "ZMCreateSessionRepModel.h"

@implementation ZMCreateSessionRepModel
- (NSString *)sessionId {
    if(!_sessionId){
        _sessionId = @"";
    }
    return _sessionId;
}

- (NSString *)token{
    if(!_token){
        _token = @"";
    }
    return _token;
}

- (NSString *)uid{
    if(!_uid){
        _uid = @"";
    }
    return _uid;
}
@end
