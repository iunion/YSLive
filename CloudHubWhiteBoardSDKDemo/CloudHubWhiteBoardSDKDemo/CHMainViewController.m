//
//  CHMainViewController.m
//  CHLiveSample
//
//

#import "CHMainViewController.h"
#import "SCBrushToolView.h"
#import "SCDrawBoardView.h"
#import "FileListTableViewCell.h"

#import "TZImagePickerController.h"


@interface CHMainViewController ()
<
    SCBrushToolViewDelegate,
    SCDrawBoardViewDelegate,
    UITableViewDelegate,
    UITableViewDataSource,
    CoursewareListCellDelegate,
    TZImagePickerControllerDelegate

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
/// 当前展示课件数组
@property (nonatomic, strong) NSMutableArray *currentFileList;
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
/// iPone设备上，默认返回值UIInterfaceOrientationMaskAllButUpSideDwon
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
    self.currentFileList = [[NSMutableArray alloc] init];
    self.cloudHubManager = [CloudHubWhiteBoardKit sharedInstance];
    
    [self.view addSubview:self.mainWhiteBoardView];
    self.mainWhiteBoardView.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH_ROTATE, UI_SCREEN_HEIGHT_ROTATE);
    
    [self setupBrushToolView];
    
    
#warning - 操作的临时按钮
    [self setupButtonsUI];
    
    //展示课件库
    [self setupFileList];
    
    //初始化画笔
    [self resetDrawTools];
}

- (void)resetDrawTools
{
    [self.brushToolView resetTool];
    self.drawBoardView.brushToolType = CHBrushToolTypeLine;
    self.drawBoardView.hidden = YES;
}

