//
//  YSLiveSDKManager.m
//  YSLiveSDK
//
//  Created by jiang deng on 2019/11/27.
//  Copyright © 2019 YS. All rights reserved.
//

#import "YSSDKManager.h"
#import "YSLiveApiRequest.h"
#import "BMAlertView+YSDefaultAlert.h"

#import "YSCoreStatus.h" //网络状态

//const unsigned char YSSDKVersionString[] = "2.0.1";

/// 对应app版本
static NSString *YSAPPVersionString = @"3.5.2";

/// SDK版本
static NSString *YSSDKVersionString = @"3.5.2.1";

@interface YSSDKManager ()
<
    CHSessionDelegate,
    YSCoreNetWorkStatusProtocol
>
/// 底部的角色type
@property (nonatomic, assign) CHUserRoleType selectRoleType;

///获取房间类型时，探测接口的调用次数
@property (nonatomic, assign) NSInteger callNum;

@property (nonatomic, assign) CHRoomUseType roomType;

@property (nonatomic, weak) UIViewController <YSSDKDelegate> *delegate;

@property (nonatomic, weak) YSLiveManager *liveManager;

@property (nonatomic, strong) UIColor *whiteBordBgColor;
@property (nonatomic, strong) UIImage *whiteBordMaskImage;

// 是否需要使用HttpDNS
@property (nonatomic, assign) BOOL needUseHttpDNSForWhiteBoard;
@property (nonatomic, strong) NSMutableDictionary *connectH5CoursewareUrlParameters;

@property (nonatomic, strong) NSArray <NSDictionary *> *connectH5CoursewareUrlCookies;

@end

@implementation YSSDKManager

+ (instancetype)sharedInstance
{
    static YSSDKManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[YSSDKManager alloc] init];
    });
    return _sharedInstance;
}

- (void)dealloc
{
    [YSCoreStatus endMonitorNetwork:self];
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
#if DEBUG
        NSString *sdkVersion = [NSString stringWithFormat:@"%@", YSSDKVersionString];
        BMLog(@"SDK Version :%@", sdkVersion);
#endif
        [YSCoreStatus beginMonitorNetwork:self];
        
        self.needUseHttpDNSForWhiteBoard = YES;
        
        self.useAppDelegateAllowRotation = NO;
        self.classCanRotation = YES;
    }
    return self;
}

+ (NSString *)SDKVersion
{
    return YSSDKVersionString;
}

+ (NSString *)SDKDetailVersion
{
    NSString *sessionVersion = [NSString stringWithFormat:@"%s", CHSessionVersionString];
    NSString *whiteBoardSDKVersion = [CHWhiteBoardManager whiteBoardVersion];
    
    NSString *version = [NSString stringWithFormat:@"sessionVersion: %@\nwhiteBoardSDKVersion: %@\nYSSDKVersion: %@", sessionVersion, whiteBoardSDKVersion, YSSDKVersionString];
    return version;
}

- (void)registerManagerDelegate:(nullable UIViewController <YSSDKDelegate> *)managerDelegate
{
    self.delegate = managerDelegate;
}

- (void)registerUseHttpDNSForWhiteBoard:(BOOL)needUseHttpDNSForWhiteBoard
{
    self.needUseHttpDNSForWhiteBoard = needUseHttpDNSForWhiteBoard;
}

/// 改变白板背景颜色和水印底图
- (void)setWhiteBoardBackGroundColor:(UIColor *)color maskImage:(UIImage *)image
{
    self.whiteBordBgColor = color;
    self.whiteBordMaskImage = image;
}

#pragma mark - network status

- (void)coreNetworkChanged:(NSNotification *)noti
{
    NSDictionary *userDic = noti.userInfo;
    
    BMLog(@"网络环境: %@", [userDic bm_stringForKey:@"currentStatusString"]);
    BMLog(@"网络运营商: %@", [userDic bm_stringForKey:@"currentBrandName"]);
}


