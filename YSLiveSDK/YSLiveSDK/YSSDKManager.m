//
//  YSLiveSDKManager.m
//  YSLiveSDK
//
//  Created by jiang deng on 2019/11/27.
//  Copyright © 2019 YS. All rights reserved.
//

#import "YSSDKManager.h"
#import "YSLiveApiRequest.h"

#import "YSCoreStatus.h" //网络状态

//const unsigned char YSSDKVersionString[] = "2.0.1";

/// 对应app版本
static NSString *YSAPPVersionString = @"2.3.3";

/// SDK版本
static NSString *YSSDKVersionString = @"2.4.0.0";

@interface YSSDKManager ()
<
    YSLiveRoomManagerDelegate,
    YSCoreNetWorkStatusProtocol
>
/// 底部的角色type
@property (nonatomic, assign) YSUserRoleType selectRoleType;

///获取房间类型时，探测接口的调用次数
@property (nonatomic, assign) NSInteger callNum;

@property (nonatomic, assign) YSSDKUseTheType roomType;

@property (nonatomic, weak) id <YSSDKDelegate> delegate;

@property (nonatomic, weak) YSLiveManager *liveManager;

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
    }
    return self;
}

+ (NSString *)SDKVersion
{
    return YSSDKVersionString;
}

- (void)registerManagerDelegate:(nullable id <YSSDKDelegate>)managerDelegate
{
    self.delegate = managerDelegate;
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
                   NSDictionary *responseDic = [YSLiveUtil convertWithData:responseObject];
                   
                   NSInteger result = [responseDic bm_intForKey:@"result"];
                   if (result == 4007)
                   {
                       failure(result, YSLocalized(@"Error.RoomTypeCheckError"));
                       return;
                   }
                   else if (result != 0)
                   {
                       failure(result, YSLocalized(@"Error.CanNotConnectNetworkError"));
                       return;
                   }
                                                         
                   NSDictionary * dataDict = [responseDic bm_dictionaryForKey:@"data"];
                   // 'roomtype'=>房间类型   3小班课，4直播，6会议
                   YSSDKUseTheType appUsetype = [dataDict bm_intForKey:@"roomtype"];
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
    return [self joinRoomWithRoomId:roomId nickName:nickName roomPassword:roomPassword userRole:YSSDKSUserType_Student userId:userId userParams:userParams needCheckPermissions:needCheckPermissions];
}

- (BOOL)joinRoomWithRoomId:(NSString *)roomId nickName:(NSString *)nickName roomPassword:(NSString *)roomPassword userRole:(YSSDKUserRoleType)userRole userId:(NSString *)userId userParams:(NSDictionary *)userParams
{
    return [self joinRoomWithRoomId:roomId nickName:nickName roomPassword:roomPassword userRole:userRole userId:userId userParams:userParams needCheckPermissions:YES];
}

- (BOOL)joinRoomWithRoomId:(NSString *)roomId nickName:(NSString *)nickName roomPassword:(NSString *)roomPassword userRole:(YSSDKUserRoleType)userRole userId:(NSString *)userId userParams:(NSDictionary *)userParams needCheckPermissions:(BOOL)needCheckPermissions
{
    self.selectRoleType = userRole;
    YSLiveManager *liveManager = [YSLiveManager shareInstance];
    self.liveManager = liveManager;

    [self.liveManager registerRoomManagerDelegate:self];
    self.liveManager.sdkDelegate = self;

    BOOL joined = [self.liveManager joinRoomWithHost:self.liveManager.liveHost port:YSLive_Port nickName:nickName roomId:roomId roomPassword:roomPassword userRole:userRole userId:nil userParams:nil needCheckPermissions:needCheckPermissions];

    return joined;
}


#pragma mark -
#pragma mark YSRoomInterfaceDelegate

