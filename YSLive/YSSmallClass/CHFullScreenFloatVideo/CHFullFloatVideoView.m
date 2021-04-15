//
//  CHFullFloatVideoView.m
//  YSAll
//
//  Created by 马迪 on 2021/4/7.
//  Copyright © 2021 CH. All rights reserved.
//

#import "CHFullFloatVideoView.h"

#define  Margin 3
#define  VideoTop 10.0f

@interface CHFullFloatVideoView ()

/// 视频ratio 16:9
@property (nonatomic, assign) BOOL isWideScreen;

/// 对rightVideoBgView的控制按钮所在View
@property (nonatomic, weak) CHFullFloatControlView *controlView;
@property (nonatomic, assign) CHFullFloatState fullFloatState;

@property (nonatomic, weak) UIView *rightVideoBgView;

/// 焦点视图右侧的宽高
@property (nonatomic, assign) CGFloat rightBgWidth;
@property (nonatomic, assign) CGFloat rightBgHeight;

/// 每个小视频的宽高
@property (nonatomic, assign) CGFloat videoWidth;
@property (nonatomic, assign) CGFloat videoHeight;

/// 窗口数据
@property (nonatomic, weak) NSArray <CHVideoView *> *myVideoSequenceArray;
@property (nonatomic, weak) NSArray <CHVideoView *> *allVideoSequenceArray;

/// 拖动rightView时的模拟移动图
@property (nonatomic, strong) UIImageView *dragImageView;
/// 刚开始拖动时，rightView的初始坐标（x,y）
@property (nonatomic, assign) CGPoint videoOriginInSuperview;

@end

@implementation CHFullFloatVideoView

- (instancetype)initWithFrame:(CGRect)frame wideScreen:(BOOL)isWideScreen
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = UIColor.clearColor;
        
        self.isWideScreen = isWideScreen;
        self.videoOriginInSuperview = CGPointZero;

        [self setupUIView];
    }
    return self;
}

- (void)setupUIView
{
    CGFloat controlViewW = 30.0f;
    
    CHFullFloatControlView *controlView = [[CHFullFloatControlView alloc] initWithFrame:CGRectMake(self.bm_width - controlViewW, 45.0f, controlViewW, self.bm_height*0.5)];
    [self addSubview:controlView];
    self.controlView = controlView;
    [controlView bm_connerWithRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:CGSizeMake(6.0f, 6.0f)];
    
    
    BMWeakSelf
    controlView.fullFloatControlButtonClick = ^(CHFullFloatControlView * _Nonnull fullFloatControlView) {
        [weakSelf fullFloatControlButtonClick];
    };
    
    UIView *rightVideoBgView = [[UIView alloc] initWithFrame:CGRectMake(0, VideoTop, 100.0f, 100.0f)];
    rightVideoBgView.backgroundColor = UIColor.clearColor;
    [self addSubview:rightVideoBgView];
    self.rightVideoBgView = rightVideoBgView;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragTheRightVideoBgView:)];
    [rightVideoBgView addGestureRecognizer:pan];
}

- (CHFullFloatState)fullFloatState
{
    return self.controlView.fullFloatState;
}

- (void)fullFloatControlButtonClick
{
    if (self.fullFloatState == CHFullFloatState_None)
    {
        self.rightVideoBgView.hidden = YES;
    }
    else
    {
        self.rightVideoBgView.hidden = NO;
    }
    
    [self bm_bringToFront];
    
    [self freshFullFloatViewWithMyVideoArray:self.myVideoSequenceArray allVideoSequenceArray:self.allVideoSequenceArray];
}

- (void)showFullFloatViewWithMyVideoArray:(NSArray <CHVideoView *> *)myVideoSequenceArray allVideoSequenceArray:(NSArray <CHVideoView *> *)allVideoSequenceArray
{
    self.controlView.fullFloatState = CHFullFloatState_All;
    
    [self fullFloatControlButtonClick];
}

/// 刷新rightVideoBgView内部view
- (void)freshFullFloatViewWithMyVideoArray:(NSArray<CHVideoView *> *)myVideoSequenceArray allVideoSequenceArray:(NSArray<CHVideoView *> *)allVideoSequenceArray
{
    self.myVideoSequenceArray = myVideoSequenceArray;
    self.allVideoSequenceArray = allVideoSequenceArray;

    [self.rightVideoBgView bm_removeAllSubviews];
    
    NSArray <CHVideoView *> *videoArry = myVideoSequenceArray;
    if (self.fullFloatState == CHFullFloatState_All)
    {
        videoArry = allVideoSequenceArray;
    }
    
    [self changeFrameFocusWithVideoCount:videoArry.count];
    
    for (CHVideoView *videoView in videoArry)
    {
        [self.rightVideoBgView addSubview:videoView];
        videoView.frame = CGRectMake(0, 0, self.videoWidth, self.videoHeight);
    }
    
    [self freshVideoViewWithVideoArray:videoArry];
}

