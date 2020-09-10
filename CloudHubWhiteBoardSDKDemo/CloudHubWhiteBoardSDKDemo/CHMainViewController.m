//
//  CHMainViewController.m
//  CHLiveSample
//
//

#import "CHMainViewController.h"
#import "SCBrushToolView.h"
#import "SCDrawBoardView.h"
#import "FileListTableViewCell.h"


@interface CHMainViewController ()
<
    SCBrushToolViewDelegate,
    SCDrawBoardViewDelegate,
    UITableViewDelegate,
    UITableViewDataSource,
    CoursewareListCellDelegate
>

@property (nonatomic, weak) CloudHubWhiteBoardKit *cloudHubManager;

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
/// 课件列表
@property (nonatomic, strong) UIButton *fileListBtn;
@property (nonatomic, strong) UITableView *fileTableView;
@end

@implementation CHMainViewController

- (instancetype)initWithwhiteBordView:(UIView *)whiteBordView userId:(nullable NSString *)userId
{
    self = [self init];
    if (self)
    {
        self.userId = userId;
        self.mainWhiteBoardView = whiteBordView;
        
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
    
    self.cloudHubManager = [CloudHubWhiteBoardKit sharedInstance];
    
    [self.view addSubview:self.mainWhiteBoardView];
    self.mainWhiteBoardView.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH_ROTATE, UI_SCREEN_HEIGHT_ROTATE);
    
    [self setupBrushToolView];
    
    
#warning - 操作的临时按钮

    UIButton *fileListBtn = [[UIButton alloc]initWithFrame:CGRectMake(50, 20, 50, 50)];
    fileListBtn.titleLabel.font = [UIFont systemFontOfSize:10.0f];
    [fileListBtn addTarget:self action:@selector(showFileList:) forControlEvents:UIControlEventTouchUpInside];
    [fileListBtn setTitle:@"课件库" forState:UIControlStateNormal];
    [fileListBtn setTitleColor:UIColor.redColor forState:UIControlStateNormal];
    [fileListBtn setBackgroundColor:UIColor.yellowColor];
    [self.view addSubview:fileListBtn];
    self.fileListBtn = fileListBtn;
    
    [self setupFileList];
    
    
    UIButton *canDrawBtn = [[UIButton alloc]initWithFrame:CGRectMake(fileListBtn.bm_right + 30, 20, 80, 50)];
    [canDrawBtn addTarget:self action:@selector(buttomsClick:) forControlEvents:UIControlEventTouchUpInside];
    [canDrawBtn setTitle:@"画笔权限" forState:UIControlStateNormal];
    [canDrawBtn setTitleColor:UIColor.redColor forState:UIControlStateNormal];
    [canDrawBtn setBackgroundColor:UIColor.yellowColor];
    [self.view addSubview:canDrawBtn];
    canDrawBtn.selected = YES;
    
    UIButton *scaleBtn = [[UIButton alloc]initWithFrame:CGRectMake(canDrawBtn.bm_right + 100, 20, 80, 50)];
    [scaleBtn addTarget:self action:@selector(buttomsClick:) forControlEvents:UIControlEventTouchUpInside];
    [scaleBtn setTitle:@"比例" forState:UIControlStateNormal];
    [scaleBtn setTitleColor:UIColor.redColor forState:UIControlStateNormal];
    [scaleBtn setBackgroundColor:UIColor.yellowColor];
    [self.view addSubview:scaleBtn];
    
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(scaleBtn.bm_right + 100, 20, 90, 50)];
    [backBtn addTarget:self action:@selector(buttomsClick:) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setTitle:@"返回登录" forState:UIControlStateNormal];
    [backBtn setTitleColor:UIColor.redColor forState:UIControlStateNormal];
    [backBtn setBackgroundColor:UIColor.yellowColor];
    [self.view addSubview:backBtn];
    
    canDrawBtn.tag = 1;
    scaleBtn.tag = 2;
    backBtn.tag = 3;
}


- (void)buttomsClick:(UIButton *)sender
{
    switch (sender.tag)
    {
        case 1:
        {
            sender.selected = !sender.selected;
            
            [self.cloudHubManager setCandraw:sender.selected];
            
            self.brushToolOpenBtn.hidden = self.brushToolView.hidden = !sender.selected;
        }
            break;
        case 2:
        {
            sender.selected = !sender.selected;
            if (sender.selected)
            {
                [self.cloudHubManager setWhiteBoardRatio:4.0/3.0];
            }
            else
            {
                [self.cloudHubManager setWhiteBoardRatio:16.0/9.0];
            }
        }
            break;
        case 3:
        {
            [self.cloudHubRtcEngineKit leaveChannel:nil];
            
        }
            break;
            
        default:
            break;
    }
}

/// 离开房间
- (void)rtcEngine:(CloudHubRtcEngineKit *)engine didLeaveChannel:(CloudHubChannelStats *)stats
{
    [CloudHubWhiteBoardKit destroy];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)setupFileList
{
    UITableView *fileTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.fileTableView = fileTableView;
    [self.view addSubview:self.fileTableView];
    
    fileTableView.bounces = NO;
    fileTableView.backgroundColor = [UIColor blackColor];
    fileTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    fileTableView.delegate = self;
    fileTableView.dataSource = self;
    fileTableView.showsVerticalScrollIndicator = YES;
    [fileTableView registerClass:[FileListTableViewCell class] forCellReuseIdentifier:@"FileListTableViewCell"];
    [self.fileTableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cloudHubManager.fileList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FileListTableViewCell * coursewareCell = [tableView dequeueReusableCellWithIdentifier:@"FileListTableViewCell" forIndexPath:indexPath];
    if (indexPath.row < self.cloudHubManager.fileList.count)
    {
        CHFileModel * model = self.cloudHubManager.fileList[indexPath.row];
        
        [coursewareCell setFileModel:model];
    }
    coursewareCell.delegate = self;
    return coursewareCell;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return 40;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CHFileModel * model = self.cloudHubManager.fileList[indexPath.row];
    [self.cloudHubManager changeCourseWithFileId:model.fileid];
}

- (void)showFileList:(UIButton *)btn
{
    btn.selected = !btn.selected;
    if (btn.selected)
    {
        self.fileTableView.frame = CGRectMake(UI_SCREEN_WIDTH - 300, 0, 300, UI_SCREEN_HEIGHT);
    }
    else
    {
        self.fileTableView.frame = CGRectMake(UI_SCREEN_WIDTH , 0, 300, UI_SCREEN_HEIGHT);
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
    self.brushToolView.bm_centerY = self.view.bm_centerX;
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
    [self.cloudHubManager brushSDKToolsDidSelect:toolViewBtnType];

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
    [self.cloudHubManager didSDKSelectDrawType:drawType color:hexColor widthProgress:progress];
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