//
//  YSMainVC.m
//  YSLive
//
//  Created by jiang deng on 2019/10/14.
//  Copyright © 2019 FS. All rights reserved.
//

#import "YSMainVC.h"
#import <objc/message.h>
#import <BMKit/BMScrollPageView.h>

#import "BMAlertView+YSDefaultAlert.h"

#import "YSBarrage.h"

#import "YSLessonView.h"
#import "YSLessonModel.h"

#import "YSChatView.h"
#import "YSCommentPopView.h"
#import "YSChatMemberListVC.h"


#import "YSQuestionView.h"
#import "YSSignedAlertView.h"
#import "YSPrizeAlertView.h"

#import "YSLiveApiRequest.h"

#import "YSFloatView.h"

#import "YSVoteVC.h"

#import "YSMediaMarkView.h"

#import "SCVideoView.h"

#import "SCEyeCareView.h"
#import "SCEyeCareWindow.h"

// 输入框高度
#define ToolHeight (IS_IPHONEXANDP?(kScale_H(56)+39):kScale_H(56))

// 上麦视频间隔
#define VIDEOVIEW_HORIZON_GAP 1
#define VIDEOVIEW_VERTICAL_GAP 1

// 上麦个数
#define PLATFPRM_VIDEO_MAXCOUNT 4

#define PAGESEGMENT_HEIGHT          (44.0f)

@interface YSMainVC ()
<
    SCEyeCareViewDelegate,
    BMScrollPageViewDelegate,
    BMScrollPageViewDataSource,
    UIPopoverPresentationControllerDelegate,
    YSChatToolViewMemberDelegate,
    SCVideoViewDelegate,
    UIGestureRecognizerDelegate
>
{
    /// 上麦视频宽
    CGFloat platformVideoWidth;
    /// 上麦视频高
    CGFloat platformVideoHeight;
    
    //BOOL needFreshVideoView;
}

/// 原keywindow
@property(nonatomic, weak) UIWindow *previousKeyWindow;
/// 护眼提醒
@property (nonatomic, strong) SCEyeCareView *eyeCareView;
/// 护眼提醒window
@property (nonatomic, strong) SCEyeCareWindow *eyeCareWindow;


/// 视频ratio 16:9
@property (nonatomic, assign) BOOL isWideScreen;

/// 固定UserId
@property (nonatomic, strong) NSString *userId;

@property (nonatomic, strong) BMScrollPageSegment *m_SegmentBar;
@property (nonatomic, strong) BMScrollPageView *m_ScrollPageView;

/// 直播视图
/// 整体直播的view容器
@property (nonatomic, strong) UIView *allVideoBgView;
/// 主播的视频view
@property (nonatomic, strong) YSFloatView *liveBgView;
@property (nonatomic, strong) UIView *liveView;
@property (nonatomic, strong) UIImageView *liveImageView;
/// 主播的视频view的高度
@property (nonatomic, assign) CGFloat liveViewHeight;


/// 老师占位图中是否上课的提示
@property (nonatomic, strong) UILabel *teacherPlaceLab ;
/// 学生视频容器
@property (nonatomic, strong) UIView *videoBackgroud;

/// 返回按钮
@property (nonatomic, strong) UIButton *returnBtn;
/// 房间号
//@property (nonatomic, strong) UILabel *roomIDLabel;
@property (nonatomic, strong) UIImageView *playMp3ImageView;

@property (nonatomic, strong) YSFloatView *mp4BgView;
@property (nonatomic, strong) UIView *mp4View;
/// 是否mp4全屏
@property (nonatomic, assign) BOOL isMp4FullScreen;
/// mp4全屏按钮
@property (nonatomic, strong) UIButton *mp4FullScreenBtn;

/// 白板视频标注视图
@property (nonatomic, strong) YSMediaMarkView *mediaMarkView;
@property (nonatomic, strong) NSMutableArray <NSDictionary *> *mediaMarkSharpsDatas;

@property (nonatomic, strong) YSLessonView *lessonView;
@property (nonatomic, strong) NSMutableArray *lessonDataSource;

/// 聊天视图
@property(nonatomic, strong) YSChatView *chaView;
/// 选择消息显示权限的popoverVC
@property(nonatomic, strong) YSCommentPopView *menuVc;
/// 提问视图
@property(nonatomic, strong) YSQuestionView *questionaView;

@property(nonatomic, strong) NSURLSessionDataTask *liveCallRollSigninTask;

/// 签到弹窗
@property(nonatomic, strong) YSSignedAlertView *signedAlert;
/// 没创建聊天页面前接收到的消息列表
@property (nonatomic, strong) NSMutableArray<YSChatMessageModel *>  *messageBeforeList;
/// 没创建提问页面前接收到的提问列表
@property (nonatomic, strong) NSMutableArray *questionBeforeArr;
/// 抽奖弹窗
@property(nonatomic, strong) YSPrizeAlertView *prizeAlert;
/// 全屏按钮
@property (nonatomic, strong) UIButton *fullScreenBtn;
/// 是否全屏
@property (nonatomic, assign) BOOL isFullScreen;
/// 弹幕
@property (nonatomic, strong) YSBarrageManager *barrageManager;
/// 开启弹幕
@property (nonatomic, assign) BOOL barrageStart;
/// 弹幕按钮
@property (nonatomic, strong) UIButton *barrageBtn;
/// 播放界面上的按钮隐藏显示
@property (nonatomic, assign) BOOL buttonHide;
/// 当前房间播放视频Id
@property (nonatomic, strong) NSString *roomVideoPeerID;
/// 是否正在播放视频
@property (nonatomic, assign) BOOL showRoomVideo;

///私聊列表
@property (nonatomic, strong) NSMutableArray<YSRoomUser *>  *memberList;
/// 举手按钮
@property(nonatomic,strong) UIButton *raiseHandsBtn;

/// 举手按钮上的倒计时蒙版
@property(nonatomic,strong)UIImageView *raiseMaskImage;
/// 举手请长按的提示
@property(nonatomic,strong)UILabel *remarkLab;
///举手按下的时间
@property (nonatomic, assign)double downTime;
///举手抬起的时间
@property (nonatomic, assign)double upTime;

/// 控制自己音视频的按钮的蒙版
@property(nonatomic,strong) UIView * controlBackMaskView ;
/// 控制自己音视频的按钮的背景View
@property(nonatomic,strong) UIView * controlBackView;
///音频控制按钮
@property(nonatomic,strong) BMImageTitleButtonView * audioBtn;
///视频控制按钮
@property(nonatomic,strong) BMImageTitleButtonView * videoBtn;

@property (nonatomic, assign) BOOL shareDesktop;

@end

@implementation YSMainVC


#pragma mark -
#pragma mark Setter

- (void)setIsFullScreen:(BOOL)isFullScreen
{
    _isFullScreen = isFullScreen;
    if (isFullScreen)
    {
        [self.barrageBtn setImage:YSSkinElementImage(@"live_lesson_barrage", @"iconNor") forState:UIControlStateNormal];
        self.barrageBtn.hidden = NO;
    }
    else
    {
        self.barrageBtn.hidden = YES;
    }
    [self freshContentView];
}



- (void)setBarrageStart:(BOOL)barrageStart
{
    _barrageStart = barrageStart;
    if (barrageStart)
    {
        [self.barrageBtn setImage:YSSkinElementImage(@"live_lesson_barrage", @"iconNor") forState:UIControlStateNormal];
        [self.barrageManager start];
    }
    else
    {
        [self.barrageBtn setImage:YSSkinElementImage(@"live_lesson_barrage", @"iconSel") forState:UIControlStateNormal];
        [self.barrageManager stop];
    }
}

- (void)setButtonHide:(BOOL)buttonHide
{
    _buttonHide = buttonHide;
    self.returnBtn.hidden = buttonHide;
    self.fullScreenBtn.hidden = buttonHide;
//    self.roomIDLabel.hidden = buttonHide;
    if (self.isFullScreen)
    {
        self.barrageBtn.hidden = buttonHide;
    }
    else
    {
        self.barrageBtn.hidden = YES;
    }
}


#pragma mark -
#pragma mark Lazy

- (NSMutableArray<YSRoomUser *> *)memberList
{
    if (!_memberList)
    {
        self.memberList = [NSMutableArray array];
    }
    return _memberList;
}

- (YSCommentPopView *)menuVc
{
    if (!_menuVc)
    {
        self.menuVc = [[YSCommentPopView alloc]init];
        
        self.menuVc.view.frame = CGRectMake(100, 100, 200, 50);
        self.menuVc.titleArr = @[YSLocalized(@"Alert.AllMessage"),YSLocalized(@"Alert.teacherMessage"),YSLocalized(@"Alert.OwnMessage")];
        BMWeakSelf
        __weak __typeof(&*self.menuVc)weakMenuVc = self.menuVc;
        self.menuVc.popoverCellClick = ^(NSInteger index) {
            switch (index)
            {
                case 0:
                {//显示全部消息
                    weakSelf.chaView.showType = YSMessageShowTypeAll;
                }
                    break;
                case 1:
                {//仅看主播消息
                    weakSelf.chaView.showType = YSMessageShowTypeAnchor;
                }
                    break;
                case 2:
                {//仅看自己消息
                    weakSelf.chaView.showType = YSMessageShowTypeMain;
                }
                    break;
                    
                default:
                    break;
            }
            [weakMenuVc dismissViewControllerAnimated:YES completion:nil];
        };
        
        //        self.menuVc.view.backgroundColor = [UIColor whiteColor];
        self.menuVc.preferredContentSize = CGSizeMake(160, 135);
        self.menuVc.modalPresentationStyle = UIModalPresentationPopover;
    }
    return _menuVc;
}


#pragma mark -
#pragma mark ViewControllerLife

- (instancetype)initWithWideScreen:(BOOL)isWideScreen whiteBordView:(UIView *)whiteBordView userId:(nullable NSString *)userId
{
    self = [super initWithWhiteBordView:whiteBordView];
    if (self)
    {
        self.isWideScreen = isWideScreen;
        self.userId = userId;
        platformVideoWidth = (BMUI_SCREEN_WIDTH - VIDEOVIEW_HORIZON_GAP * 5) / 4;
        if (self.isWideScreen)
        {
            platformVideoHeight = platformVideoWidth * 9 / 16;
            
        }
        else
        {
            platformVideoHeight = platformVideoWidth * 3 / 4;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.isWideScreen)
    {
        self.liveViewHeight = BMUI_SCREEN_WIDTH * 9/16;
    }
    else
    {
        self.liveViewHeight = BMUI_SCREEN_WIDTH * 3/4;
    }
    
    self.isFullScreen = NO;
    self.buttonHide = NO;
    self.bm_CanBackInteractive = NO;
    
    self.lessonDataSource = [[NSMutableArray alloc] initWithCapacity:0];
    self.questionBeforeArr = [NSMutableArray array];
    self.messageBeforeList = [NSMutableArray array];
    
    self.mediaMarkSharpsDatas = [[NSMutableArray alloc] init];
    
    [self creatLessonDetail];
    
    [self setupUI];
    [self setupLiveUI];
    [self makeMp3Animation];
    [self setupMp4UI];
    [self setupBarrage];
    
    [self setupReturnBar];
    
    [self setupVideoBackgroud];
    [self performSelector:@selector(creatbuttonHide) withObject:nil afterDelay:5.0f];
    
    [self.view addSubview:self.raiseHandsBtn];
    
    [self addControlMainVideoAudioView];
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:self.controlBackView])
    {
        return NO;
    }
    else
    {
        return YES;
    }
}
- (void)addControlMainVideoAudioView
{
    UIView * controlBackMaskView = [[UIView alloc]initWithFrame:self.view.bounds];
    controlBackMaskView.backgroundColor = UIColor.clearColor;
    self.controlBackMaskView = controlBackMaskView;
    [self.view addSubview:controlBackMaskView];
    controlBackMaskView.hidden = YES;
    UITapGestureRecognizer *oneTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickToShowControl)];
    oneTap.numberOfTapsRequired = 1;
    [controlBackMaskView addGestureRecognizer:oneTap];
    oneTap.delegate = self;
    
    UIView * controlBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 90, 40)];
    controlBackView.backgroundColor = YSSkinDefineColor(@"PopViewBgColor");
    self.controlBackView = controlBackView;
    [controlBackMaskView addSubview:controlBackView];
    [controlBackView bm_roundedRect:5.0f borderWidth:0 borderColor:nil];

    //音频控制按钮
    self.audioBtn = [self creatButtonWithTitle:YSLocalized(@"Button.OpenAudio") selectTitle:YSLocalized(@"Button.CloseAudio") imageName:@"videoPop_soundButton" selectImageName:@"videoPop_soundButton"];
    self.audioBtn.disabledImage = YSSkinElementImage(@"videoPop_soundButton", @"iconDis");
    self.audioBtn.disabledText = YSLocalized(@"Button.OpenAudio");
    self.audioBtn.tag = 0;
    [controlBackView addSubview:self.audioBtn];
    self.audioBtn.frame = CGRectMake(5, 4, 36, 32);
    
    //视频控制按钮
    self.videoBtn = [self creatButtonWithTitle:YSLocalized(@"Button.OpenVideo") selectTitle:YSLocalized(@"Button.CloseVideo") imageName:@"videoPop_videoButton" selectImageName:@"videoPop_videoButton"];
    UIImage * videoClose = [YSSkinElementImage(@"videoPop_videoButton", @"iconNor") bm_imageWithTintColor:[UIColor bm_colorWithHex:0x888888]];
    self.videoBtn.disabledImage = videoClose;
    self.videoBtn.disabledText = YSLocalized(@"Button.OpenVideo");
    [controlBackView addSubview:self.videoBtn];
    self.videoBtn.tag = 1;
    self.videoBtn.frame = CGRectMake(45, 4, 36, 32);
}