- (void)setupButtonsUI
{
    UIButton *fileListBtn = [[UIButton alloc]initWithFrame:CGRectMake(50, 20, 50, 50)];
    fileListBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [fileListBtn addTarget:self action:@selector(showFileList:) forControlEvents:UIControlEventTouchUpInside];
    [fileListBtn setTitle:@"课件库" forState:UIControlStateNormal];
    [fileListBtn setTitleColor:UIColor.redColor forState:UIControlStateNormal];
    
    [self.view addSubview:fileListBtn];
    self.fileListBtn = fileListBtn;
    
    UIButton *canDrawBtn = [[UIButton alloc]initWithFrame:CGRectMake(fileListBtn.bm_right + 30, 20, 80, 50)];
    [canDrawBtn addTarget:self action:@selector(buttomsClick:) forControlEvents:UIControlEventTouchUpInside];
    [canDrawBtn setTitle:@"画笔权限" forState:UIControlStateNormal];
    canDrawBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [canDrawBtn setTitleColor:UIColor.redColor forState:UIControlStateNormal];
    [canDrawBtn setBackgroundColor:UIColor.yellowColor];
    [self.view addSubview:canDrawBtn];
    canDrawBtn.selected = YES;
    
//    UIButton *scaleBtn = [[UIButton alloc]initWithFrame:CGRectMake(canDrawBtn.bm_right + 50, 20, 50, 50)];
//    [scaleBtn addTarget:self action:@selector(buttomsClick:) forControlEvents:UIControlEventTouchUpInside];
//    [scaleBtn setTitle:@"比例" forState:UIControlStateNormal];
//    scaleBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
//    [scaleBtn setTitleColor:UIColor.redColor forState:UIControlStateNormal];
//    [scaleBtn setBackgroundColor:UIColor.yellowColor];
//    scaleBtn.enabled = NO;
//    [self.view addSubview:scaleBtn];
    
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(canDrawBtn.bm_right + 50, 20, 80, 50)];
    [backBtn addTarget:self action:@selector(buttomsClick:) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setTitle:@"返回登录" forState:UIControlStateNormal];
    backBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [backBtn setTitleColor:UIColor.redColor forState:UIControlStateNormal];
    [backBtn setBackgroundColor:UIColor.yellowColor];
    [self.view addSubview:backBtn];
    
    UIButton *imageBtn = [[UIButton alloc]initWithFrame:CGRectMake(backBtn.bm_right + 50, 20, 100, 50)];
    [imageBtn addTarget:self action:@selector(buttomsClick:) forControlEvents:UIControlEventTouchUpInside];
    [imageBtn setTitle:@"上传图片课件" forState:UIControlStateNormal];
    imageBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [imageBtn setTitleColor:UIColor.redColor forState:UIControlStateNormal];
    [imageBtn setBackgroundColor:UIColor.yellowColor];
    [self.view addSubview:imageBtn];
    
    UIButton *uploadFileBtn = [[UIButton alloc]initWithFrame:CGRectMake(imageBtn.bm_right + 50, 20, 80, 50)];
    [uploadFileBtn addTarget:self action:@selector(buttomsClick:) forControlEvents:UIControlEventTouchUpInside];
    [uploadFileBtn setTitle:@"上传课件" forState:UIControlStateNormal];
    uploadFileBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [uploadFileBtn setTitleColor:UIColor.redColor forState:UIControlStateNormal];
    [uploadFileBtn setBackgroundColor:UIColor.yellowColor];
    [self.view addSubview:uploadFileBtn];
    
    UIButton *canControlShape = [[UIButton alloc]initWithFrame:CGRectMake(uploadFileBtn.bm_right + 50, 20, 80, 50)];
    [canControlShape addTarget:self action:@selector(buttomsClick:) forControlEvents:UIControlEventTouchUpInside];
    [canControlShape setTitle:@"操作所有" forState:UIControlStateNormal];
    [canControlShape setTitle:@"操作自己" forState:UIControlStateSelected];
    canControlShape.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [canControlShape setTitleColor:UIColor.redColor forState:UIControlStateNormal];
    [canControlShape setBackgroundColor:UIColor.yellowColor];
    [self.view addSubview:canControlShape];

    canDrawBtn.tag = 1;
    //scaleBtn.tag = 2;
    backBtn.tag = 3;
    imageBtn.tag = 4;
    uploadFileBtn.tag = 5;
    canControlShape.tag = 6;
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
//            sender.selected = !sender.selected;
//            if (sender.selected)
//            {
//                [self.cloudHubManager setWhiteBoardRatio:4.0/3.0];
//            }
//            else
//            {
//                [self.cloudHubManager setWhiteBoardRatio:16.0/9.0];
//            }
        }
            break;
        case 3:
        {
            [self.cloudHubRtcEngineKit leaveChannel:nil];
            
        }
            break;
        case 4:
        {
            [self openTheImagePickerWithImage];
        }
            break;
        case 5:
        {
            NSArray *pagesAddr = @[@"https://b-ssl.duitang.com/uploads/item/201611/04/20161104110413_XzVAk.gif",
                @"https://rddoccdndemows.roadofcloud.net/upload/20200515_174835_tmrpbqsc-1.pdf",
                                   @"https://rddoccdndemows.roadofcloud.net/upload/20200515_174835_tmrpbqsc-2.jpg",
                                   @"https://rddoccdndemows.roadofcloud.net/upload/20200515_174835_tmrpbqsc-3.jpg",
                                   @"https://rddoccdndemows.roadofcloud.net/upload/20200515_174835_tmrpbqsc-4.jpg",
                                   @"https://rddoccdndemows.roadofcloud.net/upload/20200515_174835_tmrpbqsc-5.jpg",
                                   @"https://rddoccdndemows.roadofcloud.net/upload/20200515_174835_tmrpbqsc-6.jpg",
                                   @"https://rddoccdndemows.roadofcloud.net/upload/20200515_174835_tmrpbqsc-7.jpg",
                                   @"https://rddoccdndemows.roadofcloud.net/upload/20200515_174835_tmrpbqsc-8.jpg",
                                   @"https://rddoccdndemows.roadofcloud.net/upload/20200515_174835_tmrpbqsc-9.jpg",
                                   @"https://rddoccdndemows.roadofcloud.net/upload/20200515_174835_tmrpbqsc-10.jpg",
                                   @"https://rddoccdndemows.roadofcloud.net/upload/20200515_174835_tmrpbqsc-11.jpg"
            ];
            
            [self.cloudHubManager addCustomFileDateWithFileId:@"-2394" fileProp:CHWhiteBordFileProp_GeneralFile fileType:@"ppt" fileName:@"分数除法三.ppt" pagesAddr:pagesAddr];
        }
            break;

        case 6:
        {
            sender.selected = !sender.selected;
            [self.cloudHubManager setIsOnlyOperationSelfShape:sender.selected];
            [self.cloudHubManager getUndoRedoState];
        }
            break;
            
        default:
            break;
    }
}
#pragma mark - 打开相册选择图片

