//
//  CloudHubManager.m
//  YSLiveSample
//
//  Created by jiang deng on 2020/9/6.
//  Copyright © 2020 yunshuxunlian. All rights reserved.
//

#import "CloudHubManager.h"
#import "JsonTool.h"

static CloudHubManager *cloudHubManagerSingleton = nil;

/// 房间ID
NSString *const CHJoinRoomParamsRoomIDKey       = @"serial";
/// 房间密码
NSString *const CHJoinRoomParamsPasswordKey     = @"password";
/// 用户ID
NSString *const CHJoinRoomParamsUserIDKey       = @"userid";
/// 用户昵称
NSString *const CHJoinRoomParamsNickNameKey     = @"nickname";

/// server
NSString *const CHJoinRoomParamsServerKey       = @"server";
/// 客户端类型
NSString *const CHJoinRoomParamsClientTypeKey   = @"clientType";

///// port
NSString *const CHJoinRoomParamsPortKey         = @"port";
///// secure
NSString *const CHJoinRoomParamsSecureKey       = @"secure";


#define CloudHubManager_DefaultApiHost     @"api.roadofcloud.net"
#define CloudHubManager_DefaultApiPort     (443)

@interface CloudHubManager ()
<
    CloudHubRtcEngineDelegate,
    CHWhiteBoardManagerDelegate
>
{
    /// 是否重连
    BOOL isReconnect;
    NSUInteger joinCount;
}

/// 音视频SDK干管理
@property (nonatomic, strong) CloudHubRtcEngineKit *cloudHubRtcEngineKit;
/// appId
@property (nonatomic, strong) NSString *appId;

/// 房间相关消息回调
@property (nonatomic, weak) id <CloudHubManagerDelegate> delegate;

/// 当前用户数据
@property (nonatomic, strong) CHRoomUser *localUser;

@property (nonatomic, strong) NSString *webServerHost;
@property (nonatomic, assign) int webServerPort;

/// 服务器地址
@property (nonatomic, strong) NSString *currentServer;

@property (nonatomic, strong) NSArray *serverList;

#pragma mark - 白板

@property (nonatomic, weak) id <CHWhiteBoardManagerDelegate> whiteBoardDelegate;
/// 白板管理
@property (nonatomic, strong) CHWhiteBoardSDKManager *whiteBoardManager;
/// 白板视图whiteBord
@property (nonatomic, weak) UIView *whiteBordView;

/// 课件列表
@property (nonatomic, strong) NSArray <CHFileModel *> *fileList;
/// 当前课件数据
@property (nonatomic, strong) CHFileModel *currentFile;

@end

@implementation CloudHubManager

- (void)dealloc
{
}

+ (void)destroy
{
    if (cloudHubManagerSingleton)
    {
        cloudHubManagerSingleton.cloudHubRtcEngineKit = nil;
    }
    
    cloudHubManagerSingleton = nil;
}

+ (instancetype)sharedInstance
{
    if (cloudHubManagerSingleton)
    {
        return cloudHubManagerSingleton;
    }
    else
    {
        cloudHubManagerSingleton = [[[self class] alloc] init];
    }
    
    return cloudHubManagerSingleton;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self initializeManager];
    }
    return self;
}

- (void)initializeManager
{
    self.appId = @"";
    
    self.apiHost = CloudHubManager_DefaultApiHost;
    self.apiPort = CloudHubManager_DefaultApiPort;
    
    joinCount = 0;
}

- (BOOL)joinRoomWithHost:(NSString *)host port:(int)port nickName:(NSString *)nickName roomId:(NSString *)roomId roomPassword:(NSString *)roomPassword userId:(NSString *)userId
{
    NSString *server = @"global";
    if ([CHSessionUtil isDomain:host] == YES)
    {
        NSArray *array = [host componentsSeparatedByString:@"."];
        server = [NSString stringWithFormat:@"%@", array[0]];
    }
    
    NSMutableDictionary *parameters = @{
        CHJoinRoomParamsRoomIDKey : roomId,
        CHJoinRoomParamsServerKey : server,
        CHJoinRoomParamsClientTypeKey : @(3)
    }.mutableCopy;
    
    if (roomPassword)
    {
        [parameters setObject:roomPassword forKey:CHJoinRoomParamsPasswordKey];
    }
    
    if (userId)
    {
        [parameters setObject:userId forKey:CHJoinRoomParamsUserIDKey];
    }
    
    return [self joinRoomWithHost:host port:port nickName:nickName roomParams:parameters];
}

