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

#import "SCTopToolBar.h"
#import "SCTeacherListView.h"

#import "SCBoardControlView.h"
#import "SCAnswerView.h"

#import "YSLiveMediaModel.h"

#import "YSFloatView.h"
#import "SCVideoView.h"
#import "SCVideoGridView.h"

#import "YSMediaMarkView.h"

#import "UIAlertController+SCAlertAutorotate.h"
#import "YSLiveApiRequest.h"

#import "SCColorSelectView.h"

#import "YSStudentResponder.h"
#import "YSStudentTimerView.h"

#import "YSControlPopoverView.h"

#define USE_YSRenderMode_adaptive   1

#define SCLessonTimeCountDownKey     @"SCLessonTimeCountDownKey"

#define PlaceholderPTag       10

#define DoubleTeacherExpandContractBtnTag          100

//#define MAXVIDEOCOUNT               12

#define GiftImageView_Width         185.0f
#define GiftImageView_Height        224.0f

/// 顶部工具条高
static const CGFloat kTopToolBar_Height_iPhone = 50.0f;
static const CGFloat kTopToolBar_Height_iPad = 70.0f;
#define TOPTOOLBAR_HEIGHT           ([UIDevice bm_isiPad] ? kTopToolBar_Height_iPad : kTopToolBar_Height_iPhone)

/// 一对一多视频最高尺寸
static const CGFloat kVideoView_MaxHeight_iPhone = 50.0f;
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

//聊天视图的高度
#define SCChatViewHeight (UI_SCREEN_HEIGHT-57)
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
    SCTopToolBarDelegate,
    SCBoardControlViewDelegate,
    UIPopoverPresentationControllerDelegate,
    YSControlPopoverViewDelegate,
    SCVideoViewDelegate,
    SCTeacherListViewDelegate
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
    
    BOOL needFreshVideoView;
    NSInteger contestTouchOne;
    
    NSInteger _personListCurentPage;
    NSInteger _personListTotalPage;
    
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

/// 顶部工具条背景
@property (nonatomic, strong) UIView *topToolBarBackgroud;

/// 顶部工具栏
@property (nonatomic, strong) SCTopToolBar *topToolBar;
@property (nonatomic, strong) SCTopToolBarModel *topBarModel;
/// 记录顶部工具栏上次选中的按钮
@property (nonatomic, strong) UIButton *topSelectBtn;
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
/// 全屏老师 视频容器
@property (nonatomic, strong) YSFloatView *fullTeacherFloatView;
@property (nonatomic, strong) SCVideoView *fullTeacherVideoView;
@property (nonatomic, assign) BOOL isWhitebordFullScreen;
/// 隐藏白板视频布局背景
@property (nonatomic, strong) SCVideoGridView *videoGridView;
/// 视频View列表
@property (nonatomic, strong) NSMutableArray <SCVideoView *> *videoViewArray;
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
@property(nonatomic,strong)UIButton *chatBtn;
/// 左侧工具栏
@property (nonatomic, strong) SCBrushToolView *brushToolView;
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

@property (nonatomic, strong) YSStudentResponder *responderView;
@property (nonatomic, strong) YSStudentTimerView *studentTimerView;
///音频播放器
@property(nonatomic, strong) AVAudioPlayer *player;
@property(nonatomic, strong) AVAudioSession *session;

/// 当前的焦点视图
@property(nonatomic, strong) SCVideoView *fouceView;
/// 视频控制popoverView
@property(nonatomic, strong) YSControlPopoverView *controlPopoverView;
/// 当前的用户视频的镜像状态
@property(nonatomic, assign) YSVideoMirrorMode videoMirrorMode;

/// 花名册 课件库
@property(nonatomic, strong) SCTeacherListView *teacherListView;
/// 大并发房间计时器 每两秒获取一次
@property (nonatomic, strong) dispatch_source_t bigRoomTimer;

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
            
            [self calculateFloatVideoSize];
        }
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
    
    [self.liveManager.whiteBoardManager changeDefaultPrimaryColor:newColorStr];
}


#pragma mark -
#pragma mark ViewControllerLife

- (void)viewDidLoad
{
    [super viewDidLoad];

    //    if (@available(iOS 13.0, *))
    //    {
    //        //[self setViewOrientationMask:UIInterfaceOrientationMaskLandscapeRight];
    //    }
    
    self.videoViewArray = [[NSMutableArray alloc] init];
    _personListCurentPage = 0;
    _personListTotalPage = 0;
    isSearch = NO;
    searchArr = [[NSMutableArray alloc] init];
    /// 本地播放 （定时器结束的音效）
    self.session = [AVAudioSession sharedInstance];
    [self.session setCategory:AVAudioSessionCategoryPlayback error:nil];
    //if (self.userId)
    {
        [self getGiftCount];
    }
    //[self setCurrentUserPrimaryColor];
    
    // 顶部工具栏背景
    [self setupTopToolBar];
    
    // 内容背景
    [self setupContentView];
    
    // 全屏白板
    [self setupFullBoardView];
    
    [self makeMp3Animation];
    
    // 隐藏白板视频布局背景
    [self setupVideoGridView];
    
    // 设置花名册 课件表
    [self setupListView];
    
    if (YSCurrentUser.role == YSUserType_Student)
    {
        // 设置左侧工具栏
        [self setupBrushToolView];
        
        // 翻页控件
        [self setupBoardControlView];
    }

    // 右侧聊天视图
    [self.view addSubview:self.rightChatView];
    
    //弹出聊天框的按钮
    [self.view addSubview:self.chatBtn];
    
    if (self.roomtype == YSRoomType_More && YSCurrentUser.role == YSUserType_Student)
    {
         //举手上台的按钮
         [self.view addSubview:self.raiseHandsBtn];
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
    
    [self setupFullTeacherView];
}

- (void)setupFullTeacherView
{
    CGFloat fullTeacherVideoHeight = VIDEOVIEW_MAXHEIGHT;
    CGFloat fullTeacherVideoWidth = 0.0f;
    if (self.isWideScreen)
    {
        fullTeacherVideoWidth = ceil(videoHeight*16 / 9);
    }
    else
    {
        fullTeacherVideoWidth = ceil(videoHeight*4 / 3);
    }

    self.fullTeacherFloatView = [[YSFloatView alloc] initWithFrame:CGRectMake(UI_SCREEN_WIDTH - 76 - fullTeacherVideoWidth, 50, fullTeacherVideoWidth, fullTeacherVideoHeight)];
    
//    self.fullTeacherVideoView = [[SCVideoView alloc] initWithRoomUser:self.liveManager.teacher isForPerch:NO];
//    self.fullTeacherVideoView.frame = CGRectMake(UI_SCREEN_WIDTH - 76 - 140, 20, 140, 105);
//
//    self.fullTeacherVideoView.appUseTheType = self.appUseTheType;

}

- (void)afterDoMsgCachePool
{
    [super afterDoMsgCachePool];
    
    if (self.appUseTheType == YSAppUseTheTypeSmallClass)
    {
        // 自动上台
        if (self.liveManager.isBeginClass && self.videoViewArray.count < maxVideoCount)
        {
            BOOL autoOpenAudioAndVideoFlag = self.liveManager.roomConfig.autoOpenAudioAndVideoFlag;
            if (autoOpenAudioAndVideoFlag)
            {
                if (YSCurrentUser.vfail == YSDeviceFaultNone)
                {
                    [self.liveManager.roomManager publishVideo:nil];
                }
                if (YSCurrentUser.afail == YSDeviceFaultNone)
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
        if (self.liveManager.isBeginClass && self.videoViewArray.count < maxVideoCount)
        {
            if (YSCurrentUser.vfail == YSDeviceFaultNone)
            {
                [self.liveManager.roomManager publishVideo:nil];
            }
            if (YSCurrentUser.afail == YSDeviceFaultNone)
            {
                [self.liveManager.roomManager publishAudio:nil];
            }
            
            [self.liveManager sendSignalingToChangePropertyWithRoomUser:YSCurrentUser withKey:sUserCandraw WithValue:@(true)];
        }
    }
}


#pragma mark 隐藏状态栏

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark 状态栏

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

/// 顶部工具栏背景
- (void)setupTopToolBar
{
    UIView *topToolBarBackGroud = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, TOPTOOLBAR_HEIGHT)];
    topToolBarBackGroud.backgroundColor = [UIColor bm_colorWithHex:0x82ABEC];
    [self.view addSubview:topToolBarBackGroud];
    self.topToolBarBackgroud = topToolBarBackGroud;
    
    self.topToolBar = [[SCTopToolBar alloc] init];
    self.topToolBar.delegate = self;
    self.topToolBar.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH, TOPTOOLBAR_HEIGHT);
    [self.topToolBarBackgroud addSubview:self.topToolBar];
    
    [self.topToolBar hidePhotoBtn:YES];
    [self.topToolBar hideMicrophoneBtn:YES];
    if (self.liveManager.localUser.role == YSUserType_Patrol)
    {
        [self.topToolBar hideCameraBtn:YES];
    }
    [self setupTopBarData];
}