//- (void)openTheImagePickerWithImageUseType:(SCUploadImageUseType)imageUseType
- (void)openTheImagePickerWithImage
{
    TZImagePickerController * imagePickerController = [[TZImagePickerController alloc]initWithMaxImagesCount:3 columnNumber:1 delegate:self pushPhotoPickerVc:YES];
    imagePickerController.showPhotoCannotSelectLayer = YES;
    imagePickerController.allowTakeVideo = NO;
    imagePickerController.allowPickingVideo = NO;
    imagePickerController.showSelectedIndex = YES;
    imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
    imagePickerController.sortAscendingByModificationDate = NO;
    
    __weak __typeof(self) weakSelf = self;
    [imagePickerController setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        [weakSelf.cloudHubManager uploadImageCourseWithImage:photos.firstObject success:^(NSDictionary * _Nonnull imageDict) {

            NSLog(@"%@", imageDict);
            
        } failure:^(NSInteger errorCode) {
            
        }];
    }];

//    self.imagePickerController = imagePickerController;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}


- (void)setupFileList
{
    UITableView *fileTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.fileTableView = fileTableView;
    [self.view addSubview:self.fileTableView];
    
    fileTableView.bounces = NO;
    fileTableView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8f];
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
        BOOL isCurrent = [self.currentFileList containsObject:model.fileid];
        [coursewareCell setFileModel:model isCurrent:isCurrent];
    }
    coursewareCell.delegate = self;
    return coursewareCell;
}


#pragma mark CoursewareListCellDelegate
- (void)deleteBtnWithFileModel:(CHFileModel *)fileModel
{
    /// 删除课件
    [self.cloudHubManager deleteCourseWithFileId:fileModel.fileid];
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (void)sendCreateMoreWBWithFileId:(NSString *)fileid
{
    NSString *instanceId = [NSString stringWithFormat:@"docModule_%@", fileid];
//    instanceId = [CHWhiteBoardUtil getSourceInstanceIdFromFileId:model.fileid];
    NSString *msgID = [NSString stringWithFormat:@"CreateMoreWB_%@", instanceId];
    NSDictionary *data = @{@"instanceId" : instanceId};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
    NSString *dataStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [self.cloudHubManager.cloudHubRtcEngineKit pubMsg:@"CreateMoreWB" msgId:msgID to:CHRoomPubMsgTellAll withData:dataStr associatedWithUser:nil associatedWithMsg:nil save:YES extraData:@""];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CHFileModel *model = self.cloudHubManager.fileList[indexPath.row];
    if (self.cloudHubManager.cloudHubWhiteBoardConfig.isMultiCourseware)
    {
        [self sendCreateMoreWBWithFileId:model.fileid];
    }
    [self.cloudHubManager changeCourseWithFileId:model.fileid];
}

- (void)showFileList:(UIButton *)btn
{
    btn.selected = !btn.selected;
    if (btn.selected)
    {
        self.fileTableView.frame = CGRectMake(UI_SCREEN_WIDTH - 300, 40, 300, UI_SCREEN_HEIGHT-80);
        [self.fileTableView reloadData];
    }
    else
    {
        self.fileTableView.frame = CGRectMake(UI_SCREEN_WIDTH , 40, 300, UI_SCREEN_HEIGHT-80);
    }
    
}

#pragma mark UI 工具栏

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
    [self.cloudHubManager changeBrushToolsType:toolViewBtnType];

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

- (void)brushToolClikWithToolBtn:(nonnull UIButton *)toolBtn
{
    if (toolBtn.tag == CHDrawTypeClear)
    {
        [self brushSelectorViewDidSelectDrawType:CHDrawTypeClear color:@"" widthProgress:0];
    }
    else if (toolBtn.tag == CHBrushToolTypeUndo)
    {
        NSLog(@"点击了undo按钮");
        
        [self.cloudHubManager changeBrushToolsDrawType:CHDrawTypeUndo color:@"" size:0];
        
    }
    else if (toolBtn.tag == CHBrushToolTypeRedo)
    {
        NSLog(@"点击了redo按钮");
        [self.cloudHubManager changeBrushToolsDrawType:CHDrawTypeRedo color:@"" size:0];
    }
}

#pragma mark - 需要传递给白板的数据
#pragma mark SCDrawBoardViewDelegate

- (void)brushSelectorViewDidSelectDrawType:(CHDrawType)drawType color:(NSString *)hexColor widthProgress:(float)progress
{
    [self.cloudHubManager changeBrushToolsDrawType:drawType color:hexColor size:progress];
}


#pragma mark - CloudHubRtcEngineDelegate
- (void)rtcEngine:(CloudHubRtcEngineKit *)engine onPubMsg:(NSString * _Nonnull)msgName msgId:(NSString * _Nonnull)msgId from:(NSString * _Nullable)fromuid withData:(NSString * _Nullable)data associatedWithUser:(NSString * _Nullable)uid associatedWithMsg:(NSString * _Nullable)assMsgID ts:(NSUInteger)ts withExtraData:(NSString * _Nullable)extraData isHistory:(BOOL)isHistory
{
    NSLog(@"PubMsg----%@",msgName);
    NSString *tDataString = [NSString stringWithFormat:@"%@", data];
    NSData *tJsData = [tDataString dataUsingEncoding:NSUTF8StringEncoding];
    
    if (tJsData)
    {
        NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:tJsData
                                                  options:NSJSONReadingMutableContainers
                                                    error:nil];
        NSLog(@"%@",dataDic);
    }
}

