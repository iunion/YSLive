//
//  YSLiveManager.m
//  YSLive
//
//  Created by jiang deng on 2020/6/24.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSLiveManager.h"
#import "YSPermissionsVC.h"

#if USECUSTOMER_COURSEWARECONTROLVIEW
#import "YSNewCoursewareControlView.h"
#endif

#if YSSDK
#import "YSSDKManager.h"
#endif

@interface YSLiveManager ()
<
    CHWhiteBoardManagerDelegate
>

#pragma mark - 白板

/// 白板管理
@property (nonatomic, strong) CHWhiteBoardManager *whiteBoardManager;

/// 白板背景色
@property (nonatomic, strong) UIColor *whiteBordBgColor;
/// 白板背景图
@property (nonatomic, strong) UIImage *whiteBordMaskImage;
/// 白板画板背景色
@property (nonatomic, strong) UIColor *whiteBordDrawBgColor;

/// 直播白板背景色
@property (nonatomic, strong) UIColor *whiteBordLiveBgColor;
/// 直播白板画板背景色
@property (nonatomic, strong) UIColor *whiteBordLiveDrawBgColor;

@property (nonatomic, strong) NSMutableDictionary *connectH5CoursewareUrlParameters;
@property (nonatomic, strong) NSArray <NSDictionary *> *connectH5CoursewareUrlCookies;

// 是否需要使用HttpDNS
@property (nonatomic, assign) BOOL needUseHttpDNSForWhiteBoard;

@end

@implementation YSLiveManager

+ (void)destroy
{
    [CHWhiteBoardManager destroy];

    [CHSessionManager destroy];
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.apiHost = YSLIVE_HOST;
        self.schoolApiHost = YSSchool_Server;
        
        self.whiteBordBgColor = CHWhiteBoard_MainBackGroudColor;
        self.whiteBordDrawBgColor = CHWhiteBoard_MainBackDrawBoardBgColor;
        self.whiteBordMaskImage = nil;

        self.whiteBordLiveBgColor = CHWhiteBoard_LiveMainBackGroudColor;
        self.whiteBordLiveDrawBgColor = CHWhiteBoard_LiveMainBackDrawBoardBgColor;
        self.needUseHttpDNSForWhiteBoard = YES;

        #if YSSDK
            // 区分是否进入教室
            self.sdkIsJoinRoom = NO;
        #endif
    }
    
    return self;
}

- (void)registerRoomDelegate:(id <CHSessionDelegate>)roomDelegate
{
    [super registerRoomDelegate:roomDelegate];
        
    [self registWithAppId: YSLive_AppKey
          settingOptional: @{
              CHRoomSettingOptionalWhiteBoardNotify : @(YES),
              CHRoomSettingOptionalReconnectattempts : @(5)
          }];
}

- (void)registerUseHttpDNSForWhiteBoard:(BOOL)needUseHttpDNSForWhiteBoard
{
#if YSSDK
    self.needUseHttpDNSForWhiteBoard = needUseHttpDNSForWhiteBoard;
#endif
}

- (BOOL)joinRoomWithHost:(NSString *)host port:(int)port nickName:(NSString *)nickName roomId:(NSString *)roomId roomPassword:(NSString *)roomPassword userRole:(CHUserRoleType)userRole userId:(NSString *)userId userParams:(NSDictionary *)userParams
{
    return [self joinRoomWithHost:host port:port nickName:nickName roomId:roomId roomPassword:roomPassword userRole:userRole userId:userId userParams:userParams needCheckPermissions:YES];
}

- (BOOL)joinRoomWithHost:(NSString *)host port:(int)port nickName:(NSString *)nickName roomId:(NSString *)roomId roomPassword:(NSString *)roomPassword userRole:(CHUserRoleType)userRole userId:(NSString *)userId userParams:(NSDictionary *)userParams needCheckPermissions:(BOOL)needCheckPermissions
{
    NSString *server = @"global";
    if ([BMCloudHubUtil isDomain:host] == YES)
    {
        NSArray *array = [host componentsSeparatedByString:@"."];
        server = [NSString stringWithFormat:@"%@", array[0]];
    }
    
    NSMutableDictionary *parameters = @{
        CHJoinRoomParamsRoomSerialKey : roomId,
        CHJoinRoomParamsUserRoleKey : @(userRole),
        CHJoinRoomParamsServerKey : server,
        CHJoinRoomParamsClientTypeKey : @(3)
    }.mutableCopy;
    
    if ([roomPassword bm_isNotEmpty])
    {
        [parameters setObject:roomPassword forKey:CHJoinRoomParamsPasswordKey];
    }
    
    if ([userId bm_isNotEmpty])
    {
        [parameters setObject:userId forKey:CHJoinRoomParamsUserIDKey];
    }
    
    return [self joinRoomWithHost:host port:port nickName:nickName roomParams:parameters userParams:userParams needCheckPermissions:needCheckPermissions];
}