/// 计算各控件的尺寸
- (void)changeFrameFocusWithVideoCount:(NSUInteger)videoNum
{
    self.videoHeight = (self.bm_height - 2*VideoTop - 7*Margin) / 6;
    
    if (self.isWideScreen)
    {
        self.videoWidth = ceil(self.videoHeight * 16.0f / 9.0f);
    }
    else
    {
        self.videoWidth = ceil(self.videoHeight * 4.0f / 3.0f);
    }
        
    if (videoNum < 1)
    {
        self.rightBgWidth = 0.0f;
        self.rightBgHeight = 0.0f;
    }
    else if (videoNum < 7)
    {
        self.rightBgWidth = self.videoWidth + 2 * Margin;
        self.rightBgHeight = videoNum * (self.videoHeight + Margin) + Margin;
    }
    else if (videoNum < 13)
    {
        self.rightBgWidth = 2 * self.videoWidth + 3 * Margin;
        self.rightBgHeight = self.bm_height - 2 * VideoTop;
    }
}

/// 对videoView布局
- (void)freshVideoViewWithVideoArray:(NSArray <CHVideoView *> *)videoArray
{
    if (!self.rightViewMaxRight)
    {
        self.rightViewMaxRight = self.controlView.bm_left - VideoTop;
    }

    self.rightVideoBgView.frame = CGRectMake(self.rightViewMaxRight - self.rightBgWidth, VideoTop, self.rightBgWidth, self.rightBgHeight);
    
    CGFloat widthM = self.videoWidth + Margin;
    CGFloat heightM = self.videoHeight + Margin;
    
    CGFloat rightBgViewW = self.rightVideoBgView.bm_width;
    
    NSUInteger itemCount = 6;
    for (NSUInteger i = 0; i < videoArray.count; i++)
    {
        CHVideoView *videoView = videoArray[i];
        if (i < itemCount)
        {
            videoView.bm_top = i * heightM + Margin;
            videoView.bm_right = rightBgViewW - Margin;
        }
        else if (i < itemCount*2)
        {
            videoView.bm_top = (i - itemCount) * heightM + Margin;
            videoView.bm_right = rightBgViewW - Margin - widthM;
        }
        else if (i < itemCount*3)
        {
            videoView.bm_top = (i - itemCount*2) * heightM + Margin;
            videoView.bm_left = rightBgViewW - Margin - 2 * widthM;
        }
    }
}

/// 拖拽事件
- (void)dragTheRightVideoBgView:(UIPanGestureRecognizer *)pan
{
    CGPoint endPoint = [pan translationInView:self.rightVideoBgView];
    
    if (!self.dragImageView)
    {
        UIImage *img = [self.rightVideoBgView bm_screenshot];
        self.dragImageView = [[UIImageView alloc] initWithImage:img];
        [self addSubview:self.dragImageView];
    }
    
    if (self.videoOriginInSuperview.x == 0 && self.videoOriginInSuperview.y == 0)
    {
        self.videoOriginInSuperview = [self convertPoint:CGPointMake(0, 0) fromView:self.rightVideoBgView];
        [self bringSubviewToFront:self.dragImageView];
    }
    self.dragImageView.frame = CGRectMake(self.videoOriginInSuperview.x + endPoint.x, self.videoOriginInSuperview.y + endPoint.y, self.rightVideoBgView.bm_width, self.rightVideoBgView.bm_height);
    
    if (pan.state == UIGestureRecognizerStateEnded)
    {
        CGFloat left = 2.0f;
        CGFloat top = 2.0f;
        CGFloat gap = 2.0f;

        if (self.videoOriginInSuperview.x+endPoint.x > self.rightViewMaxRight - self.rightBgWidth)
        {
            left = self.rightViewMaxRight - self.rightBgWidth;
        }
        else if (self.videoOriginInSuperview.x+endPoint.x > gap)
        {
            left = self.videoOriginInSuperview.x + endPoint.x;
        }
        
        if (self.videoOriginInSuperview.y + endPoint.y > self.bm_height - self.rightBgHeight - gap)
        {
            top = self.bm_height - self.rightBgHeight - gap;
        }
        else if (self.videoOriginInSuperview.y + endPoint.y > gap)
        {
            top = self.videoOriginInSuperview.y + endPoint.y;
        }
                
        self.rightVideoBgView.frame = CGRectMake(left, top, self.rightBgWidth, self.rightBgHeight);
        [self.dragImageView removeFromSuperview];
        self.dragImageView = nil;
        self.videoOriginInSuperview = CGPointZero;
    }
}

/// 穿透
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if (CGRectContainsPoint(self.controlView.frame, point) || CGRectContainsPoint(self.rightVideoBgView.frame, point))
    {
        return YES;
    }
    
    return NO;
}

@end
