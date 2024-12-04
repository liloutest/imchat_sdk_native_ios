//
//  ZMResponseModel.h
//  imchat
//
//  Created by Lilou on 2024/10/23.
//

#import <Foundation/Foundation.h>
#import "ZMModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface ZMResponseModel : ZMModel
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, copy) NSString *msg;
@property (nonatomic, copy) NSString *dlt;

@property (nonatomic, strong) id data;


@property (nonatomic, assign) NSInteger errCode;
@property (nonatomic, copy) NSString *errMsg;
@property (nonatomic, copy) NSString *errDlt;


@end

NS_ASSUME_NONNULL_END
