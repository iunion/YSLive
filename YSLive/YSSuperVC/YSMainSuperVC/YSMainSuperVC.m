//
//  YSMainSuperVC.m
//  YSLive
//
//  Created by jiang deng on 2019/11/7.
//  Copyright © 2019 YS. All rights reserved.
//

#import "YSMainSuperVC.h"
//#import <AVFoundation/AVFoundation.h>

#define YSChangeMediaLine_Delay     5.0f

@interface YSMainSuperVC ()

@property (nonatomic, weak) YSLiveManager *liveManager;
/// 白板视图whiteBord
@property (nonatomic, weak) UIView *whiteBordView;

@end

@implementation YSMainSuperVC

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.bm_CanBackInteractive = NO;
        [self setRoomManagerDelegate];
        
        [self.liveManager serverLog:[NSString stringWithFormat:@"YSMainSuperVC init with class %@", NSStringFromClass([self class])]];
        
        self.videoViewArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (instancetype)initWithWhiteBordView:(UIView *)whiteBordView;
{
    self = [self init];
    if (self)
    {
        self.whiteBordView = whiteBordView;
    }
    return self;
}

- (void)setRoomManagerDelegate
{
    self.liveManager = [YSLiveManager sharedInstance];
    [self.liveManager registerRoomDelegate:self];
    self.liveManager.whiteBoardDelegate = self;
}

- (void)doMsgCachePool
{
}

- (void)beforeDoMsgCachePool
{
}

- (void)afterDoMsgCachePool
{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // 关闭自动锁屏，保证屏幕常亮
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // 自动锁屏
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)showEyeCareRemind
{
    
}

#pragma mark - videoViewArray

- (NSUInteger)getVideoViewCount
{
    NSUInteger count = 0;
    
    for (SCVideoView *videoView in self.videoViewArray)
    {
        if (!videoView.isDragOut && !videoView.isFullScreen)
        {
            count++;
        }
    }
    return count;
}


#pragma mark - 视频窗口

- (void)playVideoAudioWithVideoView:(SCVideoView *)videoView
{
    [self playVideoAudioWithVideoView:videoView needFreshVideo:NO];
}

- (void)playVideoAudioWithVideoView:(SCVideoView *)videoView needFreshVideo:(BOOL)fresh
{
    if (!videoView)
    {
        return;
    }
    
    YSUserMediaPublishState publishState = videoView.roomUser.mediaPublishState;
    CloudHubVideoRenderMode renderType = CloudHubVideoRenderModeHidden;

    fresh = NO;
    
    NSString *userId = videoView.roomUser.peerID;
    NSString *streamID = [self.liveManager getUserStreamIdWithUserId:userId];
    
    CloudHubVideoMirrorMode videoMirrorMode = CloudHubVideoMirrorModeDisabled;
    if (self.appUseTheType != YSRoomUseTypeLiveRoom)
    {
        if (self.liveManager.roomConfig.isMirrorVideo)
        {
            if ([videoView.roomUser.properties bm_boolForKey:sYSUserIsVideoMirror])
            {
                videoMirrorMode = CloudHubVideoMirrorModeEnabled;
            }
        }
    }

    if (publishState & YSUserMediaPublishState_VIDEOONLY)
    {
        if (fresh || (videoView.publishState != YSUser_PublishState_VIDEOONLY && videoView.publishState != YSUser_PublishState_BOTH))
        {
            if (fresh)
            {
                [self.liveManager stopVideoWithUserId:userId streamID:streamID];
            }
            [self.liveManager playVideoWithUserId:userId streamID:streamID renderMode:renderType mirrorMode:videoMirrorMode inView:videoView];
        }
    }
    else
    {
        [self.liveManager stopVideoWithUserId:userId streamID:streamID];
    }
    
    [videoView freshWithRoomUserProperty:videoView.roomUser];
    videoView.publishState = videoView.roomUser.publishState;
}

