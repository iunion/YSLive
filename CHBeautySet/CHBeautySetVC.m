//
//  CHBeautySetVC.m
//  YSLive
//
//  Created by jiang deng on 2021/3/29.
//  Copyright © 2021 CH. All rights reserved.
//

#import "CHBeautySetVC.h"
#import <AVFoundation/AVFoundation.h>
#import "YSLiveManager.h"
#import "AppDelegate.h"

#import "CHPermissionsView.h"
#import "CHBeautySetView.h"

@interface CHBeautySetVC ()
<
    AVAudioPlayerDelegate,
    CHPermissionsViewDelegate,
    CHBeautySetViewDelegate
>

@property (nonatomic, strong) NSTimer *levelTimer;

/// 音频播放器
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) AVAudioSession *session;

@property (nonatomic, strong) NSString *filePath;

@property (nonatomic, strong) AVAudioRecorder *recorder;


@property (nonatomic, weak) UIView *topView;

/// 无视频权限背景图
@property (nonatomic, weak) UIImageView *backImageView;
/// 视频权限提醒
@property (nonatomic, weak) UILabel *permissionLabel;

/// 本人视频窗口
@property (nonatomic, weak) UIView *largeVideoView;

/// 底部背景窗口
@property (nonatomic, weak) UIView *bottomView;

/// 设备权限控制
@property (nonatomic, weak) CHPermissionsView *permissionsView;
/// 美颜设置
@property (nonatomic, weak) CHBeautySetView *beautySetView;

/// 进入
@property (nonatomic, weak) UIButton *enterBtn;

@end

@implementation CHBeautySetVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.bm_CanBackInteractive = NO;

    self.beautySetModel.whitenValue = 0.7f;
    self.beautySetModel.exfoliatingValue = 0.5f;
    self.beautySetModel.ruddyValue = 0.1f;
    
    [self setupAVAudio];

    [self setupView];
    
    self.filePath = [self getPlayPath];
}

#pragma mark 横竖屏

- (BOOL)shouldAutorotate
{
#if YSAutorotateNO
    return NO;
#else
#if YSSDK
    if ([YSSDKManager sharedInstance].useAppDelegateAllowRotation)
    {
        return NO;
    }
#else
    if (GetAppDelegate.useAllowRotation)
    {
        return NO;
    }
#endif
    
    return YES;
#endif
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)setupAVAudio
{
    self.session = [AVAudioSession sharedInstance];
    //[self.session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker | AVAudioSessionCategoryOptionMixWithOthers | AVAudioSessionCategoryOptionAllowBluetooth error:nil];
    
    [self startVollumListening];
}

- (void)startVollumListening
{
    [self.session setActive:NO error:nil];

    [self.session setCategory:AVAudioSessionCategoryRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker | AVAudioSessionCategoryOptionMixWithOthers | AVAudioSessionCategoryOptionAllowBluetooth error:nil];

    [self.session setActive:YES error:nil];
    
    // 不需要保存录音文件
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
    [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
    [NSNumber numberWithInt:kAudioFormatAppleLossless], AVFormatIDKey,
    [NSNumber numberWithInt:2], AVNumberOfChannelsKey,
    [NSNumber numberWithInt:AVAudioQualityMax], AVEncoderAudioQualityKey, nil];

    NSError *error;
    AVAudioRecorder *recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    if (recorder)
    {
        self.recorder = recorder;
        
        [recorder prepareToRecord];
        recorder.meteringEnabled = YES;
        [recorder record];
        
        self.levelTimer = [NSTimer scheduledTimerWithTimeInterval: 0.3 target:self selector:@selector(levelTimerCallback:) userInfo:nil repeats:YES];
    }
    else
    {
        NSLog(@"%@", [error description]);
    }
}

- (void)stopVollumListening
{
    [self.recorder stop];
    
    if (self.levelTimer)
    {
        [self.levelTimer invalidate];
        self.levelTimer = nil;
    }

    [self.permissionsView changeVolumLevel:0.0f];
        
    [self.session setActive:NO error:nil];

    [self.session setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker | AVAudioSessionCategoryOptionMixWithOthers | AVAudioSessionCategoryOptionAllowBluetooth error:nil];
    
    [self.session setActive:YES error:nil];

    NSError *error = nil;
    BOOL success = [self.session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
    if(!success)
    {
        NSLog(@"error doing outputaudioportoverride - %@", [error localizedDescription]);
    }
}

/// 该方法确实会随环境音量变化而变化，但具体分贝值是否准确暂时没有研究
- (void)levelTimerCallback:(NSTimer *)timer
{
    [self.recorder updateMeters];
    
    float level; // The linear 0.0 .. 1.0 value we need.
    float minDecibels = -60.0f; // use -80db Or use -60dB, which I measured in a silent room.
    float decibels = [self.recorder averagePowerForChannel:0];
    
    if (decibels < minDecibels)
    {
        level = 0.0f;
    }
    else if (decibels >= 0.0f)
    {
        level = 1.0f;
    }
    else
    {
        float root = 5.0f; //modified level from 2.0 to 5.0 is neast to real test
        float minAmp = powf(10.0f, 0.05f * minDecibels);
        float inverseAmpRange = 1.0f / (1.0f - minAmp);
        float amp = powf(10.0f, 0.05f * decibels);
        float adjAmp = (amp - minAmp) * inverseAmpRange;
        
        level = powf(adjAmp, 1.0f / root);
    }
    
    /* level 范围[0 ~ 1], 转为[0 ~120] 之间 */
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSLog(@"voice updated :%f",level * 120);
        //self.layerVoice.frame = CGRectMake(0, 0, level * 120, 50);
        [self.permissionsView changeVolumLevel:level];
    });
}

