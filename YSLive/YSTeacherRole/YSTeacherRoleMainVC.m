//
//  YSTeacherRoleMainVC.m
//  YSLive
//
//  Created by 马迪 on 2019/12/23.
//  Copyright © 2019 YS. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import "YSTeacherRoleMainVC.h"
#import "SCChatView.h"
#import "SCBrushToolView.h"
#import "SCDrawBoardView.h"
#import "SCChatToolView.h"
#import "SCDrawBoardView.h"
#import "YSEmotionView.h"


#import "SCTeacherListView.h"
#import "SCTeacherAnswerView.h"

#import "YSFloatView.h"
#import "SCVideoGridView.h"

#import "YSMediaMarkView.h"

#import "UIAlertController+SCAlertAutorotate.h"
#import "YSLiveApiRequest.h"

#import "SCColorSelectView.h"

#import "YSControlPopoverView.h"

#import "YSMp4ControlView.h"
#import "YSMp3Controlview.h"

#import "PanGestureControl.h"

#import "YSUpHandPopoverVC.h"
#import "YSCircleProgress.h"
#import "YSTeacherResponder.h"
#import "YSTeacherTimerView.h"
#import "YSPollingView.h"
#import "YSToolBoxView.h"

#define USE_FullTeacher             1

#define PlaceholderPTag     10

#define GiftImageView_Width         185.0f
#define GiftImageView_Height        224.0f

/// 一对一多视频最高尺寸
static const CGFloat kVideoView_MaxHeight_iPhone = 80.0f;
static const CGFloat kVideoView_MaxHeight_iPad  = 160.0f;
#define VIDEOVIEW_MAXHEIGHT         ([UIDevice bm_isiPad] ? kVideoView_MaxHeight_iPad : kVideoView_MaxHeight_iPhone)

/// 视频间距
static const CGFloat kVideoView_Gap_iPhone = 4.0f;
static const CGFloat kVideoView_Gap_iPad  = 6.0f;
#define VIDEOVIEW_GAP               ([UIDevice bm_isiPad] ? kVideoView_Gap_iPad : kVideoView_Gap_iPhone)

static NSInteger playerFirst = 0; /// 播放器播放次数限制

//聊天视图的高度
#define SCChatViewHeight (self.spreadBottomToolBar.bm_originY - self.contentBackgroud.bm_originY - STATETOOLBAR_HEIGHT)
//聊天输入框工具栏高度
#define SCChatToolHeight  60
//聊天表情列表View高度
#define SCChateEmotionHeight  109
//右侧聊天视图宽度
#define ChatViewWidth 284

/// 花名册 课件库
#define ListView_Width        426.0f
#define ListView_Height        598.0f

#define onePageMaxUsers  8
#define YSTeacherResponderCountDownKey     @"YSTeacherResponderCountDownKey"
#define YSTeacherTimerCountDownKey         @"YSTeacherTimerCountDownKey"

@interface YSTeacherRoleMainVC ()
<
    BMTZImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    //UIImagePickerControllerDelegate,
    UIPopoverPresentationControllerDelegate,
    UITextViewDelegate,
    SCBrushToolViewDelegate,
    SCDrawBoardViewDelegate,
    SCVideoViewDelegate,
    YSControlPopoverViewDelegate,
    SCTeacherListViewDelegate,
    YSMp4ControlViewDelegate,
    YSMp3ControlviewDelegate,
    UIGestureRecognizerDelegate,
    YSTeacherResponderDelegate,
    YSTeacherTimerViewDelegate,
    YSPollingViewDelegate,
    YSToolBoxViewDelegate
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

    /// 悬浮视频宽最小值(拖出和共享)
    CGFloat floatVideoMinWidth;
    /// 悬浮视频高最小值(拖出和共享)
    CGFloat floatVideoMinHeight;
    
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
    
    YSRoomLayoutType defaultRoomLayout;
    
    //BOOL needFreshVideoView;
    
    NSInteger contestCommitNumber;
    
    NSString *contestPeerId;
    
    BOOL autoUpPlatform;
    NSInteger timer_defaultTime;
    BOOL allNoAudio;// 全体静音
    
    NSInteger _personListCurentPage;
    NSInteger _personListTotalPage;
    
    BOOL isSearch;
    NSMutableArray *searchArr;
    
    BOOL _isMp4Play;// 是否是MP4全屏播放
    BOOL _isMp4ControlHide;// MP4控制是否显示 关闭按钮是否显示
    BOOL _isPolling;// 正在轮播
    NSString *_pollingFromID;/// 轮播发起者ID
    
    BOOL giftMp3Playing;
}

/// 房间类型 0:表示一对一教室  非0:表示一多教室
@property (nonatomic, assign) YSRoomUserType roomtype;
/// 视频ratio 16:9
@property (nonatomic, assign) BOOL isWideScreen;

/// 固定UserId
@property (nonatomic, strong) NSString *userId;

///标识布局变化的值
@property (nonatomic, assign) YSRoomLayoutType roomLayout;
/// 工具箱
@property(nonatomic, strong) YSToolBoxView *toolBoxView;
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
/// 大并发房间计时器 每两秒获取一次
@property (nonatomic, strong) dispatch_source_t bigRoomTimer;

/// 内容
@property (nonatomic, strong) UIView *contentView;
/// 视频背景
@property (nonatomic, strong) UIView *videoBackgroud;
/// 白板背景
@property (nonatomic, strong) UIView *whitebordBackgroud;
/// 全屏白板背景
@property (nonatomic, strong) UIView *whitebordFullBackgroud;
/// 全屏老师 视频容器
#if USE_FullTeacher
@property (nonatomic, strong) YSFloatView *fullTeacherFloatView;
@property (nonatomic, strong) SCVideoView *fullTeacherVideoView;
#endif
/// 全屏白板背景
@property (nonatomic, assign) BOOL isWhitebordFullScreen;
/// 隐藏白板视频布局背景
@property (nonatomic, strong) SCVideoGridView *videoGridView;

/// 默认老师 视频
//@property (nonatomic, strong) SCVideoView *teacherVideoView;
/// 1V1 默认用户占位
@property (nonatomic, strong) SCVideoView *userVideoView;

/// 1V1 存储学生的视频，画中画时用来伸缩
@property (nonatomic, strong) SCVideoView *studentVideoView;
/// 双师中较小视频左侧按钮
@property (nonatomic, strong) UIButton *expandContractBtn;
/// 双师布局样式
@property (nonatomic, copy) NSString *doubleType;
/// 是否是双师布局信令通知
@property (nonatomic, assign) BOOL isDoubleType;


/// 拖出视频浮动View列表
@property (nonatomic, strong) NSMutableArray <YSFloatView *> *dragOutFloatViewArray;
///拖出视频view时的模拟移动图
@property (nonatomic, strong) UIImageView *dragImageView;
///刚开始拖动时，videoView的初始坐标（x,y）
@property (nonatomic, assign) CGPoint videoOriginInSuperview;
///全屏课件时老师的视频有没有拖拽过
@property (nonatomic, assign) BOOL isFullTeacherVideoViewDragout;


///要拖动的视频view
@property (nonatomic, strong) SCVideoView *dragingVideoView;

/// 双击放大视频
@property (nonatomic, strong) YSFloatView *doubleFloatView;
@property (nonatomic, assign) BOOL isDoubleVideoBig;

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
/// 聊天输入框工具栏
@property (nonatomic, strong) SCChatToolView *chatToolView;
/// 聊天表情列表View
@property (nonatomic, strong) YSEmotionView *emotionListView;
/// 键盘弹起高度
@property (nonatomic, assign) CGFloat keyBoardH;

/// 左侧工具栏
@property (nonatomic, strong) SCBrushToolView *brushToolView;
/// 画笔工具按钮（控制工具条的展开收起）
@property (nonatomic, strong) UIButton *brushToolOpenBtn;
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
@property (nonatomic, strong) NSMutableArray *raiseHandArray;

/// 举手上台的人数
@property (nonatomic, strong) UILabel *handNumLab;

/// 上下课按钮
@property (nonatomic, strong) UIButton *classBeginBtn;

/// 抢答器
@property (nonatomic, strong)YSTeacherResponder *responderView;
/// 老师计时器
@property (nonatomic, strong)YSTeacherTimerView *teacherTimerView;
/// 轮播
@property (nonatomic, strong)YSPollingView *teacherPollingView;
/// 轮播的学生数据
@property (nonatomic, strong) NSMutableArray *pollingArr;
/// 轮播的上台学生数据
@property (nonatomic, strong) NSMutableArray *pollingUpPlatformArr;
/// 轮播定时器
@property (nonatomic, strong) dispatch_source_t pollingTimer;

///音频播放器
@property(nonatomic, strong) AVAudioPlayer *player;
@property(nonatomic, strong) AVAudioSession *session;

/// 当前的焦点视图
@property(nonatomic, strong) SCVideoView *fouceView;

@property(nonatomic, weak) BMTZImagePickerController *imagePickerController;
/// 当前展示课件数组
@property (nonatomic, strong) NSMutableArray *currentFileList;

/// 课件删除
@property(nonatomic, strong) NSURLSessionDataTask *deleteTask;
/// 白板视频标注视图
@property (nonatomic, strong) YSMediaMarkView *mediaMarkView;
@property (nonatomic, strong) NSMutableArray <NSDictionary *> *mediaMarkSharpsDatas;


@end


@implementation YSTeacherRoleMainVC

- (void)dealloc
{
    [self.deleteTask cancel];
    self.deleteTask = nil;
    
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
    
    if (self.bigRoomTimer)
    {
        dispatch_source_cancel(self.bigRoomTimer);
        self.bigRoomTimer = nil;
    }
    
    if (self.pollingTimer)
    {
        dispatch_source_cancel(self.pollingTimer);
        self.pollingTimer = nil;
    }
}

- (instancetype)initWithRoomType:(YSRoomUserType)roomType isWideScreen:(BOOL)isWideScreen maxVideoCount:(NSUInteger)maxCount whiteBordView:(UIView *)whiteBordView userId:(nullable NSString *)userId
{
    self = [super initWithWhiteBordView:whiteBordView];
    if (self)
    {
        maxVideoCount = maxCount;
        
        self.roomtype = roomType;
        self.isWideScreen = isWideScreen;
        
        self.userId = userId;
        
        self.mediaMarkSharpsDatas = [[NSMutableArray alloc] init];
        
        if (self.roomtype == YSRoomUserType_More)
        {
            videoHeight = VIDEOVIEW_MAXHEIGHT;
            
            if (self.isWideScreen)
            {
                videoWidth = ceil(videoHeight * 16/9);
            }
            else
            {
                videoWidth = ceil(videoHeight * 4/3);
            }
            // 初始化老师视频尺寸 固定值
            videoTeacherWidth = videoWidth;
            videoTeacherHeight = videoHeight;
            
        }
        [self calculateFloatVideoSize];
    }
    return self;
}


#pragma mark -
#pragma mark ViewControllerLife

#pragma mark 隐藏状态栏
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    classEndAlertVC = nil;
    _personListCurentPage = 0;
    _personListTotalPage = 0;
    _isMp4Play = NO;
    _isMp4ControlHide = NO;
    searchArr = [[NSMutableArray alloc] init];
    self.pollingArr = [[NSMutableArray alloc] init];
    self.pollingUpPlatformArr = [[NSMutableArray alloc] init];
    self.currentFileList = [[NSMutableArray alloc] init];
    isSearch = NO;
    
    _isPolling = NO;
    /// 本地播放 （定时器结束的音效）
    self.session = [AVAudioSession sharedInstance];
    [self.session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    /// 初始化顶栏数据
    [self setupStateBarData];
    
    // 内容背景
    [self setupContentView];
    
    // 全屏白板
    [self setupFullBoardView];
    
    // 隐藏白板视频布局背景
    [self setupVideoGridView];
    
    // 设置左侧工具栏
    [self setupBrushToolView];
    
    if (self.roomtype == YSRoomUserType_More)
    {
        //举手上台的按钮
        [self setupHandView];
        /// 视频布局时的全屏按钮 （只在 1VN 房间）
    }
    
    // 设置花名册 课件表
    [self setupListView];
    
    [self.spreadBottomToolBar bm_bringToFront];
    
    // 右侧聊天视图
    [self creatRightChatView];
    
    //创建上下课按钮
    [self setupClassBeginButton];
    
    // 上课前不发送修改画笔权限
    //[self.liveManager.roomManager changeUserProperty:YSCurrentUser.peerID tellWhom:YSCurrentUser.peerID key:sUserCandraw value:@(true) completion:nil];
//    [self.liveManager.whiteBoardManager brushToolsDidSelect:YSBrushToolTypeMouse];
    
    // 会议默认视频布局
    if (self.appUseTheType == YSRoomUseTypeMeeting)
    {
        defaultRoomLayout = YSRoomLayoutType_VideoLayout;
        self.roomLayout = defaultRoomLayout;
        [self handleSignalingSetRoomLayout:self.roomLayout withPeerId:nil];
    }
    else
    {
        defaultRoomLayout = YSRoomLayoutType_AroundLayout;
        self.roomLayout = defaultRoomLayout;
    }
    
#if USE_FullTeacher
    [self setupFullTeacherView];
#endif
}





#if USE_FullTeacher
- (void)setupFullTeacherView
{
    self.fullTeacherFloatView = [[YSFloatView alloc] initWithFrame:CGRectMake(self.contentWidth - 76 - floatVideoDefaultWidth, 50, floatVideoDefaultWidth, floatVideoDefaultHeight)];
    self.fullTeacherFloatView.isFullBackgrond = YES;
    [self.contentBackgroud addSubview:self.fullTeacherFloatView];
    self.fullTeacherFloatView.hidden = YES;
}
#endif

- (void)afterDoMsgCachePool
{
    [super afterDoMsgCachePool];
    
//    if (self.liveManager.isBeginClass)
//    {
//        if (YSCurrentUser.vfail == YSDeviceFaultNone)
//        {
//            [self.liveManager.roomManager publishVideo:nil];
//        }
//        if (YSCurrentUser.afail == YSDeviceFaultNone)
//        {
//            [self.liveManager.roomManager publishAudio:nil];
//        }
//    }
    //会议默认上课
    if (self.appUseTheType == YSRoomUseTypeMeeting && !self.liveManager.isClassBegin)
    {
        [self.liveManager sendSignalingTeacherToClassBegin];
    }
}


#pragma mark - 层级管理

// 重新排列VC.View的图层
- (void)arrangeAllViewInVCView
{
    // 全屏白板
    [self.whitebordFullBackgroud bm_bringToFront];
    
    // mp3f动画
    //    [self.playMp3ImageView bm_bringToFront];
    
    // 笔刷工具
    [self.brushToolView bm_bringToFront];
        
    // 聊天窗口
    [self.rightChatView bm_bringToFront];
    
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

// 重新排列whiteBordBackgroud的图层
- (void)arrangeAllViewInWhiteBordBackgroud
{
    for (YSFloatView *floatView in self.dragOutFloatViewArray)
    {
        [floatView bm_bringToFront];
    }
    
    if (self.doubleFloatView)
    {
        [self.doubleFloatView bm_bringToFront];
    }
}

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
#pragma mark setupUI

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
        
        if (location.y < 0 || location.y > self.contentHeight)
        {
            return;
        }
        CGPoint translation = [recognizer translationInView:self.view];
        
        dragView.center = CGPointMake(dragView.center.x + translation.x, dragView.center.y + translation.y);
        [recognizer setTranslation:CGPointZero inView:self.view];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled)
    {
        CGRect currentFrame = dragView.frame;
        
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
            [UIView animateWithDuration:BMDEFAULT_DELAY_TIME animations:^{
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
            [UIView animateWithDuration:BMDEFAULT_DELAY_TIME animations:^{
                dragView.frame = currentFrame;
            }];
            
            return;
        }
        
        if (currentFrame.origin.y < 0)
        {
            currentFrame.origin.y = 4;
            [UIView animateWithDuration:BMDEFAULT_DELAY_TIME animations:^{
                dragView.frame = currentFrame;
            }];
            
            return;
        }
        
        if ((currentFrame.origin.y + currentFrame.size.height) > self.view.bounds.size.height)
        {
            currentFrame.origin.y = self.view.bounds.size.height - currentFrame.size.height;
            [UIView animateWithDuration:BMDEFAULT_DELAY_TIME animations:^{
                dragView.frame = currentFrame;
            }];
            
            return;
        }
    }
}

/// 初始化顶栏数据
- (void)setupStateBarData
{
    self.roomID = self.liveManager.room_Id;
    self.lessonTime = @"00:00:00";
}

