//
//  YSLiveManager.m
//  YSLive
//
//  Created by jiang deng on 2019/10/14.
//  Copyright © 2019 FS. All rights reserved.
//

#import "YSLiveManager.h"
#import <objc/message.h>

#import "YSCoreStatus.h"

#import "YSLiveMediaModel.h"

#import "YSPermissionsVC.h"

#import <AVFoundation/AVFoundation.h>

#if YSWHITEBOARD_USEHTTPDNS
#import "YSWhiteBordHttpDNSUtil.h"
#import "YSWhiteBordNSURLProtocol.h"
#import "NSURLProtocol+YSWhiteBoard.h"
#endif

#ifdef DEBUG
#define YSADDLOW_IPHONE     0
#endif


@interface YSLiveManager ()
<
    YSRoomInterfaceDelegate,
    YSWhiteBoardManagerDelegate
>

// 是否需要设备检测
@property (nonatomic, assign) BOOL needCheckPermissions;

// 房间音视频
@property (nonatomic, strong) YSRoomInterface *roomManager;

// 白板
@property (nonatomic, strong) YSWhiteBoardManager *whiteBoardManager;
/// 白板视图whiteBord
@property (nonatomic, strong) UIView *whiteBordView;

// 消息缓存数据
@property (nonatomic, strong) NSMutableArray *cacheMsgPool;

// 房间数据
@property (nonatomic, strong) NSDictionary *roomDic;
@property (nonatomic, strong) YSLiveRoomConfiguration *roomConfig;

/// 是否大房间
@property (nonatomic, assign) BOOL isBigRoom;

// 房间用户列表
@property (nonatomic, strong) NSMutableArray <YSRoomUser *> *userList;

// 老师/主播
@property (nonatomic, strong) YSRoomUser *teacher;

// 房间用户数
@property (nonatomic, assign) NSUInteger userCount;
@property (nonatomic, strong) NSDictionary *userCountDetailDic;

// 全体禁言
//@property (nonatomic, assign) BOOL isEveryoneBanChat;

// 是否打开上麦功能
//@property (nonatomic, assign) BOOL allowEveryoneUpPlatform;

// 是否同意上麦申请
//@property (nonatomic, assign) BOOL allowUpPlatformApply;

/// 当前播放课件媒体
@property (nonatomic, strong) YSLiveMediaModel *playMediaModel;

/// 当前共享桌面用户Id
@property (nonatomic, strong) NSString *sharePeerId;

@end


static YSLiveManager *liveManagerSingleton = nil;

@implementation YSLiveManager

+ (instancetype)shareInstance
{
    BMLog(@"RoomSDKVersion: %@", [NSString stringWithCString:(char *)(YSRoomSDKVersionString) encoding:NSUTF8StringEncoding]);
    
    if (liveManagerSingleton)
    {
        return liveManagerSingleton;
    }
    else
    {
        liveManagerSingleton = [[YSLiveManager alloc] init];
        
        liveManagerSingleton.liveHost = YSLIVE_HOST;
        
        liveManagerSingleton.schoolHost = YSSchool_Server;
        
        [liveManagerSingleton registerURLProtocol:YES];
    }
    //    static dispatch_once_t onceToken;
    //    dispatch_once(&onceToken, ^{ liveManagerSingleton = [[YSLiveManager alloc] init]; });
    
    return liveManagerSingleton;
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

- (void)destroy
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    if (liveManagerSingleton)
    {
        [liveManagerSingleton.whiteBoardManager resetWhiteBoardAllData];
        [liveManagerSingleton.whiteBoardManager clearAllData];

        [YSRoomInterface destory];
        [YSWhiteBoardManager destroy];
        
        liveManagerSingleton.roomManager = nil;
        liveManagerSingleton.whiteBoardManager = nil;

        [liveManagerSingleton registerURLProtocol:NO];
    }
    
    liveManagerSingleton = nil;
}

// 拦截网络请求
- (void)registerURLProtocol:(BOOL)isRegister
{
#if YSWHITEBOARD_USEHTTPDNS
    if (isRegister)
    {
        [NSURLProtocol registerClass:[YSWhiteBordNSURLProtocol class]];
        for (NSString* scheme in @[@"http", @"https"])
        {
            [NSURLProtocol ys_registerScheme:scheme];
        }
        [YSWhiteBordHttpDNSUtil sharedInstance];
    }
    else
    {
        [NSURLProtocol unregisterClass:[YSWhiteBordNSURLProtocol class]];
        for (NSString* scheme in @[@"http", @"https"])
        {
            [NSURLProtocol ys_unregisterScheme:scheme];
        }
        YSWhiteBordHttpDNSUtil *httpDNSUtil = [YSWhiteBordHttpDNSUtil sharedInstance];
        [httpDNSUtil cancelGetHttpDNSIp];
    }
#endif
}

/// 浏览器打开app的URL解析
+ (NSDictionary *)resolveJoinRoomParamsWithUrl:(NSURL *)url
{
    NSDictionary *queryDictionary = nil;
    
    if (![[url absoluteString] containsString:@"="])
    {
        NSString * urlStr = [[url absoluteString] bm_URLDecode];
        url = [NSURL URLWithString:urlStr];
        if (![[url absoluteString] containsString:@"="])
        {
            return nil;
        }
    }
    
    queryDictionary = [url bm_queryDictionary];
    
    if (![queryDictionary bm_isNotEmptyDictionary])
    {
        return nil;
    }
    
    // 有roomId，直接返回
    if ([queryDictionary bm_containsObjectForKey:@"roomid"])
    {
        return queryDictionary;
    }
    
    NSMutableDictionary *queryMutableDictionary = [[NSMutableDictionary alloc] initWithDictionary: queryDictionary];
    NSString *host = [queryDictionary bm_stringTrimForKey:@"host"];
    if (!host)
    {
        return nil;
    }
    [YSLiveManager shareInstance].liveHost = host;
    
    NSString *server = @"global";
    if ([YSLiveUtil isDomain:host] == YES)
    {
        NSArray *array = [host componentsSeparatedByString:@"."];
        server = [NSString stringWithFormat:@"%@", array[0]];
    }
    [queryMutableDictionary bm_setString:server forKey:@"server"];
    [queryMutableDictionary bm_setInteger:3 forKey:@"clientType"];
    
    // 链接进入的 角色类型字段 是 logintype 不是 userrole 需要添加  user role
    if (![queryMutableDictionary bm_containsObjectForKey:@"userrole"])
    {
        YSUserRoleType userrole = [queryMutableDictionary bm_uintForKey:@"logintype" withDefault:YSUserType_Student];
        [queryMutableDictionary bm_setUInteger:userrole forKey:@"userrole"];
    }
    
    YSUserRoleType userrole = [queryMutableDictionary bm_uintForKey:@"userrole"];
    if (userrole == YSUserType_Teacher || userrole == YSUserType_Student || userrole == YSUserType_Patrol)
    {
        return queryMutableDictionary;
    }
    else
    {
        return nil;
    }
}

- (void)initializeManager
{
    self.viewDidAppear = NO;
    self.cacheMsgPool = [[NSMutableArray alloc] init];
    
    self.isEveryoneBanChat = NO;
//    self.isEveryoneNoAudio = YES;
    self.isEveryoneNoAudio = NO;
}

- (void)initializeSDK
{
    if (!self.roomManager)
    {
        self.roomManager = [YSRoomInterface instance];
        [self.roomManager initWithAppKey: YSLive_AppKey
                                optional: @{
                                    YSRoomSettingOptionalWhiteBoardNotify : @(YES),
                                    YSRoomSettingOptionalSecureSocket : @(1),
                                    YSRoomSettingOptionalReconnectattempts : @(5)
                                }];
        [YSRoomInterface setLogLevel:YSLogLevelOff logPath:nil debugToConsole:NO];
        
        // log存储
        NSArray *cachesPathArr = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachesPath = cachesPathArr.firstObject;
        NSString *logsDirectory = [cachesPath stringByAppendingPathComponent:YSLive_LogPath];
        [YSRoomInterface setLogLevel:(YSLogLevelDebug)logPath:logsDirectory debugToConsole:YES];
    }
}

- (void)registerRoomManagerDelegate:(id <YSLiveRoomManagerDelegate>)RoomManagerDelegate
{
    self.roomManagerDelegate = RoomManagerDelegate;
}

//- (BOOL)joinRoomWithHost:(NSString *)host port:(int)port nickName:(NSString *)nickName roomId:(NSString *)roomId roomPassword:(NSString *)roomPassword userRole:(YSUserRoleType)userRole userId:(NSString *)userId userParams:(NSDictionary *)userParams
- (BOOL)joinRoomWithHost:(NSString *)host port:(int)port nickName:(NSString *)nickName roomId:(NSString *)roomId roomPassword:(NSString *)roomPassword userRole:(YSUserRoleType)userRole userId:(NSString *)userId userParams:(NSDictionary *)userParams needCheckPermissions:(BOOL)needCheckPermissions
{
    //@"server"    :self.defaultServer,
    //@"clientType":@(3)
    NSString *server = @"global";
    if ([YSLiveUtil isDomain:host] == YES)
    {
        NSArray *array = [host componentsSeparatedByString:@"."];
        server = [NSString stringWithFormat:@"%@", array[0]];
    }
    
    NSMutableDictionary *parameters = @{
        YSJoinRoomParamsRoomIDKey : roomId,
        //YSJoinRoomParamsPasswordKey : [roomPassword bm_isNotEmpty] ? roomPassword : @"",
        YSJoinRoomParamsUserRoleKey : @(userRole),
        @"server" : server,
        @"clientType" : @(3)
    }.mutableCopy;
    
    if ([roomPassword bm_isNotEmpty])
    {
        [parameters setObject:roomPassword forKey:YSJoinRoomParamsPasswordKey];
    }
    
    if ([userId bm_isNotEmpty])
    {
        [parameters setObject:userId forKey:YSJoinRoomParamsUserIDKey];
    }
    
    return [self joinRoomWithHost:host port:port nickName:nickName roomParams:parameters userParams:nil needCheckPermissions:needCheckPermissions];
}

