#import "ZMMediaGalleryView.h"
#import <AVKit/AVKit.h>
#import <Photos/Photos.h>
#import "ZMVideoPlayerView.h"
#import <SDWebImage/SDWebImage.h>
#import "ZMAESCryptor.h"

#define kZMTagVideoIndex 1024

@interface ZMMediaGalleryModel : ZMModel
@property (nonatomic, strong) ZMMessageMsgBodyMediaJsonItem *item;
@property (nonatomic) ZMMessageType type;
@property (nonatomic, strong) ZMUploadTask *task;
@property (nonatomic, copy) NSString *body;
@property (nonatomic) NSInteger sendTimeStamp;
@end

@implementation ZMMediaGalleryModel

@end


@interface ZMMediaGalleryView () <UIScrollViewDelegate>
@property (nonatomic) BOOL navigationBarHidden;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray<ZMMediaGalleryModel *> *mediaMsgs;
@property (nonatomic, strong) NSMutableArray<UIView *> *mediaViews;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *downloadButton;
@property (nonatomic) NSInteger currentIndex;
@property (nonatomic) NSInteger imgContentIndex;
@property (nonatomic, strong) UIView *downloadContainer;  // 下载按钮容器
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;  // 活动指示器
@end

@implementation ZMMediaGalleryView

//- (instancetype)initWithMediaURLs:(NSArray<NSString *> *)mediaURLs {
//    self = [super init];
//    if (self) {
//        _mediaURLs = mediaURLs;
//        _mediaViews = [NSMutableArray array];
//        [self setupViews];
//    }
//    return self;
//}

- (instancetype)initWithMediaMsgs:(NSArray<ZMMessage *> *)mediaMsgs currentMsg:(ZMMessage *)currentMsg imgContentIndex:(NSInteger)imgContentIndex {
    self = [super init];
    if (self) {
        _mediaMsgs = @[].mutableCopy;
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(ZMMessage *message, NSDictionary *bindings) {
            if(message.msgBody.msgType == ZMMessageTypeKnowledgeAnswerMsgType){
                NSPredicate *subPredicate = [NSPredicate predicateWithBlock:^BOOL(ZMMessageMsgBodyFaqAnswers *answerMessage, NSDictionary *bindings) {
                    return answerMessage.type == ZMMessageFaqAnswerTypeImage;
                }];
                NSArray<ZMMessageMsgBodyFaqAnswers *> *imgAnswers = [message.msgBody.faqAnswers filteredArrayUsingPredicate:subPredicate];
                return imgAnswers.count > 0;
            }
            else{
                return message.msgBody.msgType == ZMMessageTypeImg || message.msgBody.msgType == ZMMessageTypeVideo;
            }
            
        }];
        NSArray<ZMMessage *> *mediaMessages = [[ZMMessageManager sharedInstance].messages filteredArrayUsingPredicate:predicate];
        
        [mediaMessages enumerateObjectsUsingBlock:^(ZMMessage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            
            switch (obj.msgBody.msgType) {
                case ZMMessageTypeImg:
                case ZMMessageTypeVideo:
                {
                    ZMMediaGalleryModel *model = [ZMMediaGalleryModel new];
                    model.type = obj.msgBody.msgType;
                    model.task = obj.msgBody.task;
                    model.body = obj.msgBody.msgBody;
                    model.sendTimeStamp = obj.msgBody.sendTimeStamp;
                    ZMMessageMsgBodyMediaJsonItem *item = [ZMMessageMsgBodyMediaJsonItem new];
                    ZMMessageMsgBodyMediaJson *mediaJson = [ZMMessageMsgBodyMediaJson modelWithJSON:obj.msgBody.msgBody];
                    item.url = mediaJson.resource.url;
                    item.key = mediaJson.resource.key;
                    if(![ZMCommon isHttp:item.url]){
                        item.url = [[ZMCacheManager sharedManager] getSandboxRealPathWithFileName:[item.url lastPathComponent]];
                    }
                    model.item = item;
                    [_mediaMsgs addObject:model];
                }
                    break;
                case ZMMessageTypeKnowledgeAnswerMsgType:
                {
                    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(ZMMessageMsgBodyFaqAnswers *answer, NSDictionary *bindings) {
                        return answer.type == ZMMessageFaqAnswerTypeImage;
                    }];
                    NSArray<ZMMessageMsgBodyFaqAnswers *> *imgAnswers = [obj.msgBody.faqAnswers ?: @[] filteredArrayUsingPredicate:predicate];
                    
                    [imgAnswers enumerateObjectsUsingBlock:^(ZMMessageMsgBodyFaqAnswers * _Nonnull answerObj, NSUInteger idx, BOOL * _Nonnull stop) {
                        ZMMediaGalleryModel *model = [ZMMediaGalleryModel new];
                        model.type = obj.msgBody.msgType;
                        model.task = obj.msgBody.task;
                        model.body = obj.msgBody.msgBody;
                        model.sendTimeStamp = obj.msgBody.sendTimeStamp;
                        ZMMessageMsgBodyMediaJsonItem *answerItem = [ZMMessageMsgBodyMediaJsonItem new];
                        answerItem = answerObj.imgContent;
                        model.item = answerItem;
                        [_mediaMsgs addObject:model];
                    }];

                }
                    break;
                default:
                    break;
            }
        }];
        
        [_mediaMsgs enumerateObjectsUsingBlock:^(ZMMediaGalleryModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if(obj.body == currentMsg.msgBody.msgBody && obj.type == currentMsg.msgBody.msgType && obj.task == currentMsg.msgBody.task && obj.sendTimeStamp == currentMsg.msgBody.sendTimeStamp){
                _currentIndex = idx;
                if(imgContentIndex != NSNotFound) {
                    _currentIndex += imgContentIndex;
                }
                *stop = YES;
            }
        }];
