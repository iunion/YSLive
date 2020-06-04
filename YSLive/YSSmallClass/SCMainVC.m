//
//  SCMainVC.m
//  YSLive
//
//  Created by fzxm on 2019/11/6.
//  Copyright © 2019 YS. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import "SCMainVC.h"
#import "SCChatView.h"
#import "YSChatMessageModel.h"
#import "SCBrushToolView.h"
#import "SCDrawBoardView.h"
#import "SCChatToolView.h"
#import "SCDrawBoardView.h"
#import "YSEmotionView.h"

//#import "SCTopToolBar.h"
#import "SCTeacherListView.h"

#import "SCAnswerView.h"

#import "YSLiveMediaModel.h"

#import "YSFloatView.h"
#import "SCVideoGridView.h"

#import "YSMediaMarkView.h"

#import "UIAlertController+SCAlertAutorotate.h"
#import "YSLiveApiRequest.h"

#import "SCColorSelectView.h"

#import "YSStudentResponder.h"
#import "YSStudentTimerView.h"

#import "YSControlPopoverView.h"

#import "PanGestureControl.h"
#import "YSToolBoxView.h"

#define USE_FullTeacher             1

#define SCLessonTimeCountDownKey     @"SCLessonTimeCountDownKey"

#define PlaceholderPTag       10

#define DoubleTeacherExpandContractBtnTag          100

//#define MAXVIDEOCOUNT               12

#define GiftImageView_Width         185.0f
#define GiftImageView_Height        224.0f

/// 顶部工具条高
//static const CGFloat kTopToolBar_Height_iPhone = 50.0f;
//static const CGFloat kTopToolBar_Height_iPad = 70.0f;
//#define TOPTOOLBAR_HEIGHT           ([UIDevice bm_isiPad] ? kTopToolBar_Height_iPad : kTopToolBar_Height_iPhone)

/// 一对一多视频最高尺寸
static const CGFloat kVideoView_MaxHeight_iPhone = 100.0f;
static const CGFloat kVideoView_MaxHeight_iPad  = 160.0f;
#define VIDEOVIEW_MAXHEIGHT         ([UIDevice bm_isiPad] ? kVideoView_MaxHeight_iPad : kVideoView_MaxHeight_iPhone)

/// 视频间距
static const CGFloat kVideoView_Gap_iPhone = 4.0f;
static const CGFloat kVideoView_Gap_iPad  = 6.0f;
#define VIDEOVIEW_GAP               ([UIDevice bm_isiPad] ? kVideoView_Gap_iPad : kVideoView_Gap_iPhone)

static const CGFloat kMp3_Width_iPhone = 55.0f;
static const CGFloat kMp3_Width_iPad = 70.0f;
static NSInteger studentPlayerFirst = 0; /// 播放器播放次数限制
#define MP3VIEW_WIDTH               ([UIDevice bm_isiPad] ? kMp3_Width_iPad : kMp3_Width_iPhone)

/// 底部部工具条高
static const CGFloat kBottomToolBar_Height_iPhone = 44.0f;
static const CGFloat kBottomToolBar_Height_iPad = 50.0f;
#define BOTTOMTOOLBAR_HEIGHT           ([UIDevice bm_isiPad] ? kBottomToolBar_Height_iPad : kBottomToolBar_Height_iPhone)
/// 底部部工具条宽
static const CGFloat kBottomToolBar_Width_iPhone = 572.0f;
static const CGFloat kBottomToolBar_Width_iPad = 744.0f;
#define BOTTOMTOOLBAR_WIDTH           ([UIDevice bm_isiPad] ? kBottomToolBar_Width_iPad : kBottomToolBar_Width_iPhone)
/// 底部工具栏右边距
static const CGFloat kBottomToolBar_rightGap_iPhone = 7.0f;
static const CGFloat kBottomToolBar_rightGap_iPad = 16.0f ;
#define BOTTOMTOOLBAR_rightGap        ([UIDevice bm_isiPad] ? kBottomToolBar_rightGap_iPad : kBottomToolBar_rightGap_iPhone)
/// 底部工具栏下边距
static const CGFloat kBottomToolBar_bottomGap_iPhone = 10.0f;
static const CGFloat kBottomToolBar_bottomGap_iPad = 46.0f;
#define BOTTOMTOOLBAR_bottomGap       ([UIDevice bm_isiPad] ? kBottomToolBar_bottomGap_iPad : kBottomToolBar_bottomGap_iPhone)

//聊天视图的高度
#define SCChatViewHeight (BMUI_SCREEN_HEIGHT - self.contentBackgroud.bm_originY - STATETOOLBAR_HEIGHT - BOTTOMTOOLBAR_bottomGap - BOTTOMTOOLBAR_HEIGHT)
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

#define YSStudentResponderCountDownKey @"YSStudentResponderCountDownKey"
#define YSStudentTimerCountDownKey     @"YSStudentTimerCountDownKey"

@interface SCMainVC ()
<
    BMTZImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    UIImagePickerControllerDelegate,
    UITextViewDelegate,
    YSLiveRoomManagerDelegate,
    SCBrushToolViewDelegate,
    SCDrawBoardViewDelegate,
//    SCTopToolBarDelegate,
    UIPopoverPresentationControllerDelegate,
    YSControlPopoverViewDelegate,
    SCVideoViewDelegate,
    SCTeacherListViewDelegate,
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
    
    NSTimeInterval _topbarTimeInterval;
    
    YSLiveRoomLayout defaultRoomLayout;
    
    //BOOL needFreshVideoView;
    NSInteger contestTouchOne;
    
    NSInteger _personListCurentPage;
    NSInteger _personListTotalPage;
    BOOL isMediaPause;
    BOOL isMediaStop;
    BOOL isSearch;
    NSMutableArray *searchArr;
}

/// 房间类型 0:表示一对一教室  非0:表示一多教室
@property (nonatomic, assign) YSRoomTypes roomtype;
/// 视频ratio 16:9
@property (nonatomic, assign) BOOL isWideScreen;

/// 固定UserId
@property (nonatomic, strong) NSString *userId;

/// 标识布局变化的值
@property (nonatomic, assign) YSLiveRoomLayout roomLayout;

/// 奖杯数请求
@property (nonatomic, strong) NSURLSessionDataTask *giftCountTask;

/// 上课时间的定时器
@property (nonatomic, strong) dispatch_source_t topBarTimer;

/// 内容背景
//@property (nonatomic, strong) UIView *contentBackgroud;
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
@property (nonatomic, assign) BOOL isWhitebordFullScreen;
/// 隐藏白板视频布局背景
@property (nonatomic, strong) SCVideoGridView *videoGridView;

/// 默认老师 视频
@property (nonatomic, strong) SCVideoView *teacherVideoView;
/// 1V1 默认老师占位
@property (nonatomic, strong) SCVideoView *teacherPlacehold;
/// 1V1 老师占位图中是否上课的提示
@property (nonatomic, strong) UILabel *teacherPlaceLab ;
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

/// 双击放大视频
@property (nonatomic, strong) YSFloatView *doubleFloatView;
@property (nonatomic, assign) BOOL isDoubleVideoBig;

/// 共享浮动窗口 视频课件
@property (nonatomic, strong) YSFloatView *shareVideoFloatView;
/// 共享视频窗口
@property (nonatomic, strong) UIView *shareVideoView;
/// 白板视频标注视图
@property (nonatomic, strong) YSMediaMarkView *mediaMarkView;
@property (nonatomic, strong) NSMutableArray <NSDictionary *> *mediaMarkSharpsDatas;

@property (nonatomic, strong) UIImageView *playMp3ImageView;
/// 聊天的View
@property(nonatomic,strong)SCChatView *rightChatView;
/// 弹出聊天View的按钮
//@property(nonatomic,strong)UIButton *chatBtn;
/// 左侧工具栏
@property (nonatomic, strong) SCBrushToolView *brushToolView;
/// 画笔工具按钮（控制工具条的展开收起）
@property (nonatomic, strong) UIButton *brushToolOpenBtn;
/// 画笔选择 颜色 大小 形状
@property (nonatomic, strong) SCDrawBoardView *drawBoardView;

/// 答题中
@property (nonatomic, strong) SCAnswerView *answerView;
/// 答题结果
@property (nonatomic, strong) SCAnswerView *answerResultView;
/// 我的答案
@property (nonatomic, strong) NSMutableDictionary *answerMyResultDic;
/// 正确答案
@property (nonatomic, strong) NSString *rightAnswer;//正确答案
/// 聊天输入框工具栏
@property (nonatomic, strong) SCChatToolView *chatToolView;
/// 聊天表情列表View
@property (nonatomic, strong) YSEmotionView *emotionListView;
/// 键盘弹起高度
@property (nonatomic, assign) CGFloat keyBoardH;
///上传图片的用途
@property (nonatomic, assign)SCUploadImageUseType *uploadImageUseType;

/// 举手按钮
@property(nonatomic,strong)UIButton *raiseHandsBtn;
/// 举手按钮上的倒计时蒙版
@property(nonatomic,strong)UIImageView * raiseMaskImage;
/// 举手请长按的提示
@property(nonatomic,strong)UILabel *remarkLab;

@property (nonatomic, strong) YSStudentResponder *responderView;
@property (nonatomic, strong) YSStudentTimerView *studentTimerView;
///音频播放器
@property(nonatomic, strong) AVAudioPlayer *player;
@property(nonatomic, strong) AVAudioSession *session;

/// 当前的焦点视图
@property(nonatomic, strong) SCVideoView *fouceView;
/// 视频控制popoverView
@property(nonatomic, strong) YSControlPopoverView *controlPopoverView;

/// 花名册 课件库
@property(nonatomic, strong) SCTeacherListView *teacherListView;
/// 大并发房间计时器 每两秒获取一次
@property (nonatomic, strong) dispatch_source_t bigRoomTimer;

@property(nonatomic, weak) BMTZImagePickerController *imagePickerController;
/// 当前展示课件数组
@property (nonatomic, strong) NSMutableArray *currentFileList;
/// 当前展示媒体课件
@property (nonatomic, strong) NSString *currentMediaFileID;
@property (nonatomic, assign) YSWhiteBordMediaState currentMediaState;

/// 视频布局时全屏按钮（隐藏顶部工具栏）
@property(nonatomic,strong)UIButton *videoFullScreenBtn;
/// 工具箱
@property(nonatomic, strong) YSToolBoxView *toolBoxView;
@end

@implementation SCMainVC

- (void)dealloc
{
    [self.giftCountTask cancel];
    self.giftCountTask = nil;
    
    if (self.topBarTimer)
    {
        dispatch_source_cancel(self.topBarTimer);
        self.topBarTimer = nil;
    }
    if (self.bigRoomTimer)
    {
        dispatch_source_cancel(self.bigRoomTimer);
        self.bigRoomTimer = nil;
    }
}

- (instancetype)initWithRoomType:(YSRoomTypes)roomType isWideScreen:(BOOL)isWideScreen maxVideoCount:(NSUInteger)maxCount whiteBordView:(UIView *)whiteBordView userId:(nullable NSString *)userId
{
    self = [super initWithWhiteBordView:whiteBordView];
    if (self)
    {
        maxVideoCount = maxCount;
        
        self.roomtype = roomType;
        self.isWideScreen = isWideScreen;
        
        self.userId = userId;
        
        self.mediaMarkSharpsDatas = [[NSMutableArray alloc] init];
        
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
        }
        [self calculateFloatVideoSize];
    }
    return self;
}

/// 获取用户奖杯数
- (void)getGiftCount
{
    BMAFHTTPSessionManager *manager = [BMAFHTTPSessionManager manager];
    NSString *roomId = [YSLiveManager shareInstance].room_Id;
    NSMutableURLRequest *request = [YSLiveApiRequest getGiftCountWithRoomId:roomId peerId:YSCurrentUser.peerID];
    //NSMutableURLRequest *request = [YSLiveApiRequest getGiftCountWithRoomId:roomId peerId:self.userId];
    if (request)
    {
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[
            @"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript",
            @"text/xml", @"image/jpeg", @"image/*"
        ]];
        
        [self.giftCountTask cancel];
        self.giftCountTask = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error)
            {
                BMLog(@"Error: %@", error);
            }
            else
            {
//                NSString *responseStr = [[NSString stringWithFormat:@"%@", responseObject] bm_convertUnicode];
//                BMLog(@"%@ %@", response, responseStr);
                
                NSDictionary *responseDic = [YSLiveUtil convertWithData:responseObject];
                
                if ([responseDic bm_containsObjectForKey:@"result"])
                {
                    NSInteger result = [responseDic bm_intForKey:@"result"];
                    if (result == 0)
                    {
                        NSUInteger giftCount = 0;
                        NSArray *giftInfos = [responseDic bm_arrayForKey:@"giftinfo"];
                        if ([giftInfos bm_isNotEmpty])
                        {
                            for (NSDictionary *giftDic in giftInfos)
                            {
                                NSString *peerId = [giftDic bm_stringTrimForKey:@"receiveid"];
                                if ([peerId isEqualToString:YSCurrentUser.peerID])
                                {
                                    giftCount += [giftDic bm_uintForKey:@"giftnumber" withDefault:0];
                                }
                            }
                        }
                        [[YSLiveManager shareInstance].roomManager changeUserProperty:YSCurrentUser.peerID tellWhom:YSRoomPubMsgTellAll key:sUserGiftNumber value:@(giftCount) completion:nil];
                    }
                }
            }
        }];
        
        [self.giftCountTask resume];
    }
}

/// 设置自己默认画笔颜色
- (void)setCurrentUserPrimaryColor
{
    //YSRoomUser *lastRoomUser = [YSLiveManager shareInstance].userList.lastObject;
    YSRoomUser *lastRoomUser = nil;
    for (NSInteger i = self.videoViewArray.count - 1; i >= 0; i--)
    {
        SCVideoView *lastVideoView = self.videoViewArray[i];
        if (![lastVideoView.roomUser.peerID isEqualToString:YSCurrentUser.peerID])
        {
            lastRoomUser = lastVideoView.roomUser;
            break;
        }
    }
    
    NSArray *colorArray = [SCColorSelectView colorArray];
    NSString *newColorStr;
    if (lastRoomUser)
    {
        NSString *colorStr = [lastRoomUser.properties bm_stringTrimForKey:sUserPrimaryColor];
        NSUInteger index = [colorArray indexOfObject:colorStr];
        if (index != NSNotFound)
        {
            index++;
            if (index >= colorArray.count)
            {
                index = 0;
            }
        }
        else
        {
            index = 0;
        }
        newColorStr = colorArray[index];
        [[YSLiveManager shareInstance].roomManager changeUserProperty:YSCurrentUser.peerID tellWhom:YSRoomPubMsgTellAll key:sUserPrimaryColor value:newColorStr completion:nil];
    }
    else
    {
        newColorStr = colorArray[0];
        [[YSLiveManager shareInstance].roomManager changeUserProperty:YSCurrentUser.peerID tellWhom:YSRoomPubMsgTellAll key:sUserPrimaryColor value:newColorStr completion:nil];
    }
    
    [self.liveManager.whiteBoardManager changePrimaryColorHex:newColorStr];
}


#pragma mark -
#pragma mark ViewControllerLife

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.videoViewArray = [[NSMutableArray alloc] init];
    _personListCurentPage = 0;
    _personListTotalPage = 0;
    isSearch = NO;
    searchArr = [[NSMutableArray alloc] init];
    self.currentFileList = [[NSMutableArray alloc] init];
    self.currentMediaFileID = @"";
    self.currentMediaState = YSWhiteBordMediaState_Stop;
    /// 本地播放 （定时器结束的音效）
    self.session = [AVAudioSession sharedInstance];
    [self.session setCategory:AVAudioSessionCategoryPlayback error:nil];

    [self getGiftCount];
    
    // 顶部工具栏背景
//    [self setupTopToolBar];
    
    /// 初始化顶栏数据
    [self setupStateBarData];
    // 内容背景
    [self setupContentView];
    
    // 全屏白板
    [self setupFullBoardView];
    
    [self makeMp3Animation];
   
    // 隐藏白板视频布局背景
    [self setupVideoGridView];
    
    // 设置花名册 课件表
    [self setupListView];
    
    [self.spreadBottomToolBar bm_bringToFront];

    if (YSCurrentUser.role == YSUserType_Student)
    {
        // 设置左侧工具栏
        [self setupBrushToolView];
    }

    // 右侧聊天视图
    [self.view addSubview:self.rightChatView];
    
    //弹出聊天框的按钮
//    [self.view addSubview:self.chatBtn];
    
    if (self.roomtype == YSRoomType_More && YSCurrentUser.role == YSUserType_Student)
    {
        //举手上台的按钮
        [self.view addSubview:self.raiseHandsBtn];
        /// 设置视频布局全屏按钮
        [self setupVideoFullBtn];
        
    }
    
    // 会议默认视频布局
    if (self.appUseTheType == YSAppUseTheTypeMeeting)
    {
        defaultRoomLayout = YSLiveRoomLayout_VideoLayout;
        self.roomLayout = defaultRoomLayout;
        [self handleSignalingSetRoomLayout:self.roomLayout withPeerId:nil];
    }
    else
    {
        defaultRoomLayout = YSLiveRoomLayout_AroundLayout;
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
    [self.view addSubview:self.fullTeacherFloatView];
    self.fullTeacherFloatView.hidden = YES;
}
#endif

