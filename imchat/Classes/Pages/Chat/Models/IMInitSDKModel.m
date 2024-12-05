//
//  IMInitSDKModel.m
//  imchat
//
//  Created by Lilou on 2024/12/5.
//

#import "IMInitSDKModel.h"

@implementation IMInitSDKModel
- (NSString *)device {
    if(!_device) {
        _device = [UIDevice currentDevice].model;
    }
    return _device;
}
@end
