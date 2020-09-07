//
//  CHMainViewController.m
//  CHLiveSample
//
//

#import "CHMainViewController.h"
#import "SCBrushToolView.h"
#import "SCDrawBoardView.h"


@interface CHMainViewController ()
<
    SCBrushToolViewDelegate,
    SCDrawBoardViewDelegate
>

@property (nonatomic, weak) CloudHubManager *cloudHubManager;

@property (nonatomic, weak) CHWhiteBoardSDKManager *whiteBoardSDKManager;
/// 固定UserId
@property (nonatomic, strong) NSString *userId;

/// 主白板
@property (nonatomic, strong) UIView *mainWhiteBoardView;

/// 左侧工具栏
@property (nonatomic, strong) SCBrushToolView *brushToolView;
/// 画笔工具按钮（控制工具条的展开收起）
@property (nonatomic, strong) UIButton *brushToolOpenBtn;
/// 画笔选择 颜色 大小 形状
@property (nonatomic, strong) SCDrawBoardView *drawBoardView;

@end

@implementation CHMainViewController

- (instancetype)initWithwhiteBordView:(UIView *)whiteBordView userId:(nullable NSString *)userId
{
    self = [self init];
    if (self)
    {
        self.userId = userId;
        self.mainWhiteBoardView = whiteBordView;
        self.whiteBoardSDKManager = [CHWhiteBoardSDKManager sharedInstance];
        
        self.view.backgroundColor = [UIColor blackColor];
    }
    return self;
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


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cloudHubManager = [CloudHubManager sharedInstance];
    
    [self.view addSubview:self.mainWhiteBoardView];
    self.mainWhiteBoardView.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH_ROTATE, UI_SCREEN_HEIGHT_ROTATE);
    
    [self setupBrushToolView];
    
    UIButton *canDrawBtn = [[UIButton alloc]initWithFrame:CGRectMake(100, 50, 100, 50)];
    [canDrawBtn addTarget:self action:@selector(canDrawBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [canDrawBtn setTitle:@"画笔权限" forState:UIControlStateNormal];
    [canDrawBtn setTitleColor:UIColor.redColor forState:UIControlStateNormal];
    [canDrawBtn setBackgroundColor:UIColor.yellowColor];
    [self.view addSubview:canDrawBtn];
    canDrawBtn.selected = YES;
    
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(UI_SCREEN_WIDTH - 150, 50, 100, 50)];
    [backBtn addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setTitle:@"返回登录页" forState:UIControlStateNormal];
    [backBtn setTitleColor:UIColor.redColor forState:UIControlStateNormal];
    [backBtn setBackgroundColor:UIColor.yellowColor];
    [self.view addSubview:backBtn];
    
    UIButton *scaleBtn = [[UIButton alloc]initWithFrame:CGRectMake(150, UI_SCREEN_WIDTH - 100, 100, 50)];
    [scaleBtn addTarget:self action:@selector(scaleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [scaleBtn setTitle:@"比例" forState:UIControlStateNormal];
    [scaleBtn setTitleColor:UIColor.redColor forState:UIControlStateNormal];
    [scaleBtn setBackgroundColor:UIColor.yellowColor];
    [self.view addSubview:scaleBtn];
    
}

- (void)canDrawBtnClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    [self.whiteBoardSDKManager setCandraw:sender.selected];
    
    self.brushToolOpenBtn.hidden = self.brushToolView.hidden = !sender.selected;
}

- (void)backBtnClick:(UIButton *)sender
{
    [self.cloudHubManager.cloudHubRtcEngineKit leaveChannel:nil];
}

- (void)scaleBtnClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.selected)
    {
        [self.whiteBoardSDKManager setWhiteBoardRatio:16.0/9.0];
    }
    else
    {
        [self.whiteBoardSDKManager setWhiteBoardRatio:4.0/3.0];
    }
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
//    self.brushToolView.hidden = YES;
    
    UIButton *brushToolOpenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [brushToolOpenBtn addTarget:self action:@selector(brushToolOpenBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [brushToolOpenBtn setBackgroundImage:CHSkinElementImage(@"brushTool_open", @"iconNor") forState:UIControlStateNormal];
    [brushToolOpenBtn setBackgroundImage:CHSkinElementImage(@"brushTool_open", @"iconSel") forState:UIControlStateSelected];
    brushToolOpenBtn.frame = CGRectMake(0, 0, 25, 37);
    brushToolOpenBtn.bm_centerY = self.brushToolView.bm_centerY;
    brushToolOpenBtn.bm_left = self.brushToolView.bm_right;
    self.brushToolOpenBtn = brushToolOpenBtn;
    [self.view addSubview:brushToolOpenBtn];
}

#pragma mark 画笔工具展开收起

- (void)brushToolOpenBtnClick:(UIButton *)btn
{
    btn.selected = !btn.selected;
    CGFloat leftGap = 10;
    if (BMIS_IPHONEXANDP)
    {
        leftGap = BMUI_HOME_INDICATOR_HEIGHT;
    }
    CGFloat tempWidth = [CHCommonTools deviceIsIPad] ? 50.0f : 36.0f;
    if (btn.selected)
    {
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

#pragma mark SCBrushToolViewDelegate

- (void)brushToolViewType:(CHBrushToolType)toolViewBtnType withToolBtn:(nonnull UIButton *)toolBtn
{
    [self.whiteBoardSDKManager brushSDKToolsDidSelect:toolViewBtnType];

    if (self.drawBoardView)
    {
        [self.drawBoardView removeFromSuperview];
    }
    
    self.drawBoardView = [[SCDrawBoardView alloc] init];
    self.drawBoardView.delegate = self;
    self.drawBoardView.brushToolType = toolViewBtnType;
    [self.view addSubview:self.drawBoardView];
    
    CHWeakSelf
    [self.drawBoardView.backgroundView  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.brushToolOpenBtn.mas_right).mas_offset(10);
        make.centerY.mas_equalTo(weakSelf.brushToolOpenBtn.mas_centerY);
    }];
}
#pragma mark - 需要传递给白板的数据
#pragma mark SCDrawBoardViewDelegate

- (void)brushSelectorViewDidSelectDrawType:(CHDrawType)drawType color:(NSString *)hexColor widthProgress:(float)progress
{
    [self.whiteBoardSDKManager didSDKSelectDrawType:drawType color:hexColor widthProgress:progress];
}


#pragma mark -
#pragma mark CloudHubManagerDelegate

- (void)onRoomJoined
{
}

/// 成功重连房间
- (void)onRoomReJoined
{
    
}

/**
    失去连接
 */
- (void)onRoomConnectionLost
{
    NSLog(@"onRoomConnectionLost");

}

/**
    已经离开房间
 */
- (void)onRoomLeft
{
    NSLog(@"onRoomLeft");
    
    [CloudHubManager destroy];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    //GetAppDelegate.allowRotation = NO;
}

/**
    自己被踢出房间
    @param reasonCode 被踢原因
 */
- (void)onRoomKickedOut:(NSInteger)reasonCode
{
    NSLog(@"onRoomKickedOut");

}

- (void)onRoomDidOccuredError:(CloudHubErrorCode)errorCode withMessage:(NSString *)message
{

}

- (void)onUpdateTimeWithTimeInterval:(NSTimeInterval)timeInterval
{
    
}


#pragma mark - CHWhiteBoardManagerDelegate

/// 白板准备完毕
- (void)onWhiteBroadCheckRoomFinish:(BOOL)finished
{
    
}

/**
 文件列表回调
 @param fileList 文件NSDictionary列表
 */
- (void)onWhiteBroadFileList:(NSArray *)fileList
{
    
}

/// H5脚本文件加载初始化完成
- (void)onWhiteBoardPageFinshed:(NSString *)fileId
{
    
}

/// 切换Web课件加载状态
- (void)onWhiteBoardLoadedState:(NSString *)fileId withState:(NSDictionary *)dic
{
    
}

/// Web课件翻页结果
- (void)onWhiteBoardStateUpdate:(NSString *)fileId withState:(NSDictionary *)dic
{
    
}
/// 翻页超时
- (void)onWhiteBoardSlideLoadTimeout:(NSString *)fileId withState:(NSDictionary *)dic
{
    
}
/// 课件缩放
- (void)onWhiteBoardZoomScaleChanged:(NSString *)fileId zoomScale:(CGFloat)zoomScale
{
    
}


#pragma mark - 课件事件

/// 课件全屏
- (void)onWhiteBoardFullScreen:(BOOL)isAllScreen
{
    
}

/// 切换课件
- (void)onWhiteBoardChangedFileWithFileList:(NSArray *)fileList
{
    
}


/// 课件窗口最大化事件
- (void)onWhiteBoardMaximizeView
{
    
}

@end
