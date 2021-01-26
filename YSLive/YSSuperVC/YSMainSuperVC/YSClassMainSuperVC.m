//
//  YSClassMainSuperVC.m
//  YSLive
//
//  Created by jiang deng on 2020/3/6.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSClassMainSuperVC.h"
#if YSSDK
#import "YSSDKManager.h"
#else
#import "AppDelegate.h"
#endif

#import "UIAlertController+SCAlertAutorotate.h"

#import "SCEyeCareView.h"
#import "SCEyeCareWindow.h"

#import <BMKit/NSString+BMURLEncode.h>


@interface YSClassMainSuperVC ()
<
    SCEyeCareViewDelegate
>

/// 整个窗口的背景图
@property (nonatomic, strong) UIImageView * backgroundImage;

/// 原keywindow
@property(nonatomic, weak) UIWindow *previousKeyWindow;
/// 护眼提醒
@property (nonatomic, strong) SCEyeCareView *eyeCareView;
/// 护眼提醒window
@property (nonatomic, strong) SCEyeCareWindow *eyeCareWindow;
/// 房间号
@property (nonatomic, strong) UILabel *roomIDL;
/// 信号
@property (nonatomic, strong) UILabel *signalStateL;
/// 时间
@property (nonatomic, strong) UILabel *timeL;

/// 所有内容的背景contentBackgroud的尺寸
@property(nonatomic, assign) CGFloat contentWidth;
@property(nonatomic, assign) CGFloat contentHeight;

/// 底部工具栏
@property (nonatomic, strong) YSSpreadBottomToolBar *spreadBottomToolBar;

@end

@implementation YSClassMainSuperVC

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#if YSSDK
    if ([YSSDKManager sharedInstance].classCanRotation)
#else
    if (GetAppDelegate.classCanRotation)
#endif
    {
        // 结束设备旋转的通知
        [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    }
}

- (instancetype)initWithWhiteBordView:(UIView *)whiteBordView
{
    self = [super initWithWhiteBordView:whiteBordView];
    if (self)
    {
        //创建一个16：9的背景view
        [self setupBottomBackgroundView];
    }
    return self;
}


#pragma mark -
#pragma mark ViewControllerLife

- (void)viewDidLoad
{
    [super viewDidLoad];

#if YSSDK
    if ([YSSDKManager sharedInstance].classCanRotation)
#else
    if (GetAppDelegate.classCanRotation)
#endif
    {
        // 开启和监听 设备旋转的通知（不开启的话，设备方向一直是UIInterfaceOrientationUnknown）
        if (![UIDevice currentDevice].generatesDeviceOrientationNotifications)
        {
            // 设备旋转通知
            [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        }

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleDeviceOrientationDidChange:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil
         ];
    }

    // 进入全屏
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(begainFullScreen) name:UIWindowDidBecomeVisibleNotification object:nil];
    // 退出全屏
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endFullScreen) name:UIWindowDidBecomeHiddenNotification object:nil];
        
    self.view.backgroundColor = UIColor.blackColor;
    
    UIImageView * backgroundImage = [[UIImageView alloc]initWithFrame:self.view.bounds];
    backgroundImage.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:backgroundImage];
    self.backgroundImage = backgroundImage;
    
    if (self.liveManager.roomModel.skinModel.mobileroomFillType && [self.liveManager.roomModel.skinModel.mobileroomFillValue bm_isNotEmpty])
    {
        NSString *urlString = self.liveManager.roomModel.skinModel.mobileroomFillValue;
        urlString = [urlString bm_URLEncode];
        NSURL * url = [NSURL URLWithString:urlString];
        
        [backgroundImage bmsd_setImageWithURL:url completed:^(UIImage * _Nullable image, NSError * _Nullable error, BMSDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (!image)
            {
                self.backgroundImage.hidden = YES;
            }
        }];
    }
    else
    {
        backgroundImage.hidden = YES;
        
        if ([self.liveManager.roomModel.skinModel.mobileroomFillValue bm_isNotEmpty])
        {
            self.view.backgroundColor = [UIColor bm_colorWithHexString:self.liveManager.roomModel.skinModel.mobileroomFillValue];
        }
    }
    
    
    //创建一个16：9的背景view
    [self.view addSubview:self.contentBackgroud];
    
    //顶部状态栏
    [self setupstateToolBar];
    
    // 底部工具栏
    [self setupBottomToolBarView];
    
    //骰子
    [self creatDiceAnimationView];
}

