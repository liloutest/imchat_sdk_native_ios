//
//  ZMNodeManager.m
//  imchat
//
//  Created by Lilou on 2024/10/15.
//

#import "ZMNodeManager.h"
#import "ZMHttpHelper.h"
#import "ZMNetworkManager.h"
#import "ZMNodesModel.h"
#import "ZMWebSocketManager.h"
@interface ZMNodeManager ()

// Array of HTTP server node URLs
@property (nonatomic, strong) NSArray<NSString *> *httpServerNodes;

// Array of WebSocket server node URLs
@property (nonatomic, strong) NSArray<NSString *> *wsServerNodes;

// Array of resource server node URLs
@property (nonatomic, strong) NSArray<NSString *> *resourceServerNodes;

// Timestamp of the last node refresh
@property (nonatomic, strong) NSDate *lastRefreshTime;

// Timer for periodic health checks
@property (nonatomic, strong) NSTimer *healthCheckTimer;

// Dispatch queue for performing health checks
@property (nonatomic, strong) dispatch_queue_t healthCheckQueue;

@end

@implementation ZMNodeManager

+ (instancetype)sharedManager {
    static ZMNodeManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadNodesFromCache];
        self.healthCheckQueue = dispatch_queue_create("com.zmchat.healthcheck", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)loadNodesFromCache {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.httpServerNodes = [defaults arrayForKey:@"HTTPServerNodes"];
    self.wsServerNodes = [defaults arrayForKey:@"WSServerNodes"];
    self.resourceServerNodes = [defaults arrayForKey:@"ResourceServerNodes"];
    self.lastRefreshTime = [defaults objectForKey:@"LastNodeRefreshTime"];
}

- (void)saveNodesToCache {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.httpServerNodes forKey:@"HTTPServerNodes"];
    [defaults setObject:self.wsServerNodes forKey:@"WSServerNodes"];
    [defaults setObject:self.resourceServerNodes forKey:@"ResourceServerNodes"];
    [defaults setObject:self.lastRefreshTime forKey:@"LastNodeRefreshTime"];
    [defaults synchronize];
}

- (void)getBestNodes:(ActionBlock)httpBlock wsBlock:(ActionBlock)wsBlock ossBlock:(ActionBlock)ossBlock {
    __weak ZMNodeManager *weakSelf = self;
    [self ensureNodesAreUpToDate:^(BOOL success, ZMNodesModel *nodeModel, NSError * _Nullable error) {
        [weakSelf getBestHTTPServerNode:^(NSString * _Nullable nodeURL, NSError * _Nullable error) {
            if(!error){
                [ZMHttpHelper configureWithBaseURL:nodeURL];
                if(httpBlock){
                    httpBlock();
                }
            }
            
        }];
        
        [weakSelf getBestWebSocketServerNode:^(NSString * _Nullable nodeURL, NSError * _Nullable error) {
            if(!error){
                [[ZMWebSocketManager sharedManager] changeNodeUrl:nodeURL];
                if(wsBlock){
                    wsBlock();
                }
            }
        }];
        
        [weakSelf getBestResourceServerNode:^(NSString * _Nullable nodeURL, NSError * _Nullable error) {
            
            if(!error){
                [ZMHttpHelper configureWithBaseOssUrl:nodeURL];
                if(ossBlock){
                    ossBlock();
                }
            }
        }];
    }];
}

- (void)getBestHTTPServerNode:(void (^)(NSString * _Nullable nodeURL, NSError * _Nullable error))completion {
    
    [self selectBestNodeFromArray:self.httpServerNodes completion:completion];
    
//    [self ensureNodesAreUpToDate:^(BOOL success, NSString *bestUrl,NSError * _Nullable error) {
//        if (success) {
//            [self selectBestNodeFromArray:self.httpServerNodes completion:completion];
//        } else {
//            completion(nil, error);
//        }
//    }];
}

- (void)getBestWebSocketServerNode:(void (^)(NSString * _Nullable nodeURL, NSError * _Nullable error))completion {
    [self selectBestNodeFromArray:self.wsServerNodes completion:completion];
//    [self ensureNodesAreUpToDate:^(BOOL success, NSString *bestUrl, NSError * _Nullable error) {
//        if (success) {
//            [self selectBestNodeFromArray:self.wsServerNodes completion:completion];
//        } else {
//            completion(nil, error);
//        }
//    }];
}

- (void)getBestResourceServerNode:(void (^)(NSString * _Nullable nodeURL, NSError * _Nullable error))completion {
    [self selectBestNodeFromArray:self.resourceServerNodes completion:completion];
//    [self ensureNodesAreUpToDate:^(BOOL success, NSString *bestUrl,NSError * _Nullable error) {
//        if (success) {
//            [self selectBestNodeFromArray:self.resourceServerNodes completion:completion];
//        } else {
//            completion(nil, error);
//        }
//    }];
}

- (void)ensureNodesAreUpToDate:(void (^)(BOOL success, ZMNodesModel *nodeModel, NSError * _Nullable error))completion {
//    if ([self shouldRefreshNodes]) {
        [self refreshNodesFromServer:completion];
//    }
//    else {
//        completion(YES,  , nil);
//    }
}

- (BOOL)shouldRefreshNodes {
    return  YES;
//    return (!self.httpServerNodes || self.httpServerNodes.count == 0 ||
//            !self.wsServerNodes || self.wsServerNodes.count == 0 ||
//            !self.resourceServerNodes || self.resourceServerNodes.count == 0 ||
//            !self.lastRefreshTime || [[NSDate date] timeIntervalSinceDate:self.lastRefreshTime] > 3600);
}

