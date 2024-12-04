//
//  ZMPicMsgCell.m
//  imchat
//
//  Created by Lilou on 2024/10/17.
//

#import "ZMPicMsgCell.h"
#import "Masonry.h"
#import "ZMColorRes.h"
#import "ZMFontRes.h"
#import "ZMMediaLoadingView.h"
#import "ZMMediaGalleryView.h"
#import "CircleProgressView.h"
@interface ZMPicMsgCell () <ZMMediaGalleryViewDelegate>
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) ZMMediaLoadingView *loadingView;
@end

@implementation ZMPicMsgCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
        [self setConfigInfo];
    }
    return self;
}

- (void)setConfigInfo {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileUploadDidChange:) name:kZMMessageFileUploadDidChangeNotification object:nil];
}

- (void)setupViews {
    [super setupViews];
    self.bubbleView.hidden = YES;
    self.imgView = [[UIImageView alloc] init];
    self.imgView.layer.cornerRadius = kW(16);
    self.imgView.clipsToBounds = YES;
    self.imgView.userInteractionEnabled = YES;
    self.imgView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.imgView];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.imgView addGestureRecognizer:singleTap];
    self.loadingView = [[ZMMediaLoadingView alloc] initWithType:ZMMediaLoadingTypeCircleProgress];
    self.loadingView.blurAlpha = 0.88;
    self.loadingView.hidden = YES;
    self.loadingView.userInteractionEnabled = YES;
    __weak ZMPicMsgCell *weakSelf = self;
    [self.loadingView setPauseBlock:^{
        [[ZMUploadManager sharedManager] pauseTaskWithMsg:weakSelf.message];
    }];
    [self.loadingView setResumeBlock:^{
        [[ZMUploadManager sharedManager] resumeTaskWithMsg:weakSelf.message completeBlock:^(ZMCompleteUploadModel * _Nullable model) {
            [weakSelf completeHandle:model];
        } progressBlock:^(CGFloat progress) {
            
        } thumbBlock:^{
            
        }];
    }];
    [self.loadingView setFailBlock:^{
        [[ZMUploadManager sharedManager] retryTaskWithMsg:weakSelf.message completeBlock:^(ZMCompleteUploadModel * _Nullable model) {
            [weakSelf completeHandle:model];
        } progressBlock:^(CGFloat progress) {
            
        } thumbBlock:^{
            
        }];
    }];
    [self.contentView addSubview:self.loadingView];

//    // 开始加载动画
//    [self.loadingView startAnimating];
//
//    // 设置进度
//    [self.loadingView setProgress:0.5 animated:YES];
//
//    // 停止加载动画，显示进度
//    [self.loadingView stopAnimating];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.loadingView.isCircular = YES;
    
////    // 创建视图
//    CircleProgressView *progressView = [[CircleProgressView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
//    progressView.center = self.contentView.center;
//    [self.contentView addSubview:progressView];
//
//    // 更新进度（例如在下载进度回调中）
//    progressView.progress = 0.4; // 40%
    
    
    [self refreshStatus];
}


- (void)refreshStatus {
    self.loadingView.userInteractionEnabled = self.message.msgBody.task.isBigFile;
    if(self.message.msgBody.task.state == ZMUploadStateFailed) {
        self.loadingView.userInteractionEnabled = YES;
    }
    
    switch (self.message.msgBody.sendStatus) {
        case ZMMessageSendStatusReaded:
        case ZMMessageSendStatusUnread:
        {
            self.msgStatusImageView.hidden = self.message.isFromSys;
        }
            break;
            
        default:
            self.msgStatusImageView.hidden = YES;
            break;
    }
}