- (void)playVideoAudioWithNewVideoView:(SCVideoView *)videoView
{
    if (!videoView)
    {
        return;
    }

    YSUserMediaPublishState publishState = videoView.roomUser.mediaPublishState;
    CloudHubVideoRenderMode renderType = CloudHubVideoRenderModeHidden;

    NSString *userId = videoView.roomUser.peerID;
    NSString *streamID = [self.liveManager getUserStreamIdWithUserId:userId];
    CloudHubVideoMirrorMode videoMirrorMode = CloudHubVideoMirrorModeDisabled;
    if (self.appUseTheType != YSRoomUseTypeLiveRoom)
    {
        if (self.liveManager.roomConfig.isMirrorVideo)
        {
            if ([videoView.roomUser.properties bm_boolForKey:sYSUserIsVideoMirror])
            {
                videoMirrorMode = CloudHubVideoMirrorModeEnabled;
            }
        }
    }

    if (publishState & YSUserMediaPublishState_VIDEOONLY)
    {
        [self.liveManager stopVideoWithUserId:userId streamID:streamID];
        [self.liveManager playVideoWithUserId:userId streamID:streamID renderMode:renderType mirrorMode:videoMirrorMode inView:videoView];
    }
    else
    {
        [self.liveManager stopVideoWithUserId:userId streamID:streamID];
    }
    
    [videoView freshWithRoomUserProperty:videoView.roomUser];

    videoView.publishState = videoView.roomUser.publishState;
}

- (void)stopVideoAudioWithVideoView:(SCVideoView *)videoView
{
    if (!videoView)
    {
        return;
    }
    
    NSString *userId = videoView.roomUser.peerID;
    NSString *streamID = [self.liveManager getUserStreamIdWithUserId:userId];
    
    [self.liveManager stopVideoWithUserId:userId streamID:streamID];
    videoView.publishState = 4;
}

#pragma mark  添加视频窗口

- (SCVideoView *)addVidoeViewWithPeerId:(NSString *)peerId
{
    return [self addVidoeViewWithPeerId:peerId withMaxCount:0];
}

- (SCVideoView *)addVidoeViewWithPeerId:(NSString *)peerId withMaxCount:(NSUInteger)count
{
    YSRoomUser *roomUser = [self.liveManager getRoomUserWithId:peerId];
    if (!roomUser)
    {
        return nil;
    }
    
    // 删除本人占位视频
    for (SCVideoView *avideoView in self.videoViewArray)
    {
        if (avideoView.isForPerch)
        {
            [self.videoViewArray removeObject:avideoView];
            break;
        }
    }
    
    BOOL isUserExist = NO;
    SCVideoView *theVideoView = nil;
    for (SCVideoView *videoView in self.videoViewArray)
    {
        if ([videoView.roomUser.peerID isEqualToString:peerId])
        {
            theVideoView = videoView;
            // property刷新原用户的值没有变化，需要重新赋值user
            [videoView freshWithRoomUserProperty:roomUser];
            isUserExist = YES;
            break;
        }
    }
    
    SCVideoView *newVideoView = nil;
    if (!isUserExist)
    {
        newVideoView = [[SCVideoView alloc] initWithRoomUser:roomUser withDelegate:self];
        newVideoView.appUseTheType = self.appUseTheType;
        theVideoView = newVideoView;
        if (newVideoView)
        {
            if (count == 0)
            {
                [self.videoViewArray addObject:newVideoView];
            }
            else
            {
                [self.videoViewArray bm_addObject:newVideoView withMaxCount:count];
            }
            if (roomUser.role == YSUserType_Teacher)
            {
                self.teacherVideoView = newVideoView;
            }
        }
        
        if (self.teacherVideoView)
        {
            [self.videoViewArray removeObject:self.teacherVideoView];
        }
        // id正序排序
        [self.videoViewArray sortUsingComparator:^NSComparisonResult(SCVideoView * _Nonnull obj1, SCVideoView * _Nonnull obj2) {
            return [obj1.roomUser.peerID compare:obj2.roomUser.peerID];
        }];
        if (self.teacherVideoView)
        {
            [self.videoViewArray insertObject:self.teacherVideoView atIndex:0];
        }
    }
    
    [theVideoView bringSubviewToFront:newVideoView.backVideoView];
    
    if (theVideoView)
    {
        [self playVideoAudioWithVideoView:theVideoView];
    }
    
    return newVideoView;
}

#pragma mark  获取视频窗口

- (SCVideoView *)getVideoViewWithPeerId:(NSString *)peerId
{
    for (SCVideoView *videoView in self.videoViewArray)
    {
        if ([videoView.roomUser.peerID isEqualToString:peerId])
        {
            return videoView;
        }
    }
    
    return nil;
}

#pragma mark  删除视频窗口

