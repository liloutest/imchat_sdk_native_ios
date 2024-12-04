//
//  ZMVideoPlayerView.m
//  imchat
//
//  Created by Lilou on 2024/10/22.
//

#import "ZMVideoPlayerView.h"
#import <objc/runtime.h>
@interface ZMVideoPlayerView ()
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) NSTimer *playbackTimer;
@property (nonatomic, strong) UISlider *progressSlider;  // 进度条
@property (nonatomic, strong) UIButton *playbackRateButton;  // 倍速按钮
@property (nonatomic, strong) UIButton *playPauseButton;  // 播放/暂停按钮
@property (nonatomic, assign) float currentPlaybackRate;  // 当前播放速度
@property (nonatomic, strong) UILabel *timeLabel;    // 时间标签
@property (nonatomic, strong) UIView *controlView;        // 控制器背景视图
@property (nonatomic, strong) UIButton *playButton;  // 中央播放按钮
@end

@implementation ZMVideoPlayerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupPlayerLayer];
        [self setupUI];
    }
    return self;
}

- (void)setupPlayerLayer {
    // 创建 AVPlayerLayer
    self.playerLayer = [AVPlayerLayer layer];
    self.playerLayer.frame = self.bounds;
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect; // 应视频比例
    self.playerLayer.contentsScale = [UIScreen mainScreen].scale; // 适应屏幕缩放
    
    [self.layer addSublayer:self.playerLayer];
}

