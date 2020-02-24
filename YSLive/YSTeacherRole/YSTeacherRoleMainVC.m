//
//  YSTeacherRoleMainVC.m
//  YSLive
//
//  Created by 马迪 on 2019/12/23.
//  Copyright © 2019 YS. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import "TZImagePickerController.h"
#import "TZPhotoPickerController.h"
#import "YSTeacherRoleMainVC.h"
#import "SCChatView.h"
#import "YSChatMessageModel.h"
#import "SCBrushToolView.h"
#import "SCDrawBoardView.h"
#import "SCChatToolView.h"
#import "SCDrawBoardView.h"
#import "YSEmotionView.h"

#import "SCTeacherTopBar.h"
#import "SCTTopPopverViewController.h"
#import "SCTeacherListView.h"
#import "SCBoardControlView.h"
#import "SCTeacherAnswerView.h"

#import "YSLiveMediaModel.h"

#import "YSFloatView.h"
#import "SCVideoView.h"
#import "SCVideoGridView.h"

#import "YSMediaMarkView.h"

#import "UIAlertController+SCAlertAutorotate.h"
#import "YSLiveApiRequest.h"

#import "SCColorSelectView.h"

#import "YSControlPopoverView.h"

#import "YSMp4ControlView.h"
#import "YSMp3Controlview.h"

#import "PanGestureControl.h"

#import "SCEyeCareView.h"
#import "SCEyeCareWindow.h"

#import "YSUpHandPopoverVC.h"
#import "YSCircleProgress.h"
#import "YSTeacherResponder.h"
#import "YSTeacherTimerView.h"

typedef NS_ENUM(NSUInteger, SCMain_ArrangeContentBackgroudViewType)
{
    SCMain_ArrangeContentBackgroudViewType_ShareVideoFloatView,
    SCMain_ArrangeContentBackgroudViewType_VideoGridView,
    SCMain_ArrangeContentBackgroudViewType_DragOutFloatViews
};

//上传图片的用途
typedef NS_ENUM(NSInteger, SCUploadImageUseType)
{
    /// 作为课件
    SCUploadImageUseType_Document = 0,
    /// 聊天用图
    SCUploadImageUseType_Message  = 1,
};

#define GiftImageView_Width         185.0f
#define GiftImageView_Height        224.0f

/// 一对一多视频最高尺寸
static const CGFloat kVideoView_MaxHeight_iPhone = 50.0f;
static const CGFloat kVideoView_MaxHeight_iPad  = 160.0f;
#define VIDEOVIEW_MAXHEIGHT         ([UIDevice bm_isiPad] ? kVideoView_MaxHeight_iPad : kVideoView_MaxHeight_iPhone)

/// 视频间距
static const CGFloat kVideoView_Gap_iPhone = 4.0f;
static const CGFloat kVideoView_Gap_iPad  = 6.0f;
#define VIDEOVIEW_GAP               ([UIDevice bm_isiPad] ? kVideoView_Gap_iPad : kVideoView_Gap_iPhone)

/// 顶部工具条高
static const CGFloat kTopToolBar_Height_iPhone = 50.0f;
static const CGFloat kTopToolBar_Height_iPad = 70.0f;
static NSInteger playerFirst = 0; /// 播放器播放次数限制
#define TOPTOOLBAR_HEIGHT           ([UIDevice bm_isiPad] ? kTopToolBar_Height_iPad : kTopToolBar_Height_iPhone)

//聊天视图的高度
#define SCChatViewHeight (UI_SCREEN_HEIGHT-57)
//聊天输入框工具栏高度
#define SCChatToolHeight  60
//聊天表情列表View高度
#define SCChateEmotionHeight  109
//右侧聊天视图宽度
#define ChatViewWidth 284

#define PlaceholderPTag     10

#define DoubleBtnTag      100

/// 花名册 课件库
#define ListView_Width        426.0f
#define ListView_Height        598.0f


#define YSTeacherResponderCountDownKey     @"YSTeacherResponderCountDownKey"
#define YSTeacherTimerCountDownKey         @"YSTeacherTimerCountDownKey"
@interface YSTeacherRoleMainVC ()
<
    SCEyeCareViewDelegate,
    TZImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    UIImagePickerControllerDelegate,
    UIPopoverPresentationControllerDelegate,
    UITextViewDelegate,
    YSLiveRoomManagerDelegate,
    SCBrushToolViewDelegate,
    SCDrawBoardViewDelegate,
    SCBoardControlViewDelegate,
    SCVideoViewDelegate,
    YSControlPopoverViewDelegate,
    SCTeacherTopBarDelegate,
    SCTTopPopverViewControllerDelegate,
    SCTeacherListViewDelegate,
    YSMp4ControlViewDelegate,
    YSMp3ControlviewDelegate,
    UIGestureRecognizerDelegate,
    YSTeacherResponderDelegate,
    YSTeacherTimerViewDelegate
>
{
    /// 最大上台数
    NSUInteger maxVideoCount;
    
    /// 一对多视频起始位置
    CGFloat videoStartX;
    
    /// 视频宽
    CGFloat videoWidth;
    /// 视频高
    CGFloat videoHeight;
    /// 老师视频宽
    CGFloat videoTeacherWidth;
    /// 老师视频高
    CGFloat videoTeacherHeight;
    
    /// 白板宽
    CGFloat whitebordWidth;
    /// 白板高
    CGFloat whitebordHeight;
    
    /// 悬浮默认视频宽(拖出和共享)
    CGFloat floatVideoDefaultWidth;
    /// 悬浮默认视频高(拖出和共享)
    CGFloat floatVideoDefaultHeight;

    /// 答题时间
    NSInteger _answerStartTime;
    /// 答题人数
    NSInteger _totalUsers;
    /// 是否公开答案
    BOOL _isOpenResult;
    /// 判断视频进度是否在拖动
    BOOL isDrag;
    BOOL isMediaPause;
    UIAlertController *classEndAlertVC;
    
    YSLiveRoomLayout defaultRoomLayout;
    
    BOOL needFreshVideoView;
    
    NSInteger contestCommitNumber;
    
    NSString *contestPeerId;
    
    BOOL autoUpPlatform;
    NSInteger timer_defaultTime;
}

/// 原keywindow
@property(nonatomic, weak) UIWindow *previousKeyWindow;
/// 护眼提醒
@property (nonatomic, strong) SCEyeCareView *eyeCareView;
/// 护眼提醒window
@property (nonatomic, strong) SCEyeCareWindow *eyeCareWindow;

/// 房间类型 0:表示一对一教室  非0:表示一多教室
@property (nonatomic, assign) YSRoomTypes roomtype;
/// 视频ratio 16:9
@property (nonatomic, assign) BOOL isWideScreen;
/// 固定UserId
@property (nonatomic, strong) NSString *userId;

///标识布局变化的值
@property (nonatomic, assign) YSLiveRoomLayout roomLayout;

/// 顶部工具条背景
@property (nonatomic, strong) UIView *topToolBarBackgroud;
/// 顶部工具栏
@property (nonatomic, strong) SCTeacherTopBar *topToolBar;
@property (nonatomic, strong) SCTopToolBarModel *topBarModel;
/// 记录顶部工具栏上次选中的按钮
@property (nonatomic, strong) UIButton *topSelectBtn;
/// 顶部按钮popoverView
@property(nonatomic, strong) SCTTopPopverViewController *topbarPopoverView;
/// 花名册 课件库
@property(nonatomic, strong) SCTeacherListView *teacherListView;

/// 开始答题
@property (nonatomic, strong) SCTeacherAnswerView *answerView;
/// 正确答案
@property (nonatomic, strong) NSString *rightAnswer;
/// 答题统计 以及结果
@property (nonatomic, strong) SCTeacherAnswerView *answerResultView;
/// 答题器的定时器
@property (nonatomic, strong) dispatch_source_t answerTimer;
/// 获取答题详情定时器
@property (nonatomic, strong) dispatch_source_t answerDetailTimer;
/// 答题器统计
@property (nonatomic, strong) NSMutableDictionary *answerStatistics;


/// 上课时间的定时器
@property (nonatomic, strong) dispatch_source_t topBarTimer;

/// 翻页工具
@property (nonatomic, strong) SCBoardControlView *boardControlView;

/// 内容背景
@property (nonatomic, strong) UIView *contentBackgroud;
/// 内容
@property (nonatomic, strong) UIView *contentView;
/// 视频背景
@property (nonatomic, strong) UIView *videoBackgroud;
/// 白板背景
@property (nonatomic, strong) UIView *whitebordBackgroud;
/// 全屏白板背景
@property (nonatomic, strong) UIView *whitebordFullBackgroud;
/// 隐藏白板视频布局背景
@property (nonatomic, strong) SCVideoGridView *videoGridView;
/// 视频View列表
@property (nonatomic, strong) NSMutableArray <SCVideoView *> *videoViewArray;
/// 默认老师 视频
@property (nonatomic, strong) SCVideoView *teacherVideoView;
/// 1V1 默认用户占位
@property (nonatomic, strong) SCVideoView *userVideoView;

/// 拖出视频浮动View列表
@property (nonatomic, strong) NSMutableArray <YSFloatView *> *dragOutFloatViewArray;
/// 长按手势的坐标
@property (nonatomic, assign) CGPoint startPoint;
///拖出视频view时的模拟移动图
@property (nonatomic, strong) UIImageView *dragImageView;
///刚开始拖动时，videoView的初始坐标（x,y）
@property (nonatomic, assign) CGPoint videoOriginInSuperview;

///要拖动的视频view
@property (nonatomic, strong) SCVideoView *dragingVideoView;

/// 共享浮动窗口 视频课件
@property (nonatomic, strong) YSFloatView *shareVideoFloatView;
/// 共享视频窗口
@property (nonatomic, strong) UIView *shareVideoView;

/// 视频控制popoverView
@property(nonatomic, strong) YSControlPopoverView *controlPopoverView;
/// 学生的视频控制popoverView
@property(nonatomic, strong) SCVideoView *selectControlView;

/// 聊天的View
@property(nonatomic,strong)SCChatView *rightChatView;
/// 弹出聊天View的按钮
@property(nonatomic,strong)UIButton *chatBtn;
/// 聊天输入框工具栏
@property (nonatomic, strong) SCChatToolView *chatToolView;
/// 聊天表情列表View
@property (nonatomic, strong) YSEmotionView *emotionListView;
/// 键盘弹起高度
@property (nonatomic, assign) CGFloat keyBoardH;

/// 左侧工具栏
@property (nonatomic, strong) SCBrushToolView *brushToolView;
/// 画笔选择 颜色 大小 形状
@property (nonatomic, strong) SCDrawBoardView *drawBoardView;

/// MP4进度控制
@property (nonatomic, strong) YSMp4ControlView *mp4ControlView;
///关闭视频播放
@property (nonatomic, strong) UIButton *closeMp4Btn;
/// MP3进度控制
@property (nonatomic, strong) YSMp3Controlview *mp3ControlView;

/// 举手按钮
@property(nonatomic,strong)UIButton *raiseHandsBtn;
//举手上台的popOverView列表
@property (nonatomic,weak)YSUpHandPopoverVC * upHandPopTableView;
/// 正在举手上台的人员数组
@property (nonatomic, strong) NSMutableArray <YSRoomUser *> *raiseHandArray;
/// 举过手的人员数组
@property (nonatomic, strong) NSMutableArray <YSRoomUser *> *haveRaiseHandArray;
/// 举手上台的人数
@property (nonatomic, strong) UILabel *handNumLab;

@property (nonatomic, strong)YSTeacherResponder *responderView;
/// 老师计时器
@property (nonatomic, strong)YSTeacherTimerView *teacherTimerView;
///音频播放器
@property(nonatomic, strong) AVAudioPlayer *player;
@property(nonatomic, strong) AVAudioSession *session;
@end

@implementation YSTeacherRoleMainVC

- (instancetype)initWithRoomType:(YSRoomTypes)roomType isWideScreen:(BOOL)isWideScreen maxVideoCount:(NSUInteger)maxCount whiteBordView:(UIView *)whiteBordView userId:(nullable NSString *)userId
{
    self = [super initWithWhiteBordView:whiteBordView];
    if (self)
    {
        maxVideoCount = maxCount;
        
        self.roomtype = roomType;
        self.isWideScreen = isWideScreen;
        
        self.userId = userId;
        
        //        self.mediaMarkSharpsDatas = [[NSMutableArray alloc] init];
        
        if (self.roomtype == YSRoomType_More)
        {
            videoHeight = VIDEOVIEW_MAXHEIGHT;
            
            if (self.isWideScreen)
            {
                videoWidth = ceil(videoHeight*16 / 9);
            }
            else
            {
                videoWidth = ceil(videoHeight*4 / 3);
            }
            // 初始化老师视频尺寸 固定值
            videoTeacherWidth = videoWidth;
            videoTeacherHeight = videoHeight;
            
            [self calculateFloatVideoSize];
        }
    }
    return self;
}

- (void)dealloc
{
    if (self.topBarTimer)
    {
        dispatch_source_cancel(self.topBarTimer);
        self.topBarTimer = nil;
    }

    if (self.answerTimer)
    {
        dispatch_source_cancel(self.answerTimer);
        self.answerTimer = nil;
    }

    if (self.answerDetailTimer)
    {
        dispatch_source_cancel(self.answerDetailTimer);
        self.answerDetailTimer = nil;
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    classEndAlertVC = nil;
    
    self.videoViewArray = [[NSMutableArray alloc] init];
    
    /// 本地播放 （定时器结束的音效）
    self.session = [AVAudioSession sharedInstance];
    [self.session setCategory:AVAudioSessionCategoryPlayback error:nil];
//    NSString * jsdkjf = YSLocalized(@"Prompt.ClassEndTeacherLeave10" );
    
    // 顶部工具栏背景
    [self setupTopToolBar];
    
    // 内容背景
    [self setupContentView];
    // 全屏白板
    [self setupFullBoardView];
    // 隐藏白板视频布局背景
    [self setupVideoGridView];
    // 设置左侧工具栏
    [self setupBrushToolView];
    // 设置花名册 课件表
    [self setupListView];
    // 翻页控件
    [self setupBoardControlView];
    // 右侧聊天视图
    [self.view addSubview:self.rightChatView];
    
    //弹出聊天框的按钮
    [self.view addSubview:self.chatBtn];
    
    //举手上台的按钮
    [self setupHandView];
    
    [self.liveManager.roomManager changeUserProperty:YSCurrentUser.peerID tellWhom:YSCurrentUser.peerID key:sUserCandraw value:@(true) completion:nil];
    [self.liveManager.whiteBoardManager brushToolsDidSelect:YSBrushToolTypeMouse];
    
    // 会议默认视频布局
    if (self.appUseTheType == YSAppUseTheTypeMeeting)
    {
        defaultRoomLayout = YSLiveRoomLayout_VideoLayout;
        self.roomLayout = defaultRoomLayout;
        [self handleSignalingSetRoomLayout:self.roomLayout];
    }
    else
    {
        defaultRoomLayout = YSLiveRoomLayout_AroundLayout;
        self.roomLayout = defaultRoomLayout;
    }
}

- (void)afterDoMsgCachePool
{
    if (self.liveManager.isBeginClass)
    {
        if (YSCurrentUser.hasVideo)
        {
            [self.liveManager.roomManager publishVideo:nil];
        }
        if (YSCurrentUser.hasAudio)
        {
            [self.liveManager.roomManager publishAudio:nil];
        }
    }
    //会议默认上课
    if (self.appUseTheType == YSAppUseTheTypeMeeting && !self.liveManager.isBeginClass)
    {
        [[YSLiveManager shareInstance] sendSignalingTeacherToClassBeginWithCompletion:nil];
    }
}

- (void)showEyeCareRemind
{
    if (self.eyeCareWindow)
    {
        return;
    }
    
    NSLog(@"小班课老师护眼模式提醒");
    
    self.previousKeyWindow = [UIApplication sharedApplication].keyWindow;
    
    CGRect frame = CGRectMake(0, 0, UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT);
    SCEyeCareWindow *eyeCareWindow = [[SCEyeCareWindow alloc] initWithFrame:frame];
    self.eyeCareWindow = eyeCareWindow;
    [self.eyeCareWindow makeKeyWindow];
    self.eyeCareWindow.hidden = NO;
    
    SCEyeCareView *eyeCareView = [[SCEyeCareView alloc] initWithFrame:frame needRotation:YES];
    eyeCareView.delegate = self;
    [eyeCareWindow addSubview:eyeCareView];
    [eyeCareView bm_centerInSuperView];

    self.eyeCareWindow.transform = CGAffineTransformMakeRotation(M_PI*0.5);
    eyeCareWindow.frame = CGRectMake(0, 0, UI_SCREEN_HEIGHT, UI_SCREEN_WIDTH);
}

#pragma mark SCEyeCareViewDelegate

- (void)eyeCareViewClose
{
    [self.eyeCareWindow bm_removeAllSubviews];
    self.eyeCareWindow.hidden = YES;
    self.eyeCareWindow = nil;
    
    [self.previousKeyWindow makeKeyWindow];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 保证屏幕常亮
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // 保证屏幕常亮
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


#pragma mark 横竖屏

/// 1.决定当前界面是否开启自动转屏，如果返回NO，后面两个方法也不会被调用，只是会支持默认的方向
- (BOOL)shouldAutorotate
{
    return YES;
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


/// 顶部工具栏背景
- (void)setupTopToolBar
{
    UIView *topToolBarBackGroud = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, TOPTOOLBAR_HEIGHT)];
    topToolBarBackGroud.backgroundColor = [UIColor bm_colorWithHex:0x82ABEC];
    [self.view addSubview:topToolBarBackGroud];
    self.topToolBarBackgroud = topToolBarBackGroud;
    
    self.topToolBar = [[SCTeacherTopBar alloc] init];
    self.topToolBar.delegate = self;
    self.topToolBar.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH, TOPTOOLBAR_HEIGHT);
    [self.topToolBarBackgroud addSubview:self.topToolBar];
    self.topToolBar.layoutType = SCTeacherTopBarLayoutType_BeforeClass;
    [self setupTopBarData];
    
    self.topbarPopoverView = [[SCTTopPopverViewController alloc]init];
    self.topbarPopoverView.modalPresentationStyle = UIModalPresentationPopover;
    self.topbarPopoverView.delegate = self;
}

/// 初始化顶栏数据
- (void)setupTopBarData
{
    self.topBarModel = [[SCTopToolBarModel alloc] init];
    self.topBarModel.roomID = [YSLiveManager shareInstance].room_Id;
    
    self.topToolBar.topToolModel = self.topBarModel;
}

/// 设置底部 翻页控件
- (void)setupBoardControlView
{
    self.boardControlView = [[SCBoardControlView alloc] init];
    [self.view addSubview:self.boardControlView];
    self.boardControlView.frame = CGRectMake(0, 0, 246, 34);
    self.boardControlView.bm_bottom = self.view.bm_bottom - 20;
    self.boardControlView.bm_centerX = self.view.bm_centerX;
    self.boardControlView.delegate = self;
    self.boardControlView.layer.cornerRadius = self.boardControlView.bm_height/2;
    self.boardControlView.layer.masksToBounds = YES;
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragReplyButton:)];
    [self.boardControlView addGestureRecognizer:panGestureRecognizer];
    self.boardControlView.allowPaging = YES;//self.liveManager.roomConfig.canPageTurningFlag;
}

/// 按钮的拖拽效果
- (void)dragReplyButton:(UIPanGestureRecognizer *)recognizer
{
    UIView *dragView = recognizer.view;
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint location = [recognizer locationInView:self.view];
        
        if (location.y < 0 || location.y > UI_SCREEN_HEIGHT)
        {
            return;
        }
        CGPoint translation = [recognizer translationInView:self.view];
        
        dragView.center = CGPointMake(dragView.center.x + translation.x, dragView.center.y + translation.y);
        [recognizer setTranslation:CGPointZero inView:self.view];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled)
    {
        CGRect currentFrame = dragView.frame;//self.chatBtn.frame;
        
        if (currentFrame.origin.x < 0) {
            
            currentFrame.origin.x = 0;
            if (currentFrame.origin.y < 0)
            {
                currentFrame.origin.y = 4;
            }
            else if ((currentFrame.origin.y + currentFrame.size.height) > self.view.bounds.size.height)
            {
                currentFrame.origin.y = self.view.bounds.size.height - currentFrame.size.height;
            }
            [UIView animateWithDuration:DEFAULT_DELAY_TIME animations:^{
                dragView.frame = currentFrame;
            }];
            
            return;
        }
        
        if ((currentFrame.origin.x + currentFrame.size.width) > self.view.bounds.size.width)
        {
            currentFrame.origin.x = self.view.bounds.size.width - currentFrame.size.width;
            if (currentFrame.origin.y < 0)
            {
                currentFrame.origin.y = 4;
            }
            else if ((currentFrame.origin.y + currentFrame.size.height) > self.view.bounds.size.height)
            {
                currentFrame.origin.y = self.view.bounds.size.height - currentFrame.size.height;
            }
            [UIView animateWithDuration:DEFAULT_DELAY_TIME animations:^{
                dragView.frame = currentFrame;
            }];
            return;
        }
        
        if (currentFrame.origin.y < 0)
        {
            currentFrame.origin.y = 4;
            [UIView animateWithDuration:DEFAULT_DELAY_TIME animations:^{
                dragView.frame = currentFrame;
            }];
            
            return;
        }
        
        if ((currentFrame.origin.y + currentFrame.size.height) > self.view.bounds.size.height)
        {
            currentFrame.origin.y = self.view.bounds.size.height - currentFrame.size.height;
            [UIView animateWithDuration:DEFAULT_DELAY_TIME animations:^{
                dragView.frame = currentFrame;
            }];
            
            return;
        }
    }
}
/// 全屏白板初始化
- (void)setupFullBoardView
{
    // 白板背景
    UIView *whitebordFullBackgroud = [[UIView alloc] init];
    whitebordFullBackgroud.backgroundColor = [UIColor bm_colorWithHex:0x9DBEF3];
    [self.view addSubview:whitebordFullBackgroud];
    whitebordFullBackgroud.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT);
    self.whitebordFullBackgroud = whitebordFullBackgroud;
    self.whitebordFullBackgroud.hidden = YES;
}