//        _mediaMsgs = mediaMessages;
//        NSInteger index = [_mediaMsgs indexOfObject:currentMsg];
//        _currentIndex = (index != NSNotFound ? index : 0);
        _mediaViews = [NSMutableArray array];
        [self setupViews];
    }
    return self;
}


- (void)setupViews {
    self.backgroundColor = [UIColor blackColor];
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    [self addSubview:self.scrollView];
    
    [self setupMediaViews];
    
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.closeButton setImage:[UIImage zm_imageWithName:ZMImageRes.chatMediaClose] forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(closeTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.closeButton];
    
    // 创建下载容器视图
    self.downloadContainer = [[UIView alloc] init];
    self.downloadContainer.backgroundColor = [ZMColorRes color_979797WithAlpha:0.4];
    self.downloadContainer.layer.cornerRadius = kW(18);
    [self addSubview:self.downloadContainer];
    
    // 初始化下载按钮
    self.downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.downloadButton setTitle:@"保存" forState:UIControlStateNormal];
    [self.downloadButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.downloadButton.titleLabel.font = ZMFontRes.font_12;
    [self.downloadButton addTarget:self action:@selector(downloadTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.downloadContainer addSubview:self.downloadButton];
    
    // 初始化活动指示器
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.activityIndicator.hidesWhenStopped = YES;
    [self.downloadContainer addSubview:self.activityIndicator];
    
    // 设置约束
    [self.downloadContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(kW(16));
        make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-kW(20));
        make.height.mas_equalTo(kW(36));
    }];
    
    [self.downloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.downloadContainer).offset(kW(12));
        if(!self.activityIndicator.isAnimating)make.right.equalTo(self.downloadContainer).offset(-kW(12));
        make.centerY.equalTo(self.downloadContainer);
        make.height.mas_equalTo(kW(24));
    }];
    
    [self.activityIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.downloadButton.mas_right).offset(kW(8));
        make.centerY.equalTo(self.downloadContainer);
        make.size.mas_equalTo(CGSizeMake(kW(20), kW(20)));
        make.right.equalTo(self.downloadContainer).offset(-kW(12));
    }];
    
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-kW(16));
        make.centerY.equalTo(self.downloadButton);
