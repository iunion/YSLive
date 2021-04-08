//
//  CHFullFloatVideoView.m
//  YSAll
//
//  Created by 马迪 on 2021/4/7.
//  Copyright © 2021 CH. All rights reserved.
//

#import "CHFullFloatVideoView.h"
#import "CHFullFloatControlView.h"


#define  Margin 3
#define  VideoTop 10

@interface CHFullFloatVideoView ()

/// 视频ratio 16:9
@property (nonatomic, assign) BOOL isWideScreen;

/// 对rightVideoBgView的控制按钮所在View
@property (nonatomic, weak) CHFullFloatControlView *controlView;

@property (nonatomic, weak) UIView *rightVideoBgView;

//焦点视图右侧的宽高
@property (nonatomic, assign) CGFloat rightBgWidth;
@property (nonatomic, assign) CGFloat rightBgHeight;

//每个小视频的宽高
@property (nonatomic, assign) CGFloat videoWidth;
@property (nonatomic, assign) CGFloat videoHeight;

//@property (nonatomic, strong) NSArray <SCVideoView *> *videoSequenceArr;
@property (nonatomic, strong) NSArray *videoSequenceArr;

///拖动rightView时的模拟移动图
@property (nonatomic, strong) UIImageView *dragImageView;
///刚开始拖动时，rightView的初始坐标（x,y）
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
                
        [self setupUIView];
    }
    return self;
}

#pragma mark -
- (void)setupUIView
{
    CGFloat controlViewW = 30;
    
    CHFullFloatControlView *controlView = [[CHFullFloatControlView alloc]initWithFrame:CGRectMake(self.bm_width - controlViewW, 45, controlViewW, self.bm_height/2)];
    [self addSubview:controlView];
    self.controlView = controlView;
    BMWeakSelf
    controlView.fullFloatControlButtonClick = ^(UIButton * _Nonnull sender) {
        [weakSelf fullFloatControlButtonClick:sender];
    };
    
    UIView *rightVideoBgView = [[UIView alloc] initWithFrame:CGRectMake(0, VideoTop, 100, 100)];
    rightVideoBgView.backgroundColor = UIColor.redColor;
    [self addSubview:rightVideoBgView];
    self.rightVideoBgView = rightVideoBgView;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(dragTheRightVideoBgView:)];
    [rightVideoBgView addGestureRecognizer:pan];
    
}

- (void)fullFloatControlButtonClick:(UIButton *)button
{
    if (button.tag == 1) {
        self.rightVideoBgView.hidden = YES;
    }
    else
    {
        self.rightVideoBgView.hidden = NO;
        if ([self.fullFloatVideoViewDelegate respondsToSelector:@selector(fullFloatControlViewEvent:)])
        {
            [self.fullFloatVideoViewDelegate fullFloatControlViewEvent:button];
        }
    }
}

/// 刷新rightVideoBgView内部view
//- (void)freshViewWithVideoViewArray:(NSMutableArray<SCVideoView *> *)videoSequenceArr
- (void)freshViewWithVideoViewArray:(NSArray *)videoSequenceArr
{
    self.videoSequenceArr = videoSequenceArr;
    
    [self.rightVideoBgView bm_removeAllSubviews];
    
    //   self.videosBgView.backgroundColor = YSSkinDefineColor(@"Color2");
    
    [self changeFrameFocus];
    
    for (SCVideoView *videoView in videoSequenceArr)
    {
        [self.rightVideoBgView addSubview:videoView];
        videoView.frame = CGRectMake(0, 0, self.videoWidth, self.videoHeight);
    }
    
    [self freshVideoView];
}

/// 计算各控件的尺寸
- (void)changeFrameFocus
{
    self.videoHeight = (self.bm_height - 2*VideoTop - 7*Margin)/6;
    
    if (self.isWideScreen)
    {
        self.videoWidth = ceil(self.videoHeight * 16 / 9);
    }
    else
    {
        self.videoWidth = ceil(self.videoHeight * 4 / 3);
    }
        
    NSInteger videoNum = self.videoSequenceArr.count;
    
    if (videoNum < 1)
    {
        self.rightBgWidth = 0.0;
        self.rightBgHeight = 0.0;
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
- (void)freshVideoView
{
    if (!self.rightViewMaxRight)
    {
        self.rightViewMaxRight = self.controlView.bm_left - VideoTop;
    }

    self.rightVideoBgView.frame = CGRectMake(self.rightViewMaxRight - self.rightBgWidth, VideoTop+100, self.rightBgWidth, self.rightBgHeight);
    
    CGFloat widthM = self.videoWidth + Margin;
    CGFloat heightM = self.videoHeight + Margin;
    
    CGFloat rightBgViewW = self.rightVideoBgView.bm_width;
    
    
    for (int i = 0; i < self.videoSequenceArr.count; i++)
    {
        SCVideoView *videoView = self.videoSequenceArr[i];
        if (i < 6)
        {
            videoView.bm_top = i * heightM + Margin;
            videoView.bm_right = rightBgViewW - Margin;
        }
        else if (i < 12)
        {
            videoView.bm_top = (i - 6) * heightM + Margin;
            videoView.bm_right = rightBgViewW - Margin - widthM;
        }
        else if (i < 18)
        {
            videoView.bm_top = (i - 12) * heightM + Margin;
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
        UIImage * img = [self.rightVideoBgView bm_screenshot];
        self.dragImageView = [[UIImageView alloc]initWithImage:img];
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
        CGFloat left = 2;
        CGFloat top = 2;

        if (self.videoOriginInSuperview.x+endPoint.x > self.rightViewMaxRight - self.rightBgWidth)
        {
            left = self.rightViewMaxRight - self.rightBgWidth;
        }
        else if (self.videoOriginInSuperview.x+endPoint.x > 2)
        {
            left = self.videoOriginInSuperview.x + endPoint.x;
        }
        
        if (self.videoOriginInSuperview.y + endPoint.y > self.bm_height - self.rightBgHeight - 2)
        {
            top = self.bm_height - self.rightBgHeight - 2;
        }
        else if (self.videoOriginInSuperview.y + endPoint.y > 2)
        {
            top = self.videoOriginInSuperview.y + endPoint.y;
        }
                
        self.rightVideoBgView.frame = CGRectMake(left, top, self.rightBgWidth, self.rightBgHeight);
        [self.dragImageView removeFromSuperview];
        self.dragImageView = nil;
        self.videoOriginInSuperview = CGPointZero;
    }
}

//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
//{
//    
//}

@end