- (void)completeHandle:(ZMCompleteUploadModel *)model {
    __weak ZMPicMsgCell *weakSelf = self;
    if(model) {
        //                            [weakSlef didTapSendButton:model.location msgType:ZMMessageTypeImg];
        // 图片上传成功后，发送消息
        weakSelf.message.msgBody.msgBody = model.location;
        [ZMHttpHelper sendMessage:weakSelf.message headers:nil success:^(NSDictionary *response) {
            ZMChatSendMsgRepModel *msgRepModel = [ZMChatSendMsgRepModel modelWithJSON:response];
            NSLog(@"msg_req = %ld",msgRepModel.msgReq);
            weakSelf.message.sendStatus = ZMMessageSendStatusUnread;
            weakSelf.message.msgBody.msgSeq = msgRepModel.msgReq;
            [[ZMMessageManager sharedInstance] updateMessage:weakSelf.message];
            [[weakSelf findSuperTableView] reloadData];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kZMMessageDidChangeNotification object:nil];
            
            
            // 通知对方已读
            [[ZMMessageManager sharedInstance] markAsReadMsg:weakSelf.message];
            
        } failure:^(NSError *error) {
            weakSelf.message.sendStatus = ZMMessageSendStatusSendFail;
            [[ZMMessageManager sharedInstance] updateMessage:weakSelf.message];
            [[weakSelf findSuperTableView] reloadData];
            [[NSNotificationCenter defaultCenter] postNotificationName:kZMMessageDidChangeNotification object:nil];
        }];
    }
    else{
        // 文件发送中断或失败
        weakSelf.message.sendStatus = (ZMMessageSendStatus)weakSelf.message.msgBody.task.state ;
        [[ZMMessageManager sharedInstance] updateMessage:weakSelf.message];
        [[weakSelf findSuperTableView] reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:kZMMessageDidChangeNotification object:nil];
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *)gesture {
    
//    ZMMediaGalleryView *galleryView = [[ZMMediaGalleryView alloc] initWithMediaURLs:@[@"http://mirror.aarnet.edu.au/pub/TED-talks/911Mothers_2010W-480p.
    [self.findViewController.view endEditing:YES];
    ZMMediaGalleryView *galleryView = [[ZMMediaGalleryView alloc] initWithMediaMsgs:[ZMMessageManager sharedInstance].messages currentMsg:self.message imgContentIndex:NSNotFound];
    galleryView.delegate = self;
    [galleryView showInView:self.findViewController.view];
    
}

- (void)mediaGalleryViewDidDismiss:(ZMMediaGalleryView *)galleryView {
    galleryView = nil;
}

- (void)configureWithMessage:(ZMMessage *)message{
    [super configureWithMessage:message];
    self.message = message;
    
    NSLog(@"url: %@",[message.msgBody resource].url);
    
    if(self.message.msgBody.task.state == ZMUploadStateCompleted){
        self.loadingView.hidden = YES;
        self.imgView.userInteractionEnabled = YES;
    }
    else{
        self.loadingView.hidden = !self.message.msgBody.task;
        self.loadingView.type = [self getLoadingTypeWithUploadState];
        self.loadingView.progress = self.message.msgBody.task.progress;
        self.imgView.userInteractionEnabled = !self.message.msgBody.task;
    }
    
    
    if(self.message.isFromSys){
//        [self.imgView mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(self.avatarImageView.mas_right).offset(kW(8));
//            make.top.equalTo(self.nameLabel.mas_bottom).offset(kW(8));
//            make.size.mas_equalTo(CGSizeMake(imgWidth, imgHeight));
//        }];
    }else{
//        [self.imgView mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.right.equalTo(self.avatarImageView.mas_left).offset(-kW(8));
//            make.top.equalTo(self.nameLabel.mas_bottom).offset(kW(8));
//            make.size.mas_equalTo(CGSizeMake(imgWidth, imgHeight));
//        }];
    }
    

    
    [self.imgView zm_setImageWithURL:[message.msgBody resource].url placeholderImage:[UIImage new] encryptKey:[message.msgBody resource].key isVideo:NO completion:^(UIImage * _Nullable image, NSError * _Nullable error) {
        if(!error && image){
            
            CGSize size = [ZMCommon getMediaFitSize:image.size];
            CGFloat imgHeight =  size.height;
            CGFloat imgWidth = size.width;
            
//            if(1440 == [ZMMessageMsgBodyMediaJson modelWithJSON:self.message.msgBody.msgBody].height){
//                self.imgView.contentMode = UIViewContentModeScaleToFill;
//                imgHeight = 230;
//            }
            
            
            if(message.isFromSys){
                
                
                
                [self.imgView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(self.avatarImageView.mas_right).offset(kW(8));
                    make.top.equalTo(self.nameLabel.mas_bottom).offset(kW(8));
                    make.size.mas_equalTo(CGSizeMake(imgWidth, imgHeight));
                }];
                
                [self.msgStatusImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(self.imgView);
                    make.left.equalTo(self.imgView.mas_right).offset(kW(8));
                }];
                self.msgStatusImageView.hidden = YES;
            }
            else{
                
               
                
                [self.imgView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(self.avatarImageView.mas_left).offset(-kW(8));
                    make.top.equalTo(self.nameLabel.mas_bottom).offset(kW(8));
                    make.size.mas_equalTo(CGSizeMake(imgWidth, imgHeight));
                }];
                
                [self.msgStatusImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(self.imgView);
                    make.right.equalTo(self.imgView.mas_left).offset(-kW(8));
                }];
                
                self.msgStatusImageView.hidden = NO;
            }
            
            [self.loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self.imgView);
                make.size.mas_equalTo(CGSizeMake(kW(32), kW(32)));
            }];
            
            
            
            self.message.height = imgHeight;
            
    
            [[self findSuperTableView] beginUpdates];
            [[self findSuperTableView] endUpdates];