/// 刷新视频控制按钮状态
- (void)updataVideoPopViewState
{
    YSPublishState userPublishState = YSCurrentUser.publishState;
    
    if (userPublishState == YSUser_PublishState_AUDIOONLY || userPublishState == YSUser_PublishState_BOTH)
    {
        self.audioBtn.selected = YES;
    }
    else
    {
        self.audioBtn.selected = NO;
    }
    if (userPublishState == YSUser_PublishState_VIDEOONLY || userPublishState == YSUser_PublishState_BOTH)
    {
        self.videoBtn.selected = YES;
    }
    else
    {
        self.videoBtn.selected = NO;
    }
    
    //没有摄像头、麦克风权限时的显示禁用状态
    if ([self.liveManager.localUser.properties bm_containsObjectForKey:sYSUserVideoFail])
    {
        if (self.liveManager.localUser.afail == YSDeviceFaultNone)
        {
            self.audioBtn.enabled = YES;
        }
        else
        {
            self.audioBtn.enabled = NO;
        }
        if (self.liveManager.localUser.vfail == YSDeviceFaultNone)
        {
            self.videoBtn.enabled = YES;
        }
        else
        {
            self.videoBtn.enabled = NO;
        }
    }
    else
    {
        
        if ([self.liveManager.localUser.properties bm_boolForKey:sYSUserHasAudio])
        {
            self.audioBtn.enabled = YES;
        }
        else
        {
            self.audioBtn.enabled = NO;
        }
        if ([self.liveManager.localUser.properties bm_boolForKey:sYSUserHasVideo])
        {
            self.videoBtn.enabled = YES;
        }
        else
        {
            self.videoBtn.enabled = NO;
        }
    }
}

///创建button
- (BMImageTitleButtonView *)creatButtonWithTitle:(NSString *)title selectTitle:(NSString *)selectTitle imageName:(NSString *)imageName selectImageName:(NSString *)selectImageName
{
    BMImageTitleButtonView * button = [[BMImageTitleButtonView alloc]init];
    [button addTarget:self action:@selector(userBtnsClick:) forControlEvents:UIControlEventTouchUpInside];
    button.textNormalColor = YSSkinDefineColor(@"defaultTitleColor");
    button.textFont = UI_FONT_10;
    button.normalText = title;
    
    if (selectTitle.length)
    {
        button.selectedText = selectTitle;
    }
    button.normalImage = YSSkinElementImage(imageName, @"iconNor");

    if (selectImageName.length)
    {
        button.selectedImage = YSSkinElementImage(imageName, @"iconSel");
    }
    
    return button;
}

- (void)clickToShowControl
{
    self.controlBackMaskView.hidden = YES;
}

- (void)userBtnsClick:(UIButton *)sender
{
    YSUserMediaPublishState userPublishState = self.liveManager.localUser.mediaPublishState;
    switch (sender.tag) {
        case 0:
        {//关闭音频
            if (sender.selected)
            {//当前是打开音频状态
                userPublishState &= ~YSUserMediaPublishState_AUDIOONLY;
            }
            else
            {//当前是关闭音频状态
                userPublishState |= YSUserMediaPublishState_AUDIOONLY;
            }
            self.liveManager.localUser.mediaPublishState = userPublishState;
            sender.selected = !sender.selected;
        }
            break;
        case 1:
        {//关闭视频
            if (sender.selected)
            {//当前是打开视频状态
                userPublishState &= ~YSUserMediaPublishState_VIDEOONLY;
            }
            else
            {//当前是关闭视频状态
                userPublishState |= YSUserMediaPublishState_VIDEOONLY;
            }
            self.liveManager.localUser.mediaPublishState = userPublishState;
            sender.selected = !sender.selected;
        }
            break;
        default:
            break;
    }
}

#pragma mark 点击弹出popoview

- (void)clickViewToControlWithVideoView:(SCVideoView*)videoView
{
    CGRect frame = [self.videoBackgroud convertRect:videoView.frame toView:self.controlBackMaskView];
    
//    self.controlBackView.center = CGPointMake(frame.size.width/2 + frame.origin.x, frame.size.height/2 + frame.origin.y);
    self.controlBackMaskView.hidden = NO;
    [self updataVideoPopViewState];
    [self.view bringSubviewToFront:self.controlBackView];
    
    if (self.isFullScreen)
    {
        self.controlBackView.center = CGPointMake(frame.size.width + 30, frame.size.height/2 + frame.origin.y);
        self.controlBackView.transform = CGAffineTransformMakeRotation(M_PI*0.5);
    }
    else
    {
        self.controlBackView.center = CGPointMake(frame.size.width/2 + frame.origin.x, frame.origin.y - self.controlBackView.bounds.size.height*0.5f);
        self.controlBackView.transform = CGAffineTransformMakeRotation(0);
    }
}

///是否打开上麦功能的通知方法
//- (void)allowEveryoneUpPlatformChange
//{
//    BOOL allowUpPlatform = [YSLiveManager shareInstance].allowEveryoneUpPlatform;
//
//    self.upPlatformBtn.hidden = !allowUpPlatform;
//    if (!allowUpPlatform)
//    {
//        self.upPlatformBtn.enabled = YES;
//    }
//}

///是否打开上麦功能
//- (void)handleSignalingAllowEveryoneUpPlatformWithIsAllow:(BOOL)isAllow
//{
//      self.upPlatformBtn.hidden = !isAllow;
//       if (!isAllow)
//       {
//           self.upPlatformBtn.enabled = YES;
//       }
//}


///是否同意上麦申请
//- (void)handleSignalingAllowUpPlatformApplyWithData:(NSDictionary *)data
//{
//    BOOL isAllow = [data bm_boolForKey:@"isAllow"];
//        NSString * userId = [data bm_stringForKey:@"id"];
//    //    NSString * userName = [dict bm_stringForKey:@"name"];
//
//        self.upPlatformBtn.enabled = YES;
//
//        if ([userId isEqualToString:self.liveManager.localUser.peerID]) {
//            if (isAllow)
//            {//同意
//                self.upPlatformBtn.hidden = YES;
//            }
//            [self.liveManager answerSignalingUpPlatformWithCompletion:nil];
//        }
//}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.view endEditing:YES];
}

- (void)backAction:(id)sender
{
    if (self.isFullScreen)
    {
        //[[UIApplication sharedApplication] setStatusBarHidden:NO];
        // 如果是全屏，点击按钮进入小屏状态
        [self changeTopVideoToOriginalFrame];
        self.barrageStart = NO;
    }
    else
    {
        BMWeakSelf
        [BMAlertView ys_showAlertWithTitle:YSLocalized(@"Prompt.Quite") message:nil cancelTitle:YSLocalized(@"Prompt.Cancel") otherTitle:YSLocalized(@"Prompt.OK") completion:^(BOOL cancelled, NSInteger buttonIndex) {
            // 关闭页面
            if (buttonIndex == 1)
            {
                [weakSelf.liveManager leaveRoom:nil];
            }
        }];
    }
}

- (void)dealloc
{
    [_liveCallRollSigninTask cancel];
    _liveCallRollSigninTask = nil;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(creatbuttonHide) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideMp4FullScreenBtn) object:nil];
}

- (void)showEyeCareRemind
{
    if (self.eyeCareWindow)
    {
        return;
    }
    
    NSLog(@"直播课护眼模式提醒");
    
    self.previousKeyWindow = [UIApplication sharedApplication].keyWindow;
    
    CGRect frame = CGRectMake(0, 0, BMUI_SCREEN_WIDTH, BMUI_SCREEN_HEIGHT);
    SCEyeCareWindow *eyeCareWindow = [[SCEyeCareWindow alloc] initWithFrame:frame];
    self.eyeCareWindow = eyeCareWindow;
    [self.eyeCareWindow makeKeyWindow];
    self.eyeCareWindow.hidden = NO;
    
    SCEyeCareView *eyeCareView = [[SCEyeCareView alloc] initWithFrame:frame needRotation:NO];
    eyeCareView.delegate = self;
    [eyeCareWindow addSubview:eyeCareView];
    [eyeCareView bm_centerInSuperView];
}

#pragma mark SCEyeCareViewDelegate

- (void)eyeCareViewClose
{
    [self.eyeCareWindow bm_removeAllSubviews];
    self.eyeCareWindow.hidden = YES;
    self.eyeCareWindow = nil;
    
    [self.previousKeyWindow makeKeyWindow];
}


#pragma mark -
#pragma mark UI

- (BOOL)prefersStatusBarHidden
{
    if (self.isFullScreen)
    {
        return YES;
    }
    
    return NO;
}


//#pragma mark 横竖屏

//1.决定当前界面是否开启自动转屏，如果返回NO，后面两个方法也不会被调用，只是会支持默认的方向
- (BOOL)shouldAutorotate
{
    return NO;
}

//2.返回支持的旋转方向
//iPad设备上，默认返回值UIInterfaceOrientationMaskAllButUpSideDwon
//iPad设备上，默认返回值是UIInterfaceOrientationMaskAll
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

//3.返回进入界面默认显示方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

//设置隐藏动画
- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationNone;
}

- (void)setupUI
{
    // 切换视图
    self.m_SegmentBar = [[BMScrollPageSegment alloc] initWithFrame:CGRectMake(0, self.liveViewHeight, BMUI_SCREEN_WIDTH, PAGESEGMENT_HEIGHT)];
    [self.view addSubview:_m_SegmentBar];
    self.m_SegmentBar.backgroundColor = YSSkinDefineColor(@"defaultTitleColor");
    self.m_SegmentBar.showMore = NO;
    self.m_SegmentBar.equalDivide = YES;
    self.m_SegmentBar.moveLineColor = YSSkinDefineColor(@"defaultSelectedBgColor");
    self.m_SegmentBar.showBottomLine = NO;
    self.m_SegmentBar.titleColor = YSSkinDefineColor(@"login_placeholderColor");
    self.m_SegmentBar.titleSelectedColor = YSSkinDefineColor(@"defaultSelectedBgColor");
    self.m_SegmentBar.showGapLine = NO;
    // 内容视图
    self.m_ScrollPageView = [[BMScrollPageView alloc] initWithFrame:CGRectMake(0, self.liveViewHeight + PAGESEGMENT_HEIGHT, BMUI_SCREEN_WIDTH, BMUI_SCREEN_HEIGHT - self.liveViewHeight - PAGESEGMENT_HEIGHT) withScrollPageSegment:self.m_SegmentBar];
    [self.view addSubview:self.m_ScrollPageView];
    self.m_ScrollPageView.datasource = self;
    self.m_ScrollPageView.delegate = self;
    
    [self.m_ScrollPageView reloadPages];
    [self.m_ScrollPageView scrollPageWithIndex:0];
    
    if (self.navigationController.interactivePopGestureRecognizer)
    {
        [self.m_ScrollPageView.scrollView.panGestureRecognizer requireGestureRecognizerToFail:self.navigationController.interactivePopGestureRecognizer];
    }
}