- (BOOL)joinRoomWithHost:(NSString *)host port:(int)port nickName:(NSString *)nickname roomParams:(NSDictionary *)roomParams userParams:(NSDictionary *)userParams needCheckPermissions:(BOOL)needCheckPermissions
{
    if (needCheckPermissions)
    {
        ///查看摄像头权限
        BOOL isCamera = [self cameraPermissionsService];
        ///查看麦克风权限
        BOOL isOpenMicrophone = [self microphonePermissionsService];
        /// 扬声器权限
        BOOL isReproducer = [YSUserDefault getReproducerPermission];
        
    //    isOpenMicrophone = NO;
        if (!isOpenMicrophone || !isCamera || !isReproducer)
        {
            UIWindow *window = [[UIApplication sharedApplication].delegate window];
            UIViewController *topViewController = [window rootViewController];

            YSPermissionsVC *vc = [[YSPermissionsVC alloc] init];

            BMWeakSelf
            vc.toJoinRoom = ^{

                [weakSelf prepareToJoinRoomWithHost:host port:port nickName:nickname roomParams:roomParams userParams:userParams];

                [weakSelf.roomManager joinRoomWithHost:host port:port nickName:nickname roomParams:roomParams userParams:userParams];
            };
            [(UINavigationController*)topViewController pushViewController:vc animated:NO];
            
            return YES;
        }
    }
    
    [self prepareToJoinRoomWithHost:host port:port nickName:nickname roomParams:roomParams userParams:userParams];
    
    if ( [self.roomManager joinRoomWithHost:host port:port nickName:nickname roomParams:roomParams userParams:userParams] == 0)
    {
        return YES;
    }
    return NO;
}

- (void)prepareToJoinRoomWithHost:(NSString *)host port:(int)port nickName:(NSString *)nickname roomParams:(NSDictionary *)roomParams userParams:(NSDictionary *)userParams
{
    [self initializeSDK];
    
    self.userList = [[NSMutableArray alloc] init];
    
    self.whiteBoardManager = [YSWhiteBoardManager shareInstance];
    
    BMWeakSelf
    self.whiteBoardManager.webContentTerminateBlock = ^NSArray *_Nullable {
        NSMutableArray *userArray = [NSMutableArray array];
        for (YSRoomUser *user in weakSelf.userList)
        {
            NSDictionary *dic = [user bm_toDictionary];
            if ([dic bm_isNotEmptyDictionary])
            {
                [userArray addObject:dic];
            }
        }
        return userArray;
    };
    
    NSDictionary *whiteBoardConfig = @{
        YSWhiteBoardWebProtocolKey : YSLive_Http,
        YSWhiteBoardWebHostKey : host,
        YSWhiteBoardWebPortKey : @(port),
        YSWhiteBoardPlayBackKey : @(NO),
    };
    [self.whiteBoardManager registerDelegate:self configration:whiteBoardConfig];
    
    self.whiteBordView = [self.whiteBoardManager createWhiteBoardWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, 100) loadComponentName:YSWBMainContentComponent loadFinishedBlock:^{

    }];
    [self.whiteBoardManager changeWhiteBoardBackImage:nil];
    [self.whiteBoardManager changeFileViewBackgroudColor:[UIColor bm_colorWithHex:0xDCE2F1]];

    [self.roomManager registerRoomInterfaceDelegate:self];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}



- (void)checkDevice
{
    
}

#pragma mark 进入前后台

- (void)enterForeground:(NSNotification *)aNotification
{
    [self sendSignalingUpdateTimeWithCompletion:nil];
    
    if ([self.roomManagerDelegate respondsToSelector:@selector(handleEnterForeground)])
    {
        [self.roomManagerDelegate handleEnterForeground];
    }
}

- (void)enterBackground:(NSNotification *)aNotification
{
    if ([self.roomManagerDelegate respondsToSelector:@selector(handleEnterBackground)])
    {
        [self.roomManagerDelegate handleEnterBackground];
    }
}


- (void)addMsgCachePoolWithMethodName:(SEL)selector parameters:(NSArray *)parameters
{
    if (!self.viewDidAppear)
    {
        NSString *methodName = NSStringFromSelector(selector);
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:methodName forKey:kYSMethodNameKey];
        if ([parameters bm_isNotEmpty])
        {
            [dic setValue:parameters forKey:kYSParameterKey];
        }
        
        [self.cacheMsgPool addObject:dic];
    }
}

///用户进教室前的一些信令回调
- (void)doMsgCachePool
{
    for (NSDictionary *dic in self.cacheMsgPool)
    {
        NSString *methodName = [dic bm_stringForKey:kYSMethodNameKey];
        SEL funcSel = NSSelectorFromString(methodName);
        NSArray *parameters = [dic bm_arrayForKey:kYSParameterKey];
        
        if ([parameters bm_isNotEmpty])
        {
            if ([methodName isEqualToString:NSStringFromSelector(@selector(onRoomDidOccuredError:))])
            {
                NSError *error = parameters[0];
                ((void (*)(id, SEL, NSError *))objc_msgSend)(self, funcSel, error);
            }
            else if ([methodName isEqualToString:NSStringFromSelector(@selector(onRoomDidOccuredWaring:))])
            {
                YSRoomWarningCode code = (YSRoomWarningCode)[parameters.firstObject integerValue];
                ((void (*)(id, SEL, YSRoomWarningCode))objc_msgSend)(self, funcSel, code);
            }
            else if ([methodName isEqualToString:NSStringFromSelector(@selector(onRoomUserJoined:inList:))])
            {
                if (parameters.count != 2)
                {
                    continue;
                }
                
                NSString *peerID = parameters[0];
                BOOL inList = [parameters[1] boolValue];
                ((void (*)(id, SEL, NSString *, BOOL))objc_msgSend)(self, funcSel, peerID, inList);
            }
            else if ([methodName isEqualToString:NSStringFromSelector(@selector(onRoomUserLeft:))])
            {
                NSString *peerID = parameters[0];
                ((void (*)(id, SEL, NSString *))objc_msgSend)(self, funcSel, peerID);
            }
            else if ([methodName isEqualToString:NSStringFromSelector(@selector(onRoomKickedOut:))])
            {
                NSDictionary *dict = parameters.firstObject;
                ((void (*)(id, SEL, NSDictionary *))objc_msgSend)(self, funcSel, dict);
            }
            else if ([methodName isEqualToString:NSStringFromSelector(@selector(onRoomUserPropertyChanged:properties:fromId:))])
            {
                if (parameters.count != 3)
                {
                    continue;
                }
                
                NSString *peerID = parameters[0];
                NSDictionary *properties = parameters[1];
                NSString *fromId = parameters[2];
                ((void (*)(id, SEL, NSString *, NSDictionary *, NSString *))objc_msgSend)(self, funcSel, peerID, properties, fromId);
            }
            else if ([methodName isEqualToString:NSStringFromSelector(@selector(onRoomUserVideoStatus:state:))])
            {
                if (parameters.count != 2)
                {
                    continue;
                }
                
                NSString *peerID = parameters[0];
                YSPublishState state = (YSPublishState)[parameters[1] integerValue];
                ((void (*)(id, SEL, NSString *, YSPublishState))objc_msgSend)(self, funcSel, peerID, state);
            }
            else if ([methodName isEqualToString:NSStringFromSelector(@selector(onRoomUserAudioStatus:state:))])
            {
                if (parameters.count != 2)
                {
                    continue;
                }
                
                NSString *peerID = parameters[0];
                YSPublishState state = (YSPublishState)[parameters[1] integerValue];
                ((void (*)(id, SEL, NSString *, YSPublishState))objc_msgSend)(self, funcSel, peerID, state);
            }
            else if ([methodName isEqualToString:NSStringFromSelector(@selector(onRoomRemotePubMsgWithMsgID:msgName:data:fromID:inList:ts:body:))])
            {
                if (parameters.count != 7)
                {
                    continue;
                }
                
                NSString *msgID = parameters[0];
                NSString *msgName = parameters[1];
                id data = parameters[2];
                NSString *fromID = parameters[3];
                BOOL inlist = [parameters[4] boolValue];
                unsigned long ts = [parameters[5] unsignedIntegerValue];
                NSDictionary *body = parameters[6];

                ((void (*)(id, SEL, NSString *, NSString *, NSObject *, NSString *, BOOL, unsigned long, NSDictionary *))objc_msgSend)(self, funcSel, msgID, msgName, data, fromID, inlist, ts, body);
            }
            else if ([methodName isEqualToString:NSStringFromSelector(@selector(onRoomRemoteDelMsgWithMsgID:msgName:data:fromID:inList:ts:))])
            {
                if (parameters.count != 6)
                {
                    continue;
                }
                
                NSString *msgID = parameters[0];
                NSString *msgName = parameters[1];
                id data = parameters[2];
                NSString *fromID = parameters[3];
                BOOL inlist = [parameters[4] boolValue];
                unsigned long ts = [parameters[5] unsignedIntegerValue];
                
                ((void (*)(id, SEL, NSString *, NSString *, NSObject *, NSString *, BOOL, unsigned long))objc_msgSend)(self, funcSel, msgID, msgName, data, fromID, inlist, ts);
            }
            else if ([methodName isEqualToString:NSStringFromSelector(@selector(onRoomMessageReceived:fromID:extension:))])
            {
                if (parameters.count != 3)
                {
                    continue;
                }
                
                NSString *message = parameters[0];
                NSString *peerID = parameters[1];
                NSDictionary *fromId = parameters[2];
                ((void (*)(id, SEL, NSString *, NSString *, NSDictionary *))objc_msgSend)(self, funcSel, message, peerID, fromId);
            }
            else if ([methodName isEqualToString:NSStringFromSelector(@selector(onRoomNetworkQuality:delay:))])
            {
                if (parameters.count != 2)
                {
                    continue;
                }
                
                YSNetQuality networkQuality = [parameters[0] unsignedIntegerValue];
                NSInteger delay = [parameters[1] doubleValue];
                ((void (*)(id, SEL, YSNetQuality, NSInteger))objc_msgSend)(self, funcSel, networkQuality, delay);
            }
            //            else if ([methodName isEqualToString:NSStringFromSelector(@selector(roomManagerPlaybackMessageReceived:fromID:ts:extension:))])
            //            {
            //                if (parameters.count != 4)
            //                {
            //                    continue;
            //                }
            //
            //                NSString *message = parameters[0];
            //                NSString *peerID = parameters[1];
            //                NSTimeInterval ts = [parameters[2] doubleValue];
            //                NSDictionary *dict = parameters[3];
            //                ((void (*)(id, SEL, NSString *, NSString *, NSTimeInterval,
            //                           NSDictionary *))objc_msgSend)(self, funcSel, message, peerID, ts, dict);
            //
            //            }
            else if ([methodName isEqualToString:NSStringFromSelector(@selector(onRoomShareMediaState:state:extensionMessage:))])
            {
                if (parameters.count != 3)
                {
                    continue;
                }
                
                NSString *peerId = parameters[0];
                YSMediaState state = (YSMediaState)[parameters[1] integerValue];
                NSDictionary *message = parameters[2];
                ((void (*)(id, SEL, NSString *, YSMediaState, NSDictionary *))objc_msgSend)(self, funcSel, peerId, state, message);
            }
            else if ([methodName isEqualToString:NSStringFromSelector(@selector(onRoomUpdateMediaStream:pos:isPlay:))])
            {
                if (parameters.count != 3)
                {
                    continue;
                }
                
                NSTimeInterval duration = [parameters[0] doubleValue];
                NSTimeInterval pos = [parameters[1] doubleValue];
                BOOL isPlay = [parameters[2] boolValue];
                
                ((void (*)(id, SEL, NSTimeInterval, NSTimeInterval, BOOL))objc_msgSend)(self, funcSel, duration, pos, isPlay);
            }
            else if ([methodName isEqualToString:NSStringFromSelector(@selector(onRoomShareScreenState:state:))])
            {
                if (parameters.count != 2)
                {
                    continue;
                }
                
                NSString *peerId = parameters[0];
                YSMediaState state = (YSMediaState)[parameters[1] integerValue];
                ((void (*)(id, SEL, NSString *, YSMediaState)) objc_msgSend)(self, funcSel, peerId, state);
            }
            else if ([methodName isEqualToString:NSStringFromSelector(@selector(onRoomShareFileState:state:extensionMessage:))])
            {
                if (parameters.count != 3)
                {
                    continue;
                }
                
                NSString *peerId = parameters[0];
                YSMediaState state = (YSMediaState)[parameters[1] integerValue];
                NSDictionary *message = parameters[2];
                
                ((void (*)(id, SEL, NSString *, YSMediaState, NSDictionary *))objc_msgSend)(self, funcSel, peerId, state, message);
            }
            else if ([methodName isEqualToString:NSStringFromSelector(@selector(onWhiteBoardViewStateUpdate:))])
            {
                if (parameters.count != 1)
                {
                    continue;
                }
                
                NSDictionary *message = parameters[0];
                ((void (*)(id, SEL, NSDictionary *))objc_msgSend)(self, funcSel, message);
            }
        }
        else
        {
            ((void (*)(id, SEL))objc_msgSend)(self, funcSel);
        }
    }
    
    [self.cacheMsgPool removeAllObjects];
}