#pragma mark - 举手上台的UI
- (void)setupHandView
{
//    UIButton * raiseHandsBtn = [[UIButton alloc]initWithFrame:CGRectMake(UI_SCREEN_WIDTH-40-26, self.chatBtn.bm_originY-60, 40, 40)];
    UIButton * raiseHandsBtn = [[UIButton alloc]initWithFrame:CGRectMake(UI_SCREEN_WIDTH-40-26, UI_SCREEN_HEIGHT - self.whitebordBackgroud.bm_height+20, 40, 40)];
    [raiseHandsBtn setBackgroundColor: UIColor.clearColor];
    [raiseHandsBtn setImage:[UIImage imageNamed:@"teacherNormalHand"] forState:UIControlStateNormal];
    [raiseHandsBtn setImage:[UIImage imageNamed:@"handSelected"] forState:UIControlStateSelected];
    [raiseHandsBtn addTarget:self action:@selector(raiseHandsButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.raiseHandsBtn = raiseHandsBtn;
     [self.view addSubview:raiseHandsBtn];
    
    UILabel * handNumLab = [[UILabel alloc]initWithFrame:CGRectMake(raiseHandsBtn.bm_originX, CGRectGetMaxY(raiseHandsBtn.frame), 40, 15)];

    handNumLab.font = UI_FONT_13;
    handNumLab.textColor = UIColor.whiteColor;
    handNumLab.backgroundColor = [UIColor bm_colorWithHex:0x5A8CDC];
    handNumLab.layer.cornerRadius = 15/2;
    handNumLab.layer.masksToBounds = YES;
    handNumLab.textAlignment = NSTextAlignmentCenter;
    self.handNumLab = handNumLab;
    [self.view addSubview:handNumLab];
    
    [self raiseHandReloadData];
}

- (void)raiseHandsButtonClick:(UIButton *)sender
{
    YSUpHandPopoverVC * popTab = [[YSUpHandPopoverVC alloc]init];
    popTab.userArr = self.raiseHandArray;
    popTab.preferredContentSize = CGSizeMake(95, 146);
    popTab.modalPresentationStyle = UIModalPresentationPopover;
    BMWeakSelf
    popTab.letStudentUpVideo = ^(YSUpHandPopCell *cell) {
        if (weakSelf.videoViewArray.count < self->maxVideoCount)
        {
            [[YSLiveManager shareInstance] sendSignalingToChangePropertyWithRoomUser:cell.userModel withKey:sUserPublishstate WithValue:@(YSUser_PublishState_BOTH)];
            cell.headBtn.selected = YES;
        }
        else
        {
            [BMProgressHUD bm_showHUDAddedTo:self.view animated:YES withText:YSLocalized(@"Error.UpPlatformMemberOverRoomLimit") delay:PROGRESSBOX_DEFAULT_HIDE_DELAY];
        }
    };
    self.upHandPopTableView = popTab;
    
    UIPopoverPresentationController *popover = popTab.popoverPresentationController;
    popover.sourceView = self.raiseHandsBtn;
    popover.sourceRect = self.raiseHandsBtn.bounds;
    popover.delegate = self;
    [self presentViewController:popTab animated:YES completion:nil];//present即可
}


/// 设置左侧工具栏
- (void)setupBrushToolView
{
    self.brushToolView = [[SCBrushToolView alloc] initWithTeacher:YES];
    [self.view addSubview:self.brushToolView];
    CGRect rect =  [self.view convertRect:self.whitebordBackgroud.frame fromView:self.whitebordBackgroud.superview];
    self.brushToolView.bm_left = UI_STATUS_BAR_HEIGHT + 5;
    self.brushToolView.bm_centerY = rect.origin.y + rect.size.height/2;
    self.brushToolView.delegate = self;
    self.brushToolView.hidden = YES;
}

#pragma mark 内容背景
- (void)setupContentView
{
    [[YSLiveManager shareInstance] setDeviceOrientation:UIDeviceOrientationLandscapeLeft];
    [[YSLiveManager shareInstance].roomManager setLocalVideoMirrorMode:YSVideoMirrorModeDisabled];

    // 整体背景
    UIView *contentBackgroud = [[UIView alloc] init];
    contentBackgroud.backgroundColor = [UIColor bm_colorWithHex:0x9DBEF3];
    [self.view addSubview:contentBackgroud];
    self.contentBackgroud = contentBackgroud;
    
    
    // 视频+白板背景
    UIView *contentView = [[UIView alloc] init];
    contentView.backgroundColor = [UIColor clearColor];
    [self.contentBackgroud addSubview:contentView];
    self.contentView = contentView;
    
    // 白板背景
    UIView *whitebordBackgroud = [[UIView alloc] init];
    whitebordBackgroud.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:whitebordBackgroud];
    self.whitebordBackgroud = whitebordBackgroud;
    
    // 视频背景
    UIView *videoBackgroud = [[UIView alloc] init];
    videoBackgroud.backgroundColor = [UIColor bm_colorWithHex:0x5A8CDC];
    [self.contentView addSubview:videoBackgroud];
    self.videoBackgroud = videoBackgroud;
    
    // 加载白板
    [self.whitebordBackgroud addSubview:self.whiteBordView];
    
    /// 设置尺寸
    self.contentBackgroud.frame = CGRectMake(0, self.topToolBarBackgroud.bm_bottom, UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT-self.topToolBarBackgroud.bm_bottom);
    
    if (self.roomtype == YSRoomType_One)
    {
        [self calculateVideoSize];
        
        self.contentView.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH, whitebordHeight);
        [self.contentView bm_centerInSuperView];
        
        self.whitebordBackgroud.frame = CGRectMake(0, 0, whitebordWidth, whitebordHeight);
        
        self.videoBackgroud.frame = CGRectMake(whitebordWidth, 0, videoWidth+VIDEOVIEW_GAP*2, whitebordHeight);
        
        [self setUp1V1DefaultVideoView];
    }
    else
    {
        self.contentView.frame = self.contentBackgroud.bounds;
        [self.contentView bm_centerInSuperView];
        
        self.videoBackgroud.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH, VIDEOVIEW_MAXHEIGHT+VIDEOVIEW_GAP);
        
        self.whitebordBackgroud.frame = CGRectMake(0, self.videoBackgroud.bm_height, UI_SCREEN_WIDTH, self.contentView.bm_height-self.videoBackgroud.bm_height);
        
        // 添加浮动视频窗口
        self.dragOutFloatViewArray = [[NSMutableArray alloc] init];
        
        // 1VN 初始本人视频音频
        SCVideoView *videoView = [[SCVideoView alloc] initWithRoomUser:YSCurrentUser isForPerch:YES withDelegate:self];
        videoView.appUseTheType = self.appUseTheType;
        [self.videoViewArray addObject:videoView];
        [self.liveManager playVideoOnView:videoView withPeerId:YSCurrentUser.peerID renderType:YSRenderMode_adaptive completion:nil];
        
        [self.liveManager playAudio:YSCurrentUser.peerID completion:nil];
    }
    
    // 共享
    self.shareVideoFloatView = [[YSFloatView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.shareVideoFloatView];
    self.shareVideoFloatView.hidden = YES;
    self.shareVideoView = [[UIView alloc] initWithFrame:self.shareVideoFloatView.bounds];
    [self.shareVideoFloatView showWithContentView:self.shareVideoView];
    self.shareVideoFloatView.backgroundColor = [UIColor blackColor];
    
    self.whiteBordView.frame = self.whitebordBackgroud.bounds;
    [[YSLiveManager shareInstance].whiteBoardManager refreshWhiteBoard];
    
    self.mp4ControlView = [[YSMp4ControlView alloc] init];
    [self.view addSubview:self.mp4ControlView];
    self.mp4ControlView.frame = CGRectMake(30, 0, UI_SCREEN_WIDTH - 60, 74);
    self.mp4ControlView.bm_bottom = self.view.bm_bottom - 23;
    self.mp4ControlView.backgroundColor = [UIColor bm_colorWithHex:0x6D7278 alpha:0.39];
    self.mp4ControlView.layer.cornerRadius = 37;
    self.mp4ControlView.hidden = YES;
    self.mp4ControlView.delegate = self;
    
    self.closeMp4Btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:self.closeMp4Btn];
    self.closeMp4Btn.frame = CGRectMake(UI_SCREEN_WIDTH - 60, 30, 25, 25);
    [self.closeMp4Btn setBackgroundImage:[UIImage imageNamed:@"ysteacher_closemp4_normal"] forState:UIControlStateNormal];
    [self.closeMp4Btn addTarget:self action:@selector(closeMp4BtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.closeMp4Btn.hidden = YES;
    
    self.mp3ControlView = [[YSMp3Controlview alloc] init];
    self.mp3ControlView.hidden = YES;
    self.mp3ControlView.delegate = self;
    self.mp3ControlView.backgroundColor = [UIColor bm_colorWithHex:0x000000 alpha:0.39];
    [self.view addSubview:self.mp3ControlView];
    if ([UIDevice bm_isiPad])
    {
        self.mp3ControlView.frame = CGRectMake(10, 0, 386, 74);
        self.mp3ControlView.bm_bottom = self.view.bm_bottom - 123;
        self.mp3ControlView.layer.cornerRadius = 37;
    }
    else
    {
        self.mp3ControlView.frame = CGRectMake(80, 0, 300, 60);
        self.mp3ControlView.bm_bottom = self.view.bm_bottom - 20;
        self.mp3ControlView.layer.cornerRadius = 30;
    }

    [self freshContentView];
}

- (void)closeMp4BtnClicked:(UIButton *)btn
{
    [self.liveManager.roomManager stopShareMediaFile:nil];
}
/// 1V1 初始默认视频背景
- (void)setUp1V1DefaultVideoView
{
    // 1V1 初始本人视频音频
    SCVideoView *videoView = [[SCVideoView alloc] initWithRoomUser:YSCurrentUser isForPerch:YES withDelegate:self];
    videoView.appUseTheType = self.appUseTheType;
    videoView.tag = PlaceholderPTag;
    
    [self.videoBackgroud addSubview:videoView];
    videoView.frame = CGRectMake(VIDEOVIEW_GAP, 0, videoWidth, videoHeight);
    self.teacherVideoView = videoView;
    
    [self.liveManager playVideoOnView:videoView withPeerId:YSCurrentUser.peerID renderType:YSRenderMode_adaptive completion:nil];
    [self.liveManager playAudio:YSCurrentUser.peerID completion:nil];
    
    // 1V1 初始学生视频蒙版
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_uservideocover"]];
    YSRoomUser *roomUser = [[YSRoomUser alloc] initWithPeerId:@"055481"];
    roomUser.role = YSUserType_Student;
    SCVideoView *userVideoView = [[SCVideoView alloc] initWithRoomUser:roomUser isForPerch:YES withDelegate:self];
    userVideoView.appUseTheType = self.appUseTheType;
    userVideoView.tag = PlaceholderPTag;
    userVideoView.frame = CGRectMake(0, 0, videoWidth, videoHeight);
    imageView.frame = userVideoView.bounds;
    [userVideoView addSubview:imageView];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView.contentMode = UIViewContentModeCenter;
    imageView.backgroundColor = [UIColor bm_colorWithHex:0xEDEDED];
    [self.videoBackgroud addSubview:userVideoView];
    userVideoView.frame = CGRectMake(VIDEOVIEW_GAP, (videoHeight+VIDEOVIEW_GAP)*1, videoWidth, videoHeight);
    self.userVideoView = userVideoView;
}

/// 隐藏白板视频布局背景
- (void)setupVideoGridView
{
    SCVideoGridView *videoGridView = [[SCVideoGridView alloc] initWithWideScreen:self.isWideScreen];
    CGFloat width;
    CGFloat height;
    if (self.isWideScreen)
    {
        height = (UI_SCREEN_HEIGHT-TOPTOOLBAR_HEIGHT) * 4 / 5;
        width = height * 16 / 9;
    }
    else
    {
        height = (UI_SCREEN_HEIGHT-TOPTOOLBAR_HEIGHT) * 4 / 5;
        width = height * 4 / 3;
    }
    // 初始化尺寸
    videoGridView.defaultSize = CGSizeMake(width, height);
    videoGridView.frame = CGRectMake(0, 0, width, height);
    
    //[self.view addSubview:videoGridView];
    [self.contentBackgroud addSubview:videoGridView];
    [videoGridView bm_centerInSuperView];
//    videoGridView.topOffset = TOPTOOLBAR_HEIGHT*0.5;
    videoGridView.backgroundColor = [UIColor clearColor];
    videoGridView.hidden = YES;
    self.videoGridView = videoGridView;
}

- (void)setupListView
{
    CGFloat tableHeight = ListView_Height;
    if (![UIDevice bm_isiPad])
    {
        
        tableHeight = UI_SCREEN_HEIGHT;
    }
    self.teacherListView = [[SCTeacherListView alloc] initWithFrame:CGRectMake(UI_SCREEN_WIDTH, 0, UI_SCREEN_WIDTH, tableHeight)];
    self.teacherListView.bm_centerY = self.view.bm_centerY;
    self.teacherListView.delegate = self;
    [self.view addSubview:self.teacherListView];
}

#pragma mark -
#pragma mark UI fresh

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

// 横排视频最大宽度计算
- (CGFloat)getVideoTotalWidth
{
    CGFloat teacherWidth = 0;
    
    NSUInteger count = [self getVideoViewCount];
    
    // 老师没被拖出
    if (self.teacherVideoView && !self.teacherVideoView.isDragOut && !self.teacherVideoView.isFullScreen)
    {
        teacherWidth = videoWidth;
        count--;
    }
    
    CGFloat totalWidth = teacherWidth + count*(videoWidth+VIDEOVIEW_GAP*0.5);
    
    return totalWidth;
}

// 计算横排视频是是否需要改变尺寸
- (BOOL)checkVideoSize
{
    if ([self.videoViewArray bm_isNotEmpty])
    {
        CGFloat totalWidth = [self getVideoTotalWidth];
        return (totalWidth > UI_SCREEN_WIDTH);
    }
    else
    {
        return NO;
    }
}


// 计算视频尺寸，除老师视频
- (void)calculateVideoSize
{
    if (self.roomtype == YSRoomType_One)
    {
        if (self.roomLayout == YSLiveRoomLayout_VideoLayout)
        {//左右平行关系
            videoWidth = ceil((UI_SCREEN_WIDTH-VIDEOVIEW_GAP*3) / 2);
            videoHeight = ceil(videoWidth*9 / 16);
        }else
        {
            // 在此调整视频大小和屏幕比例关系
            if (self.isWideScreen)
            {
                videoWidth = ceil(UI_SCREEN_WIDTH / 25) * 9;
                videoHeight = ceil(videoWidth*9 / 16);
            }
            else
            {
                videoWidth = ceil(UI_SCREEN_WIDTH*5 / 21);
                videoHeight = ceil(videoWidth*3 / 4);
            }
            
            whitebordWidth = UI_SCREEN_WIDTH - (videoWidth+VIDEOVIEW_GAP*2);
            whitebordHeight = VIDEOVIEW_GAP + videoHeight * 2;
            if ((whitebordHeight+TOPTOOLBAR_HEIGHT)>UI_SCREEN_HEIGHT)
            {
                BMLog(@"UI_SCREEN_HEIGHT: %@", @(UI_SCREEN_HEIGHT));
                
                whitebordHeight = UI_SCREEN_HEIGHT-TOPTOOLBAR_HEIGHT-VIDEOVIEW_GAP;
                videoHeight = (whitebordHeight - VIDEOVIEW_GAP)*0.5;
                if (self.isWideScreen)
                {
                    videoWidth = ceil(videoHeight*16 / 9);
                }
                else
                {
                    videoWidth = ceil(videoHeight*4 / 3);
                }
            }
        }
    }
    else
    {
        if ([self checkVideoSize])
        {
            //floor((UI_SCREEN_WIDTH+VIDEOVIEW_GAP*0.5)/self.videoViewArray.count-VIDEOVIEW_GAP*0.5);
            
            NSUInteger count = [self getVideoViewCount];
            /// 老师视频是否被拖出
            //            if (self.teacherVideoView && !self.teacherVideoView.isDragOut)
            //            {
            //                videoWidth = floor((UI_SCREEN_WIDTH-videoTeacherWidth)/(count-1)-VIDEOVIEW_GAP*0.5);
            //            }
            //            else
            {
                videoWidth = floor(UI_SCREEN_WIDTH/count-VIDEOVIEW_GAP*0.5);
            }
            
            if (self.isWideScreen)
            {
                videoHeight = ceil(videoWidth* 9 / 16);
            }
            else
            {
                videoHeight = ceil(videoWidth* 3 / 4);
            }
        }
        else
        {
            videoHeight = VIDEOVIEW_MAXHEIGHT;
            
            if (self.isWideScreen)
            {
                videoWidth = ceil(videoHeight* 16 / 9);
            }
            else
            {
                videoWidth = ceil(videoHeight* 4 / 3);
            }
        }
    }
    [self freshWhitBordContentView];
}
- (void)freshWhitBordContentView
{
    if (self.roomtype == YSRoomType_One)
    {
        if (self.roomLayout == YSLiveRoomLayout_VideoLayout)
        {//左右平行关系
            self.whitebordBackgroud.hidden = YES;
            
            self.videoBackgroud.frame = CGRectMake(whitebordWidth, 0, UI_SCREEN_WIDTH, videoHeight);
            
            self.teacherVideoView.frame = CGRectMake(VIDEOVIEW_GAP, 0, videoWidth, videoHeight);
            self.userVideoView.frame = CGRectMake(VIDEOVIEW_GAP*2+videoWidth, 0, videoWidth, videoHeight);
        }
        else
        {//默认上下平行关系
            self.whitebordBackgroud.hidden = NO;
            self.whitebordBackgroud.frame = CGRectMake(0, 0, whitebordWidth, whitebordHeight);
            self.whiteBordView.frame = self.whitebordBackgroud.bounds;
            self.videoBackgroud.frame = CGRectMake(whitebordWidth, 0, videoWidth+VIDEOVIEW_GAP*2, whitebordHeight);
            
            self.userVideoView.frame = CGRectMake(VIDEOVIEW_GAP, (videoHeight+VIDEOVIEW_GAP)*1, videoWidth, videoHeight);
            self.teacherVideoView.frame = CGRectMake(VIDEOVIEW_GAP, 0, videoWidth, videoHeight);
            [[YSLiveManager shareInstance].whiteBoardManager refreshWhiteBoard];
        }
    }
    else
    {
        self.videoBackgroud.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH, videoHeight+VIDEOVIEW_GAP);
        
        self.whitebordBackgroud.frame = CGRectMake(0, self.videoBackgroud.bm_height, UI_SCREEN_WIDTH, self.contentView.bm_height-self.videoBackgroud.bm_height);
        self.whiteBordView.frame = self.whitebordBackgroud.bounds;
        [[YSLiveManager shareInstance].whiteBoardManager refreshWhiteBoard];
    }
}

- (void)freshContentView
{
    if (self.roomtype == YSRoomType_One)
    {
        if(self.videoViewArray.count>1)
        {
            self.userVideoView.hidden = YES;
        }
        else
        {
            self.userVideoView.hidden = NO;
        }
        
        if (self.roomLayout == YSLiveRoomLayout_VideoLayout)
        {
            [self freshVidoeGridView];
        }
        else
        {
            [self freshContentVidoeView];
            [self.videoBackgroud bringSubviewToFront:self.userVideoView];
        }
    }
    else
    {
        if (self.roomLayout == YSLiveRoomLayout_VideoLayout)
        {
            [self freshVidoeGridView];
        }
        else
        {
            [self freshContentVidoeView];
        }
    }
}
// 刷新content视频布局
- (void)freshContentVidoeView
{
    self.contentView.hidden = NO;
    self.videoGridView.hidden = YES;
    
    [self.videoGridView clearView];
    
    //[self.videoBackgroud bm_removeAllSubviews];
    //    [self.userVideoView removeFromSuperview];
    [self.videoBackgroud addSubview:self.userVideoView];
    NSMutableArray *viewArray = [[NSMutableArray alloc] init];
    [self.videoBackgroud.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull childView, NSUInteger idx, BOOL * _Nonnull stop) {
        [viewArray addObject:childView];
    }];
    
    for (SCVideoView *videoView in viewArray)
    {
        if (videoView.tag != PlaceholderPTag && videoView.tag != DoubleBtnTag)
        {
            [videoView removeFromSuperview];
        }
    }
    
    for (SCVideoView *videoView in self.videoViewArray)
    {
        if (videoView.isDragOut || videoView.isFullScreen)
        {
            continue;
        }
        
        videoView.isFullMedia = NO;
        
        [self.videoBackgroud addSubview:videoView];
    }
    
    [self calculateVideoSize];
    [self arrangeVidoeView];
}

