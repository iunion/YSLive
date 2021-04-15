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
#import "SCChatToolView.h"
#import "YSEmotionView.h"

#if YSSDK
#import "YSSDKManager.h"
#else
#import "AppDelegate.h"
#endif

#import "SCTeacherListView.h"
#import "SCTeacherAnswerView.h"

#import "YSFloatView.h"
#import "SCVideoGridView.h"

#import "UIAlertController+SCAlertAutorotate.h"
#import "YSLiveApiRequest.h"

#import "YSMp4ControlView.h"
#import "YSMp3Controlview.h"

#import "YSUpHandPopoverVC.h"
#import "YSCircleProgress.h"
#import "YSTeacherResponder.h"
#import "YSTeacherTimerView.h"
#import "YSPollingView.h"
#import "YSToolBoxView.h"

#import "YSDefaultLayoutPopView.h"

//#import "CHFullFloatVideoView.h"

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
    CHVideoViewDelegate,
    SCTeacherListViewDelegate,
    YSMp4ControlViewDelegate,
    YSMp3ControlviewDelegate,
    UIGestureRecognizerDelegate,
    YSTeacherResponderDelegate,
    YSTeacherTimerViewDelegate,
    YSPollingViewDelegate,
    YSToolBoxViewDelegate,
    YSDefaultLayoutPopViewDelegate
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
    UIAlertController *classEndAlertVC;
    
    CHRoomLayoutType defaultRoomLayout;
        
    NSInteger contestCommitNumber;
    
    NSString *contestPeerId;
    NSString *contestNickName;
    
    BOOL autoUpPlatform;
    NSInteger timer_defaultTime;
    
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
/// 白板背景图片
//@property (nonatomic, strong) UIImageView *whitebordBgimage;
/// 全屏白板背景
@property (nonatomic, strong) UIView *whitebordFullBackgroud;

/// 隐藏白板视频布局背景
@property (nonatomic, strong) SCVideoGridView *videoGridView;

/// 默认老师 视频
//@property (nonatomic, strong) CHVideoView *teacherVideoView;
/// 1V1 默认用户占位
@property (nonatomic, strong) CHVideoView *userVideoView;

/// 1V1 存储学生的视频，画中画时用来伸缩
@property (nonatomic, strong) CHVideoView *studentVideoView;
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

///要拖动的视频view
@property (nonatomic, strong) CHVideoView *dragingVideoView;

/// 双击放大视频
@property (nonatomic, strong) YSFloatView *doubleFloatView;
@property (nonatomic, assign) BOOL isDoubleVideoBig;

/// 共享浮动窗口 视频课件
@property (nonatomic, strong) YSFloatView *shareVideoFloatView;
/// 共享视频窗口
@property (nonatomic, strong) UIView *shareVideoView;

/// 学生的视频控制popoverView
@property(nonatomic, strong) CHVideoView *selectControlView;

/// 聊天的View
@property(nonatomic,strong)SCChatView *rightChatView;
/// 聊天输入框工具栏
@property (nonatomic, strong) SCChatToolView *chatToolView;
/// 聊天表情列表View
@property (nonatomic, strong) YSEmotionView *emotionListView;
/// 键盘弹起高度
@property (nonatomic, assign) CGFloat keyBoardH;

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
@property (nonatomic, strong) NSMutableArray *pollingUserList;
/// 轮播的上台学生数据
@property (nonatomic, strong) NSMutableArray *pollingUpPlatformArr;
/// 轮播定时器
@property (nonatomic, strong) dispatch_source_t pollingTimer;

///音频播放器
@property(nonatomic, strong) AVAudioPlayer *player;
@property(nonatomic, strong) AVAudioSession *session;

@property(nonatomic, weak) BMTZImagePickerController *imagePickerController;
/// 当前展示课件数组
@property (nonatomic, strong) NSMutableArray *currentFileList;

/// 课件删除
@property(nonatomic, strong) NSURLSessionDataTask *deleteTask;
/// 白板视频标注视图
@property (nonatomic, strong) CHWBMediaMarkView *mediaMarkView;
@property (nonatomic, strong) NSMutableArray <NSDictionary *> *mediaMarkSharpsDatas;

@property (nonatomic, strong) YSDefaultLayoutPopView * layoutPopoverView;


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


- (void)viewWillDisappear:(BOOL)animated
{
    [YSLiveSkinManager shareInstance].isSmallVC = NO;
}

- (instancetype)initWithRoomType:(CHRoomUserType)roomType isWideScreen:(BOOL)isWideScreen maxVideoCount:(NSUInteger)maxCount whiteBordView:(UIView *)whiteBordView userId:(NSString *)userId
{
    self = [super initWithWhiteBordView:whiteBordView];
    if (self)
    {
        maxVideoCount = maxCount;
        
        self.roomtype = roomType;
        self.isWideScreen = isWideScreen;
        
        self.userId = userId;
        
        if (roomType == CHRoomUserType_More && self.liveManager.roomModel.defaultRoomLayout == CHRoomLayoutType_rightLeftLayout)
        {
            self.roomLayout = defaultRoomLayout = CHRoomLayoutType_AroundLayout;
        }
        else
        {
            self.roomLayout = defaultRoomLayout = self.liveManager.roomModel.defaultRoomLayout;
        }
        
        self.mediaMarkSharpsDatas = [[NSMutableArray alloc] init];
        
        if (self.roomtype == CHRoomUserType_More)
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
    self.pollingUserList = [[NSMutableArray alloc] init];
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
        
    if (self.roomtype == CHRoomUserType_More)
    {
        //举手上台的按钮
        [self setupHandView];
        /// 视频布局时的全屏按钮 （只在 1VN 房间）
        self.fullFloatVideoView.rightViewMaxRight = self.raiseHandsBtn.bm_left - 10;
    }
    
    // 设置花名册 课件表
    [self setupListView];
    
    [self.spreadBottomToolBar bm_bringToFront];
    
    // 右侧聊天视图
    [self creatRightChatView];
    
    //创建上下课按钮
    [self setupClassBeginButton];
    
    // 会议默认视频布局
    if (self.appUseTheType == CHRoomUseTypeMeeting)
    {
        self.roomLayout = defaultRoomLayout = CHRoomLayoutType_VideoLayout;
        [self handleSignalingSetRoomLayout:self.roomLayout withPeerId:nil withSourceId:nil];
    }
    else
    {
        if (!self.liveManager.isClassBegin)
        {

            [self handleSignalingSetRoomLayout:self.roomLayout withPeerId:YSCurrentUser.peerID withSourceId:sCHUserDefaultSourceId];
        }
    }
    
    [self.fullFloatVideoView bm_bringToFront];
}


#pragma mark - 层级管理

// 重新排列VC.View的图层
- (void)arrangeAllViewInVCView
{
    // 全屏白板
    [self.whitebordFullBackgroud bm_bringToFront];

    // 聊天窗口
    [self.rightChatView bm_bringToFront];
    
    // 信息输入
    [self.chatToolView bm_bringToFront];
    
    // 全屏MP4 共享桌面
    [self.shareVideoFloatView bm_bringToFront];
    
    [self.mp4ControlView bm_bringToFront];
    [self.closeMp4Btn bm_bringToFront];
    [self.mp3ControlView bm_bringToFront];
    [self.fullFloatVideoView bm_bringToFront];
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
    UILabel *handNumLab = [[UILabel alloc]initWithFrame:CGRectMake(BMUI_SCREEN_WIDTH - raiseHandWH - raiseHandRight, self.spreadBottomToolBar.bm_originY - labBottom - 18, raiseHandWH, 18)];
    handNumLab.bm_centerX = self.spreadBottomToolBar.bm_right - (YSSpreadBottomToolBar_BtnWidth+YSSpreadBottomToolBar_SpreadBtnGap)*0.5f;  //(YSSpreadBottomToolBar_BtnWidth+YSSpreadBottomToolBar_SpreadBtnGap)*0.5f;
    handNumLab.font = UI_FONT_13;
    handNumLab.textColor = YSSkinDefineColor(@"Color2");
    handNumLab.backgroundColor = YSSkinDefineColor(@"Color3");
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
    
    [self.controlPopoverView dismissViewControllerAnimated:NO completion:nil];
    [self.layoutPopoverView dismissViewControllerAnimated:NO completion:nil];

    YSUpHandPopoverVC *popTab = [[YSUpHandPopoverVC alloc]init];
    popTab.userArr = self.raiseHandArray;
    popTab.preferredContentSize = CGSizeMake(95, 146);
    popTab.modalPresentationStyle = UIModalPresentationPopover;
    BMWeakSelf
    popTab.letStudentUpVideo = ^(YSUpHandPopCell *cell) {
        if (weakSelf.videoSequenceArr.count < self->maxVideoCount)
        {
            CHPublishState publishState = CHUser_PublishState_UP;

            NSString *peerId = [cell.userDict bm_stringForKey:@"peerId"];
            NSString *whom = CHRoomPubMsgTellAll;
            if (self.liveManager.isBigRoom)
            {
                whom = peerId;
                [weakSelf.liveManager setPropertyOfUid:peerId tell:whom propertyKey:sCHUserPublishstate value:@(publishState)];
            }
            else
            {
                CHRoomUser *roomUser = [self.liveManager getRoomUserWithId:peerId];
                [roomUser sendToPublishStateUPTellWhom:whom];
            }
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
    [self presentViewController:popTab animated:NO completion:nil];//present即可
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
    [classBeginBtn setTitleColor:YSSkinDefineColor(@"Color2") forState:UIControlStateNormal];
    classBeginBtn.titleLabel.font = UI_FONT_10;
    [classBeginBtn setTitle:YSLocalized(@"Button.ClassBegin") forState:UIControlStateNormal];
    [classBeginBtn setTitle:YSLocalized(@"Button.ClassIsOver") forState:UIControlStateSelected];
    [classBeginBtn setBackgroundColor:YSSkinDefineColor(@"Color4")];
    classBeginBtn.layer.cornerRadius = buttonWH/2;
    self.classBeginBtn = classBeginBtn;
    [self.view addSubview:classBeginBtn];
}


- (void)classBeginBtnClick:(UIButton *)sender
{
#if CHTEST_ALLPUBMSG
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"record" ofType:@"json"];
    
    NSString *str = [NSString stringWithContentsOfFile:plistPath encoding:NSUTF8StringEncoding error:nil];

    NSArray *array = (NSArray *)[BMCloudHubUtil convertWithData:str];
    NSUInteger index = 0;
    for (NSDictionary *dic in array)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

            NSString *method = [dic bm_stringForKey:@"method"];
            if ([method isEqualToString:@"PubMsg"])
            {
                NSString *associatedMsgID = [dic bm_stringForKey:@"associatedMsgID"];
                NSString *associatedUserID = [dic bm_stringForKey:@"associatedUserID"];
                NSDictionary *data = [dic bm_dictionaryForKey:@"data"];
                NSString *msgName = [data bm_stringForKey:@"name"];
                NSString *msgId = [data bm_stringForKey:@"id"];
                NSDictionary *msgData = [data bm_dictionaryForKey:@"data"];
                id extensionData = [data objectForKey:@"extensionData"];
                
                //NSLog(@"====== send %@: %@", @(index), msgName);
                
                if ([msgId isEqualToString:@"SharpsChange"])
                {
                    NSLog(@"====== send %@: %@_%@", @(index), msgId, [msgData bm_dictionaryForKey:@"data"][@"className"]);
                }
                
                //[self.liveManager pubMsg:msgName msgId:msgId to:@"__all" withData:msgData extensionData:extensionData associatedWithUser:associatedUserID associatedWithMsg:associatedMsgID save:YES];
            }

        });
        index++;
    }
    
    return;
