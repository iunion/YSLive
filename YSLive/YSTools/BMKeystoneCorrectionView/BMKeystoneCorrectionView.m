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

@property (nonatomic, strong) UIButton *returnBtn;

@end

// setupBottomToolBarView
// bottomToolBarClickAtIndex:
@implementation BMKeystoneCorrectionView

- (instancetype)initWithFrame:(CGRect)frame liveManager:(YSLiveManager *)liveManager
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.liveManager = liveManager;
        
        [self setupUI];
    }
    
    return self;
}

- (UIButton *)creatBtnWithNormalImage:(UIImage *)normalImage action:(SEL)action
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(5.0f, 0, 30.0f, 30.0f)];
    [button setImage:normalImage forState:(UIControlStateNormal)];
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
#if DEBUG
    touchView.backgroundColor = [UIColor.redColor bm_changeAlpha:0.1f];
#else
    touchView.backgroundColor = UIColor.clearColor;
#endif
    touchView.delegate = self;
    self.touchView = touchView;
    [self freshTouchView];

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
    
    UIView *toolsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40.0f, 120.0f)];
    [self addSubview:toolsView];
    self.toolsView = toolsView;
    toolsView.backgroundColor = backgroundColor;
    toolsView.bm_centerY = self.bm_centerY;
    toolsView.bm_left = self.bm_width - 60.0f;
    [toolsView bm_roundedRect:6.0f];

    self.cameraBtn = [self creatBtnWithNormalImage:[UIImage imageNamed:@"keystonecorrection_camera"] action:@selector(camera:)];
    [self.toolsView addSubview:self.cameraBtn];
    self.cameraBtn.bm_top = 5.0f;
    
    self.flipHBtn = [self creatBtnWithNormalImage:[UIImage imageNamed:@"keystonecorrection_fliph"] action:@selector(fliph:)];
    [self.toolsView addSubview:self.flipHBtn];
    self.flipHBtn.bm_top = 45.0f;
    
    self.flipVBtn = [self creatBtnWithNormalImage:[UIImage imageNamed:@"keystonecorrection_flipv"] action:@selector(flipv:)];
    [self.toolsView addSubview:self.flipVBtn];
    self.flipVBtn.bm_top = 85.0f;

    UIButton *returnBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80.0f, 30.0f)];
    [self addSubview:returnBtn];
    self.returnBtn = returnBtn;
    returnBtn.backgroundColor = backgroundColor;
    [returnBtn setTitle:YSLocalized(@"KeystoneCorrection.Return") forState:UIControlStateNormal];
    [returnBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    returnBtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [returnBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    returnBtn.bm_centerX = self.bm_centerX;
    returnBtn.bm_top = self.bm_height - 80.0f;
    [returnBtn bm_roundedRect:15.0f];
}

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

- (void)camera:(UIButton *)btn
{
    
}

- (void)fliph:(UIButton *)btn
{
    
}

- (void)flipv:(UIButton *)btn
{
    
}

- (void)backAction:(UIButton *)btn
{
    if (self.delegate)
    {
        [self.delegate keystoneCorrectionViewClose];
    }
}


#pragma mark - BMCorrectionViewDelegate

- (void)correctionViewFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint
{
    NSLog(@"correctionViewFromPoint: %@ toPoint: %@", NSStringFromCGPoint(fromPoint), NSStringFromCGPoint(toPoint));
    
}

@end
