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
    [self.liveManager registerRoomManagerDelegate:self];
}

- (void)doMsgCachePool
{
    [self.liveManager serverLog:@"doMsgCachePool"];
    self.liveManager.readyToHandleMsg = YES;

    [self beforeDoMsgCachePool];
    
    [self.liveManager doMsgCachePool];
    
    [self afterDoMsgCachePool];
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

    [self performSelector:@selector(doMsgCachePool) withObject:nil afterDelay:0.5];
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

/// 失去连接
- (void)onRoomConnectionLost
{
//    [BMProgressHUD bm_showHUDAddedTo:YSKeyWindow animated:YES];
    [BMProgressHUD bm_showHUDAddedTo:self.view animated:YES];
}

// 成功进入房间
- (void)onRoomJoined:(long)ts;
{
    // 断开的时候不再发送这个
    // onRoomConnectionLost
    BMLog(@"=========== reconnect onRoomJoined");
    [BMProgressHUD bm_hideAllHUDsForView:YSKeyWindow animated:YES];
}

- (void)onRoomReJoined:(long)ts
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


#pragma mark 用户网络差，被服务器切换媒体线路

- (void)roomManagerChangeMediaLine
{
    [BMProgressHUD bm_showHUDAddedTo:self.view animated:YES withText:nil detailText:YSLocalized(@"HUD.NetworkPoor") images:@[@"hud_network_poor0", @"hud_network_poor1", @"hud_network_poor2", @"hud_network_poor3"] duration:0.8f delay:YSChangeMediaLine_Delay];
}

#pragma mark 用户视频状态变化的通知

- (void)onRoomUserVideoStatus:(NSString *)peerID state:(YSMediaState)state
{
//    if (state == YSMedia_Pulished)
//    {
//        if (self.liveManager.roomConfig.isMirrorVideo)
//        {
//            YSRoomUser *roomUser = [self.liveManager.roomManager getRoomUserWithUId:peerID];
//            NSDictionary *properties = roomUser.properties;
//            if ([properties bm_isNotEmptyDictionary] && [properties bm_containsObjectForKey:sUserIsVideoMirror])
//            {
//                BOOL isVideoMirror = [properties bm_boolForKey:sUserIsVideoMirror];
//                [self.liveManager changeVideoMirrorWithPeerId:peerID mirror:isVideoMirror];
//            }
//        }
//    }
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
- (void)roomWhiteBoardOnUpdateMediaFileStream:(YSSharedMediaFileModel *)mediaFileModel
{
    if (![self.liveManager.whiteBoardManager isOneWhiteBoardView])
    {
        return;
    }
    
    if (mediaFileModel.state == YSMediaState_Play)
    {
        [self handleWhiteBordPlayMediaStream:mediaFileModel];
    }
    else
    {
        [self handleWhiteBordPauseMediaStream:mediaFileModel];
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