///排布视图
- (void)arrangeVidoeView
{
    if (self.roomtype == YSRoomType_One)
    {
        for (NSUInteger i=0; i<self.videoViewArray.count; i++)
        {
            SCVideoView *view = self.videoViewArray[i];
            if (view.isFullScreen)
            {
                continue;
            }
            
            if (self.roomLayout == YSLiveRoomLayout_VideoLayout)
            {//左右平行关系
                if ([view.roomUser.peerID isEqualToString:self.liveManager.teacher.peerID])
                {
                    view.frame = CGRectMake(VIDEOVIEW_GAP, 0, videoWidth, whitebordHeight);
                }
                else
                {
                    view.frame = CGRectMake(VIDEOVIEW_GAP*2+videoWidth, 0, videoWidth, whitebordHeight);
                }
                
                [self.liveManager stopPlayVideo:view.roomUser.peerID completion:nil];
                [self.liveManager playVideoOnView:view withPeerId:view.roomUser.peerID renderType:YSRenderMode_fit completion:nil];
            }
            else
            {//上下平行关系
                if ([view.roomUser.peerID isEqualToString:self.liveManager.teacher.peerID])
                {
                    view.frame = CGRectMake(VIDEOVIEW_GAP, 0, videoWidth, videoHeight);
                }
                else
                {
                    view.frame = CGRectMake(VIDEOVIEW_GAP, videoHeight+VIDEOVIEW_GAP, videoWidth, videoHeight);
                }
                
                [self.liveManager stopPlayVideo:view.roomUser.peerID completion:nil];
                [self.liveManager playVideoOnView:view withPeerId:view.roomUser.peerID renderType:YSRenderMode_adaptive completion:nil];
                
            }
            [view bringSubviewToFront:view.backVideoView];
            
            
            
//            if ([view.roomUser.peerID isEqualToString:self.liveManager.teacher.peerID])
//            {
//                view.frame = CGRectMake(VIDEOVIEW_GAP, 0, videoWidth, videoHeight);
//            }
//            else
//            {
//                view.frame = CGRectMake(VIDEOVIEW_GAP, (videoHeight+VIDEOVIEW_GAP)*1, videoWidth, videoHeight);
//            }
        }
    }
    else
    {
        if ([self checkVideoSize])
        {
            [self calculateVideoSize];
        }
        
        CGFloat totalWidth = [self getVideoTotalWidth];
        videoStartX = (UI_SCREEN_WIDTH-totalWidth)*0.5;
        
        NSUInteger index = 0;
        for (SCVideoView *view in self.videoViewArray)
        {
            if (view.isDragOut || view.isFullScreen)
            {
                continue;
            }
            
// 老师视频是否被拖出
//            if (self.teacherVideoView && !self.teacherVideoView.isDragOut)
//            {
//                if (index==0)
//                {
//                    view.frame = CGRectMake(videoStartX, VIDEOVIEW_GAP*0.5, videoTeacherWidth, videoTeacherHeight);
//                }
//                else
//                {
//                    view.frame = CGRectMake(videoStartX+videoTeacherWidth+VIDEOVIEW_GAP*0.5+(videoWidth+VIDEOVIEW_GAP*0.5)*(index-1), VIDEOVIEW_GAP*0.5, videoWidth, videoHeight);
//                }
//            }
//            else
            {
                view.frame = CGRectMake(videoStartX+(videoWidth+VIDEOVIEW_GAP*0.5)*index, VIDEOVIEW_GAP*0.5, videoWidth, videoHeight);
            }
            
            index++;
        }
    }
}

// 刷新宫格视频布局
- (void)freshVidoeGridView
{
    //[self hideShareVidoeView];
    
    [self hideWhiteBordVidoeViewWithPeerId:nil];
    [self hideAllDragOutVidoeView];
    
    //    [self.videoBackgroud bm_removeAllSubviews];
    
    NSMutableArray *viewArray = [[NSMutableArray alloc] init];
    [self.videoBackgroud.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull childView, NSUInteger idx, BOOL * _Nonnull stop) {
        [viewArray addObject:childView];
    }];
    
    for (SCVideoView *videoView in viewArray)
    {
        if (videoView.tag != DoubleBtnTag)
        {
            [videoView removeFromSuperview];
        }
    }

    [self.videoGridView freshViewWithVideoViewArray:self.videoViewArray];
    
    [self arrangeAllViewInContentBackgroudViewWithViewType:SCMain_ArrangeContentBackgroudViewType_VideoGridView index:0];
    self.contentView.hidden = YES;
    self.videoGridView.hidden = NO;
}

