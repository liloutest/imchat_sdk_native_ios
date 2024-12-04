//
//  ChatViewController.m
//  imchat
//
//  Created by Lilou on 2024/10/10.
//

#import "ZMChatViewController.h"
#import "Msggateway.pbobjc.h"
#import "ZMWebSocketManager.h"
#import "ZMLanguageManager.h"
#import <Masonry.h>
#import "ZMMessageCell.h"
#import "ZMTextMsgCell.h"
#import "ZMChatInputToolbar.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "ZMColorRes.h"
#import "ZMTimeMsgCell.h"
#import "ZMFontRes.h"
#import "ZMNetworkManager.h"
#import "ZMNodeManager.h"
#import "NSNumber+ZMAddon.h"
#import "ZMFAQMsgCell.h"
#import "ZMFAQPointMsgCell.h"
#import "ZMFAQAnswerCell.h"
#import "ZMPicMsgCell.h"
#import "ZMVideoMsgCell.h"
#import <TZImagePickerController.h>
#import "ZMMediaGalleryView.h"
#import "ZMServicerStatusCell.h"
#import "ZMQueueCell.h"
#import "ZMQuestionIsSolveCell.h"
#import "ZMTableHeaderView.h"
#import "AFNetworkReachabilityManager.h"
#import "ZMPopMsgTipView.h"
#import <MJRefresh/MJRefresh.h>
#import <Photos/Photos.h>
#import "ZMFloatChatToolView.h"
#import "ZMTimeoutConfigRespModel.h"
@interface ZMChatViewController ()   <UITableViewDelegate, UITableViewDataSource,ChatInputToolbarDelegate,TZImagePickerControllerDelegate>
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) ZMChatInputToolbar *inputToolbar;
@property (nonatomic,strong) UIButton *connectBtn;
@property (nonatomic,strong) UIButton *sendMsgBtn;
@property (nonatomic,strong) ZMWebSocketManager *zm;

@property (nonatomic, strong) ZMTableHeaderView *headerView;
@property (nonatomic) CGFloat lastContentOffset;
@property (nonatomic, strong) ZMUploadQueueTask *task;
@end

@implementation ZMChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self layouts];
    
    @try {
        [ZMMessageManager sharedInstance].identityID = _merchantId;
        [[ZMNetworkManager sharedManager] setCustomGlobalHeaders:@{@"lbeSign": @"b184b8e64c5b0004c58b5a3c9af6f3868d63018737e68e2a1ccc61580afbc8f112119431511175252d169f0c64d9995e5de2339fdae5cbddda93b65ce305217700",@"Content-Type":@"application/json",@"lbeIdentity":[ZMMessageManager sharedInstance].identityID ?: @""}.mutableCopy];
        [self mockLayout];
        
        
        [self initConfig];

    //       self.navigationController.navigationBar.translucent = NO;
    //       self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
        
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            if(status == AFNetworkReachabilityStatusNotReachable || status == AFNetworkReachabilityStatusUnknown){
                [self.headerView showWithAnimation];
            }
            else{
                [self.headerView hideWithAnimation];
                [[ZMNodeManager sharedManager] getBestNodes:^{
                    
                } wsBlock:^{
                    
                } ossBlock:^{
                    
                }];
            }
        }];
        
    //    [self cacheLoad];
        
        [SVProgressHUD show];
        [ZMHttpHelper getBestNodes:^{
            [self mockHttps];
        } wsBlock:^{
            
        } ossBlock:^{
            
        }];
        
        
    } @catch (NSException *exception) {
        [SVProgressHUD showErrorWithStatus:exception.description];
    } @finally {
        
    }
    
    
    
}

- (void)cacheLoad {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [ZMMessageManager sharedInstance].nickId = [defaults valueForKey:@"nickId1"] ?: @"";
    
    if(![[ZMMessageManager sharedInstance].nickId isEqualToString:_nickId] )return;
    
    [ZMMessageManager sharedInstance].sessionId = [defaults valueForKey:@"sessionId"] ?: @"";
    [ZMMessageManager sharedInstance].currentUserId = [defaults valueForKey:@"currentUserId"] ?: @"";
    [ZMMessageManager sharedInstance].token = [defaults valueForKey:@"token"] ?: @"";
    [ZMMessageManager sharedInstance].nickName = [defaults valueForKey:@"nickName"] ?: @"";
    [ZMMessageManager sharedInstance].identityID = [defaults valueForKey:@"identityID"] ?: @"";
    
    [[ZMMessageManager sharedInstance] initCacheLoadMsgs:^{
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
        }];
    
    [self scrollToBottom];
}

