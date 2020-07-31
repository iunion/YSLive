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

    // 进入全屏
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(begainFullScreen) name:UIWindowDidBecomeVisibleNotification object:nil];
    // 退出全屏
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endFullScreen) name:UIWindowDidBecomeHiddenNotification object:nil];
    
//    self.view.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = YSSkinDefineColor(@"blackColor");
    
    //创建一个16：9的背景view
    [self.view addSubview:self.contentBackgroud];
    
    //顶部状态栏
    [self setupstateToolBar];
    
    // 底部工具栏
    [self setupBottomToolBarView];

    
    
}

///创建一个16：9的背景view
- (void)setupBottomBackgroundView
{
//    BMIS_IPHONEXANDP
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
    contentBackgroud.backgroundColor = YSSkinDefineColor(@"defaultBgColor");
    self.contentBackgroud = contentBackgroud;
}


///顶部状态栏
- (void)setupstateToolBar
{
    UIView * stateToolView = [[UIView alloc]initWithFrame:CGRectMake(0 , 0, self.contentBackgroud.bm_width, STATETOOLBAR_HEIGHT)];
    stateToolView.backgroundColor = YSSkinDefineColor(@"WhiteBoardBgColor");
    [self.contentBackgroud addSubview:stateToolView];
    CGFloat fontSize = 12;
    if (![UIDevice bm_isiPad])
    {
        fontSize = 8;
    }
    /// 房间号
    UILabel *roomIDL = [[UILabel alloc] init];
    roomIDL.textColor = YSSkinDefineColor(@"defaultTitleColor");
    roomIDL.textAlignment = NSTextAlignmentLeft;
    roomIDL.font = [UIFont systemFontOfSize:fontSize];
    self.roomIDL = roomIDL;
    [stateToolView addSubview:roomIDL];
    roomIDL.adjustsFontSizeToFitWidth = YES;
    self.roomIDL.frame = CGRectMake(10, 0, 150, STATETOOLBAR_HEIGHT);

    /// time
    UILabel *timeL = [[UILabel alloc] init];
    timeL.textColor = YSSkinDefineColor(@"defaultTitleColor");
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
    NSUInteger maxvideo = [self.liveManager.roomDic bm_uintForKey:@"maxvideo"];
    YSRoomUserType roomusertype = maxvideo > 2 ? YSRoomUserType_More : YSRoomUserType_One;
    
    YSSpreadBottomToolBar *spreadBottomToolBar = [[YSSpreadBottomToolBar alloc] initWithUserRole:self.liveManager.localUser.role topLeftpoint:CGPointMake(BMUI_SCREEN_WIDTH - (YSSpreadBottomToolBar_BtnWidth+YSSpreadBottomToolBar_SpreadBtnGap)*1.0f - 5, BMUI_SCREEN_HEIGHT - (YSSpreadBottomToolBar_BtnWidth+YSSpreadBottomToolBar_SpreadBtnGap)*1.5f) roomType:roomusertype];
    spreadBottomToolBar.delegate = self;
    spreadBottomToolBar.isBeginClass = self.liveManager.isClassBegin;
    spreadBottomToolBar.isPollingEnable = NO;
    spreadBottomToolBar.isToolBoxEnable = NO;
    
    self.spreadBottomToolBar = spreadBottomToolBar;
    [self.view addSubview:spreadBottomToolBar];
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