//            if ([ZMMessageManager sharedInstance].messages.count > 0) {
//                NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:[ZMMessageManager sharedInstance].messages.count - 1 inSection:0];
//                [(UITableView *)self.superview scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//            }
        }
        else{
            self.msgStatusImageView.hidden = YES;
        }
    }];
    
//    [self.imgView zm_setImageWithURL:[message.msgBody resource].url placeholderImage:nil completion:^(UIImage * _Nullable image, NSError * _Nullable error) {
//        if(!error){
//            CGFloat imgHeight = image.size.height;
//            CGFloat imgWidth = image.size.width;
//            CGFloat maxWidth = SCREEN_WIDTH / 2;
//            CGFloat maxHeight = kW(160);
//            if(imgWidth > maxWidth){
//                imgWidth = maxWidth;
//            }
//            if(imgHeight > maxHeight){
//                imgHeight = maxHeight;
//            }
//            if(message.isFromSys){
//                
//                [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
//                    make.left.equalTo(self.avatarImageView.mas_right).offset(kW(8));
//                    make.top.equalTo(self.nameLabel.mas_bottom).offset(kW(8));
//                    make.size.mas_equalTo(CGSizeMake(imgWidth, imgHeight));
//                }];
//                
//            }
//            else{
//                
//                [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
//                    make.right.equalTo(self.avatarImageView.mas_left).offset(-kW(8));
//                    make.top.equalTo(self.nameLabel.mas_bottom).offset(kW(8));
//                    make.size.mas_equalTo(CGSizeMake(imgWidth, imgHeight));
//                }];
//            }
//            
//            self.message.height = imgHeight;
//            
//            [(UITableView *)self.superview beginUpdates];
//            [(UITableView *)self.superview endUpdates];
//        }
//    }];

}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark -- Notification
- (void)fileUploadDidChange:(NSNotification *)notification {
    if([notification.object isKindOfClass:ZMUploadTask.class]){
        ZMUploadTask *task = (ZMUploadTask *)notification.object;
        [ZMCommon mainExec:^{
            if([self.message.msgBody.task.taskId isEqualToString:task.taskId] && [self.message.msgBody.task.filePath isEqualToString:task.filePath]){
                NSLog(@"self.message.msgBody.taskid = %@, progress = %f",self.message.msgBody.task.taskId,task.progress);
                switch (task.state) {
                    case ZMUploadStateUploading:
                    {
                        self.loadingView.hidden = NO;
                        self.imgView.userInteractionEnabled = NO;
                        self.loadingView.type = ZMMediaLoadingTypeCircleProgress;
                        self.loadingView.progress = task.progress;
//                        [[self findSuperTableView] reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[[ZMMessageManager sharedInstance].messages indexOfObject:self.message] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
//                        [(UITableView *)self.superview reloadData];
 
                    }

                        break;
                    case ZMUploadStateCompleted:
                    {
                        self.loadingView.progress = task.progress;
                        self.loadingView.hidden = YES;
                        self.imgView.userInteractionEnabled = YES;
//                        [[self findSuperTableView] reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[[ZMMessageManager sharedInstance].messages indexOfObject:self.message] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                    
                    }
                    case ZMUploadStatePaused:
                    {
                        
                    }
                        break;
                    case ZMUploadStateFailed:
                    {
                        
                    }
                        break;
                    default:
                        break;
                }
                [self setNeedsLayout];
                [self layoutIfNeeded];
            }
        }];
        
    }
    
}

- (ZMMediaLoadingType)getLoadingTypeWithUploadState {
    switch (self.message.msgBody.task.state) {
        case ZMUploadStateUploading:
            return ZMMediaLoadingTypeCircleProgress;
            break;
        case ZMUploadStateFailed:
            return ZMMediaLoadingTypeUploadFail;
            break;
        case ZMUploadStatePaused:
            return ZMMediaLoadingTypeUploadPause;
            break;
        default:
            break;
    }
    return ZMMediaLoadingTypeCircleProgress;
}

@end