- (void)mockHttps{
    
//    NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:10 * 1024 * 1024  // 10MB
//                                                      diskCapacity:100 * 1024 * 1024   // 100MB
//                                                          diskPath:nil];
//    NSURLCache *sharedCache = [NSURLCache sharedURLCache];
//    [NSURLCache setSharedURLCache:cache];

    
    // 获取应用的主目录
    NSString *appDirectory = NSHomeDirectory();
    NSLog(@"App Directory: %@", appDirectory);
    
    // 获取 Documents 目录
    NSString *documentsDirectory = [appDirectory stringByAppendingPathComponent:@"Documents"];
    NSLog(@"Documents Directory: %@", documentsDirectory);
        
    
//    NSInteger msgCnt = [[ZMMessageManager sharedInstance] getMsgCount];
    
//    [[ZMMessageManager sharedInstance] clearAllDBDatas];
    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [ZMMessageManager sharedInstance].sessionId = [defaults valueForKey:@"sessionId"];
//    [ZMMessageManager sharedInstance].currentUserId = [defaults valueForKey:@"currentUserId"];
//    [ZMMessageManager sharedInstance].token = [defaults valueForKey:@"token"];
//    [ZMMessageManager sharedInstance].nickName = [defaults valueForKey:@"nickName"];
//    [ZMMessageManager sharedInstance].identityID = [defaults valueForKey:@"identityID"];
//    [self loadNewData];
//    
//    [self scrollToBottom];
    
    
//    [SVProgressHUD show];
    ZMCreateSessionReqModel *sessionModel = [ZMCreateSessionReqModel new];
    sessionModel.extraInfo = @"extraInfo";
    sessionModel.headIcon = @"https://img1.baidu.com/it/u=1653751609,236581088&fm=253&app=120&size=w931&n=0&f=JPEG&fmt=auto?sec=1729270800&t=36600cf9ed9f2ffddb3a3bb1ec5bd144";
    sessionModel.device = [UIDevice currentDevice].model;
    sessionModel.language = @"zh";
    sessionModel.source = @"hello";
    sessionModel.nickId = _nickId;//@"Lilou103112__118_11@@!";// old : Lilou103112; Lilou103112__118_11
    sessionModel.nickName = _nickName;//@"1-118-Lilou1314520";
    sessionModel.identityID = _merchantId;
    sessionModel.uid = _nickId;
    
    [ZMHttpHelper createSessionWith:sessionModel success:^(NSDictionary *response) {
        [SVProgressHUD dismiss];
        ZMCreateSessionRepModel *model = [ZMCreateSessionRepModel modelWithJSON:response];
        NSLog(@"%@",model);
        [ZMMessageManager sharedInstance].sessionId = model.sessionId;
        [ZMMessageManager sharedInstance].currentUserId = model.uid;
        [ZMMessageManager sharedInstance].token = model.token;
        [ZMMessageManager sharedInstance].nickName = sessionModel.nickName;
        [ZMMessageManager sharedInstance].identityID = sessionModel.identityID;
        
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:model.sessionId forKey:@"sessionId"];
        [defaults setObject:model.uid forKey:@"currentUserId"];
        [defaults setObject:model.token forKey:@"token"];
        [defaults setObject:sessionModel.nickName forKey:@"nickName"];
        [defaults setObject:sessionModel.identityID forKey:@"identityID"];
        [defaults setObject:self.nickId forKey:@"nickId1"];
        [defaults synchronize];
        
        // 获取超时配置
        [ZMHttpHelper getTimeoutConfigWithSuccess:^(NSDictionary *response) {
            ZMTimeoutConfigRespModel *model = [ZMTimeoutConfigRespModel modelWithJSON:response];
            [ZMMessageManager sharedInstance].timeoutConfigModel = model;
        } failure:^(NSError *error) {
            
        }];
        
        NSInteger msgCntLast = [[ZMMessageManager sharedInstance] getMsgCount];
//        __block NSInteger newSeq = [[ZMMessageManager sharedInstance] lastSeq];
//        __block NSInteger endSeq = 1000;
//        [ZMMessageManager sharedInstance].startSeq = newSeq;
        // 1. 没有历史，是新会话, 关联新sessionid, 拉取FAQ 会话初始操作等
        if(msgCntLast == 0) {
            // 拉取FAQ
//            return;
        }
        
//        [[ZMMessageManager sharedInstance] loadLocalAllMsgs];
        
        [self scrollToBottom];
        // 取全部会话列表
        [ZMHttpHelper getSessionListWith:2 pageNumber:1 showNumber:1000 success:^(NSDictionary *response) {
            
            ZMMessageSessionList *sessionList = [ZMMessageSessionList modelWithJSON:response];
            // sync sessionlist
            [[ZMMessageManager sharedInstance] syncSessionList:sessionList];
            
            // 没有数据，则取该会话最新一条 , 倒序翻页
//            if(newSeq == NSNotFound) {
//                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sessionId = %@", model.sessionId];
//
//                NSArray<ZMMessageSessionItem *> *filteredModels = [sessionList.sessionList filteredArrayUsingPredicate:predicate];
//                if(filteredModels.count > 0){
//                    [ZMMessageManager sharedInstance].startSeq = newSeq;
//                    newSeq = filteredModels.firstObject.latestMsg.msgSeq;
//                    endSeq = newSeq ;
//                    newSeq -= (kZMsgPageNum - 1);
//                }
//                
//            }
//            else{
//                // 有数据则取最新一条的seq 自增查服务端下一条
//                newSeq++;
//            }
            
            [self loadNewData];
            
            [self scrollToBottom];
            
//            [[ZMMessageManager sharedInstance] startMsgSync];

//            [ZMHttpHelper getHistoryWith:model.sessionId endSeq:endSeq startSeq:newSeq success:^(NSDictionary * _Nonnull response) {
//                ZMHistoryRepModel *historyModel = [ZMHistoryRepModel modelWithJSON:response];
//                
//                [[ZMMessageManager sharedInstance] messageHandle:historyModel.content];
//
//                if(historyModel.content.count > 0){
//                    [ZMMessageManager sharedInstance].startSeq = newSeq;
//                    [ZMMessageManager sharedInstance].endSeq = endSeq;
//                }
//                else{
//                    [ZMMessageManager sharedInstance].startSeq = 0;
//                    [ZMMessageManager sharedInstance].endSeq = 0;
//                }
//                
//                [self scrollToBottom];
//                
//            } failure:^(NSError * _Nonnull error) {
//                
//            }];
            
            
        } failure:^(NSError *error) {
            [SVProgressHUD dismiss];
        }];
        
       
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}

- (void)initConfig {
    
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeFlat];
    [SVProgressHUD setMinimumDismissTimeInterval:1.5];
    [SVProgressHUD setImageViewSize:CGSizeZero];

    
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    
    
    // 注册通知监听
    [self registerAppLifecycleNotifications];
}