#pragma mark - 举手上台的UI
- (void)setupHandView
{
    CGFloat raiseHandWH = 40;
    CGFloat raiseHandRight = 10;
    
    CGFloat labBottom = 12;
    if ([UIDevice bm_isiPad])
    {
        raiseHandWH = 40;
        raiseHandRight = 20;
        labBottom = 20;
    }
//    BMUI_SCREEN_WIDTH - (YSSpreadBottomToolBar_BtnWidth+YSSpreadBottomToolBar_SpreadBtnGap)*2.0f
    UILabel *handNumLab = [[UILabel alloc]initWithFrame:CGRectMake(BMUI_SCREEN_WIDTH - raiseHandWH - raiseHandRight, self.spreadBottomToolBar.bm_originY - labBottom - 18, raiseHandWH, 18)];
    handNumLab.bm_centerX = self.spreadBottomToolBar.bm_right - (YSSpreadBottomToolBar_BtnWidth+YSSpreadBottomToolBar_SpreadBtnGap)*0.5f;  //(YSSpreadBottomToolBar_BtnWidth+YSSpreadBottomToolBar_SpreadBtnGap)*0.5f;
    handNumLab.font = UI_FONT_13;
    handNumLab.textColor = YSSkinDefineColor(@"defaultTitleColor");
    handNumLab.backgroundColor = YSSkinDefineColor(@"ToolBgColor");
    handNumLab.layer.cornerRadius = 18/2;
    handNumLab.layer.masksToBounds = YES;
    handNumLab.textAlignment = NSTextAlignmentCenter;
    self.handNumLab = handNumLab;
    [self.view addSubview:handNumLab];
    self.handNumLab.text = [NSString stringWithFormat:@"%ld/%ld",(long)self.raiseHandArray.count,(long)self.liveManager.studentCount];
    
    UIButton *raiseHandsBtn = [[UIButton alloc]initWithFrame:CGRectMake(handNumLab.bm_originX, handNumLab.bm_originY - raiseHandWH, raiseHandWH, raiseHandWH)];
    [raiseHandsBtn setImage:YSSkinElementImage(@"raiseHand_teacherBtn", @"iconNor") forState:UIControlStateNormal];
    [raiseHandsBtn setImage:YSSkinElementImage(@"raiseHand_teacherBtn", @"iconSel") forState:UIControlStateSelected];
    
    [raiseHandsBtn setImage:YSSkinElementImage(@"raiseHand_teacherBtn", @"iconSel") forState:UIControlStateSelected];
    
    [raiseHandsBtn addTarget:self action:@selector(raiseHandsButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    raiseHandsBtn.bm_centerX = self.spreadBottomToolBar.bm_right - (YSSpreadBottomToolBar_BtnWidth+YSSpreadBottomToolBar_SpreadBtnGap)*0.5f;
    self.raiseHandsBtn = raiseHandsBtn;
    [self.view addSubview:raiseHandsBtn];
}

- (void)raiseHandsButtonClick:(UIButton *)sender
{
    if (!self.raiseHandArray.count)
    {
        return;
    }
    
    YSUpHandPopoverVC *popTab = [[YSUpHandPopoverVC alloc]init];
    popTab.userArr = self.raiseHandArray;
    popTab.preferredContentSize = CGSizeMake(95, 146);
    popTab.modalPresentationStyle = UIModalPresentationPopover;
    BMWeakSelf
    popTab.letStudentUpVideo = ^(YSUpHandPopCell *cell) {
        if (weakSelf.videoViewArray.count < self->maxVideoCount)
        {
            YSPublishState publishState = YSUser_PublishState_BOTH;
            
            if (weakSelf.liveManager.isEveryoneNoAudio)
            {
                publishState = YSUser_PublishState_VIDEOONLY;
            }
            
            NSString *peerId = [cell.userDict bm_stringForKey:@"peerId"];
            [weakSelf.liveManager setPropertyOfUid:peerId tell:YSRoomPubMsgTellAll propertyKey:sYSUserPublishstate value:@(publishState)];
            cell.headBtn.selected = YES;
        }
        else
        {
            [BMProgressHUD bm_showHUDAddedTo:weakSelf.view animated:YES withDetailText:YSLocalized(@"Error.UpPlatformMemberOverRoomLimit") delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
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
    CGFloat laftGap = 10;
    if (BMIS_IPHONEXANDP)
    {
        laftGap = BMUI_HOME_INDICATOR_HEIGHT;
    }
    self.brushToolView.bm_left = laftGap;
    self.brushToolView.bm_centerY = self.view.bm_centerY;
    self.brushToolView.delegate = self;
    self.brushToolView.hidden = YES;
    
    UIButton *brushToolOpenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [brushToolOpenBtn addTarget:self action:@selector(brushToolOpenBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [brushToolOpenBtn setBackgroundImage:YSSkinElementImage(@"brushTool_open", @"iconNor") forState:UIControlStateNormal];
    [brushToolOpenBtn setBackgroundImage:YSSkinElementImage(@"brushTool_open", @"iconSel") forState:UIControlStateSelected];
    brushToolOpenBtn.frame = CGRectMake(0, 0, 24, 36);
    brushToolOpenBtn.bm_centerY = self.brushToolView.bm_centerY;
    brushToolOpenBtn.bm_left = self.brushToolView.bm_right;
    self.brushToolOpenBtn = brushToolOpenBtn;
    self.brushToolOpenBtn.hidden = YES;
    [self.view addSubview:brushToolOpenBtn];
}

/// 助教网络刷新所有人课件
- (void)handleSignalingTorefeshCourseware
{
#warning handleSignalingTorefeshCourseware
}

/// 创建上下课按钮
- (void)setupClassBeginButton
{
    CGFloat buttonWH = 36;
    CGFloat buttonLeft = 10;
    
    CGFloat buttonBottom = 14;
    if ([UIDevice bm_isiPad])
    {
        buttonWH = 40;
        buttonLeft = 20;
        buttonBottom = 50;
    }
    
    UIButton * classBeginBtn = [[UIButton alloc]initWithFrame:CGRectMake(buttonLeft, BMUI_SCREEN_HEIGHT - buttonBottom - buttonWH, buttonWH, buttonWH)];
    [classBeginBtn addTarget:self action:@selector(classBeginBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [classBeginBtn setTitleColor:YSSkinDefineColor(@"defaultTitleColor") forState:UIControlStateNormal];
    classBeginBtn.titleLabel.font = UI_FONT_10;
    [classBeginBtn setTitle:YSLocalized(@"Button.ClassBegin") forState:UIControlStateNormal];
    [classBeginBtn setTitle:YSLocalized(@"Button.ClassIsOver") forState:UIControlStateSelected];
    [classBeginBtn setBackgroundColor:YSSkinDefineColor(@"defaultSelectedBgColor")];
    classBeginBtn.layer.cornerRadius = buttonWH/2;
    self.classBeginBtn = classBeginBtn;
    [self.view addSubview:classBeginBtn];
}


- (void)classBeginBtnClick:(UIButton *)sender
{
    if (sender.selected)
    {
        BMWeakType(sender)
        BMWeakSelf
        [self.controlPopoverView dismissViewControllerAnimated:NO completion:nil];
        [self.upHandPopTableView dismissViewControllerAnimated:NO completion:nil];

        classEndAlertVC = [UIAlertController alertControllerWithTitle:YSLocalized(@"Prompt.FinishClass") message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *confimAc = [UIAlertAction actionWithTitle:YSLocalized(@"Prompt.OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            weaksender.userInteractionEnabled = NO;
            [weakSelf.liveManager sendSignalingTeacherToDismissClass];
        }];
        UIAlertAction *cancle = [UIAlertAction actionWithTitle:YSLocalized(@"Prompt.Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [classEndAlertVC addAction:confimAc];
        [classEndAlertVC addAction:cancle];
        
        [self presentViewController:classEndAlertVC animated:YES completion:nil];
    }
    else
    {
        sender.userInteractionEnabled = NO;
        [self.liveManager sendSignalingTeacherToClassBegin];
    }
}

#pragma mark 内容背景
- (void)setupContentView
{
    //[self.liveManager setDeviceOrientation:UIDeviceOrientationLandscapeLeft];
    // 前后默认开启镜像
    [self.liveManager changeLocalVideoMirrorMode:CloudHubVideoMirrorModeEnabled];

    // 视频+白板背景
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, STATETOOLBAR_HEIGHT, self.contentWidth, self.contentHeight - STATETOOLBAR_HEIGHT)];
    contentView.backgroundColor = [UIColor clearColor];
    [self.contentBackgroud addSubview:contentView];
    self.contentView = contentView;
    contentView.layer.masksToBounds = YES;
    
    // 白板背景
    UIView *whitebordBackgroud = [[UIView alloc] init];
    whitebordBackgroud.backgroundColor = [UIColor redColor];
    [self.contentView addSubview:whitebordBackgroud];
    self.whitebordBackgroud = whitebordBackgroud;
    whitebordBackgroud.layer.masksToBounds = YES;
    
    // 视频背景
    UIView *videoBackgroud = [[UIView alloc] init];
    videoBackgroud.backgroundColor = YSSkinDefineColor(@"defaultBgColor");
    videoBackgroud.layer.shadowColor = [UIColor bm_colorWithHex:0x000000 alpha:0.5].CGColor;
    videoBackgroud.layer.shadowOffset = CGSizeMake(0,2);
    videoBackgroud.layer.shadowOpacity = 1;
    videoBackgroud.layer.shadowRadius = 4;
    self.videoBackgroud = videoBackgroud;
    [self.contentView addSubview:videoBackgroud];
    
    // 加载白板
    [self.whitebordBackgroud addSubview:self.whiteBordView];
    
    [self calculateVideoSize];
    
    /// 设置尺寸
    if (self.roomtype == YSRoomUserType_One)
    {
        self.expandContractBtn = [[UIButton alloc]initWithFrame:CGRectZero];
        [self.expandContractBtn addTarget:self action:@selector(doubleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.expandContractBtn setBackgroundImage:YSSkinElementImage(@"doubleTeacher_littleView", @"iconNor") forState:UIControlStateNormal];
        [self.expandContractBtn setBackgroundImage:YSSkinElementImage(@"doubleTeacher_littleView", @"iconSel") forState:UIControlStateSelected];
        self.expandContractBtn.tag = DoubleTeacherExpandContractBtnTag;
        self.expandContractBtn.hidden = YES;
//        [self.expandContractBtn setBackgroundColor:UIColor.greenColor];
        [self.videoBackgroud addSubview:self.expandContractBtn];
        [self setUp1V1DefaultVideoView];
    }
    else
    {
        // 添加浮动视频窗口
        self.dragOutFloatViewArray = [[NSMutableArray alloc] init];
        
        // 1VN 初始本人视频音频
        SCVideoView *videoView = [[SCVideoView alloc] initWithRoomUser:YSCurrentUser isForPerch:YES withDelegate:self];
        videoView.appUseTheType = self.appUseTheType;
        [self.videoViewArray addObject:videoView];
        [self.liveManager playVideoWithUserId:YSCurrentUser.peerID streamID:nil renderMode:CloudHubVideoRenderModeHidden mirrorMode:CloudHubVideoMirrorModeEnabled inView:videoView];
#if YSAPP_NEWERROR
        [self.liveManager playVideoOnView:videoView withPeerId:YSCurrentUser.peerID renderType:YSRenderMode_adaptive completion:nil];
        
        [self.liveManager playAudio:YSCurrentUser.peerID completion:nil];
#endif
    }
    
    // 共享
    self.shareVideoFloatView = [[YSFloatView alloc] initWithFrame:CGRectMake(0, 0, self.contentWidth, self.contentHeight)];
    [self.contentBackgroud addSubview:self.shareVideoFloatView];
    self.shareVideoFloatView.hidden = YES;
    self.shareVideoView = [[UIView alloc] initWithFrame:self.shareVideoFloatView.bounds];
    UITapGestureRecognizer * shareVideoViewTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mp4ShareVideoViewClicked:)];
    shareVideoViewTapGesture.delegate =self;
    [self.shareVideoView addGestureRecognizer:shareVideoViewTapGesture];
    [self.shareVideoFloatView showWithContentView:self.shareVideoView];
    self.shareVideoFloatView.backgroundColor = [UIColor blackColor];
    
    self.whiteBordView.frame = self.whitebordBackgroud.bounds;
    [self.liveManager.whiteBoardManager refreshWhiteBoard];
    
    self.mp4ControlView = [[YSMp4ControlView alloc] init];
    [self.contentBackgroud addSubview:self.mp4ControlView];
    self.mp4ControlView.frame = CGRectMake(30, self.contentHeight - 100, self.contentWidth - 60, 74);
//    self.mp4ControlView.bm_bottom = self.view.bm_bottom - 23;
    self.mp4ControlView.backgroundColor = [UIColor bm_colorWithHex:0x6D7278 alpha:0.39];
    self.mp4ControlView.layer.cornerRadius = 37;
    self.mp4ControlView.hidden = YES;
    self.mp4ControlView.delegate = self;
    UIPanGestureRecognizer *mp4PanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureToMoveMp3View:)];
    [self.mp4ControlView addGestureRecognizer:mp4PanGesture];
    
    
    
    self.closeMp4Btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentBackgroud addSubview:self.closeMp4Btn];
    self.closeMp4Btn.frame = CGRectMake(self.contentWidth - 60, 20, 25, 25);
    [self.closeMp4Btn setBackgroundImage:YSSkinElementImage(@"media_close", @"iconNor") forState:UIControlStateNormal];
    [self.closeMp4Btn addTarget:self action:@selector(closeMp4BtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.closeMp4Btn.hidden = YES;
    
    self.mp3ControlView = [[YSMp3Controlview alloc] init];
    self.mp3ControlView.hidden = YES;
    self.mp3ControlView.delegate = self;
    self.mp3ControlView.backgroundColor = [UIColor bm_colorWithHex:0x000000 alpha:0.39];
    [self.contentBackgroud addSubview:self.mp3ControlView];
    if ([UIDevice bm_isiPad])
    {
        self.mp3ControlView.frame = CGRectMake(100, 0, 386, 74);
        self.mp3ControlView.bm_bottom = self.contentView.bm_bottom - 123;
        self.mp3ControlView.layer.cornerRadius = 37;
    }
    else
    {
        self.mp3ControlView.frame = CGRectMake(80, 0, 300, 60);
        self.mp3ControlView.bm_bottom = self.contentView.bm_bottom - 70;
        self.mp3ControlView.layer.cornerRadius = 30;
    }
    
    UIPanGestureRecognizer *mp3PanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureToMoveMp3View:)];
    [self.mp3ControlView addGestureRecognizer:mp3PanGesture];
    [self freshContentView];
}

- (void)panGestureToMoveMp3View:(UIPanGestureRecognizer *)panGesture
{
    UIView *panView = panGesture.view;

    //1、获得拖动位移
    CGPoint offsetPoint = [panGesture translationInView:panView];
    //2、清空拖动位移
    [panGesture setTranslation:CGPointZero inView:panView];
    //3、重新设置控件位置
    CGFloat newX = panView.bm_centerX+offsetPoint.x;
    CGFloat newY = panView.bm_centerY+offsetPoint.y;

    if (self.liveManager.localUser.role == YSUserType_Teacher)
    {
        CGFloat viewWidth = panView.bm_width;
        CGFloat viewHeight = panView.bm_height;
        
        if (newX < 1 + viewWidth/2)
        {
            newX = 1 + viewWidth/2 ;
        }
        else if (newX > self.contentBackgroud.bm_width - viewWidth/2 - 1)
        {
            newX = self.contentBackgroud.bm_width - viewWidth/2 - 1;
        }
        
        if (newY <= 1 + viewHeight/2)
        {
            newY = 1 + viewHeight/2;
        }
        else if (newY > self.contentBackgroud.bm_height - viewHeight/2 - 1)
        {
            newY = self.contentBackgroud.bm_height - viewHeight/2 - 1;
        }
    }
    else
    {
       CGFloat viewWidth = panView.bm_width;
        
        if (newX < 1 + viewWidth/2)
        {
            newX = 1 + viewWidth/2 ;
        }
        else if (newX > self.contentBackgroud.bm_width - viewWidth/2 - 1)
        {
            newX = self.contentBackgroud.bm_width - viewWidth/2 - 1;
        }
        
        if (newY <= 1 + viewWidth/2)
        {
            newY = 1 + viewWidth/2;
        }
        else if (newY > self.contentBackgroud.bm_height - viewWidth/2 - 1)
        {
            newY = self.contentBackgroud.bm_height - viewWidth/2 - 1;
        }
    }
        
    CGPoint centerPoint = CGPointMake(newX, newY);
    panView.center = centerPoint;
}

/// MP4 全屏播放时的点击事件
- (void)mp4ShareVideoViewClicked:(UITapGestureRecognizer *)tap
{
    if (!_isMp4Play)
    {
        return;
    }
    else
    {
        _isMp4ControlHide = !_isMp4ControlHide;
        self.mp4ControlView.hidden = _isMp4ControlHide;
        self.closeMp4Btn.hidden = _isMp4ControlHide;
    }
    BMLog(@"diandji");
}


- (void)closeMp4BtnClicked:(UIButton *)btn
{
    [self.liveManager stopShareOneMediaFile];
}

- (void)doubleBtnClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.selected)
    {
        self.studentVideoView.bm_originX = self.videoBackgroud.bm_width;
    }
    else
    {
        self.studentVideoView.bm_originX = VIDEOVIEW_GAP + videoTeacherWidth - videoWidth;
    }
    self.expandContractBtn.bm_originX = self.studentVideoView.bm_originX-23;
}

///双师：老师拖拽视频布局
- (void)handleSignalingToDoubleTeacherWithData:(NSDictionary *)data
{
    self.isDoubleType = 1;
    
    self.doubleType = [data bm_stringForKey:@"one2one"];
    
    [self freshContentView];
}

/// 双师信令时计算视频尺寸
- (void)doubleTeacherCalculateVideoSize
{
    if (self.roomLayout == YSRoomLayoutType_VideoLayout)
    {
        videoWidth = ceil((self.contentWidth-VIDEOVIEW_GAP*3) / 2);
        if (self.isWideScreen)
        {
            videoHeight = ceil(videoWidth * 9/16);
        }
        else
        {
            videoHeight = ceil(videoWidth * 3/4);
        }
    }
    else
    {
        if (![self.doubleType bm_isNotEmpty] || [self.doubleType isEqualToString:@"abreast"])//默认上下平行关系
        {
            // 在此调整视频大小和屏幕比例关系
            videoWidth = ceil((self.contentWidth - VIDEOVIEW_GAP * 3)/3);
            if (self.isWideScreen)
            {
                videoHeight = ceil(videoWidth * 9/16);
            }
            else
            {
                videoHeight = ceil(videoWidth * 3/4);
            }
            whitebordWidth = 2 * videoWidth;
            whitebordHeight = ceil(whitebordWidth * 3/4);
        }
        else if([self.doubleType isEqualToString:@"nested"] )//画中画
        {
            // 在此调整视频大小和屏幕比例关系
            videoWidth = ceil(self.contentWidth / 7);
            videoTeacherWidth = ceil((self.contentWidth-VIDEOVIEW_GAP)/2);
            whitebordWidth = videoTeacherWidth;
            if (self.isWideScreen)
            {
                videoHeight = ceil(videoWidth * 9/16);
                videoTeacherHeight = ceil(videoTeacherWidth * 9/16);
            }
            else
            {
                videoHeight = ceil(videoWidth * 3/4);
                videoTeacherHeight = ceil(videoTeacherWidth * 3/4);
            }
            
            whitebordHeight = whitebordWidth * 3/4;
        }
    }
    
    [self freshWhitBordContentView];
}


/// 1V1 初始默认视频背景
- (void)setUp1V1DefaultVideoView
{
    // 1V1 初始本人视频音频
    SCVideoView *videoView = [[SCVideoView alloc] initWithRoomUser:YSCurrentUser isForPerch:YES withDelegate:self];
    videoView.appUseTheType = self.appUseTheType;
    videoView.tag = PlaceholderPTag;
    
    [self.videoBackgroud addSubview:videoView];
    self.teacherVideoView = videoView;

    [self.liveManager playVideoWithUserId:YSCurrentUser.peerID streamID:nil renderMode:CloudHubVideoRenderModeHidden mirrorMode:CloudHubVideoMirrorModeEnabled inView:videoView];
#if YSAPP_NEWERROR
    [self.liveManager playVideoOnView:videoView withPeerId:YSCurrentUser.peerID renderType:YSRenderMode_adaptive completion:nil];
    [self.liveManager playAudio:YSCurrentUser.peerID completion:nil];
#endif
    
    // 1V1 初始学生视频蒙版
    UIImageView *imageView = [[UIImageView alloc] initWithImage:YSSkinDefineImage(@"main_uservideocover")];
    YSRoomUser *roomUser = [[YSRoomUser alloc] initWithPeerId:@"0"];
    roomUser.role = YSUserType_Student;
    SCVideoView *userVideoView = [[SCVideoView alloc] initWithRoomUser:roomUser isForPerch:YES withDelegate:self];
    userVideoView.appUseTheType = self.appUseTheType;
    userVideoView.tag = PlaceholderPTag;
    userVideoView.frame = CGRectMake(0, 0, videoWidth, videoHeight);
    imageView.frame = userVideoView.bounds;
    [userVideoView addSubview:imageView];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView.contentMode = UIViewContentModeCenter;
    imageView.backgroundColor = YSSkinDefineColor(@"noVideoMaskBgColor");
    [self.videoBackgroud addSubview:userVideoView];
    
    if (self.isWideScreen)
    {
        CGFloat orgainalY = (whitebordHeight - 2 * videoHeight - VIDEOVIEW_GAP)/2;
        self.teacherVideoView.frame = CGRectMake(0, orgainalY, videoWidth, videoHeight);
        userVideoView.frame = CGRectMake(0, orgainalY + videoHeight + VIDEOVIEW_GAP, videoWidth, videoHeight);
    }
    else
    {
        self.teacherVideoView.frame = CGRectMake(0, 0, videoWidth, videoHeight);
        userVideoView.frame = CGRectMake(0, videoHeight, videoWidth, videoHeight);
    }
    
    self.userVideoView = userVideoView;
}


// 横排视频最大宽度计算
- (CGFloat)getVideoTotalWidth
{
    NSUInteger count = [self getVideoViewCount];
    
    CGFloat totalWidth = 0.0;
    
    if (count < 8)
    {
        totalWidth = count * (videoWidth + VIDEOVIEW_GAP/2);
    }
    else if (count < 26)
    {
        NSInteger num = 0;
        if (self.teacherVideoView && !self.teacherVideoView.isDragOut && !self.teacherVideoView.isFullScreen)
        {
            num = (count - 1)/2 + (count - 1)%2;
            totalWidth = videoTeacherWidth + num * (videoWidth + VIDEOVIEW_GAP/2);
        }
        else
        {
            num = count/2 + count%2;
            totalWidth = num * (videoWidth + VIDEOVIEW_GAP/2);
        }
    }
    return totalWidth;
}

/// 全屏白板初始化
- (void)setupFullBoardView
{
    // 白板背景
    UIView *whitebordFullBackgroud = [[UIView alloc] init];
//    whitebordFullBackgroud.backgroundColor = [UIColor bm_colorWithHex:0x9DBEF3];
    whitebordFullBackgroud.backgroundColor = UIColor.redColor;
    [self.contentBackgroud addSubview:whitebordFullBackgroud];
    whitebordFullBackgroud.frame = CGRectMake(0, 0, self.contentWidth, self.contentHeight);
    self.whitebordFullBackgroud = whitebordFullBackgroud;
    self.whitebordFullBackgroud.hidden = YES;
    whitebordFullBackgroud.layer.masksToBounds = YES;
}

/// 隐藏白板视频布局背景
- (void)setupVideoGridView
{
    SCVideoGridView *videoGridView = [[SCVideoGridView alloc] initWithWideScreen:self.isWideScreen];

    CGFloat width = self.contentWidth;
    CGFloat height = self.contentHeight-STATETOOLBAR_HEIGHT;
    
    // 初始化尺寸
    videoGridView.defaultSize = CGSizeMake(width, height);
    videoGridView.frame = CGRectMake(0, STATETOOLBAR_HEIGHT, width, height);
    
    [self.contentBackgroud addSubview:videoGridView];
    videoGridView.backgroundColor = [UIColor clearColor];
    videoGridView.hidden = YES;
    self.videoGridView = videoGridView;
}

- (void)setupListView
{
    CGFloat tableHeight = BMUI_SCREEN_HEIGHT;
    self.teacherListView = [[SCTeacherListView alloc] init];

    self.teacherListView.delegate = self;
    self.teacherListView.topGap = self.contentBackgroud.bm_top + STATETOOLBAR_HEIGHT;
    BMLog(@"%f",self.contentBackgroud.bm_top);
    self.teacherListView.bottomGap = BMUI_SCREEN_HEIGHT - self.spreadBottomToolBar.bm_top + 5;
    self.teacherListView.frame = CGRectMake(BMUI_SCREEN_WIDTH, 0, BMUI_SCREEN_WIDTH, tableHeight);
    [self.view addSubview:self.teacherListView];
}

#pragma mark -
#pragma mark UI fresh

// 计算视频尺寸
- (void)calculateVideoSize
{
    if (self.roomtype == YSRoomUserType_One)
    {
        if (self.roomLayout == YSRoomLayoutType_VideoLayout)
        {//左右平行关系
            videoWidth = ceil((self.contentWidth - VIDEOVIEW_GAP * 3) / 2);
            if (self.isWideScreen)
            {
                videoHeight = ceil(videoWidth * 9/16);
            }
            else
            {
                videoHeight = ceil(videoWidth * 3/4);
            }
        }
        else
        {
            // 在此调整视频大小和屏幕比例关系
            videoWidth = ceil((self.contentWidth - VIDEOVIEW_GAP * 3)/3);
            if (self.isWideScreen)
            {
                videoHeight = ceil(videoWidth * 9/16);
            }
            else
            {
                videoHeight = ceil(videoWidth * 3/4);
            }
            whitebordWidth = 2 * videoWidth;
            whitebordHeight = ceil(whitebordWidth * 3/4);
        }
    }
    else
    {
        CGFloat scale = 0;
        if (self.isWideScreen)
        {
            scale = 16.0/9.0;
        }
        else
        {
            scale = 4.0/3.0;
        }
        
        NSUInteger count = [self getVideoViewCount];
        videoTeacherWidth = ceil((self.contentWidth - VIDEOVIEW_GAP * 0.5 * 8)/7);
        videoTeacherHeight = ceil(videoTeacherWidth / scale);
        if (count < 8)
        {
            videoWidth = videoTeacherWidth;
            videoHeight = videoTeacherHeight;
        }
        else
        {
            videoHeight = ceil((videoTeacherHeight - VIDEOVIEW_GAP * 0.5)/2.0);
            videoWidth = ceil(videoHeight * scale);
        }
        
        if ((self.contentHeight - STATETOOLBAR_HEIGHT - videoTeacherHeight - VIDEOVIEW_GAP) * 2 >= self.contentWidth)
        {
            whitebordWidth = self.contentWidth;
            whitebordHeight = ceil(whitebordWidth/2);
        }
        else
        {
            whitebordHeight = ceil(self.contentHeight - STATETOOLBAR_HEIGHT - videoTeacherHeight - VIDEOVIEW_GAP);
            whitebordWidth = ceil(whitebordHeight * 2);
        }
    }
    [self freshWhitBordContentView];
}

- (void)freshContentView
{
    if (self.roomtype == YSRoomUserType_One)
    {
        if(self.videoViewArray.count>1)
        {
            self.userVideoView.hidden = YES;
        }
        else
        {
            self.userVideoView.hidden = NO;
            if (self.videoViewArray.count == 1)
            {
//                SCVideoView *videoView = self.videoViewArray.firstObject;
//                if (![videoView.roomUser.peerID isEqualToString:YSCurrentUser.peerID])
//                {
//                    [self.liveManager stopPlayVideo:YSCurrentUser.peerID completion:nil];
//                    [self.liveManager stopPlayAudio:YSCurrentUser.peerID completion:nil];
//                    if (videoView.roomUser.role == YSUserType_Student)
//                    {
//                        self.userVideoView.hidden = YES;
//                    }
//                }
//                else
//                {
//                    self.userVideoView.hidden = YES;
//                }
            }
        }
        
        if (self.roomLayout == YSRoomLayoutType_VideoLayout)
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
        if (self.roomLayout == YSRoomLayoutType_VideoLayout || self.roomLayout == YSRoomLayoutType_FocusLayout)
        {
            [self freshVidoeGridView];
            [self.raiseHandsBtn bm_bringToFront];
            [self.handNumLab bm_bringToFront];

        }
        else
        {
            CGFloat width = self.contentWidth;
            CGFloat height = self.contentHeight-STATETOOLBAR_HEIGHT;
            self.videoGridView.defaultSize = CGSizeMake(width, height);
            self.videoGridView.frame = CGRectMake(0, STATETOOLBAR_HEIGHT, width, height);
            [self.contentBackgroud addSubview:self.videoGridView];
//            [self.videoGridView bm_centerInSuperView];
            self.videoGridView.backgroundColor = [UIColor clearColor];
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
    
    [self.userVideoView removeFromSuperview];
    [self.videoBackgroud addSubview:self.userVideoView];
    NSMutableArray *viewArray = [[NSMutableArray alloc] init];
    [self.videoBackgroud.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull childView, NSUInteger idx, BOOL * _Nonnull stop) {
        [viewArray addObject:childView];
    }];
    
    for (SCVideoView *videoView in viewArray)
    {
        if (videoView.tag != PlaceholderPTag && videoView.tag != DoubleTeacherExpandContractBtnTag)
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
    
    if (self.isDoubleType && self.roomtype == YSRoomUserType_One)
    {
        [self doubleTeacherCalculateVideoSize];
        [self doubleTeacherArrangeVidoeView];
    }
    else
    {
        [self calculateVideoSize];
        [self arrangeVidoeView];
    }
}

///排布双师模式视图
- (void)doubleTeacherArrangeVidoeView
{
    for (NSUInteger i=0; i<self.videoViewArray.count; i++)
    {
        SCVideoView *view = self.videoViewArray[i];
        if (view.isFullScreen)
        {
            continue;
        }
        
        if (self.roomLayout == YSRoomLayoutType_VideoLayout)
        {//左右平行关系
            self.expandContractBtn.hidden = YES;
            if ([view.roomUser.peerID isEqualToString:YSCurrentUser.peerID])
            {
                view.frame = CGRectMake(0, 0, videoWidth, videoHeight);
            }
            else
            {
                view.frame = CGRectMake(VIDEOVIEW_GAP + videoWidth, 0, videoWidth, videoHeight);
            }
        }
        else
        {
            if (![self.doubleType bm_isNotEmpty] || [self.doubleType isEqualToString:@"abreast"])
            {//上下平行关系
                self.expandContractBtn.hidden = YES;
                if ([view.roomUser.peerID isEqualToString:YSCurrentUser.peerID])
                {
                    view.frame = CGRectMake(0, 0, videoWidth, videoHeight);
                }
                else
                {
                    view.frame = CGRectMake(0, videoHeight+VIDEOVIEW_GAP, videoWidth, videoHeight);
                }
                
                if (self.isWideScreen)
                {//16:9
                    
                    CGFloat orgainalY = (whitebordHeight - 2 * videoHeight - VIDEOVIEW_GAP)/2;
                    
                    if ([view.roomUser.peerID isEqualToString:YSCurrentUser.peerID])
                    {
                        view.frame = CGRectMake(0, orgainalY, videoWidth, videoHeight);
                    }
                    else
                    {
                        view.frame = CGRectMake(0, orgainalY + videoHeight + VIDEOVIEW_GAP, videoWidth, videoHeight);
                    }
                }
                else
                {//4:3
                    
                    if ([view.roomUser.peerID isEqualToString:YSCurrentUser.peerID])
                    {
                        view.frame = CGRectMake(0, 0, videoWidth, videoHeight);
                    }
                    else
                    {
                        view.frame = CGRectMake(0, videoHeight, videoWidth, videoHeight);
                    }
                }
            }
            else if([self.doubleType isEqualToString:@"nested"])
            {//画中画
                
                self.expandContractBtn.hidden = NO;
                
                if ([view.roomUser.peerID isEqualToString:YSCurrentUser.peerID])
                {
                    view.frame = CGRectMake(0, 0, videoTeacherWidth, videoTeacherHeight);
                }
                else
                {
                    view.frame = CGRectMake(videoTeacherWidth - videoWidth, 0, videoWidth, videoHeight);
                    self.studentVideoView = view;
                    self.expandContractBtn.selected = NO;
                    self.expandContractBtn.frame = CGRectMake(view.bm_originX-23, view.bm_originY, 23, videoHeight);
                    self.expandContractBtn.bm_right = view.bm_left;

                    [view bm_bringToFront];
                    [self.expandContractBtn bm_bringToFront];
                }
            }
        }
        [view bringSubviewToFront:view.backVideoView];
    }
}


///排布视图
- (void)arrangeVidoeView
{
    if (self.roomtype == YSRoomUserType_One)
    {
        for (NSUInteger i=0; i<self.videoViewArray.count; i++)
        {
            SCVideoView *view = self.videoViewArray[i];
            if (view.isFullScreen)
            {
                continue;
            }
            
            if (self.roomLayout == YSRoomLayoutType_VideoLayout)
            {//左右平行关系

                if ([view.roomUser.peerID isEqualToString:self.liveManager.teacher.peerID])
                {
                    view.frame = CGRectMake(VIDEOVIEW_GAP, 0, videoWidth, videoHeight);
                }
                else
                {
                    view.frame = CGRectMake(VIDEOVIEW_GAP * 2 + videoWidth, 0, videoWidth, videoHeight);
                }
            }
            else
            {//上下平行关系
                if (self.isWideScreen)
                {//16:9
                    CGFloat orgainalY = (whitebordHeight - 2 * videoHeight - VIDEOVIEW_GAP)/2;

                    if (view.roomUser.role == YSUserType_Teacher)
                    {
                        view.frame = CGRectMake(0, orgainalY, videoWidth, videoHeight);
                    }
                    else
                    {
                        CGRectMake(0, orgainalY + videoHeight + VIDEOVIEW_GAP, videoWidth, videoHeight);
                    }
                }
                else
                {//4:3
                    if (view.roomUser.role == YSUserType_Teacher)
                    {
                        view.frame = CGRectMake(0, 0, videoWidth, videoHeight);
                    }
                    else
                    {
                        view.frame = CGRectMake(0, videoHeight, videoWidth, videoHeight);
                    }
                }
            }
            [view bringSubviewToFront:view.backVideoView];
        }
    }
    else
    {
        CGFloat totalWidth = [self getVideoTotalWidth];
                
        videoStartX = (self.contentWidth-totalWidth)*0.5;
        
        NSInteger count = [self getVideoViewCount];
        
        NSUInteger index = 0;
        
        for (int i = 0; i < self.videoViewArray.count; i++)
        {
            SCVideoView *view = self.videoViewArray[i];

            if (view.isDragOut || view.isFullScreen)
            {
                continue;
            }
            if (count < 8)
            {
                view.frame = CGRectMake(videoStartX+(videoWidth+VIDEOVIEW_GAP*0.5)*index, VIDEOVIEW_GAP*0.5, videoWidth, videoHeight);
            }
            else if (count < 26)
            {
                // 老师没被拖出
                if (self.teacherVideoView && !self.teacherVideoView.isDragOut && !self.teacherVideoView.isFullScreen)
                {
                    if (i == 0)
                    {
                        view.frame = CGRectMake(videoStartX, VIDEOVIEW_GAP*0.5, videoTeacherWidth, videoTeacherHeight);
                    }
                    else
                    {
                        NSInteger lineNum = (index - 1) % 2;//学生的行数
                        NSInteger arrangeNum = (index - 1) / 2;//学生的列数
                        
                        CGFloat videoX = videoStartX + videoTeacherWidth + VIDEOVIEW_GAP * 0.5 + (videoWidth + VIDEOVIEW_GAP * 0.5) * arrangeNum;
                        CGFloat videoY = VIDEOVIEW_GAP*0.5 + (videoHeight + VIDEOVIEW_GAP * 0.5) * lineNum;
                        
                        view.frame = CGRectMake(videoX, videoY, videoWidth, videoHeight);
                    }
                }
                else
                {
                    NSInteger lineNum = index % 2;//学生的行数
                    NSInteger arrangeNum = index / 2;//学生的列数
                    
                    CGFloat videoX = videoStartX + VIDEOVIEW_GAP * 0.5 + (videoWidth + VIDEOVIEW_GAP * 0.5) * arrangeNum;
                    CGFloat videoY = VIDEOVIEW_GAP*0.5 + (videoHeight + VIDEOVIEW_GAP * 0.5) * lineNum;
                    
                    view.frame = CGRectMake(videoX, videoY, videoWidth, videoHeight);
                }
            }
            index++;
        }
    }
}

/// 刷新白板尺寸
- (void)freshWhitBordContentView
{
    if (self.roomtype == YSRoomUserType_One)
    {
        if (self.roomLayout == YSRoomLayoutType_VideoLayout)
        {//左右平行关系
            self.whitebordBackgroud.hidden = YES;
            
            self.videoBackgroud.frame = CGRectMake(whitebordWidth, 0, videoWidth, videoHeight);
            
            self.teacherVideoView.frame = CGRectMake(VIDEOVIEW_GAP, 0, videoWidth, videoHeight);
            self.userVideoView.frame = CGRectMake(VIDEOVIEW_GAP*2+videoWidth, 0, videoWidth, videoHeight);
            
        }
        else
        {//默认上下平行关系
            self.whitebordBackgroud.hidden = NO;
            
            if (![self.doubleType bm_isNotEmpty] || [self.doubleType isEqualToString:@"abreast"])
            {//默认上下平行关系
                self.whitebordBackgroud.frame = CGRectMake(0, 0, whitebordWidth, whitebordHeight);

                self.videoBackgroud.frame = CGRectMake(whitebordWidth + VIDEOVIEW_GAP, 0, videoWidth, whitebordHeight);
                
                if (self.isWideScreen)
                {//16:9
                    
                    CGFloat orgainalY = (whitebordHeight - 2 * videoHeight - VIDEOVIEW_GAP)/2;
                    
                    self.teacherVideoView.frame = CGRectMake(0, orgainalY, videoWidth, videoHeight);
//                    self.teacherPlacehold.frame = CGRectMake(0, orgainalY, videoWidth, videoHeight);
                    self.userVideoView.frame = CGRectMake(0, orgainalY + videoHeight + VIDEOVIEW_GAP, videoWidth, videoHeight);
                }
                else
                {//4:3
                    self.teacherVideoView.frame = CGRectMake(0, 0, videoWidth, videoHeight);
//                    self.teacherPlacehold.frame = CGRectMake(0, 0, videoWidth, videoHeight);
                    self.userVideoView.frame = CGRectMake(0, videoHeight, videoWidth, videoHeight);
                }
            }
            else if([self.doubleType isEqualToString:@"nested"])
            {//画中画
                
                CGFloat whitebordY = (self.contentHeight - STATETOOLBAR_HEIGHT - whitebordHeight)/2;
                
                self.whitebordBackgroud.frame = CGRectMake(0, whitebordY, whitebordWidth, whitebordHeight);
                self.videoBackgroud.frame = CGRectMake(whitebordWidth + VIDEOVIEW_GAP, whitebordY, videoTeacherWidth, whitebordHeight);
                
                self.teacherVideoView.frame = CGRectMake(0, 0, videoTeacherWidth, videoTeacherHeight);
                self.userVideoView.frame = CGRectMake(CGRectGetMaxX(self.teacherVideoView.frame)-videoWidth, 0, videoWidth, videoHeight);
                self.studentVideoView = self.userVideoView;
                
                self.expandContractBtn.selected = NO;
                self.expandContractBtn.frame = CGRectMake(self.userVideoView.bm_originX-23, self.userVideoView.bm_originY, 23, videoHeight);
                self.expandContractBtn.bm_right = self.userVideoView.bm_left;

                [self.userVideoView bm_bringToFront];
                [self.expandContractBtn bm_bringToFront];
                
            }
        }
    }
    else
    {
        self.videoBackgroud.frame = CGRectMake(0, 0, self.contentWidth, videoTeacherHeight + VIDEOVIEW_GAP);

        self.whitebordBackgroud.frame = CGRectMake((self.contentWidth - whitebordWidth)/2, self.videoBackgroud.bm_bottom, whitebordWidth, whitebordHeight);
    }
    
    [self freshWhiteBordViewFrame];
}

- (void)freshWhiteBordViewFrame
{
    if (self.isWhitebordFullScreen)
    {
//        self.whiteBordView.frame = self.whitebordFullBackgroud.bounds;
        self.whiteBordView.frame = CGRectMake(0, 0, self.whitebordFullBackgroud.bm_width, self.whitebordFullBackgroud.bm_height);
    }
    else
    {
        self.whiteBordView.frame = self.whitebordBackgroud.bounds;
    }

    [self.liveManager.whiteBoardManager refreshWhiteBoard];
}

// 刷新宫格视频布局
- (void)freshVidoeGridView
{
    [self hideAllDragOutVidoeView];
        
    NSMutableArray *viewArray = [[NSMutableArray alloc] init];
    [self.videoBackgroud.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull childView, NSUInteger idx, BOOL * _Nonnull stop) {
        [viewArray addObject:childView];
    }];
    
    for (SCVideoView *videoView in viewArray)
    {
        if (videoView.tag != DoubleTeacherExpandContractBtnTag)
        {
            [videoView removeFromSuperview];
        }
    }
    
//    if (self.videoViewArray.count<22)
//    {
//        for (int i = 0; i<22; i++)
//        {
//
//            YSRoomUser * user = [[YSRoomUser alloc]initWithPeerId:[NSString stringWithFormat:@"jjj%d",i]];
//            SCVideoView * video = [[SCVideoView alloc]initWithRoomUser:user];
//            [self.videoViewArray addObject:video];
//        }
//    }
//
//    [self.videoGridView freshViewWithVideoViewArray:self.videoViewArray withFouceVideo:self.fouceView withRoomLayout:self.roomLayout withAppUseTheType:self.appUseTheType];
    if (self.isDoubleType)
    {
        [self.videoGridView freshViewWithVideoViewArray:self.videoViewArray withFouceVideo:nil withRoomLayout:self.roomLayout withAppUseTheType:self.appUseTheType];
    }
    else
    {
        [self.videoGridView freshViewWithVideoViewArray:self.videoViewArray withFouceVideo:self.fouceView withRoomLayout:self.roomLayout withAppUseTheType:self.appUseTheType];
    }
        
    [self arrangeAllViewInContentBackgroudViewWithViewType:SCMain_ArrangeContentBackgroudViewType_VideoGridView index:0];
    self.contentView.hidden = YES;
    self.videoGridView.hidden = NO;
}


#pragma mark - videoViewArray

/// 开关摄像头
- (void)onRoomCloseVideo:(BOOL)close withUid:(NSString *)uid streamID:(NSString *)streamID
{
    [super onRoomCloseVideo:close withUid:uid streamID:streamID];
}

/// 开关麦克风
- (void)onRoomCloseAudio:(BOOL)close withUid:(NSString *)uid
{
    [super onRoomCloseAudio:close withUid:uid];
}

/// 收到音视频流
- (void)onRoomStartVideoOfUid:(NSString *)uid streamID:(nullable NSString *)streamID
{
    [super onRoomStartVideoOfUid:uid streamID:streamID];
}

/// 停止音视频流
- (void)onRoomStopVideoOfUid:(NSString *)uid streamID:(nullable NSString *)streamID
{
    [super onRoomStopVideoOfUid:uid streamID:streamID];
}

#pragma mark  添加视频窗口

- (SCVideoView *)addVidoeViewWithPeerId:(NSString *)peerId
{
    SCVideoView *newVideoView = [super addVidoeViewWithPeerId:peerId];
    
    [self.controlPopoverView dismissViewControllerAnimated:YES completion:nil];
    [self.upHandPopTableView dismissViewControllerAnimated:YES completion:nil];
    
    YSRoomUser *roomUser = [self.liveManager getRoomUserWithId:peerId];
    if (!roomUser)
    {
        return nil;
    }
    
    ///  轮播 设置上台的人在数组最后
    if (roomUser.role == YSUserType_Student)
    {
        if ([self.pollingArr containsObject:peerId])
        {
            [self.pollingArr removeObject:peerId];
            [self.pollingArr addObject:peerId];
        }
    }
    
    if (newVideoView)
    {
        /// 轮播相关逻辑
        if (roomUser.role == YSUserType_Student)
        {
            [self.pollingUpPlatformArr addObject:peerId];
        }
        if (_isPolling)
        {
            /// 台下无人时 停止轮播
            if (self.pollingUpPlatformArr.count == self.liveManager.studentCount)
            {
                [self.liveManager sendSignalingTeacherToStopVideoPolling];
            }
        }
    }
    
    [self freshContentView];
    
    return newVideoView;
}

#pragma mark  删除视频窗口

- (SCVideoView *)delVidoeViewWithPeerId:(NSString *)peerId
{
    SCVideoView *delVideoView = [super delVidoeViewWithPeerId:peerId];

    [self.controlPopoverView dismissViewControllerAnimated:YES completion:nil];
    [self.upHandPopTableView dismissViewControllerAnimated:YES completion:nil];
    
    if (delVideoView)
    {
        [self.pollingUpPlatformArr removeObject:peerId];///删除视频的同时删除轮播上台数据

        if (delVideoView.isDragOut)
        {
            [self hideDragOutVidoeViewWithPeerId:peerId];
        }
        else if (delVideoView.isFullScreen)
        {
            [self handleSignalingDragOutVideoChangeFullSizeWithPeerId:nil isFull:NO];
        }
        else
        {
            [self freshContentView];
        }
    }
    
    return delVideoView;
}

#pragma mark  删除所有视频窗口
- (void)removeAllVideoView
{
    [super removeAllVideoView];
    
    [self hideAllDragOutVidoeView];
}

- (void)kickedOutFromRoom:(NSUInteger)reasonCode
{
    NSString *reasonString = YSLocalized(@"KickOut.Repeat");//(@"KickOut.SentOutClassroom");
    
    [self.controlPopoverView dismissViewControllerAnimated:NO completion:nil];
    [self.upHandPopTableView dismissViewControllerAnimated:NO completion:nil];

    [self.imagePickerController cancelButtonClick];

    BMWeakSelf
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:reasonString message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confimAc = [UIAlertAction actionWithTitle:YSLocalized(@"Prompt.OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [weakSelf.liveManager leaveRoom:nil];
        
    }];
    [alertVc addAction:confimAc];
    [self presentViewController:alertVc animated:YES completion:nil];
}


#pragma mark -
#pragma mark YSLiveRoomManagerDelegate

/// 大并发房间
- (void)onRoomChangeToBigRoomInList:(BOOL)inlist
{
    BMWeakSelf
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.bigRoomTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(self.bigRoomTimer, DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    //3.要调用的任务
    dispatch_source_set_event_handler(self.bigRoomTimer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            BMStrongSelf
            [strongSelf freshTeacherPersonListData];
        });
    });
    //4.开始执行
    dispatch_resume(self.bigRoomTimer);
    [self bottomToolBarPollingBtnEnable];
#if DEBUG
    [self bringSomeViewToFront];
    [self.progressHUD bm_showAnimated:NO withDetailText:@"变更为大房间" delay:5];
#endif
}

- (void)onRoomConnectionLost
{
    [super onRoomConnectionLost];
    self.spreadBottomToolBar.userEnable = NO;
    [self.view bringSubviewToFront:self.spreadBottomToolBar];
//    [self removeAllVideoView];
//    
//    if (self.isWhitebordFullScreen)
//    {
//        [self boardControlProxyfullScreen:NO];
//    }
//    
//    [self handleSignalingDefaultRoomLayout];
}

- (void)onRoomReJoined
{
    [super onRoomReJoined];
    self.spreadBottomToolBar.userEnable = YES;
}


// 已经离开房间
- (void)onRoomLeft
{
    [super onRoomLeft];
    
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
    
    if (self.bigRoomTimer)
    {
        dispatch_source_cancel(self.bigRoomTimer);
        self.bigRoomTimer = nil;
    }

    [self.controlPopoverView dismissViewControllerAnimated:NO completion:nil];
    [self.upHandPopTableView dismissViewControllerAnimated:NO completion:nil];

    [self.imagePickerController cancelButtonClick];
    
    if (self.pollingTimer)
    {
        dispatch_source_cancel(self.pollingTimer);
        self.pollingTimer = nil;
    }
    // 网络中断尝试失败后退出
    [[BMNoticeViewStack sharedInstance] closeAllNoticeViews];// 清除alert的栈
    [self dismissViewControllerAnimated:YES completion:^{
#if YSSDK
        [self.liveManager onSDKRoomLeft];
#endif
        [YSLiveManager destroy];
    }];
}

- (void)handleSignalingToForceRefresh
{
    [self.liveManager sendSignalingTeacherToStopVideoPolling];
    if (self.pollingTimer)
    {
        dispatch_source_cancel(self.pollingTimer);
        self.pollingTimer = nil;
    }
    
    [self bottomToolBarPollingBtnEnable];

    self.spreadBottomToolBar.isPolling = NO;

    _isPolling = NO;
}


// 网络测速回调
// @param networkQuality 网速质量 (TKNetQuality_Down 测速失败)
// @param delay 延迟(毫秒)
- (void)onRoomNetworkQuality:(YSNetQuality)networkQuality delay:(NSInteger)delay
{
    if (networkQuality>YSNetQuality_VeryBad)
    {
        [self bringSomeViewToFront];
        [self.progressHUD bm_showAnimated:NO withDetailText:YSLocalized(@"Error.WaitingForNetwork") delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
    }
}

#pragma mark  用户进入
- (void)onRoomUserJoined:(YSRoomUser *)user isHistory:(BOOL)isHistory
{
    // 不做互踢
    if (user.role == YSUserType_Teacher)
    {
        if (isHistory == YES)
        {
            [self.liveManager evictUser:user.peerID reason:0];
        }
    }
    [self freshTeacherPersonListData];
        
    NSInteger userCount = self.liveManager.studentCount;
    self.handNumLab.text = [NSString stringWithFormat:@"%ld/%ld",(long)self.raiseHandArray.count,(long)userCount];
    for (YSRoomUser *user in self.liveManager.userList)
    {
        if (user.role == YSUserType_Student)
        {
            if (![self.pollingArr containsObject:user.peerID])
            {
                [self.pollingArr addObject:user.peerID];
            }
        }
    }
    [self bottomToolBarPollingBtnEnable];
    self.spreadBottomToolBar.isPolling = _isPolling;
}

/// 用户退出
- (void)onRoomUserLeft:(YSRoomUser *)user
{
    if (self.roomtype == YSRoomUserType_More)
    {
        [self delVidoeViewWithPeerId:user.peerID];
    }
    
    [self freshTeacherPersonListData];
    
    //焦点用户退出
    if ([self.fouceView.roomUser.peerID isEqualToString:user.peerID])
    {
        self.roomLayout = YSRoomLayoutType_VideoLayout;
        self.fouceView = nil;
        [self.liveManager sendSignalingToChangeLayoutWithLayoutType:self.roomLayout appUserType:self.appUseTheType withFouceUserId:self.fouceView.roomUser.peerID];
    }
    
    NSInteger userCount = self.liveManager.studentCount;

    self.handNumLab.text = [NSString stringWithFormat:@"%ld/%ld",(long)self.raiseHandArray.count,(long)userCount];
    
    /// 删除轮播字典里边的该学生
    if (user.role == YSUserType_Student)
    {
        if ([self.pollingArr containsObject:user.peerID])
        {
            [self.pollingArr removeObject:user.peerID];
        }
        if ([self.pollingUpPlatformArr containsObject:user.peerID])
        {
            [self.pollingUpPlatformArr removeObject:user.peerID];
        }
    }
 
    
    if (_isPolling)
    {
        NSInteger total = 0;
        for (YSRoomUser * user in self.liveManager.userList)
        {
            if (user.role == YSUserType_Student || user.role == YSUserType_Teacher)
            {
                total++;
            }
        }
        if (total < maxVideoCount)
        {
            [self.liveManager sendSignalingTeacherToStopVideoPolling];
        }
        
        /// 如果轮播发起者退出房间 则停止轮播
        if ([_pollingFromID isEqualToString:user.peerID])
        {
            _isPolling = NO;
            if (self.pollingTimer)
            {
                dispatch_source_cancel(self.pollingTimer);
                self.pollingTimer = nil;
            }
            
            [self bottomToolBarPollingBtnEnable];

            self.spreadBottomToolBar.isPolling = NO;
        }
    }
    else
    {
        [self bottomToolBarPollingBtnEnable];
    }
}

/// 大房间刷新用户数量
- (void)onRoomBigRoomFreshUserCountInList:(BOOL)inlist
{
    NSInteger userCount = self.liveManager.studentCount;
    self.handNumLab.text = [NSString stringWithFormat:@"%ld/%ld",(long)self.raiseHandArray.count,(long)userCount];
}

/// 自己被踢出房间
- (void)onRoomKickedOut:(NSInteger)reasonCode
{
    [super onRoomKickedOut:reasonCode];
    
    [self.controlPopoverView dismissViewControllerAnimated:NO completion:nil];
    [self.upHandPopTableView dismissViewControllerAnimated:NO completion:nil];

    [self.imagePickerController cancelButtonClick];
    
    if (classEndAlertVC)
    {
        BMWeakSelf
        [classEndAlertVC dismissViewControllerAnimated:YES completion:^{
            [weakSelf kickedOutFromRoom:reasonCode];
        }];
        return;
    }
    
    [self kickedOutFromRoom:reasonCode];
}

///所有举手用户的列表,刷新举手的人数
- (void)handleSignalingRaiseHandUserArray:(NSMutableArray *)raiseHandUserArray
{
    
    NSMutableArray * mutArray = [NSMutableArray array];
    for (SCVideoView * videoView in self.videoViewArray)
    {
        [mutArray addObject:videoView.roomUser];
    }
    
    if ([mutArray bm_isNotEmpty])
    {
        for (int i = 0; i<raiseHandUserArray.count; i++)
        {
            NSMutableDictionary * userDict = raiseHandUserArray[i];
            YSPublishState publishState = YSUser_PublishState_NONE;
            for (int j = 0; j<mutArray.count; j++)
            {
                YSRoomUser * videoUser = mutArray[j];
                
                if ([videoUser.peerID isEqualToString:[userDict bm_stringForKey:@"peerId"]])
                {
                    publishState = videoUser.publishState;
                    break;
                }
            }
            if (publishState > YSUser_PublishState_NONE)
            {
                [raiseHandUserArray removeObject:userDict];
                [userDict setValue:@(publishState) forKey:@"publishState"];
                [raiseHandUserArray addObject:userDict];
                break;
            }
        }
    }
    
        self.raiseHandArray = raiseHandUserArray;
        
        self.upHandPopTableView.userArr = self.raiseHandArray;
        
        if (self.raiseHandArray.count<1)
        {
            self.raiseHandsBtn.selected = NO;
            [self.upHandPopTableView dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            self.raiseHandsBtn.selected = YES;
        }
        
        self.handNumLab.text = [NSString stringWithFormat:@"%ld/%ld",(long)self.raiseHandArray.count,(long)self.liveManager.studentCount];
}

/// 全体禁言
- (void)handleSignalingToDisAbleEveryoneBanChatWithIsDisable:(BOOL)isDisable
{
    [super handleSignalingToDisAbleEveryoneBanChatWithIsDisable:isDisable];
    
    self.rightChatView.allDisabled = isDisable;
}

#pragma mark - 用户属性变化

- (void)onRoomUserPropertyChanged:(NSString *)userId fromeUserId:(NSString *)fromeUserId properties:(NSDictionary *)properties
{
    SCVideoView *videoView = [self getVideoViewWithPeerId:userId];
    YSRoomUser *roomUser = [self.liveManager getRoomUserWithId:userId];

    // 网络状态
    if ([properties bm_containsObjectForKey:sYSUserNetWorkState])
    {
        [videoView freshWithRoomUserProperty:roomUser];
    }
    
    // 举手上台
    if ([properties bm_containsObjectForKey:sYSUserRaisehand])
    {
        BOOL raisehand = [properties bm_boolForKey:sYSUserRaisehand];
        
        if (roomUser.publishState>0 && raisehand)
        {
            videoView.isRaiseHand = YES;
        }
        else
        {
            videoView.isRaiseHand = NO;
        }
    }
     
    // 奖杯数
    if ([properties bm_containsObjectForKey:sYSUserGiftNumber])
    {
        YSRoomUser *fromUser = [self.liveManager getRoomUserWithId:fromeUserId];
        if (fromUser.role != YSUserType_Student)
        {
            videoView.giftNumber =  [properties bm_uintForKey:sYSUserGiftNumber];
            [self showGiftAnimationWithVideoView:videoView];
        }
    }
    
    // 画笔颜色值
    if ([properties bm_containsObjectForKey:sYSUserPrimaryColor])
    {
        NSString *colorStr = [properties bm_stringTrimForKey:sYSUserPrimaryColor];
        if ([colorStr bm_isNotEmpty])
        {
            videoView.brushColor = colorStr;
        }
    }
    
    // 画笔权限
    if ([properties bm_containsObjectForKey:sYSUserCandraw])
    {
        videoView.canDraw = [properties bm_boolForKey:sYSUserCandraw];
        if ([userId isEqualToString:self.liveManager.localUser.peerID])
        {
            BOOL canDraw = YSCurrentUser.canDraw;//[properties bm_boolForKey:sUserCandraw];
                        
            if (self.roomLayout == YSRoomLayoutType_VideoLayout || self.roomLayout == YSRoomLayoutType_FocusLayout)
            {
                self.brushToolView.hidden = YES;
                self.brushToolOpenBtn.hidden = YES;
                self.drawBoardView.hidden = YES;
            }
            else
            {
                if (self.liveManager.isClassBegin)
                {
                    self.brushToolView.hidden = NO;
                    self.brushToolOpenBtn.hidden = NO;
                }

                if (self.brushToolOpenBtn.selected || self.brushToolView.mouseBtn.selected)
                {
                    self.drawBoardView.hidden = YES;
                }else
                {
                    self.drawBoardView.hidden = NO;
                }
            }

            // 设置画笔颜色初始值
            if (canDraw)
            {
                if (![[YSCurrentUser.properties bm_stringTrimForKey:sYSUserPrimaryColor] bm_isNotEmpty])
                {
                    [self setCurrentUserPrimaryColor];
                }
            }
            
            videoView.canDraw = canDraw;
        }
    }
    
    // 发布媒体状态
    if ([properties bm_containsObjectForKey:sYSUserPublishstate])
    {
        YSPublishState publishState = [properties bm_intForKey:sYSUserPublishstate];
//        YSRoomUser *user = [self.liveManager.roomManager getRoomUserWithUId:peerID];

        for (NSMutableDictionary *userDict in self.raiseHandArray)
        {
            if ([userDict bm_stringForKey:@"peerId"])
            {
                [userDict setValue:@(publishState) forKey:@"publishState"];
                self.upHandPopTableView.userArr = self.raiseHandArray;
                break;
            }
        }
                
#if 0
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
#endif
        
        //YSRoomUser * user = [[YSLiveManager shareInstance].roomManager getRoomUserWithUId:peerID];
        
        if (publishState == YSUser_PublishState_VIDEOONLY)
        {
            [self addVidoeViewWithPeerId:userId];
        }
        else if (publishState == YSUser_PublishState_AUDIOONLY)
        {
            [self addVidoeViewWithPeerId:userId];
        }
        else if (publishState == YSUser_PublishState_BOTH)
        {
            [self addVidoeViewWithPeerId:userId];
        }
        else if (publishState == 4)
        {
            [self addVidoeViewWithPeerId:userId];
        }
        else if (publishState != 4)
        {
            if (!self.liveManager.isClassBegin)
            {
                return;
            }
            [self delVidoeViewWithPeerId:userId];
            if (self.controlPopoverView.presentingViewController)
            {
                [self.controlPopoverView dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }
    
#if USE_FullTeacher
    if (roomUser.role == YSUserType_Teacher)
    {
        /// 老师中途进入房间上课时的全屏处理
        if (!self.whitebordFullBackgroud.hidden)
        {
            [self playFullTeacherVideoViewInView:self.whitebordFullBackgroud];
        }
        if (!self.shareVideoFloatView.hidden)
        {
            [self playFullTeacherVideoViewInView:self.shareVideoFloatView];
        }
    }
#endif

    // 进入前后台
    if ([properties bm_containsObjectForKey:sYSUserIsInBackGround])
    {
        [videoView freshWithRoomUserProperty:roomUser];
    }
    
    // 视频镜像
    if ([properties bm_containsObjectForKey:sYSUserIsVideoMirror])
    {
        NSString *streamID = [self.liveManager getUserStreamIdWithUserId:userId];
        BOOL isVideoMirror = [properties bm_boolForKey:sYSUserIsVideoMirror];
        CloudHubVideoMirrorMode videoMirrorMode = CloudHubVideoMirrorModeDisabled;
        if (isVideoMirror)
        {
            videoMirrorMode = CloudHubVideoMirrorModeEnabled;
        }
        
        [self.liveManager changeVideoWithUserId:userId streamID:streamID renderMode:CloudHubVideoRenderModeHidden mirrorMode:videoMirrorMode];
    }
    
//    YSRoomUser *fromUser = [self.liveManager.roomManager getRoomUserWithUId:fromId];
//    if (videoView)
//    {
//        [videoView changeRoomUserProperty:fromUser];
//    }
    
    /// 用户设备状态
    if ([properties bm_containsObjectForKey:sYSUserVideoFail] || [properties bm_containsObjectForKey:sYSUserAudioFail])
    {
        [videoView freshWithRoomUserProperty:roomUser];
    }

    if ([properties bm_containsObjectForKey:sYSUserPublishstate] || [properties bm_containsObjectForKey:sYSUserGiftNumber] || [properties bm_containsObjectForKey:sYSUserDisablechat])
    {
        if ((roomUser.role == YSUserType_Student) || (roomUser.role == YSUserType_Assistant))
        {
            [self freshTeacherPersonListData];
        }
    }
}

#pragma mark 切换网络 会收到onRoomJoined

- (void)onRoomJoined
{
    [super onRoomJoined];
}


#pragma mark 上课
//inlist表示在我进房间之前的信令
- (void)handleSignalingClassBeginWihInList:(BOOL)inlist
{
    self.classBeginBtn.userInteractionEnabled = YES;

    self.rightChatView.allDisabled = self.liveManager.isEveryoneBanChat;
    
    self.spreadBottomToolBar.isBeginClass = YES;
    [self bottomToolBarPollingBtnEnable];
    self.spreadBottomToolBar.isToolBoxEnable = YES;
    // 通知各端开始举手
    [self.liveManager sendSignalingToLiveAllAllowRaiseHand];
    
    [self.liveManager setPropertyOfUid:YSCurrentUser.peerID tell:YSCurrentUser.peerID propertyKey:sYSUserCandraw value:@(true)];
    
    self.classBeginBtn.selected = YES;

    [self freshTeacherPersonListData];
    self.brushToolView.hidden = NO;
    self.brushToolOpenBtn.hidden = NO;
    for (YSRoomUser *roomUser in self.liveManager.userList)
    {
#if 0
        if (needFreshVideoView)
        {
            needFreshVideoView = NO;
            break;
        }
#endif
        YSPublishState publishState = roomUser.publishState;
        NSString *peerID = roomUser.peerID;
        /// 轮播数组数组
        if (roomUser.role == YSUserType_Student)
        {
            if (![self.pollingArr containsObject:roomUser.peerID])
            {
                [self.pollingArr addObject:roomUser.peerID];
            }
        }
        
        if (publishState == YSUser_PublishState_VIDEOONLY)
        {
            [self addVidoeViewWithPeerId:peerID];
        }
        else if (publishState == YSUser_PublishState_AUDIOONLY)
        {
            [self addVidoeViewWithPeerId:peerID];
        }
        else if (publishState == YSUser_PublishState_BOTH)
        {
            [self addVidoeViewWithPeerId:peerID];
        }
        else if (publishState == YSUser_PublishState_ONSTAGE)
        {
            [self addVidoeViewWithPeerId:peerID];
        }
        else
        {
            [self delVidoeViewWithPeerId:peerID];
        }
    }
//    self.coursewareCurrentPage = self.liveManager.currentFile.pagenum.intValue;
//    if ([self.liveManager.currentFile.fileid isEqualToString:@"0"])
//    {
//        self.coursewareBtn.hidden = YES;
//    }
//    else
//    {
//        self.coursewareBtn.hidden = NO;
//    }
    
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
            BMStrongSelf
            [strongSelf countDownTime:nil];
        });
    });
    //4.开始执行
    dispatch_resume(self.topBarTimer);

    [self.liveManager setPropertyOfUid:YSCurrentUser.peerID tell:YSRoomPubMsgTellAll propertyKey:sYSUserPublishstate value:@(YSUser_PublishState_BOTH)];
    
    if (!inlist)
    {
        if (self.liveManager.mediaFileModel)
        {
            [self.liveManager stopShareOneMediaFile];
        }
    }
}

/// 下课

- (void)handleSignalingClassEndWithText
{
    [self classEndWithText:nil];
}

- (void)classEndWithText:(NSString *)text
{
    self.classBeginBtn.userInteractionEnabled = YES;

    // 老师取消订阅举手列表
    [self.liveManager sendSignalingToSubscribeAllRaiseHandMemberWithType:@"unsubSort"];
   
    [self.controlPopoverView dismissViewControllerAnimated:YES completion:nil];
    [self.upHandPopTableView dismissViewControllerAnimated:YES completion:nil];
    
    [self.imagePickerController cancelButtonClick];

    if (![text bm_isNotEmpty])
    {
        text = YSLocalized(@"Prompt.ClassEnd");
    }
    
    BMWeakSelf
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:text message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confimAc = [UIAlertAction actionWithTitle:YSLocalized(@"Prompt.OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [weakSelf.liveManager leaveRoom:nil];
        
    }];
    [alertVC addAction:confimAc];
    [self presentViewController:alertVC animated:YES completion:nil];
}

/// 弹框
- (void)showSignalingClassEndWithText:(NSString *)text
{
    [self.controlPopoverView dismissViewControllerAnimated:NO completion:nil];
    [self.upHandPopTableView dismissViewControllerAnimated:NO completion:nil];
    
    [self.imagePickerController cancelButtonClick];

    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:text message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confimAc = [UIAlertAction actionWithTitle:YSLocalized(@"Prompt.OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertVc addAction:confimAc];
    [self presentViewController:alertVc animated:YES completion:nil];
}

///老师订阅举手列表
- (void)handleSignalingAllowEveryoneRaiseHand
{
    [self.liveManager sendSignalingToSubscribeAllRaiseHandMemberWithType:@"subSort"];
}

/// 房间即将关闭消息
- (BOOL)handleSignalingPrepareRoomEndWithDataDic:(NSDictionary *)dataDic addReason:(YSPrepareRoomEndType)reason
{
    NSUInteger reasonCount = [dataDic bm_uintForKey:@"reason"];
    
    int  classDelay = 30;
    
    if ([dataDic bm_containsObjectForKey:@"classDelay"])
    {
        classDelay = [[dataDic objectForKey:@"classDelay"] intValue];
    }
    
    if (reason == YSPrepareRoomEndType_TeacherLeaveTimeout)
    {//老师离开房间时间过长

        if (reasonCount == 1)
        {
            [self showSignalingClassEndWithText:YSLocalized(@"Prompt.TeacherLeave8")];
        }
    }
    else
        if (reason == YSPrepareRoomEndType_RoomTimeOut)
    {//房间预约时间
        
        if (reasonCount == 2)
        {//表示房间预约时间已到，30分钟后房间即将关闭
            if (classDelay == 30)
            {
                [self showSignalingClassEndWithText:YSLocalized(@"Prompt.Appointment30")];
            }
            else if (classDelay > 0)
            {
                NSString * string = YSLocalized(@"Prompt.AppointmentN");
                 [self showSignalingClassEndWithText:[NSString stringWithFormat:string,classDelay]];
            }
            else if (classDelay == -1)
            {
                [self showSignalingClassEndWithText:YSLocalized(@"Prompt.Appointment_end")];
            }
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
        [self classEndWithText:YSLocalized(@"Prompt.ClassEndAppointment30")];
    }
    else if([reason isEqualToString:@"All the teachers left the room for more than 10 minutes"])
    {
        [self classEndWithText:YSLocalized(@"Prompt.ClassEndAnchorLeave10")];
    }
}

#pragma mark -刷新花名册数据
- (void)freshTeacherPersonListData
{
    [self freshTeacherPersonListDataNeedFesh:NO];
}

- (void)freshTeacherPersonListDataNeedFesh:(BOOL)fresh
{
    if (fresh || [self.spreadBottomToolBar nameListIsShow])
    {
        //花名册  有用户进入房间调用 上下课调用
        if (self.liveManager.isBigRoom)
        {
            BMWeakSelf
            NSInteger studentNum = self.liveManager.studentCount;
            NSInteger assistantNum = self.liveManager.assistantCount;
            [self.teacherListView setPersonListCurrentPage:_personListCurentPage totalPage:ceil((CGFloat)(studentNum + assistantNum)/(CGFloat)onePageMaxUsers)];
            [self.liveManager getRoomUsersWithRole:@[@(YSUserType_Assistant),@(YSUserType_Student)] startIndex:_personListCurentPage*onePageMaxUsers maxNumber:onePageMaxUsers search:@"" order:@{} callback:^(NSArray<YSRoomUser *> * _Nonnull users, NSError * _Nonnull error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                   // UI更新代码
                   [weakSelf.teacherListView setDataSource:users withType:SCBottomToolBarTypePersonList userNum:studentNum];
                });
            }];
        }
        else
        {
            NSInteger studentNum = self.liveManager.studentCount ;
            NSInteger assistantNum = self.liveManager.assistantCount;
            NSInteger listNumber = studentNum + assistantNum;
            NSInteger divide = ceil((CGFloat)listNumber / (CGFloat)onePageMaxUsers);
            //NSInteger remainder = listNumber % onePageMaxUsers;
            _personListTotalPage = divide;
            NSLog(@"_personListTotalPage: %@", @(_personListTotalPage));
            
            NSMutableArray *listArr = [NSMutableArray arrayWithCapacity:0];
            for (YSRoomUser *user in self.liveManager.userList)
            {
                if (user.role == YSUserType_Assistant || user.role == YSUserType_Student)
                {
                    [listArr addObject:user];
                }
            }
                         
            NSArray *data = [listArr bm_divisionWithCount:onePageMaxUsers atIndex:_personListCurentPage appoint:NO];
            
            [self.teacherListView setDataSource:data withType:SCBottomToolBarTypePersonList userNum:studentNum];

            [self.teacherListView setPersonListCurrentPage:_personListCurentPage totalPage:_personListTotalPage];
        }
    }
}

/// 双击视频最大化
- (void)handleSignalingDragOutVideoChangeFullSizeWithPeerId:(NSString *)peerId isFull:(BOOL)isFull;
{
    self.isDoubleVideoBig = isFull;
    if (isFull)
    {
        if (self.doubleFloatView)
        {
            [self handleSignalingDragOutVideoChangeFullSizeWithPeerId:nil isFull:NO];
        }
        
        SCVideoView *videoView = [self getVideoViewWithPeerId:peerId];
        videoView.isFullScreen = isFull;
        
        [self freshContentView];
        
        YSFloatView *floatView = [[YSFloatView alloc] initWithFrame:self.whitebordBackgroud.bounds];
        
        [self.whitebordBackgroud addSubview:floatView];
        [floatView bm_centerInSuperView];
        [floatView showWithContentView:videoView];
        self.doubleFloatView = floatView;

    }
    else
    {
        SCVideoView *videoView = (SCVideoView *)self.doubleFloatView.contentView;
        videoView.isFullScreen = NO;
        [self.doubleFloatView cleanContent];
        [self.doubleFloatView removeFromSuperview];
        [self freshContentView];
        self.doubleFloatView = nil;

    }
    
    if (!self.isWhitebordFullScreen)
    {
        self.brushToolView.hidden = isFull;
        self.brushToolOpenBtn.hidden = isFull;
    }

//    [self freshWhiteBordViewFrame];
}

#pragma mark 白板视频/音频

// 播放白板视频/音频
- (void)handleWhiteBordPlayMediaFileWithMedia:(YSSharedMediaFileModel *)mediaModel
{
    [self freshTeacherCoursewareListData];
    
    if (mediaModel.isVideo)
    {
        [self showWhiteBordVidoeViewWithMediaModel:mediaModel];
        self.spreadBottomToolBar.hidden = YES;
        self.brushToolView.hidden = YES ;
        self.brushToolOpenBtn.hidden = YES;
    }
    else
    {
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
- (void)handleWhiteBordStopMediaFileWithMedia:(YSSharedMediaFileModel *)mediaModel
{
    if (mediaModel.isVideo)
    {
        self.spreadBottomToolBar.hidden = NO;
        if (self.liveManager.isClassBegin)
        {
            self.brushToolView.hidden = (self.roomLayout == YSRoomLayoutType_VideoLayout) || (self.roomLayout == YSRoomLayoutType_FocusLayout);
            self.brushToolOpenBtn.hidden = (self.roomLayout == YSRoomLayoutType_VideoLayout) || (self.roomLayout == YSRoomLayoutType_FocusLayout);
        }

        [self hideWhiteBordVidoeViewWithMediaModel:mediaModel];
        if (self.liveManager.isClassBegin)
        {
            //[self.liveManager.whiteBoardManager clearVideoMark];
            [self.liveManager delMsg:sYSSignalVideoWhiteboard msgId:sYSSignalVideoWhiteboard to:YSRoomPubMsgTellAll];
        }
    }
    else
    {
        [self onStopMp3];
    }
    
    [self freshTeacherCoursewareListData];
}

/// 继续播放白板视频/音频
- (void)handleWhiteBordPlayMediaStream:(YSSharedMediaFileModel *)mediaFileModel
{
    if (mediaFileModel.isVideo)
    {
        if (!self.mp4ControlView.isPlay)
        {
            [self freshTeacherCoursewareListData];
        }
        self.mp4ControlView.isPlay = YES;
    }
    else
    {
        [self onPlayMp3];
        if (!self.mp3ControlView.isPlay)
        {
            [self freshTeacherCoursewareListData];
        }
        self.mp3ControlView.isPlay = YES;
    }
}

/// 暂停播放白板视频/音频
- (void)handleWhiteBordPauseMediaStream:(YSSharedMediaFileModel *)mediaFileModel
{
    if (mediaFileModel.isVideo)
    {
        if (self.mp4ControlView.isPlay)
        {
            [self freshTeacherCoursewareListData];
        }
        self.mp4ControlView.isPlay = NO;
    }
    else
    {
        if (self.mp3ControlView.isPlay)
        {
            [self freshTeacherCoursewareListData];
        }
        self.mp3ControlView.isPlay = NO;
    }
}
 
- (void)onRoomUpdateMediaStream:(NSTimeInterval)duration
                            pos:(NSTimeInterval)pos
                         isPlay:(BOOL)isPlay
{
    BMLog(@"onRoomUpdateMediaStream: %@, %@, %@", @(duration), @(pos), @(isPlay));
    if (pos == duration)
    {
        [self.liveManager stopShareOneMediaFile];
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
            if (self.liveManager.mediaFileModel.isVideo)
            {
                [self.mp4ControlView setMediaStream:duration pos:pos isPlay:isPlay fileName:self.liveManager.mediaFileModel.fileName];
            }
            else
            {
                [self.mp3ControlView setMediaStream:duration pos:pos isPlay:isPlay fileName:self.liveManager.mediaFileModel.fileName];
            }
        }

        isDrag = NO;
    }
}

#pragma mark -YSMp3ControlViewDelegate
- (void)playMp3ControlViewPlay:(BOOL)isPlay
{
    [self.liveManager pauseShareOneMediaFile:isPlay];
    isMediaPause = isPlay;
    [self freshTeacherCoursewareListData];
}

- (void)sliderMp3ControlView:(NSInteger)value
{
    isDrag = YES;
    [self.liveManager seekShareOneMediaFile:value];
}

- (void)closeMp3ControlView
{
    [self.liveManager stopShareOneMediaFile];
}

#pragma mark -YSMp4ControlViewDelegate

- (void)playYSMp4ControlViewPlay:(BOOL)isPlay
{
    [self.liveManager pauseShareOneMediaFile:isPlay];
    
    if (isPlay)
    {
        if (self.liveManager.isClassBegin)
        {
            YSSharedMediaFileModel *mediaFileModel = self.liveManager.mediaFileModel;
            [self.liveManager pubMsg:sYSSignalVideoWhiteboard msgId:sYSSignalVideoWhiteboard to:YSRoomPubMsgTellAll withData:@{@"videoRatio":@(mediaFileModel.width/mediaFileModel.height)} save:YES];
        }
    }
    else
    {
        if (self.liveManager.isClassBegin)
        {
            //[self.liveManager.whiteBoardManager clearVideoMark];
            [self.liveManager delMsg:sYSSignalVideoWhiteboard msgId:sYSSignalVideoWhiteboard to:YSRoomPubMsgTellAll];
        }
    }
}

- (void)sliderYSMp4ControlView:(NSInteger)value
{
    isDrag = YES;
    [self.liveManager seekShareOneMediaFile:value];
    if (self.liveManager.isClassBegin)
    {
        //[self.liveManager.whiteBoardManager clearVideoMark];
        [self.liveManager delMsg:sYSSignalVideoWhiteboard msgId:sYSSignalVideoWhiteboard to:YSRoomPubMsgTellAll];
    }
}

/// 显示白板视频标注
- (void)handleSignalingShowVideoWhiteboardWithData:(NSDictionary *)data videoRatio:(CGFloat)videoRatio
{
    if (![self.liveManager.whiteBoardManager isOneWhiteBoardView])
    {
        return;
    }
    if (self.shareVideoFloatView.hidden)
    {
        return;
    }
    
    if (self.mediaMarkView.superview)
    {
        [self.mediaMarkView removeFromSuperview];
    }
    
    self.mediaMarkView = [[YSMediaMarkView alloc] initWithFrame:self.shareVideoFloatView.bounds];
    [self.shareVideoFloatView addSubview:self.mediaMarkView];
    
    [self.mediaMarkView freshViewWithSavedSharpsData:self.mediaMarkSharpsDatas videoRatio:videoRatio];
    [self.mediaMarkSharpsDatas removeAllObjects];
}

/// 绘制白板视频标注
- (void)handleSignalingDrawVideoWhiteboardWithData:(NSDictionary *)data inList:(BOOL)inlist
{
    if (![self.liveManager.whiteBoardManager isOneWhiteBoardView])
    {
        return;
    }
    if (inlist)
    {
        [self.mediaMarkSharpsDatas addObject:data];
    }
    else
    {
        [self.mediaMarkView freshViewWithData:data savedSharpsData:self.mediaMarkSharpsDatas];
        [self.mediaMarkSharpsDatas removeAllObjects];
    }
}

/// 隐藏白板视频标注
- (void)handleSignalingHideVideoWhiteboard
{
    [self.mediaMarkSharpsDatas removeAllObjects];
    
    if (self.mediaMarkView.superview)
    {
        [self.mediaMarkView removeFromSuperview];
    }
}
#pragma mark -刷新课件库数据
- (void)freshTeacherCoursewareListData
{
    if ([self.spreadBottomToolBar coursewareListIsShow])
    {
        [self.teacherListView setDataSource:self.liveManager.fileList withType:SCBottomToolBarTypeCourseware userNum:self.liveManager.fileList.count currentFileList:self.currentFileList mediaFileID:self.liveManager.mediaFileModel.fileId mediaState:self.liveManager.mediaFileModel.state];
    }
}

- (void)onRoomStopLocalMediaFile:(NSString *)mediaFileUrl
{
    NSBundle *bundle = [NSBundle bundleWithPath: [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"YSResources.bundle"]];
    NSString *filePath = [[bundle resourcePath] stringByAppendingPathComponent:@"trophy_tones.mp3"];
    if ([mediaFileUrl isEqualToString:filePath])
    {
        giftMp3Playing = NO;
    }
}

- (void)showGiftAnimationWithVideoView:(SCVideoView *)videoView
{
    if (!videoView)
    {
        return;
    }
    
    NSBundle *bundle = [NSBundle bundleWithPath: [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"YSResources.bundle"]];
    NSString *filePath = [[bundle resourcePath] stringByAppendingPathComponent:@"trophy_tones.mp3"];
    
    if (!giftMp3Playing)
    {
        giftMp3Playing = [self.liveManager startPlayingMedia:filePath];
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
            CGPoint center = [self.contentBackgroud convertPoint:videoView.center fromView:videoView.superview];
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
    imageView.image = YSSkinDefineImage(@"main_giftshow");
    [self.contentBackgroud addSubview:imageView];
    [imageView bm_centerInSuperView];
    
    return imageView;
}

#if USE_FullTeacher

#pragma mark 全屏课件时可以拖动老师视频
- (void)panToMoveVideoView:(SCVideoView*)videoView withGestureRecognizer:(nonnull UIPanGestureRecognizer *)pan
{
    if ((self.roomtype == YSRoomUserType_One && ![videoView isEqual:self.fullTeacherVideoView]) || self.roomLayout == YSRoomLayoutType_VideoLayout || self.roomLayout == YSRoomLayoutType_FocusLayout)
    {
        [[PanGestureControl shareInfo] removePanGestureAction:LONG_PRESS_VIEW_DEMO];
        return;
    }
        
    UIView * background = self.whitebordBackgroud;
    
    if (self.isWhitebordFullScreen)
    {//课件全屏
        background = self.whitebordFullBackgroud;
    }
    else if (!self.shareVideoFloatView.hidden)
    {
        background = self.shareVideoFloatView;
    }
    
    self.dragingVideoView = videoView;
    
    CGPoint endPoint = [pan translationInView:videoView];
    
    if (!self.dragImageView)
    {
        UIImage * img = [self.dragingVideoView bm_screenshot];
        self.dragImageView = [[UIImageView alloc]initWithImage:img];
        [background addSubview:self.dragImageView];
    }
    
    if (self.videoOriginInSuperview.x == 0 && self.videoOriginInSuperview.y == 0)
    {
        self.videoOriginInSuperview = [background convertPoint:CGPointMake(0, 0) fromView:videoView];
        [background bringSubviewToFront:self.dragImageView];
    }
    self.dragImageView.frame = CGRectMake(self.videoOriginInSuperview.x + endPoint.x, self.videoOriginInSuperview.y + endPoint.y, videoView.bm_width, videoView.bm_height);
    
    if (pan.state == UIGestureRecognizerStateEnded)
    {
         [[PanGestureControl shareInfo] removePanGestureAction:LONG_PRESS_VIEW_DEMO];
        
        CGFloat percentLeft = 0;
        if (background.bm_width != videoView.bm_width && background.bm_width != (videoView.bm_width + 2) )
        {
            percentLeft = (self.videoOriginInSuperview.x+endPoint.x)/(background.bm_width - 2 - videoView.bm_width);
        }
        else
        {
            percentLeft = 0.00;
        }
        CGFloat percentTop = 0;
        if (background.bm_height != videoView.bm_height && background.bm_height != (videoView.bm_height + 2))
        {
            if ((self.videoOriginInSuperview.y+endPoint.y) < 0)
            {
                percentTop = -1;
            }
            else
            {
                percentTop = (self.videoOriginInSuperview.y+endPoint.y)/(background.bm_height - 2 - videoView.bm_height);
            }
        }
        else
        {
            if ((self.videoOriginInSuperview.y+endPoint.y) < 0)
            {
                percentTop = -1;
            }
            else
            {
                percentTop = 0;
            }
        }
        
        CGFloat videoEndX = self.videoOriginInSuperview.x+endPoint.x;
        CGFloat videoEndY = self.videoOriginInSuperview.y+endPoint.y;
        
        if (percentLeft > 1)
        {
            percentLeft = 1.00;
            videoEndX = background.bm_width - 2 - videoView.bm_width;
        }
        else if (percentLeft<0)
        {
            percentLeft = 0.00;
            videoEndX = 1;
        }
        if (percentTop > 1)
        {
            percentTop = 1.00;
            videoEndY = background.bm_height - 2 - videoView.bm_height;
        }

        if (self.isWhitebordFullScreen || !self.shareVideoFloatView.hidden)
        {//课件全屏
            if (percentTop <= 0)
            {
                percentTop = 0;
                videoEndY = 1;
            }
            [self showDragOutFullTeacherVidoeViewWithPeerId:nil videoX:videoEndX videoY:videoEndY];
        }
        else
        {//不全屏
            
            if (percentTop < 0 && abs((int)videoEndY) > videoView.bm_height * 0.3)
            {
                NSDictionary * data = @{
                    @"isDrag":@0,
                    @"userId":videoView.roomUser.peerID
                };
//                [self.liveManager sendSignalingToDragOutVideoViewWithData:data];
                [self.liveManager sendSignalingTopinchVideoViewWithPeerId:videoView.roomUser.peerID withData:data];
                
                [self.dragImageView removeFromSuperview];
                self.dragImageView = nil;
                self.videoOriginInSuperview = CGPointZero;
                return;
            }
            else
            {
                if (percentTop <= 0)
                {
                    videoEndY = 1;
                }
                if (percentLeft == 0)
                {
                    videoEndX = 1;
                }
                             
                YSFloatView * floatV = [self getVideoFloatViewWithPeerId:videoView.roomUser.peerID];
                
                NSDictionary * data = @{
                    @"isDrag":@1,
                    @"percentLeft":[NSString stringWithFormat:@"%f",percentLeft],
                    @"percentTop":[NSString stringWithFormat:@"%f",percentTop],
                    @"userId":videoView.roomUser.peerID,
                    @"scale":@(floatV.endScale)
                };
//                [self.liveManager sendSignalingToDragOutVideoViewWithData:data];
                [self.liveManager sendSignalingTopinchVideoViewWithPeerId:videoView.roomUser.peerID withData:data];
                [self showDragOutFullTeacherVidoeViewWithPeerId:videoView.roomUser.peerID videoX:videoEndX videoY:videoEndY];
            }
        }
        
        [self.dragImageView removeFromSuperview];
        self.dragImageView = nil;
        self.videoOriginInSuperview = CGPointZero;
    }
    else if (pan.state == UIGestureRecognizerStateCancelled || pan.state == UIGestureRecognizerStateFailed || pan.state == UIGestureRecognizerStateRecognized)
    {
        [self.dragImageView removeFromSuperview];
        self.dragImageView = nil;
        self.videoOriginInSuperview = CGPointZero;
    }
}

// 拖拽视频（包括全屏课件时拖老师）
- (void)showDragOutFullTeacherVidoeViewWithPeerId:(NSString *)peerId videoX:(CGFloat)videoX videoY:(CGFloat)videoY
{
    if (self.roomLayout == YSRoomLayoutType_VideoLayout)
    {
        return;
    }

    SCVideoView *videoView = nil;
    BOOL dragOut = NO;
    CGFloat whitebordH = 0;
    
    if (self.isWhitebordFullScreen || !self.shareVideoFloatView.hidden)
    {
        videoView = self.fullTeacherVideoView;
        dragOut = self.isFullTeacherVideoViewDragout;
//        whitebordH = self.whitebordFullBackgroud.bm_height;
        whitebordH = self.contentWidth;
    }
    else
    {
        videoView = [self getVideoViewWithPeerId:peerId];
        dragOut = videoView.isDragOut;
        whitebordH = self.whitebordBackgroud.bm_height;
    }

    if (dragOut)
    {
        YSFloatView *floatView = (YSFloatView *)(videoView.superview.superview);
        floatView.frame = CGRectMake(videoX, videoY, videoView.bm_width, videoView.bm_height);
        [floatView bm_bringToFront];
        
        return;
    }
    else
    {
        if (self.isWhitebordFullScreen || !self.shareVideoFloatView.hidden)
        {
            self.isFullTeacherVideoViewDragout = YES;
            self.fullTeacherFloatView.frame = CGRectMake(videoX, videoY, floatVideoDefaultWidth, floatVideoDefaultHeight);
            self.fullTeacherFloatView.hidden = NO;
            // 支持本地拖动缩放
            self.fullTeacherFloatView.canGestureRecognizer = YES;
            [self.fullTeacherFloatView bm_bringToFront];
            self.fullTeacherFloatView.minSize = CGSizeMake(floatVideoMinWidth, floatVideoMinHeight);
            self.fullTeacherFloatView.maxSize = self.whitebordFullBackgroud.bm_size;
            self.fullTeacherFloatView.peerId = YSCurrentUser.peerID;
        }
        else
        {
            videoView.isDragOut = YES;
            [self freshContentVidoeView];
            YSFloatView *floatView = [[YSFloatView alloc] initWithFrame:CGRectMake(videoX, videoY, floatVideoDefaultWidth, floatVideoDefaultHeight)];
            // 暂时不支持本地拖动缩放
            floatView.canGestureRecognizer = YES;
            //[floatView showWithContentView:videoView];
            [self.dragOutFloatViewArray addObject:floatView];
            [self.whitebordBackgroud addSubview:floatView];
            
            [floatView showWithContentView:videoView];
            //[floatView stayMove];
            [floatView bm_bringToFront];
            floatView.minSize = CGSizeMake(floatVideoMinWidth, floatVideoMinHeight);
            floatView.maxSize = self.whitebordBackgroud.bm_size;
            floatView.peerId = peerId;
        }
    }
}
#endif

#pragma mark 拖出/放回视频窗口
- (void)handleSignalingDragOutAndChangeSizeVideoWithPeerId:(NSString *)peerId WithData:(NSDictionary *)data
{
    BOOL isDragOut = [data bm_boolForKey:@"isDrag"];
    
    if (isDragOut)
    {
        [self showDragOutVidoeViewWithData:data];
    }
    else
    {
        [self hideDragOutVidoeViewWithPeerId:peerId];
    }
}


// 拖出视频
- (void)showDragOutVidoeViewWithData:(NSDictionary *)data
{
    if (self.roomLayout == YSRoomLayoutType_VideoLayout)
    {
        return;
    }
    NSString *peerId = [data bm_stringForKey:@"userId"];

    CGFloat percentLeft = [data bm_floatForKey:@"percentLeft"];
    
    CGFloat percentTop = [data bm_floatForKey:@"percentTop"];
    
    CGFloat endScale = [data bm_floatForKey:@"scale"];
    
    SCVideoView *videoView = [self getVideoViewWithPeerId:peerId];
    
    if (videoView.isDragOut)
    {
        YSFloatView *floatView = (YSFloatView *)(videoView.superview.superview);
        CGSize floatViewSize = [self dragOutVideoChangeSizeWithFloatView:floatView withScale:endScale];
        
        CGFloat x = percentLeft * (self.whitebordBackgroud.bm_width - floatViewSize.width);
        CGFloat y = percentTop * (self.whitebordBackgroud.bm_height - floatViewSize.height);
        
//
        floatView.frame = CGRectMake(x, y, floatViewSize.width, floatViewSize.height);
        [floatView bm_bringToFront];
        return;
    }
    else
    {
        videoView.isDragOut = YES;
        [self freshContentVidoeView];
        
        CGFloat x = percentLeft * (self.whitebordBackgroud.bm_width - floatVideoDefaultWidth);
        CGFloat y = percentTop * (self.whitebordBackgroud.bm_height - floatVideoDefaultHeight);
        
        YSFloatView *floatView = [[YSFloatView alloc] initWithFrame:CGRectMake(x, y, floatVideoDefaultWidth, floatVideoDefaultHeight)];
        floatView.peerId = peerId;
        // 暂时不支持本地拖动缩放
        [self.dragOutFloatViewArray addObject:floatView];
        [self.whitebordBackgroud addSubview:floatView];
        floatView.minSize = CGSizeMake(floatVideoMinWidth, floatVideoMinHeight);
        floatView.maxSize = self.whitebordBackgroud.bm_size;
        floatView.canGestureRecognizer = YES;

        [floatView showWithContentView:videoView];
        [floatView bm_bringToFront];
    }
}


/// 拖出视频窗口拉伸 根据本地默认尺寸scale
- (CGSize )dragOutVideoChangeSizeWithFloatView:(YSFloatView *)floatView withScale:(CGFloat)scale
{
    CGFloat widthScale = self.whitebordBackgroud.bm_width / floatVideoMinWidth;
    CGFloat heightScale = self.whitebordBackgroud.bm_height / floatVideoMinHeight;
    
    CGFloat minscale = widthScale < heightScale ? widthScale : heightScale;
    minscale = minscale < scale ? minscale : scale;
    CGFloat width = floatVideoMinWidth * minscale;
    CGFloat height = floatVideoMinHeight * minscale;
    
//    CGPoint center = floatView.center;
    
    floatView.bm_size = CGSizeMake(width, height);
//    floatView.center = center;
    
    if (floatView.bm_top < 0.0f)
    {
        floatView.bm_top = 0.0f;
    }
    if (floatView.bm_left < 0.0f)
    {
        floatView.bm_left = 0.0f;
    }
    if (floatView.bm_top+height > self.whitebordBackgroud.bm_height)
    {
        [floatView bm_setHeight:height bottom:self.whitebordBackgroud.bm_height];
    }
    if (floatView.bm_left+width > self.whitebordBackgroud.bm_width)
    {
        [floatView bm_setWidth:width right:self.whitebordBackgroud.bm_width];
    }
    return floatView.bm_size;
}

#pragma mark floatVideo

- (void)calculateFloatVideoSize
{
    // 在此调整视频大小和屏幕比例关系
    CGFloat scale = 0.0;
    if (self.isWideScreen)
    {
        scale = 16.0/9.0;
    }
    else
    {
        scale = 4.0/3.0;
    }
    
    /// 悬浮默认视频高(拖出和共享)
    floatVideoDefaultHeight = ceil(self.whiteBordView.bm_height / 3);
    /// 悬浮默认视频宽(拖出和共享)
    floatVideoDefaultWidth = ceil(floatVideoDefaultHeight * scale);
    
    floatVideoMinHeight = ceil(self.whiteBordView.bm_height / 6);
    floatVideoMinWidth = ceil(floatVideoMinHeight * scale);
}

// 放回视频
- (void)hideDragOutVidoeViewWithPeerId:(NSString *)peerId
{
    if (self.roomLayout == YSRoomLayoutType_VideoLayout)
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
    if (self.roomtype == YSRoomUserType_One)
    {
        newColorStr = @"#FF0000";
    }
    else
    {
        NSUInteger index = arc4random() % colorArray.count;
        newColorStr = colorArray[index];
    }
    [self.liveManager setPropertyOfUid:YSCurrentUser.peerID tell:YSRoomPubMsgTellAll propertyKey:sYSUserPrimaryColor value:newColorStr];

    [self.liveManager.whiteBoardManager changePrimaryColorHex:newColorStr];
}

#pragma mark 共享桌面

/// 开始桌面共享 服务端控制与课件视频/音频互斥
- (void)onRoomStartShareDesktopWithUserId:(NSString *)userId streamID:(NSString *)streamID
{
    [self.view endEditing:YES];
    _isMp4Play = NO;
    
    [self.liveManager playVideoWithUserId:userId streamID:streamID renderMode:CloudHubVideoRenderModeFit mirrorMode:CloudHubVideoMirrorModeDisabled inView:self.shareVideoView];
    
    [self arrangeAllViewInVCView];
    self.shareVideoFloatView.canZoom = YES;
    self.shareVideoFloatView.showWaiting = NO;
    self.shareVideoFloatView.hidden = NO;
#if USE_FullTeacher
    [self playFullTeacherVideoViewInView:self.shareVideoFloatView];
#endif
}

/// 停止桌面共享
- (void)onRoomStopShareDesktopWithUserId:(NSString *)userId streamID:(NSString *)streamID
{
    _isMp4Play = NO;
    [self.liveManager stopVideoWithUserId:userId streamID:streamID];
    
    self.shareVideoFloatView.canZoom = NO;
    self.shareVideoFloatView.backScrollView.zoomScale = 1.0;
    self.shareVideoFloatView.hidden = YES;
#if USE_FullTeacher
    [self stopFullTeacherVideoView];
    
    if (!self.whitebordFullBackgroud.hidden)
    {
        [self playFullTeacherVideoViewInView:self.whitebordFullBackgroud];
    }
#endif
}





#pragma mark 进入前台后台

/// 老师不发送进入前台后台
/// 进入后台
//
- (void)handleEnterBackground
{
//    [[YSRoomInterface instance] changeUserProperty:YSCurrentUser.peerID tellWhom:YSRoomPubMsgTellAll key:sUserIsInBackGround value:@1 completion:nil];
    [[PanGestureControl shareInfo] removePanGestureAction:LONG_PRESS_VIEW_DEMO];
}

#if 0
/// 进入前台
- (void)handleEnterForeground
{
    [[YSRoomInterface instance] changeUserProperty:YSCurrentUser.peerID tellWhom:YSRoomPubMsgTellAll key:sUserIsInBackGround value:@0 completion:nil];
}
#endif

#pragma mark - 顶部bar 定时操作
- (void)countDownTime:(NSTimer *)timer
{
    NSTimeInterval time = self.liveManager.tCurrentTime - self.liveManager.tClassBeginTime;
    NSString *str =  [NSDate bm_countDownENStringDateFromTs:time];
    self.lessonTime = str;
}


// 开始播放课件视频
- (void)showWhiteBordVidoeViewWithMediaModel:(YSSharedMediaFileModel *)mediaModel
{
    _isMp4Play = YES;
    [self.view endEditing:YES];
    self.mp4ControlView.hidden = NO;
    self.closeMp4Btn.hidden = NO;
    
    [self.liveManager playVideoWithUserId:mediaModel.senderId streamID:mediaModel.streamID renderMode:CloudHubVideoRenderModeFit mirrorMode:CloudHubVideoMirrorModeDisabled inView:self.shareVideoView];

    //[self arrangeAllViewInContentBackgroudViewWithViewType:SCMain_ArrangeContentBackgroudViewType_ShareVideoFloatView index:0];
    
    [self arrangeAllViewInVCView];
    self.shareVideoFloatView.canZoom = NO;
    self.shareVideoFloatView.backScrollView.zoomScale = 1.0;
    self.shareVideoFloatView.showWaiting = YES;
    self.shareVideoFloatView.hidden = NO;
    
#if USE_FullTeacher
    [self playFullTeacherVideoViewInView:self.shareVideoFloatView];
#endif
}

// 关闭课件视频
- (void)hideWhiteBordVidoeViewWithMediaModel:(YSSharedMediaFileModel *)mediaModel
{
    _isMp4Play = NO;
    if (mediaModel.isVideo)
    {
        [self.liveManager stopVideoWithUserId:mediaModel.senderId streamID:mediaModel.streamID];
    }
    
    self.shareVideoFloatView.canZoom = NO;
    self.shareVideoFloatView.backScrollView.zoomScale = 1.0;
    self.shareVideoFloatView.hidden = YES;
    self.mp4ControlView.hidden = YES;
    self.closeMp4Btn.hidden = YES;
#if USE_FullTeacher
    [self stopFullTeacherVideoView];
    if (!self.whitebordFullBackgroud.hidden)
    {
        [self playFullTeacherVideoViewInView:self.whitebordFullBackgroud];
    }
#endif
}

#pragma mark -
#pragma mark YSWhiteBoardManagerDelegate


#pragma mark 白板翻页 换课件

/// 媒体课件状态
- (void)handleonWhiteBoardMediaFileStateWithFileId:(NSString *)fileId state:(YSMediaState)state
{
    [self freshTeacherCoursewareListData];
}

/// 当前展示的课件列表（fileid）
- (void)handleonWhiteBoardChangedFileWithFileList:(NSArray *)fileList
{
    BMLog(@"%@",fileList);
    [self.currentFileList removeAllObjects];
    [self.currentFileList addObjectsFromArray:fileList];
    [self freshTeacherCoursewareListData];
    
}

// 课件全屏
- (void)handleonWhiteBoardFullScreen:(BOOL)isAllScreen
{
    self.isWhitebordFullScreen = isAllScreen;
    
    if (isAllScreen)
    {
        [self.view endEditing:YES];
                
        [self.whiteBordView removeFromSuperview];
        
        self.whitebordFullBackgroud.hidden = NO;
        // 加载白板
        [self.whitebordFullBackgroud addSubview:self.whiteBordView];
        self.whiteBordView.frame = CGRectMake(0, 0, self.whitebordFullBackgroud.bm_width, self.whitebordFullBackgroud.bm_height );
        [self arrangeAllViewInVCView];
        
#if USE_FullTeacher
        [self playFullTeacherVideoViewInView:self.whitebordFullBackgroud];
        
#endif
    }
    else
    {
        [self.whiteBordView removeFromSuperview];
        self.whitebordFullBackgroud.hidden = YES;
        
        [self.whitebordBackgroud addSubview:self.whiteBordView];
        self.whiteBordView.frame = self.whitebordBackgroud.bounds;
        
        [self arrangeAllViewInWhiteBordBackgroud];
        
        if (self.liveManager.isClassBegin)
        {
            self.brushToolView.hidden = self.isDoubleVideoBig || (self.roomLayout == YSRoomLayoutType_VideoLayout);
            self.brushToolOpenBtn.hidden = self.isDoubleVideoBig || (self.roomLayout == YSRoomLayoutType_VideoLayout);
        }

        
#if USE_FullTeacher
        [self stopFullTeacherVideoView];
#endif

    }
    
    [self.liveManager.whiteBoardManager refreshWhiteBoard];
    [self.liveManager.whiteBoardManager whiteBoardResetEnlarge];
}

// 课件最大化
- (void)handleonWhiteBoardMaximizeView
{
    [self.spreadBottomToolBar closeToolBar];
}
#pragma mark -
#pragma mark 底部Bar -- SCTeacherTopBarDelegate

- (void)bottomToolBarSpreadOut:(BOOL)spreadOut
{
    
}
/// 功能点击
- (void)bottomToolBarClickAtIndex:(SCBottomToolBarType)teacherTopBarType isSelected:(BOOL)isSelected
{
    switch (teacherTopBarType)
    {
        case SCBottomToolBarTypePersonList:
        {
            
            //                [self.bottomToolBar setMessageOpen:NO];
            //花名册  有用户进入房间调用 上下课调用
            [self freshListViewWithSelect:isSelected];
            [self freshTeacherPersonListDataNeedFesh:YES];
            [self.teacherListView bm_bringToFront];
        }
            break;
            
        case SCBottomToolBarTypeCourseware:
        {
            //课件库
            [self freshListViewWithSelect:isSelected];
            
            [self.teacherListView setDataSource:self.liveManager.fileList withType:SCBottomToolBarTypeCourseware userNum:self.liveManager.fileList.count currentFileList:self.currentFileList mediaFileID:self.liveManager.mediaFileModel.fileId mediaState:self.liveManager.mediaFileModel.state];
            
            [self.teacherListView bm_bringToFront];
        }
            break;
        case SCBottomToolBarTypeToolBox:
        {
            //工具箱
            self.toolBoxView = [[YSToolBoxView alloc] init];
            [self.toolBoxView showToolBoxViewInView:self.view backgroundEdgeInsets:UIEdgeInsetsZero topDistance:0 userRole:self.liveManager.localUser.role];
            self.toolBoxView.delegate = self;
            
        }
            break;
        case SCBottomToolBarTypeSwitchLayout:
        {
            //切换布局
            [self changeLayoutWithMode:isSelected];
        }
            break;
        case SCBottomToolBarTypePolling:
        {
            //轮播
            if (_isPolling)
            {
                
                [self.liveManager sendSignalingTeacherToStopVideoPolling];
            }
            else
            {
                self.teacherPollingView = [[YSPollingView alloc] init];
                [self.teacherPollingView showTeacherPollingViewInView:self.view backgroundEdgeInsets:UIEdgeInsetsZero topDistance:0];
                self.teacherPollingView.delegate = self;
            }
        }
            break;
        case SCBottomToolBarTypeAllNoAudio:
        {
            // 全体静音
            [self.liveManager sendSignalingTeacherToLiveAllNoAudio:isSelected];
            
        }
            break;
        case SCBottomToolBarTypeCamera:
        {
            //摄像头
            [self.liveManager useFrontCamera:!isSelected];
        }
            break;
        case SCBottomToolBarTypeChat:
        {
            //消息
            CGRect tempRect = self.rightChatView.frame;
            if (isSelected)
            {//弹出
                tempRect.origin.x = BMUI_SCREEN_WIDTH-tempRect.size.width;
                //收回 课件表 以及 花名册
                [self freshListViewWithSelect:NO];
            }
            else
            {//收回
                tempRect.origin.x = BMUI_SCREEN_WIDTH;
            }
            [UIView animateWithDuration:0.25 animations:^{
                self.rightChatView.frame = tempRect;
            }];
            [self arrangeAllViewInVCView];
        }
            break;
        case SCBottomToolBarTypeExit:
        {
            //退出
            [self backAction:nil];
        }
            break;
            
        default:
            break;
    }
    
}

// 是否弹出课件库 以及 花名册  select  yes--弹出  no--收回
- (void)freshListViewWithSelect:(BOOL)select
{
    CGRect tempRect = self.teacherListView.frame;
    if (select)
    {//弹出
        tempRect.origin.x = 0;
        
        //收回聊天
        [self.spreadBottomToolBar hideMessageView];
        CGRect chatViewRect = self.rightChatView.frame;
        chatViewRect.origin.x = BMUI_SCREEN_WIDTH;
        [UIView animateWithDuration:0.25 animations:^{
            self.rightChatView.frame = chatViewRect;
        }];
    }
    else
    {//收回
        tempRect.origin.x = BMUI_SCREEN_WIDTH;
        [self.spreadBottomToolBar hideListView];
    }
    [UIView animateWithDuration:0.25 animations:^{
        self.teacherListView.frame = tempRect;
    }];
}

/// 轮播按钮 是否可点击  如果教室当前人数小于座位席人数上限（例如1vn教室的n），则轮播功能无法开启,此时轮播按钮置灰色，人数大于等于时可启动；
- (void)bottomToolBarPollingBtnEnable
{
    
    /// 1.开始上课  2.用户进入    3.用户离开(是否要在此做判断 例如：轮播过程中用户退出少于最大上台数 是否关闭轮播)
    /// 大房间的时候一直不能用
    if (self.liveManager.isBigRoom)
    {
        self.spreadBottomToolBar.isPollingEnable = NO;
        return;
    }
    NSInteger total = 0;
    for (YSRoomUser * user in self.liveManager.userList)
    {
        if (user.role == YSUserType_Student || user.role == YSUserType_Teacher)
        {
            total++;
        }
    }
    
    self.spreadBottomToolBar.isPollingEnable = total >= maxVideoCount;
    
}

#pragma mark 切换布局模式
- (void)changeLayoutWithMode:(BOOL)mode
{
    if (mode)
    {
        //全体复位
        for (YSRoomUser * user in self.liveManager.userList)
        {
            NSDictionary * data = @{
                @"isDrag":@0,
                @"userId":user.peerID
            };
//            [self.liveManager sendSignalingToDragOutVideoViewWithData:data];
            [self.liveManager sendSignalingTopinchVideoViewWithPeerId:user.peerID withData:data];
        }
        
        if (self.isDoubleVideoBig)
        {
            [self.liveManager deleteSignalingToDoubleClickVideoView];
        }
    }
    
    //NO:上下布局  YES:左右布局
    if (self.appUseTheType == YSRoomUseTypeMeeting)
    {
        YSRoomLayoutType roomLayout = YSRoomLayoutType_VideoLayout;
        if (!mode)
        {
            roomLayout = YSRoomLayoutType_AroundLayout;
        }
        [self.liveManager sendSignalingToChangeLayoutWithLayoutType:roomLayout appUserType:YSRoomUseTypeMeeting withFouceUserId:nil];
    }
    else
    {
        YSRoomLayoutType roomLayout = YSRoomLayoutType_VideoLayout;
        if (!mode)
        {
            roomLayout = YSRoomLayoutType_AroundLayout;
        }
        [self.liveManager sendSignalingToChangeLayoutWithLayoutType:roomLayout];
    }
}

#pragma mark 切换窗口布局变化
- (void)handleSignalingSetRoomLayout:(YSRoomLayoutType)roomLayout withPeerId:(nullable NSString *)peerId
{
    //NO:上下布局  YES:左右布局
    self.roomLayout = roomLayout;
    
    if (!self.isWhitebordFullScreen && self.liveManager.isClassBegin)
    {
        self.brushToolView.hidden = (self.roomLayout == YSRoomLayoutType_VideoLayout) || (self.roomLayout == YSRoomLayoutType_FocusLayout);
        self.brushToolOpenBtn.hidden = (self.roomLayout == YSRoomLayoutType_VideoLayout) || (self.roomLayout == YSRoomLayoutType_FocusLayout);
    }
    self.spreadBottomToolBar.isBeginClass = YES;
    
    self.spreadBottomToolBar.isAroundLayout = (self.roomLayout == YSRoomLayoutType_AroundLayout);
    
    if (roomLayout == YSRoomLayoutType_FocusLayout && peerId)
    {
        for (SCVideoView *videoView in self.videoViewArray)
        {
            if ([videoView.roomUser.peerID isEqualToString:peerId])
            {
                self.fouceView = videoView;
                break;
            }
        }
        if (![self.fouceView bm_isNotEmpty])
        {
            self.roomLayout = YSRoomLayoutType_VideoLayout;
        }
    }
    
    [self freshContentView];
}

- (void)handleSignalingDefaultRoomLayout
{
    [self handleSignalingSetRoomLayout:defaultRoomLayout withPeerId:nil];
}

#pragma mark - UIPopoverPresentationControllerDelegate
- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
    return YES;
}


#pragma mark -
#pragma mark 工具箱 YSToolBoxViewDelegate

/// 关闭工具箱
- (void)closeToolBoxView
{
    [self.spreadBottomToolBar hideToolBoxView];
}
- (void)toolBoxViewClickAtToolBoxType:(SCToolBoxType)toolBoxType
{
    [self.spreadBottomToolBar hideToolBoxView];
    switch (toolBoxType)
    {
        case SCToolBoxTypeAnswer:
        {
            /// 答题器
            [self.liveManager sendSignalingTeacherToAnswerOccupyed];
        }
            break;
        case SCToolBoxTypeAlbum:
        {
            /// 上传图片
            [self openTheImagePickerWithImageUseType:SCUploadImageUseType_Document];
        }
            break;
        case SCToolBoxTypeTimer:
        {
            /// 计时器
            [self.liveManager sendSignalingTeacherToStartTimerWithTime:300 isStatus:false isRestart:false isShow:false defaultTime:300];
        }
            break;
        case SCToolBoxTypeResponder:
        {
            /// 抢答器
            self.responderView = [[YSTeacherResponder alloc] init];
            [self.responderView showYSTeacherResponderType:YSTeacherResponderType_Start inView:self.view backgroundEdgeInsets:UIEdgeInsetsZero topDistance:0];
            [self.responderView showResponderWithType:YSTeacherResponderType_Start];
            self.responderView.delegate = self;
        }
            break;
        default:
            break;
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
        
        [weakSelf.liveManager sendSignalingTeacherToAnswerWithOptions:submitArr answerID:answerId];
        
    };
    
    self.answerView.closeBlock = ^(BOOL isAnswerIng) {
        [weakSelf.liveManager sendSignalingTeacherToDeleteAnswerWithAnswerID:answerId];
        [weakSelf.liveManager sendSignalingTeacherToDeleteAnswerPublicResult];
    };
}
#pragma mark 收到答题卡
- (void)handleSignalingSendAnswerWithAnswerId:(NSString *)answerId options:(NSArray *)options startTime:(NSInteger)startTime fromID:(NSString *)fromID
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
    if (![fromID isEqualToString:self.liveManager.localUser.peerID])
    {
        [self.answerResultView hideOpenResult:YES];
        [self.answerResultView hideEndAgainBtn:YES];
//        [self.answerResultView hideCloseBtn:YES];
    }
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
                weakSelf.answerDetailTimer = nil;
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
            weakSelf.answerTimer = nil;
        }
       
        if (!isOpen)
        {
            [weakSelf getAnswerDetailDataWithAnswerID:answerId];
        }
        
        [weakSelf.liveManager sendSignalingTeacherToAnswerGetResultWithAnswerID:answerId];//获取结果
        
        [weakSelf.liveManager sendSignalingTeacherToDeleteAnswerWithAnswerID:answerId];
    };
    
    self.answerResultView.closeBlock = ^(BOOL isAnswerIng) {
      
        if (isAnswerIng)
        {
            [weakSelf.liveManager sendSignalingTeacherToDeleteAnswerWithAnswerID:answerId];
        }
        else
        {
            [weakSelf.liveManager sendSignalingTeacherToDeleteAnswerPublicResult];
        }
 
    };
    
    //先获取一次结果
    [self.liveManager sendSignalingTeacherToAnswerGetResultWithAnswerID:answerId];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.answerTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(self.answerTimer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    //3.要调用的任务
    dispatch_source_set_event_handler(self.answerTimer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            BMStrongSelf
            [strongSelf answer_countDownTime:nil answerID:answerId];
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
        [self.liveManager sendSignalingTeacherToAnswerGetResultWithAnswerID:answerID];
    }
    NSString *str =  [NSDate bm_countDownENStringDateFromTs:time];
    self.answerResultView.timeStr = str;

}

/// 获取答题中的 详情数据
- (void)getAnswerDetailDataWithAnswerID:(NSString *)answerId
{
    BMAFHTTPSessionManager *manager = [BMAFHTTPSessionManager manager];
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
//                    YSRoomUser *user = [weakSelf.liveManager.roomManager getRoomUserWithUId:userID];
//                    NSString *userName = user.nickName;
                    NSInteger ts = [dic bm_intForKey:@"ts"];
                    NSTimeInterval time = ts - self->_answerStartTime;
                    NSString *timestr =  [NSDate bm_countDownENStringDateFromTs:time];
                    
                    NSDictionary *data = [YSSessionUtil convertWithData:[dic bm_stringForKey:@"data"]];
//                    NSDictionary *data = [dic bm_dictionaryForKey:@"data"];
                    NSString *userName = [data bm_stringForKey:@"nickname"];
                    NSString *selectOpts = [data bm_stringForKey:@"selectOpts"];
                    [tempDic setValue:userName forKey:@"studentname"];
                    [tempDic setValue:timestr forKey:@"timestr"];
                    [tempDic setValue:selectOpts forKey:@"selectOpts"];
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
    [self.liveManager sendSignalingTeacherToAnswerPublicResultWithAnswerID:answerId selecteds:self.answerStatistics duration:duration detailData:detailData totalUsers:_totalUsers];
}

///收到答题中的统计结果
- (void)handleSignalingTeacherAnswerGetResultWithAnswerId:(NSString *)answerId totalUsers:(NSInteger)totalUsers values:(nonnull NSDictionary *)values
{
    BMLog(@"%@",answerId);
    _totalUsers = totalUsers;
    for (NSString *key in self.answerStatistics.allKeys)
    {
        [self.answerStatistics setValue:@"0" forKey:key];
    }
    for (NSString *key in values)
    {
        [self.answerStatistics setValue:values[key] forKey:key];
    }
//    if (_isOpenResult)
//    {
//        //为了处理公布答案的情况
//        [self getAnswerDetailDataWithAnswerID:answerId ];
//        return;
//    }
    
    [self.answerResultView setAnswerStatistics:self.answerStatistics totalUsers:totalUsers rightResult:self.rightAnswer];
}

/// 答题结束
- (void)handleSignalingAnswerEndWithAnswerId:(NSString *)answerId fromID:(NSString *)fromID
{
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
    BMWeakSelf
    if (self.liveManager.isBigRoom)
    {

#warning BigRoom
//        [self.liveManager getRoomUserWithPeerId:fromID callback:^(YSRoomUser * _Nullable user, NSError * _Nullable error) {
//
//            dispatch_async(dispatch_get_main_queue(), ^{
//
//                [weakSelf answerResultViewWithUser:user answerId:answerId];
//
//            });
//        }];
    }
    else
    {
        YSRoomUser *user = [weakSelf.liveManager getRoomUserWithId:fromID];
        [self answerResultViewWithUser:user answerId:answerId];
        
    }
//    if ([fromID isEqualToString:self.liveManager.teacher.peerID])
//    {
//
//
//    }
//    else
//    {
//
//        [[BMNoticeViewStack sharedInstance] closeAllNoticeViews];
//        self.answerResultView = [[SCTeacherAnswerView alloc] init];
//        [self.answerResultView showTeacherAnswerViewType:SCTeacherAnswerViewType_Statistics inView:self.view backgroundEdgeInsets:UIEdgeInsetsZero topDistance:0];
//        [self.answerResultView setAnswerStatistics:self.answerStatistics totalUsers:_totalUsers rightResult:self.rightAnswer];
//        self.answerResultView.isAnswerIng = NO;
//        [self.answerResultView hideEndAgainBtn:NO];
//        self.answerResultView.againBlock = ^{
//            [weakSelf.answerResultView dismiss:nil animated:NO dismissBlock:nil];
//            // 删除答题结果信令
//            [weakSelf.liveManager sendSignalingTeacherToDeleteAnswerPublicResultCompletion:nil];
//            // 重新开始
//            [weakSelf.liveManager sendSignalingTeacherToAnswerOccupyedCompletion:nil];
//        };

//    }

}
- (void)answerResultViewWithUser:(YSRoomUser *)user answerId:(NSString *)answerId
{
    BMWeakSelf
    if (user.role == YSUserType_Assistant)
    {
        [[BMNoticeViewStack sharedInstance] closeAllNoticeViews];
    }
    else
    {
        self.answerResultView.isAnswerIng = NO;
        [self.answerResultView hideEndAgainBtn:NO];
        [self.answerResultView hideOpenResult:YES];
        self.answerResultView.againBlock = ^{
            [weakSelf.answerResultView dismiss:nil animated:NO dismissBlock:nil];
            // 删除答题结果信令
            [weakSelf.liveManager sendSignalingTeacherToDeleteAnswerPublicResult];
            // 重新开始
            [weakSelf.liveManager sendSignalingTeacherToAnswerOccupyed];
        };
        
        if (_isOpenResult)
        {
            //为了处理公布答案的情况
            [self getAnswerDetailDataWithAnswerID:answerId];
        }
        
    }
}

/// 答题结果
- (void)handleSignalingAnswerPublicResultWithAnswerId:(NSString *)answerId resault:(NSDictionary *)resault durationStr:(NSString *)durationStr answers:(NSArray *)answers totalUsers:(NSUInteger)totalUsers fromID:(NSString *)fromID
{
    
    [[BMNoticeViewStack sharedInstance] closeAllNoticeViews];
    self.answerResultView = [[SCTeacherAnswerView alloc] init];
    [self.answerResultView showTeacherAnswerViewType:SCTeacherAnswerViewType_Statistics inView:self.view backgroundEdgeInsets:UIEdgeInsetsZero topDistance:0];
    self.answerResultView.isAnswerIng = NO;
    if ([fromID isEqualToString:self.liveManager.teacher.peerID])
    {
        [self.answerResultView hideEndAgainBtn:NO];
    }
    else
    {
        [self.answerResultView hideEndAgainBtn:YES];
    }

    [self.answerResultView setAnswerResultWithStaticsDic:resault detailArr:answers duration:durationStr rightOption:self.rightAnswer totalUsers:totalUsers];
    
    BMWeakSelf
    
    self.answerResultView.closeBlock = ^(BOOL isAnswerIng) {
        [weakSelf.liveManager sendSignalingTeacherToDeleteAnswerWithAnswerID:answerId];
        [weakSelf.liveManager sendSignalingTeacherToDeleteAnswerPublicResult];
    };
    
    self.answerResultView.againBlock = ^{
        [weakSelf.answerResultView dismiss:nil animated:NO dismissBlock:nil];
        // 删除答题结果信令
        [weakSelf.liveManager sendSignalingTeacherToDeleteAnswerPublicResult];
        // 重新开始
        [weakSelf.liveManager sendSignalingTeacherToAnswerOccupyed];
    };
}

/// 答题结果关闭
- (void)handleSignalingDelAnswerResultWithAnswerId:(NSString *)answerId
{
    [[BMNoticeViewStack sharedInstance] closeAllNoticeViews];
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

#pragma mark -
///全体静音 发言
- (void)handleSignalingliveAllNoAudio:(BOOL)noAudio
{
    allNoAudio = noAudio;
}


#pragma mark -
#pragma mark 抢答器 YSTeacherResponderDelegate
- (void)startClickedWithUpPlatform:(BOOL)upPlatform
{
    autoUpPlatform = upPlatform;
    [self.liveManager sendSignalingTeacherToStartResponder];
    contestCommitNumber = 0;
    contestPeerId = @"";
}

- (void)againClicked
{
    [self.responderView showResponderWithType:YSTeacherResponderType_Start];
    [self.responderView setProgress:0.0f];
    autoUpPlatform = NO;
}

- (void)teacherResponderCloseClicked
{
    [self.liveManager sendSignalingTeacherToCloseResponder];
    [self.responderView dismiss:nil animated:NO dismissBlock:nil];
    [[BMCountDownManager manager] stopCountDownIdentifier:YSTeacherResponderCountDownKey];
}

/// 老师/助教收到 showContest
- (void)handleSignalingShowContestFromID:(NSString *)fromID
{
//    老师/助教发起抢答排序 Contest(pubMsg)，并订阅抢答排序ContestSubsort(pubMsg)
//    if (!self.responderView)
//    {
    [self.responderView dismiss:nil animated:NO dismissBlock:nil];
        self.responderView = [[YSTeacherResponder alloc] init];
        [self.responderView showYSTeacherResponderType:YSTeacherResponderType_Start inView:self.view backgroundEdgeInsets:UIEdgeInsetsZero topDistance:0];
        [self.responderView showResponderWithType:YSTeacherResponderType_Start];
        self.responderView.delegate = self;
//    }
//    if ([fromID isEqualToString:self.liveManager.localUser.peerID])
    {
         [self.liveManager sendSignalingTeacherToContestResponderWithMaxSort:300];
    }
}

/// 收到抢答排序
- (void)handleSignalingContestFromID:(NSString *)fromID
{
    [self.responderView dismiss:nil animated:NO dismissBlock:nil];
    BMWeakSelf
//    if (!self.responderView)
//    {
        self.responderView = [[YSTeacherResponder alloc] init];
        [self.responderView showYSTeacherResponderType:YSTeacherResponderType_Start inView:self.view backgroundEdgeInsets:UIEdgeInsetsZero topDistance:0];
        [self.responderView showResponderWithType:YSTeacherResponderType_Start];
        self.responderView.delegate = self;
//    }

    
    /// 订阅抢答排序
//    if ([fromID isEqualToString:self.liveManager.localUser.peerID])
    {
        [self.liveManager sendSignalingTeacherToContestSubsortWithMin:1 max:300];
    }
    
    [[BMCountDownManager manager] startCountDownWithIdentifier:YSTeacherResponderCountDownKey timeInterval:10 processBlock:^(id  _Nonnull identifier, NSInteger timeInterval, BOOL forcedStop) {
        BMLog(@"%ld", (long)timeInterval);
        [weakSelf.responderView setCloseBtnHide:YES];
        [weakSelf.responderView showResponderWithType:YSTeacherResponderType_ING];
        
        NSInteger total = 0;
        if (weakSelf.liveManager.isBigRoom)
        {
            NSInteger studentNum = self.liveManager.studentCount;
            total = studentNum;
        }
        else
        {
            for (YSRoomUser * user in weakSelf.liveManager.userList)
            {
                if (user.role == YSUserType_Student)
                {
                    total++;
                }
            }
        }
        
        NSString *totalNumber = [NSString stringWithFormat:@"%@",@(total)];
        [weakSelf.responderView setPersonNumber:[NSString stringWithFormat:@"%@",@(self->contestCommitNumber)] totalNumber:totalNumber];
        CGFloat progress = (10 - timeInterval) / 10.0f;
        [weakSelf.responderView setProgress:progress];
        
        if (timeInterval == 0)
        {
            [weakSelf.responderView showResponderWithType:YSTeacherResponderType_Result];
            [weakSelf.responderView setCloseBtnHide:NO];
            NSString *totalNumber = [NSString stringWithFormat:@"%@",@(total)];
            [weakSelf.responderView setPersonNumber:[NSString stringWithFormat:@"%@",@(self->contestCommitNumber)] totalNumber:totalNumber];;//用于传人数
            CGFloat progress = 0.0f;
            [weakSelf.responderView setProgress:progress];
            
            if (self->contestCommitNumber == 0)
            {
                [self.responderView setPersonName:[NSString stringWithFormat:@"%@",YSLocalized(@"Res.lab.fail")]];
//                if ([fromID isEqualToString:self.liveManager.localUser.peerID])
                 {
                     [weakSelf.liveManager sendSignalingTeacherToContestResultWithName:@""];
                     [weakSelf.liveManager sendSignalingTeacherToCancelContestSubsort];
                     [weakSelf.liveManager sendSignalingTeacherToDeleteContest];
                 }
                
            }
            
            if (self->contestCommitNumber > 0)
            {
                if (weakSelf.liveManager.isBigRoom)
                {

#warning BigRoom
//                    [weakSelf.liveManager getRoomUserWithPeerId:self->contestPeerId callback:^(YSRoomUser * _Nullable user, NSError * _Nullable error) {
//
//                        dispatch_async(dispatch_get_main_queue(), ^{
//
//                            [weakSelf showContestResultWithRoomUser:user fromID:fromID];
//
//                        });
//                    }];
                }
                else
                {
                    YSRoomUser *user = [weakSelf.liveManager getRoomUserWithId:self->contestPeerId];
                    [weakSelf showContestResultWithRoomUser:user fromID:fromID];
                }
            }
        }
    }];
}

/// 展示抢答结果 并确定是否自动上台
- (void)showContestResultWithRoomUser:(YSRoomUser *)user fromID:(NSString *)fromID
{
    [self.responderView setPersonName:user.nickName];
    
//    if ([fromID isEqualToString:self.liveManager.teacher.peerID])
    {
        [self.liveManager sendSignalingTeacherToContestResultWithName:user.nickName];
        if (self.videoViewArray.count < self->maxVideoCount)
        {
            if (self->autoUpPlatform && user.publishState == YSUser_PublishState_NONE)
            {
                if (self->allNoAudio)
                {
                    [self.liveManager setPropertyOfUid:user.peerID tell:YSRoomPubMsgTellAll propertyKey:sYSUserPublishstate value:@(YSUser_PublishState_VIDEOONLY)];
                }
                else
                {
                    [self.liveManager setPropertyOfUid:user.peerID tell:YSRoomPubMsgTellAll propertyKey:sYSUserPublishstate value:@(YSUser_PublishState_BOTH)];
                }
            }
        }
        else
        {
            [BMProgressHUD bm_showHUDAddedTo:self.view animated:YES withDetailText:YSLocalized(@"Error.UpPlatformMemberOverRoomLimit") delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
        }
        
    }
    
    [self.liveManager sendSignalingTeacherToCancelContestSubsort];
    [self.liveManager sendSignalingTeacherToDeleteContest];
}

/// 收到学生抢答
- (void)handleSignalingContestCommitWithData:(NSArray *)data
{
// data     @{peerId : nickName}
    contestCommitNumber = data.count;
    NSInteger total = 0;
    if (self.liveManager.isBigRoom)
    {
        NSInteger studentNum = self.liveManager.studentCount;
        total = studentNum;
    }
    else
    {
        for (YSRoomUser * user in self.liveManager.userList)
        {
            if (user.role == YSUserType_Student)
            {
                total++;
            }
        }
    }

    NSString *totalNumber = [NSString stringWithFormat:@"%@",@(total)];

    [self.responderView setPersonNumber:[NSString stringWithFormat:@"%@",@(contestCommitNumber)] totalNumber:totalNumber];
    if ([data bm_isNotEmpty])
    {
        NSDictionary *contestUset = data.firstObject;
        NSString *peerID = contestUset.allKeys.firstObject;
        contestPeerId = peerID;
    }

}

/// 收到抢答结果
- (void)handleSignalingContestResultWithName:(NSString *)name
{
    /// 取消订阅抢答排序
    [self.responderView setCloseBtnHide:NO];
//    [self.liveManager sendSignalingTeacherToCancelContestSubsortCompletion:nil];

}

/// 收到取消订阅排序
-(void)handleSignalingCancelContestSubsort
{
//    结束抢答排序
//    [self.liveManager sendSignalingTeacherToDeleteContestCompletion:nil];
}
// 结束抢答排序
-(void)handleSignalingDelContest
{
    
}

/// 关闭答题器
- (void)handleSignalingToCloseResponder
{
    [self.responderView dismiss:nil animated:NO dismissBlock:nil];
    [[BMCountDownManager manager] stopCountDownIdentifier:YSTeacherResponderCountDownKey];
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
    self.teacherTimerView.pauseBtn.selected = YES;
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
    self.teacherTimerView.pauseBtn.selected = NO;
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
    [self.liveManager sendSignalingTeacherToStartTimerWithTime:time isStatus:YES isRestart:YES isShow:YES defaultTime:timer_defaultTime];
}

/// 暂停继续
- (void)pasueWithTime:(NSInteger)time pasue:(BOOL)pasue
{
    [self.liveManager sendSignalingTeacherToStartTimerWithTime:time isStatus:!pasue isRestart:NO isShow:YES defaultTime:timer_defaultTime];
}


/// 计时中重置
- (void)resetWithTIme:(NSInteger)time pasue:(BOOL)pasue
{
    
    [self.liveManager sendSignalingTeacherToStartTimerWithTime:timer_defaultTime isStatus:!pasue isRestart:YES isShow:YES defaultTime:timer_defaultTime];
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

    [self.liveManager sendSignalingTeacherToDeleteTimer];
}


#pragma mark -
#pragma mark 轮播
- (void)closePollingView
{
    if (self.pollingTimer)
    {
        dispatch_source_cancel(self.pollingTimer);
        self.pollingTimer = nil;
    }
}

- (void)startPollingWithTime:(NSInteger)time
{
    _isPolling = YES;
    [self.liveManager sendSignalingTeacherToStartVideoPollingWithUserID:self.liveManager.localUser.peerID];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.pollingTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    dispatch_source_set_timer(self.pollingTimer, DISPATCH_TIME_NOW, time * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    //3.要调用的任务
    BMWeakSelf
    dispatch_source_set_event_handler(self.pollingTimer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [weakSelf pollingUpPlatform];
        });
    });
    //4.开始执行
    dispatch_resume(self.pollingTimer);
    [self.teacherPollingView dismiss:nil animated:NO dismissBlock:nil];

    
}

- (void)pollingUpPlatform
{
    YSRoomUser *roomUser = nil;
    for (NSString *tempPeerID in self.pollingArr)
    {
        SCVideoView *videoView = [self getVideoViewWithPeerId:tempPeerID];
        if (videoView)
        {
            if (!(videoView.isDragOut || [videoView.roomUser.peerID isEqualToString: self.liveManager.teacher.peerID]))
            {
                
                roomUser = [self.liveManager getRoomUserWithId:tempPeerID];
                break;
            }
        }
        else
        {
            roomUser = [self.liveManager getRoomUserWithId:tempPeerID];
            break;
        }

    }
    
    if (!roomUser)
    {
        return;
    }
    if (roomUser.role == YSUserType_Student)
    {
//        if (roomUser.publishState == YSUser_PublishState_NONE)
        {
            if (self.videoViewArray.count < maxVideoCount)
            {
                
                [self changeUpPlatformRoomUser:roomUser];
            }
            else
            {
                NSString *upPlatformPeerId = @"";
                for (NSString *peerId in self.pollingUpPlatformArr)
                {
                    SCVideoView *videoView = [self getVideoViewWithPeerId:peerId];
                    if (videoView)
                    {
                        if (!(videoView.isDragOut || [videoView.roomUser.peerID isEqualToString: self.liveManager.teacher.peerID]))
                        {
                            upPlatformPeerId = videoView.roomUser.peerID;
                            
                            break;
                        }
                    }

                }
                BMLog(@"----------%@~~~~~%@",upPlatformPeerId,roomUser.peerID);
                [self.liveManager setPropertyOfUid:upPlatformPeerId tell:YSRoomPubMsgTellAll properties:@{sYSUserPublishstate : @(YSUser_PublishState_NONE),sYSUserCandraw : @(false)}];

                if ([upPlatformPeerId bm_isNotEmpty])
                {
                    [self changeUpPlatformRoomUser:roomUser];
                }
            }
        }

    }
    
}

/// 上台学生
- (void)changeUpPlatformRoomUser:(YSRoomUser *)roomUser
{
    if (self.liveManager.isEveryoneNoAudio)
    {
        [self.liveManager setPropertyOfUid:roomUser.peerID tell:YSRoomPubMsgTellAll propertyKey:sYSUserPublishstate value:@(YSUser_PublishState_VIDEOONLY)];
    }
    else
    {
        [self.liveManager setPropertyOfUid:roomUser.peerID tell:YSRoomPubMsgTellAll propertyKey:sYSUserPublishstate value:@(YSUser_PublishState_BOTH)];
    }
}

/// 收到轮播
- (void)handleSignalingToStartVideoPollingFromID:(NSString *)fromID
{
    _isPolling = YES;
    self.spreadBottomToolBar.isPolling = YES;
    _pollingFromID = fromID;
//    YSRoomUser *user = [self.liveManager.roomManager getRoomUserWithUId:fromID];
//    if (!user)
//    {
//        [self.liveManager sendSignalingTeacherToStopVideoPollingCompletion:nil];
//        return;
//    }
//    if (user.role == YSUserType_Assistant)
//    {
//        return;
//    }
//    if (![fromID isEqualToString:self.liveManager.localUser.peerID])
//    {
//        [self.liveManager sendSignalingTeacherToStopVideoPollingCompletion:nil];
//    }

}
///结束轮播
- (void)handleSignalingToStopVideoPolling
{
    if (self.pollingTimer)
    {
        dispatch_source_cancel(self.pollingTimer);
        self.pollingTimer = nil;
    }
    _isPolling = NO;
    [self bottomToolBarPollingBtnEnable];
//    if (self.spreadBottomToolBar.isPollingEnable)
    {
        self.spreadBottomToolBar.isPolling = NO;
    }
    
}

#pragma mark -
#pragma mark 聊天相关视图
/// 右侧聊天视图
- (void)creatRightChatView
{
    SCChatView * rightChatView = [[SCChatView alloc]initWithFrame:CGRectMake(BMUI_SCREEN_WIDTH, self.contentBackgroud.bm_originY + STATETOOLBAR_HEIGHT, ChatViewWidth, SCChatViewHeight)];
    
    BMWeakSelf
    //点击底部输入按钮，弹起键盘
    rightChatView.textBtnClick = ^{
        [weakSelf.chatToolView.inputView becomeFirstResponder];
    };
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenTheKeyBoard)];
    [rightChatView addGestureRecognizer:tap];
    self.rightChatView = rightChatView;
    [self.view addSubview:rightChatView];
}

///  聊天输入框工具栏
- (SCChatToolView *)chatToolView
{
    if (!_chatToolView)
    {
        self.chatToolView = [[SCChatToolView alloc]initWithFrame:CGRectMake(0, BMUI_SCREEN_HEIGHT, BMUI_SCREEN_WIDTH, SCChatToolHeight)];
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
        self.emotionListView = [[YSEmotionView alloc]initWithFrame:CGRectMake(0, BMUI_SCREEN_HEIGHT, BMUI_SCREEN_WIDTH, SCChateEmotionHeight)];
        
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

///输入框条上表情按钮的点击事件
- (void)toolEmotionBtnClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    [self.chatToolView endEditing:YES];
    if (sender.selected)
    {
        [UIView animateWithDuration:0.25 animations:^{
            self.chatToolView.bm_originY = BMUI_SCREEN_HEIGHT - SCChateEmotionHeight - SCChatToolHeight;
            self.emotionListView.bm_originY = BMUI_SCREEN_HEIGHT - SCChateEmotionHeight;
        }];
    }
    sender.selected = !sender.selected;
}

#pragma mark - 聊天消息接收 _ 小班课

- (void)handleMessageWith:(YSChatMessageModel *)message
{
    self.spreadBottomToolBar.isNewMessage = YES;
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
    [super keyboardWillShow:notification];
    
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardF = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.keyBoardH = keyboardF.size.height;//竖屏： 292   横屏 ：232
    
    UIView *firstResponder = [self.view bm_firstResponder];
    
    if (firstResponder.tag == PlaceholderPTag)
    {//调用聊天键盘
        [UIView animateWithDuration:duration animations:^{
            self.chatToolView.bm_originY = BMUI_SCREEN_HEIGHT-keyboardF.size.height-SCChatToolHeight;
            self.emotionListView.bm_originY = BMUI_SCREEN_HEIGHT;
        }];
        self.chatToolView.emojBtn.selected = NO;
    }
    else if (firstResponder.tag == YSWHITEBOARD_TEXTVIEWTAG)
    {//调用白板键盘
        [UIView animateWithDuration:duration animations:^{
            self.chatToolView.bm_originY = self.emotionListView.bm_originY = BMUI_SCREEN_HEIGHT;
        }];

        CGPoint relativePoint = [firstResponder convertPoint:CGPointZero toView:[UIApplication sharedApplication].keyWindow];
        CGFloat keyboardHeight = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
        CGFloat zoomScale = [self.liveManager.whiteBoardManager currentDocumentZoomScale];
        CGFloat actualHeight = CGRectGetHeight(firstResponder.frame)*zoomScale + relativePoint.y + keyboardHeight;
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
    [super keyboardWillHide:notification];
    
    double duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    if (self.chatToolView.emojBtn.selected)
    {
        [UIView animateWithDuration:0.25 animations:^{
            self.chatToolView.bm_originY = BMUI_SCREEN_HEIGHT - SCChateEmotionHeight - SCChatToolHeight;
            self.emotionListView.bm_originY = BMUI_SCREEN_HEIGHT - SCChateEmotionHeight;
        }];
    }
    else
    {
        [UIView animateWithDuration:duration animations:^{
            self.chatToolView.bm_originY = self.emotionListView.bm_originY = BMUI_SCREEN_HEIGHT;
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
        self.chatToolView.bm_originY = self.emotionListView.bm_originY = BMUI_SCREEN_HEIGHT;
    }];
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


#pragma mark 点击弹出popoview
- (void)clickViewToControlWithVideoView:(SCVideoView*)videoView
{
    self.selectControlView = videoView;
    
    YSRoomUser * userModel = videoView.roomUser;
    
    YSUserMediaPublishState userPublishState = self.selectControlView.roomUser.mediaPublishState;
    if (userPublishState == YSUserMediaPublishState_NONE)
    {
        return;
    }
    
    UIPopoverPresentationController *popover = self.controlPopoverView.popoverPresentationController;
    if ( self.videoViewArray.count <= 2 || [self.foucePeerId isEqualToString:videoView.roomUser.peerID])
    {
        /// 1.视频数小于等于2  2.videoView为焦点视频时
        popover.sourceView = videoView.sourceView;
        popover.sourceRect = videoView.sourceView.bounds;
        if (self.roomLayout == YSRoomLayoutType_AroundLayout)
        {
            popover.sourceView = videoView;
            popover.sourceRect = videoView.bounds;
        }
    }
    else
    {
        popover.sourceView = videoView;
        popover.sourceRect = videoView.bounds;
    }
    
    popover.delegate = self;
//    popover.backgroundColor =  [UIColor bm_colorWithHex:0x336CC7];
    self.controlPopoverView.roomLayout = self.roomLayout;
    [self presentViewController:self.controlPopoverView animated:YES completion:nil];///present即可
    self.controlPopoverView.isNested = NO;
    if (self.roomtype == YSRoomUserType_One)
    {
        popover.permittedArrowDirections = UIPopoverArrowDirectionRight;
        if ([self.doubleType isEqualToString:@"nested"] && userModel.role != YSUserType_Teacher)
        {
            popover.permittedArrowDirections = UIPopoverArrowDirectionUp;
            self.controlPopoverView.isNested = YES;
        }
    }
    else if (self.roomtype == YSRoomUserType_More)
    {
        popover.permittedArrowDirections = UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown;
    }
    self.controlPopoverView.roomtype = self.roomtype;
    self.controlPopoverView.isDragOut = videoView.isDragOut;
    self.controlPopoverView.foucePeerId = self.foucePeerId;
    self.controlPopoverView.userModel = userModel;
    self.controlPopoverView.videoMirrorMode = self.liveManager.localVideoMirrorMode;
}


#pragma mark -
#pragma mark YSControlPopoverViewDelegate  视频控制按钮点击事件
- (void)videoViewControlBtnsClick:(UIButton *)sender                videoViewControlType:(SCVideoViewControlType)videoViewControlType
{
    YSUserMediaPublishState userPublishState = self.selectControlView.roomUser.mediaPublishState;
    switch (videoViewControlType) {
        case SCVideoViewControlTypeAudio:
        {//关闭音频
            if (sender.selected)
            {//当前是打开音频状态
                userPublishState &= ~YSUserMediaPublishState_AUDIOONLY;
            }
            else
            {//当前是关闭音频状态
                userPublishState |= YSUserMediaPublishState_AUDIOONLY;
            }
            YSPublishState publishState = [YSRoomUser convertMediaPublishState:userPublishState];
            [self.liveManager setPropertyOfUid:self.selectControlView.roomUser.peerID tell:YSRoomPubMsgTellAll propertyKey:sYSUserPublishstate value:@(publishState)];
            sender.selected = !sender.selected;
        }
            break;
        case SCVideoViewControlTypeVideo:
        {//关闭视频
            if (sender.selected)
            {//当前是打开视频状态
                userPublishState &= ~YSUserMediaPublishState_VIDEOONLY;
            }
            else
            {//当前是关闭视频状态
                userPublishState |= YSUserMediaPublishState_VIDEOONLY;
            }
            YSPublishState publishState = [YSRoomUser convertMediaPublishState:userPublishState];
            [self.liveManager setPropertyOfUid:self.selectControlView.roomUser.peerID tell:YSRoomPubMsgTellAll propertyKey:sYSUserPublishstate value:@(publishState)];
            sender.selected = !sender.selected;
        }
            break;
        case SCVideoViewControlTypeMirror:
        {
            //镜像
            sender.selected = !sender.selected;
            
            if (sender.selected)
            {
                [self.liveManager changeLocalVideoMirrorMode:CloudHubVideoMirrorModeEnabled];
            }
            else
            {
                [self.liveManager changeLocalVideoMirrorMode:CloudHubVideoMirrorModeDisabled];
            }
        }
            break;
        case SCVideoViewControlTypeFouce:
        {//焦点
            if (self.roomLayout == YSRoomLayoutType_VideoLayout)
            {
//                if (self.videoViewArray.count < 2)
//                {
//                    return;
//                }
                
                self.roomLayout = YSRoomLayoutType_FocusLayout;
                self.fouceView = self.selectControlView;
                [self.liveManager sendSignalingToChangeLayoutWithLayoutType:self.roomLayout appUserType:self.appUseTheType withFouceUserId:self.fouceView.roomUser.peerID];
            }
            else if (self.roomLayout == YSRoomLayoutType_FocusLayout)
            {
                if ([self.selectControlView isEqual:self.fouceView])
                {
                    self.roomLayout = YSRoomLayoutType_VideoLayout;
                    self.fouceView = nil;
                }
                else
                {
                    self.roomLayout = YSRoomLayoutType_FocusLayout;
                    self.fouceView = self.selectControlView;
                }
                [self.liveManager sendSignalingToChangeLayoutWithLayoutType:self.roomLayout appUserType:self.appUseTheType withFouceUserId:self.fouceView.roomUser.peerID];
            }
            self.foucePeerId = self.fouceView.roomUser.peerID;
            [self.controlPopoverView dismissViewControllerAnimated:YES completion:nil];
        }
            break;
            
        case SCVideoViewControlTypeRestore:
        {//视频复位
            NSDictionary * data = @{
                @"isDrag":@0,
                @"userId":self.selectControlView.roomUser.peerID
            };
//            [self.liveManager sendSignalingToDragOutVideoViewWithData:data];
            [self.liveManager sendSignalingTopinchVideoViewWithPeerId:self.selectControlView.roomUser.peerID withData:data];
            
            
            
            if (self.controlPopoverView.presentingViewController)
            {
                [self.controlPopoverView dismissViewControllerAnimated:YES completion:nil];
            }
            
            
        }
            break;
        case SCVideoViewControlTypeAllRestore:
        {
            // 全体复位
            for (YSRoomUser * user in self.liveManager.userList)
            {
                NSDictionary * data = @{
                    @"isDrag":@0,
                    @"userId":user.peerID
                };
//                [self.liveManager sendSignalingToDragOutVideoViewWithData:data];
                [self.liveManager sendSignalingTopinchVideoViewWithPeerId:user.peerID withData:data];
            }
        }
            break;
        case SCVideoViewControlTypeAllGiftCup:
        {
            //全体奖杯
            for (SCVideoView *videoView in self.videoViewArray)
            {
                YSRoomUser *user = videoView.roomUser;
                
                if (user.role == YSUserType_Student)
                {
                    [self sendGiftWithRreceiveRoomUser:user];
                }
            }
        }
            break;
        case SCVideoViewControlTypeCanDraw:
        {// 画笔权限
            
            BOOL candraw = self.selectControlView.roomUser.canDraw;
            // 兼容安卓bool
            bool bCandraw = true;
            if (candraw)
            {
                bCandraw = false;
            }
            BOOL isSucceed = [self.liveManager setPropertyOfUid:self.selectControlView.roomUser.peerID tell:YSRoomPubMsgTellAll propertyKey:sYSUserCandraw value:@(bCandraw)];
            if (isSucceed)
            {
                sender.selected = !sender.selected;
            }
        }
            break;
        case SCVideoViewControlTypeOnStage:
        {//下台
            [self.liveManager setPropertyOfUid:self.selectControlView.roomUser.peerID tell:YSRoomPubMsgTellAll propertyKey:sYSUserPublishstate value:@([YSRoomUser convertMediaPublishState:YSUserMediaPublishState_NONE])];

            [self.controlPopoverView dismissViewControllerAnimated:YES completion:nil];
        }
            break;
        case SCVideoViewControlTypeGiftCup:
        {//发奖杯
            [self sendGiftWithRreceiveRoomUser:self.selectControlView.roomUser];
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
    
    BMAFHTTPSessionManager *manager = [BMAFHTTPSessionManager manager];
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
                NSDictionary *responseDic = [YSSessionUtil convertWithData:responseObject];
                
                if ([responseDic bm_containsObjectForKey:@"result"])
                {
                    NSInteger result = [responseDic bm_intForKey:@"result"];
                    if (result == 0)
                    {
                        NSUInteger giftnumber = [roomUser.properties bm_uintForKey:sYSUserGiftNumber];
                        [weakSelf.liveManager setPropertyOfUid:roomUser.peerID tell:YSRoomPubMsgTellAll propertyKey:sYSUserGiftNumber value:@(giftnumber+1)];
                    }
                }
            }
        }];
        
        [task resume];
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
            if (self.liveManager.isEveryoneNoAudio)
            {
                [self.liveManager setPropertyOfUid:roomUser.peerID tell:YSRoomPubMsgTellAll propertyKey:sYSUserPublishstate value:@(YSUser_PublishState_VIDEOONLY)];
            }
            else
            {
                [self.liveManager setPropertyOfUid:roomUser.peerID tell:YSRoomPubMsgTellAll propertyKey:sYSUserPublishstate value:@(YSUser_PublishState_BOTH)];
            }
        }
        else
        {
            [BMProgressHUD bm_showHUDAddedTo:self.view animated:YES withDetailText:YSLocalized(@"Error.UpPlatformMemberOverRoomLimit") delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
            [self freshTeacherPersonListData];
        }
    }
    else
    {
        [self.liveManager setPropertyOfUid:roomUser.peerID tell:YSRoomPubMsgTellAll properties:@{sYSUserPublishstate : @(YSUser_PublishState_NONE), sYSUserCandraw : @(false)}];
    }
}

//对花名册中的成员禁言
- (void)speakProxyWithRoomUser:(YSRoomUser *)roomUser
{
//    if ([roomUser.properties bm_containsObjectForKey:sUserDisablechat])
//    {
        BOOL disablechat = [roomUser.properties bm_boolForKey:sYSUserDisablechat];
    
        [self.liveManager setPropertyOfUid:roomUser.peerID tell:YSRoomPubMsgTellAll propertyKey:sYSUserDisablechat value:@(!disablechat)];
//    }
}

// 踢出
- (void)outProxyWithRoomUser:(YSRoomUser *)roomUser
{
    [self.controlPopoverView dismissViewControllerAnimated:NO completion:nil];
    [self.upHandPopTableView dismissViewControllerAnimated:NO completion:nil];
    
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:YSLocalized(@"Permissions.notice") message:YSLocalized(@"Permissions.KickedOutMembers") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confimAc = [UIAlertAction actionWithTitle:YSLocalized(@"Prompt.OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.liveManager evictUser:roomUser.peerID reason:1];

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
    [self.controlPopoverView dismissViewControllerAnimated:NO completion:nil];
    [self.upHandPopTableView dismissViewControllerAnimated:NO completion:nil];


    BMWeakSelf
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:YSLocalized(@"Permissions.notice") message:YSLocalized(@"Prompt.delClassFile") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confimAc = [UIAlertAction actionWithTitle:YSLocalized(@"Prompt.OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //[weakSelf.liveManager sendSignalingTeacherToDeleteDocumentWithFile:fileModel completion:nil];
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
    BMAFHTTPSessionManager *manager = [BMAFHTTPSessionManager manager];
    NSMutableURLRequest *request = [YSLiveApiRequest deleteCoursewareWithRoomId:self.liveManager.room_Id fileId:fileid];
    if (request)
    {
        [self.deleteTask cancel];
        
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[
            @"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript",@"text/xml"
        ]];
        BMWeakSelf
        self.deleteTask = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error)
            {
                BMLog(@"Error: %@", error);
            }
            else
            {
                [weakSelf.liveManager.whiteBoardManager deleteCourseWithFileId:fileid];
//                NSDictionary *responseDic = [YSLiveUtil convertWithData:responseObject];
//
//                if ([responseDic bm_containsObjectForKey:@"result"])
//                {
//                    NSInteger result = [responseDic bm_intForKey:@"result"];
//                    if (result == 0)
//                    {
//                        [weakSelf freshTeacherCoursewareListData];
//                    }
//                }
                BMLog(@"%@--------%@", response,responseObject);
            }
        }];
        [self.deleteTask resume];
    }
}
/// 课件点击
- (void)selectCoursewareProxyWithFileModel:(YSFileModel *)fileModel
{
    if (self.liveManager.mediaFileModel)
    {
        if ([self.liveManager.mediaFileModel.fileId isEqualToString:fileModel.fileid])
        {
            isMediaPause = !isMediaPause;
            [self.liveManager pauseShareOneMediaFile:isMediaPause];
            [self freshTeacherCoursewareListData];
            self.mp3ControlView.playBtn.selected = isMediaPause;
            return;
        }

        [self.liveManager stopShareOneMediaFile];
    }
    
    if (![fileModel bm_isNotEmpty])
    {
        return;
    }
    [self.liveManager.whiteBoardManager changeCourseWithFileId:fileModel.fileid];

}

///收回列表
- (void)tapGestureBackListView
{
    [self freshListViewWithSelect:NO];
}

- (void)leftPageProxyWithPage:(NSInteger)page
{
    page--;

    if (isSearch)
    {
        if (self.liveManager.isBigRoom)
        {
            NSInteger studentNum = self.liveManager.studentCount;
            [self.teacherListView setPersonListCurrentPage:page totalPage:ceil((CGFloat)searchArr.count/(CGFloat)onePageMaxUsers)];
            
            NSArray *data = [searchArr bm_divisionWithCount:onePageMaxUsers atIndex:page appoint:NO];
            [self.teacherListView setDataSource:data withType:SCBottomToolBarTypePersonList userNum:studentNum];
        }
    }
    else
    {
        _personListCurentPage = page;
        [self freshTeacherPersonListData];
    }
    
}

- (void)rightPageProxyWithPage:(NSInteger)page
{
    page++;
    if (isSearch)
    {
        NSInteger studentNum = self.liveManager.studentCount;
        [self.teacherListView setPersonListCurrentPage:page totalPage:ceil((CGFloat)searchArr.count/(CGFloat)onePageMaxUsers)];
        
        NSArray *data = [searchArr bm_divisionWithCount:onePageMaxUsers atIndex:page appoint:NO];
        [self.teacherListView setDataSource:data withType:SCBottomToolBarTypePersonList userNum:studentNum];
    }
    else
    {
        _personListCurentPage = page;
        [self freshTeacherPersonListData];
    }
}

/// 搜索
- (void)searchProxyWithSearchContent:(NSString *)searchContent
{
    isSearch = YES;
    if (self.liveManager.isBigRoom)
    {
        if (self.bigRoomTimer)
        {
            dispatch_source_cancel(self.bigRoomTimer);
            self.bigRoomTimer = nil;
        }
        
        BMWeakSelf
        NSInteger studentNum = [self.liveManager.userCountDetailDic bm_intForKey:@"2"];
        NSInteger assistantNum = [self.liveManager.userCountDetailDic bm_intForKey:@"1"];

        [self.liveManager getRoomUsersWithRole:@[@(YSUserType_Assistant),@(YSUserType_Student)] startIndex:0 maxNumber:(studentNum + assistantNum) search:searchContent order:@{} callback:^(NSArray<YSRoomUser *> * _Nonnull users, NSError * _Nonnull error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // UI更新代码

                self->searchArr = [NSMutableArray arrayWithArray:users];
                [weakSelf.teacherListView setPersonListCurrentPage:0 totalPage:ceil((CGFloat)users.count/(CGFloat)onePageMaxUsers)];
                if (users.count > onePageMaxUsers)
                {
                    NSArray *data = [users subarrayWithRange:NSMakeRange(0, onePageMaxUsers)];
                    [weakSelf.teacherListView setDataSource:data withType:SCBottomToolBarTypePersonList userNum:studentNum];
                }
                else
                {
                    [weakSelf.teacherListView setDataSource:users withType:SCBottomToolBarTypePersonList userNum:studentNum];
                }
            });
            
        }];
    }
    else
    {
        BMWeakSelf
        NSInteger studentNum = self.liveManager.studentCount ;
        NSInteger assistantNum = self.liveManager.assistantCount;
        [self.liveManager getRoomUsersWithRole:@[@(YSUserType_Assistant),@(YSUserType_Student)] startIndex:0 maxNumber:(studentNum + assistantNum) search:searchContent order:@{} callback:^(NSArray<YSRoomUser *> * _Nonnull users, NSError * _Nonnull error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // UI更新代码
                
                self->searchArr = [NSMutableArray arrayWithArray:users];
                [weakSelf.teacherListView setPersonListCurrentPage:0 totalPage:ceil((CGFloat)users.count/(CGFloat)onePageMaxUsers)];
                if (users.count > onePageMaxUsers)
                {
                    NSArray *data = [users subarrayWithRange:NSMakeRange(0, onePageMaxUsers)];
                    [weakSelf.teacherListView setDataSource:data withType:SCBottomToolBarTypePersonList userNum:studentNum];
                }
                else
                {
                    [weakSelf.teacherListView setDataSource:users withType:SCBottomToolBarTypePersonList userNum:studentNum];
                }
                
            });
            
        }];
    }
}