- (void)setupUI {
    // 添加点击手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:tapGesture];
    
    // 控制器背景视图 - 半透明黑色背景
    self.controlView = [[UIView alloc] init];
    [self addSubview:self.controlView];
    
    // 初始化进度条
    self.progressSlider = [[UISlider alloc] init];
    self.progressSlider.minimumTrackTintColor = [UIColor whiteColor];  // 已播放部分为白色
    self.progressSlider.maximumTrackTintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];  // 未播放部分为半透明白色
    [self.progressSlider setThumbImage:[self createSliderThumbImage] forState:UIControlStateNormal];
    // 添加这些代码来自定义轨道高度
    CGRect trackRect = CGRectMake(0, 0, 100, kW(2));
    UIImage *minTrackImage = [ZMCommon createImageWithColor:[UIColor whiteColor] size:trackRect.size];
    UIImage *maxTrackImage = [ZMCommon createImageWithColor:[[UIColor whiteColor] colorWithAlphaComponent:0.3] size:trackRect.size];
    
    [self.progressSlider setMinimumTrackImage:minTrackImage forState:UIControlStateNormal];
    [self.progressSlider setMaximumTrackImage:maxTrackImage forState:UIControlStateNormal];
    [self.progressSlider addTarget:self action:@selector(sliderValueChanging:forEvent:) forControlEvents:UIControlEventValueChanged | UIControlEventTouchDragInside];
    [self.progressSlider addTarget:self action:@selector(sliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
    [self.progressSlider addTarget:self action:@selector(sliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
    [self.controlView addSubview:self.progressSlider];
    
    // 时间标签
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.font = ZMFontRes.font_10;
    self.timeLabel.text = @"0:00/1:00";
    [self.controlView addSubview:self.timeLabel];
    
    // 倍速按钮
    self.playbackRateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playbackRateButton setTitle:@"倍速" forState:UIControlStateNormal];
    [self.playbackRateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.playbackRateButton.titleLabel.font =  ZMFontRes.font_10;
    self.playbackRateButton.layer.masksToBounds = YES;
    [self.playbackRateButton addTarget:self action:@selector(changePlaybackRate) forControlEvents:UIControlEventTouchUpInside];
    self.currentPlaybackRate = 1.0;
    [self.controlView addSubview:self.playbackRateButton];
    
    // 创建毛玻璃效果视图
//    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
//    blurEffectView.layer.cornerRadius = kW(27);
//    blurEffectView.layer.masksToBounds = YES;
    
    UIView *blurEffectView = [UIView new];
    blurEffectView.layer.cornerRadius = kW(27);
    blurEffectView.layer.masksToBounds = YES;
    blurEffectView.layer.borderWidth = 1;
    blurEffectView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    UIView *dimmedView = [[UIView alloc] init];
    dimmedView.backgroundColor = [UIColor blackColor];
    dimmedView.alpha = 0.4; // 调整这个值来改变透明度效果
    dimmedView.clipsToBounds = YES;
    dimmedView.layer.masksToBounds = YES;
    [blurEffectView addSubview:dimmedView];
    dimmedView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // 初始化播放按钮
    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playButton setImage:[UIImage zm_imageWithName:ZMImageRes.chatVideoPlayBig] forState:UIControlStateNormal];
    self.playButton.layer.cornerRadius = kW(27);
    self.playButton.layer.masksToBounds = YES;
    [self.playButton addTarget:self action:@selector(playButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    // 添加毛玻璃效果和按钮
    [self addSubview:blurEffectView];
    [blurEffectView addSubview:self.playButton];
    
    // 设置约束
    blurEffectView.translatesAutoresizingMaskIntoConstraints = NO;
    self.playButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        // 毛玻璃效果视图约束
        [blurEffectView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [blurEffectView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [blurEffectView.widthAnchor constraintEqualToConstant:kW(55)],
        [blurEffectView.heightAnchor constraintEqualToConstant:kW(55)],
        
        [dimmedView.topAnchor constraintEqualToAnchor:blurEffectView.topAnchor],
            [dimmedView.leadingAnchor constraintEqualToAnchor:blurEffectView.leadingAnchor],
            [dimmedView.trailingAnchor constraintEqualToAnchor:blurEffectView.trailingAnchor],
            [dimmedView.bottomAnchor constraintEqualToAnchor:blurEffectView.bottomAnchor],
        
        // 播放按钮约束 - 填充毛玻璃效果视图
        [self.playButton.topAnchor constraintEqualToAnchor:blurEffectView.topAnchor],
        [self.playButton.leadingAnchor constraintEqualToAnchor:blurEffectView.leadingAnchor],
        [self.playButton.trailingAnchor constraintEqualToAnchor:blurEffectView.trailingAnchor],
        [self.playButton.bottomAnchor constraintEqualToAnchor:blurEffectView.bottomAnchor]
    ]];
    
    // 保存毛玻璃效果视图的引用，用于动画
    objc_setAssociatedObject(self.playButton, "blurEffectView", blurEffectView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // 设置约束
    self.controlView.translatesAutoresizingMaskIntoConstraints = NO;
    self.progressSlider.translatesAutoresizingMaskIntoConstraints = NO;
    self.timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.playbackRateButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        // 控制器背景视图
        [self.controlView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:kW(16)],
        [self.controlView.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-kW(16)],
        [self.controlView.bottomAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.bottomAnchor constant:-kW(60)],
        [self.controlView.heightAnchor constraintEqualToConstant:kW(44)],
        
        
        // 进度条
        [self.progressSlider.leftAnchor constraintEqualToAnchor:self.controlView.leftAnchor],
        [self.progressSlider.centerYAnchor constraintEqualToAnchor:self.controlView.centerYAnchor],
        [self.progressSlider.rightAnchor constraintEqualToAnchor:self.controlView.rightAnchor],
        [self.progressSlider.heightAnchor constraintEqualToConstant:kW(2)],
        // 时间标签
        [self.timeLabel.leftAnchor constraintEqualToAnchor:self.controlView.leftAnchor],
        [self.timeLabel.bottomAnchor constraintEqualToAnchor:self.progressSlider.topAnchor constant:-kW(5)],
        
        // 倍速按钮
        [self.playbackRateButton.rightAnchor constraintEqualToAnchor:self.controlView.rightAnchor],
        [self.playbackRateButton.centerYAnchor constraintEqualToAnchor:self.timeLabel.centerYAnchor],
//        [self.playbackRateButton.widthAnchor constraintEqualToConstant:45],
//        [self.playbackRateButton.heightAnchor constraintEqualToConstant:24]
    ]];
}

// 添加创建滑块图片的方法
- (UIImage *)createSliderThumbImage {
    CGRect rect = CGRectMake(0, 0, kW(10), kW(10));
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:rect];
    [[UIColor whiteColor] setFill];
    [circlePath fill];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

// 播放视频
- (void)playVideoWithURL:(NSURL *)url {
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    self.playerLayer.player = self.player;
    
    // 加播放完成通知监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(playerDidFinishPlaying:)
                                               name:AVPlayerItemDidPlayToEndTimeNotification
                                             object:playerItem];
    
    [self.player play];
    [self hidePlayButton];  // 开始播放时隐藏按钮
    
    _playbackTimer = [NSTimer timerWithTimeInterval:0.05
                                           target:self
                                         selector:@selector(updatePlaybackTime)
                                         userInfo:nil
                                          repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_playbackTimer forMode:NSRunLoopCommonModes];
    
    // 添加视频时长监听
    [self.player.currentItem addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionNew context:nil];
}

// 暂停视频
- (void)pauseVideo {
    [self.player pause];
    [self showPlayButton];  // 暂停时显示按钮
}

// 停止视频
- (void)stopVideo {
    [self.player pause];
    [self.player seekToTime:kCMTimeZero]; // 回到视频开头
    [self showPlayButton];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // 更新 AVPlayerLayer 的框架
    self.playerLayer.frame = self.bounds;
}
    
- (void)playerDidFinishPlaying:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 停止计时器
        [self.playbackTimer invalidate];
        self.playbackTimer = nil;
        
        // 回到视频开头
        [self.player seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            if (finished) {
                // 更新进度条到开始位置
                self.progressSlider.value = 0.0;
                
                // 更新时间显示为开始状态
                CMTime duration = self.player.currentItem.duration;
                float totalSeconds = CMTimeGetSeconds(duration);
                if (!isnan(totalSeconds) && totalSeconds > 0) {
                    NSString *totalTimeStr = [self formatTimeInterval:totalSeconds];
                    self.timeLabel.text = [NSString stringWithFormat:@"0:00/%@", totalTimeStr];
                }
                
                // 显示播放按钮
                [self showPlayButton];
            }
        }];
    });
}