- (SCVideoView *)delVidoeViewWithPeerId:(NSString *)peerId
{
    SCVideoView *delVideoView = nil;
    if ([peerId isEqualToString:self.teacherVideoView.roomUser.peerID])
    {
        delVideoView = self.teacherVideoView;
        [self.videoViewArray removeObject:self.teacherVideoView];
        self.teacherVideoView = nil;
    }
    else
    {
        for (SCVideoView *videoView in self.videoViewArray)
        {
            if ([videoView.roomUser.peerID isEqualToString:peerId])
            {
                delVideoView = videoView;
                [self.videoViewArray removeObject:videoView];
                break;
            }
        }
    }
    
    if (delVideoView)
    {
        [self stopVideoAudioWithVideoView:delVideoView];
    }
    
    return delVideoView;
}

#pragma mark  删除所有视频窗口

- (void)removeAllVideoView
{
    [self.videoViewArray removeAllObjects];
}


#pragma -
#pragma mark SCVideoViewDelegate

///点击手势事件
- (void)clickViewToControlWithVideoView:(SCVideoView*)videoView
{
    
}

///拖拽手势事件
- (void)panToMoveVideoView:(SCVideoView*)videoView withGestureRecognizer:(UIPanGestureRecognizer *)pan
{
    
}


#pragma -
#pragma mark YSSessionDelegate

/// 发生错误 回调
- (void)onRoomDidOccuredError:(CloudHubErrorCode)errorCode withMessage:(NSString *)message
{
    
}

/// 失去连接
- (void)onRoomConnectionLost
{
//    [BMProgressHUD bm_showHUDAddedTo:YSKeyWindow animated:YES];
    [BMProgressHUD bm_showHUDAddedTo:self.view animated:YES];
}

// 成功进入房间
- (void)onRoomJoined
{
    // 断开的时候不再发送这个
    // onRoomConnectionLost
    BMLog(@"=========== reconnect onRoomJoined");
    [BMProgressHUD bm_hideAllHUDsForView:YSKeyWindow animated:YES];
}

- (void)onRoomReJoined
{
    // 断开的时候会发这个
    // onRoomConnectionLost
    
    BMLog(@"=========== reconnect onRoomReJoined");
//    [BMProgressHUD bm_hideAllHUDsForView:YSKeyWindow animated:YES];
    [BMProgressHUD bm_hideAllHUDsForView:self.view animated:YES];
}

// 已经离开房间
- (void)onRoomLeft
{
    [BMProgressHUD bm_hideAllHUDsForView:YSKeyWindow animated:YES];
}

