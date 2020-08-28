//
//  YSLiveManager.m
//  YSLive
//
//  Created by jiang deng on 2020/6/24.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSLiveManager.h"
#import "YSPermissionsVC.h"

#import "YSNewCoursewareControlView.h"

#if YSSDK
#import "YSSDKManager.h"
#endif

@interface YSLiveManager ()
<
    YSWhiteBoardManagerDelegate
>

#pragma mark - 白板

/// 白板管理
@property (nonatomic, strong) YSWhiteBoardManager *whiteBoardManager;
/// 白板视图whiteBord
@property (nonatomic, weak) UIView *whiteBordView;

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
    [YSWhiteBoardManager destroy];

    [YSSessionManager destroy];
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.apiHost = YSLIVE_HOST;
        self.schoolApiHost = YSSchool_Server;
        
        self.whiteBordBgColor = YSWhiteBoard_MainBackGroudColor;
        self.whiteBordDrawBgColor = YSWhiteBoard_MainBackDrawBoardBgColor;
        self.whiteBordMaskImage = nil;

        self.whiteBordLiveBgColor = YSWhiteBoard_LiveMainBackGroudColor;
        self.whiteBordLiveDrawBgColor = YSWhiteBoard_LiveMainBackDrawBoardBgColor;
        self.needUseHttpDNSForWhiteBoard = YES;

        #if YSSDK
            // 区分是否进入教室
            self.sdkIsJoinRoom = NO;
        #endif
    }
    
    return self;
}

- (void)registerRoomDelegate:(id <YSSessionDelegate>)roomDelegate
{
    [super registerRoomDelegate:roomDelegate];
        
    [self registWithAppId: YSLive_AppKey
          settingOptional: @{
              YSRoomSettingOptionalWhiteBoardNotify : @(YES),
              YSRoomSettingOptionalReconnectattempts : @(5)
          }];
}

- (void)registerUseHttpDNSForWhiteBoard:(BOOL)needUseHttpDNSForWhiteBoard
{
#if YSSDK
    self.needUseHttpDNSForWhiteBoard = needUseHttpDNSForWhiteBoard;
#endif
}

- (BOOL)joinRoomWithHost:(NSString *)host port:(int)port nickName:(NSString *)nickName roomId:(NSString *)roomId roomPassword:(NSString *)roomPassword userRole:(YSUserRoleType)userRole userId:(NSString *)userId userParams:(NSDictionary *)userParams
{
    return [self joinRoomWithHost:host port:port nickName:nickName roomId:roomId roomPassword:roomPassword userRole:userRole userId:userId userParams:userParams needCheckPermissions:YES];
}