/// 上下课按钮点击事件
- (void)classBeginEndProxyWithBtn:(UIButton *)btn
{
    if (btn.selected)
    {
        BMWeakType(btn)
        BMWeakSelf
        classEndAlertVC = [UIAlertController alertControllerWithTitle:YSLocalized(@"Prompt.FinishClass") message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *confimAc = [UIAlertAction actionWithTitle:YSLocalized(@"Prompt.OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            weakbtn.userInteractionEnabled = NO;
            [weakSelf.liveManager sendSignalingTeacherToDismissClassWithCompletion:nil];
        }];
        UIAlertAction *cancle = [UIAlertAction actionWithTitle:YSLocalized(@"Prompt.Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [classEndAlertVC addAction:confimAc];
        [classEndAlertVC addAction:cancle];
        
        [self presentViewController:classEndAlertVC animated:YES completion:nil];
    }
    else
    {
        btn.userInteractionEnabled = NO;
        [self.liveManager sendSignalingTeacherToClassBeginWithCompletion:nil];
    }
}

#pragma mark - videoViewArray

- (void)playVideoAudioWithVideoView:(SCVideoView *)videoView
{
    if (!videoView)
    {
        return;
    }
    
    YSPublishState publishState = [videoView.roomUser.properties bm_intForKey:sUserPublishstate];
    
    YSRenderMode renderType = YSRenderMode_adaptive;
    if (videoView.isFullScreen)
    {
        renderType = YSRenderMode_fit;
    }
    
    if (publishState == YSUser_PublishState_VIDEOONLY)
    {
        if (videoView.publishState != YSUser_PublishState_VIDEOONLY && videoView.publishState != YSUser_PublishState_BOTH)
        {
            //[self.liveManager stopPlayVideo:videoView.roomUser.peerID completion:nil];
            [self.liveManager playVideoOnView:videoView withPeerId:videoView.roomUser.peerID renderType:renderType completion:nil];
            [videoView bringSubviewToFront:videoView.backVideoView];
        }
        [self.liveManager stopPlayAudio:videoView.roomUser.peerID completion:nil];
    }
    if (publishState == YSUser_PublishState_AUDIOONLY)
    {
        [self.liveManager playAudio:videoView.roomUser.peerID completion:nil];
        [self.liveManager stopPlayVideo:videoView.roomUser.peerID completion:nil];
    }
    if (publishState == YSUser_PublishState_BOTH)
    {
        if (videoView.publishState != YSUser_PublishState_VIDEOONLY && videoView.publishState != YSUser_PublishState_BOTH)
        {
            //[self.liveManager stopPlayVideo:videoView.roomUser.peerID completion:nil];
            [self.liveManager playVideoOnView:videoView withPeerId:videoView.roomUser.peerID renderType:renderType completion:nil];
            [videoView bringSubviewToFront:videoView.backVideoView];
        }
        [self.liveManager playAudio:videoView.roomUser.peerID completion:nil];
    }
    if (publishState < YSUser_PublishState_AUDIOONLY || publishState > YSUser_PublishState_BOTH)
    {
        [self.liveManager stopPlayVideo:videoView.roomUser.peerID completion:nil];
        [self.liveManager stopPlayAudio:videoView.roomUser.peerID completion:nil];
    }
    
    videoView.publishState = publishState;
}

- (void)stopVideoAudioWithVideoView:(SCVideoView *)videoView
{
    if (!videoView)
    {
        return;
    }
    
    [self.liveManager stopPlayVideo:videoView.roomUser.peerID completion:nil];
    [self.liveManager stopPlayAudio:videoView.roomUser.peerID completion:nil];
    videoView.publishState = 4;
}


#pragma mark  添加视频窗口
- (void)addVidoeViewWithPeerId:(NSString *)peerId
{
    //    if ([peerId isEqualToString:self.teacherVideoView.roomUser.peerID])
    //    {
    //        [self playVideoAudioWithVideoView:self.teacherVideoView];
    //        return;
    //    }
    //
    YSRoomUser *roomUser = [[YSLiveManager shareInstance].roomManager getRoomUserWithUId:peerId];
    if (!roomUser)
    {
        return;
    }
    
    // 删除本人占位视频
    for (SCVideoView *avideoView in self.videoViewArray)
    {
        if (avideoView.isForPerch)
        {
            [self stopVideoAudioWithVideoView:avideoView];
            [self.videoViewArray removeObject:avideoView];
            break;
        }
    }
    
    SCVideoView *newVideoView = nil;
    
    BOOL isUserExist = NO;
    
    for (SCVideoView *videoView in self.videoViewArray)
    {
        if ([videoView.roomUser.peerID isEqualToString:peerId])
        {
#if (0)
            // 删除本人占位视频
            if (self.roomtype == YSRoomType_One)
            {
                if (videoView.isForPerch)
                {
                    [self stopVideoAudioWithVideoView:videoView];
                    [self.videoViewArray removeObject:videoView];
                    if (self.userVideoCoverView.superview)
                    {
                        [self.userVideoCoverView removeFromSuperview];
                    }
                    break;
                }
            }
#endif
            newVideoView = videoView;
            // property刷新原用户的值没有变化，需要重新赋值user
            [videoView changeRoomUserProperty:roomUser];
            isUserExist = YES;
            break;
        }
    }
    
    if (!isUserExist)
    {
        if ([peerId isEqualToString:self.liveManager.localUser.peerID])
        {
            [self.liveManager stopPlayVideo:peerId completion:nil];
            [self.liveManager stopPlayAudio:peerId completion:nil];
        }
        
        SCVideoView *videoView = [[SCVideoView alloc] initWithRoomUser:roomUser withDelegate:self];
        videoView.appUseTheType = self.appUseTheType;
        newVideoView = videoView;
        if (videoView)
        {
            [self.videoViewArray addObject:videoView];
            if (roomUser.role == YSUserType_Teacher)
            {
                self.teacherVideoView = videoView;
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
    
    if (newVideoView)
    {
        [self playVideoAudioWithVideoView:newVideoView];
        
        [newVideoView bringSubviewToFront:newVideoView.backVideoView];
        
        [self freshContentView];
    }
    return;
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

- (void)delVidoeViewWithPeerId:(NSString *)peerId
{
    SCVideoView *delVideoView = nil;
    if ([peerId isEqualToString:self.teacherVideoView.roomUser.peerID])
    {
        delVideoView = self.teacherVideoView;
        [self.videoViewArray removeObject:self.teacherVideoView];
        self.teacherVideoView = nil;
        //        if (self.roomtype == YSRoomType_One)
        //        {
        //            // 1V1 初始老师视频蒙版
        //            [self addTeacherVideoViewForPerch];
        //        }
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
        
        if (delVideoView.isDragOut)
        {
            [self hideDragOutVidoeViewWithPeerId:peerId];
        }
        else if (delVideoView.isFullScreen)
        {
//            [self handleSignalingDragOutVideoChangeFullSizeWithPeerId:nil isFull:NO];
        }
        else
        {
            [self freshContentView];
        }
    }
}

#pragma mark  删除所有视频窗口
- (void)removeAllVideoView
{
    [self hideAllDragOutVidoeView];
//    [self handleSignalingDragOutVideoChangeFullSizeWithPeerId:nil isFull:NO];
    
    for (SCVideoView *videoView in self.videoViewArray)
    {
        [self stopVideoAudioWithVideoView:videoView];
    }
    
    [self.videoViewArray removeAllObjects];
}

- (void)kickedOutFromRoom:(NSUInteger)reasonCode
{
    NSString *reasonString = YSLocalized(@"KickOut.Repeat");//(@"KickOut.SentOutClassroom");
    
    BMWeakSelf
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:reasonString message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confimAc = [UIAlertAction actionWithTitle:YSLocalized(@"Prompt.OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[BMNoticeViewStack sharedInstance] closeAllNoticeViews];
        [weakSelf.liveManager destroy];
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertVc addAction:confimAc];
    [self presentViewController:alertVc animated:YES completion:nil];
}


#pragma mark -
#pragma mark YSLiveRoomManagerDelegate

- (void)onRoomConnectionLost
{
    [super onRoomConnectionLost];
    
    [self removeAllVideoView];
    
    [self handleSignalingDefaultRoomLayout];
}

// 已经离开房间
- (void)onRoomLeft
{
    [super onRoomLeft];
    
    // 网络中断尝试失败后退出
    [[BMNoticeViewStack sharedInstance] closeAllNoticeViews];// 清除alert的栈
    [self.liveManager destroy];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark 网络状态

/// 自己的网络状态变化
- (void)roomManagerUserChangeNetStats:(id)stats
{
    /// 网络质量
    YSNetQuality netQuality;
    /// 网络延时
    NSInteger netDelay;
    CGFloat totalPackets;
    NSInteger lostPacketsLost;
    /// 丢包率
    CGFloat lostRate;
    
    if ([stats isKindOfClass:[YSAudioStats class]])
    {
        YSAudioStats *status = (YSAudioStats *)stats;
        netQuality = [stats netLevel];
        netDelay = [status currentDelay];
        totalPackets = [status totalPackets];
        lostPacketsLost = [status packetsLost];
        lostRate = (totalPackets > 0) ? (lostPacketsLost/totalPackets) : 0.00f;
    }
    else
    {
        YSVideoStats *status = (YSVideoStats *)stats;
        netQuality = [stats netLevel];
        netDelay = [status currentDelay];
        totalPackets = [status totalPackets];
        lostPacketsLost = [status packetsLost];
        lostRate = (totalPackets > 0) ? (lostPacketsLost/totalPackets) : 0.00f;
    }
    
    if (netQuality>YSNetQuality_VeryBad)
    {
        [self bringSomeViewToFront];
        [self.progressHUD bm_showAnimated:NO withText:YSLocalized(@"Error.WaitingForNetwork") delay:PROGRESSBOX_DEFAULT_HIDE_DELAY];
    }
    
//    self.topBarModel.netQuality = netQuality;
//    self.topBarModel.netDelay = netDelay;
//    self.topBarModel.lostRate = lostRate;
//    self.topToolBar.topToolModel = self.topBarModel;
}

/// 老师主播的网络状态变化
- (void)roomManagerTeacherrChangeNetStats:(id)stats
{
    YSNetQuality netQuality;
    /// 网络延时
    NSInteger netDelay;
    CGFloat totalPackets;
    NSInteger lostPacketsLost;
    /// 丢包率
    CGFloat lostRate;
    if ([stats isKindOfClass:[YSAudioStats class]])
    {
        YSAudioStats *status = (YSAudioStats *)stats;
        netQuality = [status netLevel];
        netDelay = [status currentDelay];
        totalPackets = [status totalPackets];
        lostPacketsLost = [status packetsLost];
        lostRate = (totalPackets > 0) ? (lostPacketsLost/totalPackets) : 0.00f;
    }
    else
    {
        YSVideoStats *status = (YSVideoStats *)stats;
        netQuality = [status netLevel];
        netDelay = [status currentDelay];
        totalPackets = [status totalPackets];
        lostPacketsLost = [status packetsLost];
        lostRate = (totalPackets > 0) ? (lostPacketsLost/totalPackets) : 0.00f;
    }
    
    if (netQuality>YSNetQuality_VeryBad)
    {
        [self bringSomeViewToFront];
        [self.progressHUD bm_showAnimated:NO withText:YSLocalized(@"Error.WaitingForNetwork") delay:PROGRESSBOX_DEFAULT_HIDE_DELAY];
    }
    
    self.topBarModel.netQuality = netQuality;
    self.topBarModel.netDelay = netDelay;
    self.topBarModel.lostRate = lostRate;
    self.topToolBar.topToolModel = self.topBarModel;
}

// 网络测速回调
// @param networkQuality 网速质量 (TKNetQuality_Down 测速失败)
// @param delay 延迟(毫秒)
- (void)onRoomNetworkQuality:(YSNetQuality)networkQuality delay:(NSInteger)delay
{
    if (networkQuality>YSNetQuality_VeryBad)
    {
        [self bringSomeViewToFront];
        [self.progressHUD bm_showAnimated:NO withText:YSLocalized(@"Error.WaitingForNetwork") delay:PROGRESSBOX_DEFAULT_HIDE_DELAY];
    }
}

#pragma mark  用户进入
- (void)roomManagerJoinedUser:(YSRoomUser *)user inList:(BOOL)inList
{
    // 不做互踢
    if (user.role == YSUserType_Teacher)
    {
        if (inList == YES)
        {
            [self.liveManager.roomManager evictUser:user.peerID completion:nil];
        }
    }
    [self freshTeacherPersonListData];
    
   [self raiseHandReloadData];
    
//    if (self.appUseTheType == YSAppUseTheTypeMeeting)
//    {
//        if (user.role == YSUserType_Teacher || user.role == YSUserType_Student) {
//            [self.liveManager sendSignalingToChangePropertyWithRoomUser:user withKey:sUserPublishstate WithValue:@(YSUser_PublishState_BOTH)];
//        }
//    }
}

/// 用户退出
- (void)roomManagerLeftUser:(YSRoomUser *)user
{
    if (self.roomtype == YSRoomType_More)
    {
        [self delVidoeViewWithPeerId:user.peerID];
    }
    
    [self freshTeacherPersonListData];
    
    [self raiseHandReloadData];
}

/// 自己被踢出房间
- (void)onRoomKickedOut:(NSDictionary *)reason
{
    NSUInteger reasonCode = [reason bm_uintForKey:@"reason"];

    if (classEndAlertVC)
    {
        [classEndAlertVC dismissViewControllerAnimated:YES completion:^{
            [self kickedOutFromRoom:reasonCode];
        }];
        
        return;
    }
    
    [self kickedOutFromRoom:reasonCode];
}

///刷新举手上台的人数
- (void)raiseHandReloadData
{
    NSInteger userNum = self.liveManager.userList.count;
    
    for (YSRoomUser * user in self.liveManager.userList) {
        if (user.role != YSUserType_Student)
        {
            userNum --;
        }
    }
    if (userNum<0)
    {
        userNum = 0;
    }
    
    self.handNumLab.text = [NSString stringWithFormat:@"%lu/%ld",(unsigned long)self.raiseHandArray.count,(long)userNum];
}


#pragma mark - 用户属性变化

- (void)onRoomUserPropertyChanged:(NSString *)peerID properties:(NSDictionary *)properties fromId:(NSString *)fromId
{
    SCVideoView *videoView = [self getVideoViewWithPeerId:peerID];

    // 举手上台
       if ([properties bm_containsObjectForKey:sUserRaisehand])
       {
           BOOL raisehand = [properties bm_boolForKey:sUserRaisehand];
                      
           YSRoomUser *user = [self.liveManager.roomManager getRoomUserWithUId:peerID];
           
           if (user.publishState>0 && raisehand)
           {
               videoView.isRaiseHand = YES;
           }
           else
           {
               videoView.isRaiseHand = NO;
           }
           
           if (raisehand && ![self.raiseHandArray containsObject:user])
           {//举手上台
               [self.raiseHandArray addObject:user];
               self.upHandPopTableView.userArr = self.raiseHandArray;
               
               if (![self.haveRaiseHandArray containsObject:user]) {
                   [self.haveRaiseHandArray addObject:user];
               }
           }
           else if (!raisehand && [self.raiseHandArray containsObject:user])
           {//取消举手上台
               [self.raiseHandArray removeObject:user];
               self.upHandPopTableView.userArr = self.raiseHandArray;
               
               if (self.raiseHandArray.count<1) {
                   [self.upHandPopTableView dismissViewControllerAnimated:YES completion:nil];
               }
           }
           self.raiseHandsBtn.selected = [self.raiseHandArray bm_isNotEmpty];
           [self raiseHandReloadData];
       }
    
    // 奖杯数
    if ([properties bm_containsObjectForKey:sUserGiftNumber])
    {
        YSRoomUser *fromUser = [self.liveManager.roomManager getRoomUserWithUId:fromId];
        if (fromUser.role != YSUserType_Student)
        {
            videoView.giftNumber =  [properties bm_uintForKey:sUserGiftNumber];
            [self showGiftAnimationWithVideoView:videoView];
        }
    }
    
    // 画笔颜色值
    if ([properties bm_containsObjectForKey:sUserPrimaryColor])
    {
        NSString *colorStr = [properties bm_stringTrimForKey:sUserPrimaryColor];
        if ([colorStr bm_isNotEmpty])
        {
            videoView.brushColor = colorStr;
        }
    }
    
    // 画笔权限
    if ([properties bm_containsObjectForKey:sUserCandraw])
    {
        videoView.canDraw = [properties bm_boolForKey:sUserCandraw];
        if ([peerID isEqualToString:self.liveManager.localUser.peerID])
        {
            BOOL canDraw = YSCurrentUser.canDraw;//[properties bm_boolForKey:sUserCandraw];
                        
            if (self.roomLayout == YSLiveRoomLayout_VideoLayout)
            {
                self.brushToolView.hidden = YES;
            }
            else
            {
//                self.brushToolView.hidden = !canDraw;
                // 设置画笔颜色初始值
                if (canDraw)
                {
                    if (![[YSCurrentUser.properties bm_stringTrimForKey:sUserPrimaryColor] bm_isNotEmpty])
                    {
                        [self setCurrentUserPrimaryColor];
                    }
                }
                
                videoView.canDraw = canDraw;
                if (!self.brushToolView.toolsBtn.selected || self.brushToolView.mouseBtn.selected)
                {
                    self.drawBoardView.hidden = YES;
                }else
                {
                    self.drawBoardView.hidden = NO;
                }
                self.boardControlView.allowPaging = YES;
            }
        }
    }
    
    // 本人是否被禁言
    if ([properties bm_containsObjectForKey:sUserDisablechat])
    {
        if ([peerID isEqualToString:self.liveManager.localUser.peerID])
        {
            BOOL disablechat = [properties bm_boolForKey:sUserDisablechat];
            
            NSString * teacherId = [YSLiveManager shareInstance].teacher.peerID;
            
            if ([fromId isEqualToString:teacherId])
            {
                self.rightChatView.allDisabledChat.hidden = !disablechat;
                self.rightChatView.textBtn.hidden = disablechat;
                if (disablechat)
                {
                    self.rightChatView.allDisabledChat.text = YSLocalized(@"Prompt.BanChat");
                    [self hiddenTheKeyBoard];
                    [[YSLiveManager shareInstance] sendTipMessage:YSLocalized(@"Prompt.BanChat") tipType:YSChatMessageTypeTips];
                }
                else
                {
                    [[YSLiveManager shareInstance] sendTipMessage:YSLocalized(@"Prompt.CancelBanChat") tipType:YSChatMessageTypeTips];
                }
            }
        }
    }
    
    // 发布媒体状态
    if ([properties bm_containsObjectForKey:sUserPublishstate])
    {
        YSPublishState publishState = [properties bm_intForKey:sUserPublishstate];
        YSRoomUser *user = [self.liveManager.roomManager getRoomUserWithUId:peerID];
        
        if ([self.raiseHandArray containsObject:user]) {
            [self.raiseHandArray removeObject:user];
            [self.raiseHandArray addObject:user];
            self.upHandPopTableView.userArr = self.raiseHandArray;
        }
        
        if ([peerID isEqualToString:self.liveManager.localUser.peerID])
        {
            if (publishState == YSUser_PublishState_VIDEOONLY)
            {
                
            }
            if (publishState == YSUser_PublishState_AUDIOONLY)
            {
                
            }
            if (publishState == YSUser_PublishState_BOTH)
            {
                
            }
            if (publishState < YSUser_PublishState_AUDIOONLY || publishState > YSUser_PublishState_BOTH)
            {
                
            }
            else
            {
                if (publishState != YSUser_PublishState_VIDEOONLY)
                {
                    
                }
            }
        }
        
        //YSRoomUser * user = [[YSLiveManager shareInstance].roomManager getRoomUserWithUId:peerID];
        
        BOOL hasVidoe = NO;
        BOOL hasAudio = NO;
        if (publishState == YSUser_PublishState_VIDEOONLY)
        {
            hasVidoe = YES;
            [self addVidoeViewWithPeerId:peerID];
        }
        else if (publishState == YSUser_PublishState_AUDIOONLY)
        {
            hasAudio = YES;
            [self addVidoeViewWithPeerId:peerID];
        }
        else if (publishState == YSUser_PublishState_BOTH)
        {
            hasVidoe = YES;
            hasAudio = YES;
            [self addVidoeViewWithPeerId:peerID];
        }
        else if (publishState != 4)
        {
            [self delVidoeViewWithPeerId:peerID];
        }
        
        videoView.disableSound = !hasAudio;
        videoView.disableVideo = !hasVidoe;
    }
    
    //进入前后台
    if ([properties bm_containsObjectForKey:sUserIsInBackGround])
    {
        videoView.isInBackGround = [properties bm_boolForKey:sUserIsInBackGround];
    }
    
//    YSRoomUser *fromUser = [self.liveManager.roomManager getRoomUserWithUId:fromId];
//    if (videoView)
//    {
//        [videoView changeRoomUserProperty:fromUser];
//    }

    [self freshTeacherPersonListData];
}

#pragma mark 音量变化

- (void)handleSelfAudioVolumeChanged
{
    SCVideoView *view = [self getVideoViewWithPeerId:self.liveManager.localUser.peerID];
    view.iVolume = self.liveManager.iVolume;
}

- (void)handleOtherAudioVolumeChangedWithPeerID:(NSString *)peeID volume:(NSUInteger)volume
{
    SCVideoView *view = [self getVideoViewWithPeerId:peeID];
    view.iVolume = volume;
}

#pragma mark 切换网络 会收到onRoomJoined

- (void)onRoomJoined:(long)ts
{
    [super onRoomJoined:ts];
    
    if (self.liveManager.isBeginClass)
    {
        needFreshVideoView = YES;
        
        // 因为切换网络会先调用classBegin
        // 所以要在这里刷新VideoAudio
        [self rePlayVideoAudio];
    
        if (YSCurrentUser.hasVideo)
        {
            [self.liveManager.roomManager unPublishVideo:nil];
            [self.liveManager.roomManager publishVideo:nil];
        }
        if (YSCurrentUser.hasAudio)
        {
            [self.liveManager.roomManager unPublishAudio:nil];
            [self.liveManager.roomManager publishAudio:nil];
        }
    }
    else
    {
        if (self.roomtype == YSRoomType_More)
        {
            // 1VN 初始本人视频音频
            SCVideoView *videoView = [[SCVideoView alloc] initWithRoomUser:YSCurrentUser isForPerch:YES];
            videoView.appUseTheType = self.appUseTheType;
            [self.videoViewArray addObject:videoView];
            [self.liveManager playVideoOnView:videoView withPeerId:YSCurrentUser.peerID renderType:YSRenderMode_adaptive completion:nil];
            [self.liveManager playAudio:YSCurrentUser.peerID completion:nil];
            
            [self freshContentView];
        }
    }
}

- (void)rePlayVideoAudio
{
    for (SCVideoView *videoView in self.videoViewArray)
    {
        [self stopVideoAudioWithVideoView:videoView];
        [self playVideoAudioWithVideoView:videoView];
    }
}

#pragma mark 上课
//inlist表示在我进房间之前的信令
- (void)handleSignalingClassBeginWihInList:(BOOL)inlist
{
    self.topToolBar.classBtn.userInteractionEnabled = YES;
    
    [self.liveManager.roomManager changeUserProperty:YSCurrentUser.peerID tellWhom:YSCurrentUser.peerID key:sUserCandraw value:@(true) completion:nil];
    self.topToolBar.layoutType = SCTeacherTopBarLayoutType_ClassBegin;
    if (self.appUseTheType == YSAppUseTheTypeMeeting)
    {
        if ((self.roomLayout == YSLiveRoomLayout_VideoLayout))
        {
            self.topToolBar.layoutType = SCTeacherTopBarLayoutType_FullMedia;
        }
        else
        {
            self.topToolBar.layoutType = SCTeacherTopBarLayoutType_ClassBegin;
        }
    }
    
    [self addVidoeViewWithPeerId:self.liveManager.teacher.peerID];
    [self freshTeacherPersonListData];
    self.brushToolView.hidden = NO;
    for (YSRoomUser *roomUser in self.liveManager.userList)
    {
        if (needFreshVideoView)
        {
            needFreshVideoView = NO;
            break;
        }
        YSPublishState publishState = [roomUser.properties bm_intForKey:sUserPublishstate];
        NSString *peerID = roomUser.peerID;
        
        BOOL hasVidoe = NO;
        BOOL hasAudio = NO;
        if (publishState == YSUser_PublishState_VIDEOONLY)
        {
            hasVidoe = YES;
            [self addVidoeViewWithPeerId:peerID];
        }
        else if (publishState == YSUser_PublishState_AUDIOONLY)
        {
            hasAudio = YES;
            [self addVidoeViewWithPeerId:peerID];
        }
        else if (publishState == YSUser_PublishState_BOTH)
        {
            hasVidoe = YES;
            hasAudio = YES;
            [self addVidoeViewWithPeerId:peerID];
        }
        else if (publishState == 4)
        {
            [self addVidoeViewWithPeerId:peerID];
        }
        else
        {
            [self delVidoeViewWithPeerId:peerID];
        }
        
        SCVideoView *videoView = [self getVideoViewWithPeerId:peerID];
        videoView.disableSound = !hasAudio;
        videoView.disableVideo = !hasVidoe;
    }

    self.boardControlView.allowPaging = YES;
    [self.boardControlView sc_setTotalPage:self.liveManager.currentFile.pagenum.integerValue currentPage:self.liveManager.currentFile.currpage.integerValue isWhiteBoard:[self.liveManager.currentFile.fileid isEqualToString:@"0"]];
    
    if (self.topBarTimer)
    {
        dispatch_source_cancel(self.topBarTimer);
        self.topBarTimer = nil;
    }

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.topBarTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    dispatch_source_set_timer(self.topBarTimer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    //3.要调用的任务
    BMWeakSelf
    dispatch_source_set_event_handler(self.topBarTimer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf countDownTime:nil];
        });
    });
    //4.开始执行
    dispatch_resume(self.topBarTimer);

    if (!inlist)
    {
        if (YSCurrentUser.hasVideo)
        {
            [self.liveManager.roomManager publishVideo:nil];
        }
        if (YSCurrentUser.hasAudio)
        {
            [self.liveManager.roomManager publishAudio:nil];
        }
    }
}

/// 下课
- (void)handleSignalingClassEndWithText:(NSString *)text
{
    self.topToolBar.classBtn.userInteractionEnabled = YES;

    BMWeakSelf
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:text message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confimAc = [UIAlertAction actionWithTitle:YSLocalized(@"Prompt.OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf.liveManager destroy];
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertVC addAction:confimAc];
    [self presentViewController:alertVC animated:YES completion:nil];
}

/// 弹框
- (void)showSignalingClassEndWithText:(NSString *)text
{
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:text message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confimAc = [UIAlertAction actionWithTitle:YSLocalized(@"Prompt.OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertVc addAction:confimAc];
    [self presentViewController:alertVc animated:YES completion:nil];
}


/// 房间即将关闭消息
- (BOOL)handleSignalingPrepareRoomEndWithDataDic:(NSDictionary *)dataDic addReason:(YSPrepareRoomEndType)reason
{
    NSUInteger reasonCount = [dataDic bm_uintForKey:@"reason"];
    
//    if (reason == YSPrepareRoomEndType_TeacherLeaveTimeout)
//    {//老师离开房间时间过长
//
//        if (reasonCount == 1)
//        {
//            [self showSignalingClassEndWithText:YSLocalized(@"Prompt.TeacherLeave8")];
//        }
//    }
//    else
        if (reason == YSPrepareRoomEndType_RoomTimeOut)
    {//房间预约时间
               
        if (reasonCount == 2)
        {//表示房间预约时间已到，30分钟后房间即将关闭
            [self showSignalingClassEndWithText:YSLocalized(@"Prompt.Appointment30")];
        }
        else if(reasonCount == 3)
        {//表示已经超过房间预约时间28分钟，2分钟后房间即将关闭
           [self showSignalingClassEndWithText:YSLocalized(@"Prompt.Appointment28")];
        }
    }
    return YES;
}

///房间踢除所有用户消息
- (void)handleSignalingEvictAllRoomUseWithDataDic:(NSDictionary *)dataDic
{
    NSString * reason = [dataDic bm_stringForKey:@"reason"];
    if ([reason isEqualToString:@"30 minutes past the end of the reservation"])
    {
        [self handleSignalingClassEndWithText:YSLocalized(@"Prompt.ClassEndAppointment30")];
    }
    else if([reason isEqualToString:@"All the teachers left the room for more than 10 minutes"])
    {
        [self handleSignalingClassEndWithText:YSLocalized(@"Prompt.ClassEndAnchorLeave10")];
    }
}

#pragma mark -刷新花名册数据
- (void)freshTeacherPersonListData
{
    if (self.topSelectBtn.tag == SCTeacherTopBarTypePersonList && self.topSelectBtn.selected)
    {
        //花名册  有用户进入房间调用 上下课调用
        [self.teacherListView setDataSource:[YSLiveManager shareInstance].userList withType:SCTeacherTopBarTypePersonList];
    }

}

#pragma mark - 播放白板
- (void)handleWhiteBordPlayMediaFileWithMedia:(YSLiveMediaModel *)mediaModel
{
    [self freshTeacherCoursewareListDataWithPlay:YES];
    if (mediaModel.video)
    {
        [self showWhiteBordVidoeViewWithPeerId:mediaModel.user_peerId];
    }
    else if (mediaModel.audio)
    {
        [self.liveManager.roomManager playMediaFile:mediaModel.user_peerId renderType:YSRenderMode_fit window:self.teacherVideoView completion:^(NSError *error) {
        }];
        [self onPlayMp3];
    }
}
- (void)onPlayMp3
{
    self.mp3ControlView.hidden = NO;
    [self arrangeAllViewInVCView];
}
- (void)onStopMp3
{
    self.mp3ControlView.hidden = YES;
}
// 停止白板视频/音频
- (void)handleWhiteBordStopMediaFileWithMedia:(YSLiveMediaModel *)mediaModel
{
    if (mediaModel.video)
    {
        [self hideWhiteBordVidoeViewWithPeerId:mediaModel.user_peerId];
    }
    else if (mediaModel.audio)
    {
        [self.liveManager.roomManager unPlayMediaFile:mediaModel.user_peerId completion:^(NSError *error) {
        }];
        [self onStopMp3];
    }
    [self freshTeacherCoursewareListDataWithPlay:NO];
}

/// 继续播放白板视频/音频
- (void)handleWhiteBordPlayMediaStream
{
    
    if (self.liveManager.playMediaModel.video)
    {
        
        self.mp4ControlView.isPlay = YES;
    }
    else if (self.liveManager.playMediaModel.audio)
    {

        [self onPlayMp3];
        self.mp3ControlView.isPlay = YES;
    }
    [self freshTeacherCoursewareListDataWithPlay:YES];
}

/// 暂停播放白板视频/音频
- (void)handleWhiteBordPauseMediaStream
{
    if (self.liveManager.playMediaModel.video)
    {
        self.mp4ControlView.isPlay = NO;
    }
    else if (self.liveManager.playMediaModel.audio)
    {
        self.mp3ControlView.isPlay = NO;
    }
    [self freshTeacherCoursewareListDataWithPlay:NO];

}
 
- (void)onRoomUpdateMediaStream:(NSTimeInterval)duration
                            pos:(NSTimeInterval)pos
                         isPlay:(BOOL)isPlay
{
    BMLog(@"onRoomUpdateMediaStream: %@, %@, %@", @(duration), @(pos), @(isPlay));
    if (pos == duration)
    {
        [self.liveManager.roomManager stopShareMediaFile:nil];
        return;
    }
    if (isPlay)
    {
        if (pos <= 0)
        {
            return;
        }
        if (!isDrag)
        {
            if (self.liveManager.playMediaModel.video)
            {
                    
                [self.mp4ControlView setMediaStream:duration pos:pos isPlay:isPlay fileName:self.liveManager.playMediaModel.filename];
            }
            if (self.liveManager.playMediaModel.audio)
            {
                    
                [self.mp3ControlView setMediaStream:duration pos:pos isPlay:isPlay fileName:self.liveManager.playMediaModel.filename];
            }
        }

        isDrag = NO;
    }
}

#pragma mark -YSMp3ControlViewDelegate
- (void)playMp3ControlViewPlay:(BOOL)isPlay
{
    [self.liveManager.roomManager pauseMediaFile:isPlay];
    isMediaPause = isPlay;
    [self freshTeacherCoursewareListDataWithPlay:!isPlay];
}

- (void)sliderMp3ControlView:(NSInteger)value
{
    isDrag = YES;
    [self.liveManager.roomManager seekMediaFile:value];
}

- (void)closeMp3ControlView
{
      
    [self.liveManager.roomManager stopShareMediaFile:nil];
}
#pragma mark -YSMp4ControlViewDelegate

- (void)playYSMp4ControlViewPlay:(BOOL)isPlay
{
    [self.liveManager.roomManager pauseMediaFile:isPlay];
}

- (void)sliderYSMp4ControlView:(NSInteger)value
{
    isDrag = YES;
    [self.liveManager.roomManager pauseMediaFile:YES];
    BOOL success = [self.liveManager.roomManager seekMediaFile:value] == 0;
    if (success)
    {
        [self.liveManager.roomManager pauseMediaFile:NO];
    }
}

#pragma mark -刷新课件库数据
- (void)freshTeacherCoursewareListDataWithPlay:(BOOL)isPlay
{
    if (self.topSelectBtn.tag == SCTeacherTopBarTypeCourseware && self.topSelectBtn.selected)
    {
        YSFileModel *file = [[YSLiveManager shareInstance] getFileWithFileID:self.liveManager.playMediaModel.fileid];
        file.isPlaying = isPlay;
        
        [self.teacherListView setDataSource:self.liveManager.fileList withType:SCTeacherTopBarTypeCourseware];
    }
}

- (void)showGiftAnimationWithVideoView:(SCVideoView *)videoView
{
    if (!videoView)
    {
        return;
    }
    
    NSBundle *bundle = [NSBundle bundleWithPath: [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"YSResources.bundle"]];
    NSString *filePath = [[bundle resourcePath] stringByAppendingPathComponent:@"trophy_tones.wav"];
    
    static BOOL giftMp3Playing = NO;
    
    if (!giftMp3Playing)
    {
        giftMp3Playing = YES;
        [self.liveManager.roomManager startPlayMediaFile:filePath window:nil loop:NO progress:^(int playID, int64_t current, int64_t total) {
            if (current >= total)
            {
                giftMp3Playing = NO;
            }
        }];
    }
    
    UIImageView *giftImageView = [self makeGiftImageView];
    [UIView animateWithDuration:1.0f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
        giftImageView.bm_size = CGSizeMake(GiftImageView_Width, GiftImageView_Height);
        [giftImageView bm_centerInSuperView];
    }
                     completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
            giftImageView.bm_size = CGSizeMake(GiftImageView_Width*0.1, GiftImageView_Height*0.1);
            CGPoint center = [self.view convertPoint:videoView.center fromView:videoView.superview];
            giftImageView.center = center;
        }
                         completion:^(BOOL finished) {
            giftImageView.hidden = YES;
            [giftImageView removeFromSuperview];
        }];
    }];
}

- (UIImageView *)makeGiftImageView
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, GiftImageView_Width*0.5, GiftImageView_Height*0.5)];
    imageView.image = [UIImage imageNamed:@"main_giftshow"];
    [self.view addSubview:imageView];
    [imageView bm_centerInSuperView];
    
    return imageView;
}


#pragma mark -
#pragma mark  拖出/放回视频相关

///长按可以拖动视频
- (void)panToMoveVideoView:(SCVideoView*)videoView withGestureRecognizer:(nonnull UIPanGestureRecognizer *)pan
{
    if (self.roomtype == YSRoomType_One) {
        return;
    }
        
    self.dragingVideoView = videoView;
    
    CGPoint endPoint = [pan translationInView:videoView];
    
    if (!self.dragImageView)
    {
        UIImage * img = [self.dragingVideoView bm_screenshot];
        self.dragImageView = [[UIImageView alloc]initWithImage:img];
        [self.whitebordBackgroud addSubview:self.dragImageView];
    }
    
    if (self.videoOriginInSuperview.x == 0 && self.videoOriginInSuperview.y == 0) {
        self.videoOriginInSuperview = [self.whitebordBackgroud convertPoint:CGPointMake(0, 0) fromView:videoView];
        [self.whitebordBackgroud bringSubviewToFront:self.dragImageView];
    }
    self.dragImageView.frame = CGRectMake(self.videoOriginInSuperview.x + endPoint.x, self.videoOriginInSuperview.y + endPoint.y, videoView.bm_width, videoView.bm_height);
    
    if (pan.state == UIGestureRecognizerStateEnded) {
        
         [[PanGestureControl shareInfo] removePanGestureAction:LONG_PRESS_VIEW_DEMO];
        
        CGFloat percentLeft = (self.videoOriginInSuperview.x+endPoint.x)/(UI_SCREEN_WIDTH - videoView.bm_width);
        CGFloat percentTop = (self.videoOriginInSuperview.y+endPoint.y)/(self.whitebordBackgroud.bm_height - videoView.bm_height);
        
        if (percentLeft>1)
        {
            percentLeft = 1;
        }
        else if (percentLeft<0)
        {
            percentLeft = 0;
        }
        if (percentTop>1)
        {
            percentTop = 1;
        }

        if (percentTop<0) {
            NSDictionary * data = @{
                       @"isDrag":@0,
                       @"userId":videoView.roomUser.peerID
                   };
            [self.liveManager sendSignalingToDragOutVideoViewWithData:data];
            
            [self.dragImageView removeFromSuperview];
            self.dragImageView = nil;
            self.videoOriginInSuperview = CGPointZero;
            return;
        }
        
        NSDictionary * data = @{
            @"isDrag":@1,
            @"percentLeft":[NSString stringWithFormat:@"%f",percentLeft],
            @"percentTop":[NSString stringWithFormat:@"%f",percentTop],
            @"userId":videoView.roomUser.peerID
        };
        [self.liveManager sendSignalingToDragOutVideoViewWithData:data];
        
        [self.dragImageView removeFromSuperview];
        self.dragImageView = nil;
        self.videoOriginInSuperview = CGPointZero;
    }
}

#pragma mark 拖出/放回视频窗口
- (void)handleSignalingDragOutVideoWithPeerId:(NSString *)peerId atPercentLeft:(CGFloat)percentLeft percentTop:(CGFloat)percentTop isDragOut:(BOOL)isDragOut
{
    if (isDragOut)
    {
        [self showDragOutVidoeViewWithPeerId:peerId percentLeft:percentLeft percentTop:percentTop];
    }
    else
    {
        [self hideDragOutVidoeViewWithPeerId:peerId];
    }
}

#pragma mark floatVideo

- (void)calculateFloatVideoSize
{
    CGFloat width;
    CGFloat height;
    
    // 在此调整视频大小和屏幕比例关系
    if (self.isWideScreen)
    {
        width = ceil(UI_SCREEN_WIDTH / 25) * 9;
        NSString *heightStr = [NSString stringWithFormat:@"%.2f",width*9 / 16];
        height = [heightStr floatValue];
    }
    else
    {
        width = ceil(UI_SCREEN_WIDTH*5 / 21);
        NSString *heightStr = [NSString stringWithFormat:@"%.2f",width*3 / 4];
        height = [heightStr floatValue];
    }
    
    /// 悬浮默认视频宽(拖出和共享)
    floatVideoDefaultWidth = width;
    /// 悬浮默认视频高(拖出和共享)
    floatVideoDefaultHeight = height;
}

// 拖出视频
- (void)showDragOutVidoeViewWithPeerId:(NSString *)peerId percentLeft:(CGFloat)percentLeft percentTop:(CGFloat)percentTop
{
    if (self.roomLayout == YSLiveRoomLayout_VideoLayout)
    {
        return;
    }
    
    SCVideoView *videoView = [self getVideoViewWithPeerId:peerId];
    if (videoView.isDragOut)
    {
//        if (percentTop<0) {
//            NSDictionary * data = @{
//                       @"isDrag":@0,
//                       @"userId":peerId
//                   };
//            [self.liveManager sendSignalingToDragOutVideoViewWithData:data];
//            return;
//        }
               
        CGFloat x = percentLeft * (UI_SCREEN_WIDTH - 2 - videoView.bm_width);
        CGFloat y = percentTop * (self.whitebordBackgroud.bm_height - 2 - videoView.bm_height);
        if (x <= 0) {
            x = 1.0;
        }
        
        CGPoint point = CGPointMake(x, y);
        
        YSFloatView *floatView = (YSFloatView *)(videoView.superview.superview);
        floatView.frame = CGRectMake(point.x, point.y, videoView.bm_width, videoView.bm_height);
        [floatView bm_bringToFront];
        
        return;
    }
    else
    {
        videoView.isDragOut = YES;
        [self freshContentVidoeView];
        
        CGFloat x = percentLeft * (UI_SCREEN_WIDTH - 2 - floatVideoDefaultWidth);
        CGFloat y = percentTop * (self.whitebordBackgroud.bm_height - 2 - floatVideoDefaultHeight);
        if (x <= 0) {
            x = 1.0;
        }
        CGPoint point = CGPointMake(x, y);
        
        YSFloatView *floatView = [[YSFloatView alloc] initWithFrame:CGRectMake(point.x, point.y, floatVideoDefaultWidth, floatVideoDefaultHeight)];
        // 暂时不支持本地拖动缩放
        floatView.canGestureRecognizer = YES;
        floatView.defaultSize = CGSizeMake(floatVideoDefaultWidth, floatVideoDefaultHeight);
        //[floatView showWithContentView:videoView];
        [self.dragOutFloatViewArray addObject:floatView];
        [self.whitebordBackgroud addSubview:floatView];
        
        [floatView showWithContentView:videoView];
        //[floatView stayMove];
        [floatView bm_bringToFront];
        floatView.maxSize = self.whitebordBackgroud.bm_size;
        floatView.peerId = peerId;
    }
}

// 放回视频
- (void)hideDragOutVidoeViewWithPeerId:(NSString *)peerId
{
    if (self.roomLayout == YSLiveRoomLayout_VideoLayout)
    {
        return;
    }
    
    BOOL needFresh = NO;
    for (YSFloatView *floatView in self.dragOutFloatViewArray )
    {
        SCVideoView *videoView = (SCVideoView *)floatView.contentView;
        if ([videoView.roomUser.peerID isEqualToString:peerId])
        {
            needFresh = YES;
            videoView.isDragOut = NO;
            
            [floatView cleanContent];
            if (floatView.superview)
            {
                [floatView removeFromSuperview];
            }
            [self.dragOutFloatViewArray removeObject:floatView];
            break;
        }
    }
    
    if (needFresh)
    {
        [self freshContentVidoeView];
    }
}

#pragma mark  获取拖出的浮动窗口
- (YSFloatView *)getVideoFloatViewWithPeerId:(NSString *)peerId
{
    for (YSFloatView *floatView in self.dragOutFloatViewArray)
    {
        SCVideoView *videoView = (SCVideoView *)floatView.contentView;
        if ([videoView.roomUser.peerID isEqualToString:peerId])
        {
            return floatView;
        }
    }
    return nil;
}

- (void)hideAllDragOutVidoeView
{
    for (YSFloatView *floatView in self.dragOutFloatViewArray )
    {
        SCVideoView *videoView = (SCVideoView *)floatView.contentView;
        
        videoView.isDragOut = NO;
        
        [floatView cleanContent];
        if (floatView.superview)
        {
            [floatView removeFromSuperview];
        }
    }
    [self.dragOutFloatViewArray removeAllObjects];
}


/// 设置自己默认画笔颜色
- (void)setCurrentUserPrimaryColor
{
    NSArray *colorArray = [SCColorSelectView colorArray];
    NSString *newColorStr;
    if (self.roomtype == YSRoomType_One)
    {
        newColorStr = @"#FF0000";
        [[YSLiveManager shareInstance].roomManager changeUserProperty:YSCurrentUser.peerID tellWhom:YSRoomPubMsgTellAll key:sUserPrimaryColor value:newColorStr completion:nil];
    }
    else
    {
        NSUInteger index = arc4random() % colorArray.count;
        newColorStr = colorArray[index];
        [[YSLiveManager shareInstance].roomManager changeUserProperty:YSCurrentUser.peerID tellWhom:YSRoomPubMsgTellAll key:sUserPrimaryColor value:newColorStr completion:nil];
    }
    
    [self.liveManager.whiteBoardManager changeDefaultPrimaryColor:newColorStr];
}

#pragma mark 共享桌面

/// 开始桌面共享 服务端控制与课件视频/音频互斥
- (void)handleRoomStartShareDesktopWithPeerID:(NSString *)peerID
{
    [self showShareVidoeViewWithPeerId:peerID];
}

/// 停止桌面共享
- (void)handleRoomStopShareDesktopWithPeerID:(NSString *)peerID
{
    [self hideShareVidoeViewWithPeerId:peerID];
}

// 开始共享桌面
- (void)showShareVidoeViewWithPeerId:(NSString *)peerId
{
    [self.view endEditing:YES];
    
    //self.shareVideoFloatView.frame = CGRectMake(point.x, point.y, floatVideoDefaultWidth, floatVideoDefaultHeight);
    //[self.shareVideoFloatView stayMove];
    
    [self.liveManager.roomManager playScreen:peerId renderType:YSRenderMode_fit window:self.shareVideoView completion:^(NSError *error) {
    }];
    
    //[self arrangeAllViewInContentBackgroudViewWithViewType:SCMain_ArrangeContentBackgroudViewType_ShareVideoFloatView index:0];
    
    [self arrangeAllViewInVCView];
    self.shareVideoFloatView.canZoom = YES;
    self.shareVideoFloatView.showWaiting = NO;
    self.shareVideoFloatView.hidden = NO;
}

// 关闭共享桌面
- (void)hideShareVidoeViewWithPeerId:(NSString *)peerId
{
    [self.liveManager.roomManager unPlayScreen:peerId completion:^(NSError * _Nonnull error) {
    }];
    
    self.shareVideoFloatView.canZoom = NO;
    self.shareVideoFloatView.backScrollView.zoomScale = 1.0;
    self.shareVideoFloatView.hidden = YES;
}


#pragma mark 进入前台后台

/// 进入后台
- (void)handleEnterBackground
{
    [[YSRoomInterface instance]changeUserProperty:YSCurrentUser.peerID tellWhom:YSRoomPubMsgTellAll key:@"isInBackGround" value:@1 completion:nil];
}

/// 进入前台
- (void)handleEnterForeground
{
    [[YSRoomInterface instance]changeUserProperty:YSCurrentUser.peerID tellWhom:YSRoomPubMsgTellAll key:@"isInBackGround" value:@0 completion:nil];
}

#pragma mark - 顶部bar 定时操作
- (void)countDownTime:(NSTimer *)timer
{
    NSTimeInterval time = self.liveManager.tCurrentTime - self.liveManager.tClassStartTime;
    NSString *str =  [NSDate bm_countDownENStringDateFromTs:time];
    self.topBarModel.lessonTime = str;
    self.topToolBar.topToolModel = self.topBarModel;
}


// 开始播放课件视频
- (void)showWhiteBordVidoeViewWithPeerId:(NSString *)peerId
{
    [self.view endEditing:YES];
    self.mp4ControlView.hidden = NO;
    self.closeMp4Btn.hidden = NO;
    [self.liveManager.roomManager playMediaFile:peerId renderType:YSRenderMode_fit window:self.shareVideoView completion:^(NSError *error) {
    }];
    
    //[self arrangeAllViewInContentBackgroudViewWithViewType:SCMain_ArrangeContentBackgroudViewType_ShareVideoFloatView index:0];
    
    [self arrangeAllViewInVCView];
    self.shareVideoFloatView.canZoom = NO;
    self.shareVideoFloatView.backScrollView.zoomScale = 1.0;
    self.shareVideoFloatView.showWaiting = YES;
    self.shareVideoFloatView.hidden = NO;
}

// 关闭课件视频
- (void)hideWhiteBordVidoeViewWithPeerId:(NSString *)peerId
{
    if (self.liveManager.playMediaModel.video)
    {
        if (!peerId)
        {
            peerId = self.liveManager.playMediaModel.user_peerId;
        }
        [self.liveManager.roomManager unPlayMediaFile:peerId completion:^(NSError *error) {
        }];
    }
    
    self.shareVideoFloatView.canZoom = NO;
    self.shareVideoFloatView.backScrollView.zoomScale = 1.0;
    self.shareVideoFloatView.hidden = YES;
    self.mp4ControlView.hidden = YES;
    self.closeMp4Btn.hidden = YES;
    // 主动清除白板视频标注 服务端会发送关闭
    //    [self handleSignalingHideVideoWhiteboard];
}

/// 隐藏白板视频标注
//- (void)handleSignalingHideVideoWhiteboard
//{
//    if (self.mediaMarkView.superview)
//    {
//        [self.mediaMarkView removeFromSuperview];
//    }
//}


// 重新排列ContentBackgroudView的图层
- (void)arrangeAllViewInContentBackgroudViewWithViewType:(SCMain_ArrangeContentBackgroudViewType)arrangeType index:(NSUInteger)index
{
    switch (arrangeType)
    {
        case SCMain_ArrangeContentBackgroudViewType_ShareVideoFloatView:
            //[self.shareVideoFloatView bm_bringToFront];
            break;
            
        case SCMain_ArrangeContentBackgroudViewType_VideoGridView:
            [self.videoGridView bm_bringToFront];
            break;
            
            // 暂时不用 在i响应式直接前移
        case SCMain_ArrangeContentBackgroudViewType_DragOutFloatViews:
            [self.dragOutFloatViewArray[index] bm_bringToFront];
            break;
            
        default:
            break;
    }
}

#pragma mark -
#pragma mark YSWhiteBoardManagerDelegate

- (void)onWhiteBoardViewStateUpdate:(NSDictionary *)message
{
    // WebView显示课件刷新回调
    
    YSFileModel *file = self.liveManager.currentFile;
    
    if (!file || file.isMedia.intValue)
    {
        return;
    }
    
    [self.boardControlView resetBtnStates];

    self.boardControlView.bm_width = 161; //CGRectMake(0, 0, 160, 34);
    self.boardControlView.bm_centerX = self.view.bm_centerX;
    
    NSString *totalPage = file.pagenum;
    NSString *currentPage = file.currpage;
    if (!currentPage)
    {
        currentPage = @"1";
    }

    BOOL prevPage = NO;
    BOOL nextPage = NO;

    if ([message bm_containsObjectForKey:@"page"])
    {
        NSDictionary *dicPage = message[@"page"];
        prevPage = [dicPage bm_boolForKey:@"prevPage"];
        nextPage = [dicPage bm_boolForKey:@"nextPage"];
    }
            
    [self.boardControlView sc_setTotalPage:totalPage.integerValue currentPage:currentPage.integerValue canPrevPage:prevPage canNextPage:nextPage isWhiteBoard:[file.fileid isEqualToString:@"0"]];
    
    return;
}

/// 本地操作，缩放课件比例变化
- (void)onWhiteBoardFileViewZoomScaleChanged:(CGFloat)zoomScale
{
    [self.boardControlView changeZoomScale:zoomScale];
}

#pragma mark 白板翻页 换课件

- (void)handleSignalingWhiteBroadShowPageMessage:(NSDictionary *)message isDynamic:(BOOL)isDynamic
{
    [self freshTeacherCoursewareListDataWithPlay:NO];
    
    [self.boardControlView resetBtnStates];
    
    // 只处理白板显示课件刷新回调

    if (!isDynamic)
    {
        self.boardControlView.bm_width = 246;
        self.boardControlView.bm_centerX = self.view.bm_centerX;
        
        YSFileModel *file = self.liveManager.currentFile;
        NSString *totalPage = [message objectForKey:@"pagenum"];
        NSString *currentPage = [message objectForKey:@"currpage"];
        [self.boardControlView sc_setTotalPage:totalPage.integerValue currentPage:currentPage.integerValue isWhiteBoard:[file.fileid isEqualToString:@"0"]];
    }
    
    return;
}

/// 收到添加删除文件信令
- (void)handleSignalingWhiteBroadDocumentChange
{
    [self freshTeacherCoursewareListDataWithPlay:NO];
}

#pragma mark -
#pragma mark 顶部Bar -- SCTeacherTopBarDelegate

/// 顶部工具栏
- (void)sc_TeacherTopBarProxyWithBtn:(UIButton *)btn
{
    BMLog(@"%@",@(self.topSelectBtn.selected));
    
    if (self.topSelectBtn == btn)
    {
        
    }
    else
    {
        if (!(self.topSelectBtn.tag == SCTeacherTopBarTypeCamera || self.topSelectBtn.tag == SCTeacherTopBarTypeSwitchLayout))
        {
            self.topSelectBtn.selected = NO;
        }
        
        if (self.topSelectBtn.tag == SCTeacherTopBarTypeCourseware || self.topSelectBtn.tag == SCTeacherTopBarTypePersonList)
        {
            [self freshListViewWithSelect:NO];
        }
    }
    
    if (btn.tag == SCTeacherTopBarTypeCamera)
    {
        //摄像头
        [self.liveManager.roomManager selectCameraPosition:btn.selected];
    }
    
    if (btn.tag == SCTeacherTopBarTypeSwitchLayout)
    {
        //切换布局
        [self changeLayoutWithMode:!btn.selected];
    }
    
    if (btn.tag == SCTeacherTopBarTypeAllControll)
    {
        //全局控制
        [self popoverToolSenderWithType:SCTeacherTopBarTypeAllControll sender:btn];
        
    }
    
    if (btn.tag == SCTeacherTopBarTypeToolBox)
    {
        //工具箱
        [self popoverToolSenderWithType:SCTeacherTopBarTypeToolBox sender:btn];
    }
    
    if (btn.tag == SCTeacherTopBarTypePersonList)
    {
        //花名册  有用户进入房间调用 上下课调用
        [self freshListViewWithSelect:!btn.selected];
        [self.teacherListView setDataSource:[YSLiveManager shareInstance].userList withType:SCTeacherTopBarTypePersonList];
//        [self freshTeacherPersonListData];
    }
    
    if (btn.tag == SCTeacherTopBarTypeCourseware)
    {
        [self freshListViewWithSelect:!btn.selected];
        //课件库
        [self.teacherListView setDataSource:[YSLiveManager shareInstance].fileList withType:SCTeacherTopBarTypeCourseware];
//        [self freshTeacherCoursewareListData];
    }
    
    if (btn.tag != SCTeacherTopBarTypeSwitchLayout)
    {
        btn.selected = !btn.selected;
    }
    
    self.topSelectBtn = btn;
}

// 是否弹出课件库 以及 花名册  select  yes--弹出  no--收回
- (void)freshListViewWithSelect:(BOOL)select
{
    CGRect tempRect = self.teacherListView.frame;
    if (select)
    {//弹出
        tempRect.origin.x = 0;
        
        //收回聊天
        self.chatBtn.selected = NO;
        CGRect chatViewRect = self.rightChatView.frame;
        chatViewRect.origin.x = UI_SCREEN_WIDTH;
        [UIView animateWithDuration:0.25 animations:^{
            self.rightChatView.frame = chatViewRect;
        }];
    }
    else
    {//收回
        tempRect.origin.x = UI_SCREEN_WIDTH;
    }
    [UIView animateWithDuration:0.25 animations:^{
        self.teacherListView.frame = tempRect;
    }];
}

/// 退出
- (void)exitProxyWithBtn:(UIButton *)btn
{
    [self backAction:nil];
}

#pragma mark 切换布局模式
- (void)changeLayoutWithMode:(BOOL)mode
{
    if (mode) {
        //全体复位
        for (YSRoomUser * user in [YSLiveManager shareInstance].userList)
        {
            NSDictionary * data = @{
                @"isDrag":@0,
                @"userId":user.peerID
            };
            [self.liveManager sendSignalingToDragOutVideoViewWithData:data];
        }
    }
    
    //NO:上下布局  YES:左右布局
    if (self.appUseTheType == YSAppUseTheTypeMeeting)
    {
        YSLiveRoomLayout roomLayout = YSLiveRoomLayout_VideoLayout;
        if (!mode)
        {
            roomLayout = YSLiveRoomLayout_AroundLayout;
        }
        [self.liveManager sendSignalingToChangeLayoutWithLayoutType:roomLayout appUserType:YSAppUseTheTypeMeeting];
    }
    else
    {
        YSLiveRoomLayout roomLayout = YSLiveRoomLayout_VideoLayout;
        if (!mode)
        {
            roomLayout = YSLiveRoomLayout_AroundLayout;
        }
        [self.liveManager sendSignalingToChangeLayoutWithLayoutType:roomLayout];
    }
}

#pragma mark 窗口布局变化
- (void)handleSignalingSetRoomLayout:(YSLiveRoomLayout)roomLayout
{
    //NO:上下布局  YES:左右布局
    self.roomLayout = roomLayout;
    
    self.boardControlView.hidden = (self.roomLayout == YSLiveRoomLayout_VideoLayout);

    self.brushToolView.hidden = (self.roomLayout == YSLiveRoomLayout_VideoLayout);
    
    if ((self.roomLayout == YSLiveRoomLayout_VideoLayout))
    {
        self.topToolBar.layoutType = SCTeacherTopBarLayoutType_FullMedia;
    }
    else
    {
        self.topToolBar.layoutType = SCTeacherTopBarLayoutType_ClassBegin;
    }
    
    self.topToolBar.switchLayoutBtn.selected = (self.roomLayout == YSLiveRoomLayout_VideoLayout);
    
    [self freshContentView];
}

- (void)handleSignalingDefaultRoomLayout
{
    [self handleSignalingSetRoomLayout:defaultRoomLayout];
}

- (void)backAction:(id)sender
{
    BMWeakSelf
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:YSLocalized(@"Prompt.Quite") message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confimAc = [UIAlertAction actionWithTitle:YSLocalized(@"Prompt.OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[BMNoticeViewStack sharedInstance] closeAllNoticeViews];// 清除alert的栈
        [weakSelf.liveManager destroy];
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *cancleAc = [UIAlertAction actionWithTitle:YSLocalized(@"Prompt.Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertVc addAction:cancleAc];
    [alertVc addAction:confimAc];
    [self presentViewController:alertVc animated:YES completion:nil];
}


- (void)popoverToolSenderWithType:(SCTeacherTopBarType)type sender:(UIButton *)sender
{
    self.topbarPopoverView.popoverPresentationController.sourceView = sender;
    UIPopoverPresentationController *popover = self.topbarPopoverView.popoverPresentationController;
    popover.sourceRect = sender.bounds;
    popover.delegate = self;
    popover.backgroundColor =  [UIColor bm_colorWithHex:0x336CC7];

    popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    [self presentViewController:self.topbarPopoverView animated:YES completion:nil];///present即可
    popover.permittedArrowDirections = UIPopoverArrowDirectionUp;
    [self.topbarPopoverView freshUIWithType:type isMeeting:self.appUseTheType == YSAppUseTheTypeMeeting];
}

#pragma mark - UIPopoverPresentationControllerDelegate
- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
    if (!(self.topSelectBtn.tag == SCTeacherTopBarTypeCamera || self.topSelectBtn.tag == SCTeacherTopBarTypeSwitchLayout))
    {
        self.topSelectBtn.selected = NO;
    }
    return YES;
}


#pragma mark -
#pragma mark SCTTopPopverViewControllerDelegate

#pragma mark 工具箱
- (void)toolboxBtnsClick:(UIButton*)sender
{
    if (sender.tag == 0)
    {
        [self.topbarPopoverView dismissViewControllerAnimated:YES completion:^{
            self.topSelectBtn.selected = NO;
        }];
        
        [self.liveManager sendSignalingTeacherToAnswerOccupyedCompletion:nil];
    }
    else if (sender.tag == 1)
    {
        //拍照上传
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        // 设置照片来源为相机
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        // 设置进入相机时使用前置或后置摄像头
        imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        // 展示选取照片控制器
        [self.topbarPopoverView dismissViewControllerAnimated:YES completion:^{
            self.topSelectBtn.selected = NO;
            [self presentViewController:imagePickerController animated:YES completion:nil];
        }];
        
    }
    else if (sender.tag == 2)
    {
        //相册上传
        [self openTheImagePickerWithImageUseType:SCUploadImageUseType_Document];
    }
    else if (sender.tag == 3)
    {
        //计时器
        
        [self.topbarPopoverView dismissViewControllerAnimated:YES completion:^{
            self.topSelectBtn.selected = NO;
        }];
        [self.liveManager sendSignalingTeacherToStartTimerWithTime:300 isStatus:false isRestart:false isShow:false defaultTime:300 completion:nil];
        
    }
    else if (sender.tag == 4)
    {
        //抢答器
        [self.topbarPopoverView dismissViewControllerAnimated:YES completion:^{
            self.topSelectBtn.selected = NO;
        }];

        self.responderView = [[YSTeacherResponder alloc] init];
        [self.responderView showYSTeacherResponderType:YSTeacherResponderType_Start inView:self.view backgroundEdgeInsets:UIEdgeInsetsZero topDistance:0];
        [self.responderView showResponderWithType:YSTeacherResponderType_Start];
        self.responderView.delegate = self;
//        [self.responderView setPersonNumber:@"7" totalNumber:@"16"];//用于传人数
//        [self.responderView setPersonName:@"宁杰英"];
    }
}


#pragma mark 全局控制
- (void)allControlBtnsClick:(UIButton*)sender
{
    sender.selected = !sender.selected;
    if (sender.tag == 0)
    {
        if (sender.selected)
        {
            // 全体静音
            [self.liveManager sendSignalingTeacherToLiveAllNoAudioCompletion:nil];
        }
        else
        {
            // 全体发言
            [self.liveManager deleteSignalingTeacherToLiveAllNoAudioCompletion:nil];
        }
    }
    else if (sender.tag == 1)
    {

        if (sender.selected)
        {
            // 全体禁言
            [self.liveManager sendSignalingTeacherToLiveAllNoChatSpeakingCompletion:nil];
        }
        else
        {
            // 解除禁言
            [self.liveManager deleteSignalingTeacherToLiveAllNoChatSpeakingCompletion:nil];
        }
    }
    else if (sender.tag == 2)
    {
        // 全体奖杯
        for (SCVideoView *videoView in self.videoViewArray)
        {
            YSRoomUser *user = videoView.roomUser;
            
            if (user.role == YSUserType_Student)
            {
                [self sendGiftWithRreceiveRoomUser:user];
            }
        }

    }
    else if (sender.tag == 3)
    {
        // 全体复位
        for (YSRoomUser * user in [YSLiveManager shareInstance].userList)
        {
            NSDictionary * data = @{
                @"isDrag":@0,
                @"userId":user.peerID
            };
            [self.liveManager sendSignalingToDragOutVideoViewWithData:data];
            
        }
    }
}


#pragma mark -
#pragma mark 答题卡占位

- (void)handleSignalingAnswerOccupyedWithAnswerId:(NSString *)answerId startTime:(NSInteger)startTime
{
    BMWeakSelf
    //答题器
    self.answerView = [[SCTeacherAnswerView alloc] init];
    [self.answerView showTeacherAnswerViewType:SCTeacherAnswerViewType_AnswerPub inView:self.view backgroundEdgeInsets:UIEdgeInsetsZero topDistance:0];
    self.answerView.submitBlock = ^(NSArray * _Nonnull submitArr) {
            
        [weakSelf.liveManager sendSignalingTeacherToAnswerWithOptions:submitArr answerID:answerId completion:nil];
    
    };
    
    self.answerView.closeBlock = ^(BOOL isAnswerIng) {
        [weakSelf.liveManager sendSignalingTeacherToDeleteAnswerWithAnswerID:answerId completion:nil];
    };
}
#pragma mark 收到答题卡
- (void)handleSignalingSendAnswerWithAnswerId:(NSString *)answerId options:(NSArray *)options startTime:(NSInteger)startTime
{
    _isOpenResult = NO;
    _answerStartTime = startTime;
    if (!answerId)
    {
        return;
    }
    self.answerStatistics = [NSMutableDictionary dictionaryWithCapacity:0];
    NSString *rightResult = @"";
    for (int i = 0; i < options.count ; i++) {
        NSDictionary *dic = options[i];
        NSUInteger isRight = [dic bm_intForKey:@"isRight"];
        NSString *content = [dic bm_stringForKey:@"content"];
        if (isRight == 1)
        {
            rightResult = [rightResult stringByAppendingFormat:@"%@,",content];
        }
        [self.answerStatistics setValue:@"0" forKey:content];
    }
    
    if ([rightResult bm_isNotEmpty])
    {
        rightResult = [rightResult substringWithRange:NSMakeRange(0, rightResult.length - 1)];
    }
    self.rightAnswer = rightResult;
    
    if (self.answerView)
    {
        [self.answerView dismiss:nil animated:NO dismissBlock:nil];
    }

    self.answerResultView = [[SCTeacherAnswerView alloc] init];
    [self.answerResultView showTeacherAnswerViewType:SCTeacherAnswerViewType_Statistics inView:self.view backgroundEdgeInsets:UIEdgeInsetsZero topDistance:0];
    self.answerResultView.isAnswerIng = YES;
    BMWeakSelf
    self.answerResultView.detailBlock = ^(SCTeacherAnswerViewType type) {
        /// 切换详情统计
        
        if (type == SCTeacherAnswerViewType_Details)
        {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            weakSelf.answerDetailTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
            
            dispatch_source_set_timer(weakSelf.answerDetailTimer, DISPATCH_TIME_NOW, 5.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
            //3.要调用的任务
            dispatch_source_set_event_handler(weakSelf.answerDetailTimer, ^{
                [weakSelf getAnswerDetailDataWithAnswerID:answerId];
            });
            //4.开始执行
            dispatch_resume(weakSelf.answerDetailTimer);
        }
        else
        {
            if (weakSelf.answerDetailTimer)
            {
                dispatch_source_cancel(weakSelf.answerDetailTimer);
            }
        }
    };
    
    self.answerResultView.endBlock = ^(BOOL isOpen) {
        /// 结束答题  1.删除信令  2.公布答案或者不公布
        ///2.公布答案或者不公布 在结束答题器信令里做判断
        self->_isOpenResult = isOpen;
        if (weakSelf.answerTimer)
        {
            dispatch_source_cancel(weakSelf.answerTimer);
        }
        [weakSelf.liveManager sendSignalingTeacherToAnswerGetResultWithAnswerID:answerId completion:nil];//获取结果
        [weakSelf.liveManager sendSignalingTeacherToDeleteAnswerWithAnswerID:answerId completion:nil];
    };
    
    self.answerResultView.closeBlock = ^(BOOL isAnswerIng) {
      
        if (isAnswerIng)
        {
            [weakSelf.liveManager sendSignalingTeacherToDeleteAnswerWithAnswerID:answerId completion:nil];
        }
        else
        {
            [weakSelf.liveManager sendSignalingTeacherToDeleteAnswerPublicResultCompletion:nil];
        }
 
    };
    
    //先获取一次结果
    [self.liveManager sendSignalingTeacherToAnswerGetResultWithAnswerID:answerId completion:nil];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.answerTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(self.answerTimer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    //3.要调用的任务
    dispatch_source_set_event_handler(self.answerTimer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self answer_countDownTime:nil answerID:answerId];
        });
    });
    //4.开始执行
    dispatch_resume(self.answerTimer);
}

#pragma mark 答题器 定时操作
- (void)answer_countDownTime:(NSTimer *)timer answerID:(NSString *)answerID
{

    NSTimeInterval time = self.liveManager.tCurrentTime - _answerStartTime;
    
    if ((int)time % 5 == 0)
    {
        [self.liveManager sendSignalingTeacherToAnswerGetResultWithAnswerID:answerID completion:nil];
    }
    NSString *str =  [NSDate bm_countDownENStringDateFromTs:time];
    self.answerResultView.timeStr = str;

}

/// 获取答题中的 详情数据
- (void)getAnswerDetailDataWithAnswerID:(NSString *)answerId
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSMutableURLRequest *request = [YSLiveApiRequest getSimplifyAnswerCountWithRoomId:self.liveManager.room_Id answerId:answerId startTime:_answerStartTime endTime:self.liveManager.tCurrentTime];
    if (request)
    {
        BMWeakSelf
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[
            @"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript",@"text/xml"
        ]];
        
        NSURLSessionDataTask *task = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error)
            {
                BMLog(@"Error: %@", error);
            }
            else
            {
                BMLog(@"%@--------%@", response,responseObject);
                NSArray *details = [responseObject bm_arrayForKey:@"data"];
                NSMutableArray * detailArr = [NSMutableArray arrayWithCapacity:0];
                for (NSDictionary *dic in details)
                {
                    NSMutableDictionary * tempDic = [NSMutableDictionary dictionaryWithCapacity:0];
                    NSString *userID = [dic bm_stringForKey:@"fromid"];
                    YSRoomUser *user = [weakSelf.liveManager.roomManager getRoomUserWithUId:userID];
                    NSString *userName = user.nickName;
                    NSInteger ts = [dic bm_intForKey:@"ts"];
                    NSTimeInterval time = ts - self->_answerStartTime;
                    NSString *timestr =  [NSDate bm_countDownENStringDateFromTs:time];
                    
                    NSString *data = [dic bm_stringForKey:@"data"];
                    
                    [tempDic setValue:userName forKey:@"studentname"];
                    [tempDic setValue:timestr forKey:@"timestr"];
                    [tempDic setValue:data forKey:@"selectOpts"];
                    [tempDic setValue:userID forKey:@"userId"];
                    [detailArr addObject:tempDic];
                }
                weakSelf.answerResultView.answerDetailArr = detailArr ;
                if (self->_isOpenResult)
                {
                    /// 处理发布答案
                    [weakSelf publishAnswerResultWithDetailData:detailArr answerID:answerId];
                }
            }
        }];
        [task resume];
    }
}

