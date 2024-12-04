//
//  ZMModel.h
//  imchat
//
//  Created by Lilou on 2024/10/17.
//

#import <Foundation/Foundation.h>
#import "YYModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface ZMModel : NSObject  <YYModel>
+ (instancetype)modelWithJSON:(id)json;
- (NSDictionary *)modelToJSONObject;
@end

NS_ASSUME_NONNULL_END