- (BOOL)joinRoomWithHost:(NSString *)host port:(int)port nickName:(NSString *)nickName roomId:(NSString *)roomId roomPassword:(NSString *)roomPassword userRole:(YSUserRoleType)userRole userId:(NSString *)userId userParams:(NSDictionary *)userParams needCheckPermissions:(BOOL)needCheckPermissions
{
    NSString *server = @"global";
    if ([YSSessionUtil isDomain:host] == YES)
    {
        NSArray *array = [host componentsSeparatedByString:@"."];
        server = [NSString stringWithFormat:@"%@", array[0]];
    }
    
    NSMutableDictionary *parameters = @{
        YSJoinRoomParamsRoomIDKey : roomId,
        YSJoinRoomParamsUserRoleKey : @(userRole),
        YSJoinRoomParamsServerKey : server,
        YSJoinRoomParamsClientTypeKey : @(3)
    }.mutableCopy;
    
    if ([roomPassword bm_isNotEmpty])
    {
        [parameters setObject:roomPassword forKey:YSJoinRoomParamsPasswordKey];
    }
    
    if ([userId bm_isNotEmpty])
    {
        [parameters setObject:userId forKey:YSJoinRoomParamsUserIDKey];
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
    self.whiteBoardManager = [YSWhiteBoardManager sharedInstance];
    NSLog(@"WhiteBoard SDK Version: %@", [YSWhiteBoardManager whiteBoardVersion]);
    
    [self registerRoomForWhiteBoardDelegate:self.whiteBoardManager];

    NSDictionary *whiteBoardConfig = @{
        YSWhiteBoardWebProtocolKey : YSLive_Http,
        YSWhiteBoardWebHostKey : host,
        YSWhiteBoardWebPortKey : @(port),
        YSWhiteBoardPlayBackKey : @(NO),
        YSWhiteBoardPDFLevelsKey : @(2)
    };
    
#if YSSDK
    [self.whiteBoardManager registerDelegate:self configration:whiteBoardConfig useHttpDNS:self.needUseHttpDNSForWhiteBoard];
    
    [self.whiteBoardManager setConnectH5CoursewareUrlCookies:self.connectH5CoursewareUrlCookies];
#else
    [self.whiteBoardManager registerDelegate:self configration:whiteBoardConfig];
#endif
        
    if ([self.connectH5CoursewareUrlParameters bm_isNotEmptyDictionary])
    {
        [self.whiteBoardManager changeConnectH5CoursewareUrlParameters:self.connectH5CoursewareUrlParameters];
    }
    
    [self.whiteBoardManager registerCoursewareControlView:@"YSNewCoursewareControlView" viewSize:CGSizeMake(YSCoursewareControlView_Width, 50)];
    
    CGFloat whiteBordViewH = 500;
    if (BMIS_IPHONE)
    {
        whiteBordViewH = 300;
    }
    
    self.whiteBordView = [self.whiteBoardManager createMainWhiteBoardWithFrame:CGRectMake(0, 0, BMUI_SCREEN_WIDTH, whiteBordViewH) loadFinishedBlock:^{

    }];

    [self.whiteBoardManager changeMainWhiteBoardBackImage:self.whiteBordMaskImage];
    [self.whiteBoardManager changeMainWhiteBoardBackgroudColor:self.whiteBordBgColor];
    [self.whiteBoardManager changeMainCourseViewBackgroudColor:self.whiteBordDrawBgColor];

    [self.whiteBoardManager changeAllWhiteBoardBackgroudColor:self.whiteBordBgColor];
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
        self.whiteBordBgColor = YSWhiteBoard_MainBackGroudColor;
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
        self.whiteBordBgColor = YSWhiteBoard_MainBackGroudColor;
    }

    if (drawBgColor)
    {
        self.whiteBordDrawBgColor = drawBgColor;
    }
    else
    {
        self.whiteBordDrawBgColor = YSWhiteBoard_MainBackDrawBoardBgColor;
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
        self.whiteBordLiveBgColor = YSWhiteBoard_MainBackGroudColor;
    }

    if (drawBgColor)
    {
        self.whiteBordLiveDrawBgColor = drawBgColor;
    }
    else
    {
        self.whiteBordLiveDrawBgColor = YSWhiteBoard_MainBackDrawBoardBgColor;
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

- (NSArray <YSFileModel *> *)fileList
{
    return [self.whiteBoardManager.docmentList copy];
}

- (YSFileModel *)currentFile
{
    return [self.whiteBoardManager currentFile];
}

- (YSFileModel *)getFileWithFileID:(NSString *)fileId;
{
    YSFileModel *file = [self.whiteBoardManager getDocumentWithFileID:fileId];
    return file;
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
#pragma mark YSWhiteBoardManagerDelegate

/// 白板准备完毕
- (void)onWhiteBroadCheckRoomFinish:(BOOL)finished
{
    if (!finished)
    {
        return;
    }
    
    if (self.room_UseType == YSRoomUseTypeLiveRoom)
    {
        [self.whiteBoardManager changeMainWhiteBoardBackgroudColor:self.whiteBordLiveBgColor];
        [self.whiteBoardManager changeMainCourseViewBackgroudColor:self.whiteBordLiveDrawBgColor];
    }
}

/**
 文件列表回调
 @param fileList 文件NSDictionary列表
 */
- (void)onWhiteBroadFileList:(NSArray *)fileList
{
    
}

/// H5脚本文件加载初始化完成
- (void)onWhiteBoardPageFinshed:(NSString *)fileId
{
    
}

/// 切换Web课件加载状态
- (void)onWhiteBoardLoadedState:(NSString *)fileId withState:(NSDictionary *)dic
{
    
}

/// Web课件翻页结果
- (void)onWhiteBoardStateUpdate:(NSString *)fileId withState:(NSDictionary *)dic
{
    
}

/// 翻页超时
- (void)onWhiteBoardSlideLoadTimeout:(NSString *)fileId withState:(NSDictionary *)dic
{
    
}

/// 课件缩放
- (void)onWhiteBoardZoomScaleChanged:(NSString *)fileId zoomScale:(CGFloat)zoomScale
{
    
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
- (void)onWhiteBoardChangedMediaFileStateWithFileId:(NSString *)fileId state:(YSMediaState)state
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

/// 切换课件
- (void)onWhiteBoardChangedFileWithFileList:(NSArray *)fileList
{    
    if ([self.whiteBoardDelegate respondsToSelector:@selector(handleonWhiteBoardChangedFileWithFileList:)])
    {
        [self.whiteBoardDelegate handleonWhiteBoardChangedFileWithFileList:fileList];
    }
}

- (void)onSetSmallBoardStageState:(YSSmallBoardStageState)smallBoardStageState
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


#if YSSDK
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