/// 发布答案
- (void)publishAnswerResultWithDetailData:(NSArray *)detailData answerID:(NSString *)answerId
{
    NSTimeInterval time = self.liveManager.tCurrentTime - _answerStartTime;
    NSString *duration =  [NSDate bm_countDownENStringDateFromTs:time];
    [self.liveManager sendSignalingTeacherToAnswerPublicResultWithAnswerID:answerId selecteds:self.answerStatistics duration:duration detailData:detailData totalUsers:_totalUsers completion:nil];
}

///收到答题中的统计结果
- (void)handleSignalingTeacherAnswerGetResultWithAnswerId:(NSString *)answerId totalUsers:(NSInteger)totalUsers values:(nonnull NSDictionary *)values
{
    BMLog(@"%@",answerId);
    _totalUsers = totalUsers;
    for (NSString *key in values)
    {
        [self.answerStatistics setValue:values[key] forKey:key];
    }
    if (_isOpenResult)
    {
        //为了处理公布答案的情况
        [self getAnswerDetailDataWithAnswerID:answerId ];
        return;
    }
    
    [self.answerResultView setAnswerStatistics:self.answerStatistics totalUsers:totalUsers rightResult:self.rightAnswer];
}

/// 答题结束
- (void)handleSignalingAnswerEndWithAnswerId:(NSString *)answerId
{
    if (self.answerTimer)
    {
         dispatch_source_cancel(self.answerTimer);
    }
    
    if (self.answerDetailTimer)
    {
         dispatch_source_cancel(self.answerDetailTimer);
    }
}

