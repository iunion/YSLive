//
//  BMKeystoneCorrectionView.m
//  YSLive
//
//  Created by jiang deng on 2021/2/5.
//  Copyright © 2021 YS. All rights reserved.
//

#import "BMKeystoneCorrectionView.h"

@interface BMKeystoneCorrectionView ()
<
    BMCorrectionViewDelegate
>

@property (nonatomic, weak) YSLiveManager *liveManager;

/// 主视频容器
@property (nonatomic, strong) UIView *liveView;

/// 手势View
@property (nonatomic, strong) BMCorrectionView *touchView;

/// 顶部手势提示
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIImageView *topImageView;
@property (nonatomic, strong) UILabel *topLabel;

/// 工具容器
@property (nonatomic, strong) UIView *toolsView;
@property (nonatomic, strong) UIButton *cameraBtn;
@property (nonatomic, strong) UIButton *flipHBtn;
@property (nonatomic, strong) UIButton *flipVBtn;
@property (nonatomic, strong) UIButton *beautyBtn;

/// 底部容器
@property (nonatomic, strong) UIView *btnsView;
@property (nonatomic, strong) UIButton *finishBtn;
@property (nonatomic, strong) UIButton *resetBtn;

/// 美颜蒙层
@property (nonatomic, strong) UIControl *beautyMarskView;


@property (nonatomic, assign) BOOL isSwithCamera;
@property (nonatomic, assign) BOOL isFlipH;
@property (nonatomic, assign) BOOL isFlipV;

@end

// setupBottomToolBarView
// bottomToolBarClickAtIndex:
// hasVideoAdjustment
@implementation BMKeystoneCorrectionView

- (instancetype)initWithFrame:(CGRect)frame liveManager:(YSLiveManager *)liveManager
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.liveManager = liveManager;
        
        self.isSwithCamera = NO;
        self.isFlipH = NO;
        self.isFlipV = NO;

        [self setupUI];
    }
    
    return self;
}

- (UIButton *)creatBtnWithNormalImage:(UIImage *)normalImage action:(SEL)action
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(5.0f, 0, 30.0f, 30.0f)];
    [button setImage:normalImage forState:UIControlStateNormal];
    UIImage *selectedImage = [normalImage bm_imageWithTintColor:UIColor.blueColor];
    [button setImage:selectedImage forState:UIControlStateSelected];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (void)setupUI
{
    UIColor *backgroundColor = [[UIColor bm_colorWithHex:0x1C1D20] bm_changeAlpha:0.4f];
    
    UIView *liveView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:liveView];
    liveView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    liveView.backgroundColor = [UIColor bm_colorWithHex:0x40424A];
    self.liveView = liveView;
    
    BMCorrectionView *touchView = [[BMCorrectionView alloc] initWithFrame:self.bounds];
    [self addSubview:touchView];
    touchView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//#if DEBUG
//    touchView.backgroundColor = [UIColor.redColor bm_changeAlpha:0.1f];
//#else
    touchView.backgroundColor = UIColor.clearColor;