- (void)customBackBtn {
    // 创建自定义返回按钮
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage zm_imageWithName:ZMImageRes.chatBackBlack] forState:UIControlStateNormal];
    backButton.frame = CGRectMake(0, 0, 44, 44);
    // 设置按钮的内容左对齐
    backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    // 设置按钮图片的内边距，根据需要调整
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -8, 0, 0);
    [backButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];

    // 创建 UIBarButtonItem
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = leftItem;

    // 如果需要消除返回按钮的文字（推荐在viewDidLoad中设置）
    self.navigationItem.backButtonTitle = @"";
    // 或者全局设置
//    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(-200, 0) forBarMetrics:UIBarMetricsDefault];
}

- (void)backButtonClicked {
    // 返回上一页
    [self.navigationController popViewControllerAnimated:YES];
    [[ZMUploadManager sharedManager] pauseTaskWithMsg:nil];
    [SVProgressHUD dismiss];
    // 或者如果需要dismiss模态视图
    // [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)mockLayout {
    self.view.backgroundColor = ZMColorRes.bgGrayColor;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    // 设置导航栏
    self.title = @"在线客服";
    // 设置导航栏标题的字体大小和颜色
    // 设置导航条不透明
    [self.navigationController.navigationBar setTranslucent:YES];

    // 设置导航条的背景颜色（不透明）
//    self.navigationController.navigationBar.barTintColor = [UIColor redColor]; // 可根据需要设置为其他颜色
    NSDictionary *attributes = @{
        NSFontAttributeName: ZMFontRes.titleFont, // 设置字体大小
        NSForegroundColorAttributeName: ZMColorRes.color_18243e, // 设置字体颜色
        NSBackgroundColorAttributeName: [UIColor clearColor]
    };
    
    // 通过 appearance 设置整个导航栏的标题属性
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];
    
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        appearance.backgroundColor = ZMColorRes.bgGrayColor; // 设置导航栏背景色
        appearance.shadowColor = ZMColorRes.color_ebebeb; // 如果不需要阴影，设置为透明
        appearance.titleTextAttributes = attributes;
        self.navigationController.navigationBar.standardAppearance = appearance;
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
    }

    [self customBackBtn];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage zm_imageWithName:ZMImageRes.chatBackBlack] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped)];
    
    
    [self setupInputToolbar];
    
    // TODO tableview 后面封装抽出来，先暂时这样调试cell 和 消息逻辑
    [self setupTableView];
    
    [[ZMFloatChatToolView shared] showInView:self.view aboveView:self.inputToolbar];
    
}

- (void)setupTableView {
    
    self.headerView = [[ZMTableHeaderView alloc] initWithFrame:CGRectMake(0, self.view.frame.origin.y, self.view.bounds.size.width, kW(40))];
    
//    self.tableView.tableHeaderView = self.headerView;
    
    [self.view addSubview:self.headerView];
    
    // 初始化tableView
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor =  ZMColorRes.bgGrayColor;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, kW(8), 0)];
//    self.tableView.tableFooterView = [UIView new];
    MJRefreshNormalHeader *mjHeader = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    self.tableView.mj_header = mjHeader;
    mjHeader.stateLabel.hidden = YES;
    mjHeader.arrowView.hidden = YES;
