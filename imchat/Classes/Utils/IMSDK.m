//
//  IMSDK.m
//  imchat
//
//  Created by Lilou on 2024/11/15.
//

#import "IMSDK.h"
#import "ZMChatViewController.h"
@implementation IMSDK
+ (void)initSDKWithIdentityID:(NSString *)identityID 
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
                 successBlock:(IMInitSuccessBlock)successBlock
                    failBlock:(IMInitFailBlock)failBlock {
    ZMChatViewController *vc = [ZMChatViewController new];
//    vc.nickId = _nickIdTextField.text;
//    vc.nickName = _nickNameTextField.text;
//    vc.merchantId = _merchantIdTextField.text;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:vc.nickId forKey:@"nickId"];
    [defaults setObject:vc.nickName forKey:@"nickName"];
    [defaults setObject:vc.merchantId forKey:@"merchantId"];
    [defaults synchronize];
    
//    [self.navigationController pushViewController:vc animated:YES];
}
@end