#endif

    if (sender.selected)
    {
        BMWeakType(sender)
        BMWeakSelf
        [self.controlPopoverView dismissViewControllerAnimated:NO completion:nil];
        [self.upHandPopTableView dismissViewControllerAnimated:NO completion:nil];
        [self.layoutPopoverView dismissViewControllerAnimated:NO completion:nil];

        classEndAlertVC = [UIAlertController alertControllerWithTitle:YSLocalized(@"Prompt.FinishClass") message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *confimAc = [UIAlertAction actionWithTitle:YSLocalized(@"Prompt.OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            weaksender.userInteractionEnabled = NO;
            [weakSelf.liveManager sendSignalingTeacherToDismissClass];
        }];
        UIAlertAction *cancle = [UIAlertAction actionWithTitle:YSLocalized(@"Prompt.Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [classEndAlertVC addAction:confimAc];
        [classEndAlertVC addAction:cancle];
        
#if YSSDK
        classEndAlertVC.sc_Autorotate = ![YSSDKManager sharedInstance].useAppDelegateAllowRotation;
#else
        classEndAlertVC.sc_Autorotate = !GetAppDelegate.useAllowRotation;
#endif
        classEndAlertVC.sc_OrientationMask = UIInterfaceOrientationMaskLandscape;
        classEndAlertVC.sc_Orientation = UIInterfaceOrientationLandscapeRight;
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
    // 视频+白板背景
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, STATETOOLBAR_HEIGHT, self.contentWidth, self.contentHeight - STATETOOLBAR_HEIGHT)];
    contentView.backgroundColor = [UIColor clearColor];
    [self.contentBackgroud addSubview:contentView];
    self.contentView = contentView;
    contentView.layer.masksToBounds = YES;
    
    // 白板背景
    UIView *whitebordBackgroud = [[UIView alloc] init];
    [self.contentView addSubview:whitebordBackgroud];
    self.whitebordBackgroud = whitebordBackgroud;
    whitebordBackgroud.layer.masksToBounds = YES;
    whitebordBackgroud.backgroundColor = UIColor.clearColor;
    
    if (self.liveManager.roomModel.skinModel.whiteboardType == CHSkinWhiteboardType_color)
    {
        if ([self.liveManager.roomModel.skinModel.whiteboardValue bm_isNotEmpty])
        {
            UIColor *color = [UIColor bm_colorWithHexString:self.liveManager.roomModel.skinModel.whiteboardValue];
            
            [self.liveManager.whiteBoardManager changeMainCourseViewBackgroudColor:color];
 
            [self.liveManager.whiteBoardManager changeMainWhiteBoardBackgroudColor:YSSkinDefineColor(@"Color9")];
        }
    }
    else if (self.liveManager.roomModel.skinModel.whiteboardType == CHSkinWhiteboardType_image)
    {
        NSString *imageUrl = self.liveManager.roomModel.skinModel.whiteboardValue;
        if (self.liveManager.roomModel.roomUserType == CHRoomUserType_More)
        {
            imageUrl = self.liveManager.roomModel.skinModel.whiteboardSecondValue;
        }
        
        imageUrl = [imageUrl bm_URLEncode];
        
        [self.liveManager.whiteBoardManager changeMainCourseViewBackImageUrl:[NSURL URLWithString:imageUrl]];
    }
    else
    {
        
        [self.liveManager.whiteBoardManager changeMainCourseViewBackgroudColor:UIColor.clearColor];
        [self.liveManager.whiteBoardManager changeMainWhiteBoardBackgroudColor:UIColor.clearColor];
    }
    
    // 视频背景
    UIView *videoBackgroud = [[UIView alloc] init];
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
    if (self.roomtype == CHRoomUserType_One)
    {
        self.expandContractBtn = [[UIButton alloc]initWithFrame:CGRectZero];
        [self.expandContractBtn addTarget:self action:@selector(doubleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.expandContractBtn setBackgroundImage:YSSkinElementImage(@"doubleTeacher_littleView", @"iconNor") forState:UIControlStateNormal];
        [self.expandContractBtn setBackgroundImage:YSSkinElementImage(@"doubleTeacher_littleView", @"iconSel") forState:UIControlStateSelected];
        self.expandContractBtn.tag = DoubleTeacherExpandContractBtnTag;
        self.expandContractBtn.hidden = YES;
        [self.videoBackgroud addSubview:self.expandContractBtn];
        [self setUp1V1DefaultVideoView];
    }
    else
    {
        // 添加浮动视频窗口
        self.dragOutFloatViewArray = [[NSMutableArray alloc] init];
        
        // 1VN 初始本人视频音频
        CHVideoView *videoView = [[CHVideoView alloc] initWithRoomUser:YSCurrentUser withSourceId:sCHUserDefaultSourceId isForPerch:YES withDelegate:self];
        videoView.appUseTheType = self.appUseTheType;
        [self addVideoViewToVideoViewArrayDic:videoView];
        
                
        self.myVideoView = videoView;
        
        [self.liveManager playVideoWithUserId:YSCurrentUser.peerID streamID:videoView.streamId  renderMode:CloudHubVideoRenderModeHidden mirrorMode:CloudHubVideoMirrorModeEnabled inView:videoView.contentView];
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
    [self.liveManager.whiteBoardManager refreshMainWhiteBoard];
    
    self.mp4ControlView = [[YSMp4ControlView alloc] init];
    [self.contentBackgroud addSubview:self.mp4ControlView];
    self.mp4ControlView.frame = CGRectMake(30, self.contentHeight - 100, self.contentWidth - 60, 74);
    self.mp4ControlView.backgroundColor = [YSSkinDefineColor(@"Color5") bm_changeAlpha:0.6];
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
    self.mp3ControlView.backgroundColor = [YSSkinDefineColor(@"Color5") bm_changeAlpha:0.6];
    [UIColor bm_colorWithHex:0x736D78 alpha:0.39];
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

    if (self.liveManager.localUser.role == CHUserType_Teacher)
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
    CHSharedMediaFileModel *mediaFileModel = self.mp4ControlView.mediaFileModel;
    [self.liveManager stopSharedMediaFile:mediaFileModel.fileUrl];
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
//- (void)handleSignalingToDoubleTeacherWithData:(NSDictionary *)data
//{
//    self.isDoubleType = 1;
//
//    self.doubleType = [data bm_stringForKey:@"one2one"];
//
//    if ([self.doubleType isEqualToString:@"nested"])
//    {
//        self.roomLayout = CHRoomLayoutType_DoubleLayout;
//    }
//    else
//    {
//        self.roomLayout = CHRoomLayoutType_AroundLayout;
//    }
//
//    [self freshContentView];
//}

/// 双师信令时计算视频尺寸
- (void)doubleTeacherCalculateVideoSize
{
    if (self.roomLayout == CHRoomLayoutType_VideoLayout)
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
    else if (self.roomLayout == CHRoomLayoutType_AroundLayout)
    {//默认上下平行关系
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
    else if (self.roomLayout == CHRoomLayoutType_DoubleLayout)//画中画
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
    
    [self freshWhitBordContentView];
}

/// 1V1 初始默认视频背景
- (void)setUp1V1DefaultVideoView
{
    // 1V1 初始本人视频音频
    CHVideoView *videoView = [[CHVideoView alloc] initWithRoomUser:YSCurrentUser withSourceId:sCHUserDefaultSourceId isForPerch:YES withDelegate:self];
    videoView.frame = CGRectMake(0, 0, videoWidth, videoHeight);
    videoView.appUseTheType = self.appUseTheType;
    videoView.tag = PlaceholderPTag;
    
    [self.videoBackgroud addSubview:videoView];
    [self.teacherVideoViewArray addObject:videoView];

    self.myVideoView = videoView;
    
    [self.liveManager playVideoWithUserId:YSCurrentUser.peerID streamID:nil renderMode:CloudHubVideoRenderModeHidden mirrorMode:CloudHubVideoMirrorModeEnabled inView:videoView.contentView];
#if YSAPP_NEWERROR
    [self.liveManager playVideoOnView:videoView withPeerId:YSCurrentUser.peerID renderType:YSRenderMode_adaptive completion:nil];
    [self.liveManager playAudio:YSCurrentUser.peerID completion:nil];
#endif
    
    // 1V1 初始学生视频蒙版
    UIImageView *imageView = [[UIImageView alloc] initWithImage:YSSkinDefineImage(@"main_uservideocover")];
    CHRoomUser *roomUser = [[CHRoomUser alloc] initWithPeerId:@"0"];
    roomUser.role = CHUserType_Student;
    CHVideoView *userVideoView = [[CHVideoView alloc] initWithRoomUser:roomUser withSourceId:nil isForPerch:YES withDelegate:self];
    userVideoView.appUseTheType = self.appUseTheType;
    userVideoView.tag = PlaceholderPTag;
    userVideoView.frame = CGRectMake(0, 0, videoWidth, videoHeight);
    imageView.frame = userVideoView.bounds;
    [userVideoView addSubview:imageView];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.backgroundColor = YSSkinDefineColor(@"Color9");
    [self.videoBackgroud addSubview:userVideoView];
    [imageView bm_sendOneLevelDown];
    
    if (self.isWideScreen)
    {
        CGFloat orgainalY = (whitebordHeight - 2 * videoHeight - VIDEOVIEW_GAP)/2;
        self.teacherVideoViewArray.firstObject.frame = CGRectMake(0, orgainalY, videoWidth, videoHeight);
        userVideoView.frame = CGRectMake(0, orgainalY + videoHeight + VIDEOVIEW_GAP, videoWidth, videoHeight);
    }
    else
    {
        self.teacherVideoViewArray.firstObject.frame = CGRectMake(0, 0, videoWidth, videoHeight);
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
        if (self.teacherVideoViewArray.firstObject && !self.teacherVideoViewArray.firstObject.isDragOut && !self.teacherVideoViewArray.firstObject.isFullScreen)
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
    
    [self.contentBackgroud addSubview:whitebordFullBackgroud];
    whitebordFullBackgroud.frame = CGRectMake(0, 0, self.contentWidth, self.contentHeight);
    self.whitebordFullBackgroud = whitebordFullBackgroud;
    self.whitebordFullBackgroud.hidden = YES;
    whitebordFullBackgroud.layer.masksToBounds = YES;
    whitebordFullBackgroud.backgroundColor = self.contentBackgroud.backgroundColor;
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
    if (self.roomtype == CHRoomUserType_One)
    {
        if (self.roomLayout == CHRoomLayoutType_VideoLayout)
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
        }
        whitebordWidth = 2 * videoWidth;
        whitebordHeight = ceil(whitebordWidth * 3/4);
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
        
        NSInteger teacherWidth = ceil((self.contentWidth - VIDEOVIEW_GAP * 0.5 * 8)/7);
        
        videoTeacherHeight = ceil(teacherWidth / scale);
        if (count < 8)
        {
            videoTeacherWidth = teacherWidth;
        }
        else
        {
            videoTeacherWidth = ceil((self.contentWidth - VIDEOVIEW_GAP * 0.5 * (count + 1))/count);
        }
        
        videoWidth = videoTeacherWidth;
        videoHeight = videoTeacherHeight;
        
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
    if (self.roomtype == CHRoomUserType_One)
    {
        if(self.videoSequenceArr.count>1)
        {
            self.userVideoView.hidden = YES;
        }
        else
        {
            self.userVideoView.hidden = NO;
            if (self.videoSequenceArr.count == 1)
            {
//                CHVideoView *videoView = self.videoViewArray.firstObject;
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
        
        if (self.roomLayout == CHRoomLayoutType_VideoLayout)
        {
            [self freshVideoGridView];
        }
        else
        {
            [self freshContentVideoView];
            [self.videoBackgroud bringSubviewToFront:self.userVideoView];
        }
    }
    else
    {
        if (self.roomLayout == CHRoomLayoutType_VideoLayout || self.roomLayout == CHRoomLayoutType_FocusLayout)
        {
            [self freshVideoGridView];
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
            [self freshContentVideoView];
        }
    }
}
// 刷新content视频布局
- (void)freshContentVideoView
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
    
    for (CHVideoView *videoView in viewArray)
    {
        if (videoView.tag != PlaceholderPTag && videoView.tag != DoubleTeacherExpandContractBtnTag)
        {
            [videoView removeFromSuperview];
        }
    }
    
    for (CHVideoView *videoView in self.videoSequenceArr)
    {
        if (videoView.isDragOut || videoView.isFullScreen)
        {
            continue;
        }
        
        [self.videoBackgroud addSubview:videoView];
    }
    
    if (self.isDoubleType && self.roomtype == CHRoomUserType_One)
    {
        [self doubleTeacherCalculateVideoSize];
        [self doubleTeacherArrangeVideoView];
    }
    else
    {
        [self calculateVideoSize];
        [self arrangeVideoView];
    }
}

///排布双师模式视图
- (void)doubleTeacherArrangeVideoView
{
    for (NSUInteger i=0; i<self.videoSequenceArr.count; i++)
    {
        CHVideoView *view = self.videoSequenceArr[i];
        if (view.isFullScreen)
        {
            continue;
        }
        
        if (self.roomLayout == CHRoomLayoutType_VideoLayout)
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
        else if (self.roomLayout == CHRoomLayoutType_AroundLayout)
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
        else if (self.roomLayout == CHRoomLayoutType_DoubleLayout)
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
}


///排布视图
- (void)arrangeVideoView
{
//    NSMutableArray * videoArr = [self videoViewsSequence];
    
    if (self.roomtype == CHRoomUserType_One)
    {
        for (NSUInteger i=0; i<self.videoSequenceArr.count; i++)
        {
            CHVideoView *view = self.videoSequenceArr[i];
            if (view.isFullScreen)
            {
                continue;
            }
            
            if (self.roomLayout == CHRoomLayoutType_VideoLayout)
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

                    if (view.roomUser.role == CHUserType_Teacher)
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
                    if (view.roomUser.role == CHUserType_Teacher)
                    {
                        view.frame = CGRectMake(0, 0, videoWidth, videoHeight);
                    }
                    else
                    {
                        view.frame = CGRectMake(0, videoHeight, videoWidth, videoHeight);
                    }
                }
            }
        }
    }
    else
    {
        CGFloat totalWidth = [self getVideoTotalWidth];
                
        videoStartX = (self.contentWidth-totalWidth)*0.5;
        
        NSInteger count = [self getVideoViewCount];
        
        NSUInteger index = 0;
        
        for (int i = 0; i < self.videoSequenceArr.count; i++)
        {
            CHVideoView *view = self.videoSequenceArr[i];

            if (view.isDragOut || view.isFullScreen)
            {
                continue;
            }
            if (count < 8)
            {
                view.frame = CGRectMake(videoStartX+(videoWidth+VIDEOVIEW_GAP*0.5)*index, VIDEOVIEW_GAP*0.5, videoWidth, videoHeight);
            }
            else
            {
                view.frame = CGRectMake(VIDEOVIEW_GAP * 0.5 + (videoWidth + VIDEOVIEW_GAP * 0.5) * index, VIDEOVIEW_GAP * 0.5, videoWidth, videoHeight);
            }
            index++;
        }
    }
}

/// 刷新白板尺寸
- (void)freshWhitBordContentView
{
    if (self.roomtype == CHRoomUserType_One)
    {
        if (self.roomLayout == CHRoomLayoutType_VideoLayout)
        {//左右平行关系
            self.whitebordBackgroud.hidden = YES;
            self.whitebordBackgroud.frame = CGRectMake(0, 0, whitebordWidth, whitebordHeight);

            self.videoBackgroud.frame = CGRectMake(whitebordWidth, 0, videoWidth, videoHeight);
            
            self.teacherVideoViewArray.firstObject.frame = CGRectMake(VIDEOVIEW_GAP, 0, videoWidth, videoHeight);
            self.userVideoView.frame = CGRectMake(VIDEOVIEW_GAP*2+videoWidth, 0, videoWidth, videoHeight);
            
        }
        else if (self.roomLayout == CHRoomLayoutType_AroundLayout)
        {//默认上下平行关系
            self.whitebordBackgroud.hidden = NO;
            self.whitebordBackgroud.frame = CGRectMake(0, 0, whitebordWidth, whitebordHeight);
            
            self.videoBackgroud.frame = CGRectMake(whitebordWidth + VIDEOVIEW_GAP, 0, videoWidth, whitebordHeight);
            
            if (self.isWideScreen)
            {//16:9
                
                CGFloat orgainalY = (whitebordHeight - 2 * videoHeight - VIDEOVIEW_GAP)/2;
                
                self.teacherVideoViewArray.firstObject.frame = CGRectMake(0, orgainalY, videoWidth, videoHeight);
                //                    self.teacherPlacehold.frame = CGRectMake(0, orgainalY, videoWidth, videoHeight);
                self.userVideoView.frame = CGRectMake(0, orgainalY + videoHeight + VIDEOVIEW_GAP, videoWidth, videoHeight);
            }
            else
            {//4:3
                self.teacherVideoViewArray.firstObject.frame = CGRectMake(0, 0, videoWidth, videoHeight);
                //                    self.teacherPlacehold.frame = CGRectMake(0, 0, videoWidth, videoHeight);
                self.userVideoView.frame = CGRectMake(0, videoHeight, videoWidth, videoHeight);
            }
        }
        else if (self.roomLayout == CHRoomLayoutType_DoubleLayout)
        {//画中画
            self.whitebordBackgroud.hidden = NO;
            CGFloat whitebordY = (self.contentHeight - STATETOOLBAR_HEIGHT - whitebordHeight)/2;
            
            self.whitebordBackgroud.frame = CGRectMake(0, whitebordY, whitebordWidth, whitebordHeight);
            self.videoBackgroud.frame = CGRectMake(whitebordWidth + VIDEOVIEW_GAP, whitebordY, videoTeacherWidth, whitebordHeight);
            
            self.teacherVideoViewArray.firstObject.frame = CGRectMake(0, 0, videoTeacherWidth, videoTeacherHeight);
            self.userVideoView.frame = CGRectMake(CGRectGetMaxX(self.teacherVideoViewArray.firstObject.frame)-videoWidth, 0, videoWidth, videoHeight);
            self.studentVideoView = self.userVideoView;
            self.expandContractBtn.hidden = NO;
            self.expandContractBtn.selected = NO;
            self.expandContractBtn.frame = CGRectMake(self.userVideoView.bm_originX-23, self.userVideoView.bm_originY, 23, videoHeight);
            self.expandContractBtn.bm_right = self.userVideoView.bm_left;
            
            [self.userVideoView bm_bringToFront];
            [self.expandContractBtn bm_bringToFront];
        }
    }
    else
    {
        self.videoBackgroud.frame = CGRectMake(0, 0, self.contentWidth, videoTeacherHeight + VIDEOVIEW_GAP);

        self.whitebordBackgroud.frame = CGRectMake((self.contentWidth - whitebordWidth)/2, self.videoBackgroud.bm_bottom, whitebordWidth, whitebordHeight);
    }
    if (!floatVideoDefaultWidth)
    {
        [self calculateFloatVideoSize];
    }
    [self freshWhiteBordViewFrame];
}

- (void)freshWhiteBordViewFrame
{
    if (!self.fullFloatVideoView.hidden)
    {
        self.whiteBordView.frame = CGRectMake(0, 0, self.whitebordFullBackgroud.bm_width, self.whitebordFullBackgroud.bm_height);
    }
    else
    {
        self.whiteBordView.frame = self.whitebordBackgroud.bounds;
    }

    [self.liveManager.whiteBoardManager refreshMainWhiteBoard];
}

// 刷新宫格视频布局
- (void)freshVideoGridView
{
    [self hideAllDragOutVideoView];
        
    NSMutableArray *viewArray = [[NSMutableArray alloc] init];
    [self.videoBackgroud.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull childView, NSUInteger idx, BOOL * _Nonnull stop) {
        [viewArray addObject:childView];
    }];
//    if (!self.liveManager.isClassBegin)
//    {
//        viewArray = self.videoSequenceArr;
//    }
//    else
//    {
        for (CHVideoView *videoView in viewArray)
        {
            if (videoView.tag != DoubleTeacherExpandContractBtnTag)
            {
                [videoView removeFromSuperview];
            }
        }
//    }
    
    if (!self.liveManager.isClassBegin && ![self.videoSequenceArr bm_isNotEmpty])
    {
        if (self.teacherVideoViewArray.firstObject)
        {
            self.videoSequenceArr = [NSMutableArray array];
            [self.videoSequenceArr addObject:self.teacherVideoViewArray.firstObject];
        }
    }
    
//    if (self.videoViewArray.count<22)
//    {
//        for (int i = 0; i<22; i++)
//        {
//
//            YSRoomUser * user = [[YSRoomUser alloc]initWithPeerId:[NSString stringWithFormat:@"jjj%d",i]];
//            CHVideoView * video = [[CHVideoView alloc]initWithRoomUser:user];
//            [self.videoViewArray addObject:video];
//        }
//    }
//
//    [self.videoGridView freshViewWithVideoViewArray:self.videoViewArray withFouceVideo:self.fouceView withRoomLayout:self.roomLayout withAppUseTheType:self.appUseTheType];
    if (self.isDoubleType)
    {
        [self.videoGridView freshViewWithVideoViewArray:self.videoSequenceArr withFouceVideo:nil withRoomLayout:self.roomLayout withAppUseTheType:self.appUseTheType];
    }
    else
    {
        [self.videoGridView freshViewWithVideoViewArray:self.videoSequenceArr withFouceVideo:self.fouceView withRoomLayout:self.roomLayout withAppUseTheType:self.appUseTheType];
    }
        
    [self arrangeAllViewInContentBackgroudViewWithViewType:SCMain_ArrangeContentBackgroudViewType_VideoGridView index:0];
    self.contentView.hidden = YES;
    self.videoGridView.hidden = NO;
}


#pragma mark - pollingArr

- (void)addPollingUserWithUserId:(NSString *)peerId
{
    if (![self.pollingUserList containsObject:peerId])
    {
        [self.pollingUserList addObject:peerId];
    }
}


#pragma mark - videoViewArray

/// 开关摄像头
- (void)onRoomCloseVideo:(BOOL)close withUid:(NSString *)uid sourceID:(NSString *)sourceId streamId:(NSString *)streamId
{
    [super onRoomCloseVideo:close withUid:uid sourceID:sourceId streamId:streamId];
}

/// 开关麦克风
- (void)onRoomCloseAudio:(BOOL)close withUid:(NSString *)uid
{
    [super onRoomCloseAudio:close withUid:uid];
}

/// 收到音视频流
- (void)onRoomStartVideoOfUid:(NSString *)uid sourceID:(NSString *)sourceId streamId:(NSString *)streamId
{
    [super onRoomStartVideoOfUid:uid sourceID:sourceId streamId:streamId];

    [self freshFullFloatViewWithPeerId:uid];
}

/// 停止音视频流
- (void)onRoomStopVideoOfUid:(NSString *)uid sourceID:(NSString *)sourceId streamId:(NSString *)streamId
{
    [super onRoomStopVideoOfUid:uid sourceID:sourceId streamId:streamId];
    
    [self freshFullFloatViewWithPeerId:uid];
}

#pragma mark  添加视频窗口

- (NSMutableArray<CHVideoView *> *)addVideoViewWithPeerId:(NSString *)peerId
{
    NSMutableArray *newVideoViewArray = [super addVideoViewWithPeerId:peerId];
    
    return [self videoViewFrash:newVideoViewArray withPeerId:peerId];
}

#pragma mark  某人的摄像头设备变更
//设备变化时
- (NSMutableArray<CHVideoView *> *)freshVideoViewsCountWithPeerId:(NSString *)peerId withSourceIdArray:(NSMutableArray<NSString *> *)sourceIdArray withMaxCount:(NSUInteger)count
{
    NSMutableArray *videoViewArray = [super freshVideoViewsCountWithPeerId:peerId withSourceIdArray:(NSMutableArray<NSString *> *)sourceIdArray withMaxCount:count];
    
    return [self videoViewFrash:videoViewArray withPeerId:peerId];
}

- (NSMutableArray<CHVideoView *> *)videoViewFrash:(NSMutableArray<CHVideoView *> *)videoArray withPeerId:(NSString *)peerId
{
    [self.controlPopoverView dismissViewControllerAnimated:NO completion:nil];
    [self.upHandPopTableView dismissViewControllerAnimated:NO completion:nil];
    [self.layoutPopoverView dismissViewControllerAnimated:NO completion:nil];
    
    CHRoomUser *roomUser = [self.liveManager getRoomUserWithId:peerId];
    if (!roomUser)
    {
        return nil;
    }
    
    ///  轮播 设置上台的人在数组最后
    if (roomUser.role == CHUserType_Student)
    {
        [self.pollingUserList removeObject:roomUser.peerID];
        [self.pollingUserList addObject:roomUser.peerID];
    }
    
    if (videoArray.count)
    {
        /// 轮播相关逻辑
        if (roomUser.role == CHUserType_Student)
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
    
    [self freshFullFloatViewWithPeerId:peerId];

    return videoArray;
}

#pragma mark  删除视频窗口

- (CHVideoView *)delVideoViewWithPeerId:(NSString *)peerId andSourceId:(NSString *)sourceId
{
    CHVideoView *delVideoView = [super delVideoViewWithPeerId:peerId andSourceId:sourceId];

    [self.controlPopoverView dismissViewControllerAnimated:NO completion:nil];
    [self.upHandPopTableView dismissViewControllerAnimated:NO completion:nil];
    [self.layoutPopoverView dismissViewControllerAnimated:NO completion:nil];
    
    if (delVideoView)
    {
        [self.pollingUpPlatformArr removeObject:peerId];///删除视频的同时删除轮播上台数据
        
        //焦点用户退出
        if ([self.fouceView.roomUser.peerID isEqualToString:peerId])
        {
            self.roomLayout = CHRoomLayoutType_VideoLayout;
            
            [self.liveManager sendSignalingToChangeLayoutWithLayoutType:self.roomLayout appUserType:self.appUseTheType withFouceUserId:peerId withStreamId:self.fouceView.streamId];
            self.fouceView = nil;
            self.controlPopoverView.fouceStreamId = nil;
            self.controlPopoverView.foucePeerId = nil;
        }
        
        if (delVideoView.isDragOut)
        {
            [self hideDragOutVideoViewWithStreamId:delVideoView.streamId];
        }
        else if (delVideoView.isFullScreen)
        {
            [self handleSignalingDragOutVideoChangeFullSizeWithPeerId:nil withSourceId:nil isFull:NO];
        }
        else
        {
            [self freshContentView];
            
            [self freshFullFloatViewWithPeerId:peerId];
        }
    }
    
    return delVideoView;
}

- (void)kickedOutFromRoom:(NSUInteger)reasonCode
{
    NSString *reasonString = YSLocalized(@"KickOut.Repeat");//(@"KickOut.SentOutClassroom");
    
    [self.controlPopoverView dismissViewControllerAnimated:NO completion:nil];
    [self.upHandPopTableView dismissViewControllerAnimated:NO completion:nil];
    [self.layoutPopoverView dismissViewControllerAnimated:NO completion:nil];

    [self.imagePickerController cancelButtonClick];
    
    [BMProgressHUD bm_showHUDAddedTo:self.view animated:YES withDetailText:reasonString delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
}


#pragma mark -
#pragma mark YSLiveRoomManagerDelegate

/// 大并发房间
- (void)onRoomChangeToBigRoomIsHistory:(BOOL)isHistory
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
}

- (void)onRoomReJoined
{
    [super onRoomReJoined];
    self.spreadBottomToolBar.userEnable = YES;
//    if (self.liveManager.isBigRoom)
//    {
//        if (self.liveManager.bigRoomUserCount > 1)
//        {
//            return;
//        }
//    }
//    else
//    {
//        if (self.liveManager.userList.count > 1)
//        {
//            return;
//        }
//    }
    [self deleateAllView];
    [self updataSubViews];
}


- (void)updataSubViews
{
    classEndAlertVC = nil;
    _personListCurentPage = 0;
    _personListTotalPage = 0;
    _isMp4Play = NO;
    _isMp4ControlHide = NO;
    searchArr = [[NSMutableArray alloc] init];
    self.pollingUserList = [[NSMutableArray alloc] init];
    self.pollingUpPlatformArr = [[NSMutableArray alloc] init];
    self.currentFileList = [[NSMutableArray alloc] init];
    isSearch = NO;
    _isPolling = NO;

    /// 初始化顶栏数据
    [self setupStateBarData];

    [self.spreadBottomToolBar bm_bringToFront];
    
    //创建上下课按钮
    [self setupClassBeginButton];
    
    self.spreadBottomToolBar.isBeginClass = self.liveManager.isClassBegin;
    self.spreadBottomToolBar.isPollingEnable = NO;
    self.spreadBottomToolBar.isToolBoxEnable = NO;
    self.spreadBottomToolBar.isCameraEnable = YES;
    self.spreadBottomToolBar.isEveryoneNoAudio = self.liveManager.isEveryoneNoAudio;
}


/// 删除所有子View 定时器 弹框 等
- (void)deleateAllView
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
    
    if (self.bigRoomTimer)
    {
        dispatch_source_cancel(self.bigRoomTimer);
        self.bigRoomTimer = nil;
    }
    
    [self.controlPopoverView dismissViewControllerAnimated:NO completion:nil];
    [self.upHandPopTableView dismissViewControllerAnimated:NO completion:nil];
    [self.layoutPopoverView dismissViewControllerAnimated:NO completion:nil];
    
    [self.imagePickerController cancelButtonClick];
    
    if (self.pollingTimer)
    {
        dispatch_source_cancel(self.pollingTimer);
        self.pollingTimer = nil;
    }
    // 网络中断尝试失败后退出
    [[BMNoticeViewStack sharedInstance] closeAllNoticeViews];// 清除alert的栈
    [self.classBeginBtn removeFromSuperview];

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

    [self.imagePickerController cancelButtonClick];
    
    if (self.pollingTimer)
    {
        dispatch_source_cancel(self.pollingTimer);
        self.pollingTimer = nil;
    }
    // 网络中断尝试失败后退出
    [[BMNoticeViewStack sharedInstance] closeAllNoticeViews];// 清除alert的栈
    
    [self.controlPopoverView dismissViewControllerAnimated:NO completion:nil];
    [self.upHandPopTableView dismissViewControllerAnimated:NO completion:nil];
    [self.layoutPopoverView dismissViewControllerAnimated:NO completion:nil];

    if (self.presentedViewController)
    {
        // 关闭未知实模式VC
        [self dismissViewControllerAnimated:NO completion:^{
#if YSSDK
            [self.liveManager onSDKRoomWillLeft];
#endif
            [self dismissViewControllerAnimated:YES completion:^{
#if YSSDK
                [self.liveManager onSDKRoomLeft];
#endif
                [YSLiveManager destroy];
            }];
        }];
        return;
    }
    
#if YSSDK
    [self.liveManager onSDKRoomWillLeft];
#endif
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
- (void)onRoomNetworkQuality:(CHNetQuality)networkQuality delay:(NSInteger)delay
{
    if (networkQuality>CHNetQuality_VeryBad)
    {
        [self bringSomeViewToFront];
        [self.progressHUD bm_showAnimated:NO withDetailText:YSLocalized(@"Error.WaitingForNetwork") delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
    }
}

#pragma mark  用户进入
- (void)onRoomUserJoined:(CHRoomUser *)user isHistory:(BOOL)isHistory
{
    [super onRoomUserJoined:user isHistory:isHistory];
    
    [self freshTeacherPersonListData];
        
    NSInteger userCount = self.liveManager.studentCount;
    self.handNumLab.text = [NSString stringWithFormat:@"%ld/%ld",(long)self.raiseHandArray.count,(long)userCount];

    if (user.role == CHUserType_Student)
    {
        [self addPollingUserWithUserId:user.peerID];
    }
    
    [self bottomToolBarPollingBtnEnable];
    self.spreadBottomToolBar.isPolling = _isPolling;
}

/// 用户退出
- (void)onRoomUserLeft:(CHRoomUser *)user
{
    [super onRoomUserLeft:user];
    
    NSMutableArray * userVideoVivews = [self.videoViewArrayDic bm_mutableArrayForKey:user.peerID];
    
    for (CHVideoView * videoVivew in userVideoVivews)
    {
        [self delVideoViewWithPeerId:user.peerID andSourceId:videoVivew.sourceId];
    }
    
    [self freshTeacherPersonListData];
    
    //焦点用户退出
    if ([self.fouceView.roomUser.peerID isEqualToString:user.peerID])
    {
        self.roomLayout = CHRoomLayoutType_VideoLayout;
        [self.liveManager sendSignalingToChangeLayoutWithLayoutType:self.roomLayout appUserType:self.appUseTheType withFouceUserId:user.peerID withStreamId:self.fouceView.streamId];
        self.fouceView = nil;
        self.controlPopoverView.fouceStreamId = nil;
        self.controlPopoverView.foucePeerId = nil;
    }
    
    NSInteger userCount = self.liveManager.studentCount;

    self.handNumLab.text = [NSString stringWithFormat:@"%ld/%ld",(long)self.raiseHandArray.count,(long)userCount];
    
    /// 删除轮播字典里边的该学生
    if (user.role == CHUserType_Student)
    {
        [self.pollingUserList removeObject:user.peerID];
   
        if ([self.pollingUpPlatformArr containsObject:user.peerID])
        {
            [self.pollingUpPlatformArr removeObject:user.peerID];
        }
    }
    
    if (_isPolling)
    {
        NSInteger total = 0;
        for (CHRoomUser * user in self.liveManager.userList)
        {
            if (user.role == CHUserType_Student || user.role == CHUserType_Teacher)
            {
                total++;
            }
        }
#warning 台上人 + 台下人
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
- (void)onRoomBigRoomFreshUserCountIsHistory:(BOOL)isHistory
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
    [self.layoutPopoverView dismissViewControllerAnimated:NO completion:nil];

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
    for (CHVideoView * videoView in self.videoSequenceArr)
    {
        [mutArray addObject:videoView.roomUser];
    }
    
    if ([mutArray bm_isNotEmpty])
    {
        for (int i = 0; i<raiseHandUserArray.count; i++)
        {
            NSMutableDictionary * userDict = raiseHandUserArray[i];
            CHPublishState publishState = CHUser_PublishState_DOWN;
            for (int j = 0; j<mutArray.count; j++)
            {
                CHRoomUser * videoUser = mutArray[j];
                
                if ([videoUser.peerID isEqualToString:[userDict bm_stringForKey:@"peerId"]])
                {
                    publishState = videoUser.publishState;
                    break;
                }
            }
            if (publishState > CHUser_PublishState_DOWN)
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

//上下台
- (void)userPublishstatechange:(CHRoomUser *)roomUser
{
    [super userPublishstatechange:roomUser];
    
    CHPublishState publishState = roomUser.publishState;
    NSString *userId = roomUser.peerID;

    if (publishState == CHUser_PublishState_UP)
    {
        [self addVideoViewWithPeerId:userId];
    }
    else
    {
        NSMutableArray * userVideoVivews = [self.videoViewArrayDic bm_mutableArrayForKey:roomUser.peerID];
        
        for (CHVideoView * videoVivew in userVideoVivews)
        {
            [self delVideoViewWithPeerId:roomUser.peerID andSourceId:videoVivew.sourceId];
        }
        
        if (self.controlPopoverView.presentingViewController)
        {
            [self.controlPopoverView dismissViewControllerAnimated:NO completion:nil];
        }
    }
    
    for (NSMutableDictionary *userDict in self.raiseHandArray)
    {
        if ([[userDict bm_stringForKey:@"peerId"] isEqualToString:userId])
        {
            [userDict setValue:@(publishState) forKey:@"publishState"];
            self.upHandPopTableView.userArr = self.raiseHandArray;
            break;
        }
    }
    
#if USE_FullTeacher
    if (roomUser.role == CHUserType_Teacher)
    {
        /// 老师中途进入房间上课时的全屏处理
        if (!self.fullFloatVideoView.hidden)
        {
            [self fullScreenToShowVideoView:YES];
        }
    }
#endif
}

- (void)onRoomUserPropertyChanged:(NSString *)userId fromeUserId:(NSString *)fromeUserId properties:(NSDictionary *)properties
{
    NSMutableArray * videoViewArr = [self.videoViewArrayDic bm_mutableArrayForKey:userId];
    CHRoomUser *roomUser = [self.liveManager getRoomUserWithId:userId];

    if (!roomUser)
    {
        return;
    }
    
#if FRESHWITHROOMUSER
    if (!self.whitebordFullBackgroud.hidden && [roomUser.peerID isEqualToString:self.liveManager.teacher.peerID])
    {
        [self.fullTeacherVideoView freshWithRoomUserProperty:self.liveManager.teacher];
    }
    // 网络状态 + 设备状态
    if ([properties bm_containsObjectForKey:sCHUserNetWorkState] || [properties bm_containsObjectForKey:sCHUserMic])
    {
        for (CHVideoView * videoView in videoViewArr)
        {
            [videoView freshWithRoomUserProperty:roomUser];
        }
    }
#endif
    
    //摄像头变更
    if ([properties bm_containsObjectForKey:sCHUserCameras])
    {
        if (roomUser.publishState == CHUser_PublishState_UP)
        {
#warning 双摄逻辑
            NSDictionary * dict = [properties bm_dictionaryForKey:sCHUserCameras];
            [self freshVideoViewsCountWithPeerId:userId withSourceIdArray:[dict.allKeys mutableCopy] withMaxCount:maxVideoCount];
        }
    }
    
    // 举手上台
    if ([properties bm_containsObjectForKey:sCHUserRaisehand])
    {
        BOOL raisehand = [properties bm_boolForKey:sCHUserRaisehand];
        
        if (roomUser.publishState == CHUser_PublishState_UP && raisehand)
        {
            for (CHVideoView *videoView in videoViewArr)
            {
                videoView.isRaiseHand = YES;
            }
        }
        else
        {
            for (CHVideoView *videoView in videoViewArr)
            {
                videoView.isRaiseHand = NO;
            }
        }
    }
     
    // 奖杯数
    if ([properties bm_containsObjectForKey:sCHUserGiftNumber])
    {
        CHRoomUser *fromUser = [self.liveManager getRoomUserWithId:fromeUserId];
        if (fromUser.role != CHUserType_Student && videoViewArr.count)
        {
#if FRESHWITHROOMUSER
            NSUInteger giftNumber = [properties bm_uintForKey:sCHUserGiftNumber];
            for (CHVideoView *videoView in videoViewArr)
            {
                videoView.giftNumber = giftNumber;
            }
#endif

            CHVideoView *videoView = videoViewArr[0];
            [self showGiftAnimationWithVideoView:videoView];
        }
    }
    
#if FRESHWITHROOMUSER
    // 画笔颜色值
    if ([properties bm_containsObjectForKey:sCHUserPrimaryColor])
    {
        NSString *colorStr = [properties bm_stringTrimForKey:sCHUserPrimaryColor];
        if ([colorStr bm_isNotEmpty])
        {
            for (CHVideoView * videoView in videoViewArr)
            {
                videoView.brushColor = colorStr;
            }
        }
    }
#endif
    
    // 画笔权限
    if ([properties bm_containsObjectForKey:sCHUserCandraw])
    {
#if FRESHWITHROOMUSER
        for (CHVideoView * videoView in videoViewArr)
        {
            videoView.canDraw = [properties bm_boolForKey:sCHUserCandraw];
        }
#endif
        if ([userId isEqualToString:self.liveManager.localUser.peerID])
        {
            BOOL canDraw = YSCurrentUser.canDraw;//[properties bm_boolForKey:sUserCandraw];
            // 设置画笔颜色初始值
            if (canDraw)
            {
                if (![[YSCurrentUser.properties bm_stringTrimForKey:sCHUserPrimaryColor] bm_isNotEmpty])
                {
                    [self setCurrentUserPrimaryColor];
                }
            }
        }
    }
    
    // 发布媒体状态（上下台）
    if ([properties bm_containsObjectForKey:sCHUserPublishstate])
    {
        [self userPublishstatechange:roomUser];
    }
   
#if FRESHWITHROOMUSER
    // 进入前后台
    if ([properties bm_containsObjectForKey:sCHUserIsInBackGround])
    {
        for (CHVideoView * videoView in videoViewArr)
        {
            [videoView freshWithRoomUserProperty:roomUser];
        }
    }
#endif
    
    // 视频镜像
    if ([properties bm_containsObjectForKey:sCHUserIsVideoMirror])
    {
        BOOL isVideoMirror = [properties bm_boolForKey:sCHUserIsVideoMirror];
        CloudHubVideoMirrorMode videoMirrorMode = CloudHubVideoMirrorModeDisabled;
        if (isVideoMirror)
        {
            videoMirrorMode = CloudHubVideoMirrorModeEnabled;
        }

        NSMutableDictionary *streamIdDic = [self.liveManager getUserStreamIdsWithUserId:userId];
        NSArray *streamIdArray = streamIdDic.allKeys;
        if ([streamIdArray bm_isNotEmpty])
        {
            for (NSString *streamId in streamIdArray)
            {
                [self.liveManager changeVideoWithUserId:userId streamID:streamId renderMode:CloudHubVideoRenderModeHidden mirrorMode:videoMirrorMode];
            }
        }
        else
        {
            [self.liveManager changeVideoWithUserId:userId streamID:nil renderMode:CloudHubVideoRenderModeHidden mirrorMode:videoMirrorMode];
        }
    }

    if ([properties bm_containsObjectForKey:sCHUserPublishstate] || [properties bm_containsObjectForKey:sCHUserGiftNumber] || [properties bm_containsObjectForKey:sCHUserDisablechat])
    {
        if (roomUser.role == CHUserType_Student || roomUser.role == CHUserType_Assistant)
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
- (void)handleSignalingClassBeginWihIsHistory:(BOOL)isHistory
{
    self.classBeginBtn.userInteractionEnabled = YES;

    self.rightChatView.allDisabled = self.liveManager.isEveryoneBanChat;
    
    self.spreadBottomToolBar.isBeginClass = YES;
    [self bottomToolBarPollingBtnEnable];
    self.spreadBottomToolBar.isToolBoxEnable = YES;
    // 通知各端开始举手
    [self.liveManager sendSignalingToLiveAllAllowRaiseHand];
    
    [self.liveManager setPropertyOfUid:YSCurrentUser.peerID tell:YSCurrentUser.peerID propertyKey:sCHUserCandraw value:@(true)];
    
    self.classBeginBtn.selected = YES;

    [self freshTeacherPersonListData];

    for (CHRoomUser *roomUser in self.liveManager.userList)
    {
#if 0
        if (needFreshVideoView)
        {
            needFreshVideoView = NO;
            break;
        }
#endif
        NSString *peerID = roomUser.peerID;
        /// 轮播数组数组
        if (roomUser.role == CHUserType_Student)
        {
            [self addPollingUserWithUserId:roomUser.peerID];
        }
        
        
        if (roomUser.publishState)
        {
            [self addVideoViewWithPeerId:peerID];
            
        }
        else
        {
            [self delVideoViewWithPeerId:peerID andSourceId:sCHUserDefaultSourceId];
        }
        
    }
        
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

    [self.liveManager setPropertyOfUid:YSCurrentUser.peerID tell:CHRoomPubMsgTellAll propertyKey:sCHUserPublishstate value:@(CHUser_PublishState_UP)];
    
    if (defaultRoomLayout == CHRoomLayoutType_FocusLayout )
    {
        self.roomLayout = CHRoomLayoutType_FocusLayout;
        NSString * streamId = [NSString stringWithFormat:@"%@:video:%@",YSCurrentUser.peerID,sCHUserDefaultSourceId];
        [self.liveManager sendSignalingToChangeLayoutWithLayoutType:self.roomLayout appUserType:self.appUseTheType withFouceUserId:YSCurrentUser.peerID withStreamId:streamId];
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
   
    [self.controlPopoverView dismissViewControllerAnimated:NO completion:nil];
    [self.upHandPopTableView dismissViewControllerAnimated:NO completion:nil];
    [self.layoutPopoverView dismissViewControllerAnimated:NO completion:nil];
    
    [self.imagePickerController cancelButtonClick];

    if (![text bm_isNotEmpty])
    {
        text = YSLocalized(@"Prompt.ClassEnd");
    }
    [BMProgressHUD bm_showHUDAddedTo:YSKeyWindow animated:YES withDetailText:text delay:5.0f];
    [self.liveManager leaveRoom:nil];
}

/// 弹框
- (void)showSignalingClassEndWithText:(NSString *)text
{
    [self.controlPopoverView dismissViewControllerAnimated:NO completion:nil];
    [self.upHandPopTableView dismissViewControllerAnimated:NO completion:nil];
    [self.layoutPopoverView dismissViewControllerAnimated:NO completion:nil];
    
    [self.imagePickerController cancelButtonClick];

    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:text message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confimAc = [UIAlertAction actionWithTitle:YSLocalized(@"Prompt.OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    
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

///老师订阅举手列表
- (void)handleSignalingAllowEveryoneRaiseHand
{
    [self.liveManager sendSignalingToSubscribeAllRaiseHandMemberWithType:@"subSort"];
}

/// 房间即将关闭消息
- (BOOL)handleSignalingPrepareRoomEndWithDataDic:(NSDictionary *)dataDic addReason:(CHPrepareRoomEndType)reason
{
    NSUInteger reasonCount = [dataDic bm_uintForKey:@"reason"];
    
    int  classDelay = 30;
    
    if ([dataDic bm_containsObjectForKey:@"classDelay"])
    {
        classDelay = [[dataDic objectForKey:@"classDelay"] intValue];
    }
    
    if (reason == CHPrepareRoomEndType_TeacherLeaveTimeout)
    {//老师离开房间时间过长

        if (reasonCount == 1)
        {
            [self showSignalingClassEndWithText:YSLocalized(@"Prompt.TeacherLeave8")];
        }
    }
    else
        if (reason == CHPrepareRoomEndType_RoomTimeOut)
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
            [self.liveManager getRoomUsersWithRole:@[@(CHUserType_Assistant),@(CHUserType_Student)] startIndex:_personListCurentPage*onePageMaxUsers maxNumber:onePageMaxUsers search:@"" order:@{} callback:^(NSArray<CHRoomUser *> * _Nonnull users, NSError * _Nonnull error) {
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
            for (CHRoomUser *user in self.liveManager.userList)
            {
                if (user.role == CHUserType_Assistant || user.role == CHUserType_Student)
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
- (void)handleSignalingDragOutVideoChangeFullSizeWithPeerId:(NSString *)peerId withSourceId:(NSString *)sourceId isFull:(BOOL)isFull{
    self.isDoubleVideoBig = isFull;
    if (isFull)
    {
        if (self.doubleFloatView)
        {
            [self handleSignalingDragOutVideoChangeFullSizeWithPeerId:nil withSourceId:nil isFull:NO];
        }
                
        CHVideoView *videoView = [self getVideoViewWithPeerId:peerId andSourceId:sourceId];
        videoView.isFullScreen = isFull;
        
        [self freshContentView];
        YSFloatView *floatView = [[YSFloatView alloc] init];
        CGFloat wide = 4.0/3.0;
        if (self.isWideScreen)
        {
            wide = 16.0/9.0;
        }

        if(self.whitebordBackgroud.bm_height < self.whitebordBackgroud.bm_width)
        {
            CGFloat tempWidth = ceil(self.whitebordBackgroud.bm_height * wide);
            floatView.frame = CGRectMake(0, 0, tempWidth, self.whitebordBackgroud.bm_height);
            floatView.bm_centerX = self.whitebordBackgroud.bm_width*0.5f;
        }
        else
        {
            CGFloat tempHeight = ceil(self.whitebordBackgroud.bm_width / wide);
            floatView.frame = CGRectMake(0, 0, self.whitebordBackgroud.bm_width, tempHeight);
            floatView.bm_centerY = self.whitebordBackgroud.bm_height*0.5f;
        }
        
        [self.whitebordBackgroud addSubview:floatView];
        [floatView bm_centerInSuperView];
        [floatView showWithContentView:videoView];
        self.doubleFloatView = floatView;
        self.whiteBordView.hidden = YES;
    }
    else
    {
        CHVideoView *videoView = (CHVideoView *)self.doubleFloatView.contentView;
        videoView.isFullScreen = NO;
        [self.doubleFloatView cleanContent];
        [self.doubleFloatView removeFromSuperview];
        [self freshContentView];
        self.doubleFloatView = nil;
        self.whiteBordView.hidden = NO;
    }

//    [self freshWhiteBordViewFrame];
}


#pragma mark 本地movie stream

- (void)handlePlayMovieStreamID:(NSString *)movieStreamID userID:(NSString *)userID
{
    [self.liveManager playVideoWithUserId:userID streamID:movieStreamID renderMode:CloudHubVideoRenderModeFit mirrorMode:CloudHubVideoMirrorModeDisabled inView:self.shareVideoView];
    [self.shareVideoFloatView showMp4WaitingView];
    
    [self arrangeAllViewInVCView];
    self.shareVideoFloatView.canZoom = NO;
    self.shareVideoFloatView.backScrollView.zoomScale = 1.0;
    self.shareVideoFloatView.showWaiting = YES;
    self.shareVideoFloatView.hidden = NO;
}
- (void)handleStopMovieStreamID:(NSString *)movieStreamID userID:(NSString *)userID
{
    [self.liveManager stopVideoWithUserId:userID streamID:movieStreamID];
    [self.shareVideoFloatView showMp4WaitingView];
    self.shareVideoFloatView.canZoom = NO;
    self.shareVideoFloatView.backScrollView.zoomScale = 1.0;
    self.shareVideoFloatView.hidden = YES;
}

#pragma mark 白板视频/音频

// 播放白板视频/音频
- (void)handleWhiteBordPlayMediaFileWithMedia:(CHSharedMediaFileModel *)mediaModel
{
    [self freshTeacherCoursewareListData];
    
    if (mediaModel.isVideo)
    {
        [self showWhiteBordVideoViewWithMediaModel:mediaModel];
        self.spreadBottomToolBar.hidden = YES;
    }
    else
    {
        self.mp3ControlView.mediaFileModel = self.mediaFileModel;
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
- (void)handleWhiteBordStopMediaFileWithMedia:(CHSharedMediaFileModel *)mediaModel
{
    if (mediaModel.isVideo)
    {
        self.spreadBottomToolBar.hidden = NO;
        [self hideWhiteBordVideoViewWithMediaModel:mediaModel];
    }
    else
    {
        [self onStopMp3];
    }
    
    [self freshTeacherCoursewareListData];
}

/// 继续播放白板视频/音频
- (void)handleWhiteBordPlayMediaStream:(CHSharedMediaFileModel *)mediaFileModel
{
    if (mediaFileModel.isVideo)
    {
        if (!self.mp4ControlView.isPlay)
        {
            [self freshTeacherCoursewareListData];
        }
        self.mp4ControlView.isPlay = YES;
        [self.shareVideoFloatView showMp4WaitingView];
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
- (void)handleWhiteBordPauseMediaStream:(CHSharedMediaFileModel *)mediaFileModel
{
    if (mediaFileModel.isVideo)
    {
        if (self.mp4ControlView.isPlay)
        {
            [self freshTeacherCoursewareListData];
        }
        self.mp4ControlView.isPlay = NO;
        [self.shareVideoFloatView showMp4PauseView];
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
        [self.liveManager stopSharedMediaFile:self.mediaFileModel.fileUrl];
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
            if (self.mediaFileModel.isVideo)
            {
                [self.mp4ControlView setMediaStream:duration pos:pos isPlay:isPlay fileName:self.mediaFileModel.fileName];
            }
            else
            {
                [self.mp3ControlView setMediaStream:duration pos:pos isPlay:isPlay fileName:self.mediaFileModel.fileName];
            }
        }

        isDrag = NO;
    }
}

#pragma mark -YSMp3ControlViewDelegate
- (void)playMp3ControlViewPlay:(BOOL)isPause withFileModel:(nonnull CHSharedMediaFileModel *)mediaFileModel
{
    [self.liveManager pauseSharedMediaFile:mediaFileModel.fileUrl isPause:isPause];

    [self freshTeacherCoursewareListData];
}

- (void)sliderMp3ControlViewPos:(NSTimeInterval)value withFileModel:(CHSharedMediaFileModel *)mediaFileModel
{
    isDrag = YES;
    [self.liveManager seekSharedMediaFile:mediaFileModel.fileUrl positionByMS:value];
}

- (void)closeMp3ControlViewWithFileModel:(CHSharedMediaFileModel *)mediaFileModel
{
    [self.liveManager stopSharedMediaFile:mediaFileModel.fileUrl];
}

#pragma mark -YSMp4ControlViewDelegate

- (void)playYSMp4ControlViewPlay:(BOOL)isPause withFileModel:(CHSharedMediaFileModel *)mediaFileModel
{
    [self.liveManager pauseSharedMediaFile:mediaFileModel.fileUrl isPause:isPause];
    
    if (isPause)
    {
        if (self.liveManager.isClassBegin)
        {
            NSString *fileId = [NSString stringWithFormat:@"%@_%@", CHVideoWhiteboard_Id, mediaFileModel.fileId];
            [self.liveManager pubMsg:sCHSignal_VideoWhiteboard msgId:sCHSignal_VideoWhiteboard to:CHRoomPubMsgTellAll withData:@{@"videoRatio":@(mediaFileModel.width/mediaFileModel.height), @"fileId":fileId} save:YES];
        }
    }
}

- (void)sliderYSMp4ControlViewPos:(NSTimeInterval)value withFileModel:(CHSharedMediaFileModel *)mediaFileModel
{
    isDrag = YES;
    [self.liveManager seekSharedMediaFile:mediaFileModel.fileUrl positionByMS:value];
}

/// 显示白板视频标注
- (void)handleSignalingShowVideoWhiteboardWithData:(NSDictionary *)data
{
    if (![self.liveManager.whiteBoardManager isOneWhiteBoardView])
    {
        return;
    }
//    if (self.shareVideoFloatView.hidden)
//    {
//        return;
//    }
    
    if (self.mediaMarkView.superview)
    {
        [self.mediaMarkView removeFromSuperview];
    }
    
    NSString *fileId = [data bm_stringForKey:@"fileId"];
    CGFloat videoRatio = [data bm_doubleForKey:@"videoRatio"];
    
    self.mediaMarkView = [[CHWBMediaMarkView alloc] initWithFrame:self.shareVideoFloatView.bounds fileId:fileId];
    [self.shareVideoFloatView addSubview:self.mediaMarkView];
    
    [self.mediaMarkView freshViewWithSavedSharpsData:self.mediaMarkSharpsDatas videoRatio:videoRatio];
    [self.mediaMarkSharpsDatas removeAllObjects];
}

/// 绘制白板视频标注
- (void)handleSignalingDrawVideoWhiteboardWithData:(NSDictionary *)data
{
    if (![self.liveManager.whiteBoardManager isOneWhiteBoardView])
    {
        return;
    }
    
//    BOOL isHistory = [data bm_boolForKey:@"isHistory"];
//
//    if (isHistory)
//    {
//        [self.mediaMarkSharpsDatas addObject:data];
//    }
//    else
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
        self.mediaMarkView = nil;
    }
}
#pragma mark -刷新课件库数据
- (void)freshTeacherCoursewareListData
{
    if ([self.spreadBottomToolBar coursewareListIsShow])
    {
        [self.teacherListView setDataSource:self.liveManager.fileList withType:SCBottomToolBarTypeCourseware userNum:self.liveManager.fileList.count currentFileList:self.currentFileList mediaFileID:self.mediaFileModel.fileId mediaState:self.mediaFileModel.state];
    }
}

//- (void)onRoomStopLocalMediaFile:(NSString *)mediaFileUrl
//{
//    NSBundle *bundle = [NSBundle bundleWithPath: [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"YSResources.bundle"]];
//    NSString *filePath = [[bundle resourcePath] stringByAppendingPathComponent:@"trophy_tones.mp3"];
//    if ([mediaFileUrl isEqualToString:filePath])
//    {
//        giftMp3Playing = NO;
//    }
//}

- (void)onRoomAudioFinished:(NSInteger)soundId
{
    if (YSGiftMp3SoundId == soundId)
    {
        giftMp3Playing = NO;
    }
}

- (void)showGiftAnimationWithVideoView:(CHVideoView *)videoView
{
    if (!videoView)
    {
        return;
    }
    
    NSBundle *bundle = [NSBundle bundleWithPath: [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"YSResources.bundle"]];
    NSString *filePath = [[bundle resourcePath] stringByAppendingPathComponent:@"trophy_tones.mp3"];
    
    if (!giftMp3Playing)
    {
        //giftMp3Playing = [self.liveManager startPlayingMedia:filePath];
        giftMp3Playing = [self.liveManager startAudio:filePath withSoundId:YSGiftMp3SoundId];
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
- (void)panToMoveVideoView:(CHVideoView*)videoView withGestureRecognizer:(nonnull UIPanGestureRecognizer *)pan
{
    [[PanGestureControl shareInfo] removePanGestureAction:LONG_PRESS_VIEW_DEMO];
    
    if (self.roomtype == CHRoomUserType_One || self.roomLayout == CHRoomLayoutType_VideoLayout || self.roomLayout == CHRoomLayoutType_FocusLayout)
    {
//        [[PanGestureControl shareInfo] removePanGestureAction:LONG_PRESS_VIEW_DEMO];
        return;
    }
    UIView * background = self.whitebordBackgroud;
    
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
//         [[PanGestureControl shareInfo] removePanGestureAction:LONG_PRESS_VIEW_DEMO];
        CGFloat percentLeft = 0;
                
        if (!videoView.isDragOut)
        {

            if (self.videoOriginInSuperview.y + endPoint.y < videoView.bm_height * 0.7)
            {
                [self.dragImageView removeFromSuperview];
                self.dragImageView = nil;
                return;
            }

            videoView.bm_width = floatVideoDefaultWidth;
            videoView.bm_height = floatVideoDefaultHeight;
        }
        
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
                percentTop = 0;
            }
            else
            {
                percentTop = (self.videoOriginInSuperview.y+endPoint.y)/(background.bm_height - 2 - videoView.bm_height);
            }
        }
        else
        {
            percentTop = 0;
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
        
        if (percentTop <= 0 && abs((int)videoEndY) > videoView.bm_height * 0.3)
        {
            if (videoView.streamId && videoView.roomUser.peerID)
            {
                NSDictionary * data = @{
                    @"isDrag":@0,
                    @"streamId":videoView.streamId,
                    @"userId":videoView.roomUser.peerID,
                };
                
                BOOL result = [self.liveManager sendSignalingTopinchVideoViewWithPeerId:videoView.roomUser.peerID withStreamId:videoView.streamId withData:data];
                
                if (result)
                {
                    [self hideDragOutVideoViewWithStreamId:videoView.streamId];
                }
            }
            
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
            
            CGFloat endScale = floatV.endScale;
            if (endScale == 0)
            {
                endScale = 2;
            }
            if (videoView.streamId && videoView.roomUser.peerID)
            {
                NSDictionary * data = @{
                    @"isDrag":@1,
                    @"percentLeft":[NSString stringWithFormat:@"%f",percentLeft],
                    @"percentTop":[NSString stringWithFormat:@"%f",percentTop],
                    @"userId":videoView.roomUser.peerID,
                    @"streamId":videoView.streamId,
                    @"scale":@(endScale)
                };
                BOOL result = [self.liveManager sendSignalingTopinchVideoViewWithPeerId:videoView.roomUser.peerID withStreamId:videoView.streamId withData:data];
                if (result)
                {
                    [self showDragOutFullTeacherVideoViewWithPeerId:videoView videoX:videoEndX videoY:videoEndY];
                }
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
- (void)showDragOutFullTeacherVideoViewWithPeerId:(CHVideoView *)videoView videoX:(CGFloat)videoX videoY:(CGFloat)videoY
{
    if (self.roomLayout == CHRoomLayoutType_VideoLayout)
    {
        return;
    }

    BOOL dragOut = NO;
    CGFloat whitebordH = 0;

    dragOut = videoView.isDragOut;
    whitebordH = self.whitebordBackgroud.bm_height;

    if (dragOut)
    {
        YSFloatView *floatView = (YSFloatView *)(videoView.superview.superview);
        floatView.sourceId = videoView.sourceId;
        floatView.streamId = videoView.streamId;
        floatView.frame = CGRectMake(videoX, videoY, videoView.bm_width, videoView.bm_height);
        [floatView bm_bringToFront];
        
        return;
    }
    else
    {
        videoView.isDragOut = YES;
        [self freshContentVideoView];
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
        //floatView.maxSize = self.whitebordBackgroud.bm_size;
        floatView.maxSize = CGSizeMake(self.whitebordBackgroud.bm_size.width*0.95f, self.whitebordBackgroud.bm_size.height*0.95f);
        floatView.peerId = videoView.roomUser.peerID;
        floatView.sourceId = videoView.sourceId;
        floatView.streamId = videoView.streamId;
    }
}
#endif

#pragma mark 拖出/放回视频窗口
- (void)handleSignalingDragOutAndChangeSizeVideoWithPeerId:(NSString *)peerId withSourceId:(NSString *)sourceId withStreamId:(NSString *)streamId WithData:(NSDictionary *)data fromId:(NSString *)fromId
{
    BOOL isDragOut = [data bm_boolForKey:@"isDrag"];
        
    if (isDragOut)
    {
        [self showDragOutVideoViewWithData:data];
    }
    else
    {
        if (![fromId isEqualToString:YSCurrentUser.peerID])
        {
            [self hideDragOutVideoViewWithStreamId:peerId];
        }
    }
}

// 拖出视频
- (void)showDragOutVideoViewWithData:(NSDictionary *)data
{
    if (self.roomLayout == CHRoomLayoutType_VideoLayout)
    {
        return;
    }
    
    NSString *streamId = [data bm_stringForKey:@"streamId"];
    NSString *sourceId = [self.liveManager getSourceIdFromStreamId:streamId];

    NSString *peerId = [data bm_stringForKey:@"userId"];
    
    CGFloat percentLeft = [data bm_floatForKey:@"percentLeft"];
    
    CGFloat percentTop = [data bm_floatForKey:@"percentTop"];
    
    CGFloat endScale = [data bm_floatForKey:@"scale"];
        
    CHVideoView *videoView = [self getVideoViewWithPeerId:peerId andSourceId:sourceId];
    
    if (videoView.isDragOut)
    {
        YSFloatView *floatView = (YSFloatView *)(videoView.superview.superview);
        CGSize floatViewSize = [self dragOutVideoChangeSizeWithFloatView:floatView withScale:endScale];
        
        CGFloat x = percentLeft * (self.whitebordBackgroud.bm_width - floatViewSize.width);
        CGFloat y = percentTop * (self.whitebordBackgroud.bm_height - floatViewSize.height);
        
        floatView.frame = CGRectMake(x, y, floatViewSize.width, floatViewSize.height);
        [floatView bm_bringToFront];
        return;
    }
    else
    {
        videoView.isDragOut = YES;//必须刷新前赋值
        
        [self freshContentVideoView];
        
        CGFloat x = percentLeft * (self.whitebordBackgroud.bm_width - floatVideoMinWidth * endScale);
        CGFloat y = percentTop * (self.whitebordBackgroud.bm_height - floatVideoMinHeight * endScale);
        
        YSFloatView *floatView = [[YSFloatView alloc] initWithFrame:CGRectMake(x, y, floatVideoMinWidth * endScale, floatVideoMinHeight * endScale)];
        floatView.peerId = peerId;
        floatView.sourceId = videoView.sourceId;
        floatView.streamId = videoView.streamId;
        // 暂时不支持本地拖动缩放
        [self.dragOutFloatViewArray addObject:floatView];
        [self.whitebordBackgroud addSubview:floatView];
        floatView.minSize = CGSizeMake(floatVideoMinWidth, floatVideoMinHeight);
        //floatView.maxSize = self.whitebordBackgroud.bm_size;
        floatView.maxSize = CGSizeMake(self.whitebordBackgroud.bm_size.width*0.95f, self.whitebordBackgroud.bm_size.height*0.95f);
        floatView.canGestureRecognizer = YES;

        [floatView showWithContentView:videoView];
        [floatView bm_bringToFront];
    }
}

/// 拖出视频窗口拉伸 根据本地默认尺寸scale
- (CGSize )dragOutVideoChangeSizeWithFloatView:(YSFloatView *)floatView withScale:(CGFloat)scale
{
    if (scale == 1)
    {
        return CGSizeMake(floatVideoMinWidth, floatVideoMinHeight);
    }
    else if (scale == 2)
    {
        return CGSizeMake(floatVideoDefaultWidth, floatVideoDefaultHeight);
    }
    
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
    floatVideoDefaultHeight = self.whitebordBackgroud.bm_height / 3.0f;
    /// 悬浮默认视频宽(拖出和共享)
    floatVideoDefaultWidth = floatVideoDefaultHeight * scale;
    
    floatVideoMinHeight = self.whiteBordView.bm_height / 6.0f;
    floatVideoMinWidth = floatVideoMinHeight * scale;
}

// 放回视频
- (void)hideDragOutVideoViewWithStreamId:(NSString *)streamId
{
    if (self.roomLayout == CHRoomLayoutType_VideoLayout)
    {
        return;
    }
    
    BOOL needFresh = NO;
    for (YSFloatView *floatView in self.dragOutFloatViewArray )
    {
        CHVideoView *videoView = (CHVideoView *)floatView.contentView;
        if ([videoView.streamId isEqualToString:streamId] )
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
        [self freshContentVideoView];
    }
}

#pragma mark  获取拖出的浮动窗口
- (YSFloatView *)getVideoFloatViewWithPeerId:(NSString *)peerId
{
    for (YSFloatView *floatView in self.dragOutFloatViewArray)
    {
        CHVideoView *videoView = (CHVideoView *)floatView.contentView;
        if ([videoView.roomUser.peerID isEqualToString:peerId])
        {
            return floatView;
        }
    }
    return nil;
}

- (void)hideAllDragOutVideoView
{
    for (YSFloatView *floatView in self.dragOutFloatViewArray )
    {
        CHVideoView *videoView = (CHVideoView *)floatView.contentView;
        
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
    NSArray *colorArray = [CHWhiteBoardManager colorSelectArray];
    NSString *newColorStr;
    if (self.roomtype == CHRoomUserType_One)
    {
        newColorStr = @"#FF0000";
    }
    else
    {
        NSUInteger index = arc4random() % colorArray.count;
        newColorStr = colorArray[index];
    }
    
    NSString *colorStr = [self.liveManager.whiteBoardManager.cloudHubWhiteBoardKit.cloudHubWhiteBoardConfig.canvasColor bm_hexStringWithStartChar:@"#"];
    if ([newColorStr isEqualToString:colorStr])
    {
        newColorStr = @"#FF0000";
    }
    
    [self.liveManager setPropertyOfUid:YSCurrentUser.peerID tell:CHRoomPubMsgTellAll propertyKey:sCHUserPrimaryColor value:newColorStr];

    [self.liveManager.whiteBoardManager changeDefaultPrimaryColor:newColorStr];
}

#pragma mark 共享桌面

/// 开始桌面共享 服务端控制与课件视频/音频互斥
- (void)onRoomStartShareDesktopWithUserId:(NSString *)userId sourceID:(NSString *)sourceId streamId:(NSString *)streamId
{
    [self.view endEditing:YES];
    _isMp4Play = NO;
    
//    CloudHubMediaType mediaType = [self.liveManager getMediaTypeByUserId:userId andSourceID:sourceId];
    
    [self.liveManager playVideoWithUserId:userId streamID:streamId renderMode:CloudHubVideoRenderModeFit mirrorMode:CloudHubVideoMirrorModeDisabled inView:self.shareVideoView];
    [self.shareVideoFloatView showMp4WaitingView];

    [self arrangeAllViewInVCView];
    self.shareVideoFloatView.canZoom = YES;
    self.shareVideoFloatView.showWaiting = NO;
    self.shareVideoFloatView.hidden = NO;
    
    [self fullScreenToShowVideoView:YES];
}

/// 停止桌面共享
- (void)onRoomStopShareDesktopWithUserId:(NSString *)userId sourceID:(NSString *)sourceId streamId:(NSString *)streamId
{
    _isMp4Play = NO;
    [self.liveManager stopVideoWithUserId:userId streamID:streamId];
    
    self.shareVideoFloatView.canZoom = NO;
    self.shareVideoFloatView.backScrollView.zoomScale = 1.0;
    self.shareVideoFloatView.hidden = YES;

    [self fullScreenToShowVideoView:NO];
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
- (void)showWhiteBordVideoViewWithMediaModel:(CHSharedMediaFileModel *)mediaModel
{
    _isMp4Play = YES;
    [self.view endEditing:YES];
    self.mp4ControlView.hidden = NO;
    self.mp4ControlView.mediaFileModel = mediaModel;
    self.closeMp4Btn.hidden = NO;
        
    [self.liveManager playVideoWithUserId:mediaModel.senderId streamID:mediaModel.streamId renderMode:CloudHubVideoRenderModeFit mirrorMode:CloudHubVideoMirrorModeDisabled inView:self.shareVideoView];
    if (mediaModel.pause)
    {
        [self.shareVideoFloatView showMp4PauseView];
    }
    else
    {
        [self.shareVideoFloatView showMp4WaitingView];
    }

    //[self arrangeAllViewInContentBackgroudViewWithViewType:SCMain_ArrangeContentBackgroudViewType_ShareVideoFloatView index:0];
    
    [self arrangeAllViewInVCView];
    self.shareVideoFloatView.canZoom = NO;
    self.shareVideoFloatView.backScrollView.zoomScale = 1.0;
    self.shareVideoFloatView.showWaiting = YES;
    self.shareVideoFloatView.hidden = NO;
    
    if (self.mediaMarkView)
    {
        [self.mediaMarkView bm_bringToFront];
    }

    [self fullScreenToShowVideoView:YES];
}

// 关闭课件视频
- (void)hideWhiteBordVideoViewWithMediaModel:(CHSharedMediaFileModel *)mediaModel
{
    _isMp4Play = NO;
    if (mediaModel.isVideo)
    {
        [self.liveManager stopVideoWithUserId:mediaModel.senderId streamID:mediaModel.streamId];
        [self.shareVideoFloatView showMp4WaitingView];
    }
    
    if (self.mediaMarkView.superview)
    {
        [self.mediaMarkView removeFromSuperview];
        self.mediaMarkView = nil;
    }
    
    self.shareVideoFloatView.canZoom = NO;
    self.shareVideoFloatView.backScrollView.zoomScale = 1.0;
    self.shareVideoFloatView.hidden = YES;
    self.mp4ControlView.hidden = YES;
    self.closeMp4Btn.hidden = YES;
    
    [self fullScreenToShowVideoView:NO];
    
}

#pragma mark 白板翻页 换课件

/// 媒体课件状态
- (void)handleonWhiteBoardMediaFileStateWithFileId:(NSString *)fileId state:(CHMediaState)state
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

/// 删除课件
- (void)handleonWhiteBoardDeleteFile
{
    [self freshTeacherCoursewareListData];
}

// 课件全屏
- (void)handleonWhiteBoardFullScreen:(BOOL)isAllScreen
{
    if (isAllScreen)
    {
        [self.view endEditing:YES];
                
        [self.whiteBordView removeFromSuperview];
        
        self.whitebordFullBackgroud.hidden = NO;
        // 加载白板
        [self.whitebordFullBackgroud addSubview:self.whiteBordView];
        self.whiteBordView.frame = CGRectMake(0, 0, self.whitebordFullBackgroud.bm_width, self.whitebordFullBackgroud.bm_height );
        [self arrangeAllViewInVCView];
    }
    else
    {
        [self.whiteBordView removeFromSuperview];
        self.whitebordFullBackgroud.hidden = YES;
        
        [self.whitebordBackgroud addSubview:self.whiteBordView];
        self.whiteBordView.frame = self.whitebordBackgroud.bounds;
        
        [self arrangeAllViewInWhiteBordBackgroud];
    }
    
    [self fullScreenToShowVideoView:isAllScreen];
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
            
            [self.teacherListView setDataSource:self.liveManager.fileList withType:SCBottomToolBarTypeCourseware userNum:self.liveManager.fileList.count currentFileList:self.currentFileList mediaFileID:self.mediaFileModel.fileId mediaState:self.mediaFileModel.state];
            
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
//            [self changeLayoutWithMode:isSelected];
            
            [self creatLayoutPopoverView];
            
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
        case SCBottomToolBarTypeVideoAdjustment:
        {
            //视频调整
            [self showKeystoneCorrectionView];
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

- (void)creatLayoutPopoverView
{
    [self.controlPopoverView dismissViewControllerAnimated:NO completion:nil];
    [self.upHandPopTableView dismissViewControllerAnimated:NO completion:nil];

    if (!self.layoutPopoverView)
    {
        self.layoutPopoverView = [[YSDefaultLayoutPopView alloc]init];
        self.layoutPopoverView.modalPresentationStyle = UIModalPresentationPopover;
        self.layoutPopoverView.delegate = self;
        self.layoutPopoverView.roomLayout = self.roomLayout;
        if (self.roomtype == CHRoomUserType_One)
        {
            self.layoutPopoverView.menusArr = @[@"Title.VideoLayout",@"Title.AroundLayout",@"Title.DoubleLayout"];
        }
        else
        {
            self.layoutPopoverView.menusArr = @[@"Title.VideoLayout",@"Title.AroundLayout",@"Title.FocusLayout" ];
        }
    }
    
    UIPopoverPresentationController *popover = self.layoutPopoverView.popoverPresentationController;
    popover.backgroundColor = YSSkinDefineColor(@"Color2");

    popover.sourceView = self.spreadBottomToolBar.switchLayoutBtn;
    popover.sourceRect = self.spreadBottomToolBar.switchLayoutBtn.bounds;
    popover.delegate = self;
    
    [self presentViewController:self.layoutPopoverView animated:NO completion:nil];///present即可

    
        
    popover.permittedArrowDirections =  UIPopoverArrowDirectionDown;
    
}

- (void)layoutCellClick:(NSInteger)rowNum
{
    switch (rowNum) {
            case 0:
                self.roomLayout = CHRoomLayoutType_AroundLayout;
                break;
            case 1:
                self.roomLayout = CHRoomLayoutType_VideoLayout;
            break;
        case 2:{
            if (self.roomtype == CHRoomUserType_One)
            {
                self.roomLayout = CHRoomLayoutType_DoubleLayout;
            }
            else
            {
                self.roomLayout = CHRoomLayoutType_FocusLayout;
            }
            
        }
            break;

            default:
                break;
        }
    
    if (self.roomLayout == CHRoomLayoutType_FocusLayout)
    {
        self.fouceView = self.teacherVideoViewArray.firstObject;
        [self.liveManager sendSignalingToChangeLayoutWithLayoutType:self.roomLayout appUserType:self.appUseTheType withFouceUserId:YSCurrentUser.peerID withStreamId:self.fouceView.streamId];
    }
    else
    {
        [self.liveManager sendSignalingToChangeLayoutWithLayoutType:self.roomLayout appUserType:self.appUseTheType withFouceUserId:nil withStreamId:nil];
    }
    
    [self.layoutPopoverView dismissViewControllerAnimated:NO completion:nil];
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
    for (CHRoomUser * user in self.liveManager.userList)
    {
        if (user.role == CHUserType_Student || user.role == CHUserType_Teacher)
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
        for (CHVideoView *videoView in self.videoSequenceArr)
        {
            NSDictionary * data = @{
                @"isDrag":@0,
                @"streamId":videoView.streamId ? videoView.streamId : @"",
                @"userId":videoView.roomUser.peerID
            };
            BOOL result = [self.liveManager sendSignalingTopinchVideoViewWithPeerId:videoView.roomUser.peerID withStreamId:videoView.streamId withData:data];
            
            if (result)
            {
                [self hideDragOutVideoViewWithStreamId:videoView.streamId];
            }
        }
        
        if (self.isDoubleVideoBig)
        {
            [self.liveManager deleteSignalingToDoubleClickVideoView];
        }
    }
    
    //NO:上下布局  YES:左右布局
    if (self.appUseTheType == CHRoomUseTypeMeeting)
    {
        CHRoomLayoutType roomLayout = CHRoomLayoutType_VideoLayout;
        if (!mode)
        {
            roomLayout = CHRoomLayoutType_AroundLayout;
        }
        [self.liveManager sendSignalingToChangeLayoutWithLayoutType:roomLayout appUserType:CHRoomUseTypeMeeting withFouceUserId:nil withStreamId:nil];
    }
    else
    {
        CHRoomLayoutType roomLayout = CHRoomLayoutType_VideoLayout;
        if (!mode)
        {
            roomLayout = CHRoomLayoutType_AroundLayout;
        }
        [self.liveManager sendSignalingToChangeLayoutWithLayoutType:roomLayout];
    }
}

#pragma mark 切换窗口布局变化
- (void)handleSignalingSetRoomLayout:(CHRoomLayoutType)roomLayout withPeerId:(NSString *)peerId withSourceId:(NSString *)sourceId
{

    //NO:上下布局  YES:左右布局
    self.roomLayout = roomLayout;
    
    self.spreadBottomToolBar.isBeginClass = YES;
    
//    self.spreadBottomToolBar.isAroundLayout = (self.roomLayout == CHRoomLayoutType_AroundLayout);
    
    self.isDoubleType = 0;
    
    if (roomLayout == CHRoomLayoutType_FocusLayout && [peerId bm_isNotEmpty] && [sourceId bm_isNotEmpty])
    {
        for (CHVideoView *videoView in self.videoSequenceArr)
        {
            if ([videoView.roomUser.peerID isEqualToString:peerId] && [videoView.sourceId isEqualToString:sourceId])
            {
                self.fouceView = videoView;
                break;
            }
        }

        if (![self.fouceView bm_isNotEmpty])
        {
//            self.roomLayout = CHRoomLayoutType_VideoLayout;
        }
    }
    else if (roomLayout == CHRoomLayoutType_DoubleLayout)
    {
        self.isDoubleType = 1;
        
        self.roomLayout = CHRoomLayoutType_DoubleLayout;

    }
    
    [self freshContentView];
}

- (void)handleSignalingDefaultRoomLayout
{
    [self handleSignalingSetRoomLayout:defaultRoomLayout withPeerId:nil withSourceId:nil];
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
        case SCToolBoxTypeDice:
        {
            /// 骰子
            [self.liveManager sendSignalingToDiceWithState:0 IRand:0];
            
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
    _isOpenResult = NO;
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
                    
                    NSDictionary *data = [BMCloudHubUtil convertWithData:[dic bm_stringForKey:@"data"]];
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

    [self answerResultViewWithFromeID:fromID answerId:answerId];
}
- (void)answerResultViewWithFromeID:(NSString *)fromeId answerId:(NSString *)answerId
{
    BMWeakSelf
    if (![fromeId isEqualToString:self.liveManager.teacher.peerID])
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
//    allNoAudio = noAudio;
    self.spreadBottomToolBar.isEveryoneNoAudio = noAudio;
}

#pragma mark -
#pragma mark 抢答器 YSTeacherResponderDelegate
- (void)startClickedWithUpPlatform:(BOOL)upPlatform
{
    autoUpPlatform = upPlatform;
    [self.liveManager sendSignalingTeacherToStartResponder];
    contestCommitNumber = 0;
    contestPeerId = @"";
    contestNickName = @"";
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
- (void)handleSignalingShowContestFromID:(NSString *)fromID isHistory:(BOOL)isHistory
{
//    老师/助教发起抢答排序 Contest(pubMsg)，并订阅抢答排序ContestSubsort(pubMsg)
    if (!self.responderView)
    {
//    [self.responderView dismiss:nil animated:NO dismissBlock:nil];
        self.responderView = [[YSTeacherResponder alloc] init];
        [self.responderView showYSTeacherResponderType:YSTeacherResponderType_Start inView:self.view backgroundEdgeInsets:UIEdgeInsetsZero topDistance:0];
        
        self.responderView.delegate = self;
    }
    
//    if ([fromID isEqualToString:self.liveManager.localUser.peerID])
    [self.responderView showResponderWithType:YSTeacherResponderType_ING];
    if(!isHistory)
    {
        [self.liveManager sendSignalingTeacherToContestResponderWithMaxSort:300];
        [self.liveManager sendSignalingTeacherToContestSubsortWithMin:1 max:300];
    }
    else
    {
        [self.responderView showResponderWithType:YSTeacherResponderType_Start];
    }
}

/// 收到抢答排序
- (void)handleSignalingContestFromID:(NSString *)fromID isHistory:(BOOL)isHistory
{
//    [self.responderView dismiss:nil animated:NO dismissBlock:nil];
    BMWeakSelf
    if (!self.responderView)
    {
        self.responderView = [[YSTeacherResponder alloc] init];
        [self.responderView showYSTeacherResponderType:YSTeacherResponderType_ING inView:self.view backgroundEdgeInsets:UIEdgeInsetsZero topDistance:0];
        self.responderView.delegate = self;
    }
    
    /// 订阅抢答排序
//    if ([fromID isEqualToString:self.liveManager.localUser.peerID])
    [self.responderView showResponderWithType:YSTeacherResponderType_ING];
    
    [[BMCountDownManager manager] startCountDownWithIdentifier:YSTeacherResponderCountDownKey timeInterval:10 processBlock:^(id  _Nonnull identifier, NSInteger timeInterval, BOOL reStart, BOOL forcedStop) {
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
            for (CHRoomUser * user in weakSelf.liveManager.userList)
            {
                if (user.role == CHUserType_Student)
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
                [weakSelf showContestResultWithNickName:self->contestNickName peerID:self->contestPeerId];
            }
        }
    }];
}

/// 展示抢答结果 并确定是否自动上台
- (void)showContestResultWithNickName:(NSString *)nickName peerID:(NSString *)peerID
{
    [self.responderView setPersonName:nickName];
    
//    if ([fromID isEqualToString:self.liveManager.teacher.peerID])
    {
        [self.liveManager sendSignalingTeacherToContestResultWithName:nickName];
        if (self.videoSequenceArr.count < self->maxVideoCount)
        {
            if (self->autoUpPlatform)
            {
                BOOL isUpPlatform = NO;
                for (CHVideoView *videoView in self.videoSequenceArr)
                {
                    if ([videoView.roomUser.peerID isEqualToString:peerID])
                    {
                        isUpPlatform = YES;
                    }
                }
                if (!isUpPlatform)
                {
                    NSString *whom = CHRoomPubMsgTellAll;
                    if (self.liveManager.isBigRoom)
                    {
                        whom = peerID;
                    }
                    
                    CHRoomUser *user = [self.liveManager getRoomUserWithId:peerID];
                    [user sendToPublishStateUPTellWhom:whom];
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
- (void)handleSignalingContestCommitWithData:(NSArray *)data isHistory:(BOOL)isHistory
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
        for (CHRoomUser * user in self.liveManager.userList)
        {
            if (user.role == CHUserType_Student)
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
        contestNickName = contestUset[peerID];
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

- (void)handleSignalingDiceWithData:(NSDictionary *)diceData
{
    if ([diceData bm_isNotEmptyDictionary])
    {
        [self.diceView bm_bringToFront];
        NSInteger state = [diceData bm_intForKey:@"state"];
        self.diceView.hidden = NO;
        if (state == 1)
        {
            self.diceView.nickName = [diceData bm_stringForKey:@"nickname"];
            self.diceView.resultNum = [diceData bm_intForKey:@"iRand"];
            [self.diceView diceBegainAnimals];
        }
    }
    else
    {
        self.diceView.hidden = YES;
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
        [[BMCountDownManager manager] startCountDownWithIdentifier:YSTeacherTimerCountDownKey timeInterval:time processBlock:^(id  _Nonnull identifier, NSInteger timeInterval, BOOL reStart, BOOL forcedStop) {
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
        [[BMCountDownManager manager] startCountDownWithIdentifier:YSTeacherTimerCountDownKey timeInterval:time processBlock:^(id  _Nonnull identifier, NSInteger timeInterval, BOOL reStart, BOOL forcedStop) {
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
    [[BMCountDownManager manager] startCountDownWithIdentifier:YSTeacherTimerCountDownKey timeInterval:time processBlock:^(id  _Nonnull identifier, NSInteger timeInterval, BOOL reStart, BOOL forcedStop) {
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
    [[BMCountDownManager manager] startCountDownWithIdentifier:YSTeacherTimerCountDownKey timeInterval:time processBlock:^(id  _Nonnull identifier, NSInteger timeInterval, BOOL reStart, BOOL forcedStop) {
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
    CHRoomUser *roomUser = nil;
    for (NSString *userId in self.pollingUserList)
    {
        roomUser = [self.liveManager getRoomUserWithId:userId];
//        CHVideoView *videoView = [self getVideoViewWithPeerId:userId andSourceId:[roomUser getFirstVideoSourceId]];
        
        if (roomUser && roomUser.publishState == CHUser_PublishState_DOWN)
        {
            break;
        }
        
//        if (videoView)
//        {
//            if (!videoView.isDragOut)
//            {
//                roomUser = videoView.roomUser;
//                break;
//            }
//        }
//        else
//        {
////            roomUser = [self.liveManager getRoomUserWithId:userId];
        //            break;
        //        }
    }
    
    if (!roomUser)
    {
        return;
    }
    
    
    if (self.videoSequenceArr.count < maxVideoCount)
    {
        [self changeUpPlatformRoomUser:roomUser];
    }
    else
    {
        NSString *upPlatformPeerId = @"";
        for (NSString *peerId in self.pollingUpPlatformArr)
        {
            CHRoomUser *upPlatformUser = [self.liveManager getRoomUserWithId:peerId];
            
            NSMutableArray *upPlatformUserVideoArr = [self.videoViewArrayDic bm_mutableArrayForKey:peerId];
            upPlatformPeerId = peerId;
            for (CHVideoView *videoView in upPlatformUserVideoArr)
            {
                if (videoView && videoView.isDragOut)
                {
                    upPlatformPeerId = @"";
                    break;
                }
            }
            
            if ([upPlatformUser bm_isNotEmpty])
            {
                break;
            }
//            CHVideoView *videoView = [self getVideoViewWithPeerId:peerId andSourceId:[upPlatformUser getFirstVideoSourceId]];
//            if (videoView)
//            {
//                if (!(videoView.isDragOut || [videoView.roomUser.peerID isEqualToString: self.liveManager.teacher.peerID]))
//                {
//                    upPlatformPeerId = videoView.roomUser.peerID;
//                    break;
//                }
//            }
        }
        BMLog(@"----------%@~~~~~%@",upPlatformPeerId,roomUser.peerID);

        if ([upPlatformPeerId bm_isNotEmpty])
        {
            [self.liveManager setPropertyOfUid:upPlatformPeerId tell:CHRoomPubMsgTellAll properties:@{sCHUserPublishstate : @(CHUser_PublishState_DOWN),sCHUserCandraw : @(false)}];
            [self changeUpPlatformRoomUser:roomUser];
        }
    }
}

/// 上台学生
- (void)changeUpPlatformRoomUser:(CHRoomUser *)roomUser
{
    NSString *whom = CHRoomPubMsgTellAll;
    if (self.liveManager.isBigRoom)
    {
        whom = roomUser.peerID;
    }
    
    [roomUser sendToPublishStateUPTellWhom:whom];
}

/// 收到轮播
- (void)handleSignalingToStartVideoPollingFromID:(NSString *)fromID
{
    _isPolling = YES;
    self.spreadBottomToolBar.isPolling = YES;
    _pollingFromID = fromID;
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
    self.spreadBottomToolBar.isPolling = NO;
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

- (void)handleMessageWith:(CHChatMessageModel *)message
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
    else if (firstResponder.tag == CHWHITEBOARDKIT_TEXTVIEWTAG)
    {//调用白板键盘
        [UIView animateWithDuration:duration animations:^{
            self.chatToolView.bm_originY = self.emotionListView.bm_originY = BMUI_SCREEN_HEIGHT;
        }];

        CGPoint relativePoint = [firstResponder convertPoint:CGPointZero toView:[UIApplication sharedApplication].keyWindow];
        CGFloat keyboardHeight = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
        CGFloat zoomScale = [self.liveManager.whiteBoardManager currentWhiteBoardZoomScale];
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
- (void)creatControlPopoverView
{
    if (!self.controlPopoverView)
    {
        self.controlPopoverView = [[YSControlPopoverView alloc]init];
        self.controlPopoverView.modalPresentationStyle = UIModalPresentationPopover;
        self.controlPopoverView.delegate = self;
        self.controlPopoverView.appUseTheType = self.appUseTheType;
    }
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
- (void)clickViewToControlWithVideoView:(CHVideoView*)videoView
{
    if (self.controlPopoverView.presentingViewController)
    {
        return;
    }
    
    [self.upHandPopTableView dismissViewControllerAnimated:NO completion:nil];
    [self.layoutPopoverView dismissViewControllerAnimated:NO completion:nil];

    [self creatControlPopoverView];
    
    self.selectControlView = videoView;
    
    self.controlPopoverView.isAllNoAudio = self.liveManager.isEveryoneNoAudio;
    
    CHRoomUser * userModel = videoView.roomUser;

    UIPopoverPresentationController *popover = self.controlPopoverView.popoverPresentationController;
    popover.backgroundColor = YSSkinDefineColor(@"Color2");
    if ( self.videoSequenceArr.count <= 2 || ([self.fouceView.sourceId isEqualToString:videoView.sourceId] && [self.fouceView.roomUser.peerID isEqualToString:videoView.roomUser.peerID]))
    {
        /// 1.视频数小于等于2  2.videoView为焦点视频时
        popover.sourceView = videoView.sourceView;
        popover.sourceRect = videoView.sourceView.bounds;
        if (self.roomLayout == CHRoomLayoutType_AroundLayout)
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

    self.controlPopoverView.roomLayout = self.roomLayout;
    [self presentViewController:self.controlPopoverView animated:NO completion:nil];///present即可
    self.controlPopoverView.isNested = NO;
    if (self.roomtype == CHRoomUserType_One)
    {
        popover.permittedArrowDirections = UIPopoverArrowDirectionRight;
        if (self.roomLayout == CHRoomLayoutType_DoubleLayout && userModel.role != CHUserType_Teacher)
        {
            popover.permittedArrowDirections = UIPopoverArrowDirectionUp;
            self.controlPopoverView.isNested = YES;
        }
    }
    else if (self.roomtype == CHRoomUserType_More)
    {
        popover.permittedArrowDirections = UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown;
    }
    self.controlPopoverView.sourceId = videoView.sourceId;
    self.controlPopoverView.streamId = videoView.streamId;
    self.controlPopoverView.roomtype = self.roomtype;
    self.controlPopoverView.isDragOut = videoView.isDragOut;
    self.controlPopoverView.userModel = userModel;
    self.controlPopoverView.videoMirrorMode = self.liveManager.localVideoMirrorMode;
}

#pragma mark -
#pragma mark YSControlPopoverViewDelegate  视频控制按钮点击事件
- (void)videoViewControlBtnsClick:(BMImageTitleButtonView *)sender videoViewControlType:(CHVideoViewControlType)videoViewControlType withStreamId:(nonnull NSString *)streamId
{
    CHSessionMuteState muteState = CHSessionMuteState_UnMute;
    switch (videoViewControlType) {
        case CHVideoViewControlTypeAudio:
        {//关闭音频
            if (sender.selected)
            {//当前是打开音频状态
                muteState = CHSessionMuteState_Mute;
            }
            [self.selectControlView.roomUser sendToChangeAudioMute:muteState];
            sender.selected = !sender.selected;
        }
            break;
        case CHVideoViewControlTypeVideo:
        {//关闭视频
            if (sender.selected)
            {//当前是打开视频状态
                muteState = CHSessionMuteState_Mute;
            }

            [self.selectControlView.roomUser sendToChangeVideoMute:muteState WithSourceId:[self.liveManager getSourceIdFromStreamId:streamId]];
            sender.selected = !sender.selected;
        }
            break;
        case CHVideoViewControlTypeMirror:
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
        case CHVideoViewControlTypeFouce:
        {//焦点
            if (self.roomLayout == CHRoomLayoutType_VideoLayout)
            {
                self.roomLayout = CHRoomLayoutType_FocusLayout;
                self.fouceView = self.selectControlView;
                [self.liveManager sendSignalingToChangeLayoutWithLayoutType:self.roomLayout appUserType:self.appUseTheType withFouceUserId:self.fouceView.roomUser.peerID withStreamId:self.fouceView.streamId];
            }
            else if (self.roomLayout == CHRoomLayoutType_FocusLayout)
            {
                if ([self.selectControlView.sourceId isEqual:self.fouceView.sourceId] &&  [self.selectControlView.roomUser.peerID isEqual:self.fouceView.roomUser.peerID])
                {
                    self.roomLayout = CHRoomLayoutType_VideoLayout;
                    self.fouceView = nil;
                }
                else
                {
                    self.roomLayout = CHRoomLayoutType_FocusLayout;
                    self.fouceView = self.selectControlView;
                }
                [self.liveManager sendSignalingToChangeLayoutWithLayoutType:self.roomLayout appUserType:self.appUseTheType withFouceUserId:self.fouceView.roomUser.peerID withStreamId:self.fouceView.streamId];
            }
            
            self.controlPopoverView.fouceStreamId = self.fouceView.streamId;
            self.controlPopoverView.foucePeerId = self.fouceView.roomUser.peerID;
            [self.controlPopoverView dismissViewControllerAnimated:YES completion:nil];
        }
            break;
            
        case CHVideoViewControlTypeRestore:
        {//视频复位
            NSDictionary * data = @{
                @"isDrag":@0,
                @"streamId":streamId,
                @"userId":self.selectControlView.roomUser.peerID
            };
            
            BOOL result = [self.liveManager sendSignalingTopinchVideoViewWithPeerId:self.selectControlView.roomUser.peerID withStreamId:streamId withData:data];
            
            if (result)
            {
                [self hideDragOutVideoViewWithStreamId:self.selectControlView.streamId];
            }

            if (self.controlPopoverView.presentingViewController)
            {
                [self.controlPopoverView dismissViewControllerAnimated:YES completion:nil];
            }
        }
            break;
        case CHVideoViewControlTypeAllRestore:
        {
            // 全体复位
            for (CHVideoView *videoView in self.videoSequenceArr)
            {
                NSDictionary * data = @{
                    @"isDrag":@0,
                    @"streamId":videoView.streamId,
                    @"userId":videoView.roomUser.peerID
                };
                BOOL result = [self.liveManager sendSignalingTopinchVideoViewWithPeerId:videoView.roomUser.peerID withStreamId:videoView.streamId withData:data];
                
                if (result)
                {
                    [self hideDragOutVideoViewWithStreamId:videoView.streamId];
                }
            }
        }
            break;
        case CHVideoViewControlTypeAllGiftCup:
        {
            //全体奖杯
            for (CHVideoView *videoView in self.videoSequenceArr)
            {
                CHRoomUser *user = videoView.roomUser;
                
                if (user.role == CHUserType_Student)
                {
                    [self sendGiftWithRreceiveRoomUser:user];
                }
            }
        }
            break;
        case CHVideoViewControlTypeCanDraw:
        {// 画笔权限
            
            BOOL candraw = self.selectControlView.roomUser.canDraw;
            // 兼容安卓bool
            bool bCandraw = true;
            if (candraw)
            {
                bCandraw = false;
            }
            BOOL isSucceed = [self.liveManager setPropertyOfUid:self.selectControlView.roomUser.peerID tell:CHRoomPubMsgTellAll propertyKey:sCHUserCandraw value:@(bCandraw)];
            if (isSucceed)
            {
                sender.selected = !sender.selected;
            }
        }
            break;
        case CHVideoViewControlTypeOnStage:
        {//下台
            [self.liveManager setPropertyOfUid:self.selectControlView.roomUser.peerID tell:CHRoomPubMsgTellAll properties:@{sCHUserPublishstate : @(CHUser_PublishState_DOWN), sCHUserCandraw : @(false)}];
            [self.controlPopoverView dismissViewControllerAnimated:YES completion:nil];
        }
            break;
        case CHVideoViewControlTypeGiftCup:
        {//发奖杯
            [self sendGiftWithRreceiveRoomUser:self.selectControlView.roomUser];
        }
            break;
        default:
            break;
    }
}

/// 给用户发送奖杯
- (void)sendGiftWithRreceiveRoomUser:(CHRoomUser *)roomUser
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
                NSDictionary *responseDic = [BMCloudHubUtil convertWithData:responseObject];
                
                if ([responseDic bm_containsObjectForKey:@"result"])
                {
                    NSInteger result = [responseDic bm_intForKey:@"result"];
                    if (result == 0)
                    {
                        NSUInteger giftnumber = [roomUser.properties bm_uintForKey:sCHUserGiftNumber];
                        [weakSelf.liveManager setPropertyOfUid:roomUser.peerID tell:CHRoomPubMsgTellAll propertyKey:sCHUserGiftNumber value:@(giftnumber+1)];
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
- (void)upPlatformProxyWithRoomUser:(CHRoomUser *)roomUser
{
    BMLog(@"%@",roomUser.nickName);
    if (roomUser.publishState == CHUser_PublishState_DOWN)
    {
        if (self.videoSequenceArr.count < maxVideoCount)
        {
            NSString *whom = CHRoomPubMsgTellAll;
            if (self.liveManager.isBigRoom)
            {
                whom = roomUser.peerID;
                [self.liveManager setPropertyOfUid:roomUser.peerID tell:whom propertyKey:sCHUserPublishstate value:@(CHUser_PublishState_UP)];
            }
            else
            {
                [roomUser sendToPublishStateUPTellWhom:whom];
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
        [self.liveManager setPropertyOfUid:roomUser.peerID tell:CHRoomPubMsgTellAll properties:@{sCHUserPublishstate : @(CHUser_PublishState_DOWN), sCHUserCandraw : @(false)}];
    }
}

//对花名册中的成员禁言
- (void)speakProxyWithRoomUser:(CHRoomUser *)roomUser
{
//    if ([roomUser.properties bm_containsObjectForKey:sUserDisablechat])
//    {
        BOOL disablechat = [roomUser.properties bm_boolForKey:sCHUserDisablechat];
    
        [self.liveManager setPropertyOfUid:roomUser.peerID tell:CHRoomPubMsgTellAll propertyKey:sCHUserDisablechat value:@(!disablechat)];
//    }
}

// 踢出
- (void)outProxyWithRoomUser:(CHRoomUser *)roomUser
{
    [self.controlPopoverView dismissViewControllerAnimated:NO completion:nil];
    [self.upHandPopTableView dismissViewControllerAnimated:NO completion:nil];
    [self.layoutPopoverView dismissViewControllerAnimated:NO completion:nil];
    
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:YSLocalized(@"Permissions.notice") message:YSLocalized(@"Permissions.KickedOutMembers") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confimAc = [UIAlertAction actionWithTitle:YSLocalized(@"Prompt.OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.liveManager evictUser:roomUser.peerID reason:1];

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

/// 删除课件
- (void)deleteCoursewareProxyWithFileModel:(CHFileModel *)fileModel
{
    [self.controlPopoverView dismissViewControllerAnimated:NO completion:nil];
    [self.upHandPopTableView dismissViewControllerAnimated:NO completion:nil];
    [self.layoutPopoverView dismissViewControllerAnimated:NO completion:nil];

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
    
#if YSSDK
    alertVc.sc_Autorotate = ![YSSDKManager sharedInstance].useAppDelegateAllowRotation;
#else
    alertVc.sc_Autorotate = !GetAppDelegate.useAllowRotation;
#endif
    alertVc.sc_OrientationMask = UIInterfaceOrientationMaskLandscape;
    alertVc.sc_Orientation = UIInterfaceOrientationLandscapeRight;

    [self presentViewController:alertVc animated:YES completion:nil];
}

//删除课件
- (void)deleteCoursewareWithFileID:(NSString *)fileid
{
    [self.liveManager.whiteBoardManager.cloudHubWhiteBoardKit deleteFileWithFileId:fileid];
}

/// 课件点击
- (void)selectCoursewareProxyWithFileModel:(CHFileModel *)fileModel
{
    if (![fileModel bm_isNotEmpty])
    {
        return;
    }
    
    [self.liveManager.whiteBoardManager changeCourseWithFileId:fileModel.fileid];
}

/// 收回列表
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

        [self.liveManager getRoomUsersWithRole:@[@(CHUserType_Assistant),@(CHUserType_Student)] startIndex:0 maxNumber:(studentNum + assistantNum) search:searchContent order:@{} callback:^(NSArray<CHRoomUser *> * _Nonnull users, NSError * _Nonnull error) {
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
        [self.liveManager getRoomUsersWithRole:@[@(CHUserType_Assistant),@(CHUserType_Student)] startIndex:0 maxNumber:(studentNum + assistantNum) search:searchContent order:@{} callback:^(NSArray<CHRoomUser *> * _Nonnull users, NSError * _Nonnull error) {
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

#pragma mark - 全屏时视频浮窗代理
- (void)freshFullFloatViewWithPeerId:(NSString *)peerId
{
    if (self.fullFloatVideoView.hidden)
    {
        return;
    }
    
    [self.fullFloatVideoView freshFullFloatViewWithMyVideoArray:self.teacherVideoViewArrayFull allVideoSequenceArray:self.videoSequenceArrFull];
}

#pragma mark - 打开相册选择图片

- (void)openTheImagePickerWithImageUseType:(SCUploadImageUseType)imageUseType
{
    BMTZImagePickerController * imagePickerController = [[BMTZImagePickerController alloc]initWithMaxImagesCount:1 columnNumber:1 delegate:self pushPhotoPickerVc:YES];
    imagePickerController.showPhotoCannotSelectLayer = YES;
    imagePickerController.allowTakeVideo = NO;
    imagePickerController.allowPickingVideo = NO;
    imagePickerController.showSelectedIndex = YES;
    imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
    imagePickerController.sortAscendingByModificationDate = NO;
    
    BMWeakSelf
    [imagePickerController setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        
        [self.liveManager.whiteBoardManager uploadImageWithImage:photos.firstObject addInClass:(imageUseType == SCUploadImageUseType_Document) success:^(NSDictionary * _Nonnull dict) {
            
            if (imageUseType == SCUploadImageUseType_Document)
            {
                
            }
            else
            {
                BOOL isSucceed = [self.liveManager sendMessageWithText:[dict bm_stringTrimForKey:@"swfpath"]  withMessageType:CHChatMessageType_OnlyImage withMemberModel:nil];
                if (!isSucceed)
                {
                    BMProgressHUD *hub = [BMProgressHUD bm_showHUDAddedTo:weakSelf.view animated:YES withDetailText:YSLocalized(@"UploadPhoto.Error")];
                    hub.yOffset = -100;
                    [BMProgressHUD bm_hideHUDForView:weakSelf.view animated:YES delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
                }
            }
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
- (NSMutableArray<CHRoomUser *> *)raiseHandArray
{
    if (!_raiseHandArray) {
        _raiseHandArray = [NSMutableArray array];
    }
    return _raiseHandArray;
}

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