/// 设置返回按钮以及 房间ID
- (void)setupReturnBar
{
    self.returnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.returnBtn setImage:YSSkinElementImage(@"live_lesson_return", @"iconNor") forState:UIControlStateNormal];
    self.returnBtn.frame = CGRectMake(10, BMUI_STATUS_BAR_HEIGHT, 40, 40);
    [self.view addSubview:self.returnBtn];
    [self.view bringSubviewToFront:self.returnBtn];
    [self.returnBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    self.returnBtn.bm_ActionEdgeInsets = UIEdgeInsetsMake(-5, -5, -5, -5);
    
//    self.roomIDLabel = [[UILabel alloc] init];
//    self.roomIDLabel.font = [UIFont systemFontOfSize:12];
//    self.roomIDLabel.textColor = YSSkinDefineColor(@"defaultTitleColor");
//
//    [self.view addSubview:self.roomIDLabel];
//    [self.view bringSubviewToFront:self.roomIDLabel];
//    self.roomIDLabel.text = [NSString stringWithFormat:@"%@: %@",YSLocalized(@"Label.roomid"),self.liveManager.room_Id];
//    self.roomIDLabel.frame = CGRectMake(CGRectGetMaxX(self.returnBtn.frame) + 7, BMUI_STATUS_BAR_HEIGHT, BMUI_SCREEN_WIDTH * 0.5, 26);
//    self.roomIDLabel.adjustsFontSizeToFitWidth = YES;
//    self.roomIDLabel.minimumScaleFactor = 0.5f;
//    self.roomIDLabel.bm_centerY = self.returnBtn.bm_centerY;
//    /// 隐藏房间号
//    self.roomIDLabel.hidden = YES;
}

- (void)setupLiveUI
{
    self.allVideoBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BMUI_SCREEN_WIDTH, self.liveViewHeight)];
    self.allVideoBgView.backgroundColor = YSSkinDefineColor(@"defaultBgColor");
    [self.view addSubview:self.allVideoBgView];
    
    self.liveBgView = [[YSFloatView alloc] initWithFrame:CGRectMake(0, 0, BMUI_SCREEN_WIDTH, self.liveViewHeight)];
    self.liveBgView.backgroundColor = YSSkinDefineColor(@"defaultBgColor");
    self.liveBgView.showWaiting = NO;
    self.liveBgView.bm_centerX = self.allVideoBgView.bm_centerX;
    [self.allVideoBgView addSubview:self.liveBgView];
    
    self.liveView = [[UIView alloc] initWithFrame:self.liveBgView.bounds];
    self.liveView.backgroundColor = [UIColor clearColor];
    //self.liveBgView.canZoom = YES;
    [self.liveBgView showWithContentView:self.liveView];
    
    self.liveImageView  = [[UIImageView alloc] initWithFrame:self.liveBgView.bounds];
    self.liveImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.liveImageView.contentMode = UIViewContentModeCenter;
    self.liveImageView.backgroundColor = YSSkinDefineColor(@"noVideoMaskBgColor");
    self.liveImageView.image = YSSkinDefineImage(@"live_main_notclassbeging");
    [self.liveBgView.backScrollView addSubview:self.liveImageView];
    
    NSString * text = YSLocalized(@"Label.AnchorState");
    CGSize labSize = [text bm_sizeToFitWidth:self.liveBgView.bm_width withFont:UI_FONT_12];
    UILabel *placeLab = [[UILabel alloc]initWithFrame:CGRectMake((self.liveBgView.bm_width-labSize.width)/2, self.liveBgView.bm_height-50, labSize.width+20, 15)];
    placeLab.text = text;
    placeLab.textAlignment = NSTextAlignmentCenter;
    placeLab.backgroundColor = YSSkinDefineColor(@"jurisdictionCheckFail");
    placeLab.textColor = UIColor.whiteColor;
    placeLab.layer.cornerRadius = 15/2;
    placeLab.layer.masksToBounds = YES;
    placeLab.font = UI_FONT_12;
    placeLab.numberOfLines = 1;
    placeLab.hidden = YES;
    [self.liveImageView addSubview:placeLab];
    self.teacherPlaceLab = placeLab;
    [self.teacherPlaceLab bm_centerHorizontallyInSuperViewWithTop:self.liveImageView.bm_height-50];
    
    self.allVideoBgView.userInteractionEnabled = YES;
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(liveViewClicked:)];
    [self.allVideoBgView addGestureRecognizer:tapGesture];
    
    self.fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:self.fullScreenBtn];
    [self.view bringSubviewToFront:self.fullScreenBtn];
    [self.fullScreenBtn setImage:YSSkinElementImage(@"live_lesson_full", @"iconNor") forState:UIControlStateNormal];
    self.fullScreenBtn.frame = CGRectMake(BMUI_SCREEN_WIDTH - 15 - 40, BMUI_STATUS_BAR_HEIGHT, 40, 40);
    [self.fullScreenBtn addTarget:self action:@selector(fullScreenBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.barrageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:self.barrageBtn];
    [self.view bringSubviewToFront:self.barrageBtn];
    [self.barrageBtn setImage:YSSkinElementImage(@"live_lesson_barrage", @"iconNor") forState:UIControlStateNormal];
    self.barrageBtn.frame = CGRectZero;
    [self.barrageBtn addTarget:self action:@selector(barrageBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    //上麦按钮
    //    self.upPlatformBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [self.view addSubview:self.upPlatformBtn];
    //    [self.view bringSubviewToFront:self.upPlatformBtn];
    //
    //    // iOS 获取设备当前语言和地区的代码
    //    NSString *currentLanguageRegion = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] firstObject];
    //
    //    if([currentLanguageRegion bm_containString:@"zh-Hant"] || [currentLanguageRegion bm_containString:@"zh-Hans"])
    //    {
    //
    //        [self.upPlatformBtn setImage:[UIImage imageNamed:@"applyUpPlatfrom"] forState:UIControlStateNormal];
    //        [self.upPlatformBtn setImage:[UIImage imageNamed:@"waitUpPlatfrom"] forState:UIControlStateDisabled];
    //    }
    //    else
    //    {
    //        [self.upPlatformBtn setImage:[UIImage imageNamed:@"applyUpPlatfrom_EN"] forState:UIControlStateNormal];
    //        [self.upPlatformBtn setImage:[UIImage imageNamed:@"waitUpPlatfrom_EN"] forState:UIControlStateDisabled];
    //    }
    //    self.upPlatformBtn.frame = CGRectMake(BMUI_SCREEN_WIDTH - 12 - 50, self.fullScreenBtn.bm_bottom+15, 50, 50);
    //    [self.upPlatformBtn addTarget:self action:@selector(upPlatformBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    //    self.upPlatformBtn.layer.cornerRadius = 10;
    //    self.upPlatformBtn.hidden = YES;
}

- (void)setupVideoBackgroud
{
    // 视频背景
    self.videoBackgroud = [[UIView alloc] init];
    self.videoBackgroud.backgroundColor = [UIColor clearColor];//[UIColor bm_colorWithHex:0x5A8CDC];
    [self.allVideoBgView addSubview:self.videoBackgroud];
    self.videoBackgroud.frame = CGRectMake(0, self.liveViewHeight - platformVideoHeight - VIDEOVIEW_HORIZON_GAP , BMUI_SCREEN_WIDTH, platformVideoHeight);
    //    self.videoBackgroud.bm_bottom = self.liveBgView.bm_bottom - 2;
}

///连麦按钮点击事件
//- (void)upPlatformBtnClicked:(UIButton *)sender
//{
//    sender.enabled = NO;
//    [[YSLiveManager shareInstance] sendSignalingUpPlatformWithCompletion:nil];
//}

- (void)makeMp3Animation
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, self.liveBgView.bm_bottom - 70, 55, 55)];
    
    NSMutableArray *imageArray = [[NSMutableArray alloc] init];
    for (NSUInteger i=1; i<=50; i++)
    {
        NSString *imageName = [NSString stringWithFormat:@"main_playmp3_%02lu", (unsigned long)i];
        [imageArray addObject:imageName];
    }
    
    [imageView bm_animationWithImageArray:imageArray duration:2 repeatCount:0];
    
    imageView.hidden = YES;
    self.playMp3ImageView = imageView;
    [self.view addSubview:self.playMp3ImageView];
}

