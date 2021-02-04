//
//  YSMainVC.m
//  YSLive
//
//  Created by jiang deng on 2019/10/14.
//  Copyright © 2019 FS. All rights reserved.
//

#import "YSMainVC.h"
#import <objc/message.h>
#if YSSDK
#import "YSSDKManager.h"
#else
#import "AppDelegate.h"
#endif

#import <CloudHubWhiteBoardKit/CloudHubWhiteBoardKit+Session.h>

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

#import "SCVideoView.h"

#import "SCEyeCareView.h"
#import "SCEyeCareWindow.h"

#import "YSLiveLevelView.h"

#import "YSWarmVideoView.h"


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
}

/// 原keywindow
@property(nonatomic, weak) UIWindow *previousKeyWindow;
/// 护眼提醒
@property (nonatomic, strong) SCEyeCareView *eyeCareView;
/// 护眼提醒window
@property (nonatomic, strong) SCEyeCareWindow *eyeCareWindow;


/// 视频ratio 16:9
//@property (nonatomic, assign) BOOL isWideScreen;

/// 固定UserId
//@property (nonatomic, strong) NSString *userId;

@property (nonatomic, strong) BMScrollPageSegment *m_SegmentBar;
@property (nonatomic, strong) BMScrollPageView *m_ScrollPageView;


/// 直播视图
/// 主播的视频view的高度
@property (nonatomic, assign) CGFloat teacherVideoHeight;

/// 主视频容器
@property (nonatomic, strong) YSLiveLevelView *levelView;

/// 主播视频背景
@property (nonatomic, strong) UIImageView *teacherBgMaskView;
/// 主播的视频view
@property (nonatomic, strong) YSFloatView *teacherFloatView;
@property (nonatomic, strong) UIView *teacherVideoView;
/// 主播视频蒙版
@property (nonatomic, strong) UIImageView *teacherMaskView;
/// 学生视频容器
@property (nonatomic, strong) UIView *studentVideoBgView;

/// 老师占位图中是否上课的提示
@property (nonatomic, strong) UILabel *teacherPlaceLabel;

/// 返回按钮
@property (nonatomic, strong) UIButton *returnBtn;

/// 弹幕按钮
@property (nonatomic, strong) UIButton *barrageBtn;
/// 弹幕
@property (nonatomic, strong) YSBarrageManager *barrageManager;
/// 是否开启弹幕
@property (nonatomic, assign) BOOL barrageStart;

/// 全屏按钮
@property (nonatomic, strong) UIButton *fullScreenBtn;
/// 是否全屏
@property (nonatomic, assign) BOOL isFullScreen;

/// 房间号
//@property (nonatomic, strong) UILabel *roomIDLabel;
/// Mp3播放动画
@property (nonatomic, strong) UIImageView *playMp3ImageView;

/// Mp4

@property (nonatomic, strong) YSFloatView *mp4BgView;
@property (nonatomic, strong) UIView *mp4View;
/// 是否mp4全屏
@property (nonatomic, assign) BOOL isMp4FullScreen;
/// mp4全屏按钮
@property (nonatomic, strong) UIButton *mp4FullScreenBtn;

/// 白板视频标注视图
@property (nonatomic, strong) CHWBMediaMarkView *mediaMarkView;
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
@property (nonatomic, strong) YSSignedAlertView *signedAlert;
/// 没创建聊天页面前接收到的消息列表
@property (nonatomic, strong) NSMutableArray<CHChatMessageModel *>  *messageBeforeList;
/// 没创建提问页面前接收到的提问列表
@property (nonatomic, strong) NSMutableArray *questionBeforeArr;
/// 抽奖弹窗
@property (nonatomic, strong) YSPrizeAlertView *prizeAlert;

/// 当前房间播放视频Id
//@property (nonatomic, strong) NSString *roomVideoPeerID;
/// 是否正在播放视频
//@property (nonatomic, assign) BOOL showRoomVideo;

///私聊列表
@property (nonatomic, strong) NSMutableArray<CHRoomUser *>  *memberList;
/// 举手按钮
@property(nonatomic, strong) UIButton *raiseHandsBtn;

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

///暖场视频链接
@property (nonatomic, copy) NSString *warmUrl;

///暖场视频
@property (nonatomic, strong) YSWarmVideoView *warmVideoView;

///暖场视频的上层视频View
@property (nonatomic, strong) UIView *warmView;

/// 上部窗口视频流
@property (nonatomic, strong) NSString *currentTopStreamId;

@end

@implementation YSMainVC

- (void)dealloc
{
    [_liveCallRollSigninTask cancel];
    _liveCallRollSigninTask = nil;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideToolBtns) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideMp4FullScreenBtn) object:nil];
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
    self.bm_CanBackInteractive = NO;
    self.barrageStart = YES;
    if (self.isWideScreen)
    {
        self.teacherVideoHeight = BMUI_SCREEN_WIDTH * 9/16;
    }
    else
    {
        self.teacherVideoHeight = BMUI_SCREEN_WIDTH * 3/4;
    }
    
    self.lessonDataSource = [[NSMutableArray alloc] initWithCapacity:0];
    self.questionBeforeArr = [NSMutableArray array];
    self.messageBeforeList = [NSMutableArray array];
    
    self.mediaMarkSharpsDatas = [[NSMutableArray alloc] init];
    
    [self creatLessonDetail];
    
    [self setupSegment];// 页签Segment
    
    [self setupLevelView];

    [self setupBarrage];
    
    [self makeMp3Animation];
    [self setupMp4UI];
        
    
    [self addControlMainVideoAudioView];
}

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
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        // 如果是全屏，点击按钮进入小屏状态
        [self changeTopVideoToOriginalFrame];

    }
    else
    {
        BMWeakSelf
        [BMAlertView ys_showAlertWithTitle:YSLocalized(@"Prompt.Quite") message:nil cancelTitle:YSLocalized(@"Prompt.Cancel") otherTitle:YSLocalized(@"Prompt.OK") completion:^(BOOL cancelled, NSInteger buttonIndex) {
            // 关闭页面
            if (buttonIndex == 1)
            {
                [BMProgressHUD bm_showHUDAddedTo:weakSelf.view animated:YES];
                [weakSelf.liveManager leaveRoom:nil];
            }
        }];
    }
}