//        make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-kW(20));
        make.width.height.mas_equalTo(kW(32));
    }];
    
    [self updateDownloadButtonTitle:@"保存"];
}

- (void)setupMediaViews {
    for (NSInteger i = 0; i < self.mediaMsgs.count; i++) {
        ZMMediaGalleryModel *model = self.mediaMsgs[i];
        if ([self isImageURL:model]) {
            [self setupImageViewForURL:model atIndex:i];
        } else if([self isVideoURL:model]) {
            [self setupVideoViewForURL:model atIndex:i];
        }
    }
    
}

//- (void)setupAnswerImageViewForURL:(ZMMessageMsgBodyFaqAnswers *)imgAnswer atIndex:(NSInteger)index {
//    UIScrollView *zoomScrollView = [[UIScrollView alloc] init];
//    zoomScrollView.delegate = self;
//    zoomScrollView.minimumZoomScale = 1.0;
//    zoomScrollView.maximumZoomScale = 3.0;
//    
////    ZMMessageMsgBodyMediaJson *mediaJsonModel = [ZMMessageMsgBodyMediaJson modelWithJSON:urlString];
//    
//    UIImageView *imageView = [[UIImageView alloc] init];
//    imageView.contentMode = UIViewContentModeScaleAspectFit;
//    [imageView zm_setImageWithURL:imgAnswer.imgContent.url placeholderImage:nil encryptKey:imgAnswer.imgContent.key isVideo:NO completion:^(UIImage * _Nullable image, NSError * _Nullable error) {
//        
//    }];
//    [zoomScrollView addSubview:imageView];
//    
//    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
//    [zoomScrollView addGestureRecognizer:singleTap];
//    
//    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
//    doubleTap.numberOfTapsRequired = 2;
//    [zoomScrollView addGestureRecognizer:doubleTap];
//    
//    [singleTap requireGestureRecognizerToFail:doubleTap];
//    
//    [self.scrollView addSubview:zoomScrollView];
//    [self.mediaViews addObject:zoomScrollView];
//}