- (void)setupMp4UI
{
    /// 是否mp4全屏
    self.isMp4FullScreen = NO;
    
    self.mp4BgView = [[YSFloatView alloc] initWithFrame:CGRectMake(0, self.view.bm_height-self.m_ScrollPageView.bm_height, BMUI_SCREEN_WIDTH, self.m_ScrollPageView.bm_height)];
    self.mp4BgView.backgroundColor = [UIColor blackColor];
    self.mp4BgView.showWaiting = YES;
    //[self.view addSubview:self.mp4BgView];
    [self.m_ScrollPageView.scrollView addSubview:self.mp4BgView];
    self.mp4BgView.frame = self.m_ScrollPageView.bounds;
    
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mp4ViewClicked:)];
    [self.mp4BgView addGestureRecognizer:tapGesture];
    
    self.mp4View = [[UIView alloc] initWithFrame:self.mp4BgView.bounds];
    self.mp4View.backgroundColor = [UIColor clearColor];
    [self.mp4BgView showWithContentView:self.mp4View];
    
    self.mp4BgView.hidden = YES;
    
    self.mp4FullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.mp4BgView addSubview:self.mp4FullScreenBtn];
    [self.mp4BgView bringSubviewToFront:self.mp4FullScreenBtn];
    [self.mp4FullScreenBtn setBackgroundImage:YSSkinElementImage(@"live_mp4_full", @"iconNor") forState:UIControlStateNormal];
    [self.mp4FullScreenBtn setBackgroundImage:YSSkinElementImage(@"live_mp4_full", @"iconSel") forState:UIControlStateSelected];
    //self.mp4FullScreenBtn.frame = CGRectMake(UI_SCREEN_WIDTH - 15 - 40, UI_STATUS_BAR_HEIGHT, 40, 40);
    self.mp4FullScreenBtn.frame = CGRectMake(BMUI_SCREEN_WIDTH - 15 - 40, self.mp4BgView.bm_height - 15 - 40, 40, 40);
    [self.mp4FullScreenBtn addTarget:self action:@selector(mp4FullScreenBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupBarrage
{
    self.barrageManager = [[YSBarrageManager alloc] init];
    [self.liveBgView.backScrollView addSubview:self.barrageManager.renderView];
    //self.barrageManager.renderView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.barrageManager.renderView.userInteractionEnabled = YES;
    //UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(liveViewClicked:)];
    //[self.barrageManager.renderView addGestureRecognizer:tapGesture];
}


#pragma mark -
#pragma mark UIFunc

- (void)creatLessonDetail
{
    YSLessonModel * model = [[YSLessonModel alloc] init];
    model.roomId = self.liveManager.room_Id;
    model.name = self.liveManager.room_Name;
    [self.lessonDataSource addObject:model];
}

- (void)freshMediaView
{
    if (self.liveManager.isClassBegin)
    {
        if (self.shareDesktop)
        {
            self.liveImageView.hidden = YES;
        }
        else if (self.showRoomVideo)
        {
            self.liveImageView.hidden = YES;
        }
        else
        {
            self.liveImageView.image = [UIImage imageNamed:@"main_stopvideo"];
            self.liveImageView.hidden = NO;
        }
    }
    else
    {
        self.liveImageView.image = YSSkinDefineImage(@"live_main_notclassbeging");
        self.liveImageView.hidden = NO;
    }
}

- (void)creatbuttonHide
{
    self.buttonHide = YES;
}

- (void)freshContentView
{
    if (self.isFullScreen)
    {
        [self freshVidoeGridView];
    }
    else
    {
        [self freshContentVidoeView];
    }
}

// 刷新全屏视频布局
- (void)freshVidoeGridView
{
    [self.videoBackgroud bm_removeAllSubviews];
    
    //    CGFloat firstX = (self.videoBackgroud.bm_width - self.videoViewArray.count *platformVideoWidth - VIDEOVIEW_HORIZON_GAP * 5)/2;
    
    for (int i = 1; i <= self.videoViewArray.count; i++)
    {
        SCVideoView *videoView = self.videoViewArray[i-1];
        [self.videoBackgroud addSubview:videoView];
        videoView.frame = CGRectMake(self.videoBackgroud.bm_width - (i * (platformVideoWidth + VIDEOVIEW_HORIZON_GAP)) , 0, platformVideoWidth, platformVideoHeight);
    }
}

// 刷新content视频布局
- (void)freshContentVidoeView
{
    [self.videoBackgroud bm_removeAllSubviews];
    
    CGFloat teacherH = 0.0;
    CGFloat teacherW = 0.0;
    if (self.videoViewArray.count <= 2)
    {
        teacherH = self.liveViewHeight;
        teacherW = BMUI_SCREEN_WIDTH;
        for (NSInteger i = 1; i <= self.videoViewArray.count; i++)
        {
            SCVideoView *videoView = self.videoViewArray[i-1];
            [self.videoBackgroud addSubview:videoView];
            videoView.frame = CGRectMake(self.videoBackgroud.bm_width - (i * (platformVideoWidth + VIDEOVIEW_HORIZON_GAP)) , 0, platformVideoWidth, platformVideoHeight);
        }
    }
    else
    {
        teacherH = ceil(self.liveViewHeight - platformVideoHeight - VIDEOVIEW_HORIZON_GAP * 2) ;
        if (self.isWideScreen)
        {
            teacherW = ceil(teacherH * 16 / 9);
            
        }
        else
        {
            teacherW = ceil(teacherH * 4 / 3);
        }
        
        CGFloat firstX = (self.videoBackgroud.bm_width - self.videoViewArray.count *platformVideoWidth - VIDEOVIEW_HORIZON_GAP * 5)/2;
        for (int i = 0; i < self.videoViewArray.count; i++)
        {
            SCVideoView *videoView = self.videoViewArray[i];
            [self.videoBackgroud addSubview:videoView];
            videoView.frame = CGRectMake(firstX  + i * (platformVideoWidth + VIDEOVIEW_HORIZON_GAP) , 0, platformVideoWidth, platformVideoHeight);
        }
    }
    
    self.liveBgView.frame = CGRectMake(0, 0, teacherW, teacherH);
    self.liveBgView.bm_centerX = self.allVideoBgView.bm_centerX;
    
}


#pragma mark -
#pragma mark Mp3Func

- (void)onPlayMp3
{
    self.playMp3ImageView.hidden = NO;
    [self.playMp3ImageView startAnimating];
}

- (void)onPauseMp3
{
    [self.playMp3ImageView stopAnimating];
}

- (void)onStopMp3
{
    self.playMp3ImageView.hidden = YES;
    [self.playMp3ImageView stopAnimating];
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


- (void)removeAllVideoView
{
    [super removeAllVideoView];
}

#pragma mark  添加视频窗口

- (SCVideoView *)addVidoeViewWithPeerId:(NSString *)peerId
{
    SCVideoView *newVideoView = [super addVidoeViewWithPeerId:peerId withMaxCount:PLATFPRM_VIDEO_MAXCOUNT];

    
    [self freshContentView];
    
    return newVideoView;
}

#pragma mark  删除视频窗口

- (SCVideoView *)delVidoeViewWithPeerId:(NSString *)peerId
{
    SCVideoView *delVideoView = [super delVidoeViewWithPeerId:peerId];
    
    if (delVideoView)
    {
        [self freshContentView];
    }
    
    return delVideoView;
}


#pragma mark -
#pragma mark YSLiveRoomManagerDelegate

- (void)onRoomConnectionLost
{
    [super onRoomConnectionLost];
    [self.view bringSubviewToFront:self.returnBtn];
    //    [self removeAllVideoView];
    //
    //    if (self.isFullScreen)
    //    {
    //        self.isFullScreen = NO;
    //        [self changeTopVideoToOriginalFrame];
    //    }
    //
    //    [self freshContentView];
}


- (void)onRoomReJoined:(long)ts
{
    [super onRoomReJoined:ts];
    
}
// 已经离开房间
- (void)onRoomLeft
{
    [super onRoomLeft];
    
    // 网络中断尝试失败后退出
    [[BMNoticeViewStack sharedInstance] closeAllNoticeViews];// 清除alert的栈
    //    [self.navigationController popToRootViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:^{
#if YSSDK
        [self.liveManager onSDKRoomLeft];
#endif
        [YSLiveManager destroy];
    }];
}

/// 自己被踢出房间
- (void)onRoomKickedOut:(NSDictionary *)reason
{
    NSUInteger reasonCode = [reason bm_uintForKey:@"reason"];
    
    NSString *reasonString = YSLocalized(@"KickOut.Repeat");
    if (reasonCode)
    {
        reasonString = YSLocalized(@"KickOut.SentOutClassroom");
    }
    
    BMWeakSelf
    [BMAlertView ys_showAlertWithTitle:reasonString message:nil cancelTitle:YSLocalized(@"Prompt.OK") otherTitle:nil completion:^(BOOL cancelled, NSInteger buttonIndex) {
        
        [weakSelf.liveManager leaveRoom:nil];
    }];
}

- (void)roomManagerRoomTeacherEnter
{
    BMLog(@"roomManagerRoomTeacherEnter %@", self.liveManager.teacher.nickName);
    
    self.teacherPlaceLab.hidden = self.liveManager.isClassBegin;
}

- (void)roomManagerRoomTeacherLeft
{
    BMLog(@"roomManagerRoomTeacherLeft %@", self.liveManager.teacher.nickName);
    self.teacherPlaceLab.hidden = YES;
}

#pragma mark 用户进入

- (void)roomManagerJoinedUser:(YSRoomUser *)user inList:(BOOL)inList
{
    if (inList == NO && self.liveManager.isClassBegin && user.role == YSUserType_Teacher)
    {
#if YSAPP_NEWERROR
        self.roomVideoPeerID = user.peerID;
        if (user.publishState >= YSUser_PublishState_VIDEOONLY && user.publishState != 4)
        {
            self.showRoomVideo = YES;
            [self.liveManager playVideoOnView:self.liveView withPeerId:self.roomVideoPeerID renderType:YSRenderMode_adaptive completion:^(NSError *error) {
            }];
        }
        if (user.publishState == YSUser_PublishState_AUDIOONLY || user.publishState == YSUser_PublishState_BOTH)
        {
            [self.liveManager playAudio:self.roomVideoPeerID completion:^(NSError *error) {
            }];
        }
#endif
        
        [self freshMediaView];
    }
}

#pragma mark 用户退出

- (void)roomManagerLeftUser:(YSRoomUser *)user
{
    if (user.role == YSUserType_Teacher)
    {
#if YSAPP_NEWERROR
        [self.liveManager stopPlayVideo:user.peerID completion:nil];
        [self.liveManager stopPlayAudio:user.peerID completion:nil];
#endif
    }
    
#if 0
    for (YSRoomUser *memberUser in self.memberList)
    {
        if ([memberUser.peerID isEqualToString:user.peerID])
        {
            [self.memberList removeObject:memberUser];
            break;
        }
    }
#endif
}

#pragma mark 用户属性变化

- (void)onRoomUserPropertyChanged:(NSString *)userId fromeUserId:(NSString *)fromeUserId properties:(NSDictionary *)properties
{
    SCVideoView *videoView = [self getVideoViewWithPeerId:userId];
    YSRoomUser *roomUser = [self.liveManager getRoomUserWithId:userId];
    
    // 网络状态
    if ([properties bm_containsObjectForKey:sYSUserNetWorkState])
    {
        [videoView freshWithRoomUserProperty:roomUser];
    }
    
    // 本人是否被禁言
    if ([properties bm_containsObjectForKey:sYSUserDisablechat])
    {
        if ([userId isEqualToString:self.liveManager.localUser.peerID])
        {
            BOOL disablechat = [properties bm_boolForKey:sYSUserDisablechat];
            self.chaView.chatToolView.everyoneBanChat = disablechat;
            if (disablechat)
            {
                self.chaView.chatToolView.allDisabledChat.text = YSLocalized(@"Prompt.BanChat");
                [self.chaView toHiddenKeyBoard];
            }
        }
    }
    
    // 上台
    if ([properties bm_containsObjectForKey:sYSUserPublishstate] && roomUser.role == YSUserType_Student)
    {
        YSPublishState publishState = [properties bm_intForKey:sYSUserPublishstate];
        
        if ([userId isEqualToString:self.liveManager.localUser.peerID])
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
        }
        
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
            [self clickToShowControl];// 隐藏控制按钮
        }
    }
    
    if ([userId isEqualToString:self.liveManager.localUser.peerID] && self.controlBackMaskView.hidden == NO)
    {
        /// 更新用户的视频按钮状态
        [self updataVideoPopViewState];
    }
    
    /// 用户设备状态
    if ([properties bm_containsObjectForKey:sYSUserVideoFail] || [properties bm_containsObjectForKey:sYSUserAudioFail])
    {
        [videoView freshWithRoomUserProperty:roomUser];
    }
}

#pragma mark 切换网络 会收到onRoomJoined

- (void)onRoomJoined:(long)ts
{
    [super onRoomJoined:ts];
    
}


#pragma mark 上下课

