//
//  ZMWebSocketManager.h
//  imchat
//
//  Created by Lilou on 2024/10/10.
//

#import <Foundation/Foundation.h>
#import <SocketRocket/SocketRocket.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 @brief Socket Message Type
 */
typedef NS_ENUM(NSInteger, ZMSocketMessageType) {
    // Text Message
    SocketMessageTypeText,
    // Picture Message
    SocketMessageTypeImage,
    // Video Message
    SocketMessageTypeVideo
};

/**
 @brief Socket message protocol
 */
@protocol ZMWebSocketDelegate <NSObject>
/**
 * Received Message
 */
@optional
- (void)webSocketDidReceiveMessage:(NSString *)message;
///**
// * Called when the WebSocket connection is opened.
// */
//- (void)webSocketDidOpen;
//
///**
// * Called when the WebSocket connection is closed.
// * @param code The close code.
// * @param reason The reason for closing.
// * @param wasClean Whether the connection closed cleanly.
// */
//- (void)webSocketDidCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
//
///**
// * Called when an error occurs on the WebSocket.
// * @param error The error that occurred.
// */
//- (void)webSocketDidFailWithError:(NSError *)error;
@end

/**
 @brief Socket message Manager
 */
@interface ZMWebSocketManager : NSObject
@property (nonatomic,weak) id <ZMWebSocketDelegate> delegate;

+ (instancetype)sharedManager;

/// Initialize socket connection
//- (instancetype)initWithServerIp:(NSString *)serverIp;

- (void)changeNodeUrl:(NSString *)nodeUrl;

/// Connecting to a socket
- (void)connectWebSocket;
- (void)disconnect;

- (BOOL)sendTextMessage:(NSString *)message;
- (BOOL)sendImage:(UIImage *)image;
- (BOOL)sendVideoAtURL:(NSURL *)videoURL;
- (BOOL)sendData:(NSData *)data;
@end

NS_ASSUME_NONNULL_END
