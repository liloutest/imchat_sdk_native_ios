//
//  IMInitSDKModel.h
//  imchat
//
//  Created by Lilou on 2024/12/5.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZMModel.h"
#import "Constant.h"
NS_ASSUME_NONNULL_BEGIN

@interface IMInitSDKModel : ZMModel
@property(nonatomic, copy) NSString * identityID;
@property(nonatomic, copy) NSString * sign;
@property(nonatomic, copy) NSString * nickName;
@property(nonatomic, copy) NSString * nickId;
@property(nonatomic, copy) NSString * device;
@property(nonatomic, copy) NSString * headIcon;
@property(nonatomic, copy) NSString * phone;
@property(nonatomic, copy) NSString * email;
@property(nonatomic) IMLangType langType;
@property(nonatomic, copy) NSString * source;
@property(nonatomic, strong, nullable) NSDictionary<NSString *, NSString *> * extraInfo;
@end

NS_ASSUME_NONNULL_END
