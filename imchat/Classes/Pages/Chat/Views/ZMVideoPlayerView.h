//
//  ZMVideoPlayerView.h
//  imchat
//
//  Created by Lilou on 2024/10/22.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface ZMVideoPlayerView : UIView
@property (nonatomic, strong) AVPlayer *player;
//@property (nonatomic, copy) ActionBlock  dismissBlock;
- (void)playVideoWithURL:(NSURL *)url;
- (void)pauseVideo;
- (void)stopVideo;
- (void)dismiss;
@end

NS_ASSUME_NONNULL_END