- (BOOL)joinRoomWithHost:(NSString *)host port:(int)port nickName:(NSString *)nickname roomParams:(NSDictionary *)roomParams userParams:(NSDictionary *)userParams
{
    return [self joinRoomWithHost:host port:port nickName:nickname roomParams:roomParams userParams:userParams needCheckPermissions:YES];
}

- (BOOL)joinRoomWithHost:(NSString *)host port:(int)port nickName:(NSString *)nickname roomParams:(NSDictionary *)roomParams userParams:(NSDictionary *)userParams needCheckPermissions:(BOOL)needCheckPermissions
{
    if (needCheckPermissions)
    {
#if YSSDK
        UIViewController *rootVC = nil;
        YSSDKManager *SDKManager = (YSSDKManager *)self.sdkDelegate;
        if ([SDKManager.delegate isKindOfClass:[UIViewController class]])
        {
            rootVC = (UIViewController *)SDKManager.delegate;
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
            NSAssert(NO, YSLocalized(@"SDK.VCError"));
            return NO;
        }
#endif
        ///查看摄像头权限
        BOOL isCamera = [self cameraPermissionsService];
        ///查看麦克风权限
        BOOL isOpenMicrophone = [self microphonePermissionsService];
        /// 扬声器权限
        BOOL isReproducer = [YSUserDefault getReproducerPermission];
        
        //    isOpenMicrophone = NO;
        if (!isOpenMicrophone || !isCamera || !isReproducer)
        {
            YSPermissionsVC *vc = [[YSPermissionsVC alloc] init];
            
            BMWeakSelf
            vc.toJoinRoom = ^{
                [weakSelf joinRoomWithHost:host port:port nickName:nickname roomParams:roomParams userParams:userParams needCheckPermissions:NO];
            };
            
#if YSSDK
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            [rootVC presentViewController:vc animated:YES completion:nil];
#else
            UIWindow *window = [[UIApplication sharedApplication].delegate window];
            UIViewController *topViewController = [window rootViewController];
            
            [(UINavigationController*)topViewController pushViewController:vc animated:NO];
#endif
            
            return YES;
        }
    }
    
    [self prepareToJoinRoomWithHost:host port:port nickName:nickname roomParams:roomParams userParams:userParams];
    
   return [super joinRoomWithHost:host port:port nickName:nickname roomParams:roomParams userParams:userParams];
}

- (void)prepareToJoinRoomWithHost:(NSString *)host port:(int)port nickName:(NSString *)nickname roomParams:(NSDictionary *)roomParams userParams:(NSDictionary *)userParams
{
    self.whiteBoardManager = [CHWhiteBoardManager sharedInstance];
    NSLog(@"WhiteBoard SDK Version: %@", [CHWhiteBoardManager whiteBoardVersion]);
    
    [self registerRoomForWhiteBoardDelegate:self.whiteBoardManager];

    NSDictionary *whiteBoardConfig = @{
        CHWhiteBoardWebProtocolKey : YSLive_Http,
        CHWhiteBoardWebHostKey : host,
        CHWhiteBoardWebPortKey : @(port),
        CHWhiteBoardPDFLevelsKey : @(2),
        CHWhiteBoardIsObjectLevelKey : @(YES)
    };
    
#if YSSDK
    [self.whiteBoardManager registerDelegate:self configration:whiteBoardConfig useHttpDNS:self.needUseHttpDNSForWhiteBoard];
    
    [self.whiteBoardManager setConnectH5CoursewareUrlCookies:self.connectH5CoursewareUrlCookies];
#else
    [self.whiteBoardManager registerDelegate:self configration:whiteBoardConfig];
#endif
    
    [self registerRoomForWhiteBoardDelegate:self.whiteBoardManager];
        
    if ([self.connectH5CoursewareUrlParameters bm_isNotEmptyDictionary])
    {
        [self.whiteBoardManager changeConnectH5CoursewareUrlParameters:self.connectH5CoursewareUrlParameters];
    }
    
#if USECUSTOMER_COURSEWARECONTROLVIEW
    [self.whiteBoardManager registerCoursewareControlView:@"YSNewCoursewareControlView" viewSize:CGSizeMake(YSCoursewareControlView_Width, 50)];
#endif
    
//    [self.whiteBoardManager changeMainWhiteBoardBackImage:self.whiteBordMaskImage];
//    [self.whiteBoardManager changeMainWhiteBoardBackgroudColor:self.whiteBordBgColor];
//    [self.whiteBoardManager changeMainCourseViewBackgroudColor:self.whiteBordDrawBgColor];
//
//    [self.whiteBoardManager changeAllWhiteBoardBackgroudColor:self.whiteBordBgColor];
}

