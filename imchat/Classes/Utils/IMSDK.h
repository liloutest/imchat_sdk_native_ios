//
//  IMSDK.h
//  imchat
//
//  Created by Lilou on 2024/11/15.
//

#import <Foundation/Foundation.h>
typedef  void (^IMInitSuccessBlock)(void);
typedef  void (^IMInitFailBlock)(NSError * _Nullable error);
NS_ASSUME_NONNULL_BEGIN

@interface IMSDK : NSObject

+ (void)initSDKWithIdentityID:(NSString *)identityID              // 商户ID eg: 42nz10y3hhah
                         sign:(NSString *)sign                    // 签名 eg: b184b8e64c5b0004c58b5a3c9af6f3868d63018737e68e2a1ccc61580afbc8f112119431511175252d169f0c64d9995e5de2339fdae5cbddda93b65ce305217700
                     nickName:(NSString *)nickName                // 昵称 eg: ikun
                       nickId:(NSString *)nickId                  // 接入方业务传入的用户关联的id  eg: 112123
                       device:(NSString *)device                  // 设备名 eg: iPhone
                     headIcon:(NSString *)headIcon                // 用户头像 http://www.touxiang.com/touxiang.jpg
                        phone:(NSString *)phone                   // 手机号
                        email:(NSString *)email                   // 邮箱
                     language:(IMLangType)langType                // 语言类型：https://www.cnblogs.com/woshimrf/p/language-code-lcid.html (Language code列)  约定规则： zh,en,vi
                       source:(NSString *)source                  // 来源：接入方业务传入
                    extraInfo:(NSDictionary *)extraInfo           // 自定义传入参数 { @"xxx": @"13323232", @"yyy": @"sdfsd"}
                 successBlock:(IMInitSuccessBlock)successBlock    // 初始化sdk成功回调
                    failBlock:(IMInitFailBlock)failBlock;         // 初始化sdk失败回调


@end

NS_ASSUME_NONNULL_END