- (void)updatePlaybackTime {
    if (!self.player.currentItem) return;
    
    CMTime currentTime = self.player.currentTime;
    CMTime duration = self.player.currentItem.duration;
    
    float currentSeconds = CMTimeGetSeconds(currentTime);
    float totalSeconds = CMTimeGetSeconds(duration);
    
    // 确保时间值有效
    if (isnan(currentSeconds) || isnan(totalSeconds) || totalSeconds <= 0) return;
    
    // 处理时间，确保精确性
    currentSeconds = MAX(0, MIN(currentSeconds, totalSeconds));
    
    // 计算进度值
    float progress = currentSeconds / totalSeconds;
    progress = MAX(0, MIN(1, progress));
    
    // 更新时间标签和进度条
    dispatch_async(dispatch_get_main_queue(), ^{
        // 更新时间标签
        NSString *currentTimeStr = [self formatTimeInterval:currentSeconds];
        NSString *totalTimeStr = [self formatTimeInterval:totalSeconds];
        self.timeLabel.text = [NSString stringWithFormat:@"%@/%@", currentTimeStr, totalTimeStr];
        
        // 只在非拖动状态下更新进度条
        if (!self.progressSlider.isTracking) {
            self.progressSlider.value = progress;
        }
        
        // 如果播放接近结束，确保进度条到达终点
        if (totalSeconds - currentSeconds < 0.1) {
            self.progressSlider.value = 1.0;
        }
    });
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = self.player.currentItem.status;
        if (status == AVPlayerItemStatusReadyToPlay) {
            NSLog(@"视频准备播放");
        } else if (status == AVPlayerItemStatusFailed) {
            NSLog(@"视频加载失败: %@, %@", self.player.currentItem.error,self.player.currentItem.error.localizedDescription);
        }
    } else if ([keyPath isEqualToString:@"duration"]) {
        CMTime duration = self.player.currentItem.duration;
        float totalSeconds = CMTimeGetSeconds(duration);
        if (totalSeconds > 0) {
            self.progressSlider.minimumValue = 0.0;
            self.progressSlider.maximumValue = 1.0;
            self.progressSlider.value = 0.0;
        }
    }
}

- (void)dismiss {
    [self cleanRes];
}

- (void)cleanRes {
    [self stopVideo];
    [self.playbackTimer invalidate];
    self.playbackTimer = nil;
    
    if (self.player.currentItem) {
        @try {
            [self.player.currentItem removeObserver:self forKeyPath:@"duration"];
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                          name:AVPlayerItemDidPlayToEndTimeNotification
                                                        object:self.player.currentItem];
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
    }
}

- (void)dealloc {
    [self cleanRes];
}