- (void)afterDoMsgCachePool
{
    [super afterDoMsgCachePool];
    
#if 0
    if (self.appUseTheType == YSAppUseTheTypeSmallClass)
    {
        // 自动上台
        if (self.liveManager.isBeginClass && self.videoViewArray.count < maxVideoCount)
        {
            BOOL autoOpenAudioAndVideoFlag = self.liveManager.roomConfig.autoOpenAudioAndVideoFlag;
//            if (autoOpenAudioAndVideoFlag)
                if (autoOpenAudioAndVideoFlag && YSCurrentUser.role != YSUserType_Patrol)
            {
                //if (YSCurrentUser.vfail == YSDeviceFaultNone)
                {
                    [self.liveManager.roomManager publishVideo:nil];
                }
                //if (YSCurrentUser.afail == YSDeviceFaultNone)
                {
                    BOOL isEveryoneNoAudio = [YSLiveManager shareInstance].isEveryoneNoAudio;
                    if (!isEveryoneNoAudio) {
                        [self.liveManager.roomManager publishAudio:nil];
                    }
                }
            }
        }
    }
    else
    //会议，进教室默认上台
    if (self.appUseTheType == YSAppUseTheTypeMeeting)
    {
        if (self.liveManager.isBeginClass && self.videoViewArray.count < maxVideoCount && YSCurrentUser.role != YSUserType_Patrol)
        {
            //if (YSCurrentUser.vfail == YSDeviceFaultNone)
            {
                [self.liveManager.roomManager publishVideo:nil];
            }
            //if (YSCurrentUser.afail == YSDeviceFaultNone)
            {
                BOOL isEveryoneNoAudio = [YSLiveManager shareInstance].isEveryoneNoAudio;
                if (!isEveryoneNoAudio)
                {
                    [self.liveManager.roomManager publishAudio:nil];
                }
            }
            
            [self.liveManager sendSignalingToChangePropertyWithRoomUser:YSCurrentUser withKey:sUserCandraw WithValue:@(true)];
        }
    }
#endif
}


#pragma mark 隐藏状态栏

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark 状态栏

- (void)setupStateBarData
{
    self.roomID = [YSLiveManager shareInstance].room_Id;
    self.lessonTime = @"00:00:00";
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (UIRectEdge)preferredScreenEdgesDeferringSystemGestures
{
    return UIRectEdgeBottom;
}

// 设置隐藏动画
- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationNone;
}


#pragma mark - 层级管理

// 重新排列VC.View的图层
- (void)arrangeAllViewInVCView
{
    // 全屏白板
    [self.whitebordFullBackgroud bm_bringToFront];
    
    // mp3f动画
    [self.playMp3ImageView bm_bringToFront];
    
    // 笔刷工具
    [self.brushToolView bm_bringToFront];
    
    // 聊天窗口
    [self.rightChatView bm_bringToFront];
    
    // 聊天按钮
//    [self.chatBtn bm_bringToFront];
    
    // 信息输入
    [self.chatToolView bm_bringToFront];
    
    // 全屏MP4 共享桌面
    [self.shareVideoFloatView bm_bringToFront];
    
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

/*
 - (void)arrangeAllView
 {
 // view
 // 顶部工具栏背景
 self.topToolBarBackgroud;
 // 内容背景
 self.contentBackgroud;
 // 全屏白板
 self.whitebordFullBackgroud;
 // mp3f动画
 self.playMp3ImageView;
 // 笔刷工具
 self.brushToolView;
 // 翻页
 self.boardControlView;
 // 聊天窗口
 self.rightChatView;
 // 聊天按钮
 self.chatBtn;
 
 self.chatToolView;
 
 
 // contentBackgroud
 self.contentView;
 self.shareVideoFloatView;
 self.videoGridView;
 
 self.dragOutFloatViewArray; //---floatViewArray;
 
 
 // contentView
 self.whitebordBackgroud;
 self.videoBackgroud;
 }
 */


#pragma mark -
#pragma mark setupUI

/// 列表
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

/// 顶部工具栏背景
//- (void)setupTopToolBar
//{
//    UIView *topToolBarBackGroud = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentWidth, 0)];
//    topToolBarBackGroud.backgroundColor = [UIColor bm_colorWithHex:0x82ABEC];
//    [self.view addSubview:topToolBarBackGroud];
//    self.topToolBarBackgroud = topToolBarBackGroud;
//
//    self.topToolBar = [[SCTopToolBar alloc] init];
//    self.topToolBar.delegate = self;
//    self.topToolBar.frame = CGRectMake(0, 0, self.contentWidth, 0);
//    [self.topToolBarBackgroud addSubview:self.topToolBar];
//
//    [self.topToolBar hidePhotoBtn:YES];
//    [self.topToolBar hideMicrophoneBtn:YES];
//    if (self.liveManager.localUser.role == YSUserType_Patrol)
//    {
//        [self.topToolBar hideCameraBtn:YES];
//    }
//    [self setupTopBarData];
//}


#pragma mark 内容背景
- (void)setupContentView
{
    [self.liveManager setDeviceOrientation:UIDeviceOrientationLandscapeLeft];
    // 前后默认开启镜像
    [self.liveManager changeLocalVideoMirrorMode:YSVideoMirrorModeEnabled];
    
    // 视频+白板背景
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, STATETOOLBAR_HEIGHT, self.contentWidth, self.contentHeight - STATETOOLBAR_HEIGHT)];
    contentView.backgroundColor = [UIColor clearColor];
    [self.contentBackgroud addSubview:contentView];
    self.contentView = contentView;

    
    // 白板背景
    UIView *whitebordBackgroud = [[UIView alloc] init];
    whitebordBackgroud.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:whitebordBackgroud];
    self.whitebordBackgroud = whitebordBackgroud;
    whitebordBackgroud.layer.masksToBounds = YES;
    
    // 视频背景
    UIView *videoBackgroud = [[UIView alloc] init];
//    videoBackgroud.backgroundColor = [UIColor bm_colorWithHex:0x5A8CDC];
    videoBackgroud.backgroundColor = YSSkinDefineColor(@"defaultBgColor");
    [self.view addSubview:self.contentBackgroud];
    [self.contentView addSubview:videoBackgroud];
    self.videoBackgroud = videoBackgroud;
    videoBackgroud.layer.shadowColor = [UIColor bm_colorWithHex:0x000000 alpha:0.5].CGColor;
    videoBackgroud.layer.shadowOffset = CGSizeMake(0,2);
    videoBackgroud.layer.shadowOpacity = 1;
    videoBackgroud.layer.shadowRadius = 4;
    
    // 加载白板
    [self.whitebordBackgroud addSubview:self.whiteBordView];
    
    [self calculateVideoSize];
    
    /// 设置尺寸
    if (self.roomtype == YSRoomType_One)
    {

        self.expandContractBtn = [[UIButton alloc]initWithFrame:CGRectZero];
        [self.expandContractBtn addTarget:self action:@selector(doubleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.expandContractBtn setBackgroundImage:[UIImage imageNamed:@"LittleView_out"] forState:UIControlStateNormal];
        [self.expandContractBtn setBackgroundImage:[UIImage imageNamed:@"LittleView_input"] forState:UIControlStateSelected];
        [self.videoBackgroud addSubview:self.expandContractBtn];
        self.expandContractBtn.tag = DoubleTeacherExpandContractBtnTag;
        self.expandContractBtn.hidden = YES;
        
        [self setUp1V1DefaultVideoView];
    }
    else
    {
        // 添加浮动视频窗口
        self.dragOutFloatViewArray = [[NSMutableArray alloc] init];
        
        // 1VN 初始本人视频音频
        BMLog(@"%@",@(self.liveManager.localUser.role))
        if (self.liveManager.localUser.role != YSUserType_Patrol)
        {
            SCVideoView *videoView = [[SCVideoView alloc] initWithRoomUser:YSCurrentUser isForPerch:YES];
            videoView.appUseTheType = self.appUseTheType;
            [self.videoViewArray addObject:videoView];
            [self.liveManager playVideoOnView:videoView withPeerId:YSCurrentUser.peerID renderType:YSRenderMode_adaptive completion:nil];
            [self.liveManager playAudio:YSCurrentUser.peerID completion:nil];
        }
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
    
    [self freshContentView];
}

- (void)setupVideoFullBtn
{
    UIButton *videoFullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    videoFullScreenBtn.frame = CGRectMake(self.contentWidth-40-26-20-40, self.contentHeight-40-2, 40, 40);
    [videoFullScreenBtn setBackgroundColor: UIColor.clearColor];
    [videoFullScreenBtn setImage:[UIImage imageNamed:@"sc_pagecontrol_allScreen_normal"] forState:UIControlStateNormal];
    [videoFullScreenBtn setImage:[UIImage imageNamed:@"sc_pagecontrol_normalScreen_highlighted"] forState:UIControlStateSelected];
    [videoFullScreenBtn addTarget:self action:@selector(videoFullScreenBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    videoFullScreenBtn.hidden = YES;
    self.videoFullScreenBtn = videoFullScreenBtn;
    
    [self.view addSubview:self.videoFullScreenBtn];
}

- (void)videoFullScreenBtnClick:(UIButton *)btn
{
    btn.selected = !btn.selected;
    [self.videoGridView removeFromSuperview];
    [self fullVideoGridView:btn.selected];
  
}

- (void)fullVideoGridView:(BOOL)isFull
{
//    if (isFull)
//    {
//        self.videoGridView.defaultSize = CGSizeMake(self.contentWidth, self.contentHeight - STATETOOLBAR_HEIGHT);
//        self.videoGridView.frame = CGRectMake(0, STATETOOLBAR_HEIGHT, self.contentWidth, self.contentHeight - STATETOOLBAR_HEIGHT);
//        [self.view addSubview:self.videoGridView];
//        [self.videoGridView bm_centerInSuperView];
//        self.videoGridView.backgroundColor = [UIColor bm_colorWithHex:0x9DBEF3];
//        [self.videoGridView freshViewWithVideoViewArray:self.videoViewArray withFouceVideo:self.fouceView withRoomLayout:self.roomLayout withAppUseTheType:self.appUseTheType];
//        [self.videoFullScreenBtn bm_bringToFront];
//        [self.chatBtn bm_bringToFront];
//        [self.raiseHandsBtn bm_bringToFront	];
//    }
//    else
//    {

        self.videoGridView.defaultSize = CGSizeMake(self.contentWidth, self.contentHeight-STATETOOLBAR_HEIGHT);
        self.videoGridView.frame = CGRectMake(0, STATETOOLBAR_HEIGHT, self.contentWidth, self.contentHeight-STATETOOLBAR_HEIGHT);
        [self.contentBackgroud addSubview:self.videoGridView];
//        [self.videoGridView bm_centerInSuperView];
        self.videoGridView.backgroundColor = [UIColor clearColor];
        [self.videoGridView freshViewWithVideoViewArray:self.videoViewArray withFouceVideo:self.fouceView withRoomLayout:self.roomLayout withAppUseTheType:self.appUseTheType];
        [self.videoFullScreenBtn bm_bringToFront];
//    }
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
    if (self.roomLayout == YSLiveRoomLayout_VideoLayout)
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
    NSString *imageName;
    if (self.isWideScreen)
    {
        imageName = @"main_teachervideocover16v9";
    }
    else
    {
        imageName = @"main_teachervideocover4v3";
    }
    
    // 1V1 初始老师视频蒙版
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    YSRoomUser *roomUser = [[YSRoomUser alloc] initWithPeerId:@"0"];
    SCVideoView *teacherVideoView = [[SCVideoView alloc] initWithRoomUser:roomUser isForPerch:YES];
    teacherVideoView.appUseTheType = self.appUseTheType;
    teacherVideoView.tag = PlaceholderPTag;
    teacherVideoView.frame = CGRectMake(0, 0, videoWidth, videoHeight);
    imageView.frame = teacherVideoView.bounds;
    [teacherVideoView addSubview:imageView];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView.contentMode = UIViewContentModeCenter;
    imageView.backgroundColor = [UIColor bm_colorWithHex:0xEDEDED];
    [self.videoBackgroud addSubview:teacherVideoView];
    teacherVideoView.frame = CGRectMake(0, 0, videoWidth, videoHeight);
    self.teacherPlacehold = teacherVideoView;
    
    
    NSString * text = YSLocalized(@"Label.TeacherState");
    CGSize labSize = [text bm_sizeToFitWidth:videoWidth withFont:UI_FONT_12];
    UILabel *placeLab = [[UILabel alloc]initWithFrame:CGRectMake((videoWidth-labSize.width)/2, videoHeight-25, labSize.width+20, 15)];
    placeLab.text = text;
    placeLab.textAlignment = NSTextAlignmentCenter;
    placeLab.backgroundColor = [UIColor bm_colorWithHex:0xCA5B75];
    placeLab.textColor = UIColor.whiteColor;
    placeLab.layer.cornerRadius = 15/2;
    placeLab.layer.masksToBounds = YES;
    placeLab.font = UI_FONT_12;
    placeLab.numberOfLines = 1;
    placeLab.hidden = YES;
    [self.teacherPlacehold addSubview:placeLab];
    self.teacherPlaceLab = placeLab;
    
    // 1V1 初始本人视频音频
    SCVideoView *videoView = [[SCVideoView alloc] initWithRoomUser:YSCurrentUser isForPerch:YES];
    videoView.appUseTheType = self.appUseTheType;
    videoView.tag = PlaceholderPTag;
    UIImageView *userImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_uservideocover"]];
    userImageView.frame = videoView.bounds;
    userImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    userImageView.contentMode = UIViewContentModeCenter;
    userImageView.backgroundColor = [UIColor bm_colorWithHex:0xEDEDED];
    [videoView addSubview:userImageView];
    [self.videoBackgroud addSubview:videoView];
    videoView.frame = CGRectMake(0, videoHeight + VIDEOVIEW_GAP, videoWidth, videoHeight);
    self.userVideoView = videoView;
    
    [self.liveManager playVideoOnView:videoView withPeerId:YSCurrentUser.peerID renderType:YSRenderMode_adaptive completion:nil];
    [self.liveManager playAudio:YSCurrentUser.peerID completion:nil];
}

/// 全屏白板初始化
- (void)setupFullBoardView
{
    // 白板背景
    UIView *whitebordFullBackgroud = [[UIView alloc] init];
    whitebordFullBackgroud.backgroundColor = [UIColor bm_colorWithHex:0x9DBEF3];
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
    
    // 初始化尺寸
    videoGridView.defaultSize = CGSizeMake(self.contentWidth, self.contentHeight-STATETOOLBAR_HEIGHT);
    videoGridView.frame = CGRectMake(0, STATETOOLBAR_HEIGHT, self.contentWidth, self.contentHeight-STATETOOLBAR_HEIGHT);
    
    CGFloat sss = STATETOOLBAR_HEIGHT;
    
    [self.contentBackgroud addSubview:videoGridView];
//    [videoGridView bm_centerInSuperView];
    videoGridView.backgroundColor = [UIColor clearColor];
    videoGridView.hidden = YES;
    self.videoGridView = videoGridView;
}

/// 音频播放动画
- (void)makeMp3Animation
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, self.view.bm_height - (MP3VIEW_WIDTH+15), MP3VIEW_WIDTH, MP3VIEW_WIDTH)];
    
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

- (UIImageView *)makeGiftImageView
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, GiftImageView_Width*0.5, GiftImageView_Height*0.5)];
    imageView.image = [UIImage imageNamed:@"main_giftshow"];
    [self.view addSubview:imageView];
    [imageView bm_centerInSuperView];
    
    return imageView;
}

#pragma mark UI 工具栏

/// 设置左侧工具栏
- (void)setupBrushToolView
{
    self.brushToolView = [[SCBrushToolView alloc] initWithTeacher:NO];
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
    brushToolOpenBtn.frame = CGRectMake(0, 0, 25, 37);
    brushToolOpenBtn.bm_centerY = self.brushToolView.bm_centerY;
    brushToolOpenBtn.bm_left = self.brushToolView.bm_right;
    self.brushToolOpenBtn = brushToolOpenBtn;
    self.brushToolOpenBtn.hidden = YES;
    [self.view addSubview:brushToolOpenBtn];
}


/// 助教网络刷新课件
- (void)handleSignalingTorefeshCourseware
{
#warning handleSignalingTorefeshCourseware
}


//- (UIButton *)chatBtn
//{
//    if (!_chatBtn)
//    {
//        self.chatBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.contentWidth-40-26, self.contentHeight-40-2, 40, 40)];
//        [self.chatBtn setBackgroundColor: UIColor.clearColor];
//        [self.chatBtn setImage:[UIImage imageNamed:@"chat_SmallClassImage"] forState:UIControlStateNormal];
//        [self.chatBtn setImage:[UIImage imageNamed:@"chat_SmallClassImage_push"] forState:UIControlStateHighlighted];
//        [self.chatBtn addTarget:self action:@selector(chatButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//        //拖拽
//        //        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragReplyButton:)];
//        //        [self.chatBtn addGestureRecognizer:panGestureRecognizer];
//    }
//    return _chatBtn;
//}