- (void)onRoomKickedOut:(NSInteger)reasonCode
{
    if (reasonCode == 1)
    {
        NSString *roomIdKey = YSKickTime;
        if ([self.liveManager.room_Id bm_isNotEmpty])
        {
            roomIdKey = [NSString stringWithFormat:@"%@_%@", YSKickTime, self.liveManager.room_Id ];
        }
        
        // 存储被踢时间
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:roomIdKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark 用户user

/// 用户进入
- (void)onRoomUserJoined:(YSRoomUser *)user isHistory:(BOOL)isHistory
{
    NSString *roleName = nil;
    if (user.role == YSUserType_Teacher)
    {
        roleName = YSLocalized(@"Role.Teacher");
    }
    else if (user.role == YSUserType_Assistant)
    {
        roleName = YSLocalized(@"Role.Assistant");
    }
    else if (user.role == YSUserType_Student)
    {
        roleName = YSLocalized(@"Role.Student");
    }
    
    if (!self.liveManager.isBigRoom && !isHistory && roleName)
    {
        NSString *message = [NSString stringWithFormat:@"%@(%@) %@", user.nickName, roleName, YSLocalized(@"Action.EnterRoom")];
        [self.liveManager sendTipMessage:message tipType:YSChatMessageType_Tips];
    }
}

/// 用户退出
- (void)onRoomUserLeft:(YSRoomUser *)user
{
    NSString *roleName = nil;
    if (user.role == YSUserType_Teacher)
    {
        roleName = YSLocalized(@"Role.Teacher");
    }
    else if(user.role == YSUserType_Assistant)
    {
        roleName = YSLocalized(@"Role.Assistant");
    }
    else if (user.role == YSUserType_Student)
    {
        roleName = YSLocalized(@"Role.Student");
    }
    
    if (!self.liveManager.isBigRoom && roleName)
    {
        NSString *message = [NSString stringWithFormat:@"%@(%@) %@", user.nickName, roleName, YSLocalized(@"Action.ExitRoom")];
        [self.liveManager sendTipMessage:message tipType:YSChatMessageType_Tips];
    }
}


#pragma mark 用户流

/// 大房间同步上台用户属性
- (void)handleSignalingSyncProperty:(YSRoomUser *)roomUser
{
    [self userPublishstatechange:roomUser];
}

- (void)userPublishstatechange:(YSRoomUser *)roomUser
{
    
}

/// 用户流音量变化
- (void)onRoomAudioVolumeWithUserId:(NSString *)userId volume:(NSInteger)volume
{
    SCVideoView *view = [self getVideoViewWithPeerId:userId];
    view.iVolume = volume;
}

/// 开关摄像头
- (void)onRoomCloseVideo:(BOOL)close withUid:(NSString *)uid streamID:(NSString *)streamID
{
    SCVideoView *view = [self getVideoViewWithPeerId:uid];
    [view freshWithRoomUserProperty:view.roomUser];
}

/// 开关麦克风
- (void)onRoomCloseAudio:(BOOL)close withUid:(NSString *)uid
{
    SCVideoView *view = [self getVideoViewWithPeerId:uid];
    [view freshWithRoomUserProperty:view.roomUser];
}

/// 收到音视频流
- (void)onRoomStartVideoOfUid:(NSString *)uid streamID:(nullable NSString *)streamID
{
    SCVideoView *videoView = [self getVideoViewWithPeerId:uid];
    if (videoView)
    {
        YSRoomUser *roomUser = videoView.roomUser;
        [self.liveManager playVideoWithUserId:uid streamID:streamID renderMode:CloudHubVideoRenderModeHidden mirrorMode:[roomUser.properties bm_boolForKey:sYSUserIsVideoMirror] inView:videoView];
        [videoView freshWithRoomUserProperty:roomUser];
    }
}

/// 停止音视频流
- (void)onRoomStopVideoOfUid:(NSString *)uid streamID:(nullable NSString *)streamID
{
    [self.liveManager stopVideoWithUserId:uid streamID:streamID];
}

#pragma mark 用户网络差，被服务器切换媒体线路

- (void)roomManagerChangeMediaLine
{
    [BMProgressHUD bm_showHUDAddedTo:self.view animated:YES withText:nil detailText:YSLocalized(@"HUD.NetworkPoor") images:@[@"hud_network_poor0", @"hud_network_poor1", @"hud_network_poor2", @"hud_network_poor3"] duration:0.8f delay:YSChangeMediaLine_Delay];
}

/// 全体禁言
- (void)handleSignalingToDisAbleEveryoneBanChatWithIsDisable:(BOOL)isDisable
{
    if (isDisable)
    {
        [self.liveManager sendTipMessage:YSLocalized(@"Prompt.BanChatInView") tipType:YSChatMessageType_Tips];
    }
    else
    {
        [self.liveManager sendTipMessage:YSLocalized(@"Prompt.CancelBanChatInView") tipType:YSChatMessageType_Tips];
    }
}

#pragma mark meidia
/// 媒体流发布状态
- (void)onRoomShareMediaFile:(YSSharedMediaFileModel *)mediaFileModel
{
    if (![self.liveManager.whiteBoardManager isOneWhiteBoardView])
    {
        /// 多课件不做处理
        return;
    }

    if (mediaFileModel.state == YSMediaState_Play)
    {
        [self handleWhiteBordPlayMediaFileWithMedia:mediaFileModel];
    }
    else
    {
        [self handleWhiteBordStopMediaFileWithMedia:mediaFileModel];
    }
}

/// 更新媒体流的信息
- (void)onRoomUpdateMediaFileStream:(YSSharedMediaFileModel *)mediaFileModel isSetPos:(BOOL)isSetPos
{
    if (![self.liveManager.whiteBoardManager isOneWhiteBoardView])
    {
        return;
    }
    
    if (isSetPos)
    {
        [self onRoomUpdateMediaStream:mediaFileModel.duration pos:mediaFileModel.pos isPlay:YES];
    }
    else
    {
        if (mediaFileModel.state == YSMediaState_Play)
        {
            [self handleWhiteBordPlayMediaStream:mediaFileModel];
        }
        else
        {
            [self handleWhiteBordPauseMediaStream:mediaFileModel];
        }
    }
}

- (void)handleWhiteBordPlayMediaFileWithMedia:(YSSharedMediaFileModel *)mediaModel
{
    
}

- (void)handleWhiteBordStopMediaFileWithMedia:(YSSharedMediaFileModel *)mediaModel
{
    
}

- (void)handleWhiteBordPlayMediaStream:(YSSharedMediaFileModel *)mediaFileModel
{
    
}

- (void)handleWhiteBordPauseMediaStream:(YSSharedMediaFileModel *)mediaFileModel
{
    
}

- (void)onRoomUpdateMediaStream:(NSTimeInterval)duration
                            pos:(NSTimeInterval)pos
                         isPlay:(BOOL)isPlay
{
    
}

/*
- (void)addBaseNotification
{
    // 声音
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(routeChange:)
                                                name:AVAudioSessionRouteChangeNotification
                                              object:[AVAudioSession sharedInstance]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAudioSessionInterruption:)
                                                 name:AVAudioSessionInterruptionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMediaServicesReset:)
                                                 name:AVAudioSessionMediaServicesWereResetNotification object:nil];
}


#pragma mark -
#pragma mark 音频相关

/// 判断是否有耳机
- (BOOL)hasHeadset
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    AVAudioSessionRouteDescription *currentRoute = [audioSession currentRoute];

    for (AVAudioSessionPortDescription *output in currentRoute.outputs)
    {
          if ([[output portType] isEqualToString:AVAudioSessionPortBuiltInReceiver])
          {
                return NO;
          }
    }
    return YES;
}

- (void)handleAudioSessionInterruption:(NSNotification*)notification
{
    NSNumber *interruptionType = [[notification userInfo] objectForKey:AVAudioSessionInterruptionTypeKey];
    NSNumber *interruptionOption = [[notification userInfo] objectForKey:AVAudioSessionInterruptionOptionKey];
    
    switch (interruptionType.unsignedIntegerValue)
    {
        case AVAudioSessionInterruptionTypeBegan:
        {
            // • Audio has stopped, already inactive
            // • Change state of UI, etc., to reflect non-playing state
        }
            break;
        case AVAudioSessionInterruptionTypeEnded:
        {
            // • Make session active
            // • Update user interface
            // • AVAudioSessionInterruptionOptionShouldResume option
            if (interruptionOption.unsignedIntegerValue == AVAudioSessionInterruptionOptionShouldResume)
            {
                // Here you should continue playback.
                //[player play];
            }
        }
            break;
        default:
            break;
    }
    
    AVAudioSessionInterruptionType type = (AVAudioSessionInterruptionType)[notification.userInfo[AVAudioSessionInterruptionTypeKey] intValue];
    BMLog(@"音频相关===== 当前声音被打断 %@", @(type));
}

- (void)handleMediaServicesReset:(NSNotification *)aNotification
{
    AVAudioSessionInterruptionType type = (AVAudioSessionInterruptionType)[aNotification.userInfo[AVAudioSessionInterruptionTypeKey] intValue];
    BMLog(@"音频相关===== 当前AVAudioSessionMediaServicesWereResetNotification: 打断 %@", @(type));
}

// 音频设备切换
- (void)routeChange:(NSNotification *)notification
{
    if (notification)
    {
        AVAudioSession *audioSession = (AVAudioSession *)notification.userInfo;
        if (([AVAudioSession sharedInstance].categoryOptions !=AVAudioSessionCategoryOptionMixWithOthers )||([AVAudioSession sharedInstance].category !=AVAudioSessionCategoryPlayAndRecord))
        {
        }
        
        [self pluggInOrOutMicrophone:notification.userInfo];
        [self printAudioCurrentCategory];
        [self printAudioCurrentMode];
        [self printAudioCategoryOption];
        
    }
}

- (void)pluggInOrOutMicrophone:(NSDictionary *)userInfo
{
    NSDictionary *interuptionDict = userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason)
    {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            BMLog(@"耳机插入");
            self.isHeadphones = YES;
            self.iVolume = 0.5;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:ysPluggInMicrophoneNotification object:nil];
            break;
            
        case AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory:
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            BMLog(@"耳机拔出，停止播放操作");
            self.isHeadphones = NO;
            self.iVolume = 1;
            [[NSNotificationCenter defaultCenter] postNotificationName:ysUnunpluggingHeadsetNotification object:nil];
            
            break;
            
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            BMLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
            break;
    }
}

- (void)printAudioCurrentCategory
{
    NSString *audioCategory =  [AVAudioSession sharedInstance].category;
    if ( audioCategory == AVAudioSessionCategoryAmbient ){
        BMLog(@"---jin current category is : AVAudioSessionCategoryAmbient");
    } else if ( audioCategory == AVAudioSessionCategorySoloAmbient ){
        BMLog(@"---jin current category is : AVAudioSessionCategorySoloAmbient");
    } else if ( audioCategory == AVAudioSessionCategoryPlayback ){
        BMLog(@"---jin current category is : AVAudioSessionCategoryPlayback");
    }  else if ( audioCategory == AVAudioSessionCategoryRecord ){
        BMLog(@"---jin current category is : AVAudioSessionCategoryRecord");
    } else if ( audioCategory == AVAudioSessionCategoryPlayAndRecord ){
        BMLog(@"---jin current category is : AVAudioSessionCategoryPlayAndRecord");
    } else if ( audioCategory == AVAudioSessionCategoryAudioProcessing ){
        BMLog(@"---jin current category is : AVAudioSessionCategoryAudioProcessing");
    } else if ( audioCategory == AVAudioSessionCategoryMultiRoute ){
        BMLog(@"---jin current category is : AVAudioSessionCategoryMultiRoute");
    }  else {
        BMLog(@"---jin current category is : unknow");
    }
    
}

- (void)printAudioCurrentMode
{
    NSString *audioMode =  [AVAudioSession sharedInstance].mode;
    if ( audioMode == AVAudioSessionModeDefault ){
        BMLog(@"---jin current mode is : AVAudioSessionModeDefault");
    } else if ( audioMode == AVAudioSessionModeVoiceChat ){
        BMLog(@"---jin current mode is : AVAudioSessionModeVoiceChat");
    } else if ( audioMode == AVAudioSessionModeGameChat ){
        BMLog(@"---jin current mode is : AVAudioSessionModeGameChat");
    }  else if ( audioMode == AVAudioSessionModeVideoRecording ){
        BMLog(@"---jin current mode is : AVAudioSessionModeVideoRecording");
    } else if ( audioMode == AVAudioSessionModeMeasurement ){
        BMLog(@"---jin current mode is : AVAudioSessionModeMeasurement");
    } else if ( audioMode == AVAudioSessionModeMoviePlayback ){
        BMLog(@"---jin current mode is : AVAudioSessionModeMoviePlayback");
    } else if ( audioMode == AVAudioSessionModeVideoChat ){
        BMLog(@"---jin current mode is : AVAudioSessionModeVideoChat");
    }else if ( audioMode == AVAudioSessionModeSpokenAudio ){
        BMLog(@"---jin current mode is : AVAudioSessionModeSpokenAudio");
    } else {
        BMLog(@"---jin current mode is : unknow");
    }
}

- (void)printAudioCategoryOption
{
    NSString *tSString = @"AVAudioSessionCategoryOptionMixWithOthers";
    switch ([AVAudioSession sharedInstance].categoryOptions) {
        case AVAudioSessionCategoryOptionDuckOthers:
            tSString = @"AVAudioSessionCategoryOptionDuckOthers";
            break;
        case AVAudioSessionCategoryOptionAllowBluetooth:
            tSString = @"AVAudioSessionCategoryOptionAllowBluetooth";
//            if (![YSEduSessionHandle shareInstance].isPlayMedia) {
//                BMLog(@"---jin sessionManagerUserPublished");
//            }
            break;
        case AVAudioSessionCategoryOptionDefaultToSpeaker:
            tSString = @"AVAudioSessionCategoryOptionDefaultToSpeaker";
            break;
        case AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers:
            tSString = @"AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers";
            break;
        case AVAudioSessionCategoryOptionAllowBluetoothA2DP:
            tSString = @"AVAudioSessionCategoryOptionAllowBluetoothA2DP";
            break;
        case AVAudioSessionCategoryOptionAllowAirPlay:
            tSString = @"AVAudioSessionCategoryOptionAllowAirPlay";
            break;
        default:
            break;
    }
    
    BMLog(@"---jin current categoryOptions is :%@", tSString);
}
*/

@end
