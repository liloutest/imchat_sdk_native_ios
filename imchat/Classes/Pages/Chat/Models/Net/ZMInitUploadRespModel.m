//
//  ZMInitUploadRespModel.m
//  imchat
//
//  Created by Lilou on 2024/11/6.
//

#import "ZMInitUploadRespModel.h"

@implementation ZMInitUploadRespPartModel

@end

@implementation ZMInitUploadRespModel
+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{
             @"node":[ZMInitUploadRespPartModel class],
          
             };
}
@end
