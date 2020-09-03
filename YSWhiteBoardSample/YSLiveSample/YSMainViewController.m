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


@property (nonatomic, weak) YSWhiteBoardSDKManager *whiteBoardSDKManager;
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
        self.whiteBoardSDKManager = [YSWhiteBoardSDKManager sharedInstance];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    [self.view addSubview:self.mainWhiteBoardView];
    self.mainWhiteBoardView.frame = CGRectMake(0, 0, self.view.bm_height, self.view.bm_width);
    
    [self setupBrushToolView];
    
    
    UIButton *canDrawBtn = [[UIButton alloc]initWithFrame:CGRectMake(100, 50, 100, 50)];;
    [canDrawBtn addTarget:self action:@selector(canDrawBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    [canDrawBtn setBackgroundImage:YSSkinElementImage(@"brushTool_open", @"iconNor") forState:UIControlStateNormal];
//    [canDrawBtn setBackgroundImage:YSSkinElementImage(@"brushTool_open", @"iconSel") forState:UIControlStateSelected];
    [canDrawBtn setTitle:@"画笔权限" forState:UIControlStateNormal];
    [canDrawBtn setBackgroundColor:UIColor.yellowColor];
    [self.view addSubview:canDrawBtn];
    canDrawBtn.selected = YES;
    
}

- (void)canDrawBtnClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    [self.whiteBoardSDKManager changeUserCandraw:sender.selected];
    
    self.brushToolOpenBtn.hidden = self.brushToolView.hidden = !sender.selected;
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
//    self.brushToolOpenBtn.hidden = YES;
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
           CGFloat tempWidth = [UIDevice bm_isiPad] ? 50.0f : 36.0f;
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

- (void)brushToolViewType:(YSBrushToolType)toolViewBtnType withToolBtn:(nonnull UIButton *)toolBtn
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
    [self.whiteBoardSDKManager didSDKSelectDrawType:drawType color:hexColor widthProgress:progress];
}


@end