/// 改变小班课白板背景颜色和水印底图
- (void)setWhiteBoardBackGroundColor:(UIColor *)color maskImage:(UIImage *)image
{
    if (color)
    {
        self.whiteBordBgColor = color;
    }
    else
    {
        self.whiteBordBgColor = CHWhiteBoard_MainBackGroudColor;
    }

    self.whiteBordMaskImage = image;
}

- (void)setWhiteBoardBackGroundColor:(UIColor *)color drawBackGroundColor:(UIColor *)drawBgColor maskImage:(UIImage *)image
{
    if (color)
    {
        self.whiteBordBgColor = color;
    }
    else
    {
        self.whiteBordBgColor = CHWhiteBoard_MainBackGroudColor;
    }

    if (drawBgColor)
    {
        self.whiteBordDrawBgColor = drawBgColor;
    }
    else
    {
        self.whiteBordDrawBgColor = CHWhiteBoard_MainBackDrawBoardBgColor;
    }

    self.whiteBordMaskImage = image;
}

/// 改变直播白板背景颜色
- (void)setWhiteBoardLivrBackGroundColor:(UIColor *)color drawBackGroundColor:(UIColor *)drawBgColor
{
    if (color)
    {
        self.whiteBordLiveBgColor = color;
    }
    else
    {
        self.whiteBordLiveBgColor = CHWhiteBoard_MainBackGroudColor;
    }

    if (drawBgColor)
    {
        self.whiteBordLiveDrawBgColor = drawBgColor;
    }
    else
    {
        self.whiteBordLiveDrawBgColor = CHWhiteBoard_MainBackDrawBoardBgColor;
    }
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
    
    if (self.whiteBoardManager)
    {
        [self.whiteBoardManager changeConnectH5CoursewareUrlParameters:parameters];
    }
}

- (void)setConnectH5CoursewareUrlCookies:(NSArray<NSDictionary *> *)cookies
{
    _connectH5CoursewareUrlCookies = [NSArray arrayWithArray:cookies];
}

- (UIView *)whiteBordView
{
    return self.whiteBoardManager.mainWhiteBoardView;
}

- (NSArray <CHFileModel *> *)fileList
{
    return [self.whiteBoardManager.docmentList copy];
}

- (CHFileModel *)currentFile
{
    return nil;
    //return [self.whiteBoardManager currentFile];
}

- (CHFileModel *)getFileWithFileID:(NSString *)fileId;
{
    CHFileModel *fileModel = [self.whiteBoardManager getDocumentWithFileId:fileId];
    return fileModel;
}


///查看摄像头权限
- (BOOL)cameraPermissionsService
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    return authStatus == AVAuthorizationStatusAuthorized;
}

///查看麦克风权限
- (BOOL)microphonePermissionsService
{
    AVAudioSessionRecordPermission permissionStatus = [[AVAudioSession sharedInstance] recordPermission];
    return permissionStatus == AVAudioSessionRecordPermissionGranted;
}


#pragma mark -
#pragma mark CHWhiteBoardManagerDelegate

/// 白板管理准备完毕
- (void)onWhiteBroadCheckRoomFinish:(BOOL)finished
{
    
}

/// 白板管理进入房间完毕，SAAS使用
- (void)onWhiteBroadEnterRoomFinish:(BOOL)finished
{
    
}

