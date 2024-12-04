#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,ZMMediaLoadingType) {
    ZMMediaLoadingTypePlay,
    ZMMediaLoadingTypeCircleProgress,
    ZMMediaLoadingTypeUploadPause,
    ZMMediaLoadingTypeUploadFail
};

@interface ZMMediaLoadingView : UIView

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) BOOL isCircular;
@property (nonatomic, assign) CGFloat blurAlpha;
@property (nonatomic, assign) ZMMediaLoadingType type;
@property (nonatomic, copy) ActionBlock pauseBlock;
@property (nonatomic, copy) ActionBlock resumeBlock;
@property (nonatomic, copy) ActionBlock failBlock;
- (instancetype)initWithType:(ZMMediaLoadingType)type;
- (void)startAnimating;
- (void)stopAnimating;
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;
- (void)setBlurAlpha:(CGFloat)alpha;

@end

NS_ASSUME_NONNULL_END
