//
//  IMSDK.m
//  imchat
//
//  Created by Lilou on 2024/11/15.
//

#import "IMSDK.h"
#import "ZMChatViewController.h"
@implementation IMSDK


+ (BOOL)initSDKWithIdentityID:(NSString *)identityID              // 商户ID eg: 42nz10y3hhah
                         sign:(NSString *)sign                    // 签名 eg:
                     nickName:(NSString *)nickName                // 昵称 eg: ikun
                       nickId:(NSString *)nickId                  // 接入方业务传入的用户关联的id  eg: 112123
                       device:(NSString *)device                  // 设备名 eg: iPhone
                     headIcon:(NSString *)headIcon                // 用户头像 http://www.touxiang.com/touxiang.jpg
                        phone:(NSString *)phone                   // 手机号
                        email:(NSString *)email                   // 邮箱
                     language:(IMLangType)langType                // 语言类型：https://www.cnblogs.com/woshimrf/p/language-code-lcid.html (Language code列)  约定规则： zh,en,vi
                       source:(NSString *)source                  // 来源：接入方业务传入
                    extraInfo:(NSDictionary *)extraInfo           // 自定义传入参数 { @"xxx": @"13323232", @"yyy": @"sdfsd"}
{
    @try {
        ZMChatViewController *vc = [ZMChatViewController new];
        
    //    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //    [defaults setObject:vc.nickId forKey:@"nickId"];
    //    [defaults setObject:vc.nickName forKey:@"nickName"];
    //    [defaults setObject:vc.merchantId forKey:@"merchantId"];
    //    [defaults synchronize];
        
    //    vc.nickId =
        
        // open vc
        UIViewController *controller = [ZMCommon viewControllerWithWindow:nil];
        UINavigationController *nav = [controller navigationController];
        if(!nav){
            nav = [[UINavigationController alloc] initWithRootViewController:vc];
            [controller presentViewController:nav animated:YES completion:nil];
        }
        else{
            [nav pushViewController:vc animated:YES];
        }
        return YES;
    } @catch (NSException *exception) {
        return NO;
    }
}
@end