/// 初始化顶栏数据
- (void)setupTopBarData
{
    self.topBarModel = [[SCTopToolBarModel alloc] init];
    self.topBarModel.roomID = [YSLiveManager shareInstance].room_Id;
    
    self.topToolBar.topToolModel = self.topBarModel;
}

/// 内容背景
- (void)setupContentView
{
    [self.liveManager setDeviceOrientation:UIDeviceOrientationLandscapeLeft];
    // 前后默认开启镜像
    [self.liveManager changeLocalVideoMirrorMode:YSVideoMirrorModeEnabled];
    self.videoMirrorMode = YSVideoMirrorModeEnabled;

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
        
        self.contentView.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH, self.contentBackgroud.bm_height);
        [self.contentView bm_centerInSuperView];
        
        self.whitebordBackgroud.frame = CGRectMake(0, 0, whitebordWidth, self.contentView.bm_height);
        
        self.videoBackgroud.frame = CGRectMake(whitebordWidth, (self.contentView.bm_height-whitebordHeight)*0.5f, videoWidth+VIDEOVIEW_GAP*2, whitebordHeight);
        
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
        self.contentView.frame = self.contentBackgroud.bounds;
        [self.contentView bm_centerInSuperView];
        
        self.videoBackgroud.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH, VIDEOVIEW_MAXHEIGHT+VIDEOVIEW_GAP);
        
        self.whitebordBackgroud.frame = CGRectMake(0, self.videoBackgroud.bm_height, UI_SCREEN_WIDTH, self.contentView.bm_height-self.videoBackgroud.bm_height);
        
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
        videoWidth = ceil((UI_SCREEN_WIDTH-VIDEOVIEW_GAP*3) / 2);
        videoHeight = ceil(videoWidth*9 / 16);
    }
    else
    {
        if (![self.doubleType bm_isNotEmpty] || [self.doubleType isEqualToString:@"abreast"])//默认上下平行关系
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
        else if([self.doubleType isEqualToString:@"nested"] )//画中画
        {
            // 在此调整视频大小和屏幕比例关系
            if (self.isWideScreen)
            {
                videoWidth = ceil(UI_SCREEN_WIDTH / 7);
                videoHeight = ceil(videoWidth*9 / 16);
                
                videoTeacherWidth = ceil((UI_SCREEN_WIDTH) / 2)-VIDEOVIEW_GAP*2;
                videoTeacherHeight = ceil(videoTeacherWidth*9 / 16);
            }
            else
            {
                videoWidth = ceil(UI_SCREEN_WIDTH / 7);
                videoHeight = ceil(videoWidth*3 / 4);
                
                videoTeacherWidth = ceil((UI_SCREEN_WIDTH) / 2)-VIDEOVIEW_GAP*2;
                videoTeacherHeight = ceil(videoTeacherWidth*3 / 4);
            }
            
            whitebordWidth = UI_SCREEN_WIDTH - (videoTeacherWidth+VIDEOVIEW_GAP*2);
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
    teacherVideoView.frame = CGRectMake(VIDEOVIEW_GAP, 0, videoWidth, videoHeight);
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
    videoView.frame = CGRectMake(VIDEOVIEW_GAP, (videoHeight+VIDEOVIEW_GAP)*1, videoWidth, videoHeight);
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
    [self.view addSubview:whitebordFullBackgroud];
    whitebordFullBackgroud.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT);
    self.whitebordFullBackgroud = whitebordFullBackgroud;
    self.whitebordFullBackgroud.hidden = YES;
    
}

/// 隐藏白板视频布局背景
- (void)setupVideoGridView
{
    SCVideoGridView *videoGridView = [[SCVideoGridView alloc] initWithWideScreen:self.isWideScreen];

    CGFloat width = UI_SCREEN_WIDTH;
    CGFloat height = UI_SCREEN_HEIGHT-TOPTOOLBAR_HEIGHT;
    
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

/// 音频播放动画
- (void)makeMp3Animation
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, self.view.bm_bottom - (MP3VIEW_WIDTH+15), MP3VIEW_WIDTH, MP3VIEW_WIDTH)];
    
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
    CGRect rect =  [self.view convertRect:self.whitebordBackgroud.frame fromView:self.whitebordBackgroud.superview];
    self.brushToolView.bm_left = UI_STATUS_BAR_HEIGHT + 5;
    self.brushToolView.bm_centerY = rect.origin.y + rect.size.height/2; //self.whitebordBackgroud.bm_centerY;
    self.brushToolView.delegate = self;
    self.brushToolView.hidden = YES;
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
    self.boardControlView.allowPaging = self.liveManager.roomConfig.canPageTurningFlag;
}