- (UIButton *)raiseHandsBtn
{
    if (!_raiseHandsBtn)
    {
        
        CGFloat raiseHandWH = 30;
        CGFloat raiseHandRight = 10;
        
        CGFloat labBottom = 12;
        if ([UIDevice bm_isiPad])
        {
            raiseHandWH = 40;
            raiseHandRight = 20;
            labBottom = 20;
        }
        self.raiseHandsBtn = [[UIButton alloc]initWithFrame:CGRectMake(BMUI_SCREEN_WIDTH - raiseHandWH - raiseHandRight, BMUI_SCREEN_HEIGHT - raiseHandWH - 100, raiseHandWH, raiseHandWH)];
        [self.raiseHandsBtn setBackgroundColor: UIColor.clearColor];
        [self.raiseHandsBtn setImage:YSSkinElementImage(@"raiseHand_studentBtn", @"iconNor") forState:UIControlStateNormal];
        [self.raiseHandsBtn setImage:YSSkinElementImage(@"raiseHand_studentBtn", @"iconSel") forState:UIControlStateHighlighted];
        [self.raiseHandsBtn addTarget:self action:@selector(raiseHandsButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        self.raiseHandsBtn.hidden = YES;
        
        
        //button长按事件
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(raiseHandsBtnLong:)];
        longPress.minimumPressDuration = 0.5; //定义按的时间
        [self.raiseHandsBtn addGestureRecognizer:longPress];
        

        UIImageView * raiseMaskImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, raiseHandWH, raiseHandWH)];
        raiseMaskImage.animationImages = @[YSSkinElementImage(@"raiseHand_time_3", @"iconNor"),YSSkinElementImage(@"raiseHand_time_2", @"iconNor"),YSSkinElementImage(@"raiseHand_time_1", @"iconNor")];
        raiseMaskImage.animationDuration = 3.0;
        raiseMaskImage.animationRepeatCount = 0;
        self.raiseMaskImage = raiseMaskImage;
        [self.raiseHandsBtn addSubview:raiseMaskImage];
        raiseMaskImage.userInteractionEnabled = NO;
        raiseMaskImage.hidden = YES;
        
        
        NSString * tipStr = YSLocalized(@"Label.RaisingHandsTip");
        CGFloat tipStrWidth=[tipStr boundingRectWithSize:CGSizeMake(1000, 16) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10]} context:nil].size.width;
        
        UILabel * remarkLab = [[UILabel alloc]initWithFrame:CGRectMake(self.raiseHandsBtn.bm_originX - tipStrWidth - 15 - 5, 0, tipStrWidth + 15, 16)];
        remarkLab.bm_centerY = self.raiseHandsBtn.bm_centerY;
        remarkLab.text = YSLocalized(@"Label.RaisingHandsTip");
        remarkLab.backgroundColor = YSSkinDefineColor(@"defaultSelectedBgColor");
        remarkLab.font = UI_FONT_10;
        remarkLab.textColor = YSSkinDefineColor(@"defaultTitleColor");
        remarkLab.textAlignment = NSTextAlignmentCenter;
        remarkLab.layer.cornerRadius = 16/2;
        remarkLab.layer.masksToBounds = YES;
        remarkLab.hidden = YES;
        [self.view addSubview:remarkLab];
        self.remarkLab = remarkLab;
    }
    return _raiseHandsBtn;
}

//长按
- (void)raiseHandsBtnLong:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        [self raiseHandsButtonTouchDown];
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        [self raiseHandsButtonTouchUp];
    }
}
///点击
- (void)raiseHandsButtonClick:(UIButton *)sender
{
    [self raiseHandsButtonTouchDown];
    self.remarkLab.hidden = NO;
    self.raiseMaskImage.hidden = NO;
    [self.raiseMaskImage startAnimating];
    self.raiseHandsBtn.userInteractionEnabled = NO;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.raiseMaskImage stopAnimating];
        self.remarkLab.hidden = YES;
        self.raiseMaskImage.hidden = YES;
        self.raiseHandsBtn.userInteractionEnabled = YES;
        [self raiseHandsButtonTouchUp];
    });
}

///举手
- (void)raiseHandsButtonTouchDown
{    
    [self.liveManager sendSignalingsStudentToRaiseHandWithModify:0 Completion:nil];
    
    [self.liveManager sendSignalingToChangePropertyWithRoomUser:YSCurrentUser withKey:sUserRaisehand WithValue:@(true)];
}

///取消举手
- (void)raiseHandsButtonTouchUp
{
    [self.liveManager sendSignalingsStudentToRaiseHandWithModify:1 Completion:nil];
        [self.liveManager sendSignalingToChangePropertyWithRoomUser:YSCurrentUser withKey:sUserRaisehand WithValue:@(false)];
}


#pragma mark -
#pragma mark UI fresh

// 横排视频最大宽度计算
- (CGFloat)getVideoTotalWidth
{
    NSUInteger count = [self getVideoViewCount];
    
    CGFloat totalWidth = 0.0;
    
    if (count < 8)
    {
        totalWidth = count*(videoWidth+VIDEOVIEW_GAP*0.5);
    }
    else
    {
        NSInteger num = count/2 + count%2;
        if (self.teacherVideoView && !self.teacherVideoView.isDragOut && !self.teacherVideoView.isFullScreen)
        {
            totalWidth = videoTeacherWidth + num*(videoWidth+VIDEOVIEW_GAP*0.5);
        }
        else
        {
            totalWidth = num*(videoWidth+VIDEOVIEW_GAP*0.5);
        }
    }
    return totalWidth;
}


- (void)calculateFloatVideoSize
{
    CGFloat width;
    CGFloat height;
    
    // 在此调整视频大小和屏幕比例关系
    if (self.isWideScreen)
    {
        width = ceil(self.contentWidth / 25) * 9;
        height = ceil(width*9 / 16);
    }
    else
    {
        width = ceil(self.contentWidth*5 / 21);
        height = ceil(width*3 / 4);
    }
    
    /// 悬浮默认视频宽(拖出和共享)
    floatVideoDefaultWidth = width;
    /// 悬浮默认视频高(拖出和共享)
    floatVideoDefaultHeight = height;
}