- (void)checkRoomTypeBeforeJoinRoomWithRoomId:(NSString *)roomId success:(void(^)(YSSDKUseTheType roomType, BOOL needpassword))success failure:(void(^)(NSInteger code,NSString *errorStr))failure
{
       BMAFHTTPSessionManager *manager = [BMAFHTTPSessionManager manager];
       NSMutableURLRequest *request = [YSLiveApiRequest checkRoomTypeWithRoomId:roomId];
       request.timeoutInterval = 30.0f;
       if (request)
       {
           manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[
               @"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript",
               @"text/xml"
           ]];
       
           NSURLSessionDataTask *task = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
               if (error)
               {
                   failure(error.code, error.localizedDescription);
               }
               else
               {
                   NSDictionary *responseDic = [BMCloudHubUtil convertWithData:responseObject];
                   
                   NSInteger result = [responseDic bm_intForKey:@"result"];
                   if (result == 4007)
                   {
                       failure(result, YSLoginLocalized(@"Error.RoomTypeCheckError"));
                       return;
                   }
                   else if (result != 0)
                   {
                       failure(result, YSLoginLocalized(@"Error.CanNotConnectNetworkError"));
                       return;
                   }
                                                         
                   NSDictionary *dataDict = [responseDic bm_dictionaryForKey:@"data"];
                   // 'roomtype'=>房间类型   3小班课，4直播，6会议
                   CHRoomUseType appUsetype = [dataDict bm_intForKey:@"roomtype"];
                   BOOL needpwd = [dataDict bm_boolForKey:@"needpwd"];
                   self.roomType = appUsetype;
                   
                   success(appUsetype, needpwd);
               }
           }];
           [task resume];
       }
}

- (BOOL)joinRoomWithRoomId:(NSString *)roomId nickName:(NSString *)nickName roomPassword:(nullable NSString *)roomPassword userId:(nullable NSString *)userId userParams:(nullable NSDictionary *)userParams
{
    return [self joinRoomWithRoomId:roomId nickName:nickName roomPassword:roomPassword userId:userId userParams:userParams needCheckPermissions:YES];
}

- (BOOL)joinRoomWithRoomId:(NSString *)roomId nickName:(NSString *)nickName roomPassword:(nullable NSString *)roomPassword userId:(nullable NSString *)userId userParams:(nullable NSDictionary *)userParams needCheckPermissions:(BOOL)needCheckPermissions
{
    return [self joinRoomWithRoomId:roomId nickName:nickName roomPassword:roomPassword userRole:YSSDKUserType_Student userId:userId userParams:userParams needCheckPermissions:needCheckPermissions];
}

- (BOOL)joinRoomWithRoomId:(NSString *)roomId nickName:(NSString *)nickName roomPassword:(NSString *)roomPassword userRole:(YSSDKUserRoleType)userRole userId:(NSString *)userId userParams:(NSDictionary *)userParams
{
    return [self joinRoomWithRoomId:roomId nickName:nickName roomPassword:roomPassword userRole:userRole userId:userId userParams:userParams needCheckPermissions:YES];
}

- (BOOL)joinRoomWithRoomId:(NSString *)roomId nickName:(NSString *)nickName roomPassword:(NSString *)roomPassword userRole:(YSSDKUserRoleType)userRole userId:(NSString *)userId userParams:(NSDictionary *)userParams needCheckPermissions:(BOOL)needCheckPermissions
{
    self.selectRoleType = userRole;
    if (![self checkKickTimeWithRoomId:roomId])
    {
        return NO;
    }

    YSLiveManager *liveManager = [YSLiveManager sharedInstance];
    self.liveManager = liveManager;
    
    [liveManager registerRoomDelegate:self];
    [self.liveManager registerUseHttpDNSForWhiteBoard:self.needUseHttpDNSForWhiteBoard];
    self.liveManager.sdkDelegate = self;
    
    if ([self.connectH5CoursewareUrlCookies bm_isNotEmpty])
    {
        [self.liveManager registerUseHttpDNSForWhiteBoard:NO];
        [self.liveManager setConnectH5CoursewareUrlCookies:self.connectH5CoursewareUrlCookies];
    }

    if ([self.connectH5CoursewareUrlParameters bm_isNotEmptyDictionary])
    {
        [self.liveManager changeConnectH5CoursewareUrlParameters:self.connectH5CoursewareUrlParameters];
    }

    [self.liveManager setWhiteBoardBackGroundColor:self.whiteBordBgColor maskImage:self.whiteBordMaskImage];

    BOOL joined = [self.liveManager joinRoomWithHost:self.liveManager.apiHost port:YSLive_Port nickName:nickName roomId:roomId roomPassword:roomPassword userRole:(CHUserRoleType)userRole userId:userId userParams:nil needCheckPermissions:needCheckPermissions];

    return joined;
}

