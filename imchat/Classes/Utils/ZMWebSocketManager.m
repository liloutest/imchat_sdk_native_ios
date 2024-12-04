//
//  ZMWebSocketManager.m
//  imchat
//
//  Created by Lilou on 2024/10/10.
//

#import "ZMWebSocketManager.h"
#import <SocketRocket/SocketRocket.h>
#import "AFNetworking/AFNetworkReachabilityManager.h"
#import "Constant.h"
#import "Msggateway.pbobjc.h"
//#import <AFNetworkActivityIndicatorManager.h>

// heaet duration
static int const kHeartbeatDuration = 10;
static int const kReconnectDuration = 3;
static NSString *kDefaultWebSocketUrl = @"ws://";

@interface ZMWebSocketManager ()<SRWebSocketDelegate>
@property (nonatomic,strong) SRWebSocket *socket;
@property (strong, nonatomic) NSTimer *heartBeatTimer;
@property (assign, nonatomic) NSTimeInterval reConnectTime;

@property (nonatomic,strong) NSString *serverIpString;

@property (nonatomic,assign) BOOL autoReconnect;
@end

@implementation ZMWebSocketManager

+ (instancetype)sharedManager {
    static ZMWebSocketManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
        [sharedManager addNotify];
    });
    return sharedManager;
}

//- (void)initWithServerIp:(NSString *)serverIp {
//    if (self = [super init]) {
//        if (!serverIp) {
//            self.serverIpString = kDefaultWebSocketUrl;
//        }else{
//            self.serverIpString = serverIp;
//        }
//        [self addNotify];
//
//    }
//    return self;
//}

#pragma mark - Public

- (void)changeNodeUrl:(NSString *)nodeUrl{
    if(_socket.readyState == SR_OPEN)return;
    if (!nodeUrl) {
        self.serverIpString = kDefaultWebSocketUrl;
    }else{
        self.serverIpString = nodeUrl;
    }
    
    
//    self.serverIpString = [NSString stringWithFormat:@"ws://42nz10y3hhah.dreaminglife.cn:10001"];
    
    [self disconnect];
    [self connectWebSocket];
}

- (void)connectWebSocket {
    self.autoReconnect = YES;
    [self initWebSocket];
}
- (void)disconnect {
    self.autoReconnect = NO;
    [self close];
}


- (BOOL)sendTextMessage:(NSString *)message {
    if (self.socket && self.socket.readyState == SR_OPEN) {
        // Messages can only be sent when the socket state is SR_OPEN
        // When the socket state is not SR_OPEN, messages can be queued and sent when the websocket connects
        return [self.socket sendString:message error:nil];
    }
    return NO;
}

- (BOOL)sendImage:(UIImage *)image {
    NSData *imageData = UIImagePNGRepresentation(image);
    return [self.socket sendData:imageData error:nil];
}

- (BOOL)sendVideoAtURL:(NSURL *)videoURL {
    NSData *videoData = [NSData dataWithContentsOfURL:videoURL];
    return [self.socket sendData:videoData error:nil];
}

- (BOOL)sendData:(NSData *)data{
    return [self.socket sendData:data error:nil];
}



#pragma mark - Private

#pragma mark - WebSocket
// Initialize WebSocket
- (void)initWebSocket{
    if (_socket) {
        return;
    }
    
    NSURL *url = [NSURL URLWithString:self.serverIpString];

//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    [request setValue:[ZMMessageManager sharedInstance].token forHTTPHeaderField:@"lbeToken"];
    [request setValue:[ZMMessageManager sharedInstance].sessionId forHTTPHeaderField:@"lbeSession"];
    NSLog(@"token = %@; sessiond = %@",[ZMMessageManager sharedInstance].token,[ZMMessageManager sharedInstance].sessionId);
    
    request.timeoutInterval = 10;
    // Initialize request
    _socket = [[SRWebSocket alloc] initWithURLRequest:request];
    _socket.delegate = self;
    // Connect directly
    [_socket open];
}


#pragma mark - Notification
- (void)addNotify {
    // Monitor network changes
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNetWorkStatusChanged) name:kZMNetworkStatusChangeNotification object:nil];
}

// Network status change
- (void)handleNetWorkStatusChanged {
    if(!self.socket)return;
    // Close websocket when network is disconnected
    if(![AFNetworkReachabilityManager sharedManager].reachable){
        [self close];
    }else{
        // Reconnect websocket when network is back online
        if ((self.socket.readyState == SR_OPEN || self.socket.readyState == SR_CONNECTING) && self.socket) {
            return;
        }
        [self reConnect];
    }
}