/// 取消搜索
- (void)cancelProxy
{
    isSearch = NO;
    if (self.liveManager.isBigRoom)
    {
        if(!self.bigRoomTimer)
        {
            BMWeakSelf
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            self.bigRoomTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
            dispatch_source_set_timer(self.bigRoomTimer, DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
            //3.要调用的任务
            dispatch_source_set_event_handler(self.bigRoomTimer, ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    BMStrongSelf
                    [strongSelf freshTeacherPersonListData];
                });
            });
            //4.开始执行
            dispatch_resume(self.bigRoomTimer);
        }
    }
    else
    {
        [self freshTeacherPersonListData];
    }
    
    
}
#pragma mark -
#pragma mark UIImagePickerControllerDelegate
//// 完成图片的选取后调用的方法
//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
//{
//    // 选取完图片后跳转回原控制器
//    [picker dismissViewControllerAnimated:YES completion:nil];
//    /* 此处参数 info 是一个字典，下面是字典中的键值 （从相机获取的图片和相册获取的图片时，两者的info值不尽相同）
//     * UIImagePickerControllerMediaType; // 媒体类型
//     * UIImagePickerControllerOriginalImage; // 原始图片
//     * UIImagePickerControllerEditedImage; // 裁剪后图片
//     * UIImagePickerControllerCropRect; // 图片裁剪区域（CGRect）
//     * UIImagePickerControllerMediaURL; // 媒体的URL
//     * UIImagePickerControllerReferenceURL // 原件的URL
//     * UIImagePickerControllerMediaMetadata // 当数据来源是相机时，此值才有效
//     */
//    // 从info中将图片取出，并加载到imageView当中
//
//    BMWeakSelf
//    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
//    [YSLiveApiRequest uploadImageWithImage:image withImageUseType:SCUploadImageUseType_Document success:^(NSDictionary * _Nonnull dict) {
//
//        [weakSelf sendWhiteBordImageWithDic:dict];
//
//    } failure:^(NSInteger errorCode) {
//#if DEBUG
//        [BMProgressHUD bm_showHUDAddedTo:weakSelf.view animated:YES withDetailText:[NSString stringWithFormat:@"%@,code:%@",YSLocalized(@"UploadPhoto.Error"),@(errorCode)]];
//#else
//        [BMProgressHUD bm_showHUDAddedTo:weakSelf.view animated:YES withDetailText:YSLocalized(@"UploadPhoto.Error")];
//#endif
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [BMProgressHUD bm_hideHUDForView:weakSelf.view animated:YES];
//        });
//    }];
//
//}
//
//// 取消选取调用的方法
//- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
//{
//    [self dismissViewControllerAnimated:YES completion:nil];
//}