// 上课
- (void)handleSignalingClassBeginWihInList:(BOOL)inlist
{
    self.teacherPlaceLab.hidden = YES;
    NSString *teacherPeerID = self.liveManager.teacher.peerID;
    YSRoomUser *teacher = [self.liveManager getRoomUserWithId:teacherPeerID];
    
    self.roomVideoPeerID = self.liveManager.teacher.peerID;
    if (teacher.publishState >= YSUser_PublishState_VIDEOONLY && teacher.publishState != 4)
    {
        self.showRoomVideo = YES;
        NSString *streamID = [self.liveManager getUserStreamIdWithUserId:self.roomVideoPeerID];
        if (streamID)
        {
            [self.liveManager playVideoWithUserId:self.roomVideoPeerID streamID:streamID renderMode:CloudHubVideoRenderModeHidden mirrorMode:CloudHubVideoMirrorModeDisabled inView:self.liveView];
        }
    }
    
    [self freshMediaView];
    
    if (!inlist)
    {
        [self bringSomeViewToFront];
        [self.progressHUD bm_showAnimated:NO withDetailText:YSLocalized(@"Alert.BeginClass") delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
    }
    
    
    for (YSRoomUser *roomUser in self.liveManager.userList)
    {
#if 0
        if (needFreshVideoView)
        {
            needFreshVideoView = NO;
            break;
        }
#endif
        
        if (roomUser.role == YSUserType_Student)
        {
            YSPublishState publishState = [roomUser.properties bm_intForKey:sYSUserPublishstate];
            NSString *peerID = roomUser.peerID;
            
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
            else if (publishState == 4)
            {
                [self addVidoeViewWithPeerId:peerID];
            }
            else
            {
                [self delVidoeViewWithPeerId:peerID];
            }
        }
    }
    
    self.chaView.chatToolView.maskView.hidden = YES;
    self.questionaView.maskView.hidden = YES;
}

// 下课
- (void)handleSignalingClassEndWithText:(NSString *)text
{
    YSSharedMediaFileModel *playMediaModel = self.liveManager.mediaFileModel;
    if (!playMediaModel.isVideo)
    {
        [self onStopMp3];
    }
    
    self.showRoomVideo = NO;
    [self.liveManager stopShareOneMediaFile];
    
    self.roomVideoPeerID = nil;
    
    [self freshMediaView];
    
    BMWeakSelf
    [BMAlertView ys_showAlertWithTitle:text message:nil cancelTitle:YSLocalized(@"Prompt.OK") completion:^(BOOL cancelled, NSInteger buttonIndex) {
        
        [weakSelf.liveManager leaveRoom:nil];
        
    }];
    //    if (![YSLiveManager shareInstance].roomConfig.isChatBeforeClass) {
    //        self.chaView.chatToolView.maskView.hidden = NO;
    //        self.questionaView.maskView.hidden = NO;
    //    }
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

/* 学生不需要下课提示
 /// 房间即将关闭消息
 - (BOOL)handleSignalingPrepareRoomEndWithDataDic:(NSDictionary *)dataDic addReason:(YSPrepareRoomEndType)reason
 {
 NSUInteger reasonCount = [dataDic bm_uintForKey:@"reason"];
 
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
 [self showSignalingClassEndWithText:YSLocalized(@"Prompt.Appointment30")];
 }
 else if(reasonCount == 3)
 {//表示已经超过房间预约时间28分钟，2分钟后房间即将关闭
 [self showSignalingClassEndWithText:YSLocalized(@"Prompt.Appointment28")];
 }
 }
 return YES;
 }
 */

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


#pragma mark 房间视频/音频
/// 继续播放房间视频
- (void)handleRoomPlayMediaWithPeerID:(NSString *)peerID
{
    if (![peerID isEqualToString:self.liveManager.teacher.peerID])
    {
        return;
    }
    self.liveBgView.canZoom = NO;
    self.liveBgView.backScrollView.zoomScale = 1.0;
    
    self.showRoomVideo = YES;
#if YSAPP_NEWERROR
    [self.liveManager playVideoOnView:self.liveView withPeerId:self.roomVideoPeerID renderType:YSRenderMode_adaptive completion:^(NSError *error) {
    }];
#endif
    
    [self freshMediaView];
}

/// 暂停房间视频
- (void)handleRoomPauseMediaWithPeerID:(NSString *)peerID
{
    if (![peerID isEqualToString:self.liveManager.teacher.peerID])
    {
        return;
    }
    
    self.showRoomVideo = NO;
#if YSAPP_NEWERROR
    [self.liveManager stopPlayVideo:self.liveManager.teacher.peerID completion:^(NSError * _Nonnull error) {
    }];
#endif
    
    [self freshMediaView];
}

/// 继续播放房间音频
- (void)handleRoomPlayAudioWithPeerID:(NSString *)peerID
{
    if (![peerID isEqualToString:self.liveManager.teacher.peerID])
    {
        return;
    }
    
#if YSAPP_NEWERROR
    [self.liveManager playAudio:self.roomVideoPeerID completion:^(NSError *error) {
    }];
#endif
}

/// 暂停房间音频
- (void)handleRoomPauseAudioWithPeerID:(NSString *)peerID
{
    if (![peerID isEqualToString:self.liveManager.teacher.peerID])
    {
        return;
    }
    
#if YSAPP_NEWERROR
    [self.liveManager stopPlayAudio:self.roomVideoPeerID completion:^(NSError *error) {
    }];
#endif
    [self freshMediaView];
}

#pragma mark 白板视频/音频

// 播放白板视频/音频
- (void)handleWhiteBordPlayMediaFileWithMedia:(YSSharedMediaFileModel *)mediaModel
{
    if (!mediaModel.isVideo)
    {
        [self onPlayMp3];
    }
    else
    {
        [self.liveManager playVideoWithUserId:mediaModel.senderId streamID:mediaModel.streamID renderMode:CloudHubVideoRenderModeFit mirrorMode:CloudHubVideoMirrorModeDisabled inView:self.mp4View];
        
        if (self.isFullScreen)
        {
            // 如果是全屏，点击按钮进入小屏状态
            [self changeTopVideoToOriginalFrame];
        }
        self.fullScreenBtn.enabled = NO;
        self.mp4BgView.hidden = NO;
        [self.mp4BgView bm_bringToFront];
        [self.mp4FullScreenBtn bm_bringToFront];
    }
}

// 停止白板视频/音频
- (void)handleWhiteBordStopMediaFileWithMedia:(YSSharedMediaFileModel *)mediaModel
{
    [self onStopMp3];
    
    if (mediaModel.isVideo)
    {
        [self.liveManager stopVideoWithUserId:mediaModel.senderId streamID:mediaModel.streamID];

        self.fullScreenBtn.enabled = YES;
        self.mp4BgView.hidden = YES;
        [self handleSignalingHideVideoWhiteboard];
    }
    
}

/// 继续播放白板视频/音频
- (void)handleWhiteBordPlayMediaStream:(YSSharedMediaFileModel *)mediaFileModel
{
    if (!mediaFileModel.isVideo)
    {
        [self onPlayMp3];
    }
}

/// 暂停播放白板视频/音频
- (void)handleWhiteBordPauseMediaStream:(YSSharedMediaFileModel *)mediaFileModel
{
    if (!mediaFileModel.isVideo)
    {
        [self onPauseMp3];
    }
}

/// 显示白板视频标注
- (void)handleSignalingShowVideoWhiteboardWithData:(NSDictionary *)data videoRatio:(CGFloat)videoRatio
{
    if (![self.liveManager.whiteBoardManager isOneWhiteBoardView])
    {
        return;
    }
    if (self.mp4BgView.hidden)
    {
        return;
    }
    
    if (self.mediaMarkView.superview)
    {
        [self.mediaMarkView removeFromSuperview];
    }
    
    self.mediaMarkView = [[YSMediaMarkView alloc] initWithFrame:self.mp4BgView.bounds];
    [self.mp4BgView addSubview:self.mediaMarkView];
    [self.mp4FullScreenBtn bm_bringToFront];
    
    [self.mediaMarkView freshViewWithSavedSharpsData:self.mediaMarkSharpsDatas videoRatio:videoRatio];
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
    if (self.mediaMarkView.superview)
    {
        [self.mediaMarkView removeFromSuperview];
    }
}

#pragma mark 共享桌面

/// 开始桌面共享 服务端控制与课件视频/音频互斥
- (void)onRoomStartShareDesktopWithUserId:(NSString *)userId streamID:(NSString *)streamID
{
    self.shareDesktop = YES;
    NSString *userStreamID = [self.liveManager getUserStreamIdWithUserId:self.roomVideoPeerID];
    [self.liveManager stopVideoWithUserId:self.roomVideoPeerID streamID:userStreamID];
    self.roomVideoPeerID = nil;
    
    [self.liveManager playVideoWithUserId:userId streamID:streamID renderMode:CloudHubVideoRenderModeFit mirrorMode:CloudHubVideoMirrorModeDisabled inView:self.liveView];
    
    self.liveBgView.canZoom = YES;
    [self freshMediaView];
}

/// 停止桌面共享
- (void)onRoomStopShareDesktopWithUserId:(NSString *)userId streamID:(NSString *)streamID
{
    self.shareDesktop = NO;
    [self.liveManager stopVideoWithUserId:userId streamID:streamID];
    
    self.roomVideoPeerID = self.liveManager.teacher.peerID;
    NSString *userStreamID = [self.liveManager getUserStreamIdWithUserId:self.liveManager.teacher.peerID];
    
    [self.liveManager playVideoWithUserId:userId streamID:userStreamID renderMode:CloudHubVideoRenderModeHidden mirrorMode:CloudHubVideoMirrorModeDisabled inView:self.liveView];
    
    self.liveBgView.canZoom = NO;
    self.liveBgView.backScrollView.zoomScale = 1.0;
    [self freshMediaView];
}

#pragma mark 签到（点名）

// 收到签到
- (void)handleSignalingLiveCallRollWithStateType:(NSUInteger)stateType callRollId:(NSString *)callRollId apartTimeInterval:(NSTimeInterval)apartTimeInterval
{
    if (self.isFullScreen)
    {
        // 如果是全屏，点击按钮进入小屏状态
        [self changeTopVideoToOriginalFrame];
    }
    
    if (self.signedAlert)
    {
        [self.signedAlert dismiss:nil];
    }
    [self.view endEditing:YES];
    
    // stateType    0--1分钟  1--3分钟  2--5分钟  3--10分钟  4--30分钟
    NSInteger time = 0;
    switch (stateType)
    {
        case YSSignCountDownType_ONE:
            time = 1 * 60;
            break;
        case YSSignCountDownType_THREE:
            time = 3 * 60;
            break;
        case YSSignCountDownType_FIVE:
            time = 5 * 60;
            break;
        case YSSignCountDownType_TEN:
            time = 10 * 60;
            break;
        case YSSignCountDownType_THIRTY:
            time = 30 * 60;
            break;
        default:
            break;
    }
    
    time = time - apartTimeInterval;
    if (time <= 0 )
    {
        return;
    }
    // UI更新代码
    BMWeakSelf
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3* NSEC_PER_SEC));
    
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        weakSelf.signedAlert = [YSSignedAlertView showWithTime:time inView:self.view backgroundEdgeInsets:UIEdgeInsetsMake(self.liveViewHeight + PAGESEGMENT_HEIGHT, 0, 0, 0) topDistance:0 signedBlock:^{
            [weakSelf sendLiveCallRollSigninWithCallRollId:callRollId];
        }];
    });
    
}

// 结束点名
- (void)closeSignalingLiveCallRoll
{   
    [self.signedAlert dismiss:nil];
}

#pragma mark 抽奖

// 抽奖
- (void)handleSignalingLiveLuckDraw
{
    BMLog(@"抽奖中");
    
    
    if (self.isFullScreen)
    {
        // 如果是全屏，点击按钮进入小屏状态
        [self changeTopVideoToOriginalFrame];
    }
    
    [self.view endEditing:YES];
    BMWeakSelf
    if (self.prizeAlert)
    {
        [self.prizeAlert dismiss:nil dismissBlock:^(id  _Nullable sender, NSUInteger index) {
            
            weakSelf.prizeAlert = [YSPrizeAlertView showPrizeWithStatus:NO inView:weakSelf.view backgroundEdgeInsets:UIEdgeInsetsMake(self.liveViewHeight + PAGESEGMENT_HEIGHT, 0, 0, 0) topDistance:0];
        }];
    }
    else
    {
        
        self.prizeAlert = [YSPrizeAlertView showPrizeWithStatus:NO inView:self.view backgroundEdgeInsets:UIEdgeInsetsMake(self.liveViewHeight + PAGESEGMENT_HEIGHT, 0, 0, 0) topDistance:0];
    }
}

// 中奖结果
- (void)handleSignalingLiveLuckDrawResultWithNameList:(NSArray *)nameList withEndTime:(NSString *)endTime
{
    if (self.isFullScreen)
    {
        // 如果是全屏，点击按钮进入小屏状态
        [self changeTopVideoToOriginalFrame];
    }
    
    BMWeakSelf
    if (self.prizeAlert)
    {//移除抽奖中view
        [self.prizeAlert dismiss:nil animated:YES dismissBlock:^(id  _Nullable sender, NSUInteger index) {
            
            weakSelf.prizeAlert = [YSPrizeAlertView showPrizeWithStatus:YES inView:weakSelf.view backgroundEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0) topDistance:(BMUI_SCREEN_HEIGHT - 200)/2];
            weakSelf.prizeAlert.endTime = endTime;
            weakSelf.prizeAlert.dataSource = nameList;
        }];
    }
    else
    {
        self.prizeAlert = [YSPrizeAlertView showPrizeWithStatus:YES inView:self.view backgroundEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0) topDistance:(BMUI_SCREEN_HEIGHT - 200)/2];
        self.prizeAlert.endTime = endTime;
        self.prizeAlert.dataSource = nameList;
    }
}

// 抽奖结束
- (void)closeSignalingLiveLuckDraw
{
    [self.prizeAlert dismiss:nil];
}
///全体禁言
- (void)handleSignalingToDisAbleEveryoneBanChatWithIsDisable:(BOOL)isDisable
{
    [super handleSignalingToDisAbleEveryoneBanChatWithIsDisable:isDisable];
    
    self.chaView.chatToolView.everyoneBanChat = isDisable;
    if (isDisable)
    {
        self.chaView.chatToolView.allDisabledChat.text = YSLocalized(@"Prompt.BanChatInView");
        [self.chaView toHiddenKeyBoard];
    }
}
#pragma mark 接收消息 弹幕

