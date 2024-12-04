//
//  ZMQuestionIsSolveCell.h
//  imchat
//
//  Created by Lilou on 2024/10/22.
//

#import "ZMMessageCell.h"

NS_ASSUME_NONNULL_BEGIN
typedef  void (^SolveBlock)(ZMMessage *message,BOOL solve);
@interface ZMQuestionIsSolveCell : ZMMessageCell
@property (nonatomic,strong)  SolveBlock solveBlock;
@end

NS_ASSUME_NONNULL_END