#pragma mark -
#pragma mark SCBoardControlViewDelegate 白板翻页控件

#warning WhitebordFullScreen
/*
/// 全屏 复原 回调
- (void)boardControlProxyfullScreen:(BOOL)isAllScreen
{
    self.isWhitebordFullScreen = isAllScreen;
    
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
        
#if USE_FullTeacher
        [self playFullTeacherVideoViewInView:self.whitebordFullBackgroud];
        
//        [self.fullTeacherFloatView bm_bringToFront];
#endif
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
        
        self.brushToolView.hidden = self.isDoubleVideoBig || (self.roomLayout == YSRoomLayoutType_VideoLayout);
        
#if USE_FullTeacher
        [self stopFullTeacherVideoView];
#endif
//        [self.liveManager playVideoOnView:self.teacherVideoView withPeerId:YSCurrentUser.peerID renderType:YSRenderMode_adaptive completion:nil];
//        [self.liveManager playAudio:YSCurrentUser.peerID completion:nil];
    }
    
    [self.liveManager.whiteBoardManager refreshWhiteBoard];
    [self.liveManager.whiteBoardManager whiteBoardResetEnlarge];
}
*/


#pragma mark 画笔工具展开收起

- (void)brushToolOpenBtnClick:(UIButton *)btn
{
//    if (self.liveManager.isBeginClass)
    {
        btn.selected = !btn.selected;
        CGFloat leftGap = 10;
        if (BMIS_IPHONEXANDP)
        {
            leftGap = BMUI_HOME_INDICATOR_HEIGHT;
        }
        CGFloat tempWidth = self.brushToolView.bm_width;
        if (btn.selected)
        {
            self.drawBoardView.hidden = YES;
            [UIView animateWithDuration:0.3 animations:^{
                self.brushToolView.bm_left = -tempWidth;
                self.brushToolOpenBtn.bm_left = leftGap;

            }];
        }
        else
        {
            [UIView animateWithDuration:0.3 animations:^{
                self.brushToolView.bm_left = leftGap;
                self.brushToolOpenBtn.bm_left = self.brushToolView.bm_right;
                
            }];
            
        }
    }
}