- (NSString *)fileServer
{
    return self.whiteBoardManager.address;
}


#pragma mark -
#pragma mark user

- (YSRoomUser *)localUser
{
    return self.roomManager.localUser;
}

- (NSUInteger)userCountWithUserRole:(YSUserRoleType)role
{
    // "{"num":2,"rolenums":{"0":0,"1":0,"2":2,"3":0,"4":0,"5":0}}"
    NSUInteger count = [self.userCountDetailDic bm_uintForKey:@(role)];
    
    return count;
}

- (NSUInteger)teacherCount
{
    if (self.isBigRoom)
    {
        return [self userCountWithUserRole:YSUserType_Teacher];
    }
    else
    {
        if (self.teacher)
        {
            return 1;
        }
        else
        {
            return 0;
        }
    }
}

- (NSUInteger)assistantCount
{
    if (self.isBigRoom)
    {
        return [self userCountWithUserRole:YSUserType_Assistant];
    }
    else
    {
        NSInteger userNum = self.userList.count;
        for (YSRoomUser * user in self.userList)
        {
            if (user.role != YSUserType_Assistant)
            {
                userNum--;
            }
        }
        if (userNum < 0)
        {
            userNum = 0;
        }
        
        return userNum;
    }
}

- (NSUInteger)studentCount
{
    if (self.isBigRoom)
    {
        return [self userCountWithUserRole:YSUserType_Student];
    }
    else
    {
        NSInteger userNum = self.userList.count;
        for (YSRoomUser * user in self.userList)
        {
            if (user.role != YSUserType_Student)
            {
                userNum--;
            }
        }
        if (userNum < 0)
        {
            userNum = 0;
        }
        
        return userNum;
    }
}

- (NSUInteger)liveCount
{
    return [self userCountWithUserRole:YSUserType_Live];
}

- (NSUInteger)patrolCount
{
    return [self userCountWithUserRole:YSUserType_Patrol];
}

- (void)addRoomUser:(YSRoomUser *)aRoomUser showMessge:(BOOL)showMessge
{
    if (![aRoomUser bm_isNotEmpty])
    {
        return;
    }
    
    BOOL isUserExist = NO;
    NSUInteger roomUserIndex = 0;
    
    for (YSRoomUser *roomUser in self.userList)
    {
        if ([roomUser.peerID isEqualToString:aRoomUser.peerID])
        {
            isUserExist = YES;
            break;
        }
        roomUserIndex++;
    }
    
    // 不存在添加，存在则替换
    if (!isUserExist)
    {
        [self.userList addObject:aRoomUser];
    }
    else
    {
        [self.userList replaceObjectAtIndex:roomUserIndex withObject:aRoomUser];
    }
    
    
    NSString * roleName = nil;
    if (aRoomUser.role == YSUserType_Teacher)
    {
        self.teacher = aRoomUser;
        
        roleName = YSLocalized(@"Role.Teacher");
        
        if ([self.roomManagerDelegate respondsToSelector:@selector(roomManagerRoomTeacherEnter)])
        {
            [self.roomManagerDelegate roomManagerRoomTeacherEnter];
        }
    }
    else if (aRoomUser.role == YSUserType_Assistant)
    {
        roleName = YSLocalized(@"Role.Assistant");
    }
    else if (aRoomUser.role == YSUserType_Student)
    {
        roleName = YSLocalized(@"Role.Student");
    }
    
    if (!self.isBigRoom && showMessge && aRoomUser.role != YSUserType_Patrol)
    {
        NSString *message = [NSString stringWithFormat:@"%@(%@) %@", aRoomUser.nickName,roleName,YSLocalized(@"Action.EnterRoom")];
        [self sendTipMessage:message tipType:YSChatMessageTypeTips];
    }
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:ysUserListNotification object:nil];
}

// 内部使用
//- (YSRoomUser *)getRoomUserWithPeerId:(NSString *)peerId
//{
//    for (YSRoomUser *user in self.userList)
//    {
//        if ([user.peerID isEqualToString:peerId])
//        {
//            return user;
//        }
//    }
//
//    return nil;
//}

- (void)delRoomUser:(YSRoomUser *)aRoomUser showMessge:(BOOL)showMessge
{
    if (![aRoomUser bm_isNotEmpty])
    {
        return;
    }
    
    [self.userList removeObject:aRoomUser];
    
    NSString *roleName = nil;
    
    if (aRoomUser.role == YSUserType_Teacher)
    {
        roleName = YSLocalized(@"Role.Teacher");
        
        if ([aRoomUser.peerID isEqualToString:self.teacher.peerID])
        {
            if ([self.roomManagerDelegate respondsToSelector:@selector(roomManagerRoomTeacherLeft)])
            {
                [self.roomManagerDelegate roomManagerRoomTeacherLeft];
            }
            self.teacher = nil;
        }
    }
    else if(aRoomUser.role == YSUserType_Assistant)
    {
        roleName = YSLocalized(@"Role.Assistant");
    }
    else if (aRoomUser.role == YSUserType_Student)
    {
        roleName = YSLocalized(@"Role.Student");
    }
    
    if (!self.isBigRoom && showMessge && aRoomUser.role != YSUserType_Patrol)
    {
        NSString *message = [NSString stringWithFormat:@"%@(%@) %@", aRoomUser.nickName,roleName,YSLocalized(@"Action.ExitRoom")];
        [self sendTipMessage:message tipType:YSChatMessageTypeTips];
    }
}

- (void)freshUserList
{
    if (!self.isBigRoom)
    {
        return;
    }
    
    NSMutableArray *userList = [[NSMutableArray alloc] init];
    for (YSRoomUser *roomUser in self.userList)
    {
        if (roomUser.publishState > YSUser_PublishState_NONE)
        {
            [userList addObject:roomUser];
        }
    }
    
    self.userList = userList;
}

- (void)removeUserWhenBigRoomWithPeerId:(NSString *)peerId
{
    if (!self.isBigRoom)
    {
        return;
    }
    
    for (YSRoomUser *roomUser in self.userList)
    {
        if ([peerId isEqualToString:roomUser.peerID])
        {
            if (roomUser.publishState <= YSUser_PublishState_NONE)
            {
                [self.userList removeObject:roomUser];
            }
            
            break;
        }
    }
}


#pragma mark - RoomDic

- (NSString *)room_Companyid
{
    return [self.roomDic bm_stringTrimForKey:@"companyid"];
}

- (NSString *)room_Id
{
    return [self.roomDic bm_stringTrimForKey:@"serial"];
}

- (NSString *)room_Name
{
    return [self.roomDic bm_stringTrimForKey:@"roomname"];
}

- (YSAppUseTheType)room_UseTheType
{
    return [self.roomDic bm_uintForKey:@"roomtype"];
}


- (NSTimeInterval)room_StartTime
{
    return [self.roomDic bm_doubleForKey:@"starttime"];
}

- (NSTimeInterval)room_EndTime
{
    return [self.roomDic bm_doubleForKey:@"endtime"];
}

- (BOOL)room_IsWideScreen
{
    // 房间最大分辨率 视频宽度
    CGFloat videowidth = [self.roomDic bm_doubleForKey:@"videowidth"];
    // 房间最大分辨率 视频高度
    CGFloat videoheight = [self.roomDic bm_doubleForKey:@"videoheight"];
    
    CGFloat ratio = videowidth / videoheight;
    if (fabs(ratio-16.0f/9.0f) < fabs(ratio-4.0f/3.0f))
    {
        return YES;
    }
    return NO;
}