// 计算视频尺寸，除老师视频
- (void)calculateVideoSize
{
    if (self.roomtype == YSRoomType_One)
    {
        if (self.roomLayout == YSLiveRoomLayout_VideoLayout)
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
        NSUInteger count = [self getVideoViewCount];
        videoTeacherWidth = ceil((self.contentWidth - VIDEOVIEW_GAP * 0.5 * 8)/7);
        if (count < 8)
        {
            videoWidth = videoTeacherWidth;
        }
        else
        {
            videoWidth = ceil((videoTeacherWidth - VIDEOVIEW_GAP*0.5)/2.0);
        }
        CGFloat scale = 0;
        if (self.isWideScreen)
        {
            scale = 16.0/9.0;
        }
        else
        {
            scale = 4.0/3.0;
        }
        videoHeight = ceil(videoWidth / scale);
        videoTeacherHeight = ceil(videoTeacherWidth / scale);
        
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
    if (self.roomtype == YSRoomType_One)
    {
        if (self.videoViewArray.count>1)
        {
            self.userVideoView.hidden = YES;
        }
        else
        {
            self.userVideoView.hidden = NO;
            if (self.videoViewArray.count == 1)
            {
                SCVideoView *videoView = self.videoViewArray.firstObject;
                if (![videoView.roomUser.peerID isEqualToString:YSCurrentUser.peerID])
                {
                    [self.liveManager stopPlayVideo:YSCurrentUser.peerID completion:nil];
                    [self.liveManager stopPlayAudio:YSCurrentUser.peerID completion:nil];
                    if (videoView.roomUser.role == YSUserType_Student)
                    {
                        self.userVideoView.hidden = YES;
                    }
                }
                else
                {
                    self.userVideoView.hidden = YES;
                }
            }
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
        
        if (self.roomLayout == YSLiveRoomLayout_VideoLayout || self.roomLayout == YSLiveRoomLayout_FocusLayout)
        {
            [self freshVidoeGridView];
            self.videoFullScreenBtn.hidden = NO;
            [self.videoFullScreenBtn bm_bringToFront];
            [self.raiseHandsBtn bm_bringToFront];
//            [self.chatBtn bm_bringToFront];
        }
        else
        {
            self.videoGridView.defaultSize = CGSizeMake(self.contentWidth, self.contentHeight-STATETOOLBAR_HEIGHT);
            self.videoGridView.frame = CGRectMake(0, STATETOOLBAR_HEIGHT, self.contentWidth, self.contentHeight-STATETOOLBAR_HEIGHT);
            [self.contentBackgroud addSubview:self.videoGridView];
//            [self.videoGridView bm_centerInSuperView];
            self.videoGridView.backgroundColor = [UIColor clearColor];
            self.videoFullScreenBtn.hidden = YES;
            self.videoFullScreenBtn.selected = NO;
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
    
    if (self.isDoubleType && self.roomtype == YSRoomType_One) {
        [self doubleTeacherCalculateVideoSize];
        [self doubleTeacherArrangeVidoeView];
//        self.isDoubleType = 0;
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
        self.expandContractBtn.hidden = YES;
        if (self.roomLayout == YSLiveRoomLayout_VideoLayout)
        {//左右平行关系
            if ([view.roomUser.peerID isEqualToString:self.liveManager.teacher.peerID])
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
                if ([view.roomUser.peerID isEqualToString:self.liveManager.teacher.peerID])
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
                    
                    if ([view.roomUser.peerID isEqualToString:self.liveManager.teacher.peerID])
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
                    
                    if ([view.roomUser.peerID isEqualToString:self.liveManager.teacher.peerID])
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
                
                if ([view.roomUser.peerID isEqualToString:self.liveManager.teacher.peerID])
                {
                    view.frame = CGRectMake(0, 0, videoTeacherWidth, videoTeacherHeight);
                }
                else
                {
                    view.frame = CGRectMake(videoTeacherWidth - videoWidth, 0, videoWidth, videoHeight);
                    self.studentVideoView = view;
                    self.expandContractBtn.selected = NO;
                    self.expandContractBtn.frame = CGRectMake(view.bm_originX-23, view.bm_originY, 23, videoHeight);
                    [self.videoBackgroud bringSubviewToFront:view];
                    [self.videoBackgroud bringSubviewToFront:self.expandContractBtn];
                }
            }
        }
        [view bringSubviewToFront:view.backVideoView];
    }
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
            
            if (self.isWideScreen)
            {//16:9
                CGFloat orgainalY = (whitebordHeight - 2 * videoHeight - VIDEOVIEW_GAP)/2;

                if (view.roomUser.role == YSUserType_Teacher)
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
                 view.frame = CGRectMake(videoStartX + (videoWidth + VIDEOVIEW_GAP * 0.5) * index, VIDEOVIEW_GAP * 0.5, videoWidth, videoHeight);
             }
            else
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
    if (self.roomtype == YSRoomType_One)
    {
        self.whitebordBackgroud.hidden = NO;
        
        if (self.roomLayout == YSLiveRoomLayout_VideoLayout)
        {//左右平行关系
            self.whitebordBackgroud.hidden = YES;
            
            self.videoBackgroud.frame = CGRectMake(whitebordWidth, 0, videoWidth, videoHeight);
            
            self.teacherPlacehold.frame = CGRectMake(VIDEOVIEW_GAP, 0, videoWidth, videoHeight);
            self.userVideoView.frame = CGRectMake(VIDEOVIEW_GAP*2+videoWidth, 0, videoWidth, videoHeight);
        }
        else
        {
            if (![self.doubleType bm_isNotEmpty] || [self.doubleType isEqualToString:@"abreast"])
            {//默认上下平行关系

                self.whitebordBackgroud.frame = CGRectMake(0, 0, whitebordWidth, whitebordHeight);

                self.videoBackgroud.frame = CGRectMake(whitebordWidth + VIDEOVIEW_GAP, 0, videoWidth, whitebordHeight);
                
                if (self.isWideScreen)
                {//16:9
                    
                    CGFloat orgainalY = (whitebordHeight - 2 * videoHeight - VIDEOVIEW_GAP)/2;
                    
                    self.teacherVideoView.frame = CGRectMake(0, orgainalY, videoWidth, videoHeight);
                    self.userVideoView.frame = CGRectMake(0, orgainalY + videoHeight + VIDEOVIEW_GAP, videoWidth, videoHeight);
                }
                else
                {//4:3
                    self.teacherVideoView.frame = CGRectMake(0, 0, videoWidth, videoHeight);
                    self.userVideoView.frame = CGRectMake(0, videoHeight, videoWidth, videoHeight);
                }
            }
            else if([self.doubleType isEqualToString:@"nested"])
            {//画中画
                
                CGFloat whitebordY = (self.contentHeight - STATETOOLBAR_HEIGHT - whitebordHeight)/2;
                
                self.whitebordBackgroud.frame = CGRectMake(0, whitebordY, whitebordWidth, whitebordHeight);
                self.videoBackgroud.frame = CGRectMake(whitebordWidth + VIDEOVIEW_GAP, whitebordY, videoWidth, whitebordHeight);
                
                self.teacherPlacehold.frame = CGRectMake(0, 0, videoTeacherWidth, videoTeacherHeight);
                self.userVideoView.frame = CGRectMake(CGRectGetMaxX(self.teacherPlacehold.frame)-videoWidth, 0, videoWidth, videoHeight);
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
        self.whiteBordView.frame = CGRectMake(0, 0, self.whitebordFullBackgroud.bm_width, self.whitebordFullBackgroud.bm_height);
    }
    else
    {
        self.whiteBordView.frame = self.whitebordBackgroud.bounds;
    }

    [[YSLiveManager shareInstance].whiteBoardManager refreshWhiteBoard];
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

- (void)showGiftAnimationWithVideoView:(SCVideoView *)videoView
{
    if (!videoView)
    {
        return;
    }
    
    NSBundle *bundle = [NSBundle bundleWithPath: [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"YSResources.bundle"]];
    NSString *filePath = [[bundle resourcePath] stringByAppendingPathComponent:@"trophy_tones.mp3"];
    
    static BOOL giftMp3Playing = NO;
    
    if (!giftMp3Playing)
    {
        giftMp3Playing = YES;
        BMWeakSelf
        [self.liveManager.roomManager startPlayMediaFile:filePath window:nil loop:NO progress:^(int playID, int64_t current, int64_t total) {
            [weakSelf.liveManager.roomManager setPlayMedia:playID volume:0.5f];
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


#pragma mark - floatVideo

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
        // percentLeft = x / ( width - videowidth )
        CGFloat x = percentLeft * (self.contentWidth - videoView.bm_width);
        CGFloat y = percentTop * (self.whitebordBackgroud.bm_height - videoView.bm_height);
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
        
        // percentLeft = x / ( width - videowidth )
        CGFloat x = percentLeft * (self.contentWidth - floatVideoDefaultWidth);
        CGFloat y = percentTop * (self.whitebordBackgroud.bm_height - floatVideoDefaultHeight);
        CGPoint point = CGPointMake(x, y);
        
        YSFloatView *floatView = [[YSFloatView alloc] initWithFrame:CGRectMake(point.x, point.y, floatVideoDefaultWidth, floatVideoDefaultHeight)];
        // 暂时不支持本地拖动缩放
        //floatView.canGestureRecognizer = YES;
        floatView.defaultSize = CGSizeMake(floatVideoDefaultWidth, floatVideoDefaultHeight);
        //[floatView showWithContentView:videoView];
        [self.dragOutFloatViewArray addObject:floatView];
        [self.whitebordBackgroud addSubview:floatView];
        
        [floatView showWithContentView:videoView];
        //[floatView stayMove];
        [floatView bm_bringToFront];
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

// 开始共享桌面
- (void)showShareVidoeViewWithPeerId:(NSString *)peerId
{
    [self.view endEditing:YES];
    
    [self.liveManager.roomManager playScreen:peerId renderType:YSRenderMode_fit window:self.shareVideoView completion:^(NSError *error) {
    }];
        
    [self arrangeAllViewInVCView];
    self.shareVideoFloatView.canZoom = YES;
    self.shareVideoFloatView.showWaiting = NO;
    self.shareVideoFloatView.hidden = NO;
    
#if USE_FullTeacher
    [self playFullTeacherVideoViewInView:self.shareVideoFloatView];
#endif
}

// 关闭共享桌面
- (void)hideShareVidoeViewWithPeerId:(NSString *)peerId
{
    [self.liveManager.roomManager unPlayScreen:peerId completion:^(NSError * _Nonnull error) {
    }];
    
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

// 开始播放课件视频
- (void)showWhiteBordVidoeViewWithPeerId:(NSString *)peerId
{
    [self.view endEditing:YES];
    
    [self.liveManager.roomManager playMediaFile:peerId renderType:YSRenderMode_fit window:self.shareVideoView completion:^(NSError *error) {
    }];
    
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
    
    // 主动清除白板视频标注 服务端会发送关闭
    [self handleSignalingHideVideoWhiteboard];
#if USE_FullTeacher
    [self stopFullTeacherVideoView];
    
    if (!self.whitebordFullBackgroud.hidden)
    {
        [self playFullTeacherVideoViewInView:self.whitebordFullBackgroud];
    }
#endif
}


#pragma mark - videoViewArray

- (void)playVideoAudioWithVideoView:(SCVideoView *)videoView
{
    [self playVideoAudioWithVideoView:videoView needFreshVideo:NO];
}

- (void)playVideoAudioWithVideoView:(SCVideoView *)videoView needFreshVideo:(BOOL)fresh
{
    if (!videoView)
    {
        return;
    }
    
    YSPublishState publishState = [videoView.roomUser.properties bm_intForKey:sUserPublishstate];
    
    NSLog(@"=====================playVideoAudioWithVideoView userId: %@, publishState: %@ ", videoView.roomUser.peerID , @(publishState));
    
    YSRenderMode renderType = YSRenderMode_adaptive;

    fresh = NO;
    
    if (publishState == YSUser_PublishState_VIDEOONLY)
    {
        if (fresh || (videoView.publishState != YSUser_PublishState_VIDEOONLY && videoView.publishState != YSUser_PublishState_BOTH))
        {
            if (fresh)
            {
                [self.liveManager stopPlayVideo:videoView.roomUser.peerID completion:nil];
            }
            [self.liveManager playVideoOnView:videoView withPeerId:videoView.roomUser.peerID renderType:renderType completion:nil];
            [videoView bringSubviewToFront:videoView.backVideoView];

            if (self.liveManager.roomConfig.isMirrorVideo)
            {
                // 视频镜像要在play之后
                NSDictionary *properties = videoView.roomUser.properties;
                if ([properties bm_isNotEmptyDictionary] && [properties bm_containsObjectForKey:sUserIsVideoMirror])
                {
                    BOOL isVideoMirror = [properties bm_boolForKey:sUserIsVideoMirror];
                    [self.liveManager changeVideoMirrorWithPeerId:videoView.roomUser.peerID mirror:isVideoMirror];
                }
            }
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
        if (fresh || (videoView.publishState != YSUser_PublishState_VIDEOONLY && videoView.publishState != YSUser_PublishState_BOTH))
        {
            if (fresh)
            {
                [self.liveManager stopPlayVideo:videoView.roomUser.peerID completion:nil];
            }
            [self.liveManager playVideoOnView:videoView withPeerId:videoView.roomUser.peerID renderType:renderType completion:nil];
            [videoView bringSubviewToFront:videoView.backVideoView];
            
            if (self.liveManager.roomConfig.isMirrorVideo)
            {
                NSDictionary *properties = videoView.roomUser.properties;
                if ([properties bm_isNotEmptyDictionary] && [properties bm_containsObjectForKey:sUserIsVideoMirror])
                {
                    BOOL isVideoMirror = [properties bm_boolForKey:sUserIsVideoMirror];
                    [self.liveManager changeVideoMirrorWithPeerId:videoView.roomUser.peerID mirror:isVideoMirror];
                }
            }
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

- (void)playVideoAudioWithNewVideoView:(SCVideoView *)videoView
{
    if (!videoView)
    {
        return;
    }
    
    YSPublishState publishState = [videoView.roomUser.properties bm_intForKey:sUserPublishstate];
    
    YSRenderMode renderType = YSRenderMode_adaptive;
    
    if (publishState == YSUser_PublishState_VIDEOONLY)
    {
        [self.liveManager stopPlayVideo:videoView.roomUser.peerID completion:nil];
        [self.liveManager playVideoOnView:videoView withPeerId:videoView.roomUser.peerID renderType:renderType completion:nil];
        [videoView bringSubviewToFront:videoView.backVideoView];
        
        if (self.liveManager.roomConfig.isMirrorVideo)
        {
            NSDictionary *properties = videoView.roomUser.properties;
            if ([properties bm_isNotEmptyDictionary] && [properties bm_containsObjectForKey:sUserIsVideoMirror])
            {
                BOOL isVideoMirror = [properties bm_boolForKey:sUserIsVideoMirror];
                [self.liveManager changeVideoMirrorWithPeerId:videoView.roomUser.peerID mirror:isVideoMirror];
            }
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
        [self.liveManager stopPlayVideo:videoView.roomUser.peerID completion:nil];
        [self.liveManager playVideoOnView:videoView withPeerId:videoView.roomUser.peerID renderType:renderType completion:nil];
        [videoView bringSubviewToFront:videoView.backVideoView];

        if (self.liveManager.roomConfig.isMirrorVideo)
        {
            NSDictionary *properties = videoView.roomUser.properties;
            if ([properties bm_isNotEmptyDictionary] && [properties bm_containsObjectForKey:sUserIsVideoMirror])
            {
                BOOL isVideoMirror = [properties bm_boolForKey:sUserIsVideoMirror];
                [self.liveManager changeVideoMirrorWithPeerId:videoView.roomUser.peerID mirror:isVideoMirror];
            }
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
    if (self.controlPopoverView.presentingViewController)
    {
        [self.controlPopoverView dismissViewControllerAnimated:NO completion:nil];
    }

    YSRoomUser *roomUser = [self.liveManager.roomManager getRoomUserWithUId:peerId];
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
    {
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
                [videoView freshWithRoomUserProperty:roomUser];
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
            SCVideoView *videoView = [[SCVideoView alloc] initWithRoomUser:roomUser];
            videoView.appUseTheType = self.appUseTheType;
            videoView.delegate = self;
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

- (SCVideoView *)getFirstInlistVideoView
{
    for (SCVideoView *videoView in self.videoViewArray)
    {
        if (!videoView.isDragOut && !videoView.isFullScreen)
        {
            return videoView;
        }
    }
    return nil;
}

#pragma mark  删除视频窗口

- (void)delVidoeViewWithPeerId:(NSString *)peerId
{
    if (self.controlPopoverView.presentingViewController)
    {
        [self.controlPopoverView dismissViewControllerAnimated:NO completion:nil];
    }

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
            [self handleSignalingDragOutVideoChangeFullSizeWithPeerId:nil isFull:NO];
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
    [self handleSignalingDragOutVideoChangeFullSizeWithPeerId:nil isFull:NO];
    
    for (SCVideoView *videoView in self.videoViewArray)
    {
        [self stopVideoAudioWithVideoView:videoView];
    }
    
    [self.videoViewArray removeAllObjects];
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


#pragma mark -
#pragma mark Mp3Func

- (void)onPlayMp3
{
    [self arrangeAllViewInVCView];
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


//聊天按钮点击事件
- (void)chatButtonClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
//    [self.chatBtn setImage:[UIImage imageNamed:@"chat_SmallClassImage"] forState:UIControlStateNormal];
//    [self.chatBtn setImage:[UIImage imageNamed:@"chat_SmallClassImage_push"] forState:UIControlStateHighlighted];
    
    CGRect tempRect = self.rightChatView.frame;
    if (sender.selected)
    {//弹出
        tempRect.origin.x = BMUI_SCREEN_WIDTH-tempRect.size.width;
        //收回 课件表 以及 花名册
        [self freshListViewWithSelect:NO];
//        if (self.topSelectBtn.tag == SCTeacherTopBarTypePersonList || self.topSelectBtn.tag == SCTeacherTopBarTypeCourseware)
//        {
//            self.topSelectBtn.selected = NO;
//        }
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


#pragma mark - 右侧聊天视图

- (SCChatView *)rightChatView
{
    if (!_rightChatView)
    {
        self.rightChatView = [[SCChatView alloc]initWithFrame:CGRectMake(BMUI_SCREEN_WIDTH, self.contentBackgroud.bm_originY + STATETOOLBAR_HEIGHT, ChatViewWidth, SCChatViewHeight)];
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
           CGFloat tempWidth = [UIDevice bm_isiPad] ? 50.0f : 36.0f;
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
    [self.view addSubview:self.drawBoardView];
    
    BMWeakSelf
    [self.drawBoardView.backgroundView  bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.left.bmmas_equalTo(weakSelf.brushToolOpenBtn.bmmas_right).bmmas_offset(10);
        make.centerY.bmmas_equalTo(weakSelf.brushToolOpenBtn.bmmas_centerY);
    }];

}


#pragma mark - 需要传递给白板的数据
#pragma mark SCDrawBoardViewDelegate

- (void)brushSelectorViewDidSelectDrawType:(YSDrawType)drawType color:(NSString *)hexColor widthProgress:(float)progress
{

    if (self.liveManager.localUser.canDraw)
    {
        [self.liveManager.whiteBoardManager didSelectDrawType:drawType color:hexColor widthProgress:progress];
    }

}


#pragma mark -
#pragma mark SCTopToolBarDelegate

/// 麦克风
//- (void)microphoneProxyWithBtn:(UIButton *)btn
//{
//    if (self.liveManager.localUser.afail == YSDeviceFaultNone)
//    {
//        YSPublishState publishState = [YSCurrentUser.properties bm_intForKey:sUserPublishstate];
//
//        // selected在回调前变化过了
//        if (self.topToolBar.microphoneBtn.selected)
//        {
//            // 关闭音频
//
//            if (publishState == YSUser_PublishState_AUDIOONLY)
//            {
//                publishState = 4;
//            }
//            else if (publishState == YSUser_PublishState_BOTH)
//            {
//                publishState = YSUser_PublishState_VIDEOONLY;
//            }
//
//            if (publishState == YSUser_PublishState_VIDEOONLY || publishState == 4)
//            {
//                [self.liveManager.roomManager changeUserProperty:YSCurrentUser.peerID tellWhom:YSRoomPubMsgTellAll key:sUserPublishstate value:@(publishState) completion:nil];
//            }
//        }
//        else
//        {
//            // 打开音频
//
//            if (publishState == 4)
//            {
//                publishState = YSUser_PublishState_AUDIOONLY;
//            }
//            else if (publishState == YSUser_PublishState_VIDEOONLY)
//            {
//                publishState = YSUser_PublishState_BOTH;
//            }
//
//            if (publishState == YSUser_PublishState_AUDIOONLY || publishState == YSUser_PublishState_BOTH)
//            {
//                [self.liveManager.roomManager changeUserProperty:YSCurrentUser.peerID tellWhom:YSRoomPubMsgTellAll key:sUserPublishstate value:@(publishState) completion:nil];
//            }
//        }
//    }
//    else
//    {
//        return;
//    }
//}

/// 照片
- (void)photoProxyWithBtn:(UIButton *)btn
{
    [self openTheImagePickerWithImageUseType:SCUploadImageUseType_Document];
}

- (void)bottomToolBarSpreadOut:(BOOL)spreadOut
{
    
}
/// 功能点击
- (void)bottomToolBarClickAtIndex:(SCTeacherTopBarType)teacherTopBarType isSelected:(BOOL)isSelected
{
        switch (teacherTopBarType)
        {
            case SCTeacherTopBarTypePersonList:
            {
                //花名册  有用户进入房间调用 上下课调用
                [self freshListViewWithSelect:isSelected];
                [self freshTeacherPersonListDataNeedFesh:YES];
                [self.teacherListView bm_bringToFront];

            }
                break;
                
            case SCTeacherTopBarTypeCourseware:
            {
                //课件库
                if (!self.liveManager.roomConfig.isMultiCourseware)
                {
                    self.currentMediaFileID = self.liveManager.playMediaModel.fileid;
                    if (self.liveManager.playMediaModel)
                    {
                        self.currentMediaState = isMediaPause ? YSWhiteBordMediaState_Pause : YSWhiteBordMediaState_Play;
                    }
                    else
                    {
                        self.currentMediaState = YSWhiteBordMediaState_Stop;
                    }
                    
                }
                [self.teacherListView setUserRole:self.liveManager.localUser.role];
                [self.teacherListView setDataSource:[YSLiveManager shareInstance].fileList withType:SCTeacherTopBarTypeCourseware userNum:[YSLiveManager shareInstance].fileList.count currentFileList:self.currentFileList mediaFileID:self.currentMediaFileID mediaState:self.currentMediaState];
                [self.teacherListView bm_bringToFront];
                
            }
                break;
            case SCTeacherTopBarTypeToolBox:
            {
                self.toolBoxView = [[YSToolBoxView alloc] init];
                [self.toolBoxView showToolBoxViewInView:self.view backgroundEdgeInsets:UIEdgeInsetsZero topDistance:0 userRole:self.liveManager.localUser.role];
                self.toolBoxView.delegate = self;
            }
                break;
            case SCTeacherTopBarTypeCamera:
            {
                //摄像头
                [self.liveManager.roomManager selectCameraPosition:!isSelected];
            }
                break;
            case SCTeacherTopBarTypeChat:
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
            case SCTeacherTopBarTypeExit:
            {
                //退出
                [self backAction:nil];
            }
                break;

            default:
                break;
        }
        
}
#pragma mark 工具箱

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
        case SCToolBoxTypeAlbum:
        {
            /// 上传图片
            [self openTheImagePickerWithImageUseType:SCUploadImageUseType_Document];
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
//        self.chatBtn.selected = NO;
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

#pragma mark -刷新花名册数据

- (void)freshTeacherPersonListData
{
    [self freshTeacherPersonListDataNeedFesh:NO];
}

//- (void)freshTeacherPersonListData
- (void)freshTeacherPersonListDataNeedFesh:(BOOL)fresh
{
    if (fresh || [self.spreadBottomToolBar nameListIsShow])
    {
        //花名册  有用户进入房间调用 上下课调用
               //花名册  有用户进入房间调用 上下课调用
        
        if (self.liveManager.isBigRoom)
        {
            BMWeakSelf
            NSInteger studentNum = self.liveManager.userCount;
            NSInteger assistantNum = self.liveManager.assistantCount;
            [self.teacherListView setPersonListCurrentPage:_personListCurentPage totalPage:ceil((CGFloat)(studentNum + assistantNum)/(CGFloat)onePageMaxUsers)];
            [self.liveManager.roomManager getRoomUsersWithRole:@[@(YSUserType_Assistant),@(YSUserType_Student)] startIndex:_personListCurentPage*onePageMaxUsers maxNumber:onePageMaxUsers search:@"" order:@{} callback:^(NSArray<YSRoomUser *> * _Nonnull users, NSError * _Nonnull error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                   // UI更新代码
                    [weakSelf.teacherListView setUserRole:weakSelf.liveManager.localUser.role];
                   [weakSelf.teacherListView setDataSource:users withType:SCTeacherTopBarTypePersonList userNum:studentNum];
                });
                
            }];
        }
        else
        {
            [self.teacherListView setUserRole:self.liveManager.localUser.role];

            NSInteger studentNum = self.liveManager.studentCount ;
            NSInteger assistantNum = self.liveManager.assistantCount;
            NSInteger listNumber = studentNum + assistantNum;
            NSInteger divide = ceil((CGFloat)listNumber / (CGFloat)onePageMaxUsers);
            
            _personListTotalPage = divide;
            
            NSMutableArray *listArr = [NSMutableArray arrayWithCapacity:0];
            for (YSRoomUser *user in self.liveManager.userList)
            {
                if (user.role == YSUserType_Assistant || user.role == YSUserType_Student)
                {
                    [listArr addObject:user];
                }
            }
            
            NSArray *data = [listArr bm_divisionWithCount:onePageMaxUsers atIndex:_personListCurentPage appoint:NO];
              [self.teacherListView setDataSource:data withType:SCTeacherTopBarTypePersonList userNum:studentNum];
            
            [self.teacherListView setPersonListCurrentPage:_personListCurentPage totalPage:_personListTotalPage];
        }
    }
}

#pragma mark -刷新课件库数据
- (void)freshTeacherCoursewareListData
{
    if ([self.spreadBottomToolBar coursewareListIsShow])
    {

        if (!self.liveManager.roomConfig.isMultiCourseware)
        {
            self.currentMediaFileID = self.liveManager.playMediaModel.fileid;
            if (isMediaStop)
            {
                self.currentMediaState = YSWhiteBordMediaState_Stop;
            }
            else if (self.liveManager.playMediaModel)
            {
                self.currentMediaState = isMediaPause ? YSWhiteBordMediaState_Pause : YSWhiteBordMediaState_Play;
            }
            else
            {
                self.currentMediaState = YSWhiteBordMediaState_Stop;
            }
  
        }
        [self.teacherListView setUserRole:self.liveManager.localUser.role];

        [self.teacherListView setDataSource:self.liveManager.fileList withType:SCTeacherTopBarTypeCourseware userNum:self.liveManager.fileList.count currentFileList:self.currentFileList mediaFileID:self.currentMediaFileID mediaState:self.currentMediaState];
    }
}


#pragma mark -
#pragma mark SCTeacherListViewDelegate

///收回列表
- (void)tapGestureBackListView
{
    [self freshListViewWithSelect:NO];
//    if (self.topSelectBtn.tag == SCTeacherTopBarTypePersonList || self.topSelectBtn.tag == SCTeacherTopBarTypeCourseware)
//    {
//        self.topSelectBtn.selected = NO;
//    }
}


- (void)leftPageProxyWithPage:(NSInteger)page
{
    page--;
//    _personListCurentPage = page;
//    [self freshTeacherPersonListData];

    if (isSearch)
    {
        if (self.liveManager.isBigRoom)
        {
            NSInteger studentNum = self.liveManager.studentCount;
            [self.teacherListView setPersonListCurrentPage:page totalPage:ceil((CGFloat)searchArr.count/(CGFloat)onePageMaxUsers)];
            NSArray *data = [searchArr bm_divisionWithCount:onePageMaxUsers atIndex:page appoint:NO];
            [self.teacherListView setDataSource:data withType:SCTeacherTopBarTypePersonList userNum:studentNum];
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
        [self.teacherListView setDataSource:data withType:SCTeacherTopBarTypePersonList userNum:studentNum];
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
        NSInteger studentNum = self.liveManager.studentCount;
        NSInteger assistantNum = self.liveManager.assistantCount;

        [self.liveManager.roomManager getRoomUsersWithRole:@[@(YSUserType_Assistant),@(YSUserType_Student)] startIndex:0 maxNumber:(studentNum + assistantNum) search:searchContent order:@{} callback:^(NSArray<YSRoomUser *> * _Nonnull users, NSError * _Nonnull error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // UI更新代码

                self->searchArr = [NSMutableArray arrayWithArray:users];
                [weakSelf.teacherListView setPersonListCurrentPage:0 totalPage:ceil((CGFloat)users.count/(CGFloat)onePageMaxUsers)];
                if (users.count > onePageMaxUsers)
                {
                    NSArray *data = [users subarrayWithRange:NSMakeRange(0, onePageMaxUsers)];
                    [weakSelf.teacherListView setDataSource:data withType:SCTeacherTopBarTypePersonList userNum:studentNum];
                }
                else
                {
                    [weakSelf.teacherListView setDataSource:users withType:SCTeacherTopBarTypePersonList userNum:studentNum];
                }
                
            });
            
        }];
    }
    else
    {
        BMWeakSelf
        NSInteger studentNum = self.liveManager.studentCount ;
        NSInteger assistantNum = self.liveManager.assistantCount;
        [self.liveManager.roomManager getRoomUsersWithRole:@[@(YSUserType_Assistant),@(YSUserType_Student)] startIndex:0 maxNumber:(studentNum + assistantNum) search:searchContent order:@{} callback:^(NSArray<YSRoomUser *> * _Nonnull users, NSError * _Nonnull error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // UI更新代码
                
                self->searchArr = [NSMutableArray arrayWithArray:users];
                [weakSelf.teacherListView setPersonListCurrentPage:0 totalPage:ceil((CGFloat)users.count/(CGFloat)onePageMaxUsers)];
                if (users.count > onePageMaxUsers)
                {
                    NSArray *data = [users subarrayWithRange:NSMakeRange(0, onePageMaxUsers)];
                    [weakSelf.teacherListView setDataSource:data withType:SCTeacherTopBarTypePersonList userNum:studentNum];
                }
                else
                {
                    [weakSelf.teacherListView setDataSource:users withType:SCTeacherTopBarTypePersonList userNum:studentNum];
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
#pragma mark SCBoardControlViewDelegate

#warning WhitebordFullScreen

/// 全屏 复原 回调
//- (void)boardControlProxyfullScreen:(BOOL)isAllScreen
 - (void)handleonWhiteBoardFullScreen:(BOOL)isAllScreen
{
    self.isWhitebordFullScreen = isAllScreen;
    
//    [self.boardControlView resetBtnStates];
    
//    self.boardControlView.isAllScreen = isAllScreen;

    if (isAllScreen)
    {
        [self.view endEditing:YES];
        [self.whiteBordView removeFromSuperview];
        
#if USE_FullTeacher
        self.fullTeacherFloatView.isFullBackgrond = YES;
#endif
        self.whitebordFullBackgroud.hidden = NO;
        // 加载白板
        [self.whitebordFullBackgroud addSubview:self.whiteBordView];
        self.whiteBordView.frame = CGRectMake(0, 0, self.whitebordFullBackgroud.bm_width, self.whitebordFullBackgroud.bm_height);
        [self arrangeAllViewInVCView];
        
#if USE_FullTeacher
        [self playFullTeacherVideoViewInView:self.whitebordFullBackgroud];
//        [self.fullTeacherFloatView bm_bringToFront];
#endif
    }
    else
    {
#if USE_FullTeacher
        self.fullTeacherFloatView.isFullBackgrond = NO;
#endif
        self.whitebordFullBackgroud.hidden = YES;
        [self.whiteBordView removeFromSuperview];
        [self.whitebordBackgroud addSubview:self.whiteBordView];
        self.whiteBordView.frame = self.whitebordBackgroud.bounds;
        
        [self arrangeAllViewInWhiteBordBackgroud];
        //        [self freshContentView];
        
//        self.boardControlView.hidden = self.isDoubleVideoBig || (self.roomLayout == YSLiveRoomLayout_VideoLayout);
        if (YSCurrentUser.canDraw)
        {
            self.brushToolView.hidden = self.isDoubleVideoBig || (self.roomLayout == YSLiveRoomLayout_VideoLayout);
        }
        
        if (!YSCurrentUser.canDraw || self.brushToolView.hidden || self.brushToolOpenBtn.selected || self.brushToolView.mouseBtn.selected )
        {
            self.drawBoardView.hidden = YES;
        }
        else
        {
            self.drawBoardView.hidden = NO;
        }
#if USE_FullTeacher
        [self stopFullTeacherVideoView];
#endif
    }

    [self.liveManager.whiteBoardManager refreshWhiteBoard];
    [self.liveManager.whiteBoardManager whiteBoardResetEnlarge];

}



#pragma mark -聊天输入框工具栏

- (SCChatToolView *)chatToolView
{
    if (!_chatToolView)
    {
        self.chatToolView = [[SCChatToolView alloc]initWithFrame:CGRectMake(0, BMUI_SCREEN_HEIGHT, self.contentWidth, SCChatToolHeight)];
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

#pragma mark - 标题限制140字

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.tag == SCMessageInputViewTag)
    {
        NSInteger existTextNum = textView.text.length;
        if (existTextNum == 1 && [textView.text isEqualToString:@" "])
        {
            //existTextNum = 0;
            textView.text = @"";
        }
        else if (existTextNum > 140)
        {
            //截取到最大位置的字符
            NSString *s = [textView.text substringToIndex:140];
            [textView setText:s];
            
            BMProgressHUD *hub = [BMProgressHUD bm_showHUDAddedTo:self.view animated:YES withDetailText:YSLocalized(@"Alert.NumberOfWords.140")];
            hub.yOffset = -100;
            [BMProgressHUD bm_hideHUDForView:self.view animated:YES delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
        }
    }
}

#pragma mark - 打开相册选择图片

- (void)openTheImagePickerWithImageUseType:(SCUploadImageUseType)imageUseType{
    
    BMTZImagePickerController * imagePickerController = [[BMTZImagePickerController alloc]initWithMaxImagesCount:3 columnNumber:1 delegate:self pushPhotoPickerVc:YES];
    imagePickerController.showPhotoCannotSelectLayer = YES;
    imagePickerController.showSelectedIndex = YES;
    imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
    imagePickerController.sortAscendingByModificationDate = NO;
    
    BMWeakSelf
    [imagePickerController setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        [YSLiveApiRequest uploadImageWithImage:photos.firstObject withImageUseType:imageUseType success:^(NSDictionary * _Nonnull dict) {
            
            if (imageUseType == 0)
            {
                [self.liveManager.whiteBoardManager addWhiteBordImageCourseWithDic:dict];
            }
            else
            {
                BOOL isSucceed = [[YSLiveManager shareInstance] sendMessageWithText:[dict bm_stringTrimForKey:@"swfpath"]  withMessageType:YSChatMessageTypeOnlyImage withMemberModel:nil];
                if (!isSucceed) {
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
//    NSString *action = isDynamicPPT ? sActionShow : @"";
//    NSString *mediaType = @"";
//    NSString *filetype = @"jpeg";
//
//    [docDic setObject:action forKey:@"action"];
//    [docDic setObject:filetype forKey:@"filetype"];
//
//    [self.liveManager.whiteBoardManager addDocumentWithFileDic:docDic];
//
//    NSString *fileid = [docDic bm_stringTrimForKey:@"fileid" withDefault:@""];
//    NSString *filename = [docDic bm_stringTrimForKey:@"filename" withDefault:@""];
//    NSUInteger pagenum = [docDic bm_uintForKey:@"pagenum"];
//    NSString *swfpath = [docDic bm_stringTrimForKey:@"swfpath" withDefault:@""];
//
//    NSDictionary *tDataDic = @{
//        @"isDel" : @(false),
//        @"isGeneralFile" : @(isGeneralFile),
//        @"isDynamicPPT" : @(isDynamicPPT),
//        @"isH5Document" : @(isH5Document),
//        @"action" : action,
//        @"mediaType" : mediaType,
//        @"isMedia" : @(false),
//        @"filedata" : @{
//                @"fileid" : fileid,
//                @"filename" : filename,
//                @"filetype" : filetype,
//                @"currpage" : @(1),
//                @"pagenum" : @(pagenum),
//                @"pptslide" : @(1),
//                @"pptstep" : @(0),
//                @"steptotal" : @(0),
//                @"swfpath" : swfpath
//        }
//    };
//
//    [self.liveManager sendPubMsg:sDocumentChange toID:YSRoomPubMsgTellAllExceptSender data:[tDataDic bm_toJSON] save:NO associatedMsgID:nil associatedUserID:nil expires:0 completion:nil];
//
//    NSString *downloadpath = [docDic bm_stringTrimForKey:@"downloadpath"];
//    BOOL isContentDocument = [docDic bm_boolForKey:@"isContentDocument"];
//
//    NSDictionary *tDataDic1 = @{
//        @"isGeneralFile" : @(isGeneralFile),
//        @"isDynamicPPT" : @(isDynamicPPT),
//        @"isH5Document" : @(isH5Document),
//        @"action" : action,
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
//    [self.liveManager.roomManager pubMsg:sShowPage msgID:sDocumentFilePage_ShowPage toID:YSRoomPubMsgTellAll data:[tDataDic1 bm_toJSON] save:YES associatedMsgID:nil associatedUserID:nil expires:0 completion:nil];
//}

//输入框条上表情按钮的点击事件
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

#pragma mark 表情键盘

- (YSEmotionView *)emotionListView
{
    if (!_emotionListView)
    {
        self.emotionListView = [[YSEmotionView alloc]initWithFrame:CGRectMake(0, BMUI_SCREEN_HEIGHT, self.contentWidth, SCChateEmotionHeight)];
        
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

#pragma mark 键盘通知方法

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
            self.chatToolView.bm_originY = BMUI_SCREEN_HEIGHT - keyboardF.size.height - SCChatToolHeight;
            self.emotionListView.bm_originY = BMUI_SCREEN_HEIGHT;
        }];
        self.chatToolView.emojBtn.selected = NO;
    }
    else if (firstResponder.tag == YSWHITEBOARD_TEXTVIEWTAG)
    {//调用白板键盘
        [UIView animateWithDuration:duration animations:^{
            self.chatToolView.bm_originY = self.emotionListView.bm_height = BMUI_SCREEN_HEIGHT;
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
    
    double duration=[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    if (self.chatToolView.emojBtn.selected)
    {
        [UIView animateWithDuration:0.25 animations:^{
            self.chatToolView.bm_originY = BMUI_SCREEN_HEIGHT-SCChateEmotionHeight-SCChatToolHeight;
            self.emotionListView.bm_originY = BMUI_SCREEN_HEIGHT-SCChateEmotionHeight;
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
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.chatToolView.bm_originY<self.contentHeight-10)
    {
        [self hiddenTheKeyBoard];
    }
    else
    {
//        self.chatBtn.selected = NO;
        CGRect tempRect = self.rightChatView.frame;
        tempRect.origin.x = BMUI_SCREEN_WIDTH;
        [UIView animateWithDuration:0.25 animations:^{
            self.rightChatView.frame = tempRect;
        }];
    }
}


#pragma mark - 顶部bar 定时操作
- (void)countDownTime:(NSTimer *)timer
{
    NSTimeInterval time = self.liveManager.tCurrentTime - self.liveManager.tClassStartTime;
    NSString *str =  [NSDate bm_countDownENStringDateFromTs:time];
    self.lessonTime = str;
}


#pragma mark -
#pragma mark YSWhiteBoardManagerDelegate



#pragma mark -
#pragma mark YSLiveRoomManagerDelegate

/// 大并发房间
- (void)roomManagerChangeToBigRoomInList:(BOOL)inlist
{
    BMWeakSelf
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.bigRoomTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(self.bigRoomTimer, DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    //3.要调用的任务
    dispatch_source_set_event_handler(self.bigRoomTimer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf freshTeacherPersonListData];
        });
    });
    //4.开始执行
    dispatch_resume(self.bigRoomTimer);
    
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
#if 0
    [self removeAllVideoView];
    
    if (self.isWhitebordFullScreen)
    {
        [self boardControlProxyfullScreen:NO];
    }
    
    [self handleSignalingDefaultRoomLayout];
    
    BOOL canDraw = NO;
    if (self.roomLayout == YSLiveRoomLayout_VideoLayout || self.roomLayout == YSLiveRoomLayout_FocusLayout)
    {
//        self.coursewareBtn.hidden =
        self.brushToolView.hidden = YES;
        self.drawBoardView.hidden = YES;
    }
    else
    {
//        self.coursewareBtn.hidden = YES;
        self.brushToolView.hidden = !canDraw;
        if (!canDraw || !self.brushToolView.toolsBtn.selected || self.brushToolView.mouseBtn.selected)
        {
            self.drawBoardView.hidden = YES;
        }else{
            self.drawBoardView.hidden = NO;
        }
    }
    
    [self resetDrawTools];
#endif
}

- (void)onRoomReJoined:(long)ts
{
    [super onRoomReJoined:ts];
    self.spreadBottomToolBar.userEnable = YES;
}


- (void)resetDrawTools
{
    [self.brushToolView resetTool];
    self.drawBoardView.brushToolType = YSBrushToolTypeMouse;
    [self.liveManager.whiteBoardManager freshBrushToolConfig];
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
    if (self.bigRoomTimer)
    {
        dispatch_source_cancel(self.bigRoomTimer);
        self.bigRoomTimer = nil;
    }

    if (self.controlPopoverView.presentingViewController)
    {
        [self.controlPopoverView dismissViewControllerAnimated:NO completion:nil];
    }

    [self.imagePickerController cancelButtonClick];
    
    // 网络中断尝试失败后退出
    [[BMNoticeViewStack sharedInstance] closeAllNoticeViews];// 清除alert的栈
    [self dismissViewControllerAnimated:YES completion:^{
#if YSSDK
        [self.liveManager onSDKRoomLeft];
#endif
        [YSLiveManager destroy];
    }];
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
        [self.progressHUD bm_showAnimated:NO withDetailText:YSLocalized(@"Error.WaitingForNetwork") delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
    }
}

/// 老师主播的网络状态变化
- (void)roomManagerTeacherChangeNetStats:(id)stats
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
        [self.progressHUD bm_showAnimated:NO withDetailText:YSLocalized(@"Error.WaitingForNetwork") delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
    }
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

/// 用户进入
- (void)roomManagerRoomTeacherEnter
{
#if USE_FullTeacher
    self.teacherPlaceLab.hidden = self.liveManager.isBeginClass;
    if (!self.whitebordFullBackgroud.hidden || !self.shareVideoFloatView.hidden)
    {
        self.fullTeacherFloatView.hidden = NO;
    }
#endif
}

- (void)roomManagerRoomTeacherLeft
{
#if USE_FullTeacher
    self.teacherPlaceLab.hidden = YES;
    self.fullTeacherFloatView.hidden = YES;
#endif
}

/// 用户进入
- (void)roomManagerJoinedUser:(YSRoomUser *)user inList:(BOOL)inList
{
    [self freshTeacherPersonListData];
    // 不做互踢
#if 0
    if (self.roomtype == YSRoomType_One)
    {
        if (inList == YES)
        {
            if (user.role == self.liveManager.localUser.role)
            {
                [self.liveManager.roomManager evictUser:user.peerID completion:nil];
            }
        }
    }
#endif
}

/// 用户退出
- (void)roomManagerLeftUser:(YSRoomUser *)user
{
    [self freshTeacherPersonListData];
    if (self.roomtype == YSRoomType_More)
    {
        [self delVidoeViewWithPeerId:user.peerID];
    }
}

- (void)roomManagerBigRoomFreshUserCountInList:(BOOL)inlist
{
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

    if (self.controlPopoverView.presentingViewController)
    {
        [self.controlPopoverView dismissViewControllerAnimated:NO completion:nil];
    }

    [self.imagePickerController cancelButtonClick];
    
    BMWeakSelf
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:reasonString message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confimAc = [UIAlertAction actionWithTitle:YSLocalized(@"Prompt.OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [weakSelf.liveManager leaveRoom:nil];
        
    }];
    [alertVc addAction:confimAc];
    [self presentViewController:alertVc animated:YES completion:nil];
}

/// 全体禁言
- (void)handleSignalingToDisAbleEveryoneBanChatWithIsDisable:(BOOL)isDisable
{
//    self.rightChatView.allDisabled = isDisable;
    [self.liveManager sendSignalingToChangePropertyWithRoomUser:YSCurrentUser withKey:sUserDisablechat WithValue:@(isDisable)];
    [self hiddenTheKeyBoard];
}

#pragma mark 用户属性变化

- (void)onRoomUserPropertyChanged:(NSString *)peerID properties:(NSDictionary *)properties fromId:(NSString *)fromId
{
    SCVideoView *videoView = [self getVideoViewWithPeerId:peerID];
    YSRoomUser *roomUser = [self.liveManager.roomManager getRoomUserWithUId:peerID];

    // 网络状态
    if ([properties bm_containsObjectForKey:sUserNetWorkState])
    {
        [videoView freshWithRoomUserProperty:roomUser];
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
            //canDraw = [properties bm_boolForKey:sUserCandraw];
            if (self.roomLayout == YSLiveRoomLayout_VideoLayout)
            {
                self.brushToolView.hidden = YES;
                self.brushToolOpenBtn.hidden = YES;
                self.drawBoardView.hidden = YES;
            }
            else
            {
                self.brushToolView.hidden = !canDraw;
                self.brushToolOpenBtn.hidden = !canDraw;
                if (!canDraw || self.brushToolOpenBtn.selected || self.brushToolView.mouseBtn.selected)
                {
                    self.drawBoardView.hidden = YES;
                }else{
                    //self.drawBoardView.brushToolType = YSBrushToolTypeMouse;
                    self.drawBoardView.hidden = NO;
                }
            }
            
            // 设置画笔颜色初始值
            if (canDraw)
            {
                if (![[YSCurrentUser.properties bm_stringTrimForKey:sUserPrimaryColor] bm_isNotEmpty])
                {
                    [self setCurrentUserPrimaryColor];
                }
                [self resetDrawTools];
            }
            
            videoView.canDraw = canDraw;
            
//            [self.topToolBar hidePhotoBtn:!canDraw];
            
            YSPublishState publishState = [YSCurrentUser.properties bm_intForKey:sUserPublishstate];
            if (publishState < YSUser_PublishState_AUDIOONLY)
            {
//                [self.topToolBar hideMicrophoneBtn:YES];
            }
            else
            {
//                [self.topToolBar hideMicrophoneBtn:NO];
            }
        }
    }
    
    // 本人是否被禁言
    if ([properties bm_containsObjectForKey:sUserDisablechat])
    {
        if ([peerID isEqualToString:YSCurrentUser.peerID])
        {
            BOOL disablechat = [properties bm_boolForKey:sUserDisablechat];
                        
//            self.rightChatView.allDisabledChat.hidden = !disablechat;
            self.rightChatView.allDisabled = disablechat;
            if (disablechat)
            {
                [self hiddenTheKeyBoard];
            }
            
            YSRoomUser *fromUser = [self.liveManager.roomManager getRoomUserWithUId:fromId];
            if (fromUser.role == YSUserType_Teacher || fromUser.role == YSUserType_Assistant)
            {
                if (disablechat)
                {
                    [[YSLiveManager shareInstance] sendTipMessage:YSLocalized(@"Prompt.BanChat") tipType:YSChatMessageTypeTips];
                }
                else
                {
                    [[YSLiveManager shareInstance] sendTipMessage:YSLocalized(@"Prompt.CancelBanChat") tipType:YSChatMessageTypeTips];
                }
            }
        }
    }
    
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
    }
    
    // 发布媒体状态
    if ([properties bm_containsObjectForKey:sUserPublishstate])
    {
        YSPublishState publishState = [properties bm_intForKey:sUserPublishstate];
        
        if ([peerID isEqualToString:self.liveManager.localUser.peerID])
        {
            if (publishState == YSUser_PublishState_VIDEOONLY)
            {
//                [self.topToolBar selectMicrophoneBtn:YES];
                self.controlPopoverView.audioBtn.selected = NO;
                self.controlPopoverView.videoBtn.selected = YES;
            }
            if (publishState == YSUser_PublishState_AUDIOONLY)
            {
//                [self.topToolBar selectMicrophoneBtn:NO];
                self.controlPopoverView.audioBtn.selected = YES;
                self.controlPopoverView.videoBtn.selected = NO;
            }
            if (publishState == YSUser_PublishState_BOTH)
            {
//                [self.topToolBar selectMicrophoneBtn:NO];
                self.controlPopoverView.audioBtn.selected = YES;
                self.controlPopoverView.videoBtn.selected = YES;
            }
            if (publishState < YSUser_PublishState_AUDIOONLY)
            {
                if (!self.liveManager.isBeginClass)
                {
                    return;
                }
//                [self.topToolBar selectMicrophoneBtn:NO];
//                [self.topToolBar hideMicrophoneBtn:YES];
                    self.controlPopoverView.audioBtn.selected = NO;
                    self.controlPopoverView.videoBtn.selected = NO;
                    if (self.controlPopoverView.presentingViewController)
                    {
                        [self.controlPopoverView dismissViewControllerAnimated:NO completion:nil];
                    }
            }
            else if (publishState > YSUser_PublishState_BOTH)
            {
//                [self.topToolBar selectMicrophoneBtn:YES];
//                [self.topToolBar hideMicrophoneBtn:NO];
                self.controlPopoverView.audioBtn.selected = NO;
                self.controlPopoverView.videoBtn.selected = NO;
            }
            else
            {
//                [self.topToolBar hideMicrophoneBtn:NO];
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
        else if (publishState == 4)
        {
            [self addVidoeViewWithPeerId:peerID];
        }
        else if (publishState != 4)
        {
            if (!self.liveManager.isBeginClass)
            {
                return;
            }
            [self delVidoeViewWithPeerId:peerID];
        }
        
//        // 刷新当前用户前后台状态
//        if ([peerID isEqualToString:self.liveManager.localUser.peerID])
//        {
//            //videoView = [self getVideoViewWithPeerId:YSCurrentUser.peerID];
//            if ([videoView bm_isNotEmpty])
//            {
//                BOOL isInBackGround = NO;
//                UIApplicationState state = [[UIApplication sharedApplication] applicationState];
//                if (state != UIApplicationStateActive)
//                {
//                    isInBackGround = YES;
//                }
//                if (isInBackGround != videoView.isInBackGround)
//                {
//                    [self.liveManager.roomManager changeUserProperty:YSCurrentUser.peerID tellWhom:YSRoomPubMsgTellAll key:sUserIsInBackGround value:@(isInBackGround) completion:nil];
//                }
//            }
//        }
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
    
    //进入前后台
    if ([properties bm_containsObjectForKey:sUserIsInBackGround])
    {
        [videoView freshWithRoomUserProperty:roomUser];
    }
    
    // 视频镜像
    if ([properties bm_containsObjectForKey:sUserIsVideoMirror])
    {
        BOOL isVideoMirror = [properties bm_boolForKey:sUserIsVideoMirror];
        [self.liveManager changeVideoMirrorWithPeerId:peerID mirror:isVideoMirror];
    }
    
    /// 用户设备状态
    if ([properties bm_containsObjectForKey:sUserVideoFail] || [properties bm_containsObjectForKey:sUserAudioFail])
    {
        [videoView freshWithRoomUserProperty:roomUser];
    }

    if ([properties bm_containsObjectForKey:sUserPublishstate] || [properties bm_containsObjectForKey:sUserGiftNumber] || [properties bm_containsObjectForKey:sUserDisablechat])
    {
        if ((roomUser.role == YSUserType_Student) || (roomUser.role == YSUserType_Assistant))
        {
            [self freshTeacherPersonListData];
        }
    }
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
    
#if 0
    if (self.liveManager.isBeginClass)
    {
        needFreshVideoView = YES;
        
        // 因为切换网络会先调用classBegin
        // 所以要在这里刷新VideoAudio
        [self rePlayVideoAudio];
    
        if (self.appUseTheType == YSAppUseTheTypeSmallClass)
        {
            // 自动上台
            if (self.videoViewArray.count < maxVideoCount)
            {
                BOOL autoOpenAudioAndVideoFlag = self.liveManager.roomConfig.autoOpenAudioAndVideoFlag;
//                if (autoOpenAudioAndVideoFlag)
                if (autoOpenAudioAndVideoFlag && YSCurrentUser.role != YSUserType_Patrol)
                {
                    //if (YSCurrentUser.vfail == YSDeviceFaultNone)
                    {
                        [self.liveManager.roomManager unPublishVideo:nil];
                        [self.liveManager.roomManager publishVideo:nil];
                    }
                    //if (YSCurrentUser.afail == YSDeviceFaultNone)
                    {
                        [self.liveManager.roomManager unPublishAudio:nil];
                        BOOL isEveryoneNoAudio = [YSLiveManager shareInstance].isEveryoneNoAudio;
                        if (!isEveryoneNoAudio)
                        {
                            [self.liveManager.roomManager publishAudio:nil];
                        }
                    }
                }
            }
        }
        else if (self.appUseTheType == YSAppUseTheTypeMeeting)
        {//会议，进教室默认上台
            if (self.liveManager.isBeginClass && self.videoViewArray.count < maxVideoCount && YSCurrentUser.role != YSUserType_Patrol)
            {
                //if (YSCurrentUser.vfail == YSDeviceFaultNone)
                {
                    [self.liveManager.roomManager unPublishVideo:nil];
                    [self.liveManager.roomManager publishVideo:nil];
                }
                //if (YSCurrentUser.afail == YSDeviceFaultNone)
                {
                    [self.liveManager.roomManager unPublishAudio:nil];
                    BOOL isEveryoneNoAudio = [YSLiveManager shareInstance].isEveryoneNoAudio;
                    if (!isEveryoneNoAudio)
                    {
                        [self.liveManager.roomManager publishAudio:nil];
                    }
                }
            }
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
#endif
}

#if 0
- (void)rePlayVideoAudio
{
    for (SCVideoView *videoView in self.videoViewArray)
    {
        [self stopVideoAudioWithVideoView:videoView];
        if ([videoView.roomUser.peerID isEqualToString:YSCurrentUser.peerID])
        {
            [videoView freshWithRoomUserProperty:YSCurrentUser];
        }

        [self playVideoAudioWithVideoView:videoView];
    }
}
#endif

#pragma mark 上课

- (void)handleSignalingClassBeginWihInList:(BOOL)inlist
{
    self.rightChatView.allDisabled = NO;

    self.teacherPlaceLab.hidden = YES;
    
    [self addVidoeViewWithPeerId:self.liveManager.teacher.peerID];
    if (self.liveManager.localUser.role == YSUserType_Patrol)
    {
//        [self.topToolBar hideCoursewareBtn:NO];
//        [self.topToolBar hidePersonListBtn:NO];
    }
    else
    {
//        [self.topToolBar hideCoursewareBtn:YES];
//        [self.topToolBar hidePersonListBtn:YES];
    }
    [self freshTeacherPersonListData];
    
    for (YSRoomUser *roomUser in self.liveManager.userList)
    {
#if 0
        if (needFreshVideoView)
        {
            needFreshVideoView = NO;
            break;
        }
#endif
        
        BOOL isTeacher = NO;
        
        YSPublishState publishState = [roomUser.properties bm_intForKey:sUserPublishstate];
        NSString *peerID = roomUser.peerID;
        if ([peerID isEqualToString:self.liveManager.teacher.peerID])
        {
            isTeacher = YES;
        }

        if (publishState == YSUser_PublishState_VIDEOONLY)
        {
            if (!isTeacher)
            {
                [self addVidoeViewWithPeerId:peerID];
            }
        }
        else if (publishState == YSUser_PublishState_AUDIOONLY)
        {
            if (!isTeacher)
            {
                [self addVidoeViewWithPeerId:peerID];
            }
        }
        else if (publishState == YSUser_PublishState_BOTH)
        {
            if (!isTeacher)
            {
                [self addVidoeViewWithPeerId:peerID];
            }
        }
        else if (publishState == 4)
        {
            if (!isTeacher)
            {
                [self addVidoeViewWithPeerId:peerID];
            }
        }
        else
        {
            if (!isTeacher)
            {
                [self delVidoeViewWithPeerId:peerID];
            }
        }
    }
    
    //self.boardControlView.allowPaging = self.liveManager.roomConfig.canPageTurningFlag;

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

    //if (!inlist)
    {
        if (self.appUseTheType == YSAppUseTheTypeSmallClass)
        {
            // 自动上台
            if (self.videoViewArray.count < maxVideoCount)
            {
                BOOL autoOpenAudioAndVideoFlag = self.liveManager.roomConfig.autoOpenAudioAndVideoFlag;
//                if (autoOpenAudioAndVideoFlag)
                if (autoOpenAudioAndVideoFlag && YSCurrentUser.role != YSUserType_Patrol)
                {
                    //if (YSCurrentUser.vfail == YSDeviceFaultNone)
                    {
                        [self.liveManager.roomManager publishVideo:nil];
                    }
                    //if (YSCurrentUser.afail == YSDeviceFaultNone)
                    {
                        BOOL isEveryoneNoAudio = [YSLiveManager shareInstance].isEveryoneNoAudio;
                        if (!isEveryoneNoAudio)
                        {
                            [self.liveManager.roomManager publishAudio:nil];
                        }
                    }
                }
            }
        }
        else if (self.appUseTheType == YSAppUseTheTypeMeeting)
        {//会议，进教室默认上台
            if (self.liveManager.isBeginClass && self.videoViewArray.count < maxVideoCount && YSCurrentUser.role != YSUserType_Patrol)
            {
                //if (YSCurrentUser.vfail == YSDeviceFaultNone)
                {
                    [self.liveManager.roomManager publishVideo:nil];
                }
                //if (YSCurrentUser.afail == YSDeviceFaultNone)
                {
                    BOOL isEveryoneNoAudio = [YSLiveManager shareInstance].isEveryoneNoAudio;
                    if (!isEveryoneNoAudio)
                    {
                        [self.liveManager.roomManager publishAudio:nil];
                    }
                }
                
                [self.liveManager sendSignalingToChangePropertyWithRoomUser:YSCurrentUser withKey:sUserCandraw WithValue:@(true)];
            }
        }
    }
    
    if (inlist)
    {
        // 刷新当前用户前后台状态
        NSDictionary *properties = self.liveManager.localUser.properties;
        BOOL userIsInBackGround = [properties bm_boolForKey:sUserIsInBackGround];

        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
        BOOL isInBackGround = NO;
        if (state != UIApplicationStateActive)
        {
            isInBackGround = YES;
        }
        
        if (isInBackGround != userIsInBackGround)
        {
#if DEBUG
            [self bringSomeViewToFront];
            [self.progressHUD bm_showAnimated:NO withDetailText:@"出现后台问题！！！！！！！！" delay:5];
#endif

            [self.liveManager.roomManager changeUserProperty:YSCurrentUser.peerID tellWhom:YSRoomPubMsgTellAll key:sUserIsInBackGround value:@(isInBackGround) completion:nil];
        }
    }
}

/// 下课
- (void)handleSignalingClassEndWithText:(NSString *)text
{
    if (self.controlPopoverView.presentingViewController)
    {
        [self.controlPopoverView dismissViewControllerAnimated:NO completion:nil];
    }
    
    [self.imagePickerController cancelButtonClick];
    
    BMWeakSelf
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:text message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confimAc = [UIAlertAction actionWithTitle:YSLocalized(@"Prompt.OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [weakSelf.liveManager leaveRoom:nil];
        
    }];
    [alertVc addAction:confimAc];
    [self presentViewController:alertVc animated:YES completion:nil];
}

/// 弹框
- (void)showSignalingClassEndWithText:(NSString *)text
{
    if (self.controlPopoverView.presentingViewController)
    {
        [self.controlPopoverView dismissViewControllerAnimated:NO completion:nil];
    }
    
    [self.imagePickerController cancelButtonClick];
    
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:text message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confimAc = [UIAlertAction actionWithTitle:YSLocalized(@"Prompt.OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertVc addAction:confimAc];
    [self presentViewController:alertVc animated:YES completion:nil];
}


///学生收到RaiseHandStart展示举手按钮
- (void)handleSignalingAllowEveryoneRaiseHand
{
    self.raiseHandsBtn.hidden = NO;
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

#pragma mark - 窗口布局变化
- (void)handleSignalingSetRoomLayout:(YSLiveRoomLayout)roomLayout withPeerId:(nullable NSString *)peerId
{
    self.roomLayout = roomLayout;
    
    if (!self.isWhitebordFullScreen)
    {
        if (YSCurrentUser.canDraw)
        {
            self.brushToolView.hidden = (self.roomLayout == YSLiveRoomLayout_VideoLayout) || (self.roomLayout == YSLiveRoomLayout_FocusLayout);
            self.brushToolOpenBtn.hidden = (self.roomLayout == YSLiveRoomLayout_VideoLayout) || (self.roomLayout == YSLiveRoomLayout_FocusLayout);
        }
    }
    
    if (!YSCurrentUser.canDraw || self.brushToolView.hidden || self.brushToolOpenBtn.selected || self.brushToolView.mouseBtn.selected )
    {
        self.drawBoardView.hidden = YES;
    }
    else
    {
        self.drawBoardView.hidden = NO;
    }
    
    if (roomLayout == YSLiveRoomLayout_FocusLayout && peerId)
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
            self.roomLayout = YSLiveRoomLayout_VideoLayout;
        }
    }
    
    [self freshContentView];
}

- (void)handleSignalingDefaultRoomLayout
{
    [self handleSignalingSetRoomLayout:defaultRoomLayout withPeerId:nil];
}

#if USE_FullTeacher

#pragma mark 全屏课件时可以拖动老师视频
- (void)panToMoveVideoView:(SCVideoView*)videoView withGestureRecognizer:(nonnull UIPanGestureRecognizer *)pan
{
    if ((self.roomtype == YSRoomType_One && ![videoView isEqual:self.fullTeacherVideoView]) || self.roomLayout == YSLiveRoomLayout_FocusLayout)
    {
        return;
    }
    
    CGPoint endPoint = [pan translationInView:videoView];
    
    UIView * background = nil;
    
    if (self.isWhitebordFullScreen)
    {//课件全屏
        background = self.whitebordFullBackgroud;
    }
    else if (!self.shareVideoFloatView.hidden)
    {
        background = self.shareVideoFloatView;
    }
    
    
    if (!self.dragImageView)
    {
        UIImage * img = [self.fullTeacherVideoView bm_screenshot];
        self.dragImageView = [[UIImageView alloc]initWithImage:img];
        [background addSubview:self.dragImageView];
    }
    
    if (self.videoOriginInSuperview.x == 0 && self.videoOriginInSuperview.y == 0)
    {
        self.videoOriginInSuperview = [background convertPoint:CGPointMake(0, 0) fromView:videoView];
//        [self.whitebordFullBackgroud bringSubviewToFront:self.dragImageView];
        [self.dragImageView bm_bringToFront];
    }
    self.dragImageView.frame = CGRectMake(self.videoOriginInSuperview.x + endPoint.x, self.videoOriginInSuperview.y + endPoint.y, videoView.bm_width, videoView.bm_height);
    
    if (pan.state == UIGestureRecognizerStateEnded)
    {
         [[PanGestureControl shareInfo] removePanGestureAction:LONG_PRESS_VIEW_DEMO];
        
        CGFloat percentLeft = 0;
        if (self.contentWidth != videoView.bm_width)
        {
            percentLeft = (self.videoOriginInSuperview.x+endPoint.x)/(self.contentWidth - videoView.bm_width);
        }
        CGFloat percentTop = 0;
        if (background.bm_height != videoView.bm_height) {
            percentTop = (self.videoOriginInSuperview.y+endPoint.y)/(background.bm_height - videoView.bm_height);
        }
        
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

        if (self.isWhitebordFullScreen || !self.shareVideoFloatView.hidden)
        {//课件全屏
            if (percentTop<0)
            {
                percentTop = 0;
            }
            [self showDragOutFullTeacherVidoeViewWithPercentLeft:percentLeft percentTop:percentTop];
        }
        else
        {//不全屏
            if (percentTop<0)
            {
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
            else
            {
                NSDictionary * data = @{
                    @"isDrag":@1,
                    @"percentLeft":[NSString stringWithFormat:@"%f",percentLeft],
                    @"percentTop":[NSString stringWithFormat:@"%f",percentTop],
                    @"userId":videoView.roomUser.peerID
                };
                [self.liveManager sendSignalingToDragOutVideoViewWithData:data];
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

// 全屏课件时拖拽视频
- (void)showDragOutFullTeacherVidoeViewWithPercentLeft:(CGFloat)percentLeft percentTop:(CGFloat)percentTop
{
    if (self.roomLayout == YSLiveRoomLayout_VideoLayout)
    {
        return;
    }
    
    UIView * background = nil;
    
    if (self.isWhitebordFullScreen)
    {//课件全屏
        background = self.whitebordFullBackgroud;
    }
    else if (!self.shareVideoFloatView.hidden)
    {
        background = self.shareVideoFloatView;
    }
    
    SCVideoView *videoView = self.fullTeacherVideoView;
    if (self.isFullTeacherVideoViewDragout)
    {
        CGFloat x = percentLeft * (self.contentWidth - 2 - videoView.bm_width);
        CGFloat y = percentTop * (background.bm_height - 2 - videoView.bm_height);
        if (x <= 0)
        {
            x = 1.0;
        }
        
        CGPoint point = CGPointMake(x, y);
        
        self.fullTeacherFloatView.frame = CGRectMake(point.x, point.y, videoView.bm_width, videoView.bm_height);
                
        [self.fullTeacherFloatView bm_bringToFront];
    }
    else
    {
        self.isFullTeacherVideoViewDragout = YES;
        
        CGFloat x = percentLeft * (self.contentWidth - 2 - floatVideoDefaultWidth);
        CGFloat y = percentTop * (background.bm_height - 2 - floatVideoDefaultHeight);
        if (x <= 0) {
            x = 1.0;
        }
        CGPoint point = CGPointMake(x, y);
        self.fullTeacherFloatView.frame = CGRectMake(point.x, point.y, floatVideoDefaultWidth, floatVideoDefaultHeight);
        
        // 支持本地拖动缩放
        self.fullTeacherFloatView.canGestureRecognizer = YES;
        self.fullTeacherFloatView.defaultSize = CGSizeMake(floatVideoDefaultWidth, floatVideoDefaultHeight);
        [self.fullTeacherFloatView bm_bringToFront];
        self.fullTeacherFloatView.maxSize = background.bm_size;
        self.fullTeacherFloatView.peerId = YSCurrentUser.peerID;
    }
}
#endif

#pragma mark 拖出/放回视频窗口

/// 拖出/放回视频窗口
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

/// 拖出视频窗口拉伸 根据本地默认尺寸scale
- (void)handleSignalingDragOutVideoChangeSizeWithPeerId:(NSString *)peerId scale:(CGFloat)scale
{
    YSFloatView *floatView = [self getVideoFloatViewWithPeerId:peerId];
    //CGFloat dx = floatVideoDefaultWidth*(1-scale)*0.5;
    //CGFloat dy = floatVideoDefaultHeight*(1-scale)*0.5;
    //CGRect frame = CGRectMake(floatView.bm_left+dx, floatView.bm_top+dy, floatVideoDefaultWidth+fabs(dx*2), floatVideoDefaultHeight+fabs(dy*2));// CGRectInset(floatView.frame, dx, dy);
    
    CGFloat widthScale = self.whitebordBackgroud.bm_width / floatVideoDefaultWidth;
    CGFloat heightScale = self.whitebordBackgroud.bm_height / floatVideoDefaultHeight;
    
    CGFloat minscale = widthScale < heightScale ? widthScale : heightScale;
    minscale = minscale < scale ? minscale : scale;
    CGFloat width = floatVideoDefaultWidth*minscale;
    CGFloat height = floatVideoDefaultHeight*minscale;
    
    CGPoint center = floatView.center;
    
    floatView.bm_size = CGSizeMake(width, height);
    floatView.center = center;
    
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
        if (YSCurrentUser.canDraw)
        {
            self.brushToolView.hidden = isFull;
            self.brushToolOpenBtn.hidden = isFull;
        }
    }
    if (!YSCurrentUser.canDraw || self.brushToolView.hidden || self.brushToolOpenBtn.selected || self.brushToolView.mouseBtn.selected )
    {
        self.drawBoardView.hidden = YES;
    }
    else
    {
        self.drawBoardView.hidden = NO;
    }
//    [self freshWhiteBordViewFrame];
}

#pragma mark 白板翻页 换课件
// 播放白板视频/音频
- (void)handleWhiteBordPlayMediaFileWithMedia:(YSLiveMediaModel *)mediaModel
{
    isMediaPause = YES;
    
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
    [self freshTeacherCoursewareListData];
}

// 停止白板视频/音频
- (void)handleWhiteBordStopMediaFileWithMedia:(YSLiveMediaModel *)mediaModel
{
    isMediaStop = YES;
    
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
    [self freshTeacherCoursewareListData];
}

/// 继续播放白板视频/音频
- (void)handleWhiteBordPlayMediaStream
{
    isMediaPause = NO;
    if (!self.liveManager.playMediaModel.video && self.liveManager.playMediaModel.audio)
    {
        [self onPlayMp3];
    }
     [self freshTeacherCoursewareListData];
}

/// 暂停播放白板视频/音频
- (void)handleWhiteBordPauseMediaStream
{
    isMediaPause = YES;
    if (!self.liveManager.playMediaModel.video && self.liveManager.playMediaModel.audio)
    {
        [self onPauseMp3];
    }
    [self freshTeacherCoursewareListData];
}

/// 显示白板视频标注
- (void)handleSignalingShowVideoWhiteboardWithData:(NSDictionary *)data videoRatio:(CGFloat)videoRatio
{

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
}

/// 绘制白板视频标注
- (void)handleSignalingDrawVideoWhiteboardWithData:(NSDictionary *)data inList:(BOOL)inlist
{

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

/// 媒体课件状态
- (void)handleonWhiteBoardMediaFileStateWithFileId:(NSString *)fileId state:(YSWhiteBordMediaState)state
{
    self.currentMediaFileID = fileId;
    self.currentMediaState = state;
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
- (void)onWhiteBoardChangedFileWithFileList:(NSString *)fileId
{
    
}

- (void)handleSignalingWhiteBroadShowPageMessage:(NSDictionary *)message isDynamic:(BOOL)isDynamic
{
    [self freshTeacherCoursewareListData];
}

/// 收到添加删除文件信令
- (void)handleSignalingWhiteBroadDocumentChange
{
    [self freshTeacherCoursewareListData];
}


#pragma mark 共享桌面

/// 开始桌面共享 服务端控制与课件视频/音频互斥
- (void)handleRoomStartShareDesktopWithPeerID:(NSString *)peerID
{
// 取消共享限制老师
//    if (![peerID isEqualToString:self.liveManager.teacher.peerID])
//    {
//        return;
//    }
    
    [self showShareVidoeViewWithPeerId:peerID];
}

/// 停止桌面共享
- (void)handleRoomStopShareDesktopWithPeerID:(NSString *)peerID
{
//    if (![peerID isEqualToString:self.liveManager.teacher.peerID])
//    {
//        return;
//    }
    
    [self hideShareVidoeViewWithPeerId:peerID];
}

#pragma mark 进入前台后台

/// 进入后台
- (void)handleEnterBackground
{
    [self.liveManager.roomManager changeUserProperty:YSCurrentUser.peerID tellWhom:YSRoomPubMsgTellAll key:sUserIsInBackGround value:@(YES) completion:nil];
    [[PanGestureControl shareInfo] removePanGestureAction:LONG_PRESS_VIEW_DEMO];
}

/// 进入前台
- (void)handleEnterForeground
{
    [self.liveManager.roomManager changeUserProperty:YSCurrentUser.peerID tellWhom:YSRoomPubMsgTellAll key:sUserIsInBackGround value:@(NO) completion:nil];
}

#pragma mark  答题卡

/// 收到答题卡
- (void)handleSignalingSendAnswerWithAnswerId:(NSString *)answerId options:(nonnull NSArray *)options startTime:(NSInteger)startTime fromID:(NSString *)fromID
{
    BMLog(@"%@",options);
    if (self.answerView)
    {
        [self.answerView dismiss:nil];
    }
    if (self.answerResultView)
    {
        [self.answerResultView dismiss:nil];
    }
    self.answerMyResultDic = [NSMutableDictionary dictionaryWithCapacity:0];
    
    self.answerView = [[SCAnswerView alloc] init];
    [self.answerView showWithAnswerViewType:SCAnswerViewType_AnswerIng inView:self.view backgroundEdgeInsets:UIEdgeInsetsZero topDistance:0];
    self.answerView.dataSource = options;
    self.answerView.isSingle = NO;
    
    
    
    NSString *rightResult = @"";
    for (int i = 0; i < options.count ; i++) {
        NSDictionary *dic = options[i];
        NSUInteger isRight = [dic bm_intForKey:@"isRight"];
        NSString *content = [dic bm_stringForKey:@"content"];
        if (isRight == 1)
        {
            rightResult = [rightResult stringByAppendingFormat:@"%@,",content];
        }
    }
    
    if ([rightResult bm_isNotEmpty])
    {
        rightResult = [rightResult substringWithRange:NSMakeRange(0, rightResult.length - 1)];
    }
    self.rightAnswer = rightResult;
    
    BMWeakSelf
    self.answerView.firstSubmitBlock = ^(NSArray * _Nonnull submitArr) {
        
        [weakSelf.liveManager sendSignalingAnwserCommitWithAnswerId:answerId anwserResault:submitArr completion:nil];
        NSMutableArray *tempArr = [NSMutableArray arrayWithArray:submitArr];
        [tempArr sortUsingComparator:^NSComparisonResult(NSString * _Nonnull obj1, NSString * _Nonnull obj2) {
            
            return [obj1 compare:obj2];
        }];
        [weakSelf.answerMyResultDic setValue:tempArr forKey:weakSelf.liveManager.localUser.peerID];
        
    };
    
    self.answerView.nextSubmitBlock = ^(NSArray * _Nonnull addAnwserResault, NSArray * _Nonnull delAnwserResault, NSArray * _Nonnull notChangeAnwserResault) {
        [weakSelf.liveManager sendSignalingAnwserModifyWithAnswerId:answerId addAnwserResault:addAnwserResault delAnwserResault:delAnwserResault notChangeAnwserResault:notChangeAnwserResault completion:nil];
        
        /// 自己所选的答案  就是 未改变的 加上新添加的  （需要排序）
        NSArray *myResulst = [notChangeAnwserResault arrayByAddingObjectsFromArray:addAnwserResault];
        NSMutableArray *tempArr = [NSMutableArray arrayWithArray:myResulst];
        [tempArr sortUsingComparator:^NSComparisonResult(NSString * _Nonnull obj1, NSString * _Nonnull obj2) {
            
            return [obj1 compare:obj2];
        }];
        
        [weakSelf.answerMyResultDic setValue:tempArr forKey:weakSelf.liveManager.localUser.peerID];
        
    };
}

/// 答题结果
- (void)handleSignalingAnswerPublicResultWithAnswerId:(NSString *)answerId resault:(NSDictionary *)resault durationStr:(NSString *)durationStr answers:(NSArray *)answers totalUsers:(NSUInteger)totalUsers fromID:(NSString *)fromID
{
    if (self.answerView)
    {
        [self.answerView dismiss:nil];
    }
    
    self.answerResultView = [[SCAnswerView alloc] init];
    [self.answerResultView showWithAnswerViewType:SCAnswerViewType_Statistics inView:self.view backgroundEdgeInsets:UIEdgeInsetsZero topDistance:0];
    [self.answerResultView setAnswerResultWithStaticsDic:resault detailArr:answers duration:durationStr myResult:self.answerMyResultDic[self.liveManager.localUser.peerID] rightOption:self.rightAnswer totalUsers:totalUsers];
    //    self.answerView.dataSource = answers;
    //    self.answerView.isSingle = NO;
}

- (void)handleSignalingAnswerEndWithAnswerId:(NSString *)answerId fromID:(NSString *)fromID
{
    
    [[BMNoticeViewStack sharedInstance] closeAllNoticeViews];
}

- (void)handleSignalingDelAnswerResultWithAnswerId:(NSString *)answerId
{
    [[BMNoticeViewStack sharedInstance] closeAllNoticeViews];
}

#pragma mark -全体静音 发言
- (void)handleSignalingToliveAllNoAudio:(BOOL)noAudio
{
    if (self.liveManager.localUser.afail == YSDeviceFaultNone)
    {
        
        if (self.liveManager.isEveryoneNoAudio)
        {
            self.controlPopoverView.audioBtn.enabled = NO;
        }
        else
        {
            self.controlPopoverView.audioBtn.enabled = YES;
        }
        
        YSPublishState publishState = [YSCurrentUser.properties bm_intForKey:sUserPublishstate];
        BOOL needsend = NO;
        if (noAudio)
        {
            // 关闭音频
            if (publishState == YSUser_PublishState_AUDIOONLY)
            {
                publishState = 4;
                needsend = YES;
            }
            else if (publishState == YSUser_PublishState_BOTH)
            {
                publishState = YSUser_PublishState_VIDEOONLY;
                needsend = YES;
            }
        }
        else
        {
            // 打开音频
            if (publishState == 4)
            {
                publishState = YSUser_PublishState_AUDIOONLY;
                needsend = YES;
            }
            else if (publishState == YSUser_PublishState_VIDEOONLY)
            {
                publishState = YSUser_PublishState_BOTH;
                needsend = YES;
            }
        }
        
        if (needsend)
        {
            [self.liveManager.roomManager changeUserProperty:YSCurrentUser.peerID tellWhom:YSRoomPubMsgTellAll key:sUserPublishstate value:@(publishState) completion:nil];
        }
    }
}

#pragma mark - 抢答器
- (void)handleSignalingContestFromID:(NSString *)fromID
{
    contestTouchOne = 0;
    if (self.responderView)
    {
        [self.responderView dismiss:nil animated:NO dismissBlock:nil];
    }
      
    self.responderView = [[YSStudentResponder alloc] init];
    [self.responderView showInView:self.view backgroundEdgeInsets:UIEdgeInsetsZero topDistance:0];
    BMWeakSelf
    [[BMCountDownManager manager] startCountDownWithIdentifier:YSStudentResponderCountDownKey timeInterval:3 processBlock:^(id  _Nonnull identifier, NSInteger timeInterval, BOOL forcedStop) {
        BMLog(@"%ld", (long)timeInterval);
        //        [weakSelf.responderView setPersonName:@"宁杰英"];
        CGFloat progress = (3.0f - timeInterval) / 3.0f;
        [weakSelf.responderView setProgress:progress];
        [weakSelf.responderView setTitleName:[NSString stringWithFormat:@"%ld",(long)timeInterval]];
        weakSelf.responderView.titleL.font = [UIFont systemFontOfSize:50.0f];
        
        CGFloat newX = weakSelf.responderView.noticeView.bm_centerX+arc4random_uniform(2 * self.contentWidth/2 + 1) - self.contentWidth/2;
        CGFloat newY = weakSelf.responderView.noticeView.bm_centerY+arc4random_uniform(2 * self.contentHeight/2 + 1) - self.contentHeight/2;
        CGPoint centerPoint = CGPointMake(newX, newY);
        weakSelf.responderView.noticeView.center = centerPoint;
        
        if (weakSelf.responderView.noticeView.bm_top < 0)
        {
            weakSelf.responderView.noticeView.bm_top = 0;
        }
        if (weakSelf.responderView.noticeView.bm_left < 0)
        {
            weakSelf.responderView.noticeView.bm_left = 0;
        }
        
        if (weakSelf.responderView.noticeView.bm_bottom > self.contentHeight)
        {
            weakSelf.responderView.noticeView.bm_top = self.contentHeight - weakSelf.responderView.noticeView.bm_height;
        }
        if (weakSelf.responderView.noticeView.bm_right > self.contentWidth)
        {
            weakSelf.responderView.noticeView.bm_left = self.contentWidth - weakSelf.responderView.noticeView.bm_width;
        }

        
        if (timeInterval == 0)
        {
            [weakSelf.responderView setTitleName:YSLocalized(@"Res.lab.get")];
            weakSelf.responderView.titleL.font = [UIFont systemFontOfSize:26.0f];
//            weakSelf.responderView.noticeView.center = CGPointMake(UI_SCREEN_WIDTH/2, UI_SCREEN_HEIGHT/2);
            UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:weakSelf action:@selector(getStudentResponder:)];
            weakSelf.responderView.titleL.userInteractionEnabled = YES;
            [weakSelf.responderView.titleL addGestureRecognizer:tap];
        }
        
    }];
    
}

/// 抢答
- (void)getStudentResponder:(UITapGestureRecognizer *)sender
{
    if (contestTouchOne == 0)
    {
        
        [self.liveManager sendSignalingStudentContestCommitCompletion:nil];
        [self.responderView setTitleName:YSLocalized(@"Res.lab.studenting")];
    }
    contestTouchOne = 1;
//    [self.responderView setTitleName:[NSString stringWithFormat:@"%@",@"dsffasdf\n抢答成功"]];
//    self.responderView.titleL.font = [UIFont systemFontOfSize:16.0f];
}

-(void)handleSignalingToCloseResponder
{
    [self.responderView dismiss:nil animated:NO dismissBlock:nil];
}

- (void)handleSignalingContestResultWithName:(NSString *)name
{
    self.responderView.titleL.userInteractionEnabled = NO;
    if ([name bm_isNotEmpty])
    {
        [self.responderView setTitleName:[NSString stringWithFormat:@"%@\n%@",name,YSLocalized(@"Res.lab.success")]];
    }
    else
    {
        [self.responderView setTitleName:[NSString stringWithFormat:@"%@",YSLocalized(@"Res.lab.fail")]];
    }

    self.responderView.titleL.font = [UIFont systemFontOfSize:16.0f];
}


#pragma mark - 计时器

/// 收到计时器开始计时 或暂停计时
- (void)handleSignalingTimerWithTime:(NSInteger)time pause:(BOOL)pause defaultTime:(NSInteger)defaultTime
{
    studentPlayerFirst = 0;
    if (self.studentTimerView)
    {
        [self.studentTimerView dismiss:nil animated:NO dismissBlock:nil];

    }
    self.studentTimerView = [[YSStudentTimerView alloc] init];
    [self.studentTimerView showYSStudentTimerViewInView:self.view backgroundEdgeInsets:UIEdgeInsetsZero topDistance:0];

    [[BMCountDownManager manager] stopCountDownIdentifier:YSStudentTimerCountDownKey];
    if (!pause)
       {
           BMWeakSelf
           [[BMCountDownManager manager] startCountDownWithIdentifier:YSStudentTimerCountDownKey timeInterval:time processBlock:^(id  _Nonnull identifier, NSInteger timeInterval, BOOL forcedStop) {
               [weakSelf.studentTimerView showTimeInterval:timeInterval];
               if (timeInterval == 0)
               {
                   [weakSelf.studentTimerView showResponderWithType:YSStudentTimerViewType_End];
                   NSBundle *bundle = [NSBundle bundleWithPath: [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"YSResources.bundle"]];
                   NSString *filePath = [[bundle resourcePath] stringByAppendingPathComponent:@"timer_default.wav"];;
                   if (filePath)
                   {
                       weakSelf.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:filePath] error:nil];
                       //                    self.player.delegate = self;
                       [weakSelf.player setVolume:1.0];
                       if (studentPlayerFirst == 0)
                       {
                           [weakSelf.player play];
                           studentPlayerFirst = 1;
                       }

                   }
               }
           }];

           [[BMCountDownManager manager] pauseCountDownIdentifier:YSStudentTimerCountDownKey];
       }
       else
       {
           if (time == 0)
           {
               [self.studentTimerView showResponderWithType:YSStudentTimerViewType_End];
           }

           BMWeakSelf
           [[BMCountDownManager manager] startCountDownWithIdentifier:YSStudentTimerCountDownKey timeInterval:time processBlock:^(id  _Nonnull identifier, NSInteger timeInterval, BOOL forcedStop) {
               [weakSelf.studentTimerView showTimeInterval:timeInterval];
               if (timeInterval == 0)
               {
                   [weakSelf.studentTimerView showResponderWithType:YSStudentTimerViewType_End];
                   NSBundle *bundle = [NSBundle bundleWithPath: [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"YSResources.bundle"]];
                   NSString *filePath = [[bundle resourcePath] stringByAppendingPathComponent:@"timer_default.wav"];;
                   if (filePath)
                   {
                       weakSelf.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:filePath] error:nil];
                       //                    self.player.delegate = self;
                       [weakSelf.player setVolume:1.0];
                       if (studentPlayerFirst == 0)
                       {
                           [weakSelf.player play];
                           studentPlayerFirst = 1;
                       }

                   }
               }
           }];

       }

}

/// 收到暂停信令
-(void)handleSignalingPauseTimerWithTime:(NSInteger)time defaultTime:(NSInteger)defaultTime
{
    studentPlayerFirst = 0;
    if (!self.studentTimerView)
    {
        self.studentTimerView = [[YSStudentTimerView alloc] init];
        [self.studentTimerView showYSStudentTimerViewInView:self.view backgroundEdgeInsets:UIEdgeInsetsZero topDistance:0];
    }
    BMWeakSelf
    [[BMCountDownManager manager] startCountDownWithIdentifier:YSStudentTimerCountDownKey timeInterval:time processBlock:^(id  _Nonnull identifier, NSInteger timeInterval, BOOL forcedStop) {
        [weakSelf.studentTimerView showTimeInterval:timeInterval];
        if (timeInterval == 0)
        {
            [weakSelf.studentTimerView showResponderWithType:YSStudentTimerViewType_End];
            NSBundle *bundle = [NSBundle bundleWithPath: [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"YSResources.bundle"]];
            NSString *filePath = [[bundle resourcePath] stringByAppendingPathComponent:@"timer_default.wav"];;
            if (filePath)
            {
                weakSelf.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:filePath] error:nil];
                //                    self.player.delegate = self;
                [weakSelf.player setVolume:1.0];
                if (studentPlayerFirst == 0)
                {
                    [weakSelf.player play];
                    studentPlayerFirst = 1;
                }

            }
        }
    }];
    [[BMCountDownManager manager] pauseCountDownIdentifier:YSStudentTimerCountDownKey];

}
/// 收到继续信令
- (void)handleSignalingContinueTimerWithTime:(NSInteger)time defaultTime:(NSInteger)defaultTime
{
    studentPlayerFirst = 0;
    if (!self.studentTimerView)
    {
        self.studentTimerView = [[YSStudentTimerView alloc] init];
        [self.studentTimerView showYSStudentTimerViewInView:self.view backgroundEdgeInsets:UIEdgeInsetsZero topDistance:0];
    }
    if (time == 0)
    {
        [self.studentTimerView showResponderWithType:YSStudentTimerViewType_End];
    }

    BMWeakSelf
    [[BMCountDownManager manager] startCountDownWithIdentifier:YSStudentTimerCountDownKey timeInterval:time processBlock:^(id  _Nonnull identifier, NSInteger timeInterval, BOOL forcedStop) {
        [weakSelf.studentTimerView showTimeInterval:timeInterval];
        if (timeInterval == 0)
        {
            [weakSelf.studentTimerView showResponderWithType:YSStudentTimerViewType_End];
            NSBundle *bundle = [NSBundle bundleWithPath: [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"YSResources.bundle"]];
            NSString *filePath = [[bundle resourcePath] stringByAppendingPathComponent:@"timer_default.wav"];;
            if (filePath)
            {
                weakSelf.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:filePath] error:nil];
                //                    self.player.delegate = self;
                [weakSelf.player setVolume:1.0];
                if (studentPlayerFirst == 0)
                {
                    [weakSelf.player play];
                    studentPlayerFirst = 1;
                }

            }
        }
    }];
    [[BMCountDownManager manager] continueCountDownIdentifier:YSStudentTimerCountDownKey];
}

- (void)handleSignalingDeleteTimerWithTime
{
    [self.studentTimerView dismiss:nil animated:NO dismissBlock:nil];
    [[BMCountDownManager manager] stopCountDownIdentifier:YSStudentTimerCountDownKey];
    self.studentTimerView = nil;
}

#pragma mark - 打开相机  UIImagePickerController

///打开相机时查看相机和相册权限
- (void)checkTheCameraAuthority
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied)
    {// 无相机权限 做一个友好的提示
        [self addPhotoCameraAlertWithTag:0];
        
    }
    else if (authStatus == AVAuthorizationStatusNotDetermined)
    {
        // fix issue 466, 防止用户首次拍照拒绝授权时相机页黑屏
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self takePhoto];
                });
            }
        }];
        // 拍照之前还需要检查相册权限
    }
    else if ([PHPhotoLibrary authorizationStatus] == 2)
    { // 已被拒绝，没有相册权限，将无法保存拍的照片
        [self addPhotoCameraAlertWithTag:1];
    }
    else if ([PHPhotoLibrary authorizationStatus] == 0)
    { // 未请求过相册权限
        [[BMTZImageManager manager] requestAuthorizationWithCompletion:^{
            [self takePhoto];
        }];
    }
    else
    {
        [self takePhoto];
    }
}

- (void)addPhotoCameraAlertWithTag:(NSInteger)tag
{
    NSString * title = YSLocalized(@"Prompt.NeedCamera.title");
    NSString * message = YSLocalized(@"Prompt.NeedCamera");
    if (tag == 1)
    {
        title = YSLocalized(@"Prompt.NeedPhotograph.title" );
        message = YSLocalized(@"Prompt.NeedPhotograph");
    }

    if (self.controlPopoverView.presentingViewController)
    {
        [self.controlPopoverView dismissViewControllerAnimated:NO completion:nil];
    }

    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAc = [UIAlertAction actionWithTitle:YSLocalized(@"Prompt.Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *confimAc = [UIAlertAction actionWithTitle:YSLocalized(@"Prompt.OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVc addAction:cancelAc];
    [alertVc addAction:confimAc];
    [self presentViewController:alertVc animated:YES completion:nil];
}

///打开相机
- (void)takePhoto
{
    
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        //设置拍照后的图片可被编辑
        //        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        [self presentViewController:picker animated:YES completion:^{
        }];
    }
    else
    {
        NSLog(@"模拟其中无法打开照相机,请在真机中使用");
    }
}

#if USE_FullTeacher
/// 停止全屏老师视频流 并开始常规老师视频流
- (void)stopFullTeacherVideoView
{
    self.fullTeacherFloatView.hidden = YES;
    [self stopVideoAudioWithVideoView:self.fullTeacherVideoView];
    [self playVideoAudioWithNewVideoView:self.teacherVideoView];
//    self.raiseHandsBtn.frame = CGRectMake(self.contentWidth-40-26, self.contentHeight - self.whitebordBackgroud.bm_height+20, 40, 40);
}

/// 播放全屏老师视频流
- (void)playFullTeacherVideoViewInView:(UIView *)view
{
    if (self.liveManager.isBeginClass)
    {/// 全屏课件老师显示
        [self stopVideoAudioWithVideoView:self.teacherVideoView];
        
        if ([self.liveManager.teacher.peerID bm_isNotEmpty])
        {
            self.fullTeacherFloatView.hidden = NO;
        }
        [self.fullTeacherFloatView cleanContent];
        
        self.fullTeacherFloatView.frame = CGRectMake(self.contentWidth - 76 - floatVideoDefaultWidth, 50, floatVideoDefaultWidth, floatVideoDefaultHeight);
        [self.fullTeacherFloatView bm_bringToFront];
        
        SCVideoView *fullTeacherVideoView = [[SCVideoView alloc] initWithRoomUser:self.liveManager.teacher isForPerch:NO withDelegate:self];
        fullTeacherVideoView.frame = self.fullTeacherFloatView.bounds;
        [self.fullTeacherFloatView showWithContentView:fullTeacherVideoView];
        
        fullTeacherVideoView.appUseTheType = self.appUseTheType;
        [self playVideoAudioWithNewVideoView:fullTeacherVideoView];
        self.fullTeacherVideoView = fullTeacherVideoView;
        
        if (view == self.whitebordFullBackgroud)
        {
            [self.raiseHandsBtn bm_bringToFront];
            
            self.raiseHandsBtn.frame = CGRectMake(self.contentWidth-40-26, self.fullTeacherFloatView.bm_top, 40, 40);
        }
    }
}
#endif


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
    YSRoomUser * userModel = videoView.roomUser;
    
    SCUserPublishState userPublishState = userModel.liveUserPublishState;
    if (videoView.roomUser.peerID != YSCurrentUser.peerID || userPublishState == SCUserPublishState_NONE)
    {
        return;
    }
    
    UIPopoverPresentationController *popover = self.controlPopoverView.popoverPresentationController;
    if (self.videoViewArray.count <= 2)
    {
        popover.sourceView = videoView.sourceView;
        popover.sourceRect = videoView.sourceView.bounds;
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
    
    if (self.roomtype == YSRoomType_One)
    {
        popover.permittedArrowDirections = UIPopoverArrowDirectionRight | UIPopoverArrowDirectionLeft;

        if ([userModel bm_isNotEmpty])
        {
            self.controlPopoverView.view.frame = CGRectMake(0, 0, 50, 215);
            self.controlPopoverView.preferredContentSize = CGSizeMake(64, 215);
        }
    }
    else if (self.roomtype == YSRoomType_More)
    {
        popover.permittedArrowDirections = UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown;
        
        if (self.appUseTheType == YSAppUseTheTypeMeeting)
        {
            if ([userModel bm_isNotEmpty])
            {
                self.controlPopoverView.view.frame = CGRectMake(0, 0, 215, 50);
                self.controlPopoverView.preferredContentSize = CGSizeMake(215, 50);
            }
        }
        else
        {
            if ([userModel bm_isNotEmpty])
            {
                self.controlPopoverView.view.frame = CGRectMake(0, 0, 215, 50);
                self.controlPopoverView.preferredContentSize = CGSizeMake(215, 50);
            }
        }
    }
    self.controlPopoverView.roomtype = self.roomtype;
    self.controlPopoverView.isDragOut = videoView.isDragOut;
    self.controlPopoverView.foucePeerId = self.foucePeerId;
    self.controlPopoverView.userModel = userModel;
    self.controlPopoverView.videoMirrorMode = self.liveManager.localVideoMirrorMode;
}

#pragma mark 老师的控制按钮点击事件
- (void)teacherControlBtnsClick:(UIButton *)sender
{
    SCUserPublishState userPublishState = YSCurrentUser.liveUserPublishState;
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
            YSCurrentUser.liveUserPublishState = userPublishState;
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
            YSCurrentUser.liveUserPublishState = userPublishState;
            sender.selected = !sender.selected;
        }
            break;
        case 2:
        {//镜像
            sender.selected = !sender.selected;
            
            if (sender.selected)
            {
                [self.liveManager changeLocalVideoMirrorMode:YSVideoMirrorModeEnabled];
            }
            else
            {
                [self.liveManager changeLocalVideoMirrorMode:YSVideoMirrorModeDisabled];
            }
        }
            break;
        default:
            break;
    }
}

@end