- (void)handleMessageWith:(YSChatMessageModel *)message
{
    if (self.isFullScreen)
    {
        YSBarrageTextDescriptor *textDescriptor = [[YSBarrageTextDescriptor alloc] init];
        
        //          textDescriptor.text = message.message;
        textDescriptor.attributedText = [message emojiViewWithMessage:message.message color:YSSkinDefineColor(@"placeholderColor") font:16.0f];
        textDescriptor.textColor = [UIColor whiteColor];
        textDescriptor.positionPriority = YSBarragePositionLow;
        textDescriptor.textFont = [UIFont systemFontOfSize:16.0];
        textDescriptor.strokeColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        textDescriptor.strokeWidth = -1;
        textDescriptor.animationDuration = arc4random()%5 + 5;
        textDescriptor.barrageCellClass = [YSBarrageTextCell class];
        [self.barrageManager renderBarrageDescriptor:textDescriptor];
    }
    
    if (self.m_SegmentBar.currentIndex != 2 && message.chatMessageType != YSChatMessageType_Tips && message.chatMessageType != YSChatMessageType_ImageTips)
    {
        UIView *segmentView = [self.m_SegmentBar segmentViewAtIndex:2];
        segmentView.badgeCenterOffset = CGPointMake(-20, 15);
        [segmentView showRedDotBadge];
        
        if (![self.chaView bm_isNotEmpty])
        {
            [self.messageBeforeList addObject:message];
            return;
        }
    }
    
    [self.chaView.messageList addObject:message];
    
    if (message.chatMessageType != YSChatMessageType_Tips && message.chatMessageType != YSChatMessageType_ImageTips) {
        if (message.sendUser.role == YSUserType_Teacher)
        {
            [self.chaView.anchorMessageList addObject:message];
        }
        else if ([message.sendUser.peerID isEqualToString:YSCurrentUser.peerID])
        {
            [self.chaView.mainMessageList addObject:message];
        }
    }
    [self.chaView reloadTableView];
}

#pragma mark 提问
// 提问 确认 回答
- (void)handleSignalingQuestionResponedWithQuestion:(YSQuestionModel *)question
{
    if (self.m_SegmentBar.currentIndex != 3)
    {
        UIView *segmentView = [self.m_SegmentBar segmentViewAtIndex:3];
        segmentView.badgeCenterOffset = CGPointMake(-20, 15);
        [segmentView showRedDotBadge];
        
        if (![self.questionaView bm_isNotEmpty])
        {
            [self.questionBeforeArr addObject:question];
            return;
        }
    }
    [self.questionaView frashView:question];
}

// 删除提问
- (void)handleSignalingDeleteQuestionWithQuestionId:(NSString *)questionId
{
    if (![self.questionaView bm_isNotEmpty] && self.questionBeforeArr.count)
    {
        for (YSQuestionModel * model in self.questionBeforeArr)
        {
            if ([model.questionId isEqualToString:questionId])
            {
                [self.questionBeforeArr removeObject:model];
                break;
            }
        }
        return;
    }
    [self.questionaView frashView:questionId];
}

#pragma mark 通知 公告

// 通知
- (void)handleSignalingLiveNoticeInfoWithNotice:(NSString *)text timeInterval:(NSUInteger)timeInterval
{
    [self creatLessonDataWithNotice:text type:YSLessonNotifyType_Status timeInterval:timeInterval];
}

// 公告
- (void)handleSignalingLiveNoticeBoardWithNotice:(NSString *)text timeInterval:(NSUInteger)timeInterval
{
    [self creatLessonDataWithNotice:text type:YSLessonNotifyType_Message timeInterval:timeInterval];
}

- (void)creatLessonDataWithNotice:(NSString *)notice type:(YSLessonNotifyType)type timeInterval:(NSUInteger)timeInterval
{
    YSLessonModel * model = [[YSLessonModel alloc] init];
    model.notifyType = type;
    model.details = notice;
    model.publishTime = [NSDate bm_stringFromTs:timeInterval formatter:@"HH:mm"];
    if (self.m_SegmentBar.currentIndex != 1)
    {
        UIView *segmentView = [self.m_SegmentBar segmentViewAtIndex:1];
        segmentView.badgeCenterOffset = CGPointMake(-20, 15);
        [segmentView showRedDotBadge];
    }
    [self.lessonDataSource insertObject:model atIndex:1];
    self.lessonView.dataSource = self.lessonDataSource;
}

// 接收到送花的消息
- (void)handleSignalingSendFlowerWithSenderId:(NSString *)senderId senderName:(NSString *)senderName
{
    [self.chaView receiveFlowrsWithSenderId:senderId senderName:senderName];
}

#pragma mark 投票

// 投票
- (void)handleSignalingVoteStartWithVoteId:(NSString *)voteId userName:(NSString *)userName subject:(nonnull NSString *)subject time:(nonnull NSString *)time desc:(nonnull NSString *)desc isMulti:(BOOL)multi voteList:(nonnull NSArray<NSString *> *)voteList
{
    //当在投票结果页面时  收到老师投票信令  将投票结果页面pop掉
    [self.navigationController popToViewController:self animated:NO];
    if (self.isFullScreen)
    {
        // 如果是全屏，点击按钮进入小屏状态
        [self changeTopVideoToOriginalFrame];
    }
    
    YSVoteModel *voteModel = [[YSVoteModel alloc] init];
    voteModel.teacherName = self.liveManager.teacher.nickName;
    voteModel.timeStr = time;
    voteModel.voteId = voteId;
    voteModel.subject = subject;
    voteModel.desc = desc;
    
    NSMutableArray * arr = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i < voteList.count; i++)
    {
        YSVoteResultModel * resultModel = [[YSVoteResultModel alloc] init];
        resultModel.title = voteList[i];
        [arr addObject:resultModel];
    }
    YSVoteVC * voteVC = [[YSVoteVC alloc] init];
    voteVC.voteType = multi ? YSVoteVCType_Multiple : YSVoteVCType_Single;
    voteVC.voteModel = voteModel;
    voteVC.dataSource = arr;
    [self.navigationController pushViewController:voteVC animated:YES];
    
}

// 投票结果
- (void)handleSignalingVoteResultWithVoteId:(NSString *)voteId userName:(NSString *)userName subject:(NSString *)subject time:(nonnull NSString *)time desc:(nonnull NSString *)desc isMulti:(BOOL)multi voteResult:(nonnull NSArray<NSDictionary *> *)voteResult
{
    
    //当在投票中页面时  收到老师结束投票信令  将投票中页面pop掉
    [self.navigationController popToViewController:self animated:NO];
    if (self.isFullScreen)
    {
        // 如果是全屏，点击按钮进入小屏状态
        [self changeTopVideoToOriginalFrame];
    }
    
    YSVoteModel *voteModel = [[YSVoteModel alloc] init];
    voteModel.teacherName = self.liveManager.teacher.nickName;
    voteModel.timeStr = time;
    voteModel.voteId = voteId;
    voteModel.subject = subject;
    voteModel.desc = desc;
    
    NSMutableArray * arr = [NSMutableArray arrayWithCapacity:0];
    
    NSUInteger total = 0;
    
    NSString * rightaAnswer = @"";
    for (NSDictionary *dic in voteResult)
    {
        NSUInteger count = [dic bm_uintForKey:@"count"];
        total += count;
        
        NSUInteger isResult = [dic bm_uintForKey:@"isRight"];
        if (isResult == 1)
        {
            NSString *content = [dic bm_stringTrimForKey:@"content"];
            rightaAnswer = [rightaAnswer stringByAppendingFormat:@"%@，",content];
        }
    }
    if ([rightaAnswer bm_isNotEmpty])
    {
        voteModel.rightAnswer = [rightaAnswer substringWithRange:NSMakeRange(0, rightaAnswer.length - 1)];//正确答案
    }
    
    for (int i = 0; i < voteResult.count; i++)
    {
        YSVoteResultModel * resultModel = [[YSVoteResultModel alloc] init];
        resultModel.total = [NSString stringWithFormat:@"%@",@(total)];
        NSUInteger count = [voteResult[i] bm_uintForKey:@"count"];
        resultModel.number = [NSString stringWithFormat:@"%@",@(count)];
        resultModel.title = [voteResult[i] bm_stringTrimForKey:@"content"];
        resultModel.isSelect = NO;
        [arr addObject:resultModel];
    }
    YSVoteVC * voteVC = [[YSVoteVC alloc] init];
    voteVC.voteType = YSVoteVCType_Result;
    voteVC.dataSource = arr;
    voteVC.voteModel = voteModel;
    
    [self.navigationController pushViewController:voteVC animated:YES];
}

- (void)handleSignalingVoteEndWithVoteId:(NSString *)voteId
{
    [self.navigationController popToViewController:self animated:NO];
}

#pragma mark -
#pragma mark BMScrollPageView Delegate & DataSource

- (NSUInteger)scrollPageViewNumberOfPages:(BMScrollPageView *)scrollPageView
{
    return 4;
}

- (NSString *)scrollPageView:(BMScrollPageView *)scrollPageView titleAtIndex:(NSUInteger)index
{
    switch (index)
    {
        case 0:
            return YSLocalized(@"Label.Courseware");
            break;
        case 1:
            return YSLocalized(@"Label.Room");
            break;
        case 2:
            return YSLocalized(@"Button.chat");
            break;
        default:
            return YSLocalized(@"Label.Question");
            break;
    }
}

- (BOOL)scrollPageView:(BMScrollPageView *)scrollPageView needChangeTableSizeAtIndex:(NSUInteger)index
{
    switch (index) {
        case 1:
            return NO;
        case 2:
            return NO;
        case 3:
            return NO;
        default:
            return YES;
    }
}

- (id)scrollPageView:(BMScrollPageView *)scrollPageView pageAtIndex:(NSUInteger)index
{
    switch (index)
    {
        case 0:
        {
            //            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            //            [userDefaults setObject:@"" forKey:@"com.tingxins.sakura.current.name"];
            
            self.whiteBordView.frame = CGRectMake(0, 0, BMUI_SCREEN_WIDTH, self.m_ScrollPageView.bm_height);
            [self.liveManager.whiteBoardManager refreshWhiteBoard];
            
            return self.whiteBordView;
        }
        case 1:
        {
            //房间
            YSLessonView * view = [[YSLessonView alloc] initWithFrame:CGRectMake(0, 0, BMUI_SCREEN_WIDTH, 100)];
            self.lessonView = view;
            view.dataSource = self.lessonDataSource;
            return view;
        }
        case 2:
        {//聊天
            //2074197451
            self.chaView = [[YSChatView alloc]initWithFrame:CGRectMake(0, 0 , BMUI_SCREEN_WIDTH, self.m_ScrollPageView.bm_height)];
            self.chaView.chatToolView.memberDelegate = self;
            BMWeakSelf
            self.chaView.chatToolView.pushPopooverView = ^(UIButton * _Nonnull popoBtn) {
                [weakSelf creatPopover:popoBtn];
            };
            
            self.chaView.addChatMember = ^(YSRoomUser * _Nonnull memberModel) {
                BOOL isUserExist = NO;
                for (YSRoomUser *memberUser in weakSelf.memberList)
                {
                    if ([memberUser.peerID isEqualToString:memberModel.peerID])
                    {
                        isUserExist = YES;
                        break;
                    }
                }
                if (!isUserExist)
                {
                    [weakSelf.memberList addObject:memberModel];
                }
            };
            
            if (self.messageBeforeList.count)
            {
                self.chaView.messageList = [NSMutableArray arrayWithArray: self.messageBeforeList];
                [self.messageBeforeList removeAllObjects];
            }
            [self.chaView bringSubviewToFront:self.chaView.chatToolView];
            return self.chaView;
        }
        default:
        {//提问
            self.questionaView = [[YSQuestionView alloc]initWithFrame:CGRectMake(0, 0 , BMUI_SCREEN_WIDTH, self.m_ScrollPageView.bm_height)];
            self.questionaView.backgroundColor = [UIColor whiteColor];
            if (self.questionBeforeArr.count)
            {
                self.questionaView.questionArr = [NSMutableArray arrayWithArray: self.questionBeforeArr];;
                [self.questionBeforeArr removeAllObjects];
            }
            return self.questionaView;
        }
    }
}