//    [self.tableView.mj_header beginRefreshing];
    [self.view addSubview:self.tableView];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTableview)];
    [self.tableView addGestureRecognizer:singleTap];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
        make.top.equalTo(self.headerView.mas_bottom);
            make.bottom.equalTo(self.inputToolbar.mas_top);
        }];
    
    // 注册自定义cell
    [self.tableView registerClass:[ZMTextMsgCell class] forCellReuseIdentifier:@"ZMTextMsgCell"];
    [self.tableView registerClass:[ZMTimeMsgCell class] forCellReuseIdentifier:@"ZMTimeMsgCell"];
    [self.tableView registerClass:[ZMFAQMsgCell class] forCellReuseIdentifier:@"ZMFAQMsgCell"];
    [self.tableView registerClass:[ZMFAQPointMsgCell class] forCellReuseIdentifier:@"ZMFAQPointMsgCell"];
    [self.tableView registerClass:[ZMFAQAnswerCell class] forCellReuseIdentifier:@"ZMFAQAnswerCell"];
    [self.tableView registerClass:[ZMPicMsgCell class] forCellReuseIdentifier:@"ZMPicMsgCell"];
    [self.tableView registerClass:[ZMVideoMsgCell class] forCellReuseIdentifier:@"ZMVideoMsgCell"];
    [self.tableView registerClass:[ZMQueueCell class] forCellReuseIdentifier:@"ZMQueueCell"];
    [self.tableView registerClass:[ZMServicerStatusCell class] forCellReuseIdentifier:@"ZMServicerStatusCell"];
    [self.tableView registerClass:[ZMQuestionIsSolveCell class] forCellReuseIdentifier:@"ZMQuestionIsSolveCell"];
    
}

- (void)tapTableview {
    [self.view endEditing:YES];
}

// 下拉刷新数据
- (void)loadNewData {
    
    if(![[ZMMessageManager sharedInstance] getCurrentUidSessionListCount]){
        self.tableView.mj_header = nil;
    }
    else{
        if(!self.tableView.mj_header){
            MJRefreshNormalHeader *mjHeader = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
            self.tableView.mj_header = mjHeader;
        }
    }

    [[ZMMessageManager sharedInstance] loadNextMsgsCompleteBlock:^{
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
    } noMoreBlock:^{
        self.tableView.mj_header = nil;
    }];
    
}


- (void)setupInputToolbar {
    self.inputToolbar = [[ZMChatInputToolbar alloc] init];
    self.inputToolbar.delegate = self;
    [self.view addSubview:self.inputToolbar];
    

    [self.inputToolbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        make.height.mas_equalTo(kW(66));
    }];
    
    
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.inputToolbar.mas_top).offset(-kW(8));
    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
//    CGFloat bottomInset = self.view.safeAreaInsets.bottom;
//    [self.inputToolbar mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(self.view).offset(-bottomInset);
//        make.height.mas_equalTo( kW(66)); self.view.mas_safeAreaLayoutGuideBottom
//    }];
//    CGFloat bottomInset = self.view.safeAreaInsets.bottom;
//    [self.inputToolbar mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(self.view).offset(-bottomInset);
//        make.height.mas_equalTo( kW(66));
//    }];
    
//    [self mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(self.view).offset(-bottomInset);
//        make.height.mas_equalTo(_inputTextView.lineCountUsingTextKit > 3 ? kW(66) + 120 : kW(66));
//    }];
}

#pragma mark - ChatInputToolbarDelegate

- (void)didTapSendButton:(NSString *)message msgType:(ZMMessageType)type {
    
//    ZMMessage *test = [[ZMMessage alloc] initWithText:@"{\"knowledgeBaseTitle\":\"你好！\",\"knowledgeBaseList\":[{\"id\":\"123456789\",\"url\":\"http://xxxxx\",\"knowledgeBaseName\":\"交易问题dfdfdfdfdfdfdfdfdfdf\"},{\"id\":\"123456789\",\"url\":\"http://xxxxx\",\"knowledgeBaseName\":\"账号问题\"},{\"id\":\"123456789\",\"url\":\"http://xxxxx\",\"knowledgeBaseName\":\"账号问题\"},{\"id\":\"123456789\",\"url\":\"http://xxxxx\",\"knowledgeBaseName\":\"账号问题\"},{\"id\":\"123456789\",\"url\":\"http://xxxxx\",\"knowledgeBaseName\":\"账号问题\"}]}" type:ZMMessageTypeFaqMsgType isFromUser:YES];
//    test.msgType =  test.msgBody.msgType = ZMMessageTypeFaqMsgType;
//    [[ZMMessageManager sharedInstance] addMessage:test];
//    
//    [[ZMFloatChatToolView shared] hideTimeoutTip];
//    return;
    
//    ZMMessage *test = [[ZMMessage alloc] initWithText:@"[{\"type\":0,\"content\":\"文本 ...\"},{\"type\":1,\"content\":\"http://xxx.png\",\"width\":1920,\"height\":1080},{\"type\":2,\"contents\":[{\"content\":\"详细请\\n自行\",\"url\":\"\"},{\"content\":\"Google\",\"url\":\"https://google.com\"},{\"content\":\"吧\",\"url\":\"\"}]}]" type:ZMMessageTypeKnowledgeAnswerMsgType isFromUser:YES];
//    test.msgType =  test.msgBody.msgType = ZMMessageTypeKnowledgeAnswerMsgType;
//    [[ZMMessageManager sharedInstance] addMessage:test];
//    
//    [[ZMFloatChatToolView shared] hideTimeoutTip];
//    return;
    
    
    __block ZMMessage *msg = [[ZMMessageManager sharedInstance] sendMsg:message msgType:type];
    
    if(msg){
        [ZMHttpHelper sendMessage:msg headers:nil success:^(NSDictionary *response) {
            ZMChatSendMsgRepModel *msgRepModel = [ZMChatSendMsgRepModel modelWithJSON:response];
            NSLog(@"msg_req = %ld",msgRepModel.msgReq);
            msg.sendStatus = ZMMessageSendStatusUnread;
            msg.msgBody.msgSeq = msgRepModel.msgReq;
            [[ZMMessageManager sharedInstance] updateMessage:msg];
            [self.tableView reloadData];
            [self scrollToBottomAnimated:YES];
            
            
            // 通知对方已读
            [[ZMMessageManager sharedInstance] markAsReadMsg:msg];
            
        } failure:^(NSError *error) {
            msg.sendStatus = ZMMessageSendStatusSendFail;
            [[ZMMessageManager sharedInstance] updateMessage:msg];
            [self.tableView reloadData];
            [self scrollToBottomAnimated:YES];
        }];
    }

}