- (void)refreshNodesFromServer:(void (^)(BOOL success, ZMNodesModel *nodeModel, NSError * _Nullable error))completion {
    // In a real implementation, you would make an API call to fetch the latest node configuration
    // For this example, we'll simulate an API call with a delay

    [[ZMNetworkManager sharedManager] postRequestWithURL:ZMApis.nodes params:@{@"role_type": @0,@"source":@1,@"identityID": [ZMMessageManager sharedInstance].identityID ?: @""} headers:nil success:^(id  _Nonnull responseObject) {
        NSLog(@"%@",responseObject);
        ZMNodesModel *model = [ZMNodesModel modelWithJSON:responseObject[@"data"]];
        self.httpServerNodes = model.rest;
        self.wsServerNodes = model.ws;
        self.resourceServerNodes = model.oss;
        
        if(completion){
            completion(YES,model, nil);
        }
//        self.lastRefreshTime = [NSDate date];
        
//        [self saveNodesToCache];
//        [self performHealthChecks:^(NSString *bestUrl) {
//            if(completion){
//                completion(YES,bestUrl, nil);
//            }
//        }];
        
        } failure:^(NSError * _Nonnull error) {
            NSLog(@"%@",error.description);
            if(completion){
                completion(NO, nil,error);
            }
        }];
    
//    [[ZMNetworkManager sharedManager] setCustomGlobalHeaders:@{@"lbe_sign": @"b184b8e64c5b0004c58b5a3c9af6f3868d63018737e68e2a1ccc61580afbc8f112119431511175252d169f0c64d9995e5de2339fdae5cbddda93b65ce305217700",@"Content-Type":@"application/json"}];
//    [[ZMNetworkManager sharedManager] postRequestWithURL:@"http://42nz10y3hhah.dreaminglife.cn:10002/api/trans/session" params:@{@"headIcon": @"12",@"extraInfo":@"12",@"nickId": @"121212",@"nickName":@"1212",@"uid": @"1212"} success:^(id  _Nonnull responseObject) {
//        NSLog(@"%@",responseObject);
//        } failure:^(NSError * _Nonnull error) {
//            NSLog(@"%@",error.description);
//        }];
    
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        // Simulated server response
//        NSDictionary *serverResponse = @{
//            @"http_nodes": @[@"https://api1.example.com", @"https://api2.example.com"],
//            @"ws_nodes": @[@"wss://ws1.example.com", @"wss://ws2.example.com"],
//            @"resource_nodes": @[@"https://res1.example.com", @"https://res2.example.com"]
//        };
//        
//        self.httpServerNodes = serverResponse[@"http_nodes"];
//        self.wsServerNodes = serverResponse[@"ws_nodes"];
//        self.resourceServerNodes = serverResponse[@"resource_nodes"];
//        self.lastRefreshTime = [NSDate date];
//        
//        [self saveNodesToCache];
//        [self performHealthChecks];
//        
//        completion(YES, nil);
//    });
}

- (void)selectBestNodeFromArray:(NSArray<NSString *> *)nodes completion:(void (^)(NSString * _Nullable nodeURL, NSError * _Nullable error))completion {
    dispatch_async(self.healthCheckQueue, ^{
        __block NSString *bestNode = nil;
        __block NSTimeInterval bestLatency = DBL_MAX;
        
        dispatch_group_t group = dispatch_group_create();
        
        for (NSString *node in nodes) {
            dispatch_group_enter(group);
            [self checkLatencyForNode:node completion:^(NSTimeInterval latency) {
                if (latency < bestLatency) {
                    bestLatency = latency;
                    bestNode = node;
                }
                dispatch_group_leave(group);
            }];
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            if (bestNode) {
                completion(bestNode, nil);
            } else {
                NSError *error = [NSError errorWithDomain:@"ZMNodeManagerErrorDomain" code:1001 userInfo:@{NSLocalizedDescriptionKey: @"No healthy nodes available"}];
                completion(nil, error);
            }
        });
    });
}

- (void)checkLatencyForNode:(NSString *)nodeURL completion:(void (^)(NSTimeInterval latency))completion {
    NSDate *startTime = [NSDate date];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", nodeURL]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSTimeInterval latency = [[NSDate date] timeIntervalSinceDate:startTime];
        if (error /*||  [(NSHTTPURLResponse *)response statusCode] != 200*/) {
            latency = DBL_MAX;
        }
        completion(latency);
    }];
    [task resume];
}

- (void)performHealthChecks:(void (^)(NSString *bestUrl))completion {
    dispatch_async(self.healthCheckQueue, ^{
        [self checkNodesHealth:self.httpServerNodes];
        [self checkNodesHealth:self.wsServerNodes];
        [self checkNodesHealth:self.resourceServerNodes];
    });
}

- (void)checkNodesHealth:(NSArray<NSString *> *)nodes {
    for (NSString *node in nodes) {
        [self checkLatencyForNode:node completion:^(NSTimeInterval latency) {
            if (latency == DBL_MAX) {
                NSLog(@"Node %@ is unhealthy", node);
                // Here you might want to implement logic to remove unhealthy nodes or mark them for later checks
            }
        }];
    }
}

- (void)startPeriodicHealthChecks {
    [self stopPeriodicHealthChecks];
    self.healthCheckTimer = [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(performHealthChecks) userInfo:nil repeats:YES];
}

- (void)stopPeriodicHealthChecks {
    [self.healthCheckTimer invalidate];
    self.healthCheckTimer = nil;
}

@end