- (void)rtcEngine:(CloudHubRtcEngineKit *)engine onDelMsg:(NSString * _Nonnull)msgName msgId:(NSString * _Nonnull)msgId from:(NSString * _Nullable)fromuid withData:(NSString * _Nullable)data
{
    NSLog(@"DelMsg----%@",msgName);
}

/// 离开房间
- (void)rtcEngine:(CloudHubRtcEngineKit *)engine didLeaveChannel:(CloudHubChannelStats *)stats
{
    [CloudHubWhiteBoardKit destroy];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - CHWhiteBoardManagerDelegate

/// 文件列表回调
/// @param fileList 文件NSDictionary列表
- (void)onWhiteBroadFileList:(NSArray <NSDictionary *> *)fileList
{
    [self.fileTableView reloadData];
}

#pragma mark - 交互课件加载事件

/// H5脚本文件加载初始化完成
- (void)onWhiteBoardPageFinshed:(NSString *)fileId
{
    
}

/// 切换交互课件加载状态
- (void)onWhiteBoardLoadInterCourse:(NSString *)fileId isSuccess:(BOOL)isSuccess
{
    
}

#pragma mark - 课件翻页加载事件

/// 课件翻页显示结果
- (void)onWhiteBoardSlideCourse:(NSString *)fileId currentPage:(NSUInteger)currentPage isSuccess:(BOOL)isSuccess
{
    
}

#pragma mark - 课件事件

/// 课件缩放
- (void)onWhiteBoardZoomScaleChanged:(NSString *)fileId zoomScale:(CGFloat)zoomScale
{
    
}

/// 课件全屏
- (void)onWhiteBoardFullScreen:(BOOL)isAllScreen
{
    
}

/// 当前打开的课件列表
- (void)onWhiteBoardChangedFileWithFileList:(NSArray *)fileList
{
    [self.currentFileList removeAllObjects];
    [self.currentFileList addObjectsFromArray:fileList];
    [self.fileTableView reloadData];
}


/// 课件窗口最大化事件
- (void)onWhiteBoardMaximizeView
{
    
}

/// 关闭课件
- (void)onWhiteBoardCloseFileWithFileId:(NSString *)fileId
{
    NSString *instanceId = [NSString stringWithFormat:@"docModule_%@",fileId];
//    instanceId = [CHWhiteBoardUtil getSourceInstanceIdFromFileId:fileId];
    NSString *msgID = [NSString stringWithFormat:@"CreateMoreWB_%@",instanceId];
    
    [self.cloudHubManager.cloudHubRtcEngineKit delMsg:@"CreateMoreWB" msgId:msgID to:CHRoomPubMsgTellAll];
}

- (void)changeUndoRedoState:(NSString *)fileid currentpage:(NSUInteger)currentPage canUndo:(BOOL)canUndo canRedo:(BOOL)canRedo canErase:(BOOL)canErase canClean:(BOOL)canClean
{
    [self.brushToolView freshCanUndo:canUndo canRedo:canRedo];
    [self.brushToolView freshClear:canClean];
    [self.brushToolView freshErase:canErase];
}

@end