- (void)setupImageViewForURL:(ZMMediaGalleryModel *)model atIndex:(NSInteger)index {
    UIScrollView *zoomScrollView = [[UIScrollView alloc] init];
    zoomScrollView.delegate = self;
    zoomScrollView.minimumZoomScale = 1.0;
    zoomScrollView.maximumZoomScale = 3.0;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [imageView zm_setImageWithURL:model.item.url placeholderImage:nil encryptKey:model.item.key isVideo:NO completion:^(UIImage * _Nullable image, NSError * _Nullable error) {
        
    }];
    [zoomScrollView addSubview:imageView];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [zoomScrollView addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [zoomScrollView addGestureRecognizer:doubleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    [self.scrollView addSubview:zoomScrollView];
    [self.mediaViews addObject:zoomScrollView];
}

- (void)setupVideoViewForURL:(ZMMediaGalleryModel *)model atIndex:(NSInteger)index {
//    AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
//    playerViewController.player = [AVPlayer playerWithURL:[NSURL URLWithString:url]];
//    playerViewController.showsPlaybackControls = YES;
//    [self.scrollView addSubview:playerViewController.view];
//    [self.mediaViews addObject:playerViewController.view];
//    [playerViewController player];
//    
//    UIButton *closeVideoButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [closeVideoButton setImage:[UIImage systemImageNamed:@"xmark.circle.fill"] forState:UIControlStateNormal];
//    [closeVideoButton addTarget:self action:@selector(closeVideoTapped:) forControlEvents:UIControlEventTouchUpInside];
//    [playerViewController.view addSubview:closeVideoButton];
//    
//    [closeVideoButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(playerViewController.view).offset(20);
//        make.bottom.equalTo(playerViewController.view).offset(-20);
//        make.width.height.equalTo(@44);
//    }];
//    ZMMessageMsgBodyMediaJson *mediaJsonModel = [ZMMessageMsgBodyMediaJson modelWithJSON:url];
//    [ZMCommon thumbnailFromVideoPath:mediaJsonModel.thumbnail.url key:@"" atTime:CMTimeMakeWithSeconds(1.0, 600) completion:^(UIImage *thumbnail, NSError *error) {
//        if (thumbnail) {
//            
//            
//        }
//    }];
    
    
    ZMVideoPlayerView *pView = [[ZMVideoPlayerView alloc] initWithFrame:self.bounds];
    pView.tag = kZMTagVideoIndex + index;
    if(self.currentIndex == index){
        [pView playVideoWithURL:[NSURL URLWithString:model.item.url]];
    }
    
    [self.scrollView addSubview:pView];
    [self.mediaViews addObject:pView];
//    [self addSubview:pView];
    
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.scrollView.frame = self.bounds;
    self.scrollView.contentSize = CGSizeMake(self.bounds.size.width * self.mediaMsgs.count, self.bounds.size.height);
    
    for (NSInteger i = 0; i < self.mediaViews.count; i++) {
        UIView *mediaView = self.mediaViews[i];
        mediaView.frame = CGRectMake(i * self.bounds.size.width, 0, self.bounds.size.width, self.bounds.size.height);
        
        if ([mediaView isKindOfClass:[UIScrollView class]]) {
            UIScrollView *zoomScrollView = (UIScrollView *)mediaView;
            UIImageView *imageView = zoomScrollView.subviews.firstObject;
            imageView.frame = zoomScrollView.bounds;
        }
        else if([mediaView isKindOfClass:[ZMVideoPlayerView class]]){
            
        }
    }
    
//    // 计算文字宽度
//    CGFloat textWidth = [self.downloadButton.titleLabel.text sizeWithAttributes:@{
//        NSFontAttributeName: self.downloadButton.titleLabel.font
//    }].width;
//    
//    // 计算总宽度
//    CGFloat totalWidth = kW(12) + textWidth + kW(12) ;
//    if (self.activityIndicator.isAnimating) {
//        totalWidth += kW(8) + kW(20) + kW(12);
//    }
////  
//    [self.downloadButton mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.width.mas_equalTo(textWidth);
//    }];
//    
//    [self.downloadContainer mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.width.mas_equalTo(totalWidth);
//    }];
//    

    
    [self.scrollView setContentOffset:CGPointMake(_currentIndex * SCREEN_WIDTH, 0)];
}


- (void)showInView:(UIView *)view {
    UIViewController *findVC = view.findViewController;
    self.navigationBarHidden = findVC.navigationController.navigationBar.hidden;
    [findVC.navigationController setNavigationBarHidden:YES animated:YES];
    self.frame = view.bounds;
    [view addSubview:self];
    
    self.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
    }];
}

- (void)dismissWithAnimation {
    [self.findViewController.navigationController setNavigationBarHidden:self.navigationBarHidden animated:NO];
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if([obj isKindOfClass:ZMVideoPlayerView.class]){
                [(ZMVideoPlayerView *)obj dismiss];
                [obj removeFromSuperview];
                obj = nil;
            }
            
        }];
        self.scrollView = nil;
        [self.mediaViews removeAllObjects];
        self.mediaViews = nil;
        if ([self.delegate respondsToSelector:@selector(mediaGalleryViewDidDismiss:)]) {
            [self.delegate mediaGalleryViewDidDismiss:self];
        }
    }];
}

- (void)closeTapped {
    [self dismissWithAnimation];
//    [self closeVideoTapped:nil];
}