- (void)setupSegment
{
    // 切换视图
    self.m_SegmentBar = [[BMScrollPageSegment alloc] initWithFrame:CGRectMake(0, self.teacherVideoHeight, BMUI_SCREEN_WIDTH, PAGESEGMENT_HEIGHT)];
    [self.view addSubview:_m_SegmentBar];
    self.m_SegmentBar.backgroundColor = YSSkinDefineColor(@"Color3");
    self.m_SegmentBar.showMore = NO;
    self.m_SegmentBar.equalDivide = YES;
    self.m_SegmentBar.moveLineColor = YSSkinDefineColor(@"Color4");
    self.m_SegmentBar.showBottomLine = NO;
    self.m_SegmentBar.titleColor = YSSkinDefineColor(@"PlaceholderColor");
    self.m_SegmentBar.titleSelectedColor = YSSkinDefineColor(@"Color4");
    self.m_SegmentBar.showGapLine = NO;
    // 内容视图
    self.m_ScrollPageView = [[BMScrollPageView alloc] initWithFrame:CGRectMake(0, self.teacherVideoHeight + PAGESEGMENT_HEIGHT, BMUI_SCREEN_WIDTH, BMUI_SCREEN_HEIGHT - self.teacherVideoHeight - PAGESEGMENT_HEIGHT) withScrollPageSegment:self.m_SegmentBar];
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

- (void)setupLevelView
{
    self.levelView = [[YSLiveLevelView alloc] initWithFrame:CGRectMake(0, 0, BMUI_SCREEN_WIDTH, self.teacherVideoHeight)];
    self.levelView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.levelView];
    
    self.teacherBgMaskView = [[UIImageView alloc] initWithFrame:self.levelView.bounds];
    self.teacherBgMaskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.teacherBgMaskView.contentMode = UIViewContentModeCenter;
    self.teacherBgMaskView.backgroundColor = YSSkinDefineColor(@"Color9");
    self.teacherBgMaskView.image = YSSkinDefineImage(@"live_main_notclassbeging");
    self.teacherBgMaskView.userInteractionEnabled = YES;
    [self.levelView.bgView addSubview:self.teacherBgMaskView];
    self.teacherBgMaskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.levelView.bgView.backgroundColor = YSSkinDefineColor(@"Color2");
    /// 主播的视频view
    /// 老师视频容器
    self.teacherFloatView = [[YSFloatView alloc] initWithFrame:self.levelView.bounds];
    self.teacherFloatView.backgroundColor = [UIColor clearColor];
    self.teacherFloatView.showWaiting = NO;
    //self.levelView.liveView.backgroundColor = YSSkinDefineColor(@"ToolBgColor");
    [self.levelView.liveView addSubview:self.teacherFloatView];
    
    self.teacherVideoView = [[UIView alloc] initWithFrame:self.teacherFloatView.bounds];
    self.teacherVideoView.backgroundColor = [UIColor clearColor];
    [self.teacherFloatView showWithContentView:self.teacherVideoView];
    self.teacherFloatView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    self.teacherMaskView = [[UIImageView alloc] initWithFrame:self.levelView.bounds];
    self.teacherMaskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.teacherMaskView.contentMode = UIViewContentModeCenter;
    self.teacherMaskView.backgroundColor = YSSkinDefineColor(@"Color9");
    self.teacherMaskView.image = YSSkinDefineImage(@"live_main_stopvideo");
    [self.levelView.maskView addSubview:self.teacherMaskView];
    self.teacherMaskView.userInteractionEnabled = YES;
    self.teacherMaskView.hidden = YES;
    self.teacherMaskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    NSString *text = YSLocalized(@"Label.AnchorState");
    CGSize labelSize = [text bm_sizeToFitWidth:self.teacherBgMaskView.bm_width withFont:UI_FONT_12];
    UILabel *placeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelSize.width+20, 16)];
    placeLabel.text = text;
    placeLabel.textAlignment = NSTextAlignmentCenter;
    placeLabel.backgroundColor = YSSkinDefineColor(@"JurisdictionCheckFail");
    placeLabel.textColor = UIColor.whiteColor;
    placeLabel.layer.cornerRadius = 8.0f;
    placeLabel.layer.masksToBounds = YES;
    placeLabel.font = UI_FONT_12;
    placeLabel.numberOfLines = 1;
    placeLabel.hidden = YES;
    [self.teacherBgMaskView addSubview:placeLabel];
    self.teacherPlaceLabel = placeLabel;
    
    [self.teacherPlaceLabel bm_centerHorizontallyInSuperViewWithTop:self.teacherBgMaskView.bm_height-50];

    UIControl *control = [[UIControl alloc] initWithFrame:self.levelView.toolsView.bounds];
    control.backgroundColor = [UIColor clearColor];
    [control addTarget:self action:@selector(levelViewClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.levelView.bgView addSubview:control];
    control.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self setupVideoBackgroud];
    
    [self setupBarrage];
    
    [self setupToolsView];
    
    [self.levelView.toolsView addSubview:self.raiseHandsBtn];

    [self performSelector:@selector(hideToolBtns) withObject:nil afterDelay:5.0f];
}

// 上台视频背景容器
- (void)setupVideoBackgroud
{
    /// 学生视频容器
    UIView *studentVideoBgView = [[UIView alloc] init];
    studentVideoBgView.backgroundColor = [UIColor clearColor];
    [self.levelView.studentLiveView addSubview:studentVideoBgView];
    self.levelView.studentVideoBgView = studentVideoBgView;
    studentVideoBgView.frame = CGRectMake(0, self.teacherVideoHeight - platformVideoHeight - VIDEOVIEW_HORIZON_GAP , BMUI_SCREEN_WIDTH, platformVideoHeight);
    self.studentVideoBgView = studentVideoBgView;
}