/// 文件列表回调
/// @param fileList 文件NSDictionary列表
- (void)onWhiteBroadFileList:(NSArray <NSDictionary *> *)fileList
{
    [self.whiteBoardManager changeMainWhiteBoardBackImage:self.whiteBordMaskImage];
    [self.whiteBoardManager changeMainWhiteBoardBackgroudColor:self.whiteBordBgColor];
    [self.whiteBoardManager changeMainCourseViewBackgroudColor:self.whiteBordDrawBgColor];

    [self.whiteBoardManager changeAllWhiteBoardBackgroudColor:self.whiteBordBgColor];

    if (self.room_UseType == CHRoomUseTypeLiveRoom)
    {
        [self.whiteBoardManager changeMainWhiteBoardBackgroudColor:self.whiteBordLiveBgColor];
        [self.whiteBoardManager changeMainCourseViewBackgroudColor:self.whiteBordLiveDrawBgColor];
    }
}

/// 当前打开的课件列表
- (void)onWhiteBoardChangedShowFileIdList:(NSArray *)fileIdList
{
    if ([self.whiteBoardDelegate respondsToSelector:@selector(handleonWhiteBoardChangedFileWithFileList:)])
    {
        [self.whiteBoardDelegate handleonWhiteBoardChangedFileWithFileList:fileIdList];
    }
}

#pragma mark - 课件事件

/// 课件全屏
- (void)onWhiteBoardFullScreen:(BOOL)isAllScreen;
{
    if ([self.whiteBoardDelegate respondsToSelector:@selector(handleonWhiteBoardFullScreen:)])
    {
        [self.whiteBoardDelegate handleonWhiteBoardFullScreen:isAllScreen];
    }
}

/// 媒体播放状态
- (void)onWhiteBoardChangedMediaFileStateWithFileId:(NSString *)fileId state:(CHMediaState)state
{
    if ([self.whiteBoardDelegate respondsToSelector:@selector(handleonWhiteBoardMediaFileStateWithFileId:state:)])
    {
        [self.whiteBoardDelegate handleonWhiteBoardMediaFileStateWithFileId:fileId state:state];
    }
}

/// 课件窗口最大化事件
- (void)onWhiteBoardMaximizeView
{
    if ([self.whiteBoardDelegate respondsToSelector:@selector(handleonWhiteBoardMaximizeView)])
    {
        [self.whiteBoardDelegate handleonWhiteBoardMaximizeView];
    }
}


- (void)onSetSmallBoardStageState:(CHSmallBoardStageState)smallBoardStageState
{
    if ([self.whiteBoardDelegate respondsToSelector:@selector(handleSignalingSetSmallBoardStageState:)])
    {
        [self.whiteBoardDelegate handleSignalingSetSmallBoardStageState:smallBoardStageState];
    }
}

//小黑板bottomBar的代理
- (void)onSmallBoardBottomBarClick:(UIButton *)sender
{
    if ([self.whiteBoardDelegate respondsToSelector:@selector(handleSignalingSmallBoardBottomBarClick:)])
    {
        [self.whiteBoardDelegate handleSignalingSmallBoardBottomBarClick:sender];
    }
}

- (void)handleSignalingReceivePrivateChatWithPrivateIdArray:(NSArray *)privateIdArray
{
    if ([self.whiteBoardDelegate respondsToSelector:@selector(handleSignalingReceivePrivateChatWithPrivateIdArray:)])
    {
        [self.whiteBoardDelegate handleSignalingReceivePrivateChatWithPrivateIdArray:privateIdArray];
    }
}

- (void)handleSignalingDeletePrivateChat
{
    if ([self.whiteBoardDelegate respondsToSelector:@selector(handleSignalingDeletePrivateChat)])
    {
        [self.whiteBoardDelegate handleSignalingDeletePrivateChat];
    }
}

#if YSSDK
- (void)onSDKRoomWillLeft
{
    BMLog(@"onSDKRoomWillLeft");
    
    if ([self.sdkDelegate respondsToSelector:@selector(onRoomWillLeft)])
    {
        [self.sdkDelegate onRoomWillLeft];
    }
}

- (void)onSDKRoomLeft
{
    BMLog(@"onSDKRoomLeft");
    
    if ([self.sdkDelegate respondsToSelector:@selector(onRoomLeft)])
    {
        [self.sdkDelegate onRoomLeft];
    }
}
#endif

@end
