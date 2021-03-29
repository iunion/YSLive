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

#import "CHPermissionsView.h"

@interface CHBeautySetVC ()
<
    AVAudioPlayerDelegate
>

/// 音频播放器
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) AVAudioSession *session;


@property (nonatomic, strong) UIView *topView;

/// 无视频权限背景图
@property (nonatomic, strong) UIImageView *backImageView;
/// 视频权限提醒
@property (nonatomic, strong) UILabel *permissionLabel;

/// 本人视频窗口
@property (nonatomic, strong) UIView *largeVideoView;

/// 设备权限控制
@property (nonatomic, strong) CHPermissionsView *permissionsView;

/// 进入
@property (nonatomic, strong) UIButton *enterBtn;

@end

@implementation CHBeautySetVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupView];
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
    permissionLabel.text = YSLocalized(@"BeautySet.note");
    [self.topView addSubview:permissionLabel];
    [permissionLabel bm_centerHorizontallyInSuperViewWithTop:backImageView.bm_bottom + 20.0f];
    self.permissionLabel = permissionLabel;

    UIView *largeVideoView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:largeVideoView];
    largeVideoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.largeVideoView = largeVideoView;

    YSLiveManager *liveManager = [YSLiveManager sharedInstance];
    [liveManager playVideoWithUserId:liveManager.localUser.peerID streamID:nil renderMode:CloudHubVideoRenderModeHidden mirrorMode:CloudHubVideoMirrorModeDisabled inView:largeVideoView];
    
    //CHPermissionsView *permissionsView = [CHPermissionsView alloc] initWithFrame:<#(CGRect)#>
    
}


@end