- (BOOL)joinRoomWithHost:(NSString *)host port:(int)port nickName:(NSString *)nickName roomParams:(NSDictionary *)roomParams
{
    if (!roomParams)
    {
        return NO;
    }

    self.apiHost = host;
    self.apiPort = port;
    
    // 用户ID
    NSString *userId = [[NSUUID UUID] UUIDString];
    //_markID = [uuid substringToIndex:13];
    if (roomParams[CHJoinRoomParamsUserIDKey])
    {
        userId = roomParams[CHJoinRoomParamsUserIDKey];
    }

    self.localUser = [[CHRoomUser alloc] initWithPeerId:userId];

    // 用户属性
    self.localUser.nickName = nickName;
    
    self.webServerHost = host;
    
    NSString *serverName = [roomParams objectForKey:CHJoinRoomParamsServerKey];
    self.currentServer = serverName;
    
    // 如果host是域名，并且params中的server不是空，则需要将域名host的global替换
    if ([CHSessionUtil isDomain:host] && serverName)
    {
        NSArray *array = [host componentsSeparatedByString:@"."];
        if (array && array.count > 2)
        {
            self.webServerHost = [NSString stringWithFormat:@"%@.%@.%@", serverName, array[1], array[2]];
        }
    }
    self.webServerPort = port;

    // 初始化 cloudHubRtcEngineKit
    // rtcEngineKit 使用http，所以端口是80
    NSDictionary *rtcEngineKitConfig = @{ CHJoinRoomParamsServerKey:host, CHJoinRoomParamsPortKey:@(80), CHJoinRoomParamsSecureKey:@(NO) };
    self.cloudHubRtcEngineKit = [CloudHubRtcEngineKit sharedEngineWithAppId:self.appId config:[rtcEngineKitConfig ch_toJSON]];
    self.cloudHubRtcEngineKit.delegate = self;
#ifdef DEBUG
    [self.cloudHubRtcEngineKit setLogFilter:1];
#endif

    self.whiteBoardManager = [CHWhiteBoardSDKManager sharedInstance];
    
    [self.whiteBoardManager registerDelegate:self loudHubRtcEngineKit:self.cloudHubRtcEngineKit host:host localUser:self.localUser configration:nil useHttpDNS:YES];
    
    [self.whiteBoardManager creatWhiteBordView];

    NSString *roomId = roomParams[CHJoinRoomParamsRoomIDKey];
    if ([self.cloudHubRtcEngineKit joinChannelByToken:@"" channelId:roomId properties:nil uid:self.localUser.peerID joinSuccess:nil] != 0)
    {
        NSLog(@"Join Channel failed!!");
    }

    return NO;
}


- (void)rtcEngine:(CloudHubRtcEngineKit *)engine didOccurError:(CloudHubErrorCode)errorCode withMessage:(NSString *)message
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onRoomDidOccuredError:withMessage:)])
    {
        [self.delegate onRoomDidOccuredError:errorCode withMessage:message];
    }
}

/// 进入房间
- (void)rtcEngine:(CloudHubRtcEngineKit *)engine didJoinChannel:(NSString *)channel withUid:(NSString *)uid elapsed:(NSInteger)elapsed
{
    if (joinCount)
    {
        [self didReJoinChannel:channel];
        
        return;
    }

    joinCount++;
    
    // didJoinChannel后才会发送MsgList
    [self.whiteBoardManager roomWhiteBoardOnJoined];

    if (self.delegate && [self.delegate respondsToSelector:@selector(onRoomJoined)])
    {
        [self.delegate onRoomJoined];
    }
}

/// 被动刷新服务器时间
- (void)rtcEngine:(CloudHubRtcEngineKit *)engine onServerTime:(NSUInteger)serverts
{
    NSTimeInterval timeInterval = serverts;

     //NSLog(@"ServiceTime %@", [NSDate bm_stringFromTs:timeInterval]);
     //self.tHowMuchTimeServerFasterThenMe = timeInterval - [[NSDate date] timeIntervalSince1970];
     //NSLog(@"tHowMuchTimeServerFasterThenMe %@", @(self.tHowMuchTimeServerFasterThenMe));
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onUpdateTimeWithTimeInterval:)])
    {
        [self.delegate onUpdateTimeWithTimeInterval:timeInterval];
    }
}

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine onDocAddr:(NSString * _Nonnull)docaddr
{
    NSArray *array = (NSArray *)([CHSessionUtil convertWithData:docaddr]);
    
    NSString *currentServer = array[0];
    
    if (currentServer && [CHSessionUtil isDomain:currentServer])
    {
        self.webServerHost = currentServer;
    }
     
    NSString *serverAddr = self.webServerHost;
    NSDictionary *dict = @
    {
        CHWhiteBoardGetServerAddrKey : serverAddr,
        CHWhiteBoardGetServerAddrBackupKey : @[],
        CHWhiteBoardGetWebAddrKey : self.webServerHost
    };

    [self.whiteBoardManager roomWhiteBoardOnChangeServerAddrs:dict];
    
    [self.whiteBoardManager roomWhiteBoardOnJoined];
}

/// 离开房间
- (void)rtcEngine:(CloudHubRtcEngineKit *)engine didLeaveChannel:(CloudHubChannelStats *)stats
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onRoomLeft)])
    {
        [self.delegate onRoomLeft];
    }
}

/// 连接状态
- (void)rtcEngine:(CloudHubRtcEngineKit *)engine connectionChangedToState:(CloudHubConnectionStateType)state
{
    if (state == CloudHubConnectionStateReconnecting)
    {
        isReconnect = YES;
                
        // 失去连接 断开连接
        if (self.delegate && [self.delegate respondsToSelector:@selector(onRoomConnectionLost)])
        {
            [self.delegate onRoomConnectionLost];
        }

        [self.whiteBoardManager roomWhiteBoardOnDisconnect];
    }
    else if (isReconnect && state == CloudHubConnectionStateConnected)
    {
    }
}

#pragma mark - 重连

- (void)rtcEngine:(CloudHubRtcEngineKit *)engine didReJoinChannel:(NSString *)channel withUid:(NSString *)uid elapsed:(NSInteger) elapsed
{
    [self didReJoinChannel:channel];
}

- (void)didReJoinChannel:(NSString *)channel
{
    [self.whiteBoardManager roomWhiteBoardOnReJoined];

    if (self.delegate && [self.delegate respondsToSelector:@selector(onRoomReJoined)])
    {
        [self.delegate onRoomReJoined];
    }
}

@end