#pragma mark - time

- (void)setTServiceTime:(NSTimeInterval)tServiceTime
{
    _tServiceTime = tServiceTime;
    
    BMLog(@"tServiceTime %@", [NSDate bm_stringFromTs:tServiceTime]);
    self.tHowMuchTimeServerFasterThenMe = tServiceTime - [[NSDate date] timeIntervalSince1970];
    BMLog(@"tHowMuchTimeServerFasterThenMe %@", @(self.tHowMuchTimeServerFasterThenMe));
}

- (NSTimeInterval)tCurrentTime
{
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970] + self.tHowMuchTimeServerFasterThenMe;
    
    return timeInterval;
}

- (NSTimeInterval)tPassedTime
{
    if (self.isBeginClass)
    {
        return self.tServiceTime - self.tClassStartTime;
    }
    
    return 0;
}


#pragma mark -
#pragma mark Room对外接口

// 旋转窗口
- (BOOL)setDeviceOrientation:(UIDeviceOrientation)orientation
{
    if ([self.roomManager setVideoOrientation:orientation] == 0)
    {
        return YES;
    }
    
    return NO;
}

// 退出房间
- (void)leaveRoom:(completion_block _Nullable)block
{
    [self.roomManager leaveRoom:block];
}

- (void)leaveRoom:(BOOL)force completion:(completion_block _Nullable)block
{
    [self.roomManager leaveRoom:force Completion:block];
}

// 设置视频分辨率
- (void)setVideoProfile:(YSVideoProfile *)videoProfile
{
    [self.roomManager setVideoProfile:videoProfile];
}

// 打开视频
- (int)playVideoOnView:(UIView *)view withPeerId:(NSString *)peerID renderType:(YSRenderMode)renderType completion:(completion_block)completion
{
    BOOL isHighDevice = [self devicePlatformHighEndEquipment];
    
    if (self.room_UseTheType != YSAppUseTheTypeSmallClass || !self.isBeginClass || isHighDevice || [peerID isEqualToString:self.localUser.peerID] || [peerID isEqualToString:self.teacher.peerID])
    {
        return [self.roomManager playVideo:peerID renderType:renderType window:view completion:completion];
    }
    else
    {
        return 1;
    }
}

// 关闭视频
- (void)stopPlayVideo:(NSString *)peerID completion:(void (^)(NSError *error))block
{
    [self.roomManager unPlayVideo:peerID completion:block];
}

// 打开音频
- (int)playAudio:(NSString *)peerID completion:(completion_block)completion
{
    return [self.roomManager playAudio:peerID completion:completion];
}

// 关闭音频
- (void)stopPlayAudio:(NSString *)peerID completion:(void (^)(NSError *error))block
{
    [self.roomManager unPlayAudio:peerID completion:block];
}

// 关闭媒体流
- (void)unpublishMedia:(void (^)(NSError *))block {
    
    [self.roomManager stopShareMediaFile:block];
}


#pragma mark -
#pragma mark YSRoomInterfaceDelegate

// 成功进入房间
- (void)onRoomJoined:(long)ts
{
    NSDictionary *roomDic = [self.roomManager getRoomProperty];
    self.roomDic = roomDic;
    // 房间配置项
    NSString *chairmancontrol = [roomDic bm_stringTrimForKey:@"chairmancontrol"];
    if ([chairmancontrol bm_isNotEmpty])
    {
        self.roomConfig = [[YSLiveRoomConfiguration alloc] initWithConfigurationString:chairmancontrol];
    }
    
    BMLog(@"%@", roomDic);
    
    NSTimeInterval timeInterval = ts;
    self.tServiceTime = timeInterval;
    
    BMLog(@"onRoomJoined %@", [NSDate bm_stringFromTs:timeInterval]);
    BMLog(@"local %@", [NSDate date]);
        
    //if (!self.viewDidAppear)
    //{
    //    [self addMsgCachePoolWithMethodName:@selector(onRoomJoined) parameters:nil];
    //
    //    return;
    //}
    
//    if (self.waitingForReconnect)
//    {
//
//    }
    
    if ([self.roomManagerDelegate respondsToSelector:@selector(onRoomJoined:)])
    {
        [self.roomManagerDelegate onRoomJoined:ts];
    }

    // 等待重连
    self.waitingForReconnect = NO;

    [self addRoomUser:self.roomManager.localUser showMessge:YES];
}

// 已经离开房间
- (void)onRoomLeft
{
    BMLog(@"onRoomLeft");
    
    if (!self.viewDidAppear)
    {
        [self addMsgCachePoolWithMethodName:@selector(onRoomLeft) parameters:nil];
        
        return;
    }
    
    if ([self.roomManagerDelegate respondsToSelector:@selector(onRoomLeft)])
    {
        [self.roomManagerDelegate onRoomLeft];
    }
    
#if YSSDK
    if ([self.sdkDelegate respondsToSelector:@selector(onRoomLeft)])
    {
        [self.sdkDelegate onRoomLeft];
    }
#endif
    
    //[self delRoomUser:self.localUser showMessge:NO];
}

// 送花
- (void)handleSignalingSendFlowerWithSenderId:(NSString *)senderId senderName:(NSString *)senderName
{
    if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingSendFlowerWithSenderId:senderName:)])
    {
        [self.roomManagerDelegate handleSignalingSendFlowerWithSenderId:senderId senderName:senderName];
    }
}

// 失去连接
- (void)onRoomConnectionLost
{
    BMLog(@"onRoomConnectionLost");
    
    // 等待重连
    self.waitingForReconnect = YES;

    if ([self.roomManagerDelegate respondsToSelector:@selector(onRoomConnectionLost)])
    {
        [self.roomManagerDelegate onRoomConnectionLost];
    }
    
#if YSSDK
    if ([self.sdkDelegate respondsToSelector:@selector(onRoomConnectionLost)])
    {
        [self.sdkDelegate onRoomConnectionLost];
    }
#endif
}

// 发生错误 回调
- (void)onRoomDidOccuredError:(NSError *)error
{
    BMLog(@"onRoomDidOccuredError");
    
    BMLog(@"%@", error.description);
    NSString *alertMessage = nil;
    NSInteger errorCode = error.code;
    if (errorCode == YSErrorCode_CheckRoom_NeedPassword ||
        errorCode == YSErrorCode_CheckRoom_PasswordError ||
        errorCode == YSErrorCode_CheckRoom_WrongPasswordForRole)
    { // 密码弹出 处理进入主界面之前的错误
        if ([self.roomManagerDelegate respondsToSelector:@selector(roomManagerNeedEnterPassWord:)])
        {
            [self.roomManagerDelegate roomManagerNeedEnterPassWord:errorCode];
        }
        return;
    }

    //if (errorCode > YSErrorCode_ConnectSocketError)
    {
        alertMessage = [self onRoomDidOccuredErrorCode:errorCode];
        if ([self.roomManagerDelegate respondsToSelector:@selector(roomManagerReportFail:descript:)])
        {
            [self.roomManagerDelegate roomManagerReportFail:errorCode descript:alertMessage];
        }
        return;
    }
#if 0
    if (!self.viewDidAppear)
    {
        NSMutableArray *parameters = [[NSMutableArray alloc] init];
        if ([error bm_isNotEmpty])
        {
            [parameters addObject:error];
        }
        else
        {
            [parameters addObject:[NSNull null]];
        }
        [self addMsgCachePoolWithMethodName:@selector(onRoomDidOccuredError:) parameters:parameters];
        
        return;
    }
    
    alertMessage = [self onRoomDidOccuredErrorCode:errorCode];

    if (errorCode == YSErrorCode_CheckRoom_NeedPassword ||
        errorCode == YSErrorCode_CheckRoom_PasswordError ||
        errorCode == YSErrorCode_CheckRoom_WrongPasswordForRole)
    { // 密码弹出
        if ([self.roomManagerDelegate respondsToSelector:@selector(roomManagerNeedEnterPassWord:)])
        {
            [self.roomManagerDelegate roomManagerNeedEnterPassWord:errorCode];
        }
    }
    else
    {
        if ([self.roomManagerDelegate respondsToSelector:@selector(roomManagerReportFail:descript:)])
        {
            [self.roomManagerDelegate roomManagerReportFail:errorCode descript:alertMessage];
        }
    }
#endif
    //    if ([self.roomManagerDelegate respondsToSelector:@selector(onRoomDidOccuredError:)])
    //    {
    //        [self.roomManagerDelegate onRoomDidOccuredError:error];
    //    }
}

// 发生警告 回调
// @param code 警告码
- (void)onRoomDidOccuredWaring:(YSRoomWarningCode)code
{
    if (!self.viewDidAppear)
    {
        [self addMsgCachePoolWithMethodName:@selector(onRoomDidOccuredWaring:) parameters:@[ @(code) ]];
    }
    
    // YSRoomWarning_CheckRoom_Completed
    BMLog(@"onRoomDidOccuredWaring code:%@", @(code));
    
    if ([self.roomManagerDelegate respondsToSelector:@selector(onRoomDidOccuredWaring:)])
    {
        [self.roomManagerDelegate onRoomDidOccuredWaring:code];
    }
}

// 有用户进入房间
// @param peerID 用户ID
// @param inList true：在自己之前进入；false：在自己之后进入
- (void)onRoomUserJoined:(NSString *)peerID inList:(BOOL)inList
{
    BMLog(@"roomManagerUserJoined peerID: %@", peerID);
    
    //    TKRoomUser *roomUser = [self.roomManager getRoomUserWithUId:peerID];
    //    [self addRoomUser:roomUser];
    
    if (!self.viewDidAppear)
    {
        NSMutableArray *parameters = [[NSMutableArray alloc] init];
        if ([peerID bm_isNotEmpty])
        {
            [parameters addObject:peerID];
        }
        else
        {
            [parameters addObject:[NSNull null]];
        }
        [parameters addObject:@(inList)];
        [self addMsgCachePoolWithMethodName:@selector(onRoomUserJoined:inList:) parameters:parameters];
        
        return;
    }
    
    YSRoomUser *roomUser = [self.roomManager getRoomUserWithUId:peerID];
    [self addRoomUser:roomUser showMessge:!inList];
    
    if ([self.roomManagerDelegate respondsToSelector:@selector(roomManagerJoinedUser:inList:)])
    {
        [self.roomManagerDelegate roomManagerJoinedUser:roomUser inList:inList];
    }
    else if ([self.roomManagerDelegate respondsToSelector:@selector(onRoomUserJoined:inList:)])
    {
        [self.roomManagerDelegate onRoomUserJoined:peerID inList:inList];
    }
}