- (void)test:(ZMMessage *)msg {
    sleep(5);
    msg.sendStatus = ZMMessageSendStatusSending;
    [ZMCommon mainExec:^{
        [self.tableView reloadData];
    }];

    
}

- (void)scrollToBottom {
    NSInteger section = 0; // 假设只有一个 section
    NSInteger row = [self.tableView numberOfRowsInSection:section] - 1; // 获取最后一行的索引

    if (row >= 0) { // 确保存在行
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

- (void)didTextChange:(NSString *)text{

    NSInteger lineCount = [self.inputToolbar.inputTextView lineCountUsingTextKit];
    if(lineCount == 0)lineCount = 1;
    NSLog(@"文本行数: %ld", (long)lineCount);
    
//    [self scrollToBottom];
    
    [self.inputToolbar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        make.height.mas_equalTo(lineCount > 5 ? kW(66) + 4 * kW(18) : kW(66) + (lineCount - 1) * kW(18));
    }];
  
}

- (void)messageChange{
    [ZMCommon mainExec:^{
        [self.tableView reloadData];
    //    [self scrollToBottom];
        self.lastContentOffset = self.tableView.contentOffset.y;
    }];

}

// 实现代理方法
- (void)mediaGalleryViewDidDismiss:(ZMMediaGalleryView *)galleryView {
    // 处理画廊视图关闭事件
}

- (void)mediaGalleryView:(ZMMediaGalleryView *)galleryView didTapDownloadForItemAtIndex:(NSInteger)index {
    
}

/// 过滤图片和视频选择大小限制
- (BOOL)isAssetCanBeSelected:(PHAsset *)asset {
    
    @try {
        // 检查文件大小限制
        if (asset.mediaType == PHAssetMediaTypeImage) {
            // 图片大小限制 (例如 10MB)
            NSInteger maxImageSize = 10 * 1024 * 1024; // 字节
            
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.synchronous = YES;
            
            __block BOOL canSelect = YES;
            [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                if (imageData.length > maxImageSize) {
                    canSelect = NO;
                }
            }];
            
            if (!canSelect) {
                [SVProgressHUD showInfoWithStatus:@"图片大小超出限制"];
                return NO;
            }
        } else if (asset.mediaType == PHAssetMediaTypeVideo) {
            // 视频大小限制 (例如 100MB)
            NSInteger maxVideoSize = 100 * 1024 * 1024; // 字节
            
            PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
            options.version = PHVideoRequestOptionsVersionOriginal;
            // 创建信号量
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            __block BOOL canSelect = YES;
            [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                if ([asset isKindOfClass:[AVURLAsset class]]) {
                    AVURLAsset *urlAsset = (AVURLAsset *)asset;
                    NSNumber *size = nil;
                    BOOL value =  [urlAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
                    if ([size longLongValue] > maxVideoSize) {
                        canSelect = NO;
                    }
                }
                // 发送信号
                dispatch_semaphore_signal(semaphore);
            }];
            
            // 等待信号量，最多等待10秒
            dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC));
            
            if (!canSelect) {
                [SVProgressHUD showInfoWithStatus:@"视频大小超出限制"];
                return NO;
            }
        }
        
        return YES;
    } @catch (NSException *exception) {
        return YES;
    }
}



