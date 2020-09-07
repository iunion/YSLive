//
//  CloudHubManager.m
//  YSLiveSample
//
//

#import "CloudHubManager.h"
#import "JsonTool.h"
#import "CHNewCoursewareControlView.h"

#define APPID @"LEL26sZnybNA81cH"

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

@property (nonatomic, strong) NSString *roomId;

/// 当前用户数据
@property (nonatomic, strong) CHRoomUser *localUser;

@property (nonatomic, strong) NSString *webServerHost;
@property (nonatomic, assign) NSUInteger webServerPort;

@property (nonatomic, strong) NSArray *serverList;

#pragma mark - 白板

/// 白板管理
@property (nonatomic, strong) CHWhiteBoardSDKManager *whiteBoardManager;

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
        [CHWhiteBoardSDKManager destroy];
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
    self.appId = @"";//APPID;
    
    self.apiHost = CloudHubManager_DefaultApiHost;
    self.apiPort = CloudHubManager_DefaultApiPort;
    
    joinCount = 0;
}

- (BOOL)joinRoomWithHost:(NSString *)host port:(NSUInteger)port nickName:(NSString *)nickName roomId:(NSString *)roomId roomPassword:(NSString *)roomPassword userId:(NSString *)userId
{
    self.roomId = roomId;
    
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
    else
    {
        [parameters setObject:@""
                       forKey:CHJoinRoomParamsPasswordKey];
    }

    if (userId)
    {
        [parameters setObject:userId forKey:CHJoinRoomParamsUserIDKey];
    }
    
    return [self joinRoomWithHost:host port:port nickName:nickName roomParams:parameters];
}