// 有用户离开房间
// @param peerID 用户ID
- (void)onRoomUserLeft:(NSString *)peerID
{
    BMLog(@"onRoomUserLeft peerID: %@", peerID);
    
    //    TKRoomUser *roomUser = [self.roomManager getRoomUserWithUId:peerID];
    //    [self delRoomUser:roomUser];
    
    if (!self.viewDidAppear)
    {
        NSMutableArray *parameters = [[NSMutableArray alloc] init];
        if ([peerID bm_isNotEmpty])
        {
            [parameters addObject:peerID];
        }
        else
        {
            [parameters addObject:[NSNull null]];
        }
        [self addMsgCachePoolWithMethodName:@selector(onRoomUserLeft:) parameters:parameters];
        
        return;
    }
    
    YSRoomUser *roomUser = [self.roomManager getRoomUserWithUId:peerID];
    [self delRoomUser:roomUser showMessge:YES];
    
    if ([self.roomManagerDelegate respondsToSelector:@selector(roomManagerLeftUser:)])
    {
        [self.roomManagerDelegate roomManagerLeftUser:roomUser];
    }
    else if ([self.roomManagerDelegate respondsToSelector:@selector(onRoomUserLeft:)])
    {
        [self.roomManagerDelegate onRoomUserLeft:peerID];
    }
}

// 自己被踢出房间
// @param reason 被踢原因
- (void)onRoomKickedOut:(NSDictionary *)reason
{
    BMLog(@"onRoomKickedOut reason: %@", reason);
    
    NSUInteger reasonCode = [reason bm_uintForKey:@"reason"];
    if (reasonCode == 1)
    {
        NSString *roomId = YSKickTime;
        if ([self.room_Id bm_isNotEmpty])
        {
            roomId = [NSString stringWithFormat:@"%@_%@", YSKickTime, self.room_Id ];
        }
        
        // 存储被踢时间
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:roomId];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if (!self.viewDidAppear)
    {
        NSMutableArray *parameters = [[NSMutableArray alloc] init];
        if ([reason bm_isNotEmpty])
        {
            [parameters addObject:reason];
        }
        else
        {
            [parameters addObject:[NSNull null]];
        }
        [self addMsgCachePoolWithMethodName:@selector(onRoomKickedOut:) parameters:parameters];
        
        return;
    }
    
    if ([self.roomManagerDelegate respondsToSelector:@selector(onRoomKickedOut:)])
    {
        [self.roomManagerDelegate onRoomKickedOut:reason];
    }
    
#if YSSDK
    if ([self.sdkDelegate respondsToSelector:@selector(onRoomKickedOut:)])
    {
        [self.sdkDelegate onRoomKickedOut:reason];
    }
#endif
}

// 有用户的属性发生了变化
// @param peerID 用户ID
// @param properties 发生变化的属性
// @param fromId 修改用户属性消息的发送方的id
- (void)onRoomUserPropertyChanged:(NSString *)peerID properties:(NSDictionary *)properties fromId:(NSString *)fromId
{
    if (!self.viewDidAppear)
    {
        NSMutableArray *parameters = [[NSMutableArray alloc] init];
        if ([peerID bm_isNotEmpty])
        {
            [parameters addObject:peerID];
        }
        else
        {
            [parameters addObject:[NSNull null]];
        }
        if ([properties bm_isNotEmpty])
        {
            [parameters addObject:properties];
        }
        else
        {
            [parameters addObject:[NSNull null]];
        }
        if ([fromId bm_isNotEmpty])
        {
            [parameters addObject:fromId];
        }
        else
        {
            [parameters addObject:[NSNull null]];
        }
        [self addMsgCachePoolWithMethodName:@selector(onRoomUserPropertyChanged:properties:fromId:) parameters:parameters];
        
        return;
    }
    
    [self removeUserWhenBigRoomWithPeerId:peerID];
    
    if ([self.roomManagerDelegate respondsToSelector:@selector(onRoomUserPropertyChanged:properties:fromId:)])
    {
        [self.roomManagerDelegate onRoomUserPropertyChanged:peerID properties:properties fromId:fromId];
    }
}

// 用户视频状态变化的通知
//  @param peerID 用户ID
// @param state 视频状态
- (void)onRoomUserVideoStatus:(NSString *)peerID state:(YSMediaState)state
{
    if (!self.viewDidAppear)
    {
        NSMutableArray *parameters = [[NSMutableArray alloc] init];
        if ([peerID bm_isNotEmpty])
        {
            [parameters addObject:peerID];
        }
        else
        {
            [parameters addObject:[NSNull null]];
        }
        [parameters addObject:@(state)];
        [self addMsgCachePoolWithMethodName:@selector(onRoomUserVideoStatus:state:) parameters:parameters];
        
        return;
    }
    
    if (state == YSMedia_Pulished)
    {
        if ([peerID bm_isNotEmpty])
        {
            if ([self.roomManagerDelegate respondsToSelector:@selector(handleRoomPlayMediaWithPeerID:)])
            {
                [self.roomManagerDelegate handleRoomPlayMediaWithPeerID:peerID];
            }
        }
    }
    else
    {
        if ([peerID bm_isNotEmpty])
        {
            if ([self.roomManagerDelegate respondsToSelector:@selector(handleRoomPauseMediaWithPeerID:)])
            {
                [self.roomManagerDelegate handleRoomPauseMediaWithPeerID:peerID];
            }
        }
    }
    
    if ([self.roomManagerDelegate respondsToSelector:@selector(onRoomUserVideoStatus:state:)])
    {
        [self.roomManagerDelegate onRoomUserVideoStatus:peerID state:state];
    }
}

// 用户某一视频设备的视频状态变化的通知（多流模式）
// @param peerID 用户ID
// @param deviceId 视频设备ID
// @param state 视频状态
- (void)onRoomUserVideoStatus:(NSString *)peerID deviceId:(NSString *)deviceId state:(YSMediaState)state
{
    
}

// 用户音频状态变化的通知，
// @param peerID 用户ID
// @param state 音频状态
- (void)onRoomUserAudioStatus:(NSString *)peerID state:(YSMediaState)state
{
    if (!self.viewDidAppear)
    {
        NSMutableArray *parameters = [[NSMutableArray alloc] init];
        if ([peerID bm_isNotEmpty])
        {
            [parameters addObject:peerID];
        }
        else
        {
            [parameters addObject:[NSNull null]];
        }
        [parameters addObject:@(state)];
        [self addMsgCachePoolWithMethodName:@selector(onRoomUserAudioStatus:state:) parameters:parameters];
        
        return;
    }
    
    if (state == YSMedia_Pulished)
    {
        if ([peerID bm_isNotEmpty])
        {
            if ([self.roomManagerDelegate respondsToSelector:@selector(handleRoomPlayAudioWithPeerID:)])
            {
                [self.roomManagerDelegate handleRoomPlayAudioWithPeerID:peerID];
            }
        }
    }
    else
    {
        if ([peerID bm_isNotEmpty])
        {
            if ([self.roomManagerDelegate respondsToSelector:@selector(handleRoomPauseAudioWithPeerID:)])
            {
                [self.roomManagerDelegate handleRoomPauseAudioWithPeerID:peerID];
            }
        }
    }
    
    //    if ([self.roomManagerDelegate respondsToSelector:@selector(onRoomUserAudioStatus:state:)])
    //    {
    //        [self.roomManagerDelegate onRoomUserAudioStatus:peerID state:state];
    //    }
}

// 收到自定义信令 发布消息
// @param msgID 消息id
// @param msgName 消息名字
// @param ts 消息时间戳
// @param data 消息数据，可以是Number、String、NSDictionary或NSArray
// @param fromID  消息发布者的ID
// @param inlist 是否是inlist中的信息
- (void)onRoomRemotePubMsgWithMsgID:(NSString *)msgID msgName:(NSString *)msgName data:(NSObject *)data fromID:(NSString *)fromID inList:(BOOL)inlist ts:(long)ts body:(NSDictionary *)msgBody
{
    if (!self.viewDidAppear)
    {
        NSMutableArray *parameters = [[NSMutableArray alloc] init];
        if ([msgID bm_isNotEmpty])
        {
            [parameters addObject:msgID];
        }
        else
        {
            [parameters addObject:[NSNull null]];
        }
        if ([msgName bm_isNotEmpty])
        {
            [parameters addObject:msgName];
        }
        else
        {
            [parameters addObject:[NSNull null]];
        }
        if ([data bm_isNotEmpty])
        {
            [parameters addObject:data];
        }
        else
        {
            [parameters addObject:[NSNull null]];
        }
        if ([fromID bm_isNotEmpty])
        {
            [parameters addObject:fromID];
        }
        else
        {
            [parameters addObject:[NSNull null]];
        }
        [parameters addObject:@(inlist)];
        [parameters addObject:@(ts)];
        [parameters addObject:msgBody];
        [self addMsgCachePoolWithMethodName:@selector(onRoomRemotePubMsgWithMsgID:msgName:data:fromID:inList:ts:body:) parameters:parameters];
        
        return;
    }
        
    // 房间用户数
    if ([msgName isEqualToString:YSSignalingName_Notice_BigRoom_Usernum])
    {
        NSDictionary *dataDic = [YSLiveUtil convertWithData:data];
        
        // Notice_BigRoom_Usernum 表示大房间模式下，当前的房间用户数,格式如下
        // id: "Notice_BigRoom_Usernum"
        // name: "Notice_BigRoom_Usernum"
        // do_not_save: ""
        // toID: "__all"
        // data: "{"num":2,"rolenums":{"0":0,"1":0,"2":2,"3":0,"4":0,"5":0}}"
        // 5: 班主任
        if ([dataDic bm_isNotEmptyDictionary])
        {
            NSUInteger count = [dataDic bm_uintForKey:@"num"];
            NSDictionary *detailCountDic = [dataDic bm_dictionaryForKey:@"rolenums"];
            
            self.userCount = count;
            self.userCountDetailDic = detailCountDic;
            
            if (!self.isBigRoom)
            {
                self.isBigRoom = YES;
                [self freshUserList];
                if ([self.roomManagerDelegate respondsToSelector:@selector(roomManagerChangeToBigRoom)])
                {
                    [self.roomManagerDelegate roomManagerChangeToBigRoom];
                }
            }
        }
        
        return;
    }
    
    /// 用户网络差，被服务器切换媒体线路
    if ([msgName isEqualToString:YSSignalingName_Notice_ChangeMediaLine])
    {
        NSDictionary *dataDic = [YSLiveUtil convertWithData:data];
        
        // name:"Notice_ChangeMediaLine"
        // id:"Notice_ChangeMediaLine"
        // toID:"被切线路的用户id"
        // do_not_save: ""
        // data: "{"oldline":"bjct", "line":"cna", "userId":"123456"}"
        // fromID:"__YSServer"
        if ([dataDic bm_isNotEmptyDictionary])
        {
            NSString *userId = [dataDic bm_stringTrimForKey:@"userId"];
            
            if ([userId isEqualToString:self.localUser.peerID])
            {
                if ([self.roomManagerDelegate respondsToSelector:@selector(roomManagerChangeMediaLine)])
                {
                    [self.roomManagerDelegate roomManagerChangeMediaLine];
                }
            }
        }
        
        return;
    }
    
    [self handleRoomPubMsgWithMsgID:msgID msgName:msgName data:data fromID:fromID inList:inlist ts:ts body:msgBody];
}