- (void)didTapImageButton {
    
    
    // 实现选择图片的逻辑
    NSLog(@"Image button tapped");
    
    
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
    imagePickerVc.allowPickingMultipleVideo = YES;
    // You can get the photos by block, the same as by delegate.
    // 你可以通过block或者代理，来得到用户选择的照片.
    __weak ZMChatViewController *weakSlef = self;
    [imagePickerVc setDidFinishPickingVideoHandle:^(UIImage *coverImage, PHAsset *asset) {

    }];
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        
        @try {
            // 遍历每个选择的 PHAsset
                for (PHAsset *asset in assets) {
                    
                    if (asset.mediaType == PHAssetMediaTypeImage) {
                        [self getImageRealPath:asset completion:^(NSString *imagePath) {
                            NSString *imgPath =  [[ZMCacheManager sharedManager] copyFileToSandbox:imagePath];
                            ZMMessageMsgBodyMediaJson *mediaJson = [ZMMessageMsgBodyMediaJson new];
                            mediaJson.resource.url = imgPath;
                            mediaJson.resource.key = @"";
                            NSString *path  = [mediaJson yy_modelToJSONString];
                            
                            __block ZMMessage *msg = [[ZMMessageManager sharedInstance] sendMsg:path msgType:ZMMessageTypeImg];
                            
                            if(msg){
                                __weak ZMChatViewController *weakSelf = self;
                                
                                [[ZMUploadManager sharedManager] startTaskWithMsg:msg filePath:imgPath type:ZMUploadFileTypeImage queue:nil completeBlock:^(ZMCompleteUploadModel * _Nullable model) {
                                    if(model) {
                                        //                            [weakSlef didTapSendButton:model.location msgType:ZMMessageTypeImg];
                                        // 图片上传成功后，发送消息
                                       
                                        msg.msgBody.msgBody = model.location;
                                        [ZMHttpHelper sendMessage:msg headers:nil success:^(NSDictionary *response) {
                                            ZMChatSendMsgRepModel *msgRepModel = [ZMChatSendMsgRepModel modelWithJSON:response];
                                            NSLog(@"msg_req = %ld",msgRepModel.msgReq);
                                            msg.sendStatus = ZMMessageSendStatusUnread;
                                            msg.msgBody.msgSeq = msgRepModel.msgReq;
                                            [[ZMMessageManager sharedInstance] updateMessage:msg];
                                            [weakSelf.tableView reloadData];
                                            [weakSelf scrollToBottomAnimated:YES];
                                            
                                            
                                            // 通知对方已读
                                            [[ZMMessageManager sharedInstance] markAsReadMsg:msg];
                                            
                                        } failure:^(NSError *error) {
                                            msg.sendStatus = ZMMessageSendStatusSendFail;
                                            [[ZMMessageManager sharedInstance] updateMessage:msg];
                                            [weakSelf.tableView reloadData];
                                            [weakSelf scrollToBottomAnimated:YES];
                                        }];
                                    }
                                    else{
                                        // 文件发送中断或失败
                                        msg.sendStatus = ZMMessageSendStatusUnread;
                                        [[ZMMessageManager sharedInstance] updateMessage:msg];
                                        [weakSelf.tableView reloadData];
                                        [weakSelf scrollToBottomAnimated:YES];
                                    }
                                } progressBlock:^(CGFloat progress) {
                                    NSLog(@" ======= %f",progress);
                                } thumbBlock:^{
                                    [weakSelf scrollToBottomAnimated:YES];
                                }];
                                
                            }
                           
                        }];
                    }
                    else if (asset.mediaType == PHAssetMediaTypeVideo) {
                        [self getVideoURLFromPHAsset:asset completion:^(NSURL *url, NSError *error) {
                            NSString *videoPath =  [[ZMCacheManager sharedManager] copyFileToSandbox:url.path];
                            
                            ZMMessageMsgBodyMediaJson *mediaJson = [ZMMessageMsgBodyMediaJson new];
                            mediaJson.resource.url = videoPath;
                            mediaJson.resource.key = @"";
                            mediaJson.thumbnail.url = videoPath;
                            mediaJson.thumbnail.key = @"";
                            NSString *path  = [mediaJson yy_modelToJSONString];
                            
                            __block ZMMessage *msg = [[ZMMessageManager sharedInstance] sendMsg:path msgType:ZMMessageTypeVideo];
                            
                            if(msg) {
                                __weak ZMChatViewController *weakSelf = self;
                                
                                [[ZMUploadManager sharedManager] startTaskWithMsg:msg filePath:videoPath type:ZMUploadFileTypeVideo queue:nil completeBlock:^(ZMCompleteUploadModel * _Nullable model) {
                                    if(model) {
                                        //                            [weakSlef didTapSendButton:model.location msgType:ZMMessageTypeImg];
                                        // 图片上传成功后，发送消息
                                       
                                        msg.msgBody.msgBody = model.location;
                                        [ZMHttpHelper sendMessage:msg headers:nil success:^(NSDictionary *response) {
                                            ZMChatSendMsgRepModel *msgRepModel = [ZMChatSendMsgRepModel modelWithJSON:response];
                                            NSLog(@"msg_req = %ld",msgRepModel.msgReq);
                                            msg.sendStatus = ZMMessageSendStatusUnread;
                                            msg.msgBody.msgSeq = msgRepModel.msgReq;
                                            [[ZMMessageManager sharedInstance] updateMessage:msg];
                                            [weakSelf.tableView reloadData];
                                            [weakSelf scrollToBottomAnimated:YES];
                                            
                                            
                                            // 通知对方已读
                                            [[ZMMessageManager sharedInstance] markAsReadMsg:msg];
                                            
                                        } failure:^(NSError *error) {
                                            msg.sendStatus = ZMMessageSendStatusSendFail;
                                            [[ZMMessageManager sharedInstance] updateMessage:msg];
                                            [weakSelf.tableView reloadData];
                                            [weakSelf scrollToBottomAnimated:YES];
                                        }];
                                    }
                                    else{
                                        // 文件发送中断或失败
                                        msg.sendStatus = (ZMMessageSendStatus)msg.msgBody.task.state ;
                                        [[ZMMessageManager sharedInstance] updateMessage:msg];
                                        [weakSelf.tableView reloadData];
                                        [weakSelf scrollToBottomAnimated:YES];
                                    }
                                } progressBlock:^(CGFloat progress) {
                                    NSLog(@" ======= %f",progress);
                                } thumbBlock:^{
                             
                                    [weakSelf scrollToBottomAnimated:YES];
                                }];
                                
                            }
                            
                            
                        }];
                    }
                    
                }
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
        
        
    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

- (void)getVideoURLFromPHAsset:(PHAsset *)asset completion:(void(^)(NSURL *url, NSError *error))completion {
    // 创建一个请求选项，确保我们获得的是原始视频（如果视频存在于iCloud上，可以下载）
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
    options.networkAccessAllowed = YES; // 允许从网络获取视频

    // 使用 PHImageManager 获取视频文件
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset
                                                    options:options
                                              resultHandler:^(AVAsset *avAsset, AVAudioMix *audioMix, NSDictionary *info) {
        // avAsset 是 AVURLAsset 类型时，表示是一个本地视频资源
        if ([avAsset isKindOfClass:[AVURLAsset class]]) {
            AVURLAsset *urlAsset = (AVURLAsset *)avAsset;
            NSURL *url = urlAsset.URL;
            [ZMCommon mainExec:^{
                if (completion) {
                    completion(url, nil);
                }
            }];
           
        } else {
            // 如果不是本地视频，可以尝试处理其他情况
            [ZMCommon mainExec:^{
                if (completion) {
                    NSError *error = [NSError errorWithDomain:@"VideoError" code:1001 userInfo:@{NSLocalizedDescriptionKey: @"视频文件不是本地文件，可能是云端文件或正在加载."}];
                    completion(nil, error);
                }
            }];
            
        }
    }];
}

- (void)getImageRealPath:(PHAsset *)asset completion:(void(^)(NSString *imagePath))completion {
    PHContentEditingInputRequestOptions *options = [[PHContentEditingInputRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    
    [asset requestContentEditingInputWithOptions:options completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {

        // 获取图片真实路径
        NSString *imagePath = contentEditingInput.fullSizeImageURL.path;
        
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(imagePath);
            });
        }
    }];
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    if ([ZMMessageManager sharedInstance].messages.count > 0) {
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:[ZMMessageManager sharedInstance].messages.count - 1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

// UITableViewDataSource方法

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 在此处处理滚动事件
    // 计算滚动超过一屏的阈值
    CGFloat screenHeight = scrollView.frame.size.height;
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    
    // 判断是否滚动超过一屏
    if ((self.lastContentOffset - contentOffsetY  > screenHeight) && contentOffsetY > 0) {
        NSLog(@"滚动超过一屏");
        __weak ZMChatViewController *weakSelf = self;
        [[ZMFloatChatToolView shared] showPopMsgTip:@"回到底部"];
        [[ZMFloatChatToolView shared] setDismissPopMsgTipBlock:^{
            [weakSelf scrollToBottom];
            [[ZMFloatChatToolView shared] hidePopMsgTip];
            weakSelf.lastContentOffset = weakSelf.tableView.contentOffset.y;
        }];

//        [self.popMsgTipView showWithText:@"回到底部" inView:self.view aboveView:self.inputToolbar edge:UIEdgeInsetsMake(0, 0, kW(8), kW(16))];
    } else  {
        [[ZMFloatChatToolView shared] hidePopMsgTip];
    }

//    NSLog(@"正在滚动，当前偏移量: %@", NSStringFromCGPoint(scrollView.contentOffset));
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [ZMMessageManager sharedInstance].messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    ZMFAQMsgCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZMFAQPointMsgCell" forIndexPath:indexPath];
//    cell.questionBlock = ^(ZMMessage * _Nonnull message, int index) {
//        NSLog(@"index = %d",index);
//    };
//    
//    cell.likeEventBlock = ^(ZMMessage * _Nonnull message, BOOL like) {
//        NSLog(@"like = %d",like);
//    };
//    ZMTextMsgCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZMTextMsgCell" forIndexPath:indexPath];
//    ZMTimeMsgCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZMTimeMsgCell" forIndexPath:indexPath];

//    ZMPicMsgCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZMPicMsgCell" forIndexPath:indexPath];

//    ZMServicerStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZMServicerStatusCell" forIndexPath:indexPath];
//        ZMQueueCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZMQueueCell" forIndexPath:indexPath];
//    ZMQuestionIsSolveCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZMQuestionIsSolveCell" forIndexPath:indexPath];

    
    ZMMessage *message = [ZMMessageManager sharedInstance].messages[indexPath.row];
    
    NSString *cellTag = @"";
    
    
    switch (message.msgBody.msgType) {
        case ZMMessageTypeJoinServer:
            cellTag = @"ZMTextMsgCell";
            break;
        case ZMMessageTypeText:
            cellTag = @"ZMTextMsgCell";
            break;
        case ZMMessageTypeImg:

            cellTag = @"ZMPicMsgCell";
            break;
        case ZMMessageTypeVideo:
            
            cellTag = @"ZMVideoMsgCell";
            break;
        case ZMMessageTypeFaqMsgType:
            cellTag = @"ZMFAQMsgCell";
            break;
        case ZMMessageTypeKnowledgePointMsgType:
            cellTag = @"ZMFAQPointMsgCell";
            break;
        case ZMMessageTypeKnowledgeAnswerMsgType:
            cellTag = @"ZMFAQAnswerCell";
            break;
        default:
            break;
    }
    
    ZMMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellTag forIndexPath:indexPath];
    [cell configureWithMessage:message];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footView = [[UIView alloc] init];
    return footView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZMMessage *msg = [ZMMessageManager sharedInstance].messages[indexPath.row];
    return  msg.height;
}


