#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ZMMediaGalleryView;

@protocol ZMMediaGalleryViewDelegate <NSObject>

- (void)mediaGalleryViewDidDismiss:(ZMMediaGalleryView *)galleryView;
- (void)mediaGalleryView:(ZMMediaGalleryView *)galleryView didTapDownloadForItemAtIndex:(NSInteger)index;
- (void)mediaGalleryView:(ZMMediaGalleryView *)galleryView didSaveMediaToAlbumAtIndex:(NSInteger)index withError:(NSError *)error;

@end

@interface ZMMediaGalleryView : UIView

@property (nonatomic, weak) id<ZMMediaGalleryViewDelegate> delegate;

//- (instancetype)initWithMediaURLs:(NSArray<NSString *> *)mediaURLs;
//- (instancetype)initWithMediaMsgs:(NSArray<ZMMessage *> *)mediaMsgs currentMsg:(ZMMessage *)currentMsg;
- (instancetype)initWithMediaMsgs:(NSArray<ZMMessage *> *)mediaMsgs currentMsg:(ZMMessage *)currentMsg imgContentIndex:(NSInteger)imgContentIndex;
- (void)showInView:(UIView *)view;
- (void)dismissWithAnimation;

@end

NS_ASSUME_NONNULL_END