- (void)sliderValueChanging:(UISlider *)slider forEvent:(UIEvent *)event {
    if (!self.player.currentItem) return;
    
    CMTime duration = self.player.currentItem.duration;
    float totalSeconds = CMTimeGetSeconds(duration);
    
    if (isnan(totalSeconds) || totalSeconds <= 0) return;
    
    // 计算当前时间，确保精确性
    float currentSeconds = totalSeconds * slider.value;
    currentSeconds = floor(currentSeconds);
    currentSeconds = MAX(0, MIN(currentSeconds, totalSeconds));
    
    // 更新时间标签
    NSString *currentTimeStr = [self formatTimeInterval:currentSeconds];
    NSString *totalTimeStr = [self formatTimeInterval:totalSeconds];
    self.timeLabel.text = [NSString stringWithFormat:@"%@/%@", currentTimeStr, totalTimeStr];
    
    // 实时预览位置
    CMTime previewTime = CMTimeMakeWithSeconds(currentSeconds, NSEC_PER_SEC);
    [self.player seekToTime:previewTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    
    // 确保播放按钮保持隐藏状态
    [self hidePlayButton];
}

- (void)sliderTouchBegan:(UISlider *)slider {
    // 开始拖动时暂停视频和计时器
    [self.player pause];
    [self.playbackTimer invalidate];
    self.playbackTimer = nil;
    
    // 隐藏播放按钮
    [self hidePlayButton];
}

- (void)sliderTouchEnded:(UISlider *)slider {
    if (!self.player.currentItem) return;
    
    CMTime duration = self.player.currentItem.duration;
    float totalSeconds = CMTimeGetSeconds(duration);
    
    if (isnan(totalSeconds) || totalSeconds <= 0) return;
    
    float seekSeconds = totalSeconds * slider.value;
    seekSeconds = floor(seekSeconds);
    seekSeconds = MAX(0, MIN(seekSeconds, totalSeconds));
    
    CMTime seekTime = CMTimeMakeWithSeconds(seekSeconds, NSEC_PER_SEC);
    
    __weak typeof(self) weakSelf = self;
    [self.player seekToTime:seekTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        if (finished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf updatePlaybackTime];
                [weakSelf.player play];
                
                // 重新启动计时器
                [weakSelf.playbackTimer invalidate];
                weakSelf.playbackTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                                        target:weakSelf
                                                                      selector:@selector(updatePlaybackTime)
                                                                      userInfo:nil
                                                                       repeats:YES];
                [[NSRunLoop mainRunLoop] addTimer:weakSelf.playbackTimer forMode:NSRunLoopCommonModes];
                
                // 保持播放按钮隐藏状态
                [weakSelf hidePlayButton];
            });
        }
    }];
}

- (void)changePlaybackRate {
    float rates[] = {0.5, 1.0, 1.5, 2.0};
    NSString *rateTexts[] = {@"0.5倍速", @"1倍速", @"1.5倍速", @"2倍速"};
    static int currentIndex = 0;
    
    // 获取当前倍速的索引
    for (int i = 0; i < 4; i++) {
        if (fabs(self.currentPlaybackRate - rates[i]) < 0.1) {
            currentIndex = i;
            break;
        }
    }
    
    // 切换到下一个倍速
    currentIndex = (currentIndex + 1) % 4;
    
    self.currentPlaybackRate = rates[currentIndex];
    [self.playbackRateButton setTitle:rateTexts[currentIndex] forState:UIControlStateNormal];
    self.player.rate = self.currentPlaybackRate;
}

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    if (self.player.rate > 0) {
        [self pauseVideo];
    } else {
        [self.player play];
        [self hidePlayButton];
    }
}

// 添加时间格式化方法，确保更精确的显示
- (NSString *)formatTimeInterval:(float)seconds {
    int minutes = (int)floor(seconds) / 60;
    int remainingSeconds = (int)floor(seconds) % 60;
    return [NSString stringWithFormat:@"%d:%02d", minutes, remainingSeconds];
}

// 添加播放按钮点击方法
- (void)playButtonTapped {
    // 如果视频已经播放完成（当前时间接近总时长），则从头开始播放
    CMTime currentTime = self.player.currentTime;
    CMTime duration = self.player.currentItem.duration;
    float currentSeconds = CMTimeGetSeconds(currentTime);
    float totalSeconds = CMTimeGetSeconds(duration);
    
    if (!isnan(currentSeconds) && !isnan(totalSeconds) && 
        (currentSeconds >= totalSeconds || currentSeconds <= 0)) {
        // 重置到开始位置
        [self.player seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            if (finished) {
                // 更新时间显示
                self.timeLabel.text = [NSString stringWithFormat:@"0:00/%@", 
                                     [self formatTimeInterval:totalSeconds]];
                self.progressSlider.value = 0.0;
                [self.player play];
                [self hidePlayButton];
                
                // 重新启动计时器
                [self.playbackTimer invalidate];
                self.playbackTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                                    target:self
                                                                  selector:@selector(updatePlaybackTime)
                                                                  userInfo:nil
                                                                   repeats:YES];
                [[NSRunLoop mainRunLoop] addTimer:self.playbackTimer forMode:NSRunLoopCommonModes];
            }
        }];
    } else {
        // 正常播放
        [self.player play];
        [self hidePlayButton];
    }
}

// 修改显示/隐藏播放按钮的方法
- (void)showPlayButton {
    UIVisualEffectView *blurEffectView = objc_getAssociatedObject(self.playButton, "blurEffectView");
    [UIView animateWithDuration:0.2 animations:^{
        self.playButton.alpha = 1.0;
        blurEffectView.alpha = 1.0;
    }];
}

- (void)hidePlayButton {
    UIVisualEffectView *blurEffectView = objc_getAssociatedObject(self.playButton, "blurEffectView");
    [UIView animateWithDuration:0.2 animations:^{
        self.playButton.alpha = 0.0;
        blurEffectView.alpha = 0.0;
    }];
}

@end