// 成功进入房间
- (void)onRoomJoined:(long)ts;
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
    
    if ([rootVC isKindOfClass:[UIViewController class]])
    {
        NSAssert(NO, YSLocalized(@"SDK.VCError"));
        return;
    }

    if ([self.delegate respondsToSelector:@selector(onRoomJoined:)])
    {
        [self.delegate onRoomJoined:ts];
    }

    self.liveManager.sdkIsJoinRoom = YES;
    
    // 3: 小班课  4: 直播
    NSUInteger roomtype = [self.liveManager.roomDic bm_uintForKey:@"roomtype"];
    BOOL isSmallClass = (roomtype == YSAppUseTheTypeSmallClass || roomtype == YSAppUseTheTypeMeeting);
    
    if ([self.delegate respondsToSelector:@selector(onRoomJoined:roomType:userType:)])
    {
        [self.delegate onRoomJoined:ts roomType:roomtype userType:self.liveManager.localUser.role];
    }

    if (isSmallClass)
    {
        NSUInteger maxvideo = [[YSLiveManager shareInstance].roomDic bm_uintForKey:@"maxvideo"];
        YSRoomTypes roomusertype = maxvideo > 2 ? YSRoomType_More : YSRoomType_One;
        BOOL isWideScreen = [YSLiveManager shareInstance].room_IsWideScreen;
        
        if (self.selectRoleType == YSUserType_Teacher && (roomtype == YSAppUseTheTypeMeeting || ([UIDevice bm_isiPad] && roomtype == YSAppUseTheTypeSmallClass)))
        {
            YSTeacherRoleMainVC *mainVC = [[YSTeacherRoleMainVC alloc] initWithRoomType:roomusertype isWideScreen:isWideScreen maxVideoCount:maxvideo whiteBordView:self.liveManager.whiteBordView userId:nil];
            mainVC.appUseTheType = roomtype;
            BMNavigationController *nav = [[BMNavigationController alloc] initWithRootViewController:mainVC];
            nav.modalPresentationStyle = UIModalPresentationFullScreen;
            [rootVC presentViewController:nav animated:YES completion:^{
                if ([self.delegate respondsToSelector:@selector(onEnterClassRoom)])
                {
                    [self.delegate onEnterClassRoom];
                }
            }];
        }
        else
        {
            SCMainVC *mainVC = [[SCMainVC alloc] initWithRoomType:roomusertype isWideScreen:isWideScreen maxVideoCount:maxvideo whiteBordView:self.liveManager.whiteBordView userId:nil];
            mainVC.appUseTheType = roomtype;
            BMNavigationController *nav = [[BMNavigationController alloc] initWithRootViewController:mainVC];
            nav.modalPresentationStyle = UIModalPresentationFullScreen;
            [rootVC presentViewController:nav animated:YES completion:^{
                if ([self.delegate respondsToSelector:@selector(onEnterClassRoom)])
                {
                    [self.delegate onEnterClassRoom];
                }
            }];
        }
    }
    else
    {
        BOOL isWideScreen = [YSLiveManager shareInstance].room_IsWideScreen;
        YSMainVC *mainVC = [[YSMainVC alloc] initWithWideScreen:isWideScreen whiteBordView:self.liveManager.whiteBordView userId:nil];
        BMNavigationController *nav = [[BMNavigationController alloc] initWithRootViewController:mainVC];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [rootVC presentViewController:nav animated:YES completion:^{
            if ([self.delegate respondsToSelector:@selector(onEnterLiveRoom)])
            {
                [self.delegate onEnterLiveRoom];
            }
        }];
    }
}

- (void)roomManagerNeedEnterPassWord:(YSRoomErrorCode)errorCode
{
    [self.liveManager destroy];
    
    if ([self.delegate respondsToSelector:@selector(onRoomNeedEnterPassWord:)])
    {
        [self.delegate onRoomNeedEnterPassWord:(YSSDKErrorCode)errorCode];
    }
}

- (void)roomManagerReportFail:(YSRoomErrorCode)errorCode descript:(NSString *)descript
{
    [self.liveManager destroy];
 
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
        [self.liveManager destroy];
    }

    if ([self.delegate respondsToSelector:@selector(onRoomConnectionLost)])
    {
        [self.delegate onRoomConnectionLost];
    }
}

/**
    已经离开房间
 */
- (void)onRoomLeft
{
    self.liveManager.sdkIsJoinRoom = NO;
    if ([self.delegate respondsToSelector:@selector(onRoomLeft)])
    {
        [self.delegate onRoomLeft];
    }
}

/**
    自己被踢出房间
    @param reason 被踢原因
 */
- (void)onRoomKickedOut:(NSDictionary *)reason
{
    self.liveManager.sdkIsJoinRoom = NO;
    if ([self.delegate respondsToSelector:@selector(onRoomKickedOut:)])
    {
        [self.delegate onRoomKickedOut:reason];
    }
}

@end