// 收到自定义信令 删去消息
// @param msgID 消息id
// @param msgName 消息名字
// @param ts 消息时间戳
// @param data 消息数据，可以是Number、String、NSDictionary或NSArray
// @param fromID  消息发布者的ID
// @param inlist 是否是inlist中的信息
- (void)onRoomRemoteDelMsgWithMsgID:(NSString *)msgID msgName:(NSString *)msgName data:(NSObject *)data fromID:(NSString *)fromID inList:(BOOL)inlist ts:(long)ts
{
    if (!self.viewDidAppear)
    {
        NSMutableArray *parameters = [[NSMutableArray alloc] init];
        if ([msgID bm_isNotEmpty])
        {
            [parameters addObject:msgID];
        }
        else
        {
            [parameters addObject:[NSNull null]];
        }
        if ([msgName bm_isNotEmpty])
        {
            [parameters addObject:msgName];
        }
        else
        {
            [parameters addObject:[NSNull null]];
        }
        if ([data bm_isNotEmpty])
        {
            [parameters addObject:data];
        }
        else
        {
            [parameters addObject:[NSNull null]];
        }
        if ([fromID bm_isNotEmpty])
        {
            [parameters addObject:fromID];
        }
        else
        {
            [parameters addObject:[NSNull null]];
        }
        [parameters addObject:@(inlist)];
        [parameters addObject:@(ts)];
        [self addMsgCachePoolWithMethodName:@selector(onRoomRemoteDelMsgWithMsgID:msgName:data:fromID:inList:ts:) parameters:parameters];
        
        return;
    }
    
    
    [self handleRoomDelMsgWithMsgID:msgID msgName:msgName data:data fromID:fromID inList:inlist ts:ts];
}

// 收到聊天消息
// @param message 聊天消息内容
// @param peerID 发送者用户ID
// @param extension 消息扩展信息（用户昵称、用户角色等等）
- (void)onRoomMessageReceived:(NSString *)message fromID:(NSString *)peerID extension:(NSDictionary *)extension
{
    if (!self.viewDidAppear)
    {
        NSMutableArray *parameters = [[NSMutableArray alloc] init];
        if ([message bm_isNotEmpty])
        {
            [parameters addObject:message];
        }
        else
        {
            [parameters addObject:[NSNull null]];
        }
        if ([peerID bm_isNotEmpty])
        {
            [parameters addObject:peerID];
        }
        else
        {
            [parameters addObject:[NSNull null]];
        }
        if ([extension bm_isNotEmpty])
        {
            [parameters addObject:extension];
        }
        else
        {
            [parameters addObject:[NSNull null]];
        }
        [self addMsgCachePoolWithMethodName:@selector(onRoomMessageReceived:fromID:extension:) parameters:parameters];
        
        return;
    }
    
    [self handleMessageReceived:message fromID:peerID extension:extension];
}

// 视频数据统计
// @param peerId 用户ID
// @param stats 数据信息
- (void)onRoomVideoStatsReport:(NSString *)peerId stats:(YSVideoStats *)stats
{
    //BMLog(@"onRoomVideoStatsReport");
    
    if (!stats)
    {
        return;
    }
    
    if ([peerId isEqualToString:self.localUser.peerID])
    {
        if ([self.roomManagerDelegate respondsToSelector:@selector(roomManagerUserChangeNetStats:)])
        {
            [self.roomManagerDelegate roomManagerUserChangeNetStats:stats];
        }
    }
    else if ([peerId isEqualToString:self.teacher.peerID])
    {
        if ([self.roomManagerDelegate respondsToSelector:@selector(roomManagerTeacherChangeNetStats:)])
        {
            [self.roomManagerDelegate roomManagerTeacherChangeNetStats:stats];
        }
    }
    
    if ([self.roomManagerDelegate respondsToSelector:@selector(onRoomVideoStatsReport:stats:)])
    {
        [self.roomManagerDelegate onRoomVideoStatsReport:peerId stats:stats];
    }
}


// 音频数据统计
// @param peerId 用户ID
// @param stats 数据信息
- (void)onRoomAudioStatsReport:(NSString *)peerId stats:(YSAudioStats *)stats
{
    //BMLog(@"onRoomAudioStatsReport");
    
    if (!stats)
    {
        return;
    }
    
    if ([peerId isEqualToString:self.localUser.peerID])
    {
        if ([self.roomManagerDelegate respondsToSelector:@selector(roomManagerUserChangeNetStats:)])
        {
            [self.roomManagerDelegate roomManagerUserChangeNetStats:stats];
        }
    }
    else if ([peerId isEqualToString:self.teacher.peerID])
    {
        if ([self.roomManagerDelegate respondsToSelector:@selector(roomManagerTeacherChangeNetStats:)])
        {
            [self.roomManagerDelegate roomManagerTeacherChangeNetStats:stats];
        }
    }
    
    if ([self.roomManagerDelegate respondsToSelector:@selector(onRoomAudioStatsReport:stats:)])
    {
        [self.roomManagerDelegate onRoomAudioStatsReport:peerId stats:stats];
    }
}

// 音视频统计数据
// @param stats 视频和音频的统计数据
- (void)onRoomRtcStatsReport:(YSRtcStats *)stats
{
    //BMLog(@"onRoomRtcStatsReport");
    
    if (!stats)
    {
        return;
    }
    
    if ([self.roomManagerDelegate respondsToSelector:@selector(onRoomRtcStatsReport:)])
    {
        [self.roomManagerDelegate onRoomRtcStatsReport:stats];
    }
}

// 用户的音频音量大小变化的回调
// @param peeID 用户ID
// @param volume 音量大小（0 - 32670）
- (void)onRoomAudioVolumeWithPeerID:(NSString *)peeID volume:(int)volume
{
    if ([peeID isEqualToString:self.localUser.peerID])
    {
        self.iVolume = volume;
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSelfAudioVolumeChanged)])
        {
            [self.roomManagerDelegate handleSelfAudioVolumeChanged];
        }
    }
    else
    {
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleOtherAudioVolumeChangedWithPeerID:volume:)])
        {
            [self.roomManagerDelegate handleOtherAudioVolumeChangedWithPeerID:peeID volume:volume];
        }
    }
    
    //    if ([self.roomManagerDelegate respondsToSelector:@selector(onRoomAudioVolumeWithPeerID:volume:)])
    //    {
    //        [self.roomManagerDelegate onRoomAudioVolumeWithPeerID:peeID volume:volume];
    //    }
}

// 纯音频 与音视频 教室切换
// @param fromId 用户ID  切换房间模式的用户ID
// @param onlyAudio 是否是纯音频
- (void)onRoomAudioRoomSwitch:(NSString *)fromId onlyAudio:(BOOL)onlyAudio
{
    if ([self.roomManagerDelegate respondsToSelector:@selector(onRoomAudioRoomSwitch:onlyAudio:)])
    {
        [self.roomManagerDelegate onRoomAudioRoomSwitch:fromId onlyAudio:onlyAudio];
    }
}

// 播放某用户视频，渲染视频第一帧时，会收到回调；如果没有unplay某用户的视频，而再次play该用户视频时，不会再次收到此回调。
// @param peerID 用户ID
// @param width 视频宽
// @param height 视频高
// @param type 视频类型
- (void)onRoomFirstVideoFrameWithPeerID:(NSString *)peerID width:(NSInteger)width height:(NSInteger)height mediaType:(YSMediaType)type
{
    if ([self.roomManagerDelegate respondsToSelector:@selector(onRoomFirstVideoFrameWithPeerID:width:height:mediaType:)])
    {
        [self.roomManagerDelegate onRoomFirstVideoFrameWithPeerID:peerID width:width height:height mediaType:type];
    }
}

// 播放用户某一视频设备视频，渲染视频第一帧时，会收到回调；如果没有unplay，而再次play视频时，不会再次收到此回调。
// @param peerID 用户ID
// @param deviceId 视频设备ID
// @param width 视频宽
// @param height 视频高
// @param type 视频类型
- (void)onRoomFirstVideoFrameWithPeerID:(NSString *)peerID deviceId:(NSString *)deviceId width:(NSInteger)width height:(NSInteger)height mediaType:(YSMediaType)type
{
    
}

// 视频播放过程中画面状态回调
// @param peerId 用户ID
// @param deviceId 视频设备ID
// @param state 画面状态
// @param type 视频类型
- (void)onRoomVideoStateChange:(NSString *)peerId deviceId:(NSString *)deviceId videoState:(YSRenderState)state mediaType:(YSMediaType)type
{
    //YSRenderState_Resumption   YSRenderState_Interruption
    //YSMediaSourceType_camera
}