#pragma mark - Heart Timer
// Keep-alive mechanism - Heartbeat packet
- (void)startHeartbeat {
    [self destoryHeartbeat];
    self.heartBeatTimer = [NSTimer scheduledTimerWithTimeInterval:kHeartbeatDuration target:self selector:@selector(heartbeatAction) userInfo:nil repeats:YES];
    [self.heartBeatTimer setFireDate:[NSDate distantPast]];
    [[NSRunLoop currentRunLoop] addTimer:_heartBeatTimer forMode:NSRunLoopCommonModes];
}


// Destroy heartbeat when disconnecting
- (void)destoryHeartbeat{
    [self.heartBeatTimer invalidate];
    self.heartBeatTimer = nil;
}

// Send heartbeat
- (void)heartbeatAction {
    if (self.socket.readyState == SR_OPEN) {
        [self.socket sendPing:nil error:nil];
        NSLog(@"ZMWebSocket heartbeatAction");
    }
}


// Reconnection mechanism
- (void)reConnect{
    if (!self.autoReconnect) {
        return;
    }
    
    // Reconnection interval time, can be adjusted according to business needs
    if (_reConnectTime == 0) {
        _reConnectTime = kReconnectDuration;
    }
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_reConnectTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.socket = nil;
        [self initWebSocket];
//    });
}

// 重置重连时间
- (void)resetConnectTime {
    self.reConnectTime = kReconnectDuration;
}

// 关闭Socket
- (void)close {
    [self destoryHeartbeat];
    [self.socket close];
    self.socket = nil;
    [self resetConnectTime];
}

#pragma mark - SRWebSocketDelegate

- (void)webSocket:(SRWebSocket *)webSocket didReceivePingWithData:(nullable NSData *)data {
    // 底层代码实现了 收到PING 自动PONG
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(nullable NSData *)pongData {
    NSLog(@"ZMWebSocket Pong");
}

// Callback for receiving messages from the server
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message{
    NSLog(@"ZMWebSocket didReceiveMessage：%@",message);
    if ([message isKindOfClass:[NSString class]]) {
        NSString *msg = (NSString *)message;
        if ([self.delegate respondsToSelector:@selector(webSocketDidReceiveMessage:)]) {
            [self.delegate webSocketDidReceiveMessage:msg];
        }
    }
    else if ([message isKindOfClass:[NSData class]]){
        // Binary message (images, videos, etc.)
        // Deserialization
        NSError *error = nil;
        // 想办办法处理下c++ 异常
        @try{
            MsgEntityToFrontEnd *receivedMsg = [MsgEntityToFrontEnd parseFromData:message error:&error];
            if (error) {
                NSLog(@"Error parsing: %@", error);
            } else {
                if([receivedMsg.msgBody.receiverUid isEqualToString:@"222"])return;
                NSDictionary *dict = [receivedMsg yy_modelToJSONObject];
                ZMMessage *msg = [ZMMessage modelWithJSON:dict];
                
                switch (msg.msgType) {
                    case ZMMessageTypeHasReadReceiptMsgType: // as read
                    {
                        // 将本地所有该用户该会话的消息置为已读
                        [[ZMMessageManager sharedInstance] updateAllMsgRead];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kZMMessageDidChangeNotification object:nil];
                    }
                        break;
                    case ZMMessageTypeKickOffLineMsgType:
                    {
                        [self disconnect];
                    }
                        break;
                    case ZMMessageTypeJoinServer: // join session
                    {
                        
                    }
                        break;
                    case ZMMessageTypeCreateSessionMsgType: // Create Session
                    {
                        
                    }
                        break;
                    case ZMMessageTypeAgentUserJoinSessionMsgType: // Agent User Join
                    {
                        
                    }
                        break;
                    case ZMMessageTypeEndSessionMsgType: // end session
                    {
                        
                    }
                        break;
                    case ZMMessageTypeFaqMsgType: // Faq
                    {
                        // fallthroght
                    }
                        
                    case ZMMessageTypeKnowledgePointMsgType: // Knowledge Point
                    {
                        // fallthroght
                    }
                        
                    case ZMMessageTypeKnowledgeAnswerMsgType: // Knowledge Answer
                    {
                        // fallthroght
                    }
                        
                    default:
                    {
                    
//                        msg.msgBody.msgBody= @"[{\"type\":0,\"content\":\"文本...\"},{\"type\":1,\"content\":\"{\\\"key\\\":\\\"v1:lbe9fe27355d728f1f9c34f79feaa\\\",\\\"url\\\":\\\"http://10.40.92.203:9910/openimttt/lbe_c4e1f208d7075abe2a55fd203811ca.jpg\\\"}\",\"width\":1920,\"height\":1080},{\"type\":2,\"contents\":[{\"content\":\"详细请\\n自行\",\"url\":\"http://www.baidu.com\"},{\"content\":\"Google\",\"url\":\"https://google.com\"},{\"content\":\"吧\",\"url\":\"\"}]},{\"type\":0,\"content\":\"文本...\"},{\"type\":1,\"content\":\"{\\\"key\\\":\\\"v1:lbe9fe27355d728f1f9c34f79feaa\\\",\\\"url\\\":\\\"http://10.40.92.203:9910/openimttt/lbe_c4e1f208d7075abe2a55fd203811ca.jpg\\\"}\",\"width\":1920,\"height\":1080}]";
                        msg.sessionId = [ZMMessageManager sharedInstance].sessionId;
                        msg.createTime = msg.msgBody.createTime;
                        msg.msgType = msg.msgBody.msgType;
                        msg.sendTimeStamp = msg.msgBody.sendTimeStamp;
                        msg.msgBody.clientMsgId = receivedMsg.msgBody.clientMsgId;
//                        if(msg.msgBody.sendTime == 0){
//                            msg.msgBody.sendTimeStamp = msg.createTime;
//                            msg.sendTimeStamp = msg.createTime;
//                        }
                        msg.msgBody.sessionId = msg.sessionId;
                        [[ZMMessageManager sharedInstance] updateAllMsgRead];
                        [[ZMMessageManager sharedInstance] addMessage:msg];
                        
                        // 更新超时提醒时间
                        [[ZMMessageManager sharedInstance] resetTimeoutTimer];
                    }
                        break;
                }
            }
        } @catch(NSException *e) {
            NSLog(@"%@",e.description);
        }
        
    }
}