- (void)handleDeviceOrientationDidChange:(NSNotification *)noti
{
    UIDevice *device = [UIDevice currentDevice] ;
    
    switch (device.orientation)
    {
        case UIDeviceOrientationLandscapeLeft:
            NSLog(@"home键在右");
            [self.liveManager.cloudHubRtcEngineKit setVideoRotation:CloudHubHomeButtonOnRight];
            break;

        case UIDeviceOrientationLandscapeRight:
            NSLog(@"home键在左");
            [self.liveManager.cloudHubRtcEngineKit setVideoRotation:CloudHubHomeButtonOnLeft];
            break;
        
        case UIDeviceOrientationFaceUp:
            NSLog(@"屏幕朝上平躺");
        case UIDeviceOrientationFaceDown:
            NSLog(@"屏幕朝下平躺");
        case UIDeviceOrientationPortrait:
        {
            NSLog(@"home键在下");
            UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
            NSLog(@"状态条方向: %@", @(interfaceOrientation));
            if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
            {
                [self.liveManager.cloudHubRtcEngineKit setVideoRotation:CloudHubHomeButtonOnLeft];
            }
            else
            {
                [self.liveManager.cloudHubRtcEngineKit setVideoRotation:CloudHubHomeButtonOnRight];
            }
        }
            break;

        case UIDeviceOrientationUnknown:
            NSLog(@"未知方向");
        case UIDeviceOrientationPortraitUpsideDown:
            NSLog(@"home键在上");
        default:
            [self.liveManager.cloudHubRtcEngineKit setVideoRotation:CloudHubHomeButtonOnRight];
            break;
    }
}
///创建一个16：9的背景view
- (void)setupBottomBackgroundView
{
    NSInteger WIDTH = BMUI_SCREEN_WIDTH_ROTATE;
    NSInteger top = 0;
    if (BMIS_IPHONEXANDP)
    {
        top = BMUI_NAVIGATION_BAR_FRIMGEHEIGHT;
        WIDTH = BMUI_SCREEN_WIDTH_ROTATE - top;
    }
    
    if (WIDTH/BMUI_SCREEN_HEIGHT_ROTATE >= (16.0/9.0))
    {
        self.contentHeight = BMUI_SCREEN_HEIGHT_ROTATE;
        self.contentWidth = ceil(self.contentHeight * 16.0 / 9.0);
    }  
    else
    {
        self.contentWidth = WIDTH;
        self.contentHeight = ceil(self.contentWidth * 9.0 / 16.0);
    }
    
    CGFloat bgX = top + (WIDTH - self.contentWidth)/2;
    CGFloat bgY = (BMUI_SCREEN_HEIGHT_ROTATE - self.contentHeight)/2;
    
    UIView * contentBackgroud = [[UIView alloc]initWithFrame:CGRectMake(bgX, bgY, self.contentWidth, self.contentHeight)];
    contentBackgroud.backgroundColor = YSSkinDefineColor(@"Color1");
    self.contentBackgroud = contentBackgroud;
    
    UIImageView * contentBgImage = [[UIImageView alloc]initWithFrame:contentBackgroud.bounds];
    [contentBackgroud addSubview:contentBgImage];
    self.contentBgImage = contentBgImage;
    
    if (self.liveManager.roomModel.skinModel.backgroundType)
    {
        
        NSString *urlString = self.liveManager.roomModel.skinModel.backgroundValue;
        urlString = [urlString bm_URLEncode];
        NSURL * url = [NSURL URLWithString:urlString];
        
        [self.contentBgImage bmsd_setImageWithURL:url completed:^(UIImage * _Nullable image, NSError * _Nullable error, BMSDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        }];
    }
    else
    {
        self.contentBgImage.hidden = YES;
        if ([self.liveManager.roomModel.skinModel.backgroundValue bm_isNotEmpty])
        {
            self.contentBackgroud.backgroundColor = [UIColor bm_colorWithHexString:self.liveManager.roomModel.skinModel.backgroundValue];
        }
        else
        {
            self.contentBackgroud.backgroundColor = YSSkinDefineColor(@"Color2");
        }
    }
}