- (BOOL)joinRoomWithHost:(NSString *)host port:(NSUInteger)port nickName:(NSString *)nickName roomParams:(NSDictionary *)roomParams
{
    if (!roomParams)
    {
        return NO;
    }

    if (!host)
    {
        host = CloudHubManager_DefaultApiHost;
    }
    if (port == 0)
    {
        port = CloudHubManager_DefaultApiPort;
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
    self.webServerPort = port;

    // 初始化 cloudHubRtcEngineKit
    // rtcEngineKit 使用http，所以端口是80
    NSDictionary *rtcEngineKitConfig = @{ CHJoinRoomParamsServerKey:host, CHJoinRoomParamsPortKey:@(80), CHJoinRoomParamsSecureKey:@(NO) };
    self.cloudHubRtcEngineKit = [CloudHubRtcEngineKit sharedEngineWithAppId:self.appId config:[rtcEngineKitConfig ch_toJSON]];
    //self.cloudHubRtcEngineKit.delegate = self;
    self.cloudHubRtcEngineKit.wb = self;
    
#ifdef DEBUG
    [self.cloudHubRtcEngineKit setLogFilter:1];
#endif

    self.whiteBoardManager = [CHWhiteBoardSDKManager sharedInstance];
    
    [self.whiteBoardManager registerDelegate:self loudHubRtcEngineKit:self.cloudHubRtcEngineKit host:host localUser:self.localUser configration:nil useHttpDNS:YES];
    // 使用自定义翻页工具条
    [self.whiteBoardManager registerCoursewareControlView:@"CHNewCoursewareControlView" viewSize:CGSizeZero];
    
    [self.whiteBoardManager creatWhiteBordView];

    NSString *roomId = roomParams[CHJoinRoomParamsRoomIDKey];
    if ([self.cloudHubRtcEngineKit joinChannelByToken:@"" channelId:roomId properties:nil uid:self.localUser.peerID joinSuccess:nil] != 0)
    {
        NSLog(@"Join Channel failed!!");
    }

    return NO;
}

- (UIView *)whiteBordView
{
    return self.whiteBoardManager.mainWhiteBoardView;
}

/// 当前服务器时间 now+tHowMuchTimeServerFasterThenMe
- (NSTimeInterval)tCurrentTime
{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval timeInterval = now + self.tHowMuchTimeServerFasterThenMe;
    
    return timeInterval;
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
    
#if DEBUG
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *serviceTime = [dateFormater stringFromDate:date];
    
    NSLog(@"ServiceTime %@", serviceTime);
#endif
    self.tHowMuchTimeServerFasterThenMe = timeInterval - [[NSDate date] timeIntervalSince1970];
    NSLog(@"tHowMuchTimeServerFasterThenMe %@", @(self.tHowMuchTimeServerFasterThenMe));
    
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
    
    if (self.roomId)
    {
        [self.whiteBoardManager getFileListWithRoomId:self.roomId complete:^(NSArray<NSDictionary *> * _Nullable fileList) {
            [self.whiteBoardManager setWhiteBoardFileList:fileList];
            [self.whiteBoardManager roomWhiteBoardOnJoined];
        }];
    }
    else
    {
        [self.whiteBoardManager roomWhiteBoardOnJoined];
    }
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

/// 被踢出
- (void)rtcEngine:(CloudHubRtcEngineKit *)engine onLocalUserEvicted:(NSInteger)reason
{
    if ([self.delegate respondsToSelector:@selector(onRoomKickedOut:)])
    {
        [self.delegate onRoomKickedOut:reason];
    }
}

/// 信令
- (void)rtcEngine:(CloudHubRtcEngineKit *)engine
         onPubMsg:(NSString *)msgName
            msgId:(NSString *)msgId
             from:(NSString *)fromuid
         withData:(NSString *)data
associatedWithUser:(NSString *)uid
associatedWithMsg:(NSString *)assMsgID
               ts:(NSUInteger)ts
    withExtraData:(NSString *)extraData
        isHistory:(BOOL)isHistory
{
    //data = [data stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    //extraData = [extraData stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    
    NSDictionary *dataDic = [CHSessionUtil convertWithData:data];
    NSDictionary *extensionDic = [CHSessionUtil convertWithData:extraData];

    NSMutableDictionary *msgDic = [NSMutableDictionary dictionary];
    [msgDic setObject:msgId forKey:@"id"];
    [msgDic setObject:msgName forKey:@"name"];
    [msgDic setObject:@(ts) forKey:@"ts"];
    if (fromuid)
    {
        [msgDic setObject:fromuid forKey:@"fromID"];
    }
    if (data)
    {
        if (dataDic)
        {
            [msgDic setObject:dataDic forKey:@"data"];
        }
    }
    if (uid)
    {
        [msgDic setObject:uid forKey:@"associatedUserID"];
    }
    if (assMsgID)
    {
        [msgDic setObject:assMsgID forKey:@"associatedMsgID"];
    }
    if (extraData)
    {
        if (extensionDic)
        {
            [msgDic addEntriesFromDictionary:extensionDic];
        }
    }
    [msgDic setObject:@(isHistory) forKey:@"isHistory"];
    
    [self.whiteBoardManager roomWhiteBoardOnRemotePubMsg:msgDic];
}

- (void)rtcEngine:(CloudHubRtcEngineKit *)engine
         onDelMsg:(NSString *)msgName
            msgId:(NSString *)msgId
             from:(NSString *)fromuid
         withData:(NSString *)data
{
    //NSDictionary *dataDic = [CHSessionUtil convertWithData:data];
    NSMutableDictionary *msgDic = [NSMutableDictionary dictionary];
    [msgDic setObject:msgId forKey:@"id"];
    [msgDic setObject:msgName forKey:@"name"];
    if (fromuid)
    {
        [msgDic setObject:fromuid forKey:@"fromID"];
    }
    if (data)
    {
        NSDictionary *dataDic = [CHSessionUtil convertWithData:data];
        if (dataDic)
        {
            [msgDic setObject:dataDic forKey:@"data"];
        }
    }
    
    [self.whiteBoardManager roomWhiteBoardOnRemoteDelMsg:msgDic];
}


#pragma mark - CHWhiteBoardManagerDelegate

/// 白板准备完毕
- (void)onWhiteBroadCheckRoomFinish:(BOOL)finished
{
    [self.delegate onWhiteBroadCheckRoomFinish:finished];
}

/**
 文件列表回调
 @param fileList 文件NSDictionary列表
 */
- (void)onWhiteBroadFileList:(NSArray *)fileList
{
    [self.delegate onWhiteBroadFileList:fileList];
}

/// H5脚本文件加载初始化完成
- (void)onWhiteBoardPageFinshed:(NSString *)fileId
{
    [self.delegate onWhiteBoardPageFinshed:fileId];
}

/// 切换Web课件加载状态
- (void)onWhiteBoardLoadedState:(NSString *)fileId withState:(NSDictionary *)dic
{
    [self.delegate onWhiteBoardLoadedState:fileId withState:dic];
}

/// Web课件翻页结果
- (void)onWhiteBoardStateUpdate:(NSString *)fileId withState:(NSDictionary *)dic
{
    [self.delegate onWhiteBoardStateUpdate:fileId withState:dic];
}

/// 翻页超时
- (void)onWhiteBoardSlideLoadTimeout:(NSString *)fileId withState:(NSDictionary *)dic
{
    [self.delegate onWhiteBoardSlideLoadTimeout:fileId withState:dic];
}

/// 课件缩放
- (void)onWhiteBoardZoomScaleChanged:(NSString *)fileId zoomScale:(CGFloat)zoomScale
{
    [self.delegate onWhiteBoardZoomScaleChanged:fileId zoomScale:zoomScale];
}


#pragma mark - 课件事件

/// 课件全屏
- (void)onWhiteBoardFullScreen:(BOOL)isAllScreen
{
    [self.delegate onWhiteBoardFullScreen:isAllScreen];
}

/// 切换课件
- (void)onWhiteBoardChangedFileWithFileList:(NSArray *)fileList
{
    [self.delegate onWhiteBoardChangedFileWithFileList:fileList];
}

/// 课件窗口最大化事件
- (void)onWhiteBoardMaximizeView
{
    [self.delegate onWhiteBoardMaximizeView];
}

@end
