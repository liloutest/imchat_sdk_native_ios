//
//  IMSDK.m
//  imchat
//
//  Created by Lilou on 2024/11/15.
//

#import "IMSDK.h"
#import "ZMChatViewController.h"
@implementation IMSDK
+ (BOOL)initSDKWithIdentityID:(NSString *)identityID
                         sign:(NSString *)sign
                     nickName:(NSString *)nickName
                       nickId:(NSString *)nickId
                       device:(NSString *)device
                     headIcon:(NSString *)headIcon
                        phone:(NSString *)phone
                        email:(NSString *)email
                     language:(IMLangType)langType
                       source:(NSString *)source
                    extraInfo:(NSDictionary *)extraInfo
                   controller:(UIViewController *)controller
//                 successBlock:(IMInitSuccessBlock)successBlock
//                    failBlock:(IMInitFailBlock)failBlock
{
    ZMChatViewController *vc = [ZMChatViewController new];
    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults setObject:vc.nickId forKey:@"nickId"];
//    [defaults setObject:vc.nickName forKey:@"nickName"];
//    [defaults setObject:vc.merchantId forKey:@"merchantId"];
//    [defaults synchronize];
    
//    vc.nickId =
    
    // open vc
    UINavigationController *nav = [controller navigationController];
    if(!nav){
        nav = [[UINavigationController alloc] initWithRootViewController:controller];
    }
    
    [nav pushViewController:vc animated:YES];
    return YES;
}
@end