- (void)downloadTapped {
    NSInteger currentIndex = self.scrollView.contentOffset.x / self.scrollView.frame.size.width;
    ZMMediaGalleryModel *model = self.mediaMsgs[currentIndex];
    if ([self isImageURL:model]) {
        [self saveImageWithURL:model.item.url key:model.item.key atIndex:currentIndex];
    } else {
        [self saveVideoWithURL:model.item.url atIndex:currentIndex];
    }
}

- (void)saveImageWithURL:(NSString *)urlString key:(NSString *)key atIndex:(NSInteger)index {
    NSURL *url = [NSURL URLWithString:urlString];
    
    // 缩略图启用后 这个屏蔽掉
    // 使用密钥创建唯一的缓存key
    NSString *cacheKey = [NSString stringWithFormat:@"%@_%@", urlString, key];
    
    // 先尝试从缓存获取
    UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromCacheForKey:cacheKey];
    if (cachedImage) {
        [self saveImageToAlbum:cachedImage atIndex:index];
        return;
    }
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            [self notifyDelegateOfSaveWithError:error atIndex:index];
            return;
        }
        
        UIImage *image = [UIImage new];
        // 加密的先解密
        if(key.length > 0){
            NSData *decryptedData = [ZMAESCryptor decryptData:data key:key iv:nil];
            
            if (decryptedData) {
                image = [UIImage imageWithData:decryptedData];
            }
        }
        else{
            image = [UIImage imageWithData:data];
        }
        
    
        if (!image) {
            NSError *imageError = [NSError errorWithDomain:@"ZMMediaGalleryErrorDomain" code:0 userInfo:@{NSLocalizedDescriptionKey: @"Failed to create image from data"}];
            [self notifyDelegateOfSaveWithError:imageError atIndex:index];
            return;
        }
        else{
            // 缓存解密后的图片
            [[SDImageCache sharedImageCache] storeImage:image forKey:cacheKey completion:nil];
        }
        
        [self saveImageToAlbum:image atIndex:index];
    }];
    [task resume];
}

- (void)saveVideoWithURL:(NSString *)urlString atIndex:(NSInteger)index {
    @try {
        // 首先检查权限
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status != PHAuthorizationStatusAuthorized) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD showErrorWithStatus:@"请在设置中允许访问相册"];
                });
                return;
            }
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            ZMMediaGalleryModel *model = self.mediaMsgs[index];
            
            // 如果本地有自己上传的缓存视频 直接取
            NSString *path = [[ZMCacheManager sharedManager] getSandboxRealPathWithFileName:[model.task.filePath lastPathComponent]];
            if(model.task.filePath && [fileManager fileExistsAtPath:path]) {
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL URLWithString:path]];
                    if (!request) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self updateDownloadButtonTitle:@"保存"];
                            [SVProgressHUD showErrorWithStatus:@"保存失败"];
                        });
                    }
                } completionHandler:^(BOOL success, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self updateDownloadButtonTitle:@"保存"];
                        if (success) {
                            [SVProgressHUD showSuccessWithStatus:@"已保存至系统相册"];
                        } else {
                            [SVProgressHUD showErrorWithStatus:@"保存失败"];
                        }
                    });
                }];
                return;
            }
            
            // 创建临时文件路径
            NSString *tempFileName = [NSString stringWithFormat:@"temp_video_%ld.mp4", (long)index];
            NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:tempFileName];
            NSURL *tempURL = [NSURL fileURLWithPath:tempPath];
            
            // 如果临时文件已存在，直接保存临时文件， 不去重复下载
            if ([fileManager fileExistsAtPath:tempPath]) {
                [self saveTempPathVideoFile:tempURL];
                return;
//                [fileManager removeItemAtPath:tempPath error:nil];
            }
            
            // 创建下载请求
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
            NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
            
            // 创建下载任务
            NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updateDownloadButtonTitle:@"保存"];
                });
                
                if (error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD showErrorWithStatus:@"保存失败"];
                    });
                    return;
                }
                
                NSError *moveError = nil;
                if ([fileManager moveItemAtURL:location toURL:tempURL error:&moveError]) {
                    [self saveTempPathVideoFile:tempURL];
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD showErrorWithStatus:@"保存失败"];
                    });
                }
            }];
            
            // 添加进度监听
            [downloadTask addObserver:self
                      forKeyPath:@"countOfBytesReceived"
                         options:NSKeyValueObservingOptionNew
                         context:NULL];
            
            [downloadTask resume];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateDownloadButtonTitle:@"保存中0%"];
            });
            
        }];
    } @catch (NSException *exception) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateDownloadButtonTitle:@"保存"];
            [SVProgressHUD showErrorWithStatus:exception.description];
        });
    }
}