// 音频播放过程中状态回调
// @param peerId 用户ID
// @param state 音频状态
// @param type 类型
- (void)onRoomAudioStateChange:(NSString *)peerId audioState:(YSRenderState)state mediaType:(YSMediaType)type
{
    BMLog(@"%@: %@", peerId, @(state));
    
}

// 播放某用户音频，会收到此回调；如果没有unplay某用户的音频，而再次play该用户音频时，不会再次收到此回调。
// @param peerID 用户ID
// @param type 音频类型
- (void)onRoomFirstAudioFrameWithPeerID:(NSString *)peerID mediaType:(YSMediaType)type
{
    
}

// 网络测速回调
// @param networkQuality 网速质量 (TKNetQuality_Down 测速失败)
// @param delay 延迟(毫秒)
- (void)onRoomNetworkQuality:(YSNetQuality)networkQuality delay:(NSInteger)delay
{
    if (!self.viewDidAppear)
    {
        [self addMsgCachePoolWithMethodName:@selector(onRoomNetworkQuality:delay:) parameters:@[ @(networkQuality), @(delay) ]];
        
        return;
    }
    
    if ([self.roomManagerDelegate respondsToSelector:@selector(onRoomNetworkQuality:delay:)])
    {
        [self.roomManagerDelegate onRoomNetworkQuality:networkQuality delay:delay];
    }
}


#pragma mark meidia

// 用户媒体流发布状态 变化回调
// @param peerId 用户id
// @param state 0:取消  非0：发布
// @param message 扩展消息
- (void)onRoomShareMediaState:(NSString *)peerId state:(YSMediaState)state extensionMessage:(NSDictionary *)message
{
    if (!self.viewDidAppear)
    {
        NSMutableArray *parameters = [[NSMutableArray alloc] init];
        if ([peerId bm_isNotEmpty])
        {
            [parameters addObject:peerId];
        }
        else
        {
            [parameters addObject:[NSNull null]];
        }
        [parameters addObject:@(state)];
        if ([message bm_isNotEmpty])
        {
            [parameters addObject:message];
        }
        else
        {
            [parameters addObject:[NSNull null]];
        }
        [self addMsgCachePoolWithMethodName:@selector(onRoomShareMediaState:state:extensionMessage:) parameters:parameters];
        
        return;
    }
    
    if (state == YSMedia_Pulished)
    {
        YSLiveMediaModel *mediaModel = [YSLiveMediaModel mediaModelWithDic:message];
        if (mediaModel)
        {
            mediaModel.user_peerId = peerId;
            self.playMediaModel = mediaModel;
            self.playingMedia = YES;
            if ([self.roomManagerDelegate respondsToSelector:@selector(handleWhiteBordPlayMediaFileWithMedia:)])
            {
                [self.roomManagerDelegate handleWhiteBordPlayMediaFileWithMedia:mediaModel];
            }
        }
    }
    else
    {
        if (self.playMediaModel)
        {
            if ([self.roomManagerDelegate respondsToSelector:@selector(handleWhiteBordStopMediaFileWithMedia:)])
            {
                YSLiveMediaModel *playMediaModel = self.playMediaModel;
                [self.roomManagerDelegate handleWhiteBordStopMediaFileWithMedia:playMediaModel];
            }
            self.playMediaModel = nil;
        }
        
        self.playingMedia = NO;
    }
}

// 更新媒体流的信息回调
// @param duration 媒体流当前播放的时间点
// @param pos 媒体流当前的进度
// @param isPlay 播放（YES）暂停（NO）
- (void)onRoomUpdateMediaStream:(NSTimeInterval)duration pos:(NSTimeInterval)pos isPlay:(BOOL)isPlay
{
    if (!self.viewDidAppear)
    {
        [self addMsgCachePoolWithMethodName:@selector(onRoomUpdateMediaStream:pos:isPlay:) parameters:@[ @(duration), @(pos), @(isPlay)]];
        
        return;
    }
    
    if (isPlay)
    {
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleWhiteBordPlayMediaStream)])
        {
            [self.roomManagerDelegate handleWhiteBordPlayMediaStream];
        }
    }
    else
    {
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleWhiteBordPauseMediaStream)])
        {
            [self.roomManagerDelegate handleWhiteBordPauseMediaStream];
        }
    }
    
    
    if ([self.roomManagerDelegate respondsToSelector:@selector(onRoomUpdateMediaStream:pos:isPlay:)])
    {
        [self.roomManagerDelegate onRoomUpdateMediaStream:duration pos:pos isPlay:isPlay];
    }
}

// 媒体流加载出第一帧画面回调
- (void)onRoomMediaLoaded
{
    if (!self.viewDidAppear)
    {
        [self addMsgCachePoolWithMethodName:@selector(onRoomMediaLoaded) parameters:nil];
        
        return;
    }
    
    if ([self.roomManagerDelegate respondsToSelector:@selector(onRoomMediaLoaded)])
    {
        [self.roomManagerDelegate onRoomMediaLoaded];
    }
}


#pragma mark screen

// 用户桌面共享状态 变化回调
// @param peerId 用户id
// @param state 状态0:取消  非0：发布
- (void)onRoomShareScreenState:(NSString *)peerId state:(YSMediaState)state
{
    if (!self.viewDidAppear)
    {
        NSMutableArray *parameters = [[NSMutableArray alloc] init];
        if ([peerId bm_isNotEmpty])
        {
            [parameters addObject:peerId];
        }
        else
        {
            [parameters addObject:[NSNull null]];
        }
        [parameters addObject:@(state)];
        [self addMsgCachePoolWithMethodName:@selector(onRoomShareScreenState:state:) parameters:parameters];
        
        return;
    }
    
    if (state == YSMedia_Pulished)
    {
        if ([peerId bm_isNotEmpty])
        {
            self.sharePeerId = peerId;
            
            if ([self.roomManagerDelegate respondsToSelector:@selector(handleRoomStartShareDesktopWithPeerID:)])
            {
                [self.roomManagerDelegate handleRoomStartShareDesktopWithPeerID:peerId];
            }
        }
    }
    else
    {
        if ([peerId bm_isNotEmpty])
        {
            if ([self.roomManagerDelegate respondsToSelector:@selector(handleRoomStopShareDesktopWithPeerID:)])
            {
                NSString *sharePeerId = [peerId copy];
                self.sharePeerId = nil;
                [self.roomManagerDelegate handleRoomStopShareDesktopWithPeerID:sharePeerId];
            }
        }
    }
    
    
    if ([self.roomManagerDelegate respondsToSelector:@selector(onRoomShareScreenState:state:)])
    {
        [self.roomManagerDelegate onRoomShareScreenState:peerId state:state];
    }
}

#pragma mark file
// 用户电影共享状态 变化回调
// @param peerId 用户id
// @param state 状态0:取消  非0：发布
// @param message 扩展消息
- (void)onRoomShareFileState:(NSString *)peerId state:(YSMediaState)state extensionMessage:(NSDictionary *)message
{
    if (!self.viewDidAppear)
    {
        NSMutableArray *parameters = [[NSMutableArray alloc] init];
        if ([peerId bm_isNotEmpty])
        {
            [parameters addObject:peerId];
        }
        else
        {
            [parameters addObject:[NSNull null]];
        }
        [parameters addObject:@(state)];
        if ([message bm_isNotEmpty])
        {
            [parameters addObject:message];
        }
        else
        {
            [parameters addObject:[NSNull null]];
        }
        [self addMsgCachePoolWithMethodName:@selector(onRoomShareFileState:state:extensionMessage:) parameters:parameters];
        
        return;
    }
    
    if ([self.roomManagerDelegate respondsToSelector:@selector(onRoomShareFileState:state:extensionMessage:)])
    {
        [self.roomManagerDelegate onRoomShareFileState:peerId state:state extensionMessage:message];
    }
}


#pragma mark -
#pragma mark YSWhiteBoardManagerDelegate

// 文件列表回调
// @param fileList 文件列表 是一个NSArray类型的数据
- (void)onWhiteBroadFileList:(NSArray *)fileList
{
    BMLog(@"onWhiteBroadFileList");

    // 添加一个白板 只用于文件列表显示
    NSNumber *companyid = @([self.room_Companyid integerValue]);
    [self.whiteBoardManager createWhiteBoard:companyid];
}

// PubMsg消息
- (void)onWhiteBroadPubMsgWithMsgID:(NSString *)msgID
                            msgName:(NSString *)msgName
                               data:(NSObject *)data
                             fromID:(NSString *)fromID
                             inList:(BOOL)inlist
                                 ts:(long)ts
{
    [self handleWhiteBroadPubMsgWithMsgID:msgID msgName:msgName data:data fromID:fromID inList:inlist ts:ts];
}

// msglist消息
// @param msgList 消息
- (void)onWhiteBoardOnRoomConnectedMsglist:(NSDictionary *)msgList
{
    BMLog(@"onWhiteBoardOnRoomConnectedMsglist");
    BMLog(@"%@", msgList);
}

// 界面更新
- (void)onWhiteBoardViewStateUpdate:(NSDictionary *)message
{
    if (!self.viewDidAppear)
    {
        NSMutableArray *parameters = [[NSMutableArray alloc] init];
        if ([message bm_isNotEmpty])
        {
            [parameters addObject:message];
        }
        else
        {
            [parameters addObject:[NSNull null]];
        }
        [self addMsgCachePoolWithMethodName:@selector(onWhiteBoardViewStateUpdate:) parameters:parameters];
        
        return;
    }

    if (self.roomManagerDelegate && [self.roomManagerDelegate respondsToSelector:@selector(onWhiteBoardViewStateUpdate:)])
    {
        [self.roomManagerDelegate onWhiteBoardViewStateUpdate:message];
    }
}

// 教室加载状态
- (void)onWhiteBoardLoadedState:(NSDictionary *)message
{
    if (self.roomManagerDelegate && [self.roomManagerDelegate respondsToSelector:@selector(onWhiteBoardLoadedState:)])
    {
        [self.roomManagerDelegate onWhiteBoardLoadedState:message];
    }
}