// Connection successful
- (void)webSocketDidOpen:(SRWebSocket *)webSocket{
    NSLog(@"ZMWebSocket DidOpen");
//    [self resetConnectTime];
    [self startHeartbeat];
    
    // The following logic should be handled according to business requirements
    if (self.socket != nil) {
        // Only when the socket is in SR_OPEN state can we call the send method
        if (_socket.readyState == SR_OPEN) {
//            NSString *jsonString = @"{\"sid\": \"13b313a3-fea9-4e28-9e56-352458f7007f\"}";
//            [_socket sendString:jsonString error:nil];  //发送数据包
//            MsgEntity *entity = [MsgEntity new];
//            MsgType *type = [MsgType new];
//            type.messageType = 1;
//            entity.msgType = type;
//            Join *join = [Join new];
//            join.uid = @"我是一个uid";
//            entity.join = join;
//            TalkText *tt = [TalkText new];
//            tt.uid = @"123";
//            tt.content = @"hello im";
//            entity.talkText = tt;
//           NSLog(@"连接发送状态: %d", [self sendData:[entity data]]);
            NSLog(@"didopen");
            // 一个会话连上后调用faq 接口，后端处理了只会发一次
            [ZMHttpHelper getFaq:ZMMessageGetFaqTypeGetFaq faqId:@"" headers:nil success:^(NSDictionary *response) {
                NSLog(@"faq");
            } failure:^(NSError *error) {
                
            }];
        } else if (_socket.readyState == SR_CONNECTING) {
            NSLog(@"正在连接中，重连后其他方法会去自动同步数据");
            // 每隔2秒检测一次 socket.readyState 状态，检测 10 次左右
            // 只要有一次状态是 SR_OPEN 的就调用 [ws.socket send:data] 发送数据
            // 如果 10 次都还是没连上的，那这个发送请求就丢失了，这种情况是服务器的问题了，小概率的
            // 代码有点长，我就写个逻辑在这里好了
            // TODO
        } else if (_socket.readyState == SR_CLOSING || _socket.readyState == SR_CLOSED) {
            // websocket 断开了，调用 reConnect 方法重连
            [self reConnect];
        }
    }
}


// Callback for connection failure
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error{
    NSLog(@"ZMWebSocket didFailWithError %@",error);
    // 1.判断当前网络环境，如果断网了就不要连了，等待网络到来，在发起重连
    // 2.判断调用层是否需要连接，例如用户都没在聊天界面，连接上去浪费流量
    
    if (error.code == 50 || ![AFNetworkReachabilityManager sharedManager].reachable) {
        // Do not reconnect due to network exception
        return;
    }
    [self reConnect];
}

// 连接断开的回调
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean{
    NSLog(@"ZMWebSocket Close code %ld reason %@",(long)code,reason);
    // Automatically reconnect when the connection is closed
    // Whether to reconnect can be handled according to specific business requirements
    if (![AFNetworkReachabilityManager sharedManager].reachable) {
        return;
    }
    [self reConnect];
}


#pragma mark - Other
- (void)dealloc {
    NSLog(@"ZM: dealloc: %@", self);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