- (void)saveTempPathVideoFile:(NSURL *)tempURL {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:tempURL];
        if (!request) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showErrorWithStatus:@"保存失败"];
            });
        }
    } completionHandler:^(BOOL success, NSError *error) {
//                        [fileManager removeItemAtURL:tempURL error:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [SVProgressHUD showSuccessWithStatus:@"已保存至系统相册"];
            } else {
                [SVProgressHUD showErrorWithStatus:@"保存失败"];
            }
        });
    }];
}

- (void)saveImageToAlbum:(UIImage *)image atIndex:(NSInteger)index {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromImage:image];
    } completionHandler:^(BOOL success, NSError *error) {
        [self notifyDelegateOfSaveWithError:error atIndex:index];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [SVProgressHUD showSuccessWithStatus:@"已保存至系统相册"];
            } else {
                [SVProgressHUD showErrorWithStatus:@"保存失败"];
            }
        });
    }];
}

- (void)notifyDelegateOfSaveWithError:(NSError *)error atIndex:(NSInteger)index {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(mediaGalleryView:didSaveMediaToAlbumAtIndex:withError:)]) {
            [self.delegate mediaGalleryView:self didSaveMediaToAlbumAtIndex:index withError:error];
        }
    });
}

//// iOS 14+ 的权限检查
//- (void)checkPhotoLibraryPermissionForiOS14:(NSURL *)fileURL atIndex:(NSInteger)index {
//    if (@available(iOS 14, *)) {
//        [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelReadWrite
//                                                 handler:^(PHAuthorizationStatus status) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                switch (status) {
//                    case PHAuthorizationStatusAuthorized:
//                        [self accessPhotoLibrary];
//                        break;
//                    case PHAuthorizationStatusLimited:
//                        // 用户选择了部分照片访问
//                        [self accessPhotoLibrary];
//                        break;
//                    default:
//                        [self showPermissionDeniedAlert];
//                        break;
//                }
//            });
//        }];
//    } else {
//        [self checkAndRequestPhotoLibraryPermission];
//    }
//}
//
//- (void)permissionHandle:(NSURL *)fileURL atIndex:(NSInteger)index {
//    if (@available(iOS 14, *)) {
//        [self checkPhotoLibraryPermissionForiOS14:fileURL atIndex:index];
//    } else {
//        [self checkAndRequestPhotoLibraryPermission];
//    }
//}