///顶部状态栏
- (void)setupstateToolBar
{
    UIView * stateToolView = [[UIView alloc]initWithFrame:CGRectMake(0 , 0, self.contentBackgroud.bm_width, STATETOOLBAR_HEIGHT)];
    stateToolView.backgroundColor = YSSkinDefineColor(@"Color2");
    [self.contentBackgroud addSubview:stateToolView];
    CGFloat fontSize = 12;
    if (![UIDevice bm_isiPad])
    {
        fontSize = 8;
    }
    /// 房间号
    UILabel *roomIDL = [[UILabel alloc] init];
    roomIDL.textColor = YSSkinDefineColor(@"Color3");
    roomIDL.textAlignment = NSTextAlignmentLeft;
    roomIDL.font = [UIFont systemFontOfSize:fontSize];
    self.roomIDL = roomIDL;
    [stateToolView addSubview:roomIDL];
    roomIDL.adjustsFontSizeToFitWidth = YES;
    self.roomIDL.frame = CGRectMake(10, 0, 150, STATETOOLBAR_HEIGHT);

    /// time
    UILabel *timeL = [[UILabel alloc] init];
    timeL.textColor = YSSkinDefineColor(@"Color3");
    timeL.textAlignment = NSTextAlignmentCenter;
    timeL.font = [UIFont fontWithName:@"Helvetica" size:fontSize];
    self.timeL = timeL;
    [stateToolView addSubview:timeL];
    timeL.adjustsFontSizeToFitWidth = YES;
    self.timeL.frame = CGRectMake(0, 0, 90, STATETOOLBAR_HEIGHT);
    self.timeL.bm_centerX = stateToolView.bm_centerX;
}

// 底部工具栏
- (void)setupBottomToolBarView
{
    YSSpreadBottomToolBar *spreadBottomToolBar = [[YSSpreadBottomToolBar alloc] initWithUserRole:self.liveManager.localUser.role topLeftpoint:CGPointMake(BMUI_SCREEN_WIDTH - (YSSpreadBottomToolBar_BtnWidth+YSSpreadBottomToolBar_SpreadBtnGap)*1.0f - 5, BMUI_SCREEN_HEIGHT - (YSSpreadBottomToolBar_BtnWidth+YSSpreadBottomToolBar_SpreadBtnGap)*1.5f) roomType:self.roomtype isChairManControl:self.liveManager.roomConfig.isChairManControl];
    spreadBottomToolBar.delegate = self;
    spreadBottomToolBar.isBeginClass = self.liveManager.isClassBegin;
    spreadBottomToolBar.isPollingEnable = NO;
    spreadBottomToolBar.isToolBoxEnable = NO;
    
    self.spreadBottomToolBar = spreadBottomToolBar;
    [self.view addSubview:spreadBottomToolBar];
}

// 横排视频最大宽度计算
- (CGFloat)getVideoTotalWidth
{
    return 0.0f;
}

- (void)setRoomID:(NSString *)roomID
{
    self.roomIDL.text = [NSString stringWithFormat:@"  %@：%@",YSLocalized(@"Label.roomid"),roomID];
}

- (void)setLessonTime:(NSString *)lessonTime
{
    if ([lessonTime bm_isNotEmpty])
    {
        self.timeL.text = lessonTime;
    }
    else
    {
        self.timeL.text = @"00:00:00";
    }
}