- (void)setupView
{
    self.view.backgroundColor = [UIColor bm_colorWithHex:0x24262C];
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BMUI_SCREEN_WIDTH, BMUI_SCREEN_WIDTH * 0.5)];
    [self.view addSubview:topView];
    self.topView = topView;

    UIImageView *backImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"permissions_noCamera"]];
    [self.topView addSubview:backImageView];
    [backImageView bm_centerInSuperView];
    self.backImageView = backImageView;

    UILabel *permissionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, BMUI_SCREEN_WIDTH - 80.0f, 36.0f)];
    permissionLabel.font = [UIFont systemFontOfSize:10.0f];
    permissionLabel.textColor = [UIColor bm_colorWithHex:0xE18D49];
    permissionLabel.textAlignment = NSTextAlignmentCenter;
    permissionLabel.numberOfLines = 0;
    permissionLabel.text = YSLocalized(@"BeautySet.Note");
    [self.topView addSubview:permissionLabel];
    [permissionLabel bm_centerHorizontallyInSuperViewWithTop:backImageView.bm_bottom + 20.0f];
    self.permissionLabel = permissionLabel;

    UIView *largeVideoView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:largeVideoView];
    largeVideoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.largeVideoView = largeVideoView;

    // 初始美颜设置环境
    [self resetBeautySetEnvironmental];
    
    [self.liveManager playVideoWithUserId:self.liveManager.localUser.peerID streamID:nil renderMode:CloudHubVideoRenderModeHidden mirrorMode:CloudHubVideoMirrorModeDisabled inView:largeVideoView];
    self.liveManager.sessionManagerSelfVolume = ^(NSUInteger volume) {
        NSLog(@"volume: %@", @(volume));
    };
    
    UIView *bottomView = [[UIView alloc] init];
    bottomView.backgroundColor = [UIColor bm_colorWithHex:0x1C1D20 alpha:0.4f];
    [self.view addSubview:bottomView];
    bottomView.bm_width = BMUI_SCREEN_WIDTH;
    self.bottomView = bottomView;
    
    CHPermissionsView *permissionsView = [[CHPermissionsView alloc] initWithFrame:self.view.bounds];
    permissionsView.liveManager = self.liveManager;
    permissionsView.delegate = self;
    permissionsView.beautySetModel = self.beautySetModel;
    [self.bottomView addSubview:permissionsView];
    self.permissionsView = permissionsView;

    bottomView.bm_height = permissionsView.bm_height + 70.0f;
    bottomView.bm_top = BMUI_SCREEN_HEIGHT - bottomView.bm_height;
    
    CHBeautySetView *beautySetView = [[CHBeautySetView alloc] initWithFrame:self.view.bounds];
    beautySetView.liveManager = self.liveManager;
    beautySetView.delegate = self;
    beautySetView.beautySetModel = self.beautySetModel;
    beautySetView.hidden = YES;
    [self.bottomView addSubview:beautySetView];
    self.beautySetView = beautySetView;
    
    CGFloat btnWidth = 90.0f;
    if ([UIDevice bm_isiPad])
    {
        btnWidth = 120.0f;
    }
    UIButton *enterBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnWidth, 30.0f)];
    enterBtn.backgroundColor = [UIColor bm_colorWithHex:0x1C1D20 alpha:0.4f];
    [enterBtn setTitle:YSLocalized(@"BeautySet.Enter") forState:UIControlStateNormal];
    enterBtn.titleLabel.font = UI_FONT_12;
    [enterBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [enterBtn addTarget:self action:@selector(enterBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [enterBtn bm_roundedRect:enterBtn.bm_height*0.5];
    [self.bottomView addSubview:enterBtn];
    enterBtn.bm_centerX = bottomView.bm_centerX;
    enterBtn.bm_top = bottomView.bm_height - 55.0f;
    self.enterBtn = enterBtn;
}

- (void)setBeautySetModel:(CHBeautySetModel *)beautySetModel
{
    _beautySetModel = beautySetModel;
    
    if (!beautySetModel.microphonePermissions)
    {
        [self stopVollumListening];
    }
    
#warning test propUrlArray
    [self performSelector:@selector(adddata) withObject:nil afterDelay:2];
}

- (void)adddata
{
    NSMutableArray *propUrlArray = [NSMutableArray array];
    
    [propUrlArray addObject:@"1"];
    [propUrlArray addObject:@"1"];
    [propUrlArray addObject:@"1"];
    [propUrlArray addObject:@"1"];
    [propUrlArray addObject:@"1"];
    [propUrlArray addObject:@"1"];
    [propUrlArray addObject:@"1"];
    [propUrlArray addObject:@"1"];
    [propUrlArray addObject:@"1"];
    [propUrlArray addObject:@"1"];
    [propUrlArray addObject:@"1"];
    [propUrlArray addObject:@"1"];
    [propUrlArray addObject:@"1"];
    [propUrlArray addObject:@"1"];
    [propUrlArray addObject:@"1"];
    [propUrlArray addObject:@"1"];
    [propUrlArray addObject:@"1"];
    [propUrlArray addObject:@"1"];
    [propUrlArray addObject:@"1"];
    [propUrlArray addObject:@"1"];

    self.beautySetModel.propUrlArray = propUrlArray;
    self.beautySetModel.propIndex = 2;

    self.beautySetView.beautySetModel = self.beautySetModel;
}

- (void)enterBtnClick:(id)sender
{
    if (self.permissionsView.hidden)
    {
        [UIView animateWithDuration:0.5 animations:^{
            self.bottomView.bm_height = self.permissionsView.bm_height + 70.0f;
            self.bottomView.bm_top = BMUI_SCREEN_HEIGHT - self.bottomView.bm_height;

            self.beautySetView.hidden = YES;
            self.permissionsView.hidden = NO;
            
            [self.enterBtn setTitle:YSLocalized(@"BeautySet.Enter") forState:UIControlStateNormal];
            self.enterBtn.bm_top = self.bottomView.bm_height - 55.0f;
        }];

        return;
    }
    
    [self stopVollumListening];
    //[self.session setActive:NO error:nil];

    [self.liveManager stopVideoWithUserId:self.liveManager.localUser.peerID streamID:nil];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(beautySetFinished:)])
    {
        [self.delegate beautySetFinished:YES];
    }
}