// 字幕
- (void)setupBarrage
{
    self.barrageManager = [[YSBarrageManager alloc] init];
    [self.levelView.barrageView addSubview:self.barrageManager.renderView];
    self.barrageManager.renderView.frame = CGRectMake(0, 40, self.levelView.barrageView.bm_width, self.levelView.barrageView.bm_height-(self->platformVideoHeight) - 40);
    self.barrageManager.renderView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

/// 设置按钮
- (void)setupToolsView
{
    self.returnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.returnBtn setImage:YSSkinElementImage(@"live_lesson_return", @"iconNor") forState:UIControlStateNormal];
    self.returnBtn.frame = CGRectMake(10, BMUI_STATUS_BAR_HEIGHT, 40, 40);
    [self.levelView.toolsAutoHideView addSubview:self.returnBtn];
    [self.returnBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    self.returnBtn.bm_ActionEdgeInsets = UIEdgeInsetsMake(-5, -5, -5, -5);
    
    self.fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.levelView.toolsAutoHideView addSubview:self.fullScreenBtn];
    [self.fullScreenBtn setImage:YSSkinElementImage(@"live_lesson_full", @"iconNor") forState:UIControlStateNormal];
    self.fullScreenBtn.frame = CGRectMake(self.levelView.toolsAutoHideView.bm_width - 15 - 40, BMUI_STATUS_BAR_HEIGHT, 40, 40);
    [self.fullScreenBtn addTarget:self action:@selector(fullScreenBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.barrageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.levelView.toolsAutoHideView addSubview:self.barrageBtn];
    [self.barrageBtn setImage:YSSkinElementImage(@"live_lesson_barrage", @"iconNor") forState:UIControlStateNormal];
    self.barrageBtn.frame = CGRectMake(self.levelView.toolsAutoHideView.bm_width - 15 - 40, self.fullScreenBtn.bm_bottom + 10, 40, 40);
    [self.barrageBtn addTarget:self action:@selector(barrageBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.barrageBtn.hidden = YES;
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
    UIControl* controlBackMaskView = [[UIControl alloc]initWithFrame:self.view.bounds];
    controlBackMaskView.backgroundColor = UIColor.clearColor;
    self.controlBackMaskView = controlBackMaskView;
    [self.view addSubview:controlBackMaskView];
    [controlBackMaskView addTarget:self action:@selector(clickToHideControl) forControlEvents:UIControlEventTouchUpInside];
    
    controlBackMaskView.hidden = YES;
    
    UIView * controlBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 90, 40)];
    controlBackView.backgroundColor = YSSkinDefineColor(@"Color2");
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
- (void)updataVideoPopViewStateWithSourceId:(NSString *)sourceId
{
    if (YSCurrentUser.audioMute == CHSessionMuteState_Mute)
    {
        self.audioBtn.selected = NO;
    }
    else
    {
        self.audioBtn.selected = YES;
    }

    if ([YSCurrentUser getVideoMuteWithSourceId:sourceId] == CHSessionMuteState_Mute)
    {
        self.videoBtn.selected = NO;
    }
    else
    {
        self.videoBtn.selected = YES;
    }
        
    //没有摄像头、麦克风权限时的显示禁用状态
    if (YSCurrentUser.afail == CHDeviceFaultNone)
    {
        self.audioBtn.enabled = YES;
    }
    else
    {
        self.audioBtn.enabled = NO;
    }
    
    if ([YSCurrentUser getVideoVfailWithSourceId:sourceId] == CHDeviceFaultNone)
    {
        self.videoBtn.enabled = YES;
    }
    else
    {
        self.videoBtn.enabled = NO;
    }
}

///创建button
- (BMImageTitleButtonView *)creatButtonWithTitle:(NSString *)title selectTitle:(NSString *)selectTitle imageName:(NSString *)imageName selectImageName:(NSString *)selectImageName
{
    BMImageTitleButtonView * button = [[BMImageTitleButtonView alloc]init];
    [button addTarget:self action:@selector(userBtnsClick:) forControlEvents:UIControlEventTouchUpInside];
    button.textNormalColor = YSSkinDefineColor(@"Color3");
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

- (void)clickToHideControl
{
    self.controlBackMaskView.hidden = YES;
}

- (void)userBtnsClick:(UIButton *)sender
{
    CHSessionMuteState muteState = CHSessionMuteState_UnMute;
    
    switch (sender.tag) {
        case 0:
        {//关闭音频
            if (sender.selected)
            {//当前是打开音频状态
                muteState = CHSessionMuteState_Mute;
            }
            [YSCurrentUser sendToChangeAudioMute:muteState];
            sender.selected = !sender.selected;
        }
            break;
        case 1:
        {//关闭视频
            if (sender.selected)
            {//当前是打开视频状态
                muteState = CHSessionMuteState_Mute;
            }
            
            [YSCurrentUser sendToChangeVideoMute:muteState WithSourceId:sCHUserDefaultSourceId];
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
    CHRoomUser * userModel = videoView.roomUser;
    if (videoView.roomUser.peerID != YSCurrentUser.peerID || userModel.publishState == CHUser_PublishState_DOWN)
    {
        return;
    }
    
    CGRect frame = [self.studentVideoBgView convertRect:videoView.frame toView:self.controlBackMaskView];
    
//    self.controlBackView.center = CGPointMake(frame.size.width/2 + frame.origin.x, frame.size.height/2 + frame.origin.y);
    self.controlBackMaskView.hidden = NO;
    [self updataVideoPopViewStateWithSourceId:videoView.sourceId];
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

//2.返回支持的旋转方向
//iPhone设备上，默认返回值UIInterfaceOrientationMaskAllButUpSideDwon
//iPad设备上，默认返回值是UIInterfaceOrientationMaskAll
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
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

- (void)makeMp3Animation
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, self.teacherFloatView.bm_bottom - 70, 55, 55)];
    
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
        self.teacherBgMaskView.hidden = YES;
        
        if (self.shareDesktop)
        {
            self.teacherMaskView.hidden = YES;
        }
        else
        {
            CHPublishState publishState = self.liveManager.teacher.publishState;
            NSString *sourceId = [self.liveManager.teacher getFirstVideoSourceId];
            if ([sourceId bm_isNotEmpty])
            {
                if ([self.liveManager.teacher getVideoMuteWithSourceId:sourceId] == CHSessionMuteState_UnMute)
                {
                    self.teacherMaskView.hidden = YES;
                }
                else
                {
                    self.teacherMaskView.hidden = NO;
                    
                    if (publishState == CHUser_PublishState_DOWN)
                    {
                        self.teacherMaskView.image = YSSkinDefineImage(@"live_main_waitingvideo");
                    }
                    else
                    {
                        self.teacherMaskView.image = YSSkinDefineImage(@"live_main_stopvideo");
                    }
                }
            }
            else
            {
                self.teacherMaskView.hidden = NO;
                self.teacherMaskView.image = YSSkinDefineImage(@"live_main_stopvideo");
            }
        }
    }
    else
    {
        self.teacherBgMaskView.hidden = NO;
    }
}

- (void)freshContentView
{
    [self videoViewsSequence];
    
    if (self.isFullScreen)
    {
        [self freshVideoGridView];
    }
    else
    {
        [self freshContentVideoView];
    }
}

// 刷新全屏视频布局
- (void)freshVideoGridView
{
    [self.studentVideoBgView bm_removeAllSubviews];
    
    //    CGFloat firstX = (self.videoBackgroud.bm_width - self.videoViewArray.count *platformVideoWidth - VIDEOVIEW_HORIZON_GAP * 5)/2;
    
    for (int i = 1; i <= self.videoSequenceArr.count; i++)
    {
        SCVideoView *videoView = self.videoSequenceArr[i-1];
        [self.studentVideoBgView addSubview:videoView];
        videoView.frame = CGRectMake(self.studentVideoBgView.bm_width - (i * (platformVideoWidth + VIDEOVIEW_HORIZON_GAP)) , 0, platformVideoWidth, platformVideoHeight);
    }
}

// 刷新content视频布局
- (void)freshContentVideoView
{
    [self.studentVideoBgView bm_removeAllSubviews];
    
    CGFloat teacherH = 0.0;
    CGFloat teacherW = 0.0;
    if (self.videoSequenceArr.count <= 2)
    {
        teacherH = self.teacherVideoHeight;
        teacherW = BMUI_SCREEN_WIDTH;
        for (NSInteger i = 1; i <= self.videoSequenceArr.count; i++)
        {
            SCVideoView *videoView = self.videoSequenceArr[i-1];
            [self.studentVideoBgView addSubview:videoView];
            videoView.frame = CGRectMake(self.studentVideoBgView.bm_width - (i * (platformVideoWidth + VIDEOVIEW_HORIZON_GAP)) , 0, platformVideoWidth, platformVideoHeight);
        }
    }
    else
    {
        teacherH = ceil(self.teacherVideoHeight - platformVideoHeight - VIDEOVIEW_HORIZON_GAP * 2) ;
        if (self.isWideScreen)
        {
            teacherW = ceil(teacherH * 16 / 9);
            
        }
        else
        {
            teacherW = ceil(teacherH * 4 / 3);
        }
        
        CGFloat firstX = (self.studentVideoBgView.bm_width - self.videoSequenceArr.count *platformVideoWidth - VIDEOVIEW_HORIZON_GAP * 5)/2;
        for (int i = 0; i < self.videoSequenceArr.count; i++)
        {
            SCVideoView *videoView = self.videoSequenceArr[i];
            [self.studentVideoBgView addSubview:videoView];
            videoView.frame = CGRectMake(firstX  + i * (platformVideoWidth + VIDEOVIEW_HORIZON_GAP) , 0, platformVideoWidth, platformVideoHeight);
        }
    }
    self.teacherMaskView.frame =CGRectMake(0, 0, teacherW, teacherH);
    self.teacherMaskView.bm_centerX = self.levelView.bm_centerX;
    self.teacherFloatView.frame = CGRectMake(0, 0, teacherW, teacherH);
    self.teacherFloatView.bm_centerX = self.levelView.bm_centerX;
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

/// 用户流音量变化
- (void)onRoomAudioVolumeWithSpeakers:(NSArray<CloudHubAudioVolumeInfo *> *)speakers
{
    [super onRoomAudioVolumeWithSpeakers:speakers];
}

/// 开关摄像头
- (void)onRoomCloseVideo:(BOOL)close withUid:(NSString *)uid sourceID:(nullable NSString *)sourceID streamId:(nonnull NSString *)streamId
{
    [super onRoomCloseVideo:close withUid:uid sourceID:sourceID streamId:streamId];
}

/// 开关麦克风
- (void)onRoomCloseAudio:(BOOL)close withUid:(NSString *)uid
{
    [super onRoomCloseAudio:close withUid:uid];
}

/// 收到音视频流
- (void)onRoomStartVideoOfUid:(NSString *)uid sourceID:(nullable NSString *)sourceID streamId:(nullable NSString *)streamId
{
    SCVideoView *videoView = [self getVideoViewWithPeerId:uid andSourceId:sourceID];
        
    videoView.sourceId = sourceID;
    videoView.streamId = streamId;
    
    if (videoView)
    {
        CHRoomUser *roomUser = videoView.roomUser;
        BOOL isVideoMirror = [roomUser.properties bm_boolForKey:sCHUserIsVideoMirror];
        CloudHubVideoMirrorMode videoMirrorMode = CloudHubVideoMirrorModeDisabled;
        if (isVideoMirror)
        {
            videoMirrorMode = CloudHubVideoMirrorModeEnabled;
        }
        [self.liveManager playVideoWithUserId:uid streamID:streamId renderMode:CloudHubVideoRenderModeHidden mirrorMode:videoMirrorMode inView:videoView];
        [videoView freshWithRoomUserProperty:roomUser];
    }
    else
    {
        CHRoomUser *roomUser = [self.liveManager getRoomUserWithId:uid];
        if (!self.shareDesktop && roomUser && roomUser.role == CHUserType_Teacher)
        {
            BOOL isVideoMirror = [roomUser.properties bm_boolForKey:sCHUserIsVideoMirror];
            CloudHubVideoMirrorMode videoMirrorMode = CloudHubVideoMirrorModeDisabled;
            if (isVideoMirror)
            {
                videoMirrorMode = CloudHubVideoMirrorModeEnabled;
            }
            self.currentTopStreamId = streamId;
            [self.liveManager playVideoWithUserId:uid streamID:streamId  renderMode:CloudHubVideoRenderModeHidden mirrorMode:videoMirrorMode inView:self.teacherVideoView];
            
            [self freshMediaView];
        }
    }
}

/// 停止音视频流
- (void)onRoomStopVideoOfUid:(NSString *)uid sourceID:(nullable NSString *)sourceId streamId:(nullable NSString *)streamId
{
    [super onRoomStopVideoOfUid:uid sourceID:sourceId streamId:streamId];
    [self freshMediaView];
}


#pragma mark  添加视频窗口

- (NSMutableArray<SCVideoView *> *)addVideoViewWithPeerId:(NSString *)peerId
{
    NSMutableArray *newVideoViewArray = [super addVideoViewWithPeerId:peerId withMaxCount:PLATFPRM_VIDEO_MAXCOUNT];
    
    [self freshContentView];
    
    return newVideoViewArray;
}

#pragma mark  删除视频窗口

- (SCVideoView *)delVideoViewWithPeerId:(NSString *)peerId andSourceId:(NSString *)sourceId
{
    SCVideoView *delVideoView = [super delVideoViewWithPeerId:peerId andSourceId:sourceId];
    
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
    //[self.view bringSubviewToFront:self.returnBtn];
//
    if (self.isFullScreen)
    {
        self.isFullScreen = NO;
        [self changeTopVideoToOriginalFrame];
    }
//
    [self freshContentView];
}


- (void)onRoomReJoined
{
    [super onRoomReJoined];
    
}
// 已经离开房间
- (void)onRoomLeft
{
    [super onRoomLeft];
    
    // 网络中断尝试失败后退出
    [[BMNoticeViewStack sharedInstance] closeAllNoticeViews];// 清除alert的栈
    //    [self.navigationController popToRootViewControllerAnimated:YES];
    
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

/// 自己被踢出房间
- (void)onRoomKickedOut:(NSInteger)reasonCode
{
    [super onRoomKickedOut:reasonCode];
    
    NSString *reasonString = YSLocalized(@"KickOut.Repeat");
    if (reasonCode)
    {
        reasonString = YSLocalized(@"KickOut.SentOutClassroom");
    }
        
    [BMProgressHUD bm_showHUDAddedTo:self.view animated:YES withDetailText:reasonString delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
}

#pragma mark 用户进入

- (void)onRoomUserJoined:(CHRoomUser *)user isHistory:(BOOL)isHistory
{
    [super onRoomUserJoined:user isHistory:isHistory];

    if (isHistory == NO && self.liveManager.isClassBegin && user.role == CHUserType_Teacher)
    {
        NSString *sourceId = self.liveManager.teacher.sourceListDic.allKeys.firstObject;

        if ([sourceId bm_isNotEmpty] && [user getVideoMuteWithSourceId:sourceId] == CHSessionMuteState_UnMute)
        {
            NSMutableArray *sourceIdsArray = [self.liveManager getUserStreamIdsWithUserId:user.peerID];
            
            if ([sourceIdsArray bm_isNotEmpty])
            {
                self.currentTopStreamId = sourceIdsArray.firstObject;
                [self.liveManager playVideoWithUserId:user.peerID streamID:sourceIdsArray.firstObject renderMode:CloudHubVideoRenderModeHidden mirrorMode:CloudHubVideoMirrorModeDisabled inView:self.teacherVideoView];
            }
        }
        [self freshMediaView];
    }
}

#pragma mark 用户退出

- (void)onRoomUserLeft:(CHRoomUser *)user
{
    [super onRoomUserLeft:user];
    
    if (user.role == CHUserType_Teacher)
    {
        NSMutableArray *streamIdsArray = [self.liveManager getUserStreamIdsWithUserId:user.peerID];
        
        if ([streamIdsArray.firstObject bm_isNotEmpty])
        {
            
            [self.liveManager stopVideoWithUserId:user.peerID streamID:streamIdsArray.firstObject];
            [self freshMediaView];
        }
    }
    else
    {
        NSMutableArray * userVideoVivews = [self.videoViewArrayDic bm_mutableArrayForKey:user.peerID];
        SCVideoView * videoVivew = userVideoVivews.firstObject;
        
        [self delVideoViewWithPeerId:user.peerID andSourceId:videoVivew.sourceId];
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

/// 老师进入
- (void)onRoomTeacherJoined:(BOOL)isHistory;
{
    self.teacherPlaceLabel.hidden = self.liveManager.isClassBegin;
}

/// 老师退出
- (void)onRoomTeacherLeft
{
    self.teacherPlaceLabel.hidden = YES;
}


#pragma mark 用户属性变化

- (void)userPublishstatechange:(CHRoomUser *)roomUser
{
    [super userPublishstatechange:roomUser];
    
    if (roomUser.role == CHUserType_Teacher)
    {
        NSString * streamId = [self.liveManager.userStreamIds_userId bm_mutableArrayForKey:roomUser.peerID].firstObject;
                
        NSString * sourceId = [self.liveManager getSourceIdFromStreamId:streamId];
        
        if ([streamId bm_isNotEmpty] && [roomUser getVideoMuteWithSourceId:sourceId] == CHSessionMuteState_UnMute)
        {
            if (streamId)
            {
                self.currentTopStreamId = streamId;
                [self.liveManager playVideoWithUserId:roomUser.peerID streamID:streamId renderMode:CloudHubVideoRenderModeHidden mirrorMode:CloudHubVideoMirrorModeDisabled inView:self.teacherVideoView];
            }
        }
        else
        {
            [self.liveManager stopVideoWithUserId:roomUser.peerID streamID:streamId];
        }
        
        [self freshMediaView];
        
        return;
    }
    
    if (roomUser.publishState == CHUser_PublishState_UP)
    {
        [self addVideoViewWithPeerId:roomUser.peerID];
    }
    else
    {
        if (!self.liveManager.isClassBegin)
        {
            return;
        }
        
        NSMutableArray * userVideoVivews = [self.videoViewArrayDic bm_mutableArrayForKey:roomUser.peerID];
        SCVideoView * videoVivew = userVideoVivews.firstObject;
        
        [self delVideoViewWithPeerId:roomUser.peerID andSourceId:videoVivew.sourceId];
        [self clickToHideControl];// 隐藏控制按钮
    }
}

- (void)onRoomUserPropertyChanged:(NSString *)userId fromeUserId:(NSString *)fromeUserId properties:(NSDictionary *)properties
{
//    SCVideoView *videoView = [self getVideoViewWithPeerId:userId];
    
    CHRoomUser *roomUser = [self.liveManager getRoomUserWithId:userId];
    
    if (!roomUser)
    {
        return;
    }
    
    // 网络状态 + 设备状态
    if ([properties bm_containsObjectForKey:sCHUserNetWorkState] || [properties bm_containsObjectForKey:sCHUserMic] || [properties bm_containsObjectForKey:sCHUserCameras])
    {
        NSMutableArray * videoViewArr = [self.videoViewArrayDic bm_mutableArrayForKey:userId];
        [videoViewArr.firstObject freshWithRoomUserProperty:roomUser];
    }
    
    // 本人是否被禁言
    if ([properties bm_containsObjectForKey:sCHUserDisablechat])
    {
        if ([userId isEqualToString:self.liveManager.localUser.peerID])
        {
            BOOL disablechat = [properties bm_boolForKey:sCHUserDisablechat];
            self.chaView.chatToolView.everyoneBanChat = disablechat;
            if (disablechat)
            {
                self.chaView.chatToolView.allDisabledChat.text = YSLocalized(@"Prompt.BanChat");
                [self.chaView toHiddenKeyBoard];
            }
        }
    }
    
    // 上台
    if ([properties bm_containsObjectForKey:sCHUserPublishstate])
    {
        [self userPublishstatechange:roomUser];
    }
    
    if ([userId isEqualToString:self.liveManager.localUser.peerID] && self.controlBackMaskView.hidden == NO)
    {
        /// 更新用户的视频按钮状态
        [self updataVideoPopViewStateWithSourceId:sCHUserDefaultSourceId];
    }
}

#pragma mark 切换网络 会收到onRoomJoined

- (void)onRoomJoined
{
    [super onRoomJoined];
    
    if (!self.liveManager.isClassBegin && self.liveManager.roomConfig.hasWarmVideo)
    {
        [self creatWarmUpVideo];
    }
}

#pragma mark 上下课

// 上课
- (void)handleSignalingClassBeginWihIsHistory:(BOOL)isHistory
{
    self.teacherPlaceLabel.hidden = YES;
//    NSString *teacherPeerID = self.liveManager.teacher.peerID;
    CHRoomUser *teacher = self.liveManager.teacher;
    if (teacher)
    {
        NSString * sourceId = teacher.sourceListDic.allKeys.firstObject;
        if ([sourceId bm_isNotEmpty])
        {
            sourceId = sCHUserDefaultSourceId;
        }
        NSString * streamId = [self.liveManager getUserStreamIdsWithUserId:self.liveManager.teacher.peerID].firstObject;
        
        if ([sourceId bm_isNotEmpty] && [teacher getVideoMuteWithSourceId:sourceId] == CHSessionMuteState_UnMute)
        {
            self.currentTopStreamId = streamId;
            [self.liveManager playVideoWithUserId:teacher.peerID streamID:streamId renderMode:CloudHubVideoRenderModeHidden mirrorMode:CloudHubVideoMirrorModeDisabled inView:self.teacherVideoView];
        }
    }

    if (self.warmVideoView)
    {
        [self.liveManager.cloudHubRtcEngineKit stopPlayingMovie:self.warmUrl];
    }
    
    [self freshMediaView];
    
    if (!isHistory)
    {
        [self bringSomeViewToFront];
        [self.progressHUD bm_showAnimated:NO withDetailText:YSLocalized(@"Alert.BeginClass") delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
    }
    
    for (CHRoomUser *roomUser in self.liveManager.userList)
    {
#if 0
        if (needFreshVideoView)
        {
            needFreshVideoView = NO;
            break;
        }
#endif
        
        if (roomUser.role != CHUserType_Teacher)
        {
            NSString *peerID = roomUser.peerID;
            
            if (roomUser.publishState == CHUser_PublishState_UP)
            {
                [self addVideoViewWithPeerId:peerID];
            }
            else
            {
                [self delVideoViewWithPeerId:peerID andSourceId:sCHUserDefaultSourceId];
            }
        }
    }
    
    self.chaView.chatToolView.maskView.hidden = YES;
    self.questionaView.maskView.hidden = YES;
}

// 下课
- (void)handleSignalingClassEndWithText
{
    [self classEndWithText:nil];
}
- (void)classEndWithText:(NSString *)text
{
    [self handleWhiteBordStopMediaFileWithMedia:self.mediaFileModel];
        
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
        [self classEndWithText:YSLocalized(@"Prompt.ClassEndAppointment30")];
    }
    else if([reason isEqualToString:@"All the teachers left the room for more than 10 minutes"])
    {
        [self classEndWithText:YSLocalized(@"Prompt.ClassEndAnchorLeave10")];
    }
}


#pragma mark 房间视频/音频

#if 0
///// 继续播放房间视频
//- (void)handleRoomPlayMediaWithPeerID:(NSString *)peerID
//{
//    if (![peerID isEqualToString:self.liveManager.teacher.peerID])
//    {
//        return;
//    }
//    self.liveBgView.canZoom = NO;
//    self.liveBgView.backScrollView.zoomScale = 1.0;
//
//    self.showRoomVideo = YES;
//#if YSAPP_NEWERROR
//    [self.liveManager playVideoOnView:self.liveView withPeerId:self.roomVideoPeerID renderType:YSRenderMode_adaptive completion:^(NSError *error) {
//    }];
//#endif
//
//    [self freshMediaView];
//}
//
///// 暂停房间视频
//- (void)handleRoomPauseMediaWithPeerID:(NSString *)peerID
//{
//    if (![peerID isEqualToString:self.liveManager.teacher.peerID])
//    {
//        return;
//    }
//
//    self.showRoomVideo = NO;
//#if YSAPP_NEWERROR
//    [self.liveManager stopPlayVideo:self.liveManager.teacher.peerID completion:^(NSError * _Nonnull error) {
//    }];
//#endif
//
//    [self freshMediaView];
//}
//
///// 继续播放房间音频
//- (void)handleRoomPlayAudioWithPeerID:(NSString *)peerID
//{
//    if (![peerID isEqualToString:self.liveManager.teacher.peerID])
//    {
//        return;
//    }
//
//#if YSAPP_NEWERROR
//    [self.liveManager playAudio:self.roomVideoPeerID completion:^(NSError *error) {
//    }];
//#endif
//}
//
///// 暂停房间音频
//- (void)handleRoomPauseAudioWithPeerID:(NSString *)peerID
//{
//    if (![peerID isEqualToString:self.liveManager.teacher.peerID])
//    {
//        return;
//    }
//
//#if YSAPP_NEWERROR
//    [self.liveManager stopPlayAudio:self.roomVideoPeerID completion:^(NSError *error) {
//    }];
//#endif
//    [self freshMediaView];
//}
#endif


#pragma mark 本地movie stream

- (void)handlePlayMovieStreamID:(NSString *)movieStreamID userID:(NSString *)userID
{
    [self.liveManager playVideoWithUserId:userID streamID:movieStreamID renderMode:CloudHubVideoRenderModeFit mirrorMode:CloudHubVideoMirrorModeDisabled inView:self.mp4View];
    
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
- (void)handleStopMovieStreamID:(NSString *)movieStreamID userID:(NSString *)userID
{
    [self.liveManager stopVideoWithUserId:userID streamID:movieStreamID];
    self.fullScreenBtn.enabled = YES;
    self.mp4BgView.hidden = YES;
}
#pragma mark 白板视频/音频

// 播放白板视频/音频
- (void)handleWhiteBordPlayMediaFileWithMedia:(CHSharedMediaFileModel *)mediaModel
{
    if (!mediaModel.isVideo)
    {
        [self onPlayMp3];
    }
    else
    {
        [self.liveManager playVideoWithUserId:mediaModel.senderId streamID:mediaModel.streamId renderMode:CloudHubVideoRenderModeFit mirrorMode:CloudHubVideoMirrorModeDisabled inView:self.mp4View];
        if (mediaModel.pause)
        {
            [self.mp4BgView showMp4PauseView];
        }
        else
        {
            [self.mp4BgView showMp4WaitingView];
        }

        if (self.isFullScreen)
        {
            // 如果是全屏，点击按钮进入小屏状态
            [self changeTopVideoToOriginalFrame];
        }
        self.fullScreenBtn.enabled = NO;
        self.mp4BgView.hidden = NO;
        [self.mp4BgView bm_bringToFront];
        [self.mp4FullScreenBtn bm_bringToFront];
        
        if (self.mediaMarkView)
        {
            [self.mediaMarkView bm_bringToFront];
        }
    }
}

// 停止白板视频/音频
- (void)handleWhiteBordStopMediaFileWithMedia:(CHSharedMediaFileModel *)mediaModel
{
    [self onStopMp3];
    
    if (mediaModel.isVideo)
    {
        [self.liveManager stopVideoWithUserId:mediaModel.senderId streamID:mediaModel.streamId];
        [self.mp4BgView showMp4WaitingView];

        self.fullScreenBtn.enabled = YES;
        self.mp4BgView.hidden = YES;
        [self handleSignalingHideVideoWhiteboard];
    }
}

/// 继续播放白板视频/音频
- (void)handleWhiteBordPlayMediaStream:(CHSharedMediaFileModel *)mediaFileModel
{
    if (!mediaFileModel.isVideo)
    {
        [self onPlayMp3];
    }
    else
    {
        [self.mp4BgView showMp4WaitingView];
    }
}

/// 暂停播放白板视频/音频
- (void)handleWhiteBordPauseMediaStream:(CHSharedMediaFileModel *)mediaFileModel
{
    if (!mediaFileModel.isVideo)
    {
        [self onPauseMp3];
    }
    else
    {
        [self.mp4BgView showMp4PauseView];
    }
}

/// 显示白板视频标注
- (void)handleSignalingShowVideoWhiteboardWithData:(NSDictionary *)data
{
    if (![self.liveManager.whiteBoardManager isOneWhiteBoardView])
    {
        return;
    }
//    if (self.mp4BgView.hidden)
//    {
//        return;
//    }
    
    if (self.mediaMarkView.superview)
    {
        [self.mediaMarkView removeFromSuperview];
    }
    
    NSString *fileId = [data bm_stringForKey:@"fileId"];
    CGFloat videoRatio = [data bm_doubleForKey:@"videoRatio"];
    
    self.mediaMarkView = [[CHWBMediaMarkView alloc] initWithFrame:self.mp4BgView.bounds fileId:fileId];
    [self.mp4BgView addSubview:self.mediaMarkView];
    [self.mp4FullScreenBtn bm_bringToFront];
    
    [self.mediaMarkView freshViewWithSavedSharpsData:self.mediaMarkSharpsDatas videoRatio:videoRatio];
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
    if (self.mediaMarkView.superview)
    {
        [self.mediaMarkView removeFromSuperview];
        self.mediaMarkView = nil;
    }
}

#pragma mark 共享桌面

/// 开始桌面共享 服务端控制与课件视频/音频互斥
- (void)onRoomStartShareDesktopWithUserId:(NSString *)userId sourceID:(nullable NSString *)sourceId streamId:(nonnull NSString *)streamId
{
    self.shareDesktop = YES;
    NSString *userStreamID = [self.liveManager getUserStreamIdsWithUserId:self.liveManager.teacher.peerID].firstObject;
        
    [self.liveManager stopVideoWithUserId:self.liveManager.teacher.peerID streamID:userStreamID];
    
    self.currentTopStreamId = streamId;
    [self.liveManager playVideoWithUserId:userId streamID:streamId renderMode:CloudHubVideoRenderModeFit mirrorMode:CloudHubVideoMirrorModeDisabled inView:self.teacherVideoView];
    
    self.teacherFloatView.canZoom = YES;
    [self freshMediaView];
}

/// 停止桌面共享
- (void)onRoomStopShareDesktopWithUserId:(NSString *)userId sourceID:(nullable NSString *)sourceId streamId:(nonnull NSString *)streamId
{
    self.shareDesktop = NO;
    [self.liveManager stopVideoWithUserId:userId streamID:streamId];
    
    NSString *userStreamID = [self.liveManager getUserStreamIdsWithUserId:self.liveManager.teacher.peerID].firstObject;
    self.currentTopStreamId = userStreamID;
    CloudHubVideoRenderMode renderMode = CloudHubVideoRenderModeHidden;
    if (self.isFullScreen)
    {
        renderMode = CloudHubVideoRenderModeFit;
    }
    [self.liveManager playVideoWithUserId:userId streamID:userStreamID renderMode:renderMode mirrorMode:CloudHubVideoMirrorModeDisabled inView:self.teacherVideoView];
    
    self.teacherFloatView.canZoom = NO;
    self.teacherFloatView.backScrollView.zoomScale = 1.0;
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
    NSTimeInterval time = 0.0f;
    switch (stateType)
    {
        case YSSignCountDownType_ONE:
            time = 1.0f * 60.0f;
            break;
        case YSSignCountDownType_THREE:
            time = 3.0f * 60.0f;
            break;
        case YSSignCountDownType_FIVE:
            time = 5.0f * 60.0f;
            break;
        case YSSignCountDownType_TEN:
            time = 10.0f * 60.0f;
            break;
        case YSSignCountDownType_THIRTY:
            time = 30.0f * 60.0f;
            break;
        default:
            break;
    }
    
    time = time - apartTimeInterval;
    if (time <= 0.0f )
    {
        return;
    }
    // UI更新代码
    BMWeakSelf
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3* NSEC_PER_SEC));
    
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        NSString *signStr = [NSString stringWithFormat:@"%@%@",YSCurrentUser.peerID,callRollId];
        if (![[YSUserDefault getUserSignin] isEqualToString:signStr])
        {
            weakSelf.signedAlert = [YSSignedAlertView showWithTime:time inView:self.view backgroundEdgeInsets:UIEdgeInsetsMake(self.teacherVideoHeight + PAGESEGMENT_HEIGHT, 0, 0, 0) topDistance:0 signedBlock:^{
                [weakSelf sendLiveCallRollSigninWithCallRollId:callRollId];
            }];
        }

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
            
            weakSelf.prizeAlert = [YSPrizeAlertView showPrizeWithStatus:NO inView:weakSelf.view backgroundEdgeInsets:UIEdgeInsetsMake(self.teacherVideoHeight + PAGESEGMENT_HEIGHT, 0, 0, 0) topDistance:0];
        }];
    }
    else
    {
        
        self.prizeAlert = [YSPrizeAlertView showPrizeWithStatus:NO inView:self.view backgroundEdgeInsets:UIEdgeInsetsMake(self.teacherVideoHeight + PAGESEGMENT_HEIGHT, 0, 0, 0) topDistance:0];
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
    [self.liveManager setPropertyOfUid:YSCurrentUser.peerID tell:CHRoomPubMsgTellAll propertyKey:sCHUserDisablechat value:@(isDisable)];
    if (isDisable)
    {
        self.chaView.chatToolView.allDisabledChat.text = YSLocalized(@"Prompt.BanChatInView");
        [self.chaView toHiddenKeyBoard];
    }
}
#pragma mark 接收消息 弹幕

- (void)handleMessageWith:(CHChatMessageModel *)message
{
    if (self.barrageStart && !message.isPersonal)
    {
        YSBarrageTextDescriptor *textDescriptor = [[YSBarrageTextDescriptor alloc] init];
        
        //          textDescriptor.text = message.message;
        NSArray *colors = @[@"#FFFFFF",@"#FF7D7D",@"#82ABEC",@"#FB8B2C",@"#5ABEDC"];
        UIColor *color = [UIColor bm_colorWithHexString:colors[arc4random()%colors.count]];
        textDescriptor.attributedText = [message emojiViewWithMessage:message.message color:color font:16.0f];
        textDescriptor.textColor = [UIColor whiteColor];
        textDescriptor.positionPriority = YSBarragePositionLow;
        textDescriptor.textFont = [UIFont systemFontOfSize:16.0];
        textDescriptor.strokeColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        textDescriptor.strokeWidth = -1;
        textDescriptor.animationDuration = arc4random()%5 + 5;
        textDescriptor.barrageCellClass = [YSBarrageTextCell class];
        [self.barrageManager renderBarrageDescriptor:textDescriptor];
    }
    
    if (self.m_SegmentBar.currentIndex != 2 && message.chatMessageType != CHChatMessageType_Tips && message.chatMessageType != CHChatMessageType_ImageTips)
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
    
    if (message.chatMessageType != CHChatMessageType_Tips && message.chatMessageType != CHChatMessageType_ImageTips) {
        if (message.sendUser.role == CHUserType_Teacher)
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
- (void)handleSignalingQuestionResponedWithQuestion:(CHQuestionModel *)question
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
        for (CHQuestionModel * model in self.questionBeforeArr)
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
    if ([text isEqualToString:sCHSignal_LiveLuckDrawResult])
    {
        [self creatLessonDataWithNotice:YSLocalized(@"Alert.Reward.title") type:YSLessonNotifyType_Status timeInterval:timeInterval];
        return;
    }
    
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
    voteModel.isSingle = !multi;
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
    voteModel.isSingle = !multi;
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
#pragma mark  弹幕
- (void)handleSignalingBarrageIsOpen:(BOOL)isOpen
{
    if (isOpen)
    {
        self.barrageBtn.hidden = NO;
        if (self.barrageStart)
        {
            [self.barrageManager start];
        }
    }
    else
    {
        self.barrageBtn.hidden = YES;
        [self.barrageManager stop];
    }
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
            return YSLocalized(@"Label.Document");
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
            [self.liveManager.whiteBoardManager refreshMainWhiteBoard];
                        
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
            
            self.chaView.addChatMember = ^(CHRoomUser * _Nonnull memberModel) {
                BOOL isUserExist = NO;
                for (CHRoomUser *memberUser in weakSelf.memberList)
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

///创建暖场视频
- (void)creatWarmUpVideo
{
    NSString *warmVideoUrl = self.liveManager.whiteBoardManager.cloudHubWhiteBoardKit.warmFileModel.swfpath;

    if ([warmVideoUrl bm_isNotEmpty])
    {
        NSTimeInterval nowTime = [[NSDate new] timeIntervalSince1970];
        double time = self.liveManager.roomModel.startTime - nowTime;
        
        //时间是否在上课前一小时
        if (time < 3600)
        {
            warmVideoUrl = [NSString stringWithFormat:@"%@:%d%@", self.liveManager.whiteBoardManager.cloudHubWhiteBoardKit.docHost, YSLive_Port, warmVideoUrl];
            NSString *tdeletePathExtension = warmVideoUrl.stringByDeletingPathExtension;
            self.warmUrl = [NSString stringWithFormat:@"%@://%@-1.%@", YSLive_Http, tdeletePathExtension, warmVideoUrl.pathExtension];
            
            self.warmVideoView = [[YSWarmVideoView alloc]initWithFrame:CGRectMake(0, BMUI_SCREEN_HEIGHT - self.m_ScrollPageView.bm_height, BMUI_SCREEN_WIDTH, self.m_ScrollPageView.bm_height)];
            
            [self.view addSubview:self.warmVideoView];
            BMWeakSelf
            self.warmVideoView.warmViewFullBtnClick = ^(UIButton * _Nonnull sender) {
                if (sender.selected)
                {
                    weakSelf.warmVideoView.frame = weakSelf.view.bounds;
                    
                    [UIView animateWithDuration:0.25 animations:^{
                        weakSelf.warmView.transform = CGAffineTransformMakeRotation(M_PI*0.5);
                    }];
                }
                else
                {
                    weakSelf.warmVideoView.frame = CGRectMake(0, BMUI_SCREEN_HEIGHT - weakSelf.m_ScrollPageView.bm_height, BMUI_SCREEN_WIDTH, weakSelf.m_ScrollPageView.bm_height);
                    [UIView animateWithDuration:0.25 animations:^{
                        weakSelf.warmView.transform = CGAffineTransformMakeRotation(0);
                    }];
                }
            };
            
            BOOL isCycle = NO;
            //是否循环播放
            if (self.liveManager.roomModel.warmupCycle == CHWarmVideoCycleType_Cycle)
            {
                isCycle = YES;
            }
            
            int iii = [self.liveManager.cloudHubRtcEngineKit startPlayingMovie:self.warmUrl cycle:isCycle view:self.warmVideoView paused:NO];
            
//            NSLog(@"12345self.warmUrl = %@ -- %d",self.warmUrl,iii);
            
            for (UIView *view in weakSelf.warmVideoView.subviews)
            {
                if ([NSStringFromClass([view class]) isEqualToString:@"CloudHubRtcRender"])
                {
                    self.warmView = view;
                }
            }
            [self.warmVideoView.fullBtn bm_bringToFront];
        }
    }
}

- (void)onRoomStopLocalMediaFile:(NSString *)mediaFileUrl
{
    if (self.warmVideoView)
    {
        [self.warmVideoView removeFromSuperview];
        self.warmVideoView = nil;
    }
}


- (void)creatPopover:(UIButton*)popoBtn
{
    self.menuVc.popoverPresentationController.sourceView = popoBtn;
    UIPopoverPresentationController *popover = self.menuVc.popoverPresentationController;
    popover.sourceRect = popoBtn.bounds;
    popover.permittedArrowDirections = UIPopoverArrowDirectionDown;
    popover.delegate = self;
    [self presentViewController:self.menuVc animated:NO completion:nil];///present即可
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
    vc.passTheMemberOfChat = ^(CHRoomUser * _Nonnull memberModel) {
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
                NSDictionary *responseDic = [BMCloudHubUtil convertWithData:responseObject];
                
#ifdef DEBUG
                NSString *responseStr = [[NSString stringWithFormat:@"%@", responseDic] bm_convertUnicode];
                BMLog(@"%@ %@", response, responseStr);
#endif
                [weakSelf liveCallRollSigninRequestFinished:response responseDic:responseDic callRollId:callRollId];
            }
        }];
        [self.liveCallRollSigninTask resume];
    }
}

- (void)liveCallRollSigninRequestFinished:(NSURLResponse *)response responseDic:(NSDictionary *)resDic callRollId:(NSString *)callRollId
{
    BMLog(@"签到-------------%@", resDic);
    
    NSInteger result = [resDic bm_intForKey:@"result"];
    
    if (result == 0)
    {
        NSString *signStr = [NSString stringWithFormat:@"%@%@",YSCurrentUser.peerID,callRollId];
        [YSUserDefault setUserSignin:signStr];
        [self.signedAlert dismiss:nil];
    }
}

- (void)liveCallRollSigninRequestFailed:(NSURLResponse *)response error:(NSError *)error
{
    BMLog(@"签到-------------失败%@", error);
}


#pragma mark -
#pragma mark SEL

- (void)levelViewClicked:(id)sender
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideToolBtns) object:nil];
    
    if (self.levelView.toolsAutoHideView.hidden)
    {
        self.levelView.toolsAutoHideView.hidden = NO;
        [self performSelector:@selector(hideToolBtns) withObject:nil afterDelay:5.0f];
    }
    else
    {
        self.levelView.toolsAutoHideView.hidden = YES;
    }
}

- (void)hideToolBtns
{
    self.levelView.toolsAutoHideView.hidden = YES;
}

- (void)barrageBtnClicked:(UIButton *)btn
{
    self.barrageStart = !self.barrageStart;
    if (self.barrageStart)
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
            [self.liveManager.cloudHubRtcEngineKit setVideoRotation:CloudHubHomeButtonOnBottom];
            
            [UIView animateWithDuration:0.25 animations:^{
                self.isFullScreen = NO;//通过set 方法刷新了视频布局
//                self.barrageStart = NO;
                self.levelView.transform = CGAffineTransformMakeRotation(0);
                self.levelView.frame = CGRectMake(0, 0, BMUI_SCREEN_WIDTH, self.teacherVideoHeight);
                self.teacherFloatView.frame =  self.levelView.bounds;
                self.studentVideoBgView.frame = CGRectMake(0, self.teacherVideoHeight - self->platformVideoHeight - VIDEOVIEW_HORIZON_GAP , BMUI_SCREEN_WIDTH, self->platformVideoHeight);
                [self freshContentVideoView];
                
                self.barrageManager.renderView.frame = CGRectMake(0, 40, self.levelView.barrageView.bm_width, self.levelView.barrageView.bm_height-(self->platformVideoHeight) - 40);
                
                self.returnBtn.frame = CGRectMake(10, BMUI_STATUS_BAR_HEIGHT, 40, 40);
                self.fullScreenBtn.frame = CGRectMake(self.levelView.toolsAutoHideView.bm_width - 15 - 40, BMUI_STATUS_BAR_HEIGHT, 40, 40);
                self.barrageBtn.frame = CGRectMake(self.levelView.toolsAutoHideView.bm_width - 15 - 40, self.fullScreenBtn.bm_bottom + 10, 40, 40);
                self.raiseHandsBtn.frame = CGRectMake(self.levelView.toolsView.bm_width-40-15, self.barrageBtn.bm_bottom + 10, 40, 40);
                self.raiseMaskImage.frame = self.raiseHandsBtn.frame;
                self.remarkLab.frame = CGRectMake(self.raiseHandsBtn.bm_originX - self.remarkLab.bm_width - 15 - 5, self.raiseHandsBtn.bm_centerY - 8, self.remarkLab.bm_width + 15, 16);
                
                self.playMp3ImageView.bm_origin = CGPointMake(15, self.levelView.bm_bottom - 70);
                
                [self.teacherPlaceLabel bm_centerHorizontallyInSuperViewWithTop:self.teacherMaskView.bm_height-50];
                
                NSString *userStreamID = [self.liveManager getUserStreamIdsWithUserId:self.liveManager.teacher.peerID].firstObject;
                if (self.currentTopStreamId && [self.currentTopStreamId isEqualToString:userStreamID])
                {
                    [self.liveManager.cloudHubRtcEngineKit setRemoteRenderMode:userStreamID renderMode:CloudHubVideoRenderModeHidden mirrorMode:CloudHubVideoMirrorModeDisabled];
                }
                
                [self setNeedsStatusBarAppearanceUpdate];
            }];
        }
            break;
        case UIDeviceOrientationLandscapeLeft:
        {
#warning setDeviceOrientation
            //[[YSLiveManager shareInstance] setDeviceOrientation:UIDeviceOrientationLandscapeLeft];
            [self.liveManager.cloudHubRtcEngineKit setVideoRotation:CloudHubHomeButtonOnRight];
            [UIView animateWithDuration:0.25 animations:^{
                
                self.isFullScreen = YES;//通过set 方法刷新了视频布局
//                self.barrageStart = YES;
                self.levelView.transform = CGAffineTransformMakeRotation(M_PI*0.5);
                self.levelView.frame = CGRectMake(0, 0, BMUI_SCREEN_WIDTH, BMUI_SCREEN_HEIGHT);
                self.teacherFloatView.frame =  self.levelView.bounds;
                self.teacherMaskView.frame = self.levelView.maskView.bounds;
                self.studentVideoBgView.frame = CGRectMake(0, BMUI_SCREEN_WIDTH - self->platformVideoHeight - VIDEOVIEW_HORIZON_GAP , BMUI_SCREEN_WIDTH, self->platformVideoHeight);
                self.studentVideoBgView.bm_centerX = self.levelView.liveView.bm_centerX;
                
                self.barrageManager.renderView.frame = CGRectMake(0, 10, BMUI_SCREEN_HEIGHT, BMUI_SCREEN_WIDTH-(self->platformVideoHeight) - 20);
                self.fullScreenBtn.frame = CGRectMake(self.levelView.toolsAutoHideView.bm_width - 15 - 40, BMUI_STATUS_BAR_HEIGHT, 40, 40);
                self.barrageBtn.frame = CGRectMake(self.levelView.toolsAutoHideView.bm_width - 15 - 40, self.fullScreenBtn.bm_bottom + 10, 40, 40);
                
                self.raiseHandsBtn.frame = CGRectMake(self.levelView.toolsView.bm_width-40-15, self.barrageBtn.bm_bottom + 10, 40, 40);
                self.raiseMaskImage.frame = self.raiseHandsBtn.frame;
                self.remarkLab.frame = CGRectMake(self.raiseHandsBtn.bm_originX - self.remarkLab.bm_width - 15 - 5, self.raiseHandsBtn.bm_centerY - 8, self.remarkLab.bm_width + 15, 16);
                
                self.playMp3ImageView.bm_origin = CGPointMake(15, 70);
                
                [self.teacherPlaceLabel bm_centerHorizontallyInSuperViewWithTop:self.teacherMaskView.bm_height-80];
                
                NSString *userStreamID = [self.liveManager getUserStreamIdsWithUserId:self.liveManager.teacher.peerID].firstObject;
                if (self.currentTopStreamId && [self.currentTopStreamId isEqualToString:userStreamID])
                {
                    [self.liveManager.cloudHubRtcEngineKit setRemoteRenderMode:userStreamID renderMode:CloudHubVideoRenderModeFit mirrorMode:CloudHubVideoMirrorModeDisabled];
                }

                [self setNeedsStatusBarAppearanceUpdate];
            }];
        }
            break;
        case UIDeviceOrientationLandscapeRight:
        {
#warning setDeviceOrientation
            /*
            //[[YSLiveManager shareInstance] setDeviceOrientation:UIDeviceOrientationLandscapeRight];
            [self.liveManager.cloudHubRtcEngineKit setVideoRotation:CloudHubHomeButtonOnLeft];
            [UIView animateWithDuration:0.25 animations:^{
                
                self.isFullScreen = YES;
//                self.barrageStart = YES;
                self.teacherFloatView.transform = CGAffineTransformMakeRotation(-M_PI*0.5);
                self.teacherFloatView.frame = CGRectMake(0, 0, BMUI_SCREEN_WIDTH, BMUI_SCREEN_HEIGHT);
                
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
                
                [self.teacherPlaceLabel bm_centerHorizontallyInSuperViewWithTop:self.teacherMaskView.bm_height-80];
                
                [self setNeedsStatusBarAppearanceUpdate];
            }];
             */
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
        self.raiseHandsBtn = [[UIButton alloc]initWithFrame:CGRectMake(BMUI_SCREEN_WIDTH-40-15, BMUI_STATUS_BAR_HEIGHT+40+15, raiseHandWH, raiseHandWH)];
        
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
        [self.levelView.toolsView addSubview:raiseMaskImage];
        raiseMaskImage.userInteractionEnabled = NO;
        raiseMaskImage.hidden = YES;
        
        NSString * tipStr = YSLocalized(@"Label.RaisingHandsTip");
        CGFloat tipStrWidth=[tipStr boundingRectWithSize:CGSizeMake(1000, 16) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10]} context:nil].size.width;
        
        UILabel * remarkLab = [[UILabel alloc]initWithFrame:CGRectMake(self.raiseHandsBtn.bm_originX - tipStrWidth - 15 - 5, 0, tipStrWidth + 15, 16)];
        remarkLab.bm_centerY = self.raiseHandsBtn.bm_centerY;
        remarkLab.text = YSLocalized(@"Label.RaisingHandsTip");
        remarkLab.backgroundColor = YSSkinDefineColor(@"Color4");
        remarkLab.font = UI_FONT_10;
        remarkLab.textColor = YSSkinDefineColor(@"Color2");
        remarkLab.textAlignment = NSTextAlignmentCenter;
        remarkLab.layer.cornerRadius = 16/2;
        remarkLab.layer.masksToBounds = YES;
        remarkLab.hidden = YES;
        [self.levelView.toolsView addSubview:remarkLab];
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
    
    [self.liveManager setPropertyOfUid:YSCurrentUser.peerID tell:CHRoomPubMsgTellAll propertyKey:sCHUserRaisehand value:@(true)];
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
            [self.liveManager setPropertyOfUid:YSCurrentUser.peerID tell:CHRoomPubMsgTellAll propertyKey:sCHUserRaisehand value:@(false)];
        });
    }
    else
    {
        self.remarkLab.hidden = YES;
        self.raiseMaskImage.hidden = YES;
        self.raiseHandsBtn.userInteractionEnabled = YES;
        [self.liveManager sendSignalingsStudentToRaiseHandWithModify:1];
        [self.liveManager setPropertyOfUid:YSCurrentUser.peerID tell:CHRoomPubMsgTellAll propertyKey:sCHUserRaisehand value:@(false)];
    }
}