- (void)closeVideoTapped:(UIButton *)sender {
    [self dismissWithAnimation];
    // 视频的URL（可以是本地文件URL或网络URL）
//        NSURL *videoURL = [NSURL URLWithString:@"http://vjs.zencdn.net/v/oceans.mp4"];
//        
//        // 创建一个AVPlayer实例
//        AVPlayer *player = [AVPlayer playerWithURL:videoURL];
//        
//        // 创建AVPlayerViewController并设置player
//        AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
//        playerViewController.player = player;
//        
//        // 可选：设置一些AVPlayerViewController的属性
//        playerViewController.showsPlaybackControls = YES; // 显示播放控件
//        
//        // 以模态方式呈现AVPlayerViewController
//        [self.findViewController presentViewController:playerViewController animated:YES completion:^{
//            [player play]; // 在呈现完成后开始播放
//        }];
    
//    AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
//    playerViewController.player = [AVPlayer playerWithURL:[NSURL URLWithString:@"http://vjs.zencdn.net/v/oceans.mp4"]];
//    playerViewController.showsPlaybackControls = YES;
//    playerViewController.view.frame = self.bounds; // 设置为与当前视图相同的大小
//        playerViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight; // 自适大小
//    [self.findViewController addChildViewController:playerViewController];
//    [self addSubview:playerViewController.view];
//    [playerViewController didMoveToParentViewController:self.findViewController];
//    [self.mediaViews addObject:playerViewController.view];
//    [playerViewController player];
    
    
}

- (void)handleSingleTap:(UITapGestureRecognizer *)gesture {
    [self dismissWithAnimation];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return scrollView.subviews.firstObject;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger index = scrollView.contentOffset.x / SCREEN_WIDTH;
    _currentIndex = index;
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    @try {
        ZMMediaGalleryModel *model = [self.mediaMsgs objectAtIndex:_currentIndex];
        if(model.type == ZMMessageTypeVideo){
//            ZMMessageMsgBodyMediaJson *mediaJsonModel = [ZMMessageMsgBodyMediaJson modelWithJSON:msg.msgBody.msgBody];
            UIView *view = [self.scrollView viewWithTag:kZMTagVideoIndex + _currentIndex];
            if([view isKindOfClass:ZMVideoPlayerView.class]){
                ZMVideoPlayerView *pView = (ZMVideoPlayerView *)view;
                [pView playVideoWithURL:[NSURL URLWithString:model.item.url]];
            }
        }
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    @try {
//        ZMMessage *msg = [self.mediaMsgs objectAtIndex:_currentIndex];
//        if(msg.msgBody.msgType == ZMMessageTypeVideo){
//            ZMMessageMsgBodyMediaJson *mediaJsonModel = [ZMMessageMsgBodyMediaJson modelWithJSON:msg.msgBody.msgBody];
//            UIView *view = [self.scrollView viewWithTag:kZMTagVideoIndex + _currentIndex];
//            if([view isKindOfClass:ZMVideoPlayerView.class]){
//                ZMVideoPlayerView *pView = (ZMVideoPlayerView *)view;
//                [pView stopVideo];
////                [pView playVideoWithURL:[NSURL URLWithString:mediaJsonModel.resource.url]];
//            }
//        }
//    } @catch (NSException *exception) {
//        
//    } @finally {
//        
//    }
}

- (BOOL)isImageURL:(ZMMediaGalleryModel *)msg {
    return msg.type == ZMMessageTypeImg || msg.type == ZMMessageTypeKnowledgeAnswerMsgType;
//    NSString *lowercaseURL = [urlString lowercaseString];
//    NSArray *imageExtensions = @[@".jpg", @".jpeg", @".png", @".gif", @".bmp", @".tiff"];
//    
//    for (NSString *extension in imageExtensions) {
//        if ([lowercaseURL hasSuffix:extension]) {
//            return YES;
//        }
//    }
//    
//
//    return NO;
}

- (BOOL)isVideoURL:(ZMMediaGalleryModel *)msg {
    return msg.type == ZMMessageTypeVideo;
//    NSString *lowercaseURL = [urlString lowercaseString];
//    NSArray *videoExtensions = @[@".mp4", @".mov", @".avi", @".wmv", @".flv", @".mkv"];
//    
//    for (NSString *extension in videoExtensions) {
//        if ([lowercaseURL hasSuffix:extension]) {
//            return YES;
//        }
//    }
//    
//    return NO;
}

- (BOOL)isAnswerImageURL:(ZMMediaGalleryModel *)msg {
    return msg.type == ZMMessageTypeKnowledgeAnswerMsgType;
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)gesture {
    UIScrollView *zoomScrollView = (UIScrollView *)gesture.view;
    
    if (zoomScrollView.zoomScale > zoomScrollView.minimumZoomScale) {
        [zoomScrollView setZoomScale:zoomScrollView.minimumZoomScale animated:YES];
    } else {
        CGPoint touchPoint = [gesture locationInView:zoomScrollView];
        CGFloat newZoomScale = zoomScrollView.maximumZoomScale;
        CGSize scrollViewSize = zoomScrollView.bounds.size;
        
        CGFloat w = scrollViewSize.width / newZoomScale;
        CGFloat h = scrollViewSize.height / newZoomScale;
        CGFloat x = touchPoint.x - (w / 2.0f);
        CGFloat y = touchPoint.y - (h / 2.0f);
        
        CGRect rectToZoomTo = CGRectMake(x, y, w, h);
        
        [zoomScrollView zoomToRect:rectToZoomTo animated:YES];
    }
}

// 添加更新下载按钮标题的方法
- (void)updateDownloadButtonTitle:(NSString *)title {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.downloadButton setTitle:title forState:UIControlStateNormal];
        
        if ([title hasPrefix:@"保存中"]) {
            [self.activityIndicator startAnimating];
        } else {
            [self.activityIndicator stopAnimating];
        }
        
        // 延迟一帧更新容器宽度，确保文字已经更新
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateDownloadContainerWidth];
        });
    });
}

