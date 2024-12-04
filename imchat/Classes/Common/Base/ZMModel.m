//
//  ZMModel.m
//  imchat
//
//  Created by Lilou on 2024/10/17.
//

#import "ZMModel.h"

@implementation ZMModel
+ (instancetype)modelWithJSON:(id)json {
    return [self yy_modelWithJSON:json];
}

- (NSDictionary *)modelToJSONObject {
    return [self yy_modelToJSONObject];
}
@end