- (void)creatDiceAnimationView
{
    CGFloat width = 150;
    if ([UIDevice bm_isiPad])
    {
        width = 250;
    }
    
    YSDiceAnimationView *diceView = [[YSDiceAnimationView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
    [self.view addSubview:diceView];
    diceView.center = self.view.center;
    self.diceView = diceView;
    self.diceView.hidden = YES;
}

/// 进入全屏
- (void)begainFullScreen
{
    NSLog(@"=================================begainFullScreen");
}

/// 退出全屏
- (void)endFullScreen
{
    NSLog(@"=================================begainFullScreen");

    // 强制
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)])
    {
        SEL selector = NSSelectorFromString(@"setOrientation:");

        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];

        [invocation setTarget:[UIDevice currentDevice]];

        int val = UIInterfaceOrientationLandscapeRight; //UIInterfaceOrientationPortrait;
        [invocation setArgument:&val atIndex:2];

        [invocation invoke];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark 键盘通知方法

- (void)keyboardWillShow:(NSNotification*)notification
{
}

- (void)keyboardWillHide:(NSNotification *)notification
{
}

#pragma mark 横竖屏

/// 1.决定当前界面是否开启自动转屏，如果返回NO，后面两个方法也不会被调用，只是会支持默认的方向
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

/// 2.返回支持的旋转方向
/// iPhone设备上，默认返回值UIInterfaceOrientationMaskAllButUpSideDwon
/// iPad设备上，默认返回值是UIInterfaceOrientationMaskAll
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
#if YSSDK
    if ([YSSDKManager sharedInstance].classCanRotation)
#else
    if (GetAppDelegate.classCanRotation)
#endif
    {
        return UIInterfaceOrientationMaskLandscape;
    }
    else
    {
        return UIInterfaceOrientationMaskLandscapeRight;
    }
}

/// 3.返回进入界面默认显示方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
}

- (void)backAction:(id)sender
{
    BMWeakSelf
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:YSLocalized(@"Prompt.Quite") message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confimAc = [UIAlertAction actionWithTitle:YSLocalized(@"Prompt.OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [BMProgressHUD bm_showHUDAddedTo:weakSelf.view animated:YES];
        [weakSelf.liveManager leaveRoom:nil];
        
    }];
    UIAlertAction *cancleAc = [UIAlertAction actionWithTitle:YSLocalized(@"Prompt.Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertVc addAction:cancleAc];
    [alertVc addAction:confimAc];
    
#if YSSDK
    alertVc.sc_Autorotate = ![YSSDKManager sharedInstance].useAppDelegateAllowRotation;
#else
    alertVc.sc_Autorotate = !GetAppDelegate.useAllowRotation;
#endif
    alertVc.sc_OrientationMask = UIInterfaceOrientationMaskLandscape;
    alertVc.sc_Orientation = UIInterfaceOrientationLandscapeRight;
    
    [self presentViewController:alertVc animated:YES completion:nil];
}

- (void)showEyeCareRemind
{
    if (self.eyeCareWindow)
    {
        return;
    }
    
    NSLog(@"小班课护眼模式提醒");
    
    self.previousKeyWindow = [UIApplication sharedApplication].keyWindow;
    
    CGRect frame = CGRectMake(0, 0, BMUI_SCREEN_WIDTH, BMUI_SCREEN_HEIGHT);
    SCEyeCareWindow *eyeCareWindow = [[SCEyeCareWindow alloc] initWithFrame:frame];
    self.eyeCareWindow = eyeCareWindow;
    [self.eyeCareWindow makeKeyWindow];
    self.eyeCareWindow.hidden = NO;
    
    SCEyeCareView *eyeCareView = [[SCEyeCareView alloc] initWithFrame:frame needRotation:YES];
    eyeCareView.delegate = self;
    [eyeCareWindow addSubview:eyeCareView];
    [eyeCareView bm_centerInSuperView];

    self.eyeCareWindow.transform = CGAffineTransformMakeRotation(M_PI*0.5);
    eyeCareWindow.frame = CGRectMake(0, 0, BMUI_SCREEN_HEIGHT, BMUI_SCREEN_WIDTH);
}

#pragma mark SCEyeCareViewDelegate

- (void)eyeCareViewClose
{
    [self.eyeCareWindow bm_removeAllSubviews];
    self.eyeCareWindow.hidden = YES;
    self.eyeCareWindow = nil;
    
    [self.previousKeyWindow makeKeyWindow];
}

@end
