//
//  YSMainViewController.m
//  YSLiveSample
//
//  Created by 马迪 on 2020/9/1.
//  Copyright © 2020 yunshuxunlian. All rights reserved.
//

#import "YSMainViewController.h"
#import "SCBrushToolView.h"
#import "SCDrawBoardView.h"


@interface YSMainViewController ()
<
    SCBrushToolViewDelegate,
    SCDrawBoardViewDelegate
>


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

@implementation YSMainViewController

- (instancetype)initWithwhiteBordView:(UIView *)whiteBordView userId:(nullable NSString *)userId
{
    self = [self init];
    if (self)
    {
        self.userId = userId;
        self.mainWhiteBoardView = whiteBordView;
        self.whiteBoardSDKManager = [CHWhiteBoardSDKManager sharedInstance];
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
        
    self.view.backgroundColor = UIColor.redColor;
    
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
    
    [self.whiteBoardSDKManager changeUserCandraw:sender.selected];
    
    self.brushToolOpenBtn.hidden = self.brushToolView.hidden = !sender.selected;
}

- (void)backBtnClick:(UIButton *)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)scaleBtnClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.selected)
    {
        [self.whiteBoardSDKManager setTheWhiteBoardRatio:16.0/9.0];
    }
    else
    {
        [self.whiteBoardSDKManager setTheWhiteBoardRatio:4.0/3.0];
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
    [brushToolOpenBtn setBackgroundImage:YSSkinElementImage(@"brushTool_open", @"iconNor") forState:UIControlStateNormal];
    [brushToolOpenBtn setBackgroundImage:YSSkinElementImage(@"brushTool_open", @"iconSel") forState:UIControlStateSelected];
    brushToolOpenBtn.frame = CGRectMake(0, 0, 25, 37);
    brushToolOpenBtn.bm_centerY = self.brushToolView.bm_centerY;
    brushToolOpenBtn.bm_left = self.brushToolView.bm_right;
    self.brushToolOpenBtn = brushToolOpenBtn;
    [self.view addSubview:brushToolOpenBtn];
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
           CGFloat tempWidth = [YSCommonTools deviceIsIPad] ? 50.0f : 36.0f;
           if (btn.selected)
           {
//               self.drawBoardView.hidden = YES;
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
    
    YSWeakSelf
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


@end