- (void)scrollPageViewChangeToIndex:(NSUInteger)index
{
    [self.view endEditing:YES];
    
    if (index == 1 || index == 2 || index == 3 )
    {
        UIView *segmentView = [self.m_SegmentBar segmentViewAtIndex:index];
        [segmentView clearBadge];
    }
}

- (void)creatPopover:(UIButton*)popoBtn
{
    self.menuVc.popoverPresentationController.sourceView = popoBtn;
    UIPopoverPresentationController *popover = self.menuVc.popoverPresentationController;
    popover.sourceRect = popoBtn.bounds;
    popover.permittedArrowDirections = UIPopoverArrowDirectionDown;
    popover.delegate = self;
    [self presentViewController:self.menuVc animated:YES completion:nil];///present即可
}


#pragma mark -
#pragma mark YSChatToolViewDelegate

- (void)clickPlaceholderdBtn
{
    [self.chaView toHiddenKeyBoard];
    
    YSChatMemberListVC *vc = [[YSChatMemberListVC alloc]init];
    vc.memberList = [NSMutableArray arrayWithArray:self.memberList];
    vc.selectModel = self.chaView.chatToolView.memberModel;
    
    BMWeakSelf
    vc.passTheMemberOfChat = ^(YSRoomUser * _Nonnull memberModel) {
        weakSelf.chaView.chatToolView.memberModel = memberModel;
    };
    
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark -
#pragma mark UIPopoverPresentationControllerDelegate

-(UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}


#pragma mark -
#pragma mark Request

/// 点名签到
- (void)sendLiveCallRollSigninWithCallRollId:(NSString *)callRollId
{
    BMAFHTTPSessionManager *manager = [YSLiveApiRequest makeYSHTTPSessionManager];
    NSMutableURLRequest *request = [YSLiveApiRequest liveCallRollSigninWithCallRollId:callRollId];
    if (request)
    {
        [self.liveCallRollSigninTask cancel];
        self.liveCallRollSigninTask = nil;
        
        BMWeakSelf
        self.liveCallRollSigninTask = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error)
            {
                BMLog(@"Error: %@", error);
                [weakSelf liveCallRollSigninRequestFailed:response error:error];
                
            }
            else
            {
                NSDictionary *responseDic = [YSSessionUtil convertWithData:responseObject];
                
#ifdef DEBUG
                NSString *responseStr = [[NSString stringWithFormat:@"%@", responseDic] bm_convertUnicode];
                BMLog(@"%@ %@", response, responseStr);
#endif
                [weakSelf liveCallRollSigninRequestFinished:response responseDic:responseDic];
            }
        }];
        [self.liveCallRollSigninTask resume];
    }
}

- (void)liveCallRollSigninRequestFinished:(NSURLResponse *)response responseDic:(NSDictionary *)resDic
{
    BMLog(@"签到-------------%@", resDic);
    
    NSInteger result = [resDic bm_intForKey:@"result"];
    
    if (result == 0)
    {
        [self.signedAlert dismiss:nil];
    }
}

- (void)liveCallRollSigninRequestFailed:(NSURLResponse *)response error:(NSError *)error
{
    BMLog(@"签到-------------失败%@", error);
}


#pragma mark -
#pragma mark SEL

- (void)liveViewClicked:(UITapGestureRecognizer *)sender
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(creatbuttonHide) object:nil];
    
    if (self.buttonHide)
    {
        self.buttonHide = NO;
        [self performSelector:@selector(creatbuttonHide) withObject:nil afterDelay:5.0f];
    }
    else
    {
        self.buttonHide = YES;
    }
}

- (void)barrageBtnClicked:(UIButton *)btn
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(creatbuttonHide) object:nil];
    [self performSelector:@selector(creatbuttonHide) withObject:nil afterDelay:5.0f];
    if (self.isFullScreen)
    {
        //控制弹幕关闭开启
        self.barrageStart = !self.barrageStart;
    }
    else
    {
        //控制转换
    }
}

/// 全屏按钮
- (void)fullScreenBtnClicked:(UIButton *)btn
{
    if ([[BMNoticeViewStack sharedInstance] getNoticeViewCount])
    {
        return;
    }
    
    // 播放Mp4时
    if (self.mp4BgView.hidden == NO)
    {
        return;
    }
    
    if (self.isFullScreen)
    {
        // 如果是全屏，点击按钮进入小屏状态
        [self changeTopVideoToOriginalFrame];
    }
    else
    {
        // 不是全屏，点击按钮进入全屏状态
        [self changeTopVideoToFullScreen];
        
    }
}

- (void)changeTopVideoToOriginalFrame
{
    [self setInterfaceOrientation:UIInterfaceOrientationPortrait];
}

- (void)changeTopVideoToFullScreen
{
    [self setInterfaceOrientation:UIInterfaceOrientationLandscapeRight];
}

- (void)mp4ViewClicked:(UITapGestureRecognizer *)sender
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideMp4FullScreenBtn) object:nil];
    
    if (self.mp4FullScreenBtn.hidden)
    {
        self.mp4FullScreenBtn.hidden = NO;
        [self performSelector:@selector(hideMp4FullScreenBtn) withObject:nil afterDelay:5.0f];
    }
    else
    {
        [self hideMp4FullScreenBtn];
    }
}

- (void)hideMp4FullScreenBtn
{
    self.mp4FullScreenBtn.hidden = YES;
}

- (void)mp4FullScreenBtnClicked:(UIButton *)btn
{
    if ([[BMNoticeViewStack sharedInstance] getNoticeViewCount])
    {
        return;
    }
    
    if (self.isMp4FullScreen)
    {
        // 如果是全屏，点击按钮进入小屏状态
        [self changeMp4VideoToOriginalFrame];
    }
    else
    {
        // 不是全屏，点击按钮进入全屏状态
        [self changeMp4VideoToFullScreen];
    }
}

- (void)changeMp4VideoToOriginalFrame
{
    [self setMp4InterfaceOrientation:UIInterfaceOrientationPortrait];
}

- (void)changeMp4VideoToFullScreen
{
    [self setMp4InterfaceOrientation:UIInterfaceOrientationLandscapeRight];
}


//- (void)setInterfaceOrientation:(UIInterfaceOrientation)orientation
//{
//    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)])
//    {
//        [[UIDevice currentDevice] performSelector:@selector(setOrientation:) withObject:@(orientation)];
//        [UIViewController attemptRotationToDeviceOrientation];
//    }
//
//    SEL selector = NSSelectorFromString(@"setOrientation:");
//
//    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
//    [invocation setSelector:selector];
//    [invocation setTarget:[UIDevice currentDevice]];
//    int val = (int)orientation;
//    [invocation setArgument:&val atIndex:2];
//    [invocation invoke];
//    [self orientChange:nil];
//}

/// 转屏通知
//- (void)orientChange:(NSNotification *)noti
- (void)setInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    //UIDeviceOrientation orientation = UIDeviceOrientationLandscapeLeft;//[UIDevice currentDevice].orientation;
    switch (orientation)
    {
        case UIDeviceOrientationPortrait:
        {
#warning setDeviceOrientation
            //[[YSLiveManager shareInstance] setDeviceOrientation:UIDeviceOrientationPortrait];
            
            [UIView animateWithDuration:0.25 animations:^{
                self.isFullScreen = NO;//通过set 方法刷新了视频布局
                self.barrageStart = NO;
                self.allVideoBgView.transform = CGAffineTransformMakeRotation(0);
                self.allVideoBgView.frame = CGRectMake(0, 0, BMUI_SCREEN_WIDTH, self.liveViewHeight);
                
                //                self.liveBgView.transform = CGAffineTransformMakeRotation(0);
                //                self.liveBgView.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH, VIDEOVIEW_HEIGHT);
                
                self.videoBackgroud.frame = CGRectMake(0, self.liveViewHeight - (self->platformVideoHeight) - VIDEOVIEW_VERTICAL_GAP , BMUI_SCREEN_WIDTH, (self->platformVideoHeight));
                
                self.returnBtn.transform = CGAffineTransformMakeRotation(0);
                self.returnBtn.frame = CGRectMake(10, BMUI_STATUS_BAR_HEIGHT, 40, 40);
                
//                self.roomIDLabel.transform = CGAffineTransformMakeRotation(0);
//                self.roomIDLabel.frame = CGRectMake(CGRectGetMaxX(self.returnBtn.frame) + 7, BMUI_STATUS_BAR_HEIGHT, 120, 26);
//                self.roomIDLabel.bm_centerY = self.returnBtn.bm_centerY;
                //self.barrageManager.renderView.transform = CGAffineTransformMakeRotation(0);
                self.barrageManager.renderView.frame = CGRectZero;
                //self.barrageManager.renderView.hidden = YES;
                
                self.fullScreenBtn.transform = CGAffineTransformMakeRotation(0);
                self.fullScreenBtn.frame = CGRectMake(BMUI_SCREEN_WIDTH - 15 - 40, BMUI_STATUS_BAR_HEIGHT, 40, 40);
                
                self.barrageBtn.transform = CGAffineTransformMakeRotation(0);
                self.barrageBtn.frame = CGRectZero;
                
                self.raiseHandsBtn.transform = CGAffineTransformMakeRotation(0);
                self.raiseHandsBtn.frame = CGRectMake(BMUI_SCREEN_WIDTH-40-15, self.fullScreenBtn.bm_bottom + 15, 40, 40);
                
                self.playMp3ImageView.bm_origin = CGPointMake(15, self.liveBgView.bm_bottom - 70);
                
                [self.teacherPlaceLab bm_centerHorizontallyInSuperViewWithTop:self.liveImageView.bm_height-50];
                [self setNeedsStatusBarAppearanceUpdate];
            }];
        }
            break;
        case UIDeviceOrientationLandscapeLeft:
        {
#warning setDeviceOrientation
            //[[YSLiveManager shareInstance] setDeviceOrientation:UIDeviceOrientationLandscapeLeft];
            
            [UIView animateWithDuration:0.25 animations:^{
                
                self.isFullScreen = YES;//通过set 方法刷新了视频布局
                self.barrageStart = YES;
                self.allVideoBgView.transform = CGAffineTransformMakeRotation(M_PI*0.5);
                self.allVideoBgView.frame = CGRectMake(0, 0, BMUI_SCREEN_WIDTH, BMUI_SCREEN_HEIGHT);
                //                self.liveBgView.transform = CGAffineTransformMakeRotation(M_PI*0.5);
                self.liveBgView.frame = CGRectMake(0, 0, BMUI_SCREEN_HEIGHT, BMUI_SCREEN_WIDTH);
                
                //                self.videoBackgroud.transform = CGAffineTransformMakeRotation(M_PI*0.5);
                self.videoBackgroud.frame = CGRectMake(0, BMUI_SCREEN_WIDTH - (self->platformVideoHeight) - 7 , BMUI_SCREEN_WIDTH, (self->platformVideoHeight));
                self.videoBackgroud.bm_centerX = self.allVideoBgView.bm_centerY;
                //                self.videoBackgroud.bm_bottom = self.liveBgView.bm_bottom - 7;
                
                self.returnBtn.transform = CGAffineTransformMakeRotation(M_PI*0.5);
                self.returnBtn.frame = CGRectMake(BMUI_SCREEN_WIDTH - 25 - 40, BMUI_STATUS_BAR_HEIGHT, 40, 40);
                
//                self.roomIDLabel.transform = CGAffineTransformMakeRotation(M_PI*0.5);
//                self.roomIDLabel.frame = CGRectMake(BMUI_SCREEN_WIDTH - 25 - 40, BMUI_STATUS_BAR_HEIGHT + 40 + 7, 26, 120);
//                self.roomIDLabel.bm_centerX = self.returnBtn.bm_centerX;
//
                
                self.barrageManager.renderView.frame = CGRectMake(0, 70, BMUI_SCREEN_HEIGHT, BMUI_SCREEN_WIDTH-70-(self->platformVideoHeight) - 10);
                
                self.fullScreenBtn.transform = CGAffineTransformMakeRotation(M_PI*0.5);
                self.fullScreenBtn.frame = CGRectMake(BMUI_SCREEN_WIDTH - 25 - 40 ,BMUI_SCREEN_HEIGHT - BMUI_HOME_INDICATOR_HEIGHT - 40 - 10 , 40, 40);
                
                self.barrageBtn.transform = CGAffineTransformMakeRotation(M_PI*0.5);
                self.barrageBtn.frame = CGRectMake(10, BMUI_SCREEN_HEIGHT - BMUI_HOME_INDICATOR_HEIGHT - 40 - 10, 40, 40);
                
                self.raiseHandsBtn.transform = CGAffineTransformMakeRotation(M_PI*0.5);
                self.raiseHandsBtn.frame = CGRectMake(self.fullScreenBtn.bm_left - 40 - 20, self.fullScreenBtn.bm_top, 40, 40);
                
                self.playMp3ImageView.bm_origin = CGPointMake(15, 70);
                
                [self.teacherPlaceLab bm_centerHorizontallyInSuperViewWithTop:self.liveImageView.bm_height-80];
                
                [self setNeedsStatusBarAppearanceUpdate];
            }];
        }
            break;
        case UIDeviceOrientationLandscapeRight:
        {
#warning setDeviceOrientation
            //[[YSLiveManager shareInstance] setDeviceOrientation:UIDeviceOrientationLandscapeRight];
            [UIView animateWithDuration:0.25 animations:^{
                
                self.isFullScreen = YES;
                self.barrageStart = YES;
                self.liveBgView.transform = CGAffineTransformMakeRotation(-M_PI*0.5);
                self.liveBgView.frame = CGRectMake(0, 0, BMUI_SCREEN_WIDTH, BMUI_SCREEN_HEIGHT);
                
                self.returnBtn.transform = CGAffineTransformMakeRotation(-M_PI*0.5);
                self.returnBtn.frame = CGRectMake(25, BMUI_SCREEN_HEIGHT -  BMUI_HOME_INDICATOR_HEIGHT - 10 - 40, 40, 40);
                
//                self.roomIDLabel.transform = CGAffineTransformMakeRotation(-M_PI*0.5);
//                self.roomIDLabel.frame = CGRectMake(25, 0, 26, 120);
//                self.roomIDLabel.bm_bottom = self.returnBtn.bm_top - 7;
                
                self.barrageManager.renderView.frame = CGRectMake(0, 70, BMUI_SCREEN_HEIGHT, BMUI_SCREEN_WIDTH-70-55);
                //self.barrageManager.renderView.hidden = NO;
                
                self.fullScreenBtn.transform = CGAffineTransformMakeRotation(-M_PI*0.5);
                self.fullScreenBtn.frame = CGRectMake(BMUI_SCREEN_WIDTH - 20 - 40 ,BMUI_STATUS_BAR_HEIGHT + 10 , 40, 40);
                
                self.barrageBtn.transform = CGAffineTransformMakeRotation(-M_PI*0.5);
                self.barrageBtn.frame = CGRectMake(BMUI_SCREEN_WIDTH - 20 - 40, CGRectGetMaxY(self.fullScreenBtn.frame) + 10, 40, 40);

                self.playMp3ImageView.bm_origin = CGPointMake(BMUI_SCREEN_WIDTH - 70 , BMUI_SCREEN_HEIGHT - BMUI_STATUS_BAR_HEIGHT - BMUI_HOME_INDICATOR_HEIGHT - 15);
                
                [self.teacherPlaceLab bm_centerHorizontallyInSuperViewWithTop:self.liveImageView.bm_height-80];
                
                [self setNeedsStatusBarAppearanceUpdate];
            }];
        }
            break;
            
        default:
            break;
    }
}

