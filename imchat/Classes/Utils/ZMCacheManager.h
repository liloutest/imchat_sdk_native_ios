//
//  ZMCacheManager.h
//  imchat
//
//  Created by Lilou on 2024/11/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZMCacheManager : NSObject
+ (instancetype)sharedManager;
- (NSString *)getSandboxRealPathWithFileName:(NSString *)fileName;
- (NSString *)copyFileToSandbox:(NSString *)path;
@end

NS_ASSUME_NONNULL_END