/// 答题结果
- (void)handleSignalingAnswerPublicResultWithAnswerId:(NSString *)answerId resault:(NSDictionary *)resault durationStr:(NSString *)durationStr answers:(NSArray *)answers totalUsers:(NSUInteger)totalUsers
{
    self.answerResultView.isAnswerIng = NO;
    [self.answerResultView setAnswerResultWithStaticsDic:resault detailArr:answers duration:durationStr rightOption:self.rightAnswer totalUsers:totalUsers];
    BMWeakSelf
    self.answerResultView.againBlock = ^{
        [weakSelf.answerResultView dismiss:nil animated:NO dismissBlock:nil];
        // 删除答题结果信令
        [weakSelf.liveManager sendSignalingTeacherToDeleteAnswerPublicResultCompletion:nil];
        // 重新开始
        [weakSelf.liveManager sendSignalingTeacherToAnswerOccupyedCompletion:nil];
    };
}

/// 答题结果关闭
- (void)handleSignalingDelAnswerResultWithAnswerId:(NSString *)answerId
{
    [[BMNoticeViewStack sharedInstance] closeAllNoticeViews];
    if (self.answerTimer)
    {
         dispatch_source_cancel(self.answerTimer);
    }
    
    if (self.answerDetailTimer)
    {
         dispatch_source_cancel(self.answerDetailTimer);
    }
}

#pragma mark -
///全体静音 发言
- (void)handleSignalingToliveAllNoAudio:(BOOL)noAudio
{
    
}


#pragma mark -
#pragma mark 抢答器 YSTeacherResponderDelegate
- (void)startClickedWithUpPlatform:(BOOL)upPlatform
{
    autoUpPlatform = upPlatform;
    BMWeakSelf
    [self.liveManager sendSignalingTeacherToStartResponderCompletion:nil];
    contestCommitNumber = 0;
    contestPeerId = @"";
    [[BMCountDownManager manager] startCountDownWithIdentifier:YSTeacherResponderCountDownKey timeInterval:10 processBlock:^(id  _Nonnull identifier, NSInteger timeInterval, BOOL forcedStop) {
        BMLog(@"%ld", (long)timeInterval);
        [weakSelf.responderView showResponderWithType:YSTeacherResponderType_ING];
      
        NSInteger total = 0;
        for (YSRoomUser * user in weakSelf.liveManager.userList)
        {
            if (user.role == YSUserType_Student)
            {
                total++;
            }
        }
        NSString *totalNumber = [NSString stringWithFormat:@"%@",@(total)];
        [weakSelf.responderView setPersonNumber:[NSString stringWithFormat:@"%@",@(self->contestCommitNumber)] totalNumber:totalNumber];//用于传人数
//        [weakSelf.responderView setPersonName:@"宁杰英"];
        CGFloat progress = (10 - timeInterval) / 10.0f;
        [weakSelf.responderView setProgress:progress];
        if (timeInterval == 0)
        {
            [weakSelf.responderView showResponderWithType:YSTeacherResponderType_Result];
            NSInteger total = 0;
            for (YSRoomUser * user in weakSelf.liveManager.userList)
            {
                if (user.role == YSUserType_Student)
                {
                    total++;
                }
            }
            NSString *totalNumber = [NSString stringWithFormat:@"%@",@(total)];
            [weakSelf.responderView setPersonNumber:[NSString stringWithFormat:@"%@",@(self->contestCommitNumber)] totalNumber:totalNumber];;//用于传人数
            CGFloat progress = 1.0f;
            [weakSelf.responderView setProgress:progress];
            
            if (self->contestCommitNumber == 0)
            {
                [weakSelf.responderView setPersonName:YSLocalized(@"Res.lab.fail")];
                
                [weakSelf.liveManager sendSignalingTeacherToContestResultWithName:@"" completion:nil];
            }
            if (self->contestCommitNumber > 0)
            {
                YSRoomUser *user = [self.liveManager.roomManager getRoomUserWithUId:self->contestPeerId];
                [weakSelf.responderView setPersonName:user.nickName];
                [weakSelf.liveManager sendSignalingTeacherToContestResultWithName:user.nickName completion:nil];
                if (self->autoUpPlatform && user.publishState == YSUser_PublishState_NONE)
                {
                    [self.liveManager sendSignalingToChangePropertyWithRoomUser:user withKey:sUserPublishstate WithValue:@(YSUser_PublishState_BOTH)];
                }
            }
            
            
        }
    }];
    
}

- (void)againClicked
{
    [self.responderView showResponderWithType:YSTeacherResponderType_Start];
    [self.responderView setProgress:0.0f];
    autoUpPlatform = NO;
}

- (void)teacherResponderCloseClicked
{
    [self.liveManager sendSignalingTeacherToCloseResponderCompletion:nil];
    [[BMCountDownManager manager] stopCountDownIdentifier:YSTeacherResponderCountDownKey];
}

- (void)handleSignalingContestCommitWithData:(NSDictionary *)data
{
    contestCommitNumber++;
    NSInteger total = 0;
    for (YSRoomUser * user in self.liveManager.userList)
    {
        if (user.role == YSUserType_Student)
        {
            total++;
        }
    }
    NSString *totalNumber = [NSString stringWithFormat:@"%@",@(total)];

    [self.responderView setPersonNumber:[NSString stringWithFormat:@"%@",@(contestCommitNumber)] totalNumber:totalNumber];
    if (contestCommitNumber == 1)
    {
        NSString *peerID = [data bm_stringForKey:@"peerId"];
        contestPeerId = peerID;
    }

}


#pragma mark -
#pragma mark 计时器信令

- (void)handleSignalingTeacherTimerShow
{
    
    if (self.teacherTimerView)
    {
        [self.teacherTimerView dismiss:nil animated:NO dismissBlock:nil];
    }
    self.teacherTimerView  = [[YSTeacherTimerView alloc] init];
    [self.teacherTimerView showYSTeacherTimerViewInView:self.view
                                   backgroundEdgeInsets:UIEdgeInsetsZero
                                            topDistance:0];
    [self.teacherTimerView showResponderWithType:YSTeacherTimerViewType_Start];
    self.teacherTimerView.delegate = self;
}

-(void)handleSignalingTimerWithTime:(NSInteger)time pause:(BOOL)pause defaultTime:(NSInteger)defaultTime
{
    timer_defaultTime = defaultTime;

    playerFirst = 0;
    if (!self.teacherTimerView)
    {
        self.teacherTimerView  = [[YSTeacherTimerView alloc] init];
        [self.teacherTimerView showYSTeacherTimerViewInView:self.view
                                       backgroundEdgeInsets:UIEdgeInsetsZero
                                                topDistance:0];
        self.teacherTimerView.delegate = self;

    }
    [[BMCountDownManager manager] stopCountDownIdentifier:YSTeacherTimerCountDownKey];
    if (!pause)
    {
        self.teacherTimerView.pauseBtn.selected = YES;

        BMWeakSelf
        [[BMCountDownManager manager] startCountDownWithIdentifier:YSTeacherTimerCountDownKey timeInterval:time processBlock:^(id  _Nonnull identifier, NSInteger timeInterval, BOOL forcedStop) {
            BMLog(@"%ld", (long)timeInterval);
            [weakSelf.teacherTimerView showResponderWithType:YSTeacherTimerViewType_Ing];
            [weakSelf.teacherTimerView showTimeInterval:timeInterval];
            if (playerFirst == 1)
            {
                return;
            }
            if (timeInterval == 0)
            {
                playerFirst = 1;
                [weakSelf.teacherTimerView showResponderWithType:YSTeacherTimerViewType_End];
                NSBundle *bundle = [NSBundle bundleWithPath: [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"YSResources.bundle"]];
                NSString *filePath = [[bundle resourcePath] stringByAppendingPathComponent:@"timer_default.wav"];;
                if (filePath)
                {
                    weakSelf.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:filePath] error:nil];
                    //                    self.player.delegate = self;
                    [weakSelf.player setVolume:1.0];
                    if (playerFirst == 0)
                    {
                        [weakSelf.player play];
                        playerFirst = 1;
                    }
                }
            }
        }];

        [[BMCountDownManager manager] pauseCountDownIdentifier:YSTeacherTimerCountDownKey];
    }
    else
    {
        self.teacherTimerView.pauseBtn.selected = NO;
        if (time == 0)
        {
            [self.teacherTimerView showResponderWithType:YSTeacherTimerViewType_End];
        }
        BMWeakSelf
        [[BMCountDownManager manager] startCountDownWithIdentifier:YSTeacherTimerCountDownKey timeInterval:time processBlock:^(id  _Nonnull identifier, NSInteger timeInterval, BOOL forcedStop) {
            BMLog(@"%ld", (long)timeInterval);
            [weakSelf.teacherTimerView showResponderWithType:YSTeacherTimerViewType_Ing];
            [weakSelf.teacherTimerView showTimeInterval:timeInterval];
            
 
            if (timeInterval == 0)
            {
                
                [weakSelf.teacherTimerView showResponderWithType:YSTeacherTimerViewType_End];
                
                NSBundle *bundle = [NSBundle bundleWithPath: [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"YSResources.bundle"]];
                NSString *filePath = [[bundle resourcePath] stringByAppendingPathComponent:@"timer_default.wav"];
                if (filePath)
                {
                    weakSelf.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:filePath] error:nil];
                    //                    self.player.delegate = self;
                    [weakSelf.player setVolume:1.0];
                    if (playerFirst == 0)
                    {
                        [weakSelf.player play];
                        playerFirst = 1;
                    }
                    
                }

            }
        }];
    }
}