#pragma mark -
#pragma mark SCBrushToolViewDelegate


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
    [self.contentBackgroud addSubview:self.drawBoardView];
    
    BMWeakSelf
    [self.drawBoardView.backgroundView  bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.left.bmmas_equalTo(weakSelf.brushToolOpenBtn.bmmas_right).bmmas_offset(10);
        make.centerY.bmmas_equalTo(weakSelf.brushToolOpenBtn.bmmas_centerY);
    }];

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
    

    BMTZImagePickerController * imagePickerController = [[BMTZImagePickerController alloc]initWithMaxImagesCount:3 columnNumber:1 delegate:self pushPhotoPickerVc:YES];
    imagePickerController.showPhotoCannotSelectLayer = YES;
//    imagePickerController.allowTakePicture = imageUseType == SCUploadImageUseType_Document ? NO : YES;
    imagePickerController.allowTakeVideo = NO;
    imagePickerController.allowPickingVideo = NO;
    imagePickerController.showSelectedIndex = YES;
    imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
    imagePickerController.sortAscendingByModificationDate = NO;
    
    BMWeakSelf
    [imagePickerController setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        [YSLiveApiRequest uploadImageWithImage:photos.firstObject withImageUseType:imageUseType success:^(NSDictionary * _Nonnull dict) {
            
            if (imageUseType == 0)
            {
                [weakSelf.liveManager.whiteBoardManager addWhiteBordImageCourseWithDic:dict];
            }
            else
            {
                BOOL isSucceed = [self.liveManager sendMessageWithText:[dict bm_stringTrimForKey:@"swfpath"]  withMessageType:YSChatMessageType_OnlyImage withMemberModel:nil];
                if (!isSucceed)
                {
                    BMProgressHUD *hub = [BMProgressHUD bm_showHUDAddedTo:weakSelf.view animated:YES withDetailText:YSLocalized(@"UploadPhoto.Error")];
                    hub.yOffset = -100;
                    [BMProgressHUD bm_hideHUDForView:weakSelf.view animated:YES delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
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
            [BMProgressHUD bm_showHUDAddedTo:weakSelf.view animated:YES withDetailText:[NSString stringWithFormat:@"%@,code:%@",YSLocalized(@"UploadPhoto.Error"),@(errorCode)]];
#else
            [BMProgressHUD bm_showHUDAddedTo:weakSelf.view animated:YES withDetailText:YSLocalized(@"UploadPhoto.Error")];
#endif
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [BMProgressHUD bm_hideHUDForView:weakSelf.view animated:YES];
            });
        }];
    }];

    self.imagePickerController = imagePickerController;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

