//
//  ZMFAQBaseCell.h
//  imchat
//
//  Created by Lilou on 2024/11/25.
//

#import "ZMMessageCell.h"

NS_ASSUME_NONNULL_BEGIN
typedef  void (^QuestionBlock)(ZMMessage *message,int index);
typedef  void (^LikeEventBlock)(ZMMessage *message,BOOL like);
@interface ZMFAQBaseCell : ZMMessageCell
@property (nonatomic,strong)  QuestionBlock questionBlock;
@property (nonatomic,strong)  LikeEventBlock likeEventBlock;
@end

NS_ASSUME_NONNULL_END