/// 变更H5课件地址参数，此方法会刷新当前H5课件以变更新参数
- (void)changeConnectH5CoursewareUrlParameters:(NSDictionary *)parameters
{
    if ([parameters bm_isNotEmptyDictionary])
    {
        self.connectH5CoursewareUrlParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
    }
    else
    {
        self.connectH5CoursewareUrlParameters = [NSMutableDictionary dictionary];
    }
    
    if (self.liveManager)
    {
        [self.liveManager changeConnectH5CoursewareUrlParameters:parameters];
    }
}

- (void)setConnectH5CoursewareUrlCookies:(nullable NSArray <NSDictionary *> *)cookies;
{
    _connectH5CoursewareUrlCookies = [NSArray arrayWithArray:cookies];
}

- (BOOL)checkKickTimeWithRoomId:(NSString *)roomId
{
    if (self.selectRoleType == CHUserType_Student)
    {
        // 学生被T 3分钟内不能登录
        NSString *roomIdKey = [NSString stringWithFormat:@"%@_%@", YSKickTime, roomId];
        
        id idTime = [[NSUserDefaults standardUserDefaults] objectForKey:roomIdKey];
        if (idTime && [idTime isKindOfClass:NSDate.class])
        {
            NSDate *time = (NSDate *)idTime;
            NSDate *curTime = [NSDate date];
            // 计算出相差多少秒
            NSTimeInterval delta = [curTime timeIntervalSinceDate:time];
            
            if (delta < 60 * 3)
            {
                NSString *content =  YSLoginLocalized(@"Prompt.kick");
                [BMAlertView ys_showAlertWithTitle:content message:nil cancelTitle:nil completion:nil];
                return NO;
            }
            else
            {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:roomIdKey];
            }
        }
    }
    
    return YES;
}


#pragma mark -
#pragma mark YSRoomInterfaceDelegate

- (void)waitRoomLeft
{
    [self.liveManager leaveRoom:nil];
}

// 成功进入房间
- (void)onRoomDidCheckRoom
{
    UIViewController *rootVC = nil;
    if ([self.delegate isKindOfClass:[UIViewController class]])
    {
        rootVC = (UIViewController *)self.delegate;
    }
    else
    {
        NSArray *windows = [UIApplication sharedApplication].windows;
        if ([windows bm_isNotEmpty])
        {
            UIWindow *window = [windows firstObject];
            if (window.rootViewController)
            {
                rootVC = window.rootViewController;
            }
            
            if ([rootVC isKindOfClass:[UINavigationController class]])
            {
                UINavigationController *nav = (UINavigationController *)rootVC;
                rootVC = nav.visibleViewController;
            }
        }
    }
    
    if (![rootVC isKindOfClass:[UIViewController class]])
    {
        NSAssert(NO, YSLoginLocalized(@"SDK.VCError"));
        return;
    }

    self.liveManager.sdkIsJoinRoom = YES;
    
    // 3: 小班课  4: 直播
    CHRoomUseType roomtype = [self.liveManager.roomDic bm_uintForKey:@"roomtype"];
    BOOL isSmallClass = (roomtype == CHRoomUseTypeSmallClass || roomtype == CHRoomUseTypeMeeting);
    
    if ([self.delegate respondsToSelector:@selector(onRoomJoinWithRoomType:userType:)])
    {
        [self.delegate onRoomJoinWithRoomType:(YSSDKUseTheType)roomtype userType:(YSSDKUserRoleType)self.liveManager.localUser.role];
    }

    if (isSmallClass)
    {
        NSUInteger maxvideo = [self.liveManager.roomDic bm_uintForKey:@"maxvideo"];
        CHRoomUserType roomusertype = maxvideo > 2 ? CHRoomUserType_More : CHRoomUserType_One;
        BOOL isWideScreen = self.liveManager.room_IsWideScreen;
        
        if (self.selectRoleType == CHUserType_Teacher)
        {
            YSTeacherRoleMainVC *mainVC = [[YSTeacherRoleMainVC alloc] initWithRoomType:roomusertype isWideScreen:isWideScreen maxVideoCount:maxvideo whiteBordView:self.liveManager.whiteBordView userId:nil];
            mainVC.appUseTheType = roomtype;
            BMNavigationController *nav = [[BMNavigationController alloc] initWithRootViewController:mainVC];
            nav.modalPresentationStyle = UIModalPresentationFullScreen;
            [rootVC presentViewController:nav animated:YES completion:^{
            }];
        }
        else
        {
            SCMainVC *mainVC = [[SCMainVC alloc] initWithRoomType:roomusertype isWideScreen:isWideScreen maxVideoCount:maxvideo whiteBordView:self.liveManager.whiteBordView userId:nil];
            mainVC.appUseTheType = roomtype;
            BMNavigationController *nav = [[BMNavigationController alloc] initWithRootViewController:mainVC];
            nav.modalPresentationStyle = UIModalPresentationFullScreen;
            [rootVC presentViewController:nav animated:YES completion:^{
            }];
        }
    }
    else
    {
        if (self.selectRoleType == CHUserType_Student)
        {
            BOOL isWideScreen = self.liveManager.room_IsWideScreen;
            YSMainVC *mainVC = [[YSMainVC alloc] initWithWideScreen:isWideScreen whiteBordView:self.liveManager.whiteBordView userId:nil];
            BMNavigationController *nav = [[BMNavigationController alloc] initWithRootViewController:mainVC];
            nav.modalPresentationStyle = UIModalPresentationFullScreen;
            [rootVC presentViewController:nav animated:YES completion:^{
            }];
            
            return;
        }
        
        NSLog(@"直播只能学生登入");
        //[self.liveManager destroy];
        [self waitRoomLeft];
    }
}