- (UIButton *)chatBtn
{
    if (!_chatBtn)
    {
        self.chatBtn = [[UIButton alloc]initWithFrame:CGRectMake(UI_SCREEN_WIDTH-40-26, UI_SCREEN_HEIGHT-40-2, 40, 40)];
        [self.chatBtn setBackgroundColor: UIColor.clearColor];
        [self.chatBtn setImage:[UIImage imageNamed:@"chat_SmallClassImage"] forState:UIControlStateNormal];
        [self.chatBtn setImage:[UIImage imageNamed:@"chat_SmallClassImage_push"] forState:UIControlStateHighlighted];
        [self.chatBtn addTarget:self action:@selector(chatButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        //拖拽
        //        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragReplyButton:)];
        //        [self.chatBtn addGestureRecognizer:panGestureRecognizer];
    }
    return _chatBtn;
}

- (UIButton *)raiseHandsBtn
{
    if (!_raiseHandsBtn)
    {
        self.raiseHandsBtn = [[UIButton alloc]initWithFrame:CGRectMake(UI_SCREEN_WIDTH-40-26, UI_SCREEN_HEIGHT - self.whitebordBackgroud.bm_height+20, 40, 40)];
        [self.raiseHandsBtn setBackgroundColor: UIColor.clearColor];
        [self.raiseHandsBtn setImage:[UIImage imageNamed:@"studentNormalHand"] forState:UIControlStateNormal];
        [self.raiseHandsBtn setImage:[UIImage imageNamed:@"handSelected"] forState:UIControlStateHighlighted];
        [self.raiseHandsBtn addTarget:self action:@selector(raiseHandsButtonClick:) forControlEvents:UIControlEventTouchDown];
        
        [self.raiseHandsBtn addTarget:self action:@selector(downHandsButtonClick:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        self.raiseHandsBtn.hidden = YES;
    }
    return _raiseHandsBtn;
}

///举手
- (void)raiseHandsButtonClick:(UIButton *)sender
{    
    [self.liveManager sendSignalingsStudentToRaiseHandWithModify:0 Completion:nil];
    
//    if (self.liveManager.isBeginClass)
//    {
        [self.liveManager sendSignalingToChangePropertyWithRoomUser:YSCurrentUser withKey:sUserRaisehand WithValue:@(true)];
//    }
//    else
//    {
//        [BMProgressHUD bm_showHUDAddedTo:self.view animated:YES withDetailText:YSLocalized(@"Prompt.RaiseHand_classBegain") delay:PROGRESSBOX_DEFAULT_HIDE_DELAY];
//    }
}

///取消举手
- (void)downHandsButtonClick:(UIButton *)sender
{
    [self.liveManager sendSignalingsStudentToRaiseHandWithModify:1 Completion:nil];
//    if (self.liveManager.isBeginClass) {
        [self.liveManager sendSignalingToChangePropertyWithRoomUser:YSCurrentUser withKey:sUserRaisehand WithValue:@(false)];
//    }
//    else{
//    }
    
    
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
        //teacherWidth = videoTeacherWidth;
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

- (void)calculateFloatVideoSize
{
    CGFloat width;
    CGFloat height;
    
    // 在此调整视频大小和屏幕比例关系
    if (self.isWideScreen)
    {
        width = ceil(UI_SCREEN_WIDTH / 25) * 9;
        height = ceil(width*9 / 16);
    }
    else
    {
        width = ceil(UI_SCREEN_WIDTH*5 / 21);
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
        
        [self freshWhitBordContentView];
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
                
        if (self.roomLayout == YSLiveRoomLayout_VideoLayout || self.roomLayout == YSLiveRoomLayout_FocusLayout)
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
                view.frame = CGRectMake(VIDEOVIEW_GAP, 0, videoWidth, whitebordHeight);
            }
            else
            {
                view.frame = CGRectMake(VIDEOVIEW_GAP*2+videoWidth, 0, videoWidth, whitebordHeight);
            }
            
#if USE_YSRenderMode_adaptive
#else
            [self.liveManager stopPlayVideo:view.roomUser.peerID completion:nil];
            [self.liveManager playVideoOnView:view withPeerId:view.roomUser.peerID renderType:YSRenderMode_fit completion:nil];
#endif
        }
        else
        {
            if (![self.doubleType bm_isNotEmpty] || [self.doubleType isEqualToString:@"abreast"])
            {//上下平行关系
                if ([view.roomUser.peerID isEqualToString:self.liveManager.teacher.peerID])
                {
                    view.frame = CGRectMake(VIDEOVIEW_GAP, 0, videoWidth, videoHeight);
                }
                else
                {
                    view.frame = CGRectMake(VIDEOVIEW_GAP, videoHeight+VIDEOVIEW_GAP, videoWidth, videoHeight);
                }
                
#if USE_YSRenderMode_adaptive
#else
                [self.liveManager stopPlayVideo:view.roomUser.peerID completion:nil];
                [self.liveManager playVideoOnView:view withPeerId:view.roomUser.peerID renderType:YSRenderMode_adaptive completion:nil];
#endif
                
            }
            else if([self.doubleType isEqualToString:@"nested"])
            {//画中画
                
                self.expandContractBtn.hidden = NO;
                
                if ([view.roomUser.peerID isEqualToString:self.liveManager.teacher.peerID])
                {
                    view.frame = CGRectMake(VIDEOVIEW_GAP, 0, videoTeacherWidth, whitebordHeight);
                    
#if USE_YSRenderMode_adaptive
#else
                    [self.liveManager stopPlayVideo:view.roomUser.peerID completion:nil];
                    [self.liveManager playVideoOnView:view withPeerId:view.roomUser.peerID renderType:YSRenderMode_fit completion:nil];
#endif
                }
                else
                {
                    view.frame = CGRectMake(VIDEOVIEW_GAP + videoTeacherWidth - videoWidth, 0, videoWidth, videoHeight);
                    self.studentVideoView = view;
                    self.expandContractBtn.selected = NO;
                    self.expandContractBtn.frame = CGRectMake(view.bm_originX-23, view.bm_originY, 23, videoHeight);
                    [self.videoBackgroud bringSubviewToFront:view];
                    [self.videoBackgroud bringSubviewToFront:self.expandContractBtn];
                    
#if USE_YSRenderMode_adaptive
#else
                    [self.liveManager stopPlayVideo:view.roomUser.peerID completion:nil];
                    [self.liveManager playVideoOnView:view withPeerId:view.roomUser.peerID renderType:YSRenderMode_adaptive completion:nil];
#endif
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
            
            if ([view.roomUser.peerID isEqualToString:self.liveManager.teacher.peerID])
            {
                view.frame = CGRectMake(VIDEOVIEW_GAP, 0, videoWidth, videoHeight);
            }
            else
            {
                view.frame = CGRectMake(VIDEOVIEW_GAP, (videoHeight+VIDEOVIEW_GAP)*1, videoWidth, videoHeight);
            }
            
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

/// 刷新白板尺寸
- (void)freshWhitBordContentView
{
    if (self.roomtype == YSRoomType_One)
    {
        self.whitebordBackgroud.hidden = NO;
        
        if (self.roomLayout == YSLiveRoomLayout_VideoLayout)
        {
            self.whitebordBackgroud.hidden = YES;
            
            self.videoBackgroud.frame = CGRectMake(whitebordWidth, 0, UI_SCREEN_WIDTH, videoHeight);
            
            self.userVideoView.frame = CGRectMake(VIDEOVIEW_GAP*2+videoWidth, 0, videoWidth, videoHeight);
            self.teacherPlacehold.frame = CGRectMake(VIDEOVIEW_GAP, 0, videoWidth, videoHeight);
        }
        else
        {
            if (![self.doubleType bm_isNotEmpty] || [self.doubleType isEqualToString:@"abreast"])
            {//默认上下平行关系

                self.whitebordBackgroud.frame = CGRectMake(0, 0, whitebordWidth, self.contentView.bm_height);

                //self.whiteBordView.frame = self.whitebordBackgroud.bounds;
                self.videoBackgroud.frame = CGRectMake(whitebordWidth, (self.contentView.bm_height-whitebordHeight)*0.5f, videoWidth+VIDEOVIEW_GAP*2, whitebordHeight);
                
                self.userVideoView.frame = CGRectMake(VIDEOVIEW_GAP, (videoHeight+VIDEOVIEW_GAP)*1, videoWidth, videoHeight);
                self.teacherPlacehold.frame = CGRectMake(VIDEOVIEW_GAP, 0, videoWidth, videoHeight);
                //[[YSLiveManager shareInstance].whiteBoardManager refreshWhiteBoard];
            }
            else if([self.doubleType isEqualToString:@"nested"])
            {//画中画
                
                self.whitebordBackgroud.frame = CGRectMake(0, 0, whitebordWidth, self.contentView.bm_height);
                //self.whiteBordView.frame = self.whitebordBackgroud.bounds;
                self.videoBackgroud.frame = CGRectMake(whitebordWidth, (self.contentView.bm_height-whitebordHeight)*0.5f, videoTeacherWidth+VIDEOVIEW_GAP*2, whitebordHeight);
                
                self.teacherPlacehold.frame = CGRectMake(VIDEOVIEW_GAP, 0, videoTeacherWidth, whitebordHeight);
                self.userVideoView.frame = CGRectMake(CGRectGetMaxX(self.teacherPlacehold.frame)-videoWidth, 0, videoWidth, videoHeight);
                //[[YSLiveManager shareInstance].whiteBoardManager refreshWhiteBoard];
            }
        }
    }
    else
    {
        self.videoBackgroud.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH, videoHeight+VIDEOVIEW_GAP);
        
        self.whitebordBackgroud.frame = CGRectMake(0, self.videoBackgroud.bm_height, UI_SCREEN_WIDTH, self.contentView.bm_height-self.videoBackgroud.bm_height);
        //self.whiteBordView.frame = self.whitebordBackgroud.bounds;
        //[[YSLiveManager shareInstance].whiteBoardManager refreshWhiteBoard];
    }
    
    [self freshWhiteBordViewFrame];
}

- (void)freshWhiteBordViewFrame
{
    if (self.isWhitebordFullScreen)
    {
        self.whiteBordView.frame = self.whitebordFullBackgroud.bounds;
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
        if (videoView.tag != DoubleTeacherExpandContractBtnTag)
        {
            [videoView removeFromSuperview];
        }
    }
    
    
    if (self.isDoubleType)
    {
//        [self.userVideoView removeFromSuperview];
        
//        NSMutableArray * arr = [NSMutableArray array];
//
//        if (self.videoViewArray.count)
//        {
//            for (SCVideoView * view in self.videoViewArray) {
//                [arr addObject:view];
//            }
//        }
//
//        if (self.videoViewArray.count < 2)
//        {
//            [arr addObject:self.userVideoView];
//        }
        
        [self.videoGridView freshViewWithVideoViewArray:self.videoViewArray withFouceVideo:nil withRoomLayout:self.roomLayout withAppUseTheType:self.appUseTheType];
        
//        self.isDoubleType = 0;
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
        CGFloat x = percentLeft * (UI_SCREEN_WIDTH - videoView.bm_width);
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
        CGFloat x = percentLeft * (UI_SCREEN_WIDTH - floatVideoDefaultWidth);
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
    
    //self.shareVideoFloatView.frame = CGRectMake(point.x, point.y, floatVideoDefaultWidth, floatVideoDefaultHeight);
    //[self.shareVideoFloatView stayMove];
    
    [self.liveManager.roomManager playScreen:peerId renderType:YSRenderMode_fit window:self.shareVideoView completion:^(NSError *error) {
    }];
    
    //[self arrangeAllViewInContentBackgroudViewWithViewType:SCMain_ArrangeContentBackgroudViewType_ShareVideoFloatView index:0];
    
    [self arrangeAllViewInVCView];
    self.shareVideoFloatView.canZoom = YES;
    self.shareVideoFloatView.showWaiting = NO;
    self.shareVideoFloatView.hidden = NO;
    
    [self playFullTeacherVideoViewInView:self.shareVideoFloatView];
}

// 关闭共享桌面
- (void)hideShareVidoeViewWithPeerId:(NSString *)peerId
{
    [self.liveManager.roomManager unPlayScreen:peerId completion:^(NSError * _Nonnull error) {
    }];
    
    self.shareVideoFloatView.canZoom = NO;
    self.shareVideoFloatView.backScrollView.zoomScale = 1.0;
    self.shareVideoFloatView.hidden = YES;
    [self stopFullTeacherVideoView];
    
    if (!self.whitebordFullBackgroud.hidden)
    {
        [self playFullTeacherVideoViewInView:self.whitebordFullBackgroud];
    }

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
    
    [self playFullTeacherVideoViewInView:self.shareVideoFloatView];

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
    [self stopFullTeacherVideoView];
    
    if (!self.whitebordFullBackgroud.hidden)
    {
        [self playFullTeacherVideoViewInView:self.whitebordFullBackgroud];
    }

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
#if USE_YSRenderMode_adaptive
    fresh = NO;
#else
    if (videoView.isFullScreen)
    {
        renderType = YSRenderMode_fit;
    }
#endif
        
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
    [self.controlPopoverView dismissViewControllerAnimated:YES completion:nil];
    YSRoomUser *roomUser = [self.liveManager.roomManager getRoomUserWithUId:peerId];
    if (!roomUser)
    {
        return;
    }
    
    if ([roomUser.properties bm_containsObjectForKey:sUserVideoFail])
    {
        if (roomUser.vfail != YSDeviceFaultNone && roomUser.afail != YSDeviceFaultNone)
        {
            return;
        }
    }
    else
    {
        if (!roomUser.hasVideo && !roomUser.hasAudio)
        {
            return;
        }
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
    [self.controlPopoverView dismissViewControllerAnimated:YES completion:nil];
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


#pragma mark - 右侧聊天视图

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
        
        if (YSCurrentUser.role == YSUserType_Patrol)
        {
            self.rightChatView.allDisabledChat.hidden = NO;
            self.rightChatView.textBtn.hidden = YES;
            self.rightChatView.allDisabledChat.text = YSLocalized(@"Prompt.CannotInput");
        }
    }
    return _rightChatView;
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
    [self.drawBoardView.triangleImgView bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.left.bmmas_equalTo(weakSelf.brushToolView.bmmas_right);
        make.centerY.bmmas_equalTo(toolBtn.bmmas_centerY);
        make.width.bmmas_equalTo(13);
        make.height.bmmas_equalTo(28);
    }];
    
    switch (toolViewBtnType) {
        case YSBrushToolTypeMouse:
            //鼠标
            break;
        case YSBrushToolTypeLine:
        { //笔 划线
            [self.drawBoardView.backgroundView  bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
                make.left.bmmas_equalTo(weakSelf.drawBoardView.triangleImgView.bmmas_right).bmmas_offset(-2);
                make.centerY.bmmas_equalTo(toolBtn.bmmas_centerY);
            }];
        }
            break;
        case YSBrushToolTypeText:
        { // 文字
            [self.drawBoardView.backgroundView  bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
                make.left.bmmas_equalTo(weakSelf.drawBoardView.triangleImgView.bmmas_right).bmmas_offset(-2);
                make.centerY.bmmas_equalTo(toolBtn.bmmas_centerY);
            }];
        }
            break;
        case YSBrushToolTypeShape:
        {    // 形状
            [self.drawBoardView.backgroundView  bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
                make.left.bmmas_equalTo(weakSelf.drawBoardView.triangleImgView.bmmas_right).bmmas_offset(-2);
                make.centerY.bmmas_equalTo(toolBtn.bmmas_centerY ).bmmas_offset(-40);
            }];
        }
            break;
        case YSBrushToolTypeEraser:
        {    //橡皮擦
            [self.drawBoardView.backgroundView  bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
                make.left.bmmas_equalTo(weakSelf.drawBoardView.triangleImgView.bmmas_right).bmmas_offset(-2);
                make.centerY.bmmas_equalTo(toolBtn.bmmas_centerY).bmmas_offset(-10);
                
            }];
        }
            break;
        default:
            break;
    }
    //    self.drawBoardView.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT);
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
- (void)microphoneProxyWithBtn:(UIButton *)btn
{
    if (self.liveManager.localUser.afail == YSDeviceFaultNone)
    {
        YSPublishState publishState = [YSCurrentUser.properties bm_intForKey:sUserPublishstate];
        
        // selected在回调前变化过了
        if (self.topToolBar.microphoneBtn.selected)
        {
            // 关闭音频
            
            if (publishState == YSUser_PublishState_AUDIOONLY)
            {
                publishState = 4;
            }
            else if (publishState == YSUser_PublishState_BOTH)
            {
                publishState = YSUser_PublishState_VIDEOONLY;
            }
            
            if (publishState == YSUser_PublishState_VIDEOONLY || publishState == 4)
            {
                [self.liveManager.roomManager changeUserProperty:YSCurrentUser.peerID tellWhom:YSRoomPubMsgTellAll key:sUserPublishstate value:@(publishState) completion:nil];
            }
        }
        else
        {
            // 打开音频
            
            if (publishState == 4)
            {
                publishState = YSUser_PublishState_AUDIOONLY;
            }
            else if (publishState == YSUser_PublishState_VIDEOONLY)
            {
                publishState = YSUser_PublishState_BOTH;
            }
            
            if (publishState == YSUser_PublishState_AUDIOONLY || publishState == YSUser_PublishState_BOTH)
            {
                [self.liveManager.roomManager changeUserProperty:YSCurrentUser.peerID tellWhom:YSRoomPubMsgTellAll key:sUserPublishstate value:@(publishState) completion:nil];
            }
        }
    }
    else
    {
        return;
    }
}

/// 照片
- (void)photoProxyWithBtn:(UIButton *)btn
{
    [self openTheImagePickerWithImageUseType:SCUploadImageUseType_Document];
}

/// 摄像头
- (void)cameraProxyWithBtn:(UIButton *)btn
{
    // selected在回调前变化过了
    // true：使用前置摄像头；false：使用后置摄像头
        [self.liveManager.roomManager selectCameraPosition:!btn.selected];
}

/// 退出
- (void)exitProxyWithBtn:(UIButton *)btn
{
    [self backAction:nil];
}

/// 巡课花名册   课件表
- (void)sc_TopBarProxyWithBtn:(UIButton *)btn
{
    if (self.topSelectBtn == btn)
    {
        
    }
    else
    {
        if (self.topSelectBtn.tag == SCTeacherTopBarTypeCourseware || self.topSelectBtn.tag == SCTeacherTopBarTypePersonList)
        {
            [self freshListViewWithSelect:NO];
        }
    }
        
    if (btn.tag == SCTeacherTopBarTypePersonList)
    {
        //花名册  有用户进入房间调用 上下课调用
        [self freshListViewWithSelect:!btn.selected];
        
        BMWeakSelf
        if (self.liveManager.isBigRoom)
        {
            NSInteger studentNum = [self.liveManager.userCountDetailDic bm_intForKey:@"2"];
            NSInteger assistantNum = [self.liveManager.userCountDetailDic bm_intForKey:@"1"];
            _personListCurentPage = 0;
            _personListTotalPage = (studentNum + assistantNum)/onePageMaxUsers;
            [self.teacherListView setPersonListCurrentPage:_personListCurentPage totalPage:_personListTotalPage];
            
            [self.liveManager.roomManager getRoomUsersWithRole:@[@(YSUserType_Assistant),@(YSUserType_Student)] startIndex:_personListCurentPage maxNumber:onePageMaxUsers search:@"" order:@{} callback:^(NSArray<YSRoomUser *> * _Nonnull users, NSError * _Nonnull error) {
                
                BMLog(@"%@",users);
                dispatch_async(dispatch_get_main_queue(), ^{
                    // UI更新代码
                    
                    [weakSelf.teacherListView setUserRole:weakSelf.liveManager.localUser.role];
                    [weakSelf.teacherListView setDataSource:users withType:SCTeacherTopBarTypePersonList userNum:studentNum];
                });
            }];
        }
        else
        {            
//            _personListCurentPage = 0;
//            _personListTotalPage = self.liveManager.userList.count/onePageMaxUsers;
//
//            [self.teacherListView setDataSource:[YSLiveManager shareInstance].userList withType:SCTeacherTopBarTypePersonList userNum:self.liveManager.studentCount];
            //            [self.teacherListView setPersonListCurrentPage:_personListCurentPage totalPage:(self.liveManager.studentCount + self.liveManager.assistantCount)/onePageMaxUsers];
            [self.teacherListView setUserRole:self.liveManager.localUser.role];
            _personListCurentPage = 0;
            _personListTotalPage = 0;
            NSInteger studentNum = self.liveManager.studentCount ;
            NSInteger assistantNum = self.liveManager.assistantCount;
            NSInteger divide = (studentNum + assistantNum)/onePageMaxUsers;
            NSInteger remainder = (studentNum + assistantNum)%onePageMaxUsers;
            if (divide == 1 )
            {
                if (remainder == 0)
                {
                    _personListTotalPage = 0;
                }
                else
                {
                    _personListTotalPage = 1;
                }
                
            }
            else
            {
                if (remainder == 0)
                {
                    _personListTotalPage = divide - 1;
                }
                else
                {
                    _personListTotalPage = divide;
                }
                
            }
            
            
            NSMutableArray *listArr = [NSMutableArray arrayWithCapacity:0];
            for (YSRoomUser *user in self.liveManager.userList)
            {
                if (user.role == YSUserType_Assistant || user.role == YSUserType_Student)
                {
                    [listArr addObject:user];
                }
            }
            
            if ((_personListCurentPage + 1) * onePageMaxUsers <= (studentNum + assistantNum))
            {
                NSArray *data = [listArr subarrayWithRange:NSMakeRange(_personListCurentPage * onePageMaxUsers, onePageMaxUsers)];
                [self.teacherListView setDataSource:data withType:SCTeacherTopBarTypePersonList userNum:studentNum];
            }
            else
            {
                
                NSArray *data = [listArr subarrayWithRange:NSMakeRange(_personListCurentPage * onePageMaxUsers, listArr.count - _personListCurentPage * onePageMaxUsers)];
                [self.teacherListView setDataSource:data withType:SCTeacherTopBarTypePersonList userNum:studentNum];
            }
            [self.teacherListView setPersonListCurrentPage:_personListCurentPage totalPage:_personListTotalPage];
            
        }
        
        //        [self freshTeacherPersonListData];
    }
    
    if (btn.tag == SCTeacherTopBarTypeCourseware)
    {
        [self freshListViewWithSelect:!btn.selected];
        //课件库
        [self.teacherListView setUserRole:self.liveManager.localUser.role];
        [self.teacherListView setDataSource:[YSLiveManager shareInstance].fileList withType:SCTeacherTopBarTypeCourseware userNum:[YSLiveManager shareInstance].fileList.count];
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

#pragma mark -刷新花名册数据
- (void)freshTeacherPersonListData
{
    if (self.topSelectBtn.tag == SCTeacherTopBarTypePersonList && self.topSelectBtn.selected)
    {
        //花名册  有用户进入房间调用 上下课调用
               //花名册  有用户进入房间调用 上下课调用
        
        if (self.liveManager.isBigRoom)
        {
            BMWeakSelf
            NSInteger studentNum = [self.liveManager.userCountDetailDic bm_intForKey:@"2"];
            NSInteger assistantNum = [self.liveManager.userCountDetailDic bm_intForKey:@"1"];
            [self.teacherListView setPersonListCurrentPage:_personListCurentPage totalPage:(studentNum + assistantNum)/onePageMaxUsers];
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
//            [self.teacherListView setDataSource:[YSLiveManager shareInstance].userList withType:SCTeacherTopBarTypePersonList userNum:self.liveManager.studentCount];
            //            [self.teacherListView setPersonListCurrentPage:_personListCurentPage totalPage:(self.liveManager.studentCount + self.liveManager.assistantCount)/onePageMaxUsers];
            NSInteger studentNum = self.liveManager.studentCount ;
            NSInteger assistantNum = self.liveManager.assistantCount;
            NSInteger listNumber = studentNum + assistantNum;
            NSInteger divide = listNumber/onePageMaxUsers;
            NSInteger remainder = listNumber%onePageMaxUsers;
            if (divide == 1 )
            {
                if (remainder == 0)
                {
                    _personListTotalPage = 0;
                }
                else
                {
                    _personListTotalPage = 1;
                }
                
            }
            else
            {
                if (remainder == 0)
                {
                    _personListTotalPage = divide - 1;
                }
                else
                {
                    _personListTotalPage = divide;
                }
                
            }
            
            NSMutableArray *listArr = [NSMutableArray arrayWithCapacity:0];
            for (YSRoomUser *user in self.liveManager.userList)
            {
                if (user.role == YSUserType_Assistant || user.role == YSUserType_Student)
                {
                    [listArr addObject:user];
                }
            }
            
            if (_personListCurentPage + 1 > divide )
            {
                if (remainder == 0)
                {
                    _personListCurentPage = _personListCurentPage - 1;
                }
                else
                {
                    //                    _personListCurentPage = _personListCurentPage;
                }
                
            }
            
            if (listNumber > onePageMaxUsers)
            {
                if ((_personListCurentPage + 1) * onePageMaxUsers <= listNumber)
                {
                    NSArray *data = [listArr subarrayWithRange:NSMakeRange(_personListCurentPage * onePageMaxUsers, onePageMaxUsers)];
                    [self.teacherListView setDataSource:data withType:SCTeacherTopBarTypePersonList userNum:studentNum];
                }
                else
                {
                    
                    NSArray *data = [listArr subarrayWithRange:NSMakeRange(_personListCurentPage * onePageMaxUsers, listArr.count - _personListCurentPage * onePageMaxUsers)];
                    [self.teacherListView setDataSource:data withType:SCTeacherTopBarTypePersonList userNum:studentNum];
                }
            }
            else
            {
                //                _personListCurentPage = 0;
                if ((_personListCurentPage + 1) * onePageMaxUsers <= (studentNum + assistantNum))
                {
                    NSArray *data = [listArr subarrayWithRange:NSMakeRange(_personListCurentPage * onePageMaxUsers, onePageMaxUsers)];
                    [self.teacherListView setDataSource:data withType:SCTeacherTopBarTypePersonList userNum:studentNum];
                }
                else
                {
                    
                    NSArray *data = [listArr subarrayWithRange:NSMakeRange(_personListCurentPage * onePageMaxUsers, listArr.count - _personListCurentPage * onePageMaxUsers)];
                    [self.teacherListView setDataSource:data withType:SCTeacherTopBarTypePersonList userNum:studentNum];
                }
                
            }
            
            
            //            [self.teacherListView setDataSource:[YSLiveManager shareInstance].userList withType:SCTeacherTopBarTypePersonList userNum:self.liveManager.studentCount];
            [self.teacherListView setPersonListCurrentPage:_personListCurentPage totalPage:_personListTotalPage];


        }
    }
}

#pragma mark -刷新课件库数据
- (void)freshTeacherCoursewareListDataWithPlay:(BOOL)isPlay
{
    if (self.topSelectBtn.tag == SCTeacherTopBarTypeCourseware && self.topSelectBtn.selected)
    {
        YSFileModel *file = [[YSLiveManager shareInstance] getFileWithFileID:self.liveManager.playMediaModel.fileid];
        file.isPlaying = isPlay;
        [self.teacherListView setUserRole:self.liveManager.localUser.role];

        [self.teacherListView setDataSource:self.liveManager.fileList withType:SCTeacherTopBarTypeCourseware userNum:self.liveManager.fileList.count];
    }
}


#pragma mark -
#pragma mark SCTeacherListViewDelegate

///收回列表
- (void)tapGestureBackListView
{
    [self freshListViewWithSelect:NO];
    if (self.topSelectBtn.tag == SCTeacherTopBarTypePersonList || self.topSelectBtn.tag == SCTeacherTopBarTypeCourseware)
    {
        self.topSelectBtn.selected = NO;
    }
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
            NSInteger studentNum = [self.liveManager.userCountDetailDic bm_intForKey:@"2"];
//            NSInteger assistantNum = [self.liveManager.userCountDetailDic bm_intForKey:@"1"];
            [self.teacherListView setPersonListCurrentPage:page totalPage:searchArr.count/onePageMaxUsers];
            if (searchArr.count > onePageMaxUsers)
            {
                if (page * onePageMaxUsers <= searchArr.count)
                {
                    NSArray *data = [searchArr subarrayWithRange:NSMakeRange(page * onePageMaxUsers, onePageMaxUsers)];
                    [self.teacherListView setDataSource:data withType:SCTeacherTopBarTypePersonList userNum:studentNum];
                }
                else
                {
                    NSArray *data = [searchArr subarrayWithRange:NSMakeRange(page * onePageMaxUsers, searchArr.count - page * onePageMaxUsers)];
                    [self.teacherListView setDataSource:data withType:SCTeacherTopBarTypePersonList userNum:studentNum];
                }
            }
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
        NSInteger studentNum  = 0;
        if (self.liveManager.isBigRoom)
        {
            studentNum = [self.liveManager.userCountDetailDic bm_intForKey:@"2"];
        }
        else
        {
            studentNum = self.liveManager.studentCount;
        }
        [self.teacherListView setPersonListCurrentPage:page totalPage:searchArr.count/onePageMaxUsers];
        if (searchArr.count > onePageMaxUsers)
        {
            if (searchArr.count - page * onePageMaxUsers > onePageMaxUsers)
            {
                NSArray *data = [searchArr subarrayWithRange:NSMakeRange(page * onePageMaxUsers, onePageMaxUsers)];
                [self.teacherListView setDataSource:data withType:SCTeacherTopBarTypePersonList userNum:studentNum];
            }
            else
            {
                NSArray *data = [searchArr subarrayWithRange:NSMakeRange(page * onePageMaxUsers, searchArr.count - page * onePageMaxUsers)];
                [self.teacherListView setDataSource:data withType:SCTeacherTopBarTypePersonList userNum:studentNum];
            }
        }
        
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

        [self.liveManager.roomManager getRoomUsersWithRole:@[@(YSUserType_Assistant),@(YSUserType_Student)] startIndex:0 maxNumber:(studentNum + assistantNum) search:searchContent order:@{} callback:^(NSArray<YSRoomUser *> * _Nonnull users, NSError * _Nonnull error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // UI更新代码

                self->searchArr = [NSMutableArray arrayWithArray:users];
                [weakSelf.teacherListView setPersonListCurrentPage:0 totalPage:users.count/onePageMaxUsers];
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
                [weakSelf.teacherListView setPersonListCurrentPage:0 totalPage:users.count/onePageMaxUsers];
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
                    [weakSelf freshTeacherPersonListData];
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

/// 全屏 复原 回调
- (void)boardControlProxyfullScreen:(BOOL)isAllScreen
{
    self.isWhitebordFullScreen = isAllScreen;
    
    [self.boardControlView resetBtnStates];
    
    if (isAllScreen)
    {
        [self.view endEditing:YES];
        [self.whiteBordView removeFromSuperview];
//        [self.whitebordBackgroud bm_removeAllSubviews];
        
        self.whitebordFullBackgroud.hidden = NO;
        // 加载白板
        [self.whitebordFullBackgroud addSubview:self.whiteBordView];
        self.whiteBordView.frame = self.whitebordFullBackgroud.bounds;
        [self arrangeAllViewInVCView];
        
        [self playFullTeacherVideoViewInView:self.whitebordFullBackgroud];

    }
    else
    {
        
//        [self.whitebordFullBackgroud bm_removeAllSubviews];
        self.whitebordFullBackgroud.hidden = YES;
        [self.whiteBordView removeFromSuperview];
        [self.whitebordBackgroud addSubview:self.whiteBordView];
        self.whiteBordView.frame = self.whitebordBackgroud.bounds;
        
        [self arrangeAllViewInWhiteBordBackgroud];
        //        [self freshContentView];
        
        self.boardControlView.hidden = self.isDoubleVideoBig || (self.roomLayout == YSLiveRoomLayout_VideoLayout);
        if (YSCurrentUser.canDraw)
        {
            self.brushToolView.hidden = self.isDoubleVideoBig || (self.roomLayout == YSLiveRoomLayout_VideoLayout);
        }
        
        if (!YSCurrentUser.canDraw || self.brushToolView.hidden || !self.brushToolView.toolsBtn.selected || self.brushToolView.mouseBtn.selected )
        {
            self.drawBoardView.hidden = YES;
        }
        else
        {
            self.drawBoardView.hidden = NO;
        }
        [self stopFullTeacherVideoView];
    }

    [self.liveManager.whiteBoardManager refreshWhiteBoard];
    [self.liveManager.whiteBoardManager whiteBoardResetEnlarge];

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


#pragma mark -聊天输入框工具栏

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
            [BMProgressHUD bm_hideHUDForView:self.view animated:YES delay:PROGRESSBOX_DEFAULT_HIDE_DELAY];
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
                [self sendWhiteBordImageWithDic:dict];
            }
            else
            {
                BOOL isSucceed = [[YSLiveManager shareInstance] sendMessageWithText:[dict bm_stringTrimForKey:@"swfpath"]  withMessageType:YSChatMessageTypeOnlyImage withMemberModel:nil];
                if (!isSucceed) {
                    BMProgressHUD *hub = [BMProgressHUD bm_showHUDAddedTo:weakSelf.view animated:YES withDetailText:YSLocalized(@"UploadPhoto.Error")];
                    hub.yOffset = -100;
                    [BMProgressHUD bm_hideHUDForView:weakSelf.view animated:YES delay:PROGRESSBOX_DEFAULT_HIDE_DELAY];
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
    [self presentViewController:imagePickerController animated:YES completion:nil];
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
    NSString *filetype = @"jpeg";
    
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
                @"filename" : filename,
                @"filetype" : filetype,
                @"currpage" : @(1),
                @"pagenum" : @(pagenum),
                @"pptslide" : @(1),
                @"pptstep" : @(0),
                @"steptotal" : @(0),
                @"swfpath" : swfpath
        }
    };
    
    [self.liveManager sendPubMsg:sDocumentChange toID:YSRoomPubMsgTellAllExceptSender data:[tDataDic bm_toJSON] save:NO associatedMsgID:nil associatedUserID:nil expires:0 completion:nil];
    
    NSString *downloadpath = [docDic bm_stringTrimForKey:@"downloadpath"];
    BOOL isContentDocument = [docDic bm_boolForKey:@"isContentDocument"];
    
    NSDictionary *tDataDic1 = @{
        @"isGeneralFile" : @(isGeneralFile),
        @"isDynamicPPT" : @(isDynamicPPT),
        @"isH5Document" : @(isH5Document),
        @"action" : action,
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

//输入框条上表情按钮的点击事件
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

#pragma mark 表情键盘

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
    [super keyboardWillHide:notification];
    
    double duration=[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
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
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.chatToolView.bm_originY<UI_SCREEN_HEIGHT-10)
    {
        [self hiddenTheKeyBoard];
    }
    else
    {
        self.chatBtn.selected = NO;
        CGRect tempRect = self.rightChatView.frame;
        tempRect.origin.x = UI_SCREEN_WIDTH;
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
    self.topBarModel.lessonTime = str;
    self.topToolBar.topToolModel = self.topBarModel;
}


#pragma mark -
#pragma mark YSWhiteBoardManagerDelegate

- (void)onWhiteBoardViewStateUpdate:(NSDictionary *)message
{
    //BMLog(@"-------------------------%@----------------", message);
    // WebView显示课件刷新回调

    YSFileModel *file = self.liveManager.currentFile;
    
    if (!file || file.isMedia.intValue)
    {
        return;
    }
    
    [self.boardControlView resetBtnStates];

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
    
    BOOL isDynamic = YES;
    if (file.isGeneralFile)
    {
        isDynamic = NO;
        
        NSString *filetype = file.filetype;
        NSString *path = file.swfpath;
        if ([filetype isEqualToString:@"gif"] || [filetype isEqualToString:@"svg"])
        {
            isDynamic = YES;
        }
        else if ([path hasSuffix:@".gif"] || [path hasSuffix:@".svg"])
        {
            isDynamic = YES;
        }
    }
        
    if (!isDynamic)
    {
        self.boardControlView.bm_width = 246;
        if (self.boardControlView.bm_right > UI_SCREEN_WIDTH)
        {
            self.boardControlView.bm_left = UI_SCREEN_WIDTH - self.boardControlView.bm_width - 2;
        }

        [self.boardControlView sc_setTotalPage:totalPage.integerValue currentPage:currentPage.integerValue isWhiteBoard:[file.fileid isEqualToString:@"0"]];
    }
    else
    {
        self.boardControlView.bm_width = 161; //CGRectMake(0, 0, 160, 34);
        
        [self.boardControlView sc_setTotalPage:totalPage.integerValue currentPage:currentPage.integerValue canPrevPage:prevPage canNextPage:nextPage isWhiteBoard:[file.fileid isEqualToString:@"0"]];
    }

    //self.boardControlView.bm_centerX = self.view.bm_centerX;

    return;
}

/// 本地操作，缩放课件比例变化
- (void)onWhiteBoardFileViewZoomScaleChanged:(CGFloat)zoomScale
{
    [self.boardControlView changeZoomScale:zoomScale];
}


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
    
    [self removeAllVideoView];
    
    if (self.isWhitebordFullScreen)
    {
        [self boardControlProxyfullScreen:NO];
    }
    
    [self handleSignalingDefaultRoomLayout];
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

    // 网络中断尝试失败后退出
    [[BMNoticeViewStack sharedInstance] closeAllNoticeViews];// 清除alert的栈
    [self dismissViewControllerAnimated:YES completion:^{
#if YSSDK
        [self.liveManager onSDKRoomLeft];
#endif
        [self.liveManager destroy];
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
        [self.progressHUD bm_showAnimated:NO withDetailText:YSLocalized(@"Error.WaitingForNetwork") delay:PROGRESSBOX_DEFAULT_HIDE_DELAY];
    }
    
    self.topBarModel.netQuality = netQuality;
    self.topBarModel.netDelay = netDelay;
    self.topBarModel.lostRate = lostRate;
    self.topToolBar.topToolModel = self.topBarModel;
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
        [self.progressHUD bm_showAnimated:NO withDetailText:YSLocalized(@"Error.WaitingForNetwork") delay:PROGRESSBOX_DEFAULT_HIDE_DELAY];
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
        [self.progressHUD bm_showAnimated:NO withDetailText:YSLocalized(@"Error.WaitingForNetwork") delay:PROGRESSBOX_DEFAULT_HIDE_DELAY];
    }
}

/// 用户进入
- (void)roomManagerRoomTeacherEnter
{
    self.teacherPlaceLab.hidden = self.liveManager.isBeginClass;
    if (!self.whitebordFullBackgroud.hidden || !self.shareVideoFloatView.hidden)
    {
        self.fullTeacherFloatView.hidden = NO;
    }
    
}

- (void)roomManagerRoomTeacherLeft
{
    self.teacherPlaceLab.hidden = YES;
    self.fullTeacherFloatView.hidden = YES;
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

/// 自己被踢出房间
- (void)onRoomKickedOut:(NSDictionary *)reason
{
    NSUInteger reasonCode = [reason bm_uintForKey:@"reason"];

    NSString *reasonString = YSLocalized(@"KickOut.Repeat");
    if (reasonCode)
    {
        reasonString = YSLocalized(@"KickOut.SentOutClassroom");
    }

    [self.controlPopoverView dismissViewControllerAnimated:YES completion:nil];
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
                self.drawBoardView.hidden = YES;
            }
            else
            {
                self.brushToolView.hidden = !canDraw;
                if (!canDraw || !self.brushToolView.toolsBtn.selected || self.brushToolView.mouseBtn.selected)
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
                
                [self.liveManager.whiteBoardManager brushToolsDidSelect:YSBrushToolTypeMouse];
                [self.liveManager.whiteBoardManager freshBrushToolConfig];
            }
            
            videoView.canDraw = canDraw;
            if (self.liveManager.isBeginClass)
            {
                self.boardControlView.allowPaging = self.liveManager.roomConfig.canPageTurningFlag && canDraw;
            }
            
            [self.topToolBar hidePhotoBtn:!canDraw];
            
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
                        
            self.rightChatView.allDisabledChat.hidden = !disablechat;
            self.rightChatView.textBtn.hidden = disablechat;
            if (disablechat)
            {
                self.rightChatView.allDisabledChat.text = YSLocalized(@"Prompt.BanChat");
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
//                [self.topToolBar selectMicrophoneBtn:NO];
//                [self.topToolBar hideMicrophoneBtn:YES];
                self.controlPopoverView.audioBtn.selected = NO;
                self.controlPopoverView.videoBtn.selected = NO;
                [self.controlPopoverView dismissViewControllerAnimated:YES completion:nil];
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
    
    //进入前后台
    if ([properties bm_containsObjectForKey:sUserIsInBackGround])
    {
        [videoView freshWithRoomUserProperty:roomUser];
    }
    
    /// 用户设备状态
    if ([properties bm_containsObjectForKey:sUserVideoFail] || [properties bm_containsObjectForKey:sUserAudioFail])
    {
        [videoView freshWithRoomUserProperty:roomUser];
    }

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
    
        if (self.appUseTheType == YSAppUseTheTypeSmallClass)
        {
            // 自动上台
            if (self.videoViewArray.count < maxVideoCount)
            {
                BOOL autoOpenAudioAndVideoFlag = self.liveManager.roomConfig.autoOpenAudioAndVideoFlag;
                if (autoOpenAudioAndVideoFlag)
                {
                    if (YSCurrentUser.vfail == YSDeviceFaultNone)
                    {
                        [self.liveManager.roomManager unPublishVideo:nil];
                        [self.liveManager.roomManager publishVideo:nil];
                    }
                    if (YSCurrentUser.afail == YSDeviceFaultNone)
                    {
                        [self.liveManager.roomManager unPublishAudio:nil];
                        [self.liveManager.roomManager publishAudio:nil];
                    }
                }
            }
        }
        else if (self.appUseTheType == YSAppUseTheTypeMeeting)
        {//会议，进教室默认上台
            if (self.liveManager.isBeginClass && self.videoViewArray.count < maxVideoCount)
            {
                if (YSCurrentUser.vfail == YSDeviceFaultNone)
                {
                    [self.liveManager.roomManager unPublishVideo:nil];
                    [self.liveManager.roomManager publishVideo:nil];
                }
                if (YSCurrentUser.afail == YSDeviceFaultNone)
                {
                    [self.liveManager.roomManager unPublishAudio:nil];
                    [self.liveManager.roomManager publishAudio:nil];
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
}

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

#pragma mark 上课

- (void)handleSignalingClassBeginWihInList:(BOOL)inlist
{    
    [self setupFullTeacherView];
    self.teacherPlaceLab.hidden = YES;
    [self addVidoeViewWithPeerId:self.liveManager.teacher.peerID];
    if (self.liveManager.localUser.role == YSUserType_Patrol)
    {
        [self.topToolBar hideCoursewareBtn:NO];
        [self.topToolBar hidePersonListBtn:NO];
    }
    else
    {
        [self.topToolBar hideCoursewareBtn:YES];
        [self.topToolBar hidePersonListBtn:YES];
    }
    [self freshTeacherPersonListData];
    for (YSRoomUser *roomUser in self.liveManager.userList)
    {
        if (needFreshVideoView)
        {
            needFreshVideoView = NO;
            break;
        }
        
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
    
    if (self.appUseTheType != YSAppUseTheTypeMeeting)
    {
        [self.liveManager stopPlayVideo:YSCurrentUser.peerID completion:nil];
        [self.liveManager stopPlayAudio:YSCurrentUser.peerID completion:nil];
    }
    
    self.boardControlView.allowPaging = NO;
    //self.boardControlView.allowPaging = self.liveManager.roomConfig.canPageTurningFlag;

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
        if (self.appUseTheType == YSAppUseTheTypeSmallClass) {
            
            // 自动上台
            if (self.videoViewArray.count < maxVideoCount)
            {
                BOOL autoOpenAudioAndVideoFlag = self.liveManager.roomConfig.autoOpenAudioAndVideoFlag;
                if (autoOpenAudioAndVideoFlag)
                {
                    if (YSCurrentUser.vfail == YSDeviceFaultNone)
                    {
                        [self.liveManager.roomManager publishVideo:nil];
                    }
                    if (YSCurrentUser.afail == YSDeviceFaultNone)
                    {
                        [self.liveManager.roomManager publishAudio:nil];
                    }
                }
            }
        }
        else if (self.appUseTheType == YSAppUseTheTypeMeeting)
        {//会议，进教室默认上台
            if (self.liveManager.isBeginClass && self.videoViewArray.count < maxVideoCount)
            {
                if (YSCurrentUser.vfail == YSDeviceFaultNone)
                {
                    [self.liveManager.roomManager publishVideo:nil];
                }
                if (YSCurrentUser.afail == YSDeviceFaultNone)
                {
                    [self.liveManager.roomManager publishAudio:nil];
                }
                
                [self.liveManager sendSignalingToChangePropertyWithRoomUser:YSCurrentUser withKey:sUserCandraw WithValue:@(true)];
            }
        }
    }
    else
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
            [self.progressHUD bm_showAnimated:NO withDetailText:@"出现后台问题！！！！！！！！" delay:10];
#endif

            [self.liveManager.roomManager changeUserProperty:YSCurrentUser.peerID tellWhom:YSRoomPubMsgTellAll key:sUserIsInBackGround value:@(isInBackGround) completion:nil];
        }
    }
}

/// 下课
- (void)handleSignalingClassEndWithText:(NSString *)text
{
    [self.controlPopoverView dismissViewControllerAnimated:YES completion:nil];
    
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
    [self.controlPopoverView dismissViewControllerAnimated:YES completion:nil];
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
        self.boardControlView.hidden = (self.roomLayout == YSLiveRoomLayout_VideoLayout) || (self.roomLayout == YSLiveRoomLayout_FocusLayout);
        if (YSCurrentUser.canDraw)
        {
            self.brushToolView.hidden = (self.roomLayout == YSLiveRoomLayout_VideoLayout) || (self.roomLayout == YSLiveRoomLayout_FocusLayout);
        }
    }
    
    if (!YSCurrentUser.canDraw || self.brushToolView.hidden || !self.brushToolView.toolsBtn.selected || self.brushToolView.mouseBtn.selected )
    {
        self.drawBoardView.hidden = YES;
    }
    else
    {
        self.drawBoardView.hidden = NO;
    }
    
    if (roomLayout == YSLiveRoomLayout_FocusLayout)
    {
        for (SCVideoView *videoView in self.videoViewArray)
        {
            if ([videoView.roomUser.peerID isEqualToString: peerId])
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

#if USE_YSRenderMode_adaptive
#else
        [self playVideoAudioWithVideoView:videoView needFreshVideo:YES];
#endif
    }
    else
    {
        SCVideoView *videoView = (SCVideoView *)self.doubleFloatView.contentView;
        videoView.isFullScreen = NO;
        [self.doubleFloatView cleanContent];
        [self.doubleFloatView removeFromSuperview];
        [self freshContentView];
        self.doubleFloatView = nil;
        
#if USE_YSRenderMode_adaptive
#else
        [self playVideoAudioWithVideoView:videoView needFreshVideo:YES];
#endif
    }
    
    if (!self.isWhitebordFullScreen)
    {
        self.boardControlView.hidden = isFull;
        if (YSCurrentUser.canDraw)
        {
            self.brushToolView.hidden = isFull;
        }
    }
    if (!YSCurrentUser.canDraw || self.brushToolView.hidden || !self.brushToolView.toolsBtn.selected || self.brushToolView.mouseBtn.selected )
    {
        self.drawBoardView.hidden = YES;
    }
    else
    {
        self.drawBoardView.hidden = NO;
    }
    
//    [self freshWhiteBordViewFrame];
}

#pragma mark 白板视频/音频

// 播放白板视频/音频
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

// 停止白板视频/音频
- (void)handleWhiteBordStopMediaFileWithMedia:(YSLiveMediaModel *)mediaModel
{
    [self freshTeacherCoursewareListDataWithPlay:NO];
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
}

/// 继续播放白板视频/音频
- (void)handleWhiteBordPlayMediaStream
{
    if (!self.liveManager.playMediaModel.video && self.liveManager.playMediaModel.audio)
    {
        [self onPlayMp3];
    }
     [self freshTeacherCoursewareListDataWithPlay:YES];
}

/// 暂停播放白板视频/音频
- (void)handleWhiteBordPauseMediaStream
{
    if (!self.liveManager.playMediaModel.video && self.liveManager.playMediaModel.audio)
    {
        [self onPauseMp3];
    }
    [self freshTeacherCoursewareListDataWithPlay:NO];
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

#pragma mark 白板翻页 换课件

- (void)handleSignalingWhiteBroadShowPageMessage:(NSDictionary *)message isDynamic:(BOOL)isDynamic
{
    [self.boardControlView resetBtnStates];
    [self freshTeacherCoursewareListDataWithPlay:NO];
    // 只处理白板显示课件刷新回调

    if (!isDynamic)
    {
        self.boardControlView.bm_width = 246;
        if (self.boardControlView.bm_right > UI_SCREEN_WIDTH)
        {
            self.boardControlView.bm_left = UI_SCREEN_WIDTH - self.boardControlView.bm_width - 2;
        }
        //self.boardControlView.bm_centerX = self.view.bm_centerX;
        
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
        
        CGFloat newX = weakSelf.responderView.noticeView.bm_centerX+arc4random_uniform(2 * UI_SCREEN_WIDTH/2 + 1) - UI_SCREEN_WIDTH/2;
        CGFloat newY = weakSelf.responderView.noticeView.bm_centerY+arc4random_uniform(2 * UI_SCREEN_HEIGHT/2 + 1) - UI_SCREEN_HEIGHT/2;
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
        
        if (weakSelf.responderView.noticeView.bm_bottom > UI_SCREEN_HEIGHT)
        {
            weakSelf.responderView.noticeView.bm_top = UI_SCREEN_HEIGHT - weakSelf.responderView.noticeView.bm_height;
        }
        if (weakSelf.responderView.noticeView.bm_right > UI_SCREEN_WIDTH)
        {
            weakSelf.responderView.noticeView.bm_left = UI_SCREEN_WIDTH - weakSelf.responderView.noticeView.bm_width;
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
    [self.controlPopoverView dismissViewControllerAnimated:YES completion:nil];
    
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


/// 停止全屏老师视频流 并开始常规老师视频流
- (void)stopFullTeacherVideoView
{
    [self.fullTeacherFloatView removeFromSuperview];
    [self stopVideoAudioWithVideoView:self.fullTeacherVideoView];
    [self playVideoAudioWithNewVideoView:self.teacherVideoView];
    self.raiseHandsBtn.frame = CGRectMake(UI_SCREEN_WIDTH-40-26, UI_SCREEN_HEIGHT - self.whitebordBackgroud.bm_height+20, 40, 40);
}

/// 播放全屏老师视频流
- (void)playFullTeacherVideoViewInView:(UIView *)view
{
    if (self.liveManager.isBeginClass)
    {/// 全屏课件老师显示
        [self stopVideoAudioWithVideoView:self.teacherVideoView];
        [self.fullTeacherFloatView removeFromSuperview];
        
        [view addSubview:self.fullTeacherFloatView];
        [self.fullTeacherFloatView cleanContent];
        SCVideoView *fullTeacherVideoView = [[SCVideoView alloc] initWithRoomUser:self.liveManager.teacher isForPerch:NO];
        fullTeacherVideoView.frame = self.fullTeacherFloatView.bounds;
        [self.fullTeacherFloatView showWithContentView:fullTeacherVideoView];
        
        fullTeacherVideoView.appUseTheType = self.appUseTheType;
        [self playVideoAudioWithNewVideoView:fullTeacherVideoView];
        self.fullTeacherVideoView = fullTeacherVideoView;
        
        if (view == self.whitebordFullBackgroud)
        {
            [self.raiseHandsBtn bm_bringToFront];
            
            self.raiseHandsBtn.frame = CGRectMake(UI_SCREEN_WIDTH-40-26, self.fullTeacherFloatView.bm_top, 40, 40);
        }
        
    }
    
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
    YSRoomUser * userModel = videoView.roomUser;
    
    SCUserPublishState userPublishState = userModel.liveUserPublishState;
    if (videoView.roomUser.peerID != YSCurrentUser.peerID || userPublishState == SCUserPublishState_NONE)
    {
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
    self.controlPopoverView.videoMirrorMode = self.videoMirrorMode;
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
                self.videoMirrorMode = YSVideoMirrorModeEnabled;
            }
            else
            {
                [self.liveManager changeLocalVideoMirrorMode:YSVideoMirrorModeDisabled];
                self.videoMirrorMode = YSVideoMirrorModeDisabled;
            }
        }
            break;
        default:
            break;
    }
}

@end