//- (void)sendWhiteBordImageWithDic:(NSDictionary *)uplaodDic
//{
//    NSMutableDictionary *docDic = [[NSMutableDictionary alloc] initWithDictionary:uplaodDic];
//
//    // 0:表示普通文档　１－２动态ppt(1: 第一版动态ppt 2: 新版动态ppt ）  3:h5文档
//    NSUInteger fileprop = [docDic bm_uintForKey:@"fileprop"];
//    BOOL isGeneralFile = fileprop == 0 ? YES : NO;
//    BOOL isDynamicPPT = fileprop == 1 || fileprop == 2 ? YES : NO;
//    BOOL isH5Document = fileprop == 3 ? YES : NO;
//    //NSString *action = isDynamicPPT ? sActionShow : @"";
//    NSString *mediaType = @"";
//    NSString *filetype = @"jpg";
//
//    //[docDic setObject:action forKey:@"action"];
//    [docDic setObject:filetype forKey:@"filetype"];
//
//    [self.liveManager.whiteBoardManager addDocumentWithFileDic:docDic];
//
//    NSString *fileid = [docDic bm_stringTrimForKey:@"fileid" withDefault:@""];
//    NSString *filename = [docDic bm_stringTrimForKey:@"filename" withDefault:@""];
//    NSUInteger pagenum = [docDic bm_uintForKey:@"pagenum"];
//    NSString *swfpath = [docDic bm_stringTrimForKey:@"swfpath" withDefault:@""];
//
//    NSInteger isContentDocument = [docDic bm_intForKey:@"isContentDocument"];
//
//    NSDictionary *tDataDic = @{
//        @"isDel" : @(false),
//        @"isGeneralFile" : @(isGeneralFile),
//        @"isDynamicPPT" : @(isDynamicPPT),
//        @"isH5Document" : @(isH5Document),
//        //@"action" : action,
//        @"mediaType" : mediaType,
//        @"isMedia" : @(false),
//        @"filedata" : @{
//                @"fileid" : fileid,
//                @"currpage" : @(1),
//                @"pagenum" : @(pagenum),
//                @"filetype" : filetype,
//                @"filename" : filename,
//                @"swfpath" : swfpath,
//                @"pptslide" : @(1),
//                @"pptstep" : @(0),
//                @"steptotal" : @(0),
//                @"filecategory":@(0),
//                @"isContentDocument" : @(isContentDocument)
//        }
//    };
//
//    [self.liveManager sendPubMsg:sDocumentChange toID:YSRoomPubMsgTellAllExceptSender data:tDataDic save:NO associatedMsgID:nil associatedUserID:nil expires:0 completion:nil];
//
//    NSString *downloadpath = [docDic bm_stringTrimForKey:@"downloadpath"];
////    data: "{"sourceInstanceId":"default","isGeneralFile":true,"isMedia":false,"isDynamicPPT":false,"isH5Document":false,"action":"show","mediaType":"","filedata":{"currpage":1,"pptslide":1,"pptstep":0,"steptotal":0,"fileid":1701,"pagenum":1,"filename":"老师_qr_2020-01-14_15_59_24.png","filetype":"png","isContentDocument":0,"swfpath":"/upload/20200114_155926_dwbudtjw.png"}}"
//
//    NSDictionary *tDataDic1 = @{
//        @"sourceInstanceId":@"default",
//        @"isGeneralFile" : @(isGeneralFile),
//        @"isDynamicPPT" : @(isDynamicPPT),
//        @"isH5Document" : @(isH5Document),
//        @"action" : sActionShow,
//        @"downloadpath" : downloadpath,
//        @"fileid" : fileid,
//        @"mediaType" : mediaType,
//        @"isMedia" : @(false),
//        @"filedata" : @{
//                @"fileid" : fileid ,
//                @"filename" : filename,
//                @"filetype" : filetype,
//                @"currpage" : @(1),
//                @"pagenum" : @(pagenum),
//                @"pptslide" : @(1),
//                @"pptstep" : @(0),
//                @"steptotal" : @(0),
//                @"isContentDocument" : @(isContentDocument),
//                @"swfpath" : swfpath
//        }
//    };
//
//    [self.liveManager.roomManager pubMsg:sShowPage msgID:sDocumentFilePage_ShowPage toID:YSRoomPubMsgTellAll data:tDataDic save:YES associatedMsgID:nil associatedUserID:nil expires:0 completion:nil];
//}