- (void)roomManagerNeedEnterPassWord:(CHRoomErrorCode)errorCode
{
    [YSLiveManager destroy];
    
    if ([self.delegate respondsToSelector:@selector(onRoomNeedEnterPassWord:)])
    {
        [self.delegate onRoomNeedEnterPassWord:(YSSDKErrorCode)errorCode];
    }
}

/// 进入房间失败
- (void)onRoomJoinFailed:(NSDictionary *)errorDic
{
    NSError *error = [errorDic objectForKey:@"error"];
    CHRoomErrorCode errorCode = error.code;
    NSString *descript = [YSLiveUtil getOccuredErrorCode:errorCode];

    if (errorCode == CHErrorCode_CheckRoom_NeedPassword ||
        errorCode == CHErrorCode_CheckRoom_PasswordError ||
        errorCode == CHErrorCode_CheckRoom_WrongPasswordForRole)
    {
        [self roomManagerNeedEnterPassWord:errorCode];
        return;
    }

    //[self.liveManager destroy];
    [self waitRoomLeft];

    if ([self.delegate respondsToSelector:@selector(onRoomReportFail:descript:)])
    {
        [self.delegate onRoomReportFail:(YSSDKErrorCode)errorCode descript:descript];
    }
}

/**
 失去连接
 */
- (void)onRoomConnectionLost
{
    // 未进入教室需要销毁liveManager
    if (!self.liveManager.sdkIsJoinRoom)
    {
        [self waitRoomLeft];
    }

    if ([self.delegate respondsToSelector:@selector(onRoomConnectionLost)])
    {
        [self.delegate onRoomConnectionLost];
    }
}

/**
    即将离开房间
 */
- (void)onRoomWillLeft
{
    if ([self.delegate respondsToSelector:@selector(onRoomWillLeft)])
    {
        [self.delegate onRoomWillLeft];
    }
}

/**
    已经离开房间
 */
- (void)onRoomLeft
{
    [YSLiveManager destroy];

    self.liveManager.sdkIsJoinRoom = NO;
    if ([self.delegate respondsToSelector:@selector(onRoomLeft)])
    {
        [self.delegate onRoomLeft];
    }
}

// 自己被踢出房间
- (void)onRoomKickedOut:(NSInteger)reasonCode
{
    self.liveManager.sdkIsJoinRoom = NO;
    if ([self.delegate respondsToSelector:@selector(onRoomKickedOut:)])
    {
        [self.delegate onRoomKickedOut:reasonCode];
    }
}

@end
