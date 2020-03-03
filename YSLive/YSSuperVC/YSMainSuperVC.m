//
//  YSMainSuperVC.m
//  YSLive
//
//  Created by jiang deng on 2019/11/7.
//  Copyright © 2019 YS. All rights reserved.
//

#import "YSMainSuperVC.h"
//#import <AVFoundation/AVFoundation.h>

@interface YSMainSuperVC ()
<
    YSLiveRoomManagerDelegate
>
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
    self.liveManager = [YSLiveManager shareInstance];
    [self.liveManager registerRoomManagerDelegate:self];
}

- (void)doMsgCachePool
{
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

    // 保证屏幕常亮
    [UIApplication sharedApplication].idleTimerDisabled = YES;

    self.liveManager.viewDidAppear = YES;
    [self performSelector:@selector(doMsgCachePool) withObject:nil afterDelay:0.5];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

/// 失去连接
- (void)onRoomConnectionLost
{
    // 等待重连
    self.waitingForReconnect = YES;

    [BMProgressHUD bm_showHUDAddedTo:YSKeyWindow animated:YES];
}

// 成功进入房间
- (void)onRoomJoined:(long)ts;
{
//    断开的时候会发这个
//onRoomConnectionLost
    BMLog(@"=========== reconnect onRoomJoined");
    [BMProgressHUD bm_hideAllHUDsForView:YSKeyWindow animated:YES];
    
    // 等待重连
    self.waitingForReconnect = NO;
}

// 已经离开房间
- (void)onRoomLeft
{
    [BMProgressHUD bm_hideAllHUDsForView:YSKeyWindow animated:YES];
}

- (void)showEyeCareRemind
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
