//
//  ZMNodesModel.h
//  imchat
//
//  Created by Lilou on 2024/10/23.
//

#import "ZMResponseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZMNodesModel : ZMResponseModel
@property (nonatomic, strong) NSArray *oss;
@property (nonatomic, strong) NSArray *ws;
@property (nonatomic, strong) NSArray *rest;

@end

NS_ASSUME_NONNULL_END