#pragma mark -- Notification

- (void)scrollToBottomAnimated {
    [self scrollToBottomAnimated:YES];
}

- (void)layouts{
    self.view.backgroundColor = [UIColor whiteColor];
    self.connectBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.connectBtn.frame = CGRectMake(100, 100, 100, 50);
    [self.connectBtn addTarget:self action:@selector(connectSR) forControlEvents:UIControlEventTouchUpInside];
    [self.connectBtn setTitle:@"连接" forState:UIControlStateNormal];
    [self.view addSubview:self.connectBtn];
    
    self.sendMsgBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.sendMsgBtn.frame = CGRectMake(100, 200, 100, 50);
    [self.sendMsgBtn setTitle:@"发送消息" forState:UIControlStateNormal];
    [self.sendMsgBtn addTarget:self action:@selector(connectSR) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.sendMsgBtn];
}

- (void)connectSR {
//    self.zm = [[ZMWebSocketManager alloc] initWithServerIp:@"ws://10.40.91.10:10001"];
//    [self.zm connectWebSocket];
//    MsgEntity *entity = [MsgEntity new];
//    MsgType *type = [MsgType new];
//    type.messageType = 1;
//    entity.msgType = type;
//    Join *join = [Join new];
//    join.uid = @"hzh Uid";
//    entity.join = join;
//    TalkText *tt = [TalkText new];
//    tt.uid = @"123";
//    tt.content = @"hello im";
//    entity.talkText = tt;
//    [self.zm sendData:[entity data]];
    NSString *s =  [[ZMLanguageManager sharedInstance] currentLanguage];
    [[ZMLanguageManager sharedInstance] updateLanguagePackFromServer:^(BOOL success, NSError *error) {
        if(success)NSLog(@"success");
//        [[ZMLanguageManager sharedInstance] setCurrentLanguage:@"en"];
        NSLog(@"%@",[[ZMLanguageManager sharedInstance] localizedStringForKey:@"welcome_message",@"dalao",@"fd",@"11"]);
    }];
    

    NSLog(@"%@",s);
}