- (void)resetBeautySetEnvironmental
{
    // 复原摄像头设置
    [self.liveManager useFrontCamera:YES];
    [self.liveManager.cloudHubRtcEngineKit setVideoRotation:CloudHubHomeButtonOnBottom];
    
    //[self.liveManager setCameraFlipMode:NO Vertivcal:NO];
    //[self.liveManager resetCameraKeystoning];
}

- (NSString *)getPlayPath
{
    NSString *currentLanguageRegion = [[NSLocale preferredLanguages] firstObject];
    NSBundle *bundle = [NSBundle bundleWithPath: [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"YSResources.bundle"]];
    NSString *filePath = nil;

    if([currentLanguageRegion bm_containString:@"zh-Hant"] || [currentLanguageRegion bm_containString:@"zh-Hans"])
    {
        filePath = [[bundle resourcePath] stringByAppendingPathComponent:@"SpeakerDetection_China.mp3"];
    }
    else
    {
        filePath = [[bundle resourcePath] stringByAppendingPathComponent:@"SpeakerDetection_English.mp3"];
    }
    
    return filePath;
}

- (void)playAudio:(BOOL)isPlay
{
    if (isPlay && self.filePath)
    {
        [self stopVollumListening];
        
        if (self.player && !self.player.isPlaying)
        {
            [self.player play];
            [self.player setVolume:1.0];
        }
        else
        {
            self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:self.filePath] error:nil];
            self.player.delegate = self;
            [self.player setVolume:1.0];
            
            [self.player play];
        }
    }
    else
    {
        [self.player pause];

        [self startVollumListening];
    }
}

#pragma mark - AVAudioPlayer Delegate

// 播放完成
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self startVollumListening];

    [self.permissionsView stopPlay];
}


#pragma mark - CHPermissionsViewDelegate

- (void)onPermissionsViewChanged:(CHPermissionsViewChangeType)changeType value:(BOOL)value
{
    switch (changeType)
    {
        case CHPermissionsViewChange_Play:
        {
            [self playAudio:value];
        }
            break;
            
        case CHPermissionsViewChange_BeautySet:
        {
            [UIView animateWithDuration:0.5 animations:^{
                self.bottomView.bm_height = self.beautySetView.bm_height + 70.0f;
                self.bottomView.bm_top = BMUI_SCREEN_HEIGHT - self.bottomView.bm_height;
                
                self.beautySetView.hidden = NO;
                self.permissionsView.hidden = YES;
                
                [self.enterBtn setTitle:YSLocalized(@"BeautySet.Back") forState:UIControlStateNormal];
                self.enterBtn.bm_top = self.bottomView.bm_height - 55.0f;
            }];

        }
            break;
            
        default:
            break;
    }
}


#pragma mark - CHBeautySetViewDelegate

- (void)beautySetFinished:(BOOL)isFinished
{
    
}

@end