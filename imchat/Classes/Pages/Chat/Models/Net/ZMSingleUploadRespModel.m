//
//  ZMSingleUploadRespModel.m
//  imchat
//
//  Created by Lilou on 2024/11/8.
//

#import "ZMSingleUploadRespModel.h"

@implementation ZMSingleUploadItemModel

@end

@implementation ZMSingleUploadRespModel
+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{
             @"paths":[ZMSingleUploadItemModel class],
          
             };
}
@end