// 添加更新容器宽度的方法
- (void)updateDownloadContainerWidth {
    @try {
        // 计算文字宽度
        CGFloat textWidth = [self.downloadButton.titleLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, kW(24))
                                                                            options:NSStringDrawingUsesLineFragmentOrigin
                                                                         attributes:@{NSFontAttributeName: self.downloadButton.titleLabel.font}
                                                                            context:nil].size.width;
        
        // 计算总宽度：左边距 + 文字宽度 + 间距 + 指示器宽度(如果显示) + 右边距
        CGFloat totalWidth = kW(12) + textWidth + kW(12);
        if (self.activityIndicator.isAnimating) {
            totalWidth += kW(8) + kW(20) + kW(12);
        }
        
        // 确保最小宽度
//        totalWidth = MAX(totalWidth, kW(80));
        
        // 更新容器宽度约束
        [self.downloadContainer mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(totalWidth);
        }];
        
        // 更新按钮宽度约束
//        [self.downloadButton mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.width.mas_equalTo(textWidth);
//        }];
        
        [self.downloadButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.downloadContainer).offset(kW(12));
            if(!self.activityIndicator.isAnimating)make.right.equalTo(self.downloadContainer).offset(-kW(12));
            make.centerY.equalTo(self.downloadContainer);
            make.height.mas_equalTo(kW(24));
        }];
        
        [self.downloadContainer setNeedsLayout];
        [self.downloadContainer layoutIfNeeded];
        
    } @catch (NSException *exception) {
        NSLog(@"Update download container width error: %@", exception);
    }
}

// 添加进度监听方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isKindOfClass:[NSURLSessionDownloadTask class]] && [keyPath isEqualToString:@"countOfBytesReceived"]) {
        NSURLSessionDownloadTask *task = (NSURLSessionDownloadTask *)object;
        float progress = (float)task.countOfBytesReceived / (float)task.countOfBytesExpectedToReceive;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *progressText = [NSString stringWithFormat:@"保存中%d%%", (int)(progress * 100)];
            [self updateDownloadButtonTitle:progress == 1 ? @"保存" : progressText];
        });
    }
}

// 在 dealloc 中移除观察者
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // 移除所有 KVO
    @try {
        [self.downloadButton removeObserver:self forKeyPath:@"countOfBytesReceived"];
    } @catch (NSException *exception) {
        // 忽略异常
    }
}

@end
