//
//  YSClassMainSuperVC.m
//  YSLive
//
//  Created by jiang deng on 2020/3/6.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSClassMainSuperVC.h"

#import "SCEyeCareView.h"
#import "SCEyeCareWindow.h"




@interface YSClassMainSuperVC ()
<
    SCEyeCareViewDelegate
>

/// 原keywindow
@property(nonatomic, weak) UIWindow *previousKeyWindow;
/// 护眼提醒
@property (nonatomic, strong) SCEyeCareView *eyeCareView;
/// 护眼提醒window
@property (nonatomic, strong) SCEyeCareWindow *eyeCareWindow;
/// 所有内容的背景contentBackgroud的尺寸
@property(nonatomic, assign) CGFloat contentWidth;
@property(nonatomic, assign) CGFloat contentHeight;

@end

@implementation YSClassMainSuperVC

#pragma mark -
#pragma mark ViewControllerLife

- (void)viewDidLoad
{
    [super viewDidLoad];

    // 进入全屏
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(begainFullScreen) name:UIWindowDidBecomeVisibleNotification object:nil];
    // 退出全屏
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endFullScreen) name:UIWindowDidBecomeHiddenNotification object:nil];
    
//    self.view.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = YSSkinDefineColor(@"blackColor ");
    
    //创建一个16：9的背景view
    [self setupBottomBackgroundView];
    
    //顶部状态栏
    [self setupstateToolBar];
    
}

///创建一个16：9的背景view
- (void)setupBottomBackgroundView
{
//    BMIS_IPHONEXANDP
    NSInteger WIDTH = BMUI_SCREEN_WIDTH;
    
    NSInteger top = 0;
    
    if (BMIS_IPHONEXANDP)
    {
        top = BMUI_NAVIGATION_BAR_FRIMGEHEIGHT;
        WIDTH = BMUI_SCREEN_WIDTH - top;
    }
    
    if (WIDTH/BMUI_SCREEN_HEIGHT >= (16.0/9.0))
    {
        self.contentHeight = BMUI_SCREEN_HEIGHT;
        self.contentWidth = ceil(self.contentHeight * 16.0 / 9.0);
    }  
    else
    {
        self.contentWidth = WIDTH;
        self.contentHeight = ceil(self.contentWidth * 9.0 / 16.0);
    }
    
    CGFloat bgX = top + (WIDTH - self.contentWidth)/2;
    CGFloat bgY = (BMUI_SCREEN_HEIGHT - self.contentHeight)/2;
    
    UIView * contentBackgroud = [[UIView alloc]initWithFrame:CGRectMake(bgX, bgY, self.contentWidth, self.contentHeight)];
    contentBackgroud.backgroundColor = YSSkinDefineColor(@"defaultBgColor");
    [self.view addSubview:contentBackgroud];
    self.contentBackgroud = contentBackgroud;
}


///顶部状态栏
- (void)setupstateToolBar
{
    UIView * stateToolView = [[UIView alloc]initWithFrame:CGRectMake(0 , 0, self.contentBackgroud.bm_width, STATETOOLBAR_HEIGHT)];
    stateToolView.backgroundColor = YSSkinDefineColor(@"defaultBgColor");
    [self.contentBackgroud addSubview:stateToolView];
    self.stateToolView = stateToolView;
    
    
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

- (void)beforeDoMsgCachePool
{
    [super beforeDoMsgCachePool];
}

- (void)afterDoMsgCachePool
{
    [super afterDoMsgCachePool];
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
    return NO;
}

/// 2.返回支持的旋转方向
/// iPad设备上，默认返回值UIInterfaceOrientationMaskAllButUpSideDwon
/// iPad设备上，默认返回值是UIInterfaceOrientationMaskAll
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
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
        
        [weakSelf.liveManager leaveRoom:nil];
        
    }];
    UIAlertAction *cancleAc = [UIAlertAction actionWithTitle:YSLocalized(@"Prompt.Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertVc addAction:cancleAc];
    [alertVc addAction:confimAc];
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