#pragma mark -
#pragma mark Lazy

- (NSMutableArray<CHRoomUser *> *)memberList
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
                    [weakSelf.chaView.chatToolView.msgTypeBtn setImage:YSSkinElementImage(@"live_chatMessageAllPersional", @"iconNor") forState:UIControlStateNormal];
                    [weakSelf.chaView.chatToolView.msgTypeBtn setImage:YSSkinElementImage(@"live_chatMessageAllPersional", @"iconSel") forState:UIControlStateHighlighted];
                    
                }
                    break;
                case 1:
                {//仅看主播消息
                    weakSelf.chaView.showType = YSMessageShowTypeAnchor;
                    [weakSelf.chaView.chatToolView.msgTypeBtn setImage:YSSkinElementImage(@"live_chatMessageAnchor", @"iconNor") forState:UIControlStateNormal];
                    [weakSelf.chaView.chatToolView.msgTypeBtn setImage:YSSkinElementImage(@"live_chatMessageAnchor", @"iconSel") forState:UIControlStateHighlighted];
                }
                    break;
                case 2:
                {//仅看自己消息
                    weakSelf.chaView.showType = YSMessageShowTypeMain;
                    [weakSelf.chaView.chatToolView.msgTypeBtn setImage:YSSkinElementImage(@"live_chatMessageMine", @"iconNor") forState:UIControlStateNormal];
                    [weakSelf.chaView.chatToolView.msgTypeBtn setImage:YSSkinElementImage(@"live_chatMessageMine", @"iconSel") forState:UIControlStateHighlighted];
                }
                    break;
                    
                default:
                    break;
            }
            [weakMenuVc dismissViewControllerAnimated:YES completion:nil];
        };
        
        self.menuVc.preferredContentSize = CGSizeMake(160, 135);
        self.menuVc.modalPresentationStyle = UIModalPresentationPopover;
    }
    return _menuVc;
}

@end