/// 收到暂停信令
-(void)handleSignalingPauseTimerWithTime:(NSInteger)time defaultTime:(NSInteger)defaultTime
{
    timer_defaultTime = defaultTime;
    playerFirst = 0;
    if (!self.teacherTimerView)
    {
        self.teacherTimerView  = [[YSTeacherTimerView alloc] init];
        [self.teacherTimerView showYSTeacherTimerViewInView:self.view
                                       backgroundEdgeInsets:UIEdgeInsetsZero
                                                topDistance:0];
        self.teacherTimerView.delegate = self;
        [self.teacherTimerView showResponderWithType:YSTeacherTimerViewType_Ing];
//        self.teacherTimerView.pauseBtn.selected = YES;
        self.teacherTimerView.pauseBtn.selected = YES;
    }
    if (time == 0)
    {
        [self.teacherTimerView showResponderWithType:YSTeacherTimerViewType_End];
    }
    BMWeakSelf
    [[BMCountDownManager manager] startCountDownWithIdentifier:YSTeacherTimerCountDownKey timeInterval:time processBlock:^(id  _Nonnull identifier, NSInteger timeInterval, BOOL forcedStop) {
        BMLog(@"%ld", (long)timeInterval);
        [weakSelf.teacherTimerView showTimeInterval:timeInterval];
        if (timeInterval == 0)
        {
            [weakSelf.teacherTimerView showResponderWithType:YSTeacherTimerViewType_End];
            NSBundle *bundle = [NSBundle bundleWithPath: [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"YSResources.bundle"]];
            NSString *filePath = [[bundle resourcePath] stringByAppendingPathComponent:@"timer_default.wav"];;
            if (filePath)
            {
                weakSelf.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:filePath] error:nil];
                //                    self.player.delegate = self;
                [weakSelf.player setVolume:1.0];
                if (playerFirst == 0)
                {
                    [weakSelf.player play];
                    playerFirst = 1;
                }

            }
        }
    }];

    [[BMCountDownManager manager] pauseCountDownIdentifier:YSTeacherTimerCountDownKey];
}
/// 收到继续信令
- (void)handleSignalingContinueTimerWithTime:(NSInteger)time defaultTime:(NSInteger)defaultTime
{
    playerFirst = 0;
    if (time == 0)
    {
        [self.teacherTimerView showResponderWithType:YSTeacherTimerViewType_End];
    }
    timer_defaultTime = defaultTime;
    if (!self.teacherTimerView)
    {
        self.teacherTimerView  = [[YSTeacherTimerView alloc] init];
        [self.teacherTimerView showYSTeacherTimerViewInView:self.view
                                       backgroundEdgeInsets:UIEdgeInsetsZero
                                                topDistance:0];
        self.teacherTimerView.delegate = self;
        [self.teacherTimerView showResponderWithType:YSTeacherTimerViewType_Ing];
        self.teacherTimerView.pauseBtn.selected = NO;
    }
    BMWeakSelf
    [[BMCountDownManager manager] startCountDownWithIdentifier:YSTeacherTimerCountDownKey timeInterval:time processBlock:^(id  _Nonnull identifier, NSInteger timeInterval, BOOL forcedStop) {
        BMLog(@"%ld", (long)timeInterval);
        
        [weakSelf.teacherTimerView showTimeInterval:timeInterval];
//        weakSelf.teacherTimerView.pauseBtn.selected = YES;
        if (timeInterval == 0)
        {
            [weakSelf.teacherTimerView showResponderWithType:YSTeacherTimerViewType_End];
            NSBundle *bundle = [NSBundle bundleWithPath: [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"YSResources.bundle"]];
            NSString *filePath = [[bundle resourcePath] stringByAppendingPathComponent:@"timer_default.wav"];;
            if (filePath)
            {
                weakSelf.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:filePath] error:nil];
                //                    self.player.delegate = self;
                [weakSelf.player setVolume:1.0];
                if (playerFirst == 0)
                {
                    [weakSelf.player play];
                    playerFirst = 1;
                }

            }
        }
    }];

    [[BMCountDownManager manager] continueCountDownIdentifier:YSTeacherTimerCountDownKey];
}


- (void)handleSignalingDeleteTimerWithTime
{
    [self.teacherTimerView showResponderWithType:YSTeacherTimerViewType_Start];
}

#pragma mark -
#pragma mark 计时器代理 YSTeacherTimerViewDelegate
/// 开始
- (void)startWithTime:(NSInteger)time
{
    timer_defaultTime = time;
    [self.liveManager sendSignalingTeacherToStartTimerWithTime:time isStatus:YES isRestart:YES isShow:YES defaultTime:timer_defaultTime completion:nil];
}

/// 暂停继续
- (void)pasueWithTime:(NSInteger)time pasue:(BOOL)pasue
{
    [self.liveManager sendSignalingTeacherToStartTimerWithTime:time isStatus:!pasue isRestart:NO isShow:YES defaultTime:timer_defaultTime completion:nil];
}


/// 计时中重置
- (void)resetWithTIme:(NSInteger)time pasue:(BOOL)pasue
{
    
    [self.liveManager sendSignalingTeacherToStartTimerWithTime:timer_defaultTime isStatus:!pasue isRestart:YES isShow:YES defaultTime:timer_defaultTime completion:nil];;
}

- (void)againTimer
{
    
//    [self.liveManager sendSignalingTeacherToDeleteTimerCompletion:nil];
        
//    [self.liveManager sendSignalingTeacherToStartTimerWithTime:300 isStatus:false isRestart:false isShow:false defaultTime:300 completion:nil];
    [self.teacherTimerView showResponderWithType:YSTeacherTimerViewType_Start];
}

- (void)timerClose
{
    [[BMCountDownManager manager] stopCountDownIdentifier:YSTeacherTimerCountDownKey];

    [self.liveManager sendSignalingTeacherToDeleteTimerCompletion:nil];
}

#pragma mark -
#pragma mark 聊天相关视图

/// 弹出聊天View的按钮
- (UIButton *)chatBtn
{
    if (!_chatBtn)
    {
        self.chatBtn = [[UIButton alloc]initWithFrame:CGRectMake(UI_SCREEN_WIDTH-40-26, UI_SCREEN_HEIGHT-40-2, 40, 40)];
        [self.chatBtn setBackgroundColor: UIColor.clearColor];
        [self.chatBtn setImage:[UIImage imageNamed:@"chat_SmallClassImage"] forState:UIControlStateNormal];
        [self.chatBtn setImage:[UIImage imageNamed:@"chat_SmallClassImage_push"] forState:UIControlStateHighlighted];
        [self.chatBtn addTarget:self action:@selector(chatButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _chatBtn;
}

/// 右侧聊天视图
- (SCChatView *)rightChatView
{
    if (!_rightChatView)
    {
        self.rightChatView = [[SCChatView alloc]initWithFrame:CGRectMake(UI_SCREEN_WIDTH, 0, ChatViewWidth, SCChatViewHeight)];
        BMWeakSelf
        //点击底部输入按钮，弹起键盘
        self.rightChatView.textBtnClick = ^{
            [weakSelf.chatToolView.inputView becomeFirstResponder];
        };
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenTheKeyBoard)];
        [self.rightChatView addGestureRecognizer:tap];
    }
    return _rightChatView;
}

///  聊天输入框工具栏
- (SCChatToolView *)chatToolView
{
    if (!_chatToolView)
    {
        self.chatToolView = [[SCChatToolView alloc]initWithFrame:CGRectMake(0, UI_SCREEN_HEIGHT, UI_SCREEN_WIDTH, SCChatToolHeight)];
        self.chatToolView.inputView.delegate = self;
        BMWeakSelf
        //点击视图收起键盘
        self.rightChatView.clickViewToHiddenTheKeyBoard = ^{
            [weakSelf hiddenTheKeyBoard];
        };
        //输入框中按钮的点击事件
        self.chatToolView.SCChatToolViewButtonsClick = ^(UIButton * _Nonnull sender) {
            if (sender.tag == 2)
            {//选择图片
                [weakSelf hiddenTheKeyBoard];
                [weakSelf openTheImagePickerWithImageUseType:SCUploadImageUseType_Message];
            }
            else
            {//选择表情
                [weakSelf toolEmotionBtnClick:sender];
            }
        };
        [self.view addSubview:self.chatToolView];
    }
    return _chatToolView;
}

/// 表情键盘
- (YSEmotionView *)emotionListView
{
    if (!_emotionListView)
    {
        self.emotionListView = [[YSEmotionView alloc]initWithFrame:CGRectMake(0, UI_SCREEN_HEIGHT, UI_SCREEN_WIDTH, SCChateEmotionHeight)];
        
        BMWeakSelf
        //把表情添加到输入框
        self.emotionListView.addEmotionToTextView = ^(NSString * _Nonnull emotionName) {
            [weakSelf.chatToolView.inputView insertText:[NSString stringWithFormat:@"[%@]",emotionName]];
            // 滚动到可视区域
            [weakSelf.chatToolView.inputView scrollRectToVisible:CGRectMake(0, 0,weakSelf.chatToolView.inputView.contentSize.width , weakSelf.chatToolView.inputView.contentSize.height) animated:YES];
        };
        
        //删除输入框中的表情
        self.emotionListView.deleteEmotionBtnClick = ^{
            [weakSelf.chatToolView.inputView deleteBackward];
        };
        [self.view addSubview:self.emotionListView];
    }
    [self.view bringSubviewToFront:_emotionListView];
    return _emotionListView;
}

#pragma mark -
#pragma mark 聊天相关点击事件


///聊天按钮点击事件
- (void)chatButtonClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    [self.chatBtn setImage:[UIImage imageNamed:@"chat_SmallClassImage"] forState:UIControlStateNormal];
    [self.chatBtn setImage:[UIImage imageNamed:@"chat_SmallClassImage_push"] forState:UIControlStateHighlighted];
    
    CGRect tempRect = self.rightChatView.frame;
    if (sender.selected)
    {//弹出
        tempRect.origin.x = UI_SCREEN_WIDTH-tempRect.size.width;
        
        
        //收回 课件表 以及 花名册
        [self freshListViewWithSelect:NO];
        if (self.topSelectBtn.tag == SCTeacherTopBarTypePersonList || self.topSelectBtn.tag == SCTeacherTopBarTypeCourseware)
        {
            self.topSelectBtn.selected = NO;
        }
    }
    else
    {//收回
        tempRect.origin.x = UI_SCREEN_WIDTH;
    }
    [UIView animateWithDuration:0.25 animations:^{
        self.rightChatView.frame = tempRect;
    }];
    
    [self arrangeAllViewInVCView];
}

///输入框条上表情按钮的点击事件
- (void)toolEmotionBtnClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    [self.chatToolView endEditing:YES];
    if (sender.selected)
    {
        [UIView animateWithDuration:0.25 animations:^{
            self.chatToolView.bm_originY = self.view.bm_height-SCChateEmotionHeight-SCChatToolHeight;
            self.emotionListView.bm_originY = self.view.bm_height-SCChateEmotionHeight;
        }];
    }
    sender.selected = !sender.selected;
}

#pragma mark - 聊天消息接收 _ 小班课

- (void)handleMessageWith:(YSChatMessageModel *)message
{
    if (!self.chatBtn.selected && message.chatMessageType != YSChatMessageTypeTips) {
        [self.chatBtn setImage:[UIImage imageNamed:@"chat_newMsg_SmallClassImage"] forState:UIControlStateNormal];
        [self.chatBtn setImage:[UIImage imageNamed:@"chat_newMsg_SmallClassImage_push"] forState:UIControlStateHighlighted];
    }
    
    [self.rightChatView.SCMessageList addObject:message];
    [self.rightChatView.SCChatTableView reloadData];
    
    if (self.rightChatView.SCMessageList.count)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.rightChatView.SCMessageList.count-1 inSection:0];
        [self.rightChatView.SCChatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

#pragma mark - 键盘通知方法

- (void)keyboardWillShow:(NSNotification*)notification
{
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardF = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.keyBoardH = keyboardF.size.height;//竖屏： 292   横屏 ：232
    
    UIView *firstResponder = [self.view bm_firstResponder];
    
    if (firstResponder.tag == PlaceholderPTag)
    {//调用聊天键盘
        [UIView animateWithDuration:duration animations:^{
            self.chatToolView.bm_originY = self.view.bm_height-keyboardF.size.height-SCChatToolHeight;
            self.emotionListView.bm_originY = self.view.bm_height;
        }];
        self.chatToolView.emojBtn.selected = NO;
    }
    else if (firstResponder.tag == YSWHITEBOARD_TEXTVIEWTAG)
    {//调用白板键盘
        [UIView animateWithDuration:duration animations:^{
            self.chatToolView.bm_originY = self.view.bm_height;
            self.emotionListView.bm_originY = self.view.bm_height;
        }];

        CGPoint relativePoint = [firstResponder convertPoint:CGPointZero toView:[UIApplication sharedApplication].keyWindow];
        CGFloat keyboardHeight = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
        CGFloat actualHeight = CGRectGetHeight(firstResponder.frame)*self.boardControlView.zoomScale + relativePoint.y + keyboardHeight;
        CGFloat overstep = actualHeight - CGRectGetHeight([UIScreen mainScreen].bounds);// + 5;
        if (overstep > 1)
        {
            CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
            CGRect frame = [UIScreen mainScreen].bounds;
            frame.origin.y -= overstep;
            [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear animations: ^{
                [UIApplication sharedApplication].keyWindow.frame = frame;
            } completion:nil];
        }
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    double duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    if (self.chatToolView.emojBtn.selected)
    {
        [UIView animateWithDuration:0.25 animations:^{
            self.chatToolView.bm_originY = self.view.bm_height-SCChateEmotionHeight-SCChatToolHeight;
            self.emotionListView.bm_originY = self.view.bm_height-SCChateEmotionHeight;
        }];
    }
    else
    {
        [UIView animateWithDuration:duration animations:^{
            self.chatToolView.bm_originY = self.view.bm_height;
            self.emotionListView.bm_originY = self.view.bm_height;
        }];
    }
    
    CGRect frame = [UIScreen mainScreen].bounds;
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear animations: ^{
        [UIApplication sharedApplication].keyWindow.frame = frame;
    } completion:nil];
}

- (void)hiddenTheKeyBoard
{
    [self.view endEditing:YES];
    [UIView animateWithDuration:0.25 animations:^{
        self.chatToolView.bm_originY = self.view.bm_height;
        self.emotionListView.bm_originY = self.view.bm_height;
    }];
}

///全体禁言
- (void)handleSignalingToDisAbleEveryoneBanChatWithIsDisable:(BOOL)isDisable
{
    self.rightChatView.allDisabledChat.hidden = !isDisable;
    self.rightChatView.allDisabledChat.text = YSLocalized(@"Prompt.BanChatInView");
    self.rightChatView.textBtn.hidden = isDisable;
    [self hiddenTheKeyBoard];
}

#pragma mark 重新排列VC.View的图层
- (void)arrangeAllViewInVCView
{
    // 全屏白板
    [self.whitebordFullBackgroud bm_bringToFront];
    
    // mp3f动画
    //    [self.playMp3ImageView bm_bringToFront];
    
    // 笔刷工具
    [self.brushToolView bm_bringToFront];
    
    // 翻页
    [self.boardControlView bm_bringToFront];
    
    // 聊天窗口
    [self.rightChatView bm_bringToFront];
    
    // 聊天按钮
    [self.chatBtn bm_bringToFront];
    
    // 信息输入
    [self.chatToolView bm_bringToFront];
    
    // 全屏MP4 共享桌面
    [self.shareVideoFloatView bm_bringToFront];
    
    [self.mp4ControlView bm_bringToFront];
    [self.closeMp4Btn bm_bringToFront];
    [self.mp3ControlView bm_bringToFront];
    // 所有答题卡按顺序放置最上层
    [[BMNoticeViewStack sharedInstance] bringAllViewsToFront];
}


#pragma mark -
#pragma mark 视频控制popoverView视图

- (YSControlPopoverView *)controlPopoverView
{
    if (!_controlPopoverView)
    {
        self.controlPopoverView = [[YSControlPopoverView alloc]init];
        self.controlPopoverView.modalPresentationStyle = UIModalPresentationPopover;
        self.controlPopoverView.delegate = self;
        self.controlPopoverView.appUseTheType = self.appUseTheType;
    }
    return _controlPopoverView;
}

// 只实现这个代理的话，会有横屏显示不正确的问题。
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}

// 实现下面这个代理方法后，横屏状态下显示正常。解决plus机型横屏显示问题
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller traitCollection:(UITraitCollection *)traitCollection
{
    return UIModalPresentationNone;
}


///点击弹出popoview
- (void)clickViewToControlWithVideoView:(SCVideoView*)videoView
{
    self.selectControlView = videoView;
    
    YSRoomUser * userModel = videoView.roomUser;
    
    SCUserPublishState userPublishState = self.selectControlView.roomUser.liveUserPublishState;
    if (userPublishState == SCUserPublishState_NONE) {
        return;
    }
    
    UIPopoverPresentationController *popover = self.controlPopoverView.popoverPresentationController;
    popover.sourceView = videoView;
    popover.sourceRect = videoView.bounds;
    popover.delegate = self;
    popover.backgroundColor =  [UIColor bm_colorWithHex:0x336CC7];
    self.controlPopoverView.roomLayout = self.roomLayout;
    [self presentViewController:self.controlPopoverView animated:YES completion:nil];///present即可

        
    if (self.roomtype == YSRoomType_One)
    {
        popover.permittedArrowDirections = UIPopoverArrowDirectionRight | UIPopoverArrowDirectionLeft;

        if ([userModel bm_isNotEmpty] && !userModel.role)
        {//老师
            self.controlPopoverView.view.frame = CGRectMake(0, 0, 50, 147);
            self.controlPopoverView.preferredContentSize = CGSizeMake(64, 147);
        }
        else
        {
            self.controlPopoverView.view.frame = CGRectMake(0, 0, 50, 325);
            self.controlPopoverView.preferredContentSize = CGSizeMake(64, 325);
        }
    }
    else if (self.roomtype == YSRoomType_More)
    {
        popover.permittedArrowDirections = UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown;
        
        if (self.appUseTheType == YSAppUseTheTypeMeeting) {
            if (videoView.isDragOut) {
                if ([userModel bm_isNotEmpty] && !userModel.role)
                {//老师
                    self.controlPopoverView.view.frame = CGRectMake(0, 0, 215, 50);
                    self.controlPopoverView.preferredContentSize = CGSizeMake(215, 50);
                }
                else
                {
                    self.controlPopoverView.view.frame = CGRectMake(0, 0, 325, 50);
                    self.controlPopoverView.preferredContentSize = CGSizeMake(325, 50);
                }
            }
            else
            {
                if ([userModel bm_isNotEmpty] && !userModel.role)
                {//老师
                    self.controlPopoverView.view.frame = CGRectMake(0, 0, 147, 50);
                    self.controlPopoverView.preferredContentSize = CGSizeMake(147, 50);
                }
                else
                {
                    self.controlPopoverView.view.frame = CGRectMake(0, 0, 262, 50);
                    self.controlPopoverView.preferredContentSize = CGSizeMake(262, 50);
                }
            }
        }
        else
        {
            if (videoView.isDragOut) {
                if ([userModel bm_isNotEmpty] && !userModel.role)
                {//老师
                    self.controlPopoverView.view.frame = CGRectMake(0, 0, 215, 50);
                    self.controlPopoverView.preferredContentSize = CGSizeMake(215, 50);
                }
                else
                {
                    self.controlPopoverView.view.frame = CGRectMake(0, 0, 388, 50);
                    self.controlPopoverView.preferredContentSize = CGSizeMake(388, 50);
                }
            }
            else
            {
                if ([userModel bm_isNotEmpty] && !userModel.role)
                {//老师
                    self.controlPopoverView.view.frame = CGRectMake(0, 0, 147, 50);
                    self.controlPopoverView.preferredContentSize = CGSizeMake(147, 50);
                }
                else
                {
                    self.controlPopoverView.view.frame = CGRectMake(0, 0, 325, 50);
                    self.controlPopoverView.preferredContentSize = CGSizeMake(325, 50);
                }
            }
        }
    }
    self.controlPopoverView.roomtype = self.roomtype;
    self.controlPopoverView.isDragOut = videoView.isDragOut;
    self.controlPopoverView.userModel = userModel;
}


///老师的控制按钮点击事件
- (void)teacherControlBtnsClick:(UIButton *)sender
{
    SCUserPublishState userPublishState = self.selectControlView.roomUser.liveUserPublishState;
    switch (sender.tag) {
        case 0:
        {//关闭音频
            if (sender.selected)
            {//当前是打开音频状态
                userPublishState &= ~SCUserPublishState_AUDIOONLY;
            }
            else
            {//当前是关闭音频状态
                userPublishState |= SCUserPublishState_AUDIOONLY;
            }
            self.selectControlView.roomUser.liveUserPublishState = userPublishState;
            sender.selected = !sender.selected;
        }
            break;
        case 1:
        {//关闭视频
            if (sender.selected)
            {//当前是打开视频状态
                userPublishState &= ~SCUserPublishState_VIDEOONLY;
            }
            else
            {//当前是关闭视频状态
                userPublishState |= SCUserPublishState_VIDEOONLY;
            }
            self.selectControlView.roomUser.liveUserPublishState = userPublishState;
            sender.selected = !sender.selected;
        }
            break;
        case 2:
        {//视频复位
            NSDictionary * data = @{
                       @"isDrag":@0,
                       @"userId":self.selectControlView.roomUser.peerID
                   };
            [self.liveManager sendSignalingToDragOutVideoViewWithData:data];
            [self.controlPopoverView dismissViewControllerAnimated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}

/// 给用户发送奖杯
- (void)sendGiftWithRreceiveRoomUser:(YSRoomUser *)roomUser
{
    NSString *receiveUserId = roomUser.peerID;
    NSString *receiveUserName = roomUser.nickName;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *roomId = self.liveManager.room_Id;
    NSMutableURLRequest *request = [YSLiveApiRequest sendGiftWithRoomId:roomId sendUserId:self.liveManager.localUser.peerID sendUserName:self.liveManager.localUser.nickName receiveUserId:receiveUserId receiveUserName:receiveUserName];
    if (request)
    {
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[
            @"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript",
            @"text/xml"
        ]];
        
        BMWeakSelf
        NSURLSessionDataTask *task = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error)
            {
                BMLog(@"Error: %@", error);
            }
            else
            {
                NSDictionary *responseDic = [YSLiveUtil convertWithData:responseObject];
                
                if ([responseDic bm_containsObjectForKey:@"result"])
                {
                    NSInteger result = [responseDic bm_intForKey:@"result"];
                    if (result == 0)
                    {
                        NSUInteger giftnumber = [roomUser.properties bm_uintForKey:sUserGiftNumber];
                        [weakSelf.liveManager sendSignalingToChangePropertyWithRoomUser:roomUser withKey:sUserGiftNumber WithValue:@(giftnumber+1)];
                    }
                }
            }
        }];
        
        [task resume];
    }
}