//#endif
    touchView.delegate = self;
    self.touchView = touchView;
    //[self freshTouchView];

    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120.0f, 30.0f)];
    [self addSubview:topView];
    self.topView = topView;
    UIImageView *topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30.0f, 30.0f)];
    [self.topView addSubview:topImageView];
    topImageView.image = [UIImage imageNamed:@"keystonecorrection_tip"];
    topImageView.contentMode = UIViewContentModeCenter;
    [topImageView bm_circleView];
    topImageView.backgroundColor = backgroundColor;
    self.topImageView = topImageView;

    UILabel *topLabel = [[UILabel alloc] init];
    [self.topView addSubview:topLabel];
    topLabel.text = YSLocalized(@"KeystoneCorrection.Tip");
    topLabel.textColor = UIColor.whiteColor;
    topLabel.textAlignment = NSTextAlignmentCenter;
    topLabel.font = [UIFont systemFontOfSize:12.0f];
    CGFloat width = [topLabel bm_labelSizeToFitHeight:16.0f].width;
    topLabel.frame = CGRectMake(36.0f, 7.0f, width+8.0f, 16.0f);
    topView.bm_width = topLabel.bm_right + 2.0f;
    topLabel.backgroundColor = backgroundColor;
    [topLabel bm_roundedRect:8.0f];
    
    [topView bm_centerHorizontallyInSuperViewWithTop:40.0f];
    
    CGFloat toolsViewHeight = 30.0f*4 + 10*2 + 15*3;
    UIView *toolsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40.0f, toolsViewHeight)];
    [self addSubview:toolsView];
    self.toolsView = toolsView;
    toolsView.backgroundColor = backgroundColor;
    toolsView.bm_centerY = self.bm_centerY;
    toolsView.bm_left = self.bm_width - 100.0f;
    [toolsView bm_roundedRect:6.0f];

    self.cameraBtn = [self creatBtnWithNormalImage:[UIImage imageNamed:@"keystonecorrection_camera"] action:@selector(camera:)];
    [self.toolsView addSubview:self.cameraBtn];
    self.cameraBtn.bm_top = 10.0f;
    
    self.flipHBtn = [self creatBtnWithNormalImage:[UIImage imageNamed:@"keystonecorrection_fliph"] action:@selector(fliph:)];
    [self.toolsView addSubview:self.flipHBtn];
    self.flipHBtn.bm_top = 55.0f;
    
    self.flipVBtn = [self creatBtnWithNormalImage:[UIImage imageNamed:@"keystonecorrection_flipv"] action:@selector(flipv:)];
    [self.toolsView addSubview:self.flipVBtn];
    self.flipVBtn.bm_top = 100.0f;
    
    self.beautyBtn = [self creatBtnWithNormalImage:[UIImage imageNamed:@"keystonecorrection_beauty"] action:@selector(showBeauty)];
    [self.toolsView addSubview:self.beautyBtn];
    self.beautyBtn.bm_top = 145.0f;

    UIView *btnsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 220.0f, 36.0f)];
    [self addSubview:btnsView];
    self.btnsView = btnsView;
    btnsView.backgroundColor = UIColor.clearColor;
    btnsView.bm_centerX = self.bm_centerX;
    btnsView.bm_top = self.bm_height - 80.0f;

    UIButton *resetBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 90.0f, 36.0f)];
    [self.btnsView addSubview:resetBtn];
    self.resetBtn = resetBtn;
    resetBtn.backgroundColor = backgroundColor;
    [resetBtn setTitle:YSLocalized(@"KeystoneCorrection.Reset") forState:UIControlStateNormal];
    [resetBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [resetBtn setTitleColor:UIColor.grayColor forState:UIControlStateDisabled];
    resetBtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [resetBtn addTarget:self action:@selector(resetAction:) forControlEvents:UIControlEventTouchUpInside];
    [resetBtn bm_roundedRect:18.0f];
    resetBtn.enabled = NO;

    UIButton *finishBtn = [[UIButton alloc] initWithFrame:CGRectMake(130.0f, 0, 90.0f, 36.0f)];
    [self.btnsView addSubview:finishBtn];
    self.finishBtn = finishBtn;
    finishBtn.backgroundColor = backgroundColor;
    [finishBtn setTitle:YSLocalized(@"KeystoneCorrection.Finish") forState:UIControlStateNormal];
    [finishBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    finishBtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [finishBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [finishBtn bm_roundedRect:18.0f];
    
    UIControl *beautyMarskView = [[UIControl alloc] initWithFrame:self.bounds];
    [self addSubview:beautyMarskView];
    beautyMarskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    beautyMarskView.backgroundColor = UIColor.clearColor;
    beautyMarskView.hidden = YES;
    [beautyMarskView addTarget:self action:@selector(hideBeauty) forControlEvents:UIControlEventTouchUpInside];
    self.beautyMarskView = beautyMarskView;
}

#if 0
- (void)freshTouchView
{
    CGFloat ratio = 1.0f;
    
    if (!CGSizeEqualToSize(self.liveManager.localVideoSize, CGSizeZero))
    {
        ratio = self.liveManager.localVideoSize.width /  self.liveManager.localVideoSize.height;
    }

    CGFloat width = self.bm_width;
    CGFloat height = self.bm_height;

    if (ratio >= self.bm_width / self.bm_height)
    {
        // 矮长型
        height = ceil(self.bm_width*(1.0f / ratio));
        if (height > self.bm_height)
        {
            height = self.bm_height;
        }
    }
    else
    {
        // 高瘦型
        width = ceil(self.bm_height*ratio);
        if (width > self.bm_width)
        {
            width = self.bm_width;
        }
    }
    
    self.touchView.frame = CGRectMake(0, 0, width, height);
    [self.touchView bm_centerInSuperView];
}
#endif

- (void)camera:(UIButton *)btn
{
    self.isSwithCamera = !self.isSwithCamera;
    //btn.selected = self.isSwithCamera;
    
    [self.liveManager useFrontCamera:!self.isSwithCamera];
}

- (void)fliph:(UIButton *)btn
{
    self.isFlipH = !self.isFlipH;
    //btn.selected = self.isFlipH;

    [self.liveManager.cloudHubRtcEngineKit setCameraFlipMode:self.isFlipH Vertivcal:self.isFlipV];
}

- (void)flipv:(UIButton *)btn
{
    self.isFlipV = !self.isFlipV;
    //btn.selected = self.isFlipV;

    [self.liveManager.cloudHubRtcEngineKit setCameraFlipMode:self.isFlipH Vertivcal:self.isFlipV];
}

- (void)showBeauty
{
    self.beautyMarskView.hidden = NO;
    
    self.topView.hidden = YES;
    self.toolsView.hidden = YES;
    self.btnsView.hidden = YES;
}

- (void)hideBeauty
{
    self.beautyMarskView.hidden = YES;
    
    self.topView.hidden = NO;
    self.toolsView.hidden = NO;
    self.btnsView.hidden = NO;
}

- (void)backAction:(UIButton *)btn
{
    if (self.delegate)
    {
        [self.delegate keystoneCorrectionViewClose];
    }
}

- (void)resetAction:(UIButton *)btn
{
    [self.liveManager.cloudHubRtcEngineKit resetCameraKeystoning];
    self.resetBtn.enabled = NO;
}


#pragma mark - BMCorrectionViewDelegate

- (void)correctionViewFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint
{
    NSLog(@"correctionViewFromPoint: %@ toPoint: %@", NSStringFromCGPoint(fromPoint), NSStringFromCGPoint(toPoint));
    
    [self.liveManager.cloudHubRtcEngineKit correctCameraKeystoning:fromPoint.x FromY:fromPoint.y ToX:toPoint.x ToY:toPoint.y];
    self.resetBtn.enabled = YES;
}

@end