#pragma mark -- LifeCycle

- (void)registerAppLifecycleNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    // 将要进入前台
    [center addObserver:self
               selector:@selector(appWillEnterForeground:)
                   name:UIApplicationWillEnterForegroundNotification
                 object:nil];
    
    // 已经进入前台
    [center addObserver:self
               selector:@selector(appDidBecomeActive:)
                   name:UIApplicationDidBecomeActiveNotification
                 object:nil];
    
    // 将要进入后台
    [center addObserver:self
               selector:@selector(appWillResignActive:)
                   name:UIApplicationWillResignActiveNotification
                 object:nil];
    
    // 已经进入后台
    [center addObserver:self
               selector:@selector(appDidEnterBackground:)
                   name:UIApplicationDidEnterBackgroundNotification
                 object:nil];
    
    // 将要终止
    [center addObserver:self
               selector:@selector(appWillTerminate:)
                   name:UIApplicationWillTerminateNotification
                 object:nil];
    
    [center addObserver:self selector:@selector(messageChange) name:kZMMessageDidChangeNotification object:nil];
    
    [center addObserver:self selector:@selector(scrollToBottomAnimated) name:kZMChatListScrollToBottomNotification object:nil];
}

#pragma mark - App生命周期回调方法
- (void)appWillEnterForeground:(NSNotification *)notification {
    NSLog(@"App将要进入前台");
    // 在这里处理将要进入前台时的逻辑
    // TODO: 1.处理sync session 状态， 因为后台期间会话可能被结束，此时需要 createsession ; 2. 需要sync msg , 因为websocket 后台期间会断， 可能少消息
    
}

- (void)appDidBecomeActive:(NSNotification *)notification {
    NSLog(@"App已经变成活跃状态");
    // 在这里处理已经进入前台时的逻辑
}

- (void)appWillResignActive:(NSNotification *)notification {
    NSLog(@"App将要进入非活跃状态");
    // 在这里处理将要进入后台时的逻辑
}

- (void)appDidEnterBackground:(NSNotification *)notification {
    NSLog(@"App已经进入后台");
    // 在这里处理已经进入后台时的逻辑
}

- (void)appWillTerminate:(NSNotification *)notification {
    NSLog(@"App将要终止");
    // 在这里处理App终止前的逻辑
    @try {
        [[ZMUploadManager sharedManager] pauseTaskWithMsg:nil];
    } @catch (NSException *exception) {
        
    }
    
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}


- (void)dealloc{
    // 移除所有通知监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[ZMMessageManager sharedInstance] destory];
    [[ZMWebSocketManager sharedManager] disconnect];
}

@end