///学生的控制按钮点击事件
- (void)studentControlBtnsClick:(UIButton *)sender
{
    SCUserPublishState userPublishState = self.selectControlView.roomUser.liveUserPublishState;
    switch (sender.tag) {
        case 0:
        {//关闭音频
            if (sender.selected)
            {//当前是打开音频状态
                userPublishState &= ~SCUserPublishState_AUDIOONLY;
            }
            else
            {//当前是关闭音频状态
                userPublishState |= SCUserPublishState_AUDIOONLY;
            }
            self.selectControlView.roomUser.liveUserPublishState = userPublishState;
            sender.selected = !sender.selected;
        }
            break;
        case 1:
        {//关闭视频
            if (sender.selected)
            {//当前是打开视频状态
                userPublishState &= ~SCUserPublishState_VIDEOONLY;
            }
            else
            {//当前是关闭视频状态
                userPublishState |= SCUserPublishState_VIDEOONLY;
            }
            self.selectControlView.roomUser.liveUserPublishState = userPublishState;
            sender.selected = !sender.selected;
        }
            break;
        case 2:
        {// 画笔权限
            
            BOOL candraw = [self.selectControlView.roomUser.properties bm_boolForKey:sUserCandraw];
            // 兼容安卓bool
            bool bCandraw = true;
            if (candraw)
            {
                bCandraw = false;
            }
            BOOL isSucceed = [self.liveManager sendSignalingToChangePropertyWithRoomUser:self.selectControlView.roomUser withKey:sUserCandraw WithValue:@(bCandraw)];
            if (isSucceed)
            {
                sender.selected = !sender.selected;
            }
        }
            break;
        case 3:
        {//下台
            self.selectControlView.roomUser.liveUserPublishState = SCUserPublishState_NONE;
            
            [self.liveManager sendSignalingToChangePropertyWithRoomUser:self.selectControlView.roomUser withKey:sUserCandraw WithValue:@(false)];
            [self.controlPopoverView dismissViewControllerAnimated:YES completion:nil];
            
        }
            break;
        case 4:
        {//发奖杯
            [self sendGiftWithRreceiveRoomUser:self.selectControlView.roomUser];
        }
            break;
        case 5:
        {//视频复位
            NSDictionary * data = @{
                       @"isDrag":@0,
                       @"userId":self.selectControlView.roomUser.peerID
                   };
            [self.liveManager sendSignalingToDragOutVideoViewWithData:data];
            [self.controlPopoverView dismissViewControllerAnimated:YES completion:nil];
        }
            break;
            
        default:
            break;
    }
}


#pragma mark -
#pragma mark SCTeacherListViewDelegate

//上下台
- (void)upPlatformProxyWithRoomUser:(YSRoomUser *)roomUser
{
    BMLog(@"%@",roomUser.nickName);
    if (roomUser.publishState == YSUser_PublishState_NONE)
    {
        if (self.videoViewArray.count < maxVideoCount)
        {
            [self.liveManager sendSignalingToChangePropertyWithRoomUser:roomUser withKey:sUserPublishstate WithValue:@(YSUser_PublishState_BOTH)];
        }
        else
        {
            [BMProgressHUD bm_showHUDAddedTo:self.view animated:YES withText:YSLocalized(@"Error.UpPlatformMemberOverRoomLimit") delay:PROGRESSBOX_DEFAULT_HIDE_DELAY];
            [self freshTeacherPersonListData];
        }
    }
    else
    {
        [self.liveManager.roomManager changeUserProperty:roomUser.peerID tellWhom:YSRoomPubMsgTellAll data:@{sUserPublishstate : @(YSUser_PublishState_NONE),sUserCandraw : @(false)} completion:nil];
    }
}

//禁言
- (void)speakProxyWithRoomUser:(YSRoomUser *)roomUser
{
//    if ([roomUser.properties bm_containsObjectForKey:sUserDisablechat])
//    {
        BOOL disablechat = [roomUser.properties bm_boolForKey:sUserDisablechat];
        [self.liveManager sendSignalingToChangePropertyWithRoomUser:roomUser withKey:sUserDisablechat WithValue:@(!disablechat)];
//    }
}

// 踢出
- (void)outProxyWithRoomUser:(YSRoomUser *)roomUser
{
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:YSLocalized(@"Permissions.notice") message:YSLocalized(@"Permissions.KickedOutMembers") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confimAc = [UIAlertAction actionWithTitle:YSLocalized(@"Prompt.OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[YSRoomInterface instance] evictUser:roomUser.peerID evictReason:@(1) completion:nil];

    }];
    UIAlertAction *cancleAc = [UIAlertAction actionWithTitle:YSLocalized(@"Prompt.Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertVc addAction:cancleAc];
    [alertVc addAction:confimAc];
    [self presentViewController:alertVc animated:YES completion:nil];
}
/// 删除课件
- (void)deleteCoursewareProxyWithFileModel:(YSFileModel *)fileModel
{
    BMWeakSelf
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:YSLocalized(@"Permissions.notice") message:YSLocalized(@"Prompt.delClassFile") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confimAc = [UIAlertAction actionWithTitle:YSLocalized(@"Prompt.OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf.liveManager sendSignalingTeacherToDeleteDocumentWithFile:fileModel completion:nil];
        [weakSelf deleteCoursewareWithFileID:fileModel.fileid];

    }];
    UIAlertAction *cancleAc = [UIAlertAction actionWithTitle:YSLocalized(@"Prompt.Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertVc addAction:cancleAc];
    [alertVc addAction:confimAc];
    [self presentViewController:alertVc animated:YES completion:nil];
    
}
- (void)deleteCoursewareWithFileID:(NSString *)fileid
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSMutableURLRequest *request = [YSLiveApiRequest deleteCoursewareWithRoomId:self.liveManager.room_Id fileId:fileid];
    if (request)
    {

        manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[
            @"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript",@"text/xml"
        ]];
        
        NSURLSessionDataTask *task = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error)
            {
                BMLog(@"Error: %@", error);
            }
            else
            {
                BMLog(@"%@--------%@", response,responseObject);
            }
        }];
        [task resume];
    }
}
/// 课件点击
- (void)selectCoursewareProxyWithFileModel:(YSFileModel *)fileModel
{
    if (self.liveManager.playMediaModel)
    {
        if ([self.liveManager.playMediaModel.fileid isEqualToString:fileModel.fileid])
        {
            isMediaPause = !isMediaPause;
            [self.liveManager.roomManager pauseMediaFile:isMediaPause];
            [self freshTeacherCoursewareListDataWithPlay:!isMediaPause];
            self.mp3ControlView.playBtn.selected = isMediaPause;
            return;
        }

        [self.liveManager.roomManager stopShareMediaFile:nil];
    }
    [self.liveManager sendSignalingTeacherToSwitchDocumentWithFile:fileModel completion:nil];

}

///收回列表
- (void)tapGestureBackListView
{
    [self freshListViewWithSelect:NO];
    if (self.topSelectBtn.tag == SCTeacherTopBarTypePersonList || self.topSelectBtn.tag == SCTeacherTopBarTypeCourseware)
    {
        self.topSelectBtn.selected = NO;
    }
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate
// 完成图片的选取后调用的方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // 选取完图片后跳转回原控制器
    [picker dismissViewControllerAnimated:YES completion:nil];
    /* 此处参数 info 是一个字典，下面是字典中的键值 （从相机获取的图片和相册获取的图片时，两者的info值不尽相同）
     * UIImagePickerControllerMediaType; // 媒体类型
     * UIImagePickerControllerOriginalImage; // 原始图片
     * UIImagePickerControllerEditedImage; // 裁剪后图片
     * UIImagePickerControllerCropRect; // 图片裁剪区域（CGRect）
     * UIImagePickerControllerMediaURL; // 媒体的URL
     * UIImagePickerControllerReferenceURL // 原件的URL
     * UIImagePickerControllerMediaMetadata // 当数据来源是相机时，此值才有效
     */
    // 从info中将图片取出，并加载到imageView当中
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [YSLiveApiRequest uploadImageWithImage:image withImageUseType:SCUploadImageUseType_Document success:^(NSDictionary * _Nonnull dict) {
        
        [self sendWhiteBordImageWithDic:dict];
        
    } failure:^(NSInteger errorCode) {
#if DEBUG
        [BMProgressHUD bm_showHUDAddedTo:self.view animated:YES withText:[NSString stringWithFormat:@"%@,code:%@",YSLocalized(@"UploadPhoto.Error"),@(errorCode)]];
#else
        [BMProgressHUD bm_showHUDAddedTo:self.view animated:YES withText:YSLocalized(@"UploadPhoto.Error")];
#endif
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [BMProgressHUD bm_hideHUDForView:self.view animated:YES];
        });
    }];
    
}

// 取消选取调用的方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    self.topSelectBtn.selected = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -
#pragma mark SCBoardControlViewDelegate 白板翻页控件

/// 全屏 复原 回调
- (void)boardControlProxyfullScreen:(BOOL)isAllScreen
{
    [self.boardControlView resetBtnStates];
    if (isAllScreen)
    {
        [self.view endEditing:YES];
        
//        [self.whitebordBackgroud bm_removeAllSubviews];
        
        [self.whiteBordView removeFromSuperview];
        
        self.whitebordFullBackgroud.hidden = NO;
//        self.whitebordFullBackgroud.backgroundColor = [UIColor redColor];
        // 加载白板
        [self.whitebordFullBackgroud addSubview:self.whiteBordView];
        self.whiteBordView.frame = self.whitebordFullBackgroud.bounds;
        [self arrangeAllViewInVCView];
    }
    else
    {
//        [self.whitebordFullBackgroud bm_removeAllSubviews];
        [self.whiteBordView removeFromSuperview];
        self.whitebordFullBackgroud.hidden = YES;
        
        [self.whitebordBackgroud addSubview:self.whiteBordView];
        self.whiteBordView.frame = self.whitebordBackgroud.bounds;
        
        [self arrangeAllViewInWhiteBordBackgroud];
        //        [self freshContentView];
    }
    
    [self.liveManager.whiteBoardManager refreshWhiteBoard];
    
    [self.liveManager.whiteBoardManager whiteBoardResetEnlarge];
}

- (void)arrangeAllViewInWhiteBordBackgroud
{
    for (YSFloatView *floatView in self.dragOutFloatViewArray)
    {
        [floatView bm_bringToFront];
    }
}
/// 上一页
- (void)boardControlProxyPrePage
{
    //- (void)whiteBoardPrePage;
    [self.liveManager.whiteBoardManager whiteBoardPrePage];
}

/// 下一页
- (void)boardControlProxyNextPage
{
    //- (void)whiteBoardNextPage;
    [self.liveManager.whiteBoardManager whiteBoardNextPage];
}

/// 放大
- (void)boardControlProxyEnlarge
{
    //    - (void)whiteBoardEnlarge;
    [self.liveManager.whiteBoardManager whiteBoardEnlarge];
}

/// 缩小
- (void)boardControlProxyNarrow
{
    //- (void)whiteBoardNarrow;
    [self.liveManager.whiteBoardManager whiteBoardNarrow];
}

#pragma mark -
#pragma mark SCBrushToolViewDelegate

- (void)toolBtnClickedSeleted:(BOOL)seleted
{
    if (!seleted)
    {
        self.drawBoardView.hidden = YES;
    }
}

- (void)brushToolViewType:(YSBrushToolType)toolViewBtnType withToolBtn:(nonnull UIButton *)toolBtn
{
    [self.liveManager.whiteBoardManager brushToolsDidSelect:toolViewBtnType];

    if (self.drawBoardView)
    {
        [self.drawBoardView removeFromSuperview];
    }
    self.drawBoardView = [[SCDrawBoardView alloc] init];
    self.drawBoardView.delegate = self;
    self.drawBoardView.brushToolType = toolViewBtnType;
    [self.view addSubview:self.drawBoardView];
    
    BMWeakSelf
    //小三角
    [self.drawBoardView.triangleImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.brushToolView.mas_right);
        make.centerY.mas_equalTo(toolBtn.mas_centerY);
        make.width.mas_equalTo(13);
        make.height.mas_equalTo(28);
    }];
    
    switch (toolViewBtnType) {
        case YSBrushToolTypeMouse:
            //鼠标
            break;
        case YSBrushToolTypeLine:
        { //笔 划线
            [self.drawBoardView.backgroundView  mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(weakSelf.drawBoardView.triangleImgView.mas_right).offset(-2);
                make.centerY.mas_equalTo(toolBtn.mas_centerY);
            }];
        }
            break;
        case YSBrushToolTypeText:
        { // 文字
            [self.drawBoardView.backgroundView  mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(weakSelf.drawBoardView.triangleImgView.mas_right).offset(-2);
                make.centerY.mas_equalTo(toolBtn.mas_centerY);
            }];
        }
            break;
        case YSBrushToolTypeShape:
        {    // 形状
            [self.drawBoardView.backgroundView  mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(weakSelf.drawBoardView.triangleImgView.mas_right).offset(-2);
                make.centerY.mas_equalTo(toolBtn.mas_centerY ).offset(-40);
            }];
        }
            break;
        case YSBrushToolTypeEraser:
        {    //橡皮擦
            [self.drawBoardView.backgroundView  mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(weakSelf.drawBoardView.triangleImgView.mas_right).offset(-2);
                make.centerY.mas_equalTo(toolBtn.mas_centerY).offset(-10);
                
            }];
        }
            break;
        default:
            break;
    }
    //    self.drawBoardView.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT);
}

- (void)brushToolDoClean
{
    [self.liveManager.whiteBoardManager didSelectDrawType:YSDrawTypeClear color:@"" widthProgress:0];

    if (self.drawBoardView)
    {
        [self.drawBoardView removeFromSuperview];
        self.drawBoardView = nil;
    }
}

#pragma mark - 需要传递给白板的数据
#pragma mark SCDrawBoardViewDelegate

- (void)brushSelectorViewDidSelectDrawType:(YSDrawType)drawType color:(NSString *)hexColor widthProgress:(float)progress
{
    [self.liveManager.whiteBoardManager didSelectDrawType:drawType color:hexColor widthProgress:progress];
}

#pragma mark - 打开相册选择图片

- (void)openTheImagePickerWithImageUseType:(SCUploadImageUseType)imageUseType{
    
    TZImagePickerController * imagePickerController = [[TZImagePickerController alloc]initWithMaxImagesCount:3 columnNumber:1 delegate:self pushPhotoPickerVc:YES];
    imagePickerController.showPhotoCannotSelectLayer = YES;
    imagePickerController.allowTakePicture = imageUseType == SCUploadImageUseType_Document ? NO : YES;
    imagePickerController.allowTakeVideo = NO;
    imagePickerController.allowPickingVideo = NO;
    imagePickerController.showSelectedIndex = YES;
    imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
    imagePickerController.sortAscendingByModificationDate = NO;
    
    [imagePickerController setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        [YSLiveApiRequest uploadImageWithImage:photos.firstObject withImageUseType:imageUseType success:^(NSDictionary * _Nonnull dict) {
            
            if (imageUseType == 0)
            {
                [self sendWhiteBordImageWithDic:dict];
            }
            else
            {
                BOOL isSucceed = [[YSLiveManager shareInstance] sendMessageWithText:[dict bm_stringTrimForKey:@"swfpath"]  withMessageType:YSChatMessageTypeOnlyImage withMemberModel:nil];
                if (!isSucceed)
                {
                    BMProgressHUD *hub = [BMProgressHUD bm_showHUDAddedTo:self.view animated:YES withText:YSLocalized(@"UploadPhoto.Error")];
                    hub.yOffset = -100;
                    [BMProgressHUD bm_hideHUDForView:self.view animated:YES delay:PROGRESSBOX_DEFAULT_HIDE_DELAY];
                }
            }
            /*
             cospath = "https://demo.roadofcloud.com";
             downloadpath = "/upload/20191114_170842_rjkvvosq.jpg";
             dynamicppt = 0;
             fileid = 157372252254;
             filename = "iOS_mobile_2019-11-14_17_08_38.JPG";
             fileprop = 0;
             isContentDocument = 0;
             pagenum = 1;
             realUrl = "";
             result = 0;
             size = 1256893;
             status = 1;
             swfpath = "/upload/20191114_170842_rjkvvosq.jpg";
             */
        } failure:^(NSInteger errorCode) {
#if DEBUG
            [BMProgressHUD bm_showHUDAddedTo:self.view animated:YES withText:[NSString stringWithFormat:@"%@,code:%@",YSLocalized(@"UploadPhoto.Error"),@(errorCode)]];
#else
            [BMProgressHUD bm_showHUDAddedTo:self.view animated:YES withText:YSLocalized(@"UploadPhoto.Error")];
#endif
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [BMProgressHUD bm_hideHUDForView:self.view animated:YES];
            });
        }];
    }];
    [self.topbarPopoverView dismissViewControllerAnimated:YES completion:^{
        self.topSelectBtn.selected = NO;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }];
    
}

- (void)sendWhiteBordImageWithDic:(NSDictionary *)uplaodDic
{
    NSMutableDictionary *docDic = [[NSMutableDictionary alloc] initWithDictionary:uplaodDic];
    
    // 0:表示普通文档　１－２动态ppt(1: 第一版动态ppt 2: 新版动态ppt ）  3:h5文档
    NSUInteger fileprop = [docDic bm_uintForKey:@"fileprop"];
    BOOL isGeneralFile = fileprop == 0 ? YES : NO;
    BOOL isDynamicPPT = fileprop == 1 || fileprop == 2 ? YES : NO;
    BOOL isH5Document = fileprop == 3 ? YES : NO;
    NSString *action = isDynamicPPT ? sActionShow : @"";
    NSString *mediaType = @"";
    NSString *filetype = @"jpg";
    
    [docDic setObject:action forKey:@"action"];
    [docDic setObject:filetype forKey:@"filetype"];
    
    [self.liveManager.whiteBoardManager addDocumentWithFile:docDic];
    
    NSString *fileid = [docDic bm_stringTrimForKey:@"fileid" withDefault:@""];
    NSString *filename = [docDic bm_stringTrimForKey:@"filename" withDefault:@""];
    NSUInteger pagenum = [docDic bm_uintForKey:@"pagenum"];
    NSString *swfpath = [docDic bm_stringTrimForKey:@"swfpath" withDefault:@""];
    
    NSDictionary *tDataDic = @{
        @"isDel" : @(false),
        @"isGeneralFile" : @(isGeneralFile),
        @"isDynamicPPT" : @(isDynamicPPT),
        @"isH5Document" : @(isH5Document),
        @"action" : action,
        @"mediaType" : mediaType,
        @"isMedia" : @(false),
        @"filedata" : @{
                @"fileid" : fileid,
                @"currpage" : @(1),
                @"pagenum" : @(pagenum),
                @"filetype" : filetype,
                @"filename" : filename,
                @"swfpath" : swfpath,
                @"pptslide" : @(1),
                @"pptstep" : @(0),
                @"steptotal" : @(0),
                @"filecategory":@(0)
        }
    };

    [self.liveManager sendPubMsg:sDocumentChange toID:YSRoomPubMsgTellAllExceptSender data:[tDataDic bm_toJSON] save:NO associatedMsgID:nil associatedUserID:nil expires:0 completion:nil];
    
    NSString *downloadpath = [docDic bm_stringTrimForKey:@"downloadpath"];
    NSInteger isContentDocument = [docDic bm_intForKey:@"isContentDocument"];
//    data: "{"sourceInstanceId":"default","isGeneralFile":true,"isMedia":false,"isDynamicPPT":false,"isH5Document":false,"action":"show","mediaType":"","filedata":{"currpage":1,"pptslide":1,"pptstep":0,"steptotal":0,"fileid":1701,"pagenum":1,"filename":"老师_qr_2020-01-14_15_59_24.png","filetype":"png","isContentDocument":0,"swfpath":"/upload/20200114_155926_dwbudtjw.png"}}"

    NSDictionary *tDataDic1 = @{
        @"sourceInstanceId":@"default",
        @"isGeneralFile" : @(isGeneralFile),
        @"isDynamicPPT" : @(isDynamicPPT),
        @"isH5Document" : @(isH5Document),
        @"action" : sActionShow,
        @"downloadpath" : downloadpath,
        @"fileid" : fileid,
        @"mediaType" : mediaType,
        @"isMedia" : @(false),
        @"filedata" : @{
                @"fileid" : fileid ,
                @"filename" : filename,
                @"filetype" : filetype,
                @"currpage" : @(1),
                @"pagenum" : @(pagenum),
                @"pptslide" : @(1),
                @"pptstep" : @(0),
                @"steptotal" : @(0),
                @"isContentDocument" : @(isContentDocument),
                @"swfpath" : swfpath
        }
    };
    
    [self.liveManager.whiteBoardManager changeDocumentWithFileID:fileid
                                                    isBeginClass:self.liveManager.isBeginClass
                                                        isPubMsg:NO];
    [self.liveManager.roomManager pubMsg:sShowPage msgID:sDocumentFilePage_ShowPage toID:YSRoomPubMsgTellAll data:[tDataDic1 bm_toJSON] save:YES associatedMsgID:nil associatedUserID:nil expires:0 completion:nil];
}

/// 正在举手上台的人员数组
- (NSMutableArray<YSRoomUser *> *)raiseHandArray
{
    if (!_raiseHandArray) {
        _raiseHandArray = [NSMutableArray array];
    }
    return _raiseHandArray;
}

/// 举过手的人员数组
- (NSMutableArray<YSRoomUser *> *)haveRaiseHandArray
{
    if (!_haveRaiseHandArray) {
        _haveRaiseHandArray = [NSMutableArray array];
    }
    return _haveRaiseHandArray;
}

@end