// 本地操作，缩放课件比例变化
- (void)onWhiteBoardFileViewZoomScaleChanged:(CGFloat)zoomScale
{
    if (self.roomManagerDelegate && [self.roomManagerDelegate respondsToSelector:@selector(onWhiteBoardFileViewZoomScaleChanged:)])
    {
        [self.roomManagerDelegate onWhiteBoardFileViewZoomScaleChanged:zoomScale];
    }
}


#pragma mark -
#pragma mark setter/getter

- (BOOL)isBeginClass
{
    return self.whiteBoardManager.isBeginClass;
}

// 记录UI层是否开始上课
- (void)setIsBeginClass:(BOOL)isBeginClass
{
    self.whiteBoardManager.isBeginClass = isBeginClass;
}

- (BOOL)playingMedia
{
    return self.whiteBoardManager.playingMedia;
}

// 记录UI层是否正在播放媒体
- (void)setPlayingMedia:(BOOL)playingMedia
{
    self.whiteBoardManager.playingMedia = playingMedia;
}


#pragma mark -
#pragma mark Func

- (YSFileModel *)currentFile
{
    return [self.whiteBoardManager currentFile];
}

- (NSArray <YSFileModel *> *)fileList
{
    return [self.whiteBoardManager.docmentList copy];
}

- (YSFileModel *)getFileWithFileID:(NSString *)fileId;
{
    YSFileModel *file = [self.whiteBoardManager getDocumentWithFileID:fileId];
    return file;
}

#pragma mark -
#pragma mark 信令消息

///**
// 发布自定义消息
//
// @param msgName 消息名字
// @param msgID ：消息id
// @param toID 要通知给哪些用户。NSString类型，详情见 YSRoomDefines.h 相关定义. 可以是某一用户ID，表示此信令只发送给该用户
// @param data 消息数据，可以是Number、String、NSDictionary或NSArray
// @param save ：是否保存，详见3.5：自定义信令
// @param completion 完成的回调
// @return 0表示调用成功，非0表示调用失败
// */
//- (int)pubMsg:(NSString *)msgName
//        msgID:(NSString *)msgID
//         toID:(NSString *)toID
//         data:(NSObject * _Nullable)data
//         save:(BOOL)save
//   completion:(completion_block _Nullable)completion;
//
////expires ：这个消息，多长时间结束，以秒为单位，是相对时间。一般用于classbegin，给定一个相对时间
//- (int)pubMsg:(NSString *)msgName
//        msgID:(NSString *)msgID
//         toID:(NSString *)toID
//         data:(NSObject * _Nullable)data
//         save:(BOOL)save
//associatedMsgID:(NSString * _Nullable)associatedMsgID
//associatedUserID:(NSString * _Nullable)associatedUserID
//      expires:(NSTimeInterval)expires
//   completion:(completion_block _Nullable)completion;
//
////expendData:拓展数据，与msgName同级
//- (int)pubMsg:(NSString *)msgName
//        msgID:(NSString *)msgID
//         toID:(NSString *)toID
//         data:(NSObject * _Nullable)data
//         save:(BOOL)save
//extensionData:(NSDictionary * _Nullable)extensionData
//   completion:(completion_block _Nullable)completion;
//
///**
// 删除自定义消息
// @param msgName 消息名字
// @param msgID ：消息id
// @param toID 要通知给哪些用户。NSString类型，详情见 YSRoomDefines.h 相关定义. 可以是某一用户ID，表示此信令只发送给该用户
// @param data 消息数据，可以是Number、String、NSDictionary或NSArray
// @param completion 完成的回调
// @return 0表示调用成功，非0表示调用失败
// */
//- (int)delMsg:(NSString *)msgName
//        msgID:(NSString *)msgID
//         toID:(NSString *)toID
//         data:(NSObject * _Nullable)data
//   completion:(completion_block _Nullable)completion;


/// 发生错误 回调的提示信息
/// @param errorCode 错误码
- (NSString *)onRoomDidOccuredErrorCode:(NSInteger)errorCode
{
    NSString *alertMessage = nil;
    switch (errorCode)
    {
        case YSErrorCode_CheckRoom_ServerOverdue:
        { // 3001  服务器过期
            alertMessage = YSLocalized(@"Error.ServerExpired");
        }
            break;
        case YSErrorCode_CheckRoom_RoomFreeze:
        { // 3002  公司被冻结
            alertMessage = YSLocalized(@"Error.CompanyFreeze");
        }
            break;
        case YSErrorCode_CheckRoom_RoomDeleteOrOrverdue: // 3003  房间被删除或过期
        case YSErrorCode_CheckRoom_RoomNonExistent:
        { // 4007 房间不存在 房间被删除或者过期
            alertMessage = YSLocalized(@"Error.RoomDeletedOrExpired");
        }
            break;
        case YSErrorCode_CheckRoom_RequestFailed:
        {
            alertMessage = YSLocalized(@"Error.WaitingForNetwork");
        }
            break;
        case YSErrorCode_CheckRoom_PasswordError:
        { // 4008  房间密码错误
            alertMessage = YSLocalized(@"Error.PwdError");
        }
            break;
        case YSErrorCode_CheckRoom_WrongPasswordForRole:
        { // 4012  密码与角色不符
            alertMessage = YSLocalized(@"Error.PwdError");
        }
            break;
        case YSErrorCode_CheckRoom_RoomNumberOverRun:
        { // 4103  房间人数超限
            alertMessage = YSLocalized(@"Error.MemberOverRoomLimit");
        }
            break;
        case YSErrorCode_CheckRoom_NeedPassword:
        { // 4110  该房间需要密码，请输入密码
            alertMessage = YSLocalized(@"Error.NeedPwd");
        } break;
            
        case YSErrorCode_CheckRoom_RoomPointOverrun:
        { // 4112  企业点数超限
            alertMessage = YSLocalized(@"Error.pointOverRun");
        }
            break;
        case YSErrorCode_CheckRoom_RoomAuthenError:
        { // 4109  认证错误
            alertMessage = YSLocalized(@"Error.AuthIncorrect");
        }
            break;
            
        default:
        {
#ifdef DEBUG
            alertMessage = [NSString stringWithFormat:@"%@(%@)", YSLocalized(@"Error.WaitingForNetwork"), @(errorCode)];
#else
            if ([YSCoreStatus currentNetWorkStatus] == YSCoreNetWorkStatusNone)
            {
                alertMessage = YSLocalized(@"Error.WaitingForNetwork");//@"网络错误，请稍后再试";
            }
            else
            {
                alertMessage = YSLocalized(@"Error.CanNotConnectNetworkError");//@"服务器繁忙，请稍后再试";
            }
#endif
        }
            break;
    }
    
    return alertMessage;
}


///查看麦克风权限
- (BOOL)microphonePermissionsService
{
    AVAudioSessionRecordPermission permissionStatus = [[AVAudioSession sharedInstance] recordPermission];
    return permissionStatus == AVAudioSessionRecordPermissionGranted;
}
///查看摄像头权限
- (BOOL)cameraPermissionsService
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    return authStatus == AVAuthorizationStatusAuthorized;
}


//判断设备是否是高端机型，能否支持多人上台
- (BOOL)devicePlatformHighEndEquipment
{
    NSString *platform = [UIDevice bm_devicePlatform];
    // iPhone
    if ([platform isEqualToString:@"iPhone1,1"])    return NO;
    if ([platform isEqualToString:@"iPhone1,2"])    return NO;
    if ([platform isEqualToString:@"iPhone2,1"])    return NO;
    if ([platform isEqualToString:@"iPhone3,1"])    return NO;
    if ([platform isEqualToString:@"iPhone3,1"])    return NO;
    if ([platform isEqualToString:@"iPhone3,3"])    return NO;
    if ([platform isEqualToString:@"iPhone4,1"])    return NO;
    if ([platform isEqualToString:@"iPhone5,1"])    return NO;
    if ([platform isEqualToString:@"iPhone5,2"])    return NO;
    if ([platform isEqualToString:@"iPhone5,3"])    return NO;
    if ([platform isEqualToString:@"iPhone5,4"])    return NO;
    if ([platform isEqualToString:@"iPhone6,1"])    return NO;
    if ([platform isEqualToString:@"iPhone6,2"])    return NO;
    if ([platform isEqualToString:@"iPhone7,1"])    return NO;
    if ([platform isEqualToString:@"iPhone7,2"])    return NO;
    
#ifdef DEBUG
#if YSADDLOW_IPHONE
    // iPhone 8 Plus
    if ([platform isEqualToString:@"iPhone10,2"])   return NO;
#endif
#endif

    // iPod
    if ([platform isEqualToString:@"iPod1,1"])      return NO;
    if ([platform isEqualToString:@"iPod2,1"])      return NO;
    if ([platform isEqualToString:@"iPod3,1"])      return NO;
    if ([platform isEqualToString:@"iPod4,1"])      return NO;
    if ([platform isEqualToString:@"iPod5,1"])      return NO;
    if ([platform isEqualToString:@"iPod7,1"])      return NO;
    // iPad
    if ([platform isEqualToString:@"iPad1,1"])      return NO;
    if ([platform isEqualToString:@"iPad2,1"])      return NO;
    if ([platform isEqualToString:@"iPad2,2"])      return NO;
    if ([platform isEqualToString:@"iPad2,3"])      return NO;
    if ([platform isEqualToString:@"iPad2,4"])      return NO;
    if ([platform isEqualToString:@"iPad3,1"])      return NO;
    if ([platform isEqualToString:@"iPad3,2"])      return NO;
    if ([platform isEqualToString:@"iPad3,3"])      return NO;
    if ([platform isEqualToString:@"iPad3,4"])      return NO;
    if ([platform isEqualToString:@"iPad3,5"])      return NO;
    if ([platform isEqualToString:@"iPad3,6"])      return NO;
    if ([platform isEqualToString:@"iPad4,1"])      return NO;
    if ([platform isEqualToString:@"iPad4,2"])      return NO;
    if ([platform isEqualToString:@"iPad4,3"])      return NO;
    if ([platform isEqualToString:@"iPad5,3"])      return NO;
    if ([platform isEqualToString:@"iPad5,4"])      return NO;
    // iPad mini
    if ([platform isEqualToString:@"iPad2,5"])      return NO;
    if ([platform isEqualToString:@"iPad2,6"])      return NO;
    if ([platform isEqualToString:@"iPad2,7"])      return NO;
    
    return YES;
}


    
@end