/// 正在举手上台的人员数组
- (NSMutableArray<YSRoomUser *> *)raiseHandArray
{
    if (!_raiseHandArray) {
        _raiseHandArray = [NSMutableArray array];
    }
    return _raiseHandArray;
}

#if USE_FullTeacher
/// 停止全屏老师视频流 并开始常规老师视频流
- (void)stopFullTeacherVideoView
{
    self.fullTeacherFloatView.hidden = YES;
    [self stopVideoAudioWithVideoView:self.fullTeacherVideoView];
    [self playVideoAudioWithNewVideoView:self.teacherVideoView];
    [self.teacherVideoView freshWithRoomUserProperty:self.liveManager.teacher];
}

/// 播放全屏老师视频流
- (void)playFullTeacherVideoViewInView:(UIView *)view
{
    if (self.liveManager.isClassBegin)
    {/// 全屏课件老师显示
        [self stopVideoAudioWithVideoView:self.teacherVideoView];

        [self.fullTeacherFloatView cleanContent];
        self.fullTeacherFloatView.hidden = NO;
        self.fullTeacherFloatView.frame = CGRectMake(self.contentWidth - 76 - floatVideoDefaultWidth, 50, floatVideoDefaultWidth, floatVideoDefaultHeight);
        [self.fullTeacherFloatView bm_bringToFront];
//        SCVideoView *fullTeacherVideoView = [[SCVideoView alloc] initWithRoomUser:YSCurrentUser isForPerch:NO];
        SCVideoView *fullTeacherVideoView = [[SCVideoView alloc] initWithRoomUser:YSCurrentUser isForPerch:NO withDelegate:self];
        fullTeacherVideoView.frame = self.fullTeacherFloatView.bounds;
        [self.fullTeacherFloatView showWithContentView:fullTeacherVideoView];
        
        fullTeacherVideoView.appUseTheType = self.appUseTheType;
        [self playVideoAudioWithNewVideoView:fullTeacherVideoView];
        self.fullTeacherVideoView = fullTeacherVideoView;
        [fullTeacherVideoView freshWithRoomUserProperty:self.liveManager.teacher];
        
        if (view == self.whitebordFullBackgroud)
        {
            [self.raiseHandsBtn bm_bringToFront];
            [self.handNumLab bm_bringToFront];
            
//            self.raiseHandsBtn.frame = CGRectMake(UI_SCREEN_WIDTH-40-26, self.fullTeacherFloatView.bm_top, 40, 40);
        }
    }
    
}
#endif


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.chatToolView.bm_originY<self.contentHeight-10)
    {
        [self hiddenTheKeyBoard];
    }
    else
    {
        //收回聊天
        [self.spreadBottomToolBar hideMessageView];
        CGRect tempRect = self.rightChatView.frame;
        tempRect.origin.x = BMUI_SCREEN_WIDTH;
        [UIView animateWithDuration:0.25 animations:^{
            self.rightChatView.frame = tempRect;
        }];
    }
}

@end