- (void)setMp4InterfaceOrientation:(UIInterfaceOrientation)orientation
{
    //UIDeviceOrientation orientation = UIDeviceOrientationLandscapeLeft;//[UIDevice currentDevice].orientation;
    switch (orientation)
    {
        case UIDeviceOrientationPortrait:
        {
            [UIView animateWithDuration:0.25 animations:^{
                
                self.isMp4FullScreen = NO;
                self.mp4BgView.transform = CGAffineTransformMakeRotation(0);
                //self.mp4BgView.frame = CGRectMake(0, self.view.bm_height-self.m_ScrollPageView.bm_height, UI_SCREEN_WIDTH, self.m_ScrollPageView.bm_height);
                
                [self.mp4BgView removeFromSuperview];
                [self.m_ScrollPageView.scrollView addSubview:self.mp4BgView];
                self.mp4BgView.frame = self.m_ScrollPageView.bounds;
                
                self.mediaMarkView.frame = self.mp4BgView.bounds;
                self.mp4FullScreenBtn.frame = CGRectMake(BMUI_SCREEN_WIDTH - 15 - 40, self.mp4BgView.bm_height - 15 - 40, 40, 40);
                self.mp4FullScreenBtn.selected = NO;
                
                
                [self setNeedsStatusBarAppearanceUpdate];
            }];
        }
            break;
        case UIDeviceOrientationLandscapeLeft:
        {
            [UIView animateWithDuration:0.25 animations:^{
                
                self.isMp4FullScreen = YES;
                self.mp4BgView.transform = CGAffineTransformMakeRotation(M_PI*0.5);
                
                [self.mp4BgView removeFromSuperview];
                [self.view addSubview:self.mp4BgView];
                self.mp4BgView.frame = CGRectMake(0, 0, BMUI_SCREEN_WIDTH, BMUI_SCREEN_HEIGHT);
                
                self.mediaMarkView.frame = self.mp4BgView.bounds;
                self.mp4FullScreenBtn.frame = CGRectMake(BMUI_SCREEN_HEIGHT - 15 - 40, 15, 40, 40);
                self.mp4FullScreenBtn.selected = YES;
                
                [self setNeedsStatusBarAppearanceUpdate];
            }];
        }
            break;
        case UIDeviceOrientationLandscapeRight:
        {
            [UIView animateWithDuration:0.25 animations:^{
                
                self.isMp4FullScreen = YES;
                self.mp4BgView.transform = CGAffineTransformMakeRotation(-M_PI*0.5);
                
                [self.mp4BgView removeFromSuperview];
                [self.view addSubview:self.mp4BgView];
                self.mp4BgView.frame = CGRectMake(0, 0, BMUI_SCREEN_WIDTH, BMUI_SCREEN_HEIGHT);
                
                self.mediaMarkView.frame = self.mp4BgView.bounds;
                self.mp4FullScreenBtn.frame = CGRectMake(BMUI_SCREEN_HEIGHT - 15 - 40, 15, 40, 40);
                self.mp4FullScreenBtn.selected = YES;
                
                [self setNeedsStatusBarAppearanceUpdate];
            }];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark -
#pragma mark  举手相关

- (UIButton *)raiseHandsBtn
{
    if (!_raiseHandsBtn)
    {
        CGFloat raiseHandWH = 40;
        self.raiseHandsBtn = [[UIButton alloc]initWithFrame:CGRectMake(BMUI_SCREEN_WIDTH-40-15, self.fullScreenBtn.bm_bottom+15, raiseHandWH, raiseHandWH)];
        [self.raiseHandsBtn setBackgroundColor: UIColor.clearColor];
        [self.raiseHandsBtn setImage:YSSkinElementImage(@"live_raiseHand_time", @"iconNor") forState:UIControlStateNormal];
        [self.raiseHandsBtn setImage:YSSkinElementImage(@"live_raiseHand_time", @"iconSel") forState:UIControlStateHighlighted];

        self.raiseHandsBtn.hidden = YES;
        
        [self.raiseHandsBtn addTarget:self action:@selector(raiseHandsButtonTouchDown) forControlEvents:UIControlEventTouchDown];
        [self.raiseHandsBtn addTarget:self action:@selector(raiseHandsButtonTouchUp) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];

        UIImageView * raiseMaskImage = [[UIImageView alloc]initWithFrame:self.raiseHandsBtn.frame];
        raiseMaskImage.animationImages = @[YSSkinElementImage(@"live_raiseHand_time", @"iconNor3"),YSSkinElementImage(@"live_raiseHand_time", @"iconNor2"),YSSkinElementImage(@"live_raiseHand_time", @"iconNor1")];
        raiseMaskImage.animationDuration = 3.0;
        raiseMaskImage.animationRepeatCount = 0;
        self.raiseMaskImage = raiseMaskImage;
        [self.view addSubview:raiseMaskImage];
        raiseMaskImage.userInteractionEnabled = NO;
        raiseMaskImage.hidden = YES;
        
        NSString * tipStr = YSLocalized(@"Label.RaisingHandsTip");
        CGFloat tipStrWidth=[tipStr boundingRectWithSize:CGSizeMake(1000, 16) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10]} context:nil].size.width;
        
        UILabel * remarkLab = [[UILabel alloc]initWithFrame:CGRectMake(self.raiseHandsBtn.bm_originX - tipStrWidth - 15 - 5, 0, tipStrWidth + 15, 16)];
        remarkLab.bm_centerY = self.raiseHandsBtn.bm_centerY;
        remarkLab.text = YSLocalized(@"Label.RaisingHandsTip");
        remarkLab.backgroundColor = YSSkinDefineColor(@"defaultTitleColor");
        remarkLab.font = UI_FONT_10;
        remarkLab.textColor = YSSkinDefineColor(@"login_placeholderColor");
        remarkLab.textAlignment = NSTextAlignmentCenter;
        remarkLab.layer.cornerRadius = 16/2;
        remarkLab.layer.masksToBounds = YES;
        remarkLab.hidden = YES;
        [self.view addSubview:remarkLab];
        self.remarkLab = remarkLab;
    }
    return _raiseHandsBtn;
}

///学生收到RaiseHandStart展示举手按钮
- (void)handleSignalingAllowEveryoneRaiseHand
{
    self.raiseHandsBtn.hidden = NO;
}

///举手
- (void)raiseHandsButtonTouchDown
{
    self.remarkLab.text = YSLocalized(@"Label.RaisingHandsTip");
    self.remarkLab.hidden = NO;
    
    self.downTime = [NSDate date].timeIntervalSince1970;
    
    [self.liveManager sendSignalingsStudentToRaiseHandWithModify:0];
    
    [self.liveManager setPropertyOfUid:YSCurrentUser.peerID tell:YSRoomPubMsgTellAll propertyKey:sYSUserRaisehand value:@(true)];
}

///取消举手
- (void)raiseHandsButtonTouchUp
{
    self.upTime = [NSDate date].timeIntervalSince1970;
    
    if (self.upTime - self.downTime <= 2)
    {
        self.raiseMaskImage.hidden = NO;
        [self.raiseMaskImage startAnimating];
        self.raiseHandsBtn.userInteractionEnabled = NO;
        self.raiseHandsBtn.hidden = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.raiseMaskImage stopAnimating];
            self.remarkLab.hidden = YES;
            self.raiseMaskImage.hidden = YES;
            self.raiseHandsBtn.hidden = NO;
            self.raiseHandsBtn.userInteractionEnabled = YES;
            [self.liveManager sendSignalingsStudentToRaiseHandWithModify:1];
            [self.liveManager setPropertyOfUid:YSCurrentUser.peerID tell:YSRoomPubMsgTellAll propertyKey:sYSUserRaisehand value:@(false)];
        });
    }
    else
    {
        self.remarkLab.hidden = YES;
        self.raiseMaskImage.hidden = YES;
        self.raiseHandsBtn.userInteractionEnabled = YES;
        [self.liveManager sendSignalingsStudentToRaiseHandWithModify:1];
        [self.liveManager setPropertyOfUid:YSCurrentUser.peerID tell:YSRoomPubMsgTellAll propertyKey:sYSUserRaisehand value:@(false)];
    }
}


@end
