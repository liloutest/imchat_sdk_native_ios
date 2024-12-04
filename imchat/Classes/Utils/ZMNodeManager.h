//
//  ZMNodeManager.h
//  imchat
//
//  Created by Lilou on 2024/10/15.
//

#import <Foundation/Foundation.h>
@class ZMNodesModel;
NS_ASSUME_NONNULL_BEGIN

/**
 * ZMNodeManager is responsible for managing communication nodes.
 * It provides methods to retrieve HTTP, WebSocket, and resource server nodes,
 * and implements node selection strategy and health check functionality.
 */
@interface ZMNodeManager : NSObject

/**
 * Returns the shared instance of ZMNodeManager.
 */
+ (instancetype)sharedManager;

- (void)getBestNodes:(ActionBlock)httpBlock wsBlock:(ActionBlock)wsBlock ossBlock:(ActionBlock)ossBlock;

/**
 * Retrieves the best HTTP domain server node based on network conditions.
 *
 * @param completion A block to be executed when the node is retrieved. 
 *                   It receives the node URL as a string and an error if any occurred.
 */
- (void)getBestHTTPServerNode:(void (^)(NSString * _Nullable nodeURL, NSError * _Nullable error))completion;

/**
 * Retrieves the best WebSocket server node based on network conditions.
 *
 * @param completion A block to be executed when the node is retrieved. 
 *                   It receives the node URL as a string and an error if any occurred.
 */
- (void)getBestWebSocketServerNode:(void (^)(NSString * _Nullable nodeURL, NSError * _Nullable error))completion;

/**
 * Retrieves the best resource server node based on network conditions.
 *
 * @param completion A block to be executed when the node is retrieved. 
 *                   It receives the node URL as a string and an error if any occurred.
 */
- (void)getBestResourceServerNode:(void (^)(NSString * _Nullable nodeURL, NSError * _Nullable error))completion;

/**
 * Refreshes all server nodes from the remote configuration and performs health checks.
 *
 * @param completion A block to be executed when the refresh is complete.
 *                   It receives a boolean indicating success and an error if any occurred.
 */
- (void)refreshNodesFromServer:(void (^)(BOOL success,ZMNodesModel *nodeModel, NSError * _Nullable error))completion;

/**
 * Starts periodic health checks for all nodes.
 */
- (void)startPeriodicHealthChecks;

/**
 * Stops periodic health checks.
 */
- (void)stopPeriodicHealthChecks;

@end

NS_ASSUME_NONNULL_END
