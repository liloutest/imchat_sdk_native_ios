//
//  ZMApis.m
//  imchat
//
//  Created by Lilou on 2024/10/23.
//

#import "ZMApis.h"

@implementation ZMApis
+ (NSString *)nodes{
//    return @"http://42nz10y3hhah.im-dreaminglife.cn/miner-api/trans/nodes";
    if(kZMENV) {
        return @"http://www.im-sit-dreaminglife.cn/miner-api/trans/nodes"; // sit
    }
    else {
        return @"http://www.im-dreaminglife.cn/miner-api/trans/nodes"; // dev
    }
    

}
@end
