//
//  YSFloatView.m
//  YSLive
//
//  Created by jiang deng on 2019/11/12.
//  Copyright © 2019 YS. All rights reserved.
//

#import "YSFloatView.h"
#import "PanGestureControl.h"

@interface YSFloatView ()
<
    UIScrollViewDelegate,
    UIGestureRecognizerDelegate
>
{
    CGPoint scaleCenterPoint;
    CGFloat scaleWidth;
    CGFloat scaleHeight;
}

@property (nonatomic, strong) UIScrollView *backScrollView;

@property (nonatomic, strong) UIImageView *backImageView;

@property (nonatomic, weak) UIView *contentView;

///默认刚拖出来的比例为1
@property (nonatomic , assign) CGFloat endScale;
///上次捏合后的尺寸
@property (nonatomic , assign) CGSize lastSize;

// 触摸起始点
@property (nonatomic , assign) CGPoint startPoint;
// 触摸结束点
@property (nonatomic , assign) CGPoint endPoint;

@end

@implementation YSFloatView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.canGestureRecognizer = NO;
        self.canZoom = NO;
        self.endScale = 1;
        // 设置默认偏移
        self.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        self.defaultSize = CGSizeZero;

        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        imageView.contentMode = UIViewContentModeCenter;
        [self addSubview:imageView];
        self.backImageView = imageView;
        
        NSMutableArray *imageArray = [[NSMutableArray alloc] init];
        for (NSUInteger i=1; i<=21; i++)
        {
            NSString *imageName = [NSString stringWithFormat:@"ysfloatview_loding%@", @(i)];
            [imageArray addObject:imageName];
        }
        [imageView bm_animationWithImageArray:imageArray duration:3 repeatCount:0];
        [imageView startAnimating];

        self.showWaiting = NO;

        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [self addSubview:scrollView];
        //scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        scrollView.delegate = self;
        scrollView.bounces = NO;
        scrollView.backgroundColor = [UIColor clearColor];
        
        scrollView.minimumZoomScale = 1.0;
        scrollView.maximumZoomScale = 3.0;
        scrollView.zoomScale = 1.0;
        self.backScrollView = scrollView;

        // 移动手势
//        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragView:)];
//        [self addGestureRecognizer:panGestureRecognizer];
        
        // 双击手势
        UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        [doubleTapGestureRecognizer setNumberOfTapsRequired:2];
        [self addGestureRecognizer:doubleTapGestureRecognizer];
        
        // 捏合手势
        UIPinchGestureRecognizer *pinchRcognize =[[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchView:)];
        pinchRcognize.delegate = self;
        [self addGestureRecognizer:pinchRcognize];
        [pinchRcognize delaysTouchesEnded];
        [pinchRcognize cancelsTouchesInView];
        
        self.exclusiveTouch = YES;
    }
    return self;
}


- (void)setContentView:(UIView *)contentView
{
    _contentView = contentView;
    contentView.frame = self.bounds;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.backScrollView.frame = self.bounds;
    self.backImageView.frame = self.bounds;
    self.contentView.frame = self.bounds;
}

- (void)setShowWaiting:(BOOL)showWaiting
{
    _showWaiting = showWaiting;
    
    self.backImageView.hidden = !showWaiting;
}

- (void)doubleTap:(UITapGestureRecognizer *)doubleTap
{
    if (!self.canGestureRecognizer)
    {
        return;
    }
    
    // 双击恢复默认尺寸
    if (!CGSizeEqualToSize(self.defaultSize, CGSizeZero))
    {
        [UIView animateWithDuration:BMDEFAULT_DELAY_TIME animations:^{
            CGPoint center = self.center;
            self.bm_width = self.defaultSize.width;
            self.bm_height = self.defaultSize.height;
            self.center = center;
        }];
    }
    
    [self stayMove];
}

//- (void)dragView:(UIPanGestureRecognizer *)recognizer
//{
//    if (!self.canGestureRecognizer)
//    {
//        return;
//    }
//
//    UIView *dragView = recognizer.view;
//    if (recognizer.state == UIGestureRecognizerStateBegan)
//    {
//
//    }
//    else if (recognizer.state == UIGestureRecognizerStateChanged)
//    {
//        CGPoint location = [recognizer locationInView:self.superview];
//
//        if (location.y < 0 || location.y > UI_SCREEN_HEIGHT)
//        {
//            return;
//        }
//        CGPoint translation = [recognizer translationInView:self.superview];
//
//        dragView.center = CGPointMake(dragView.center.x + translation.x, dragView.center.y + translation.y);
//        [recognizer setTranslation:CGPointZero inView:self.superview];
//    }
//    else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled)
//    {
//        [self stayMove];
//    }
//}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([[PanGestureControl shareInfo] isExistPanGestureAction:LONG_PRESS_VIEW_DEMO])
    {
        return NO;
    }

    return YES;
}

- (void)pinchView:(UIPinchGestureRecognizer *)pinch
{
    if (!self.canGestureRecognizer)
    {
        return;
    }
    
    UIView *view = pinch.view;
    
    if (!view)
    {
        return;
    }
    
    // 通过 transform(改变) 进行视图的视图的捏合
//    view.transform = CGAffineTransformScale(view.transform, pinch.scale, pinch.scale);
    if (pinch.state == UIGestureRecognizerStateBegan)
    {
        scaleCenterPoint = self.center;
        scaleWidth = self.bm_width;
        scaleHeight = self.bm_height;
        self.lastSize = self.bm_size;
    }
    
    if (!CGSizeEqualToSize(self.defaultSize, CGSizeZero))
    {
        self.bm_size = CGSizeMake(scaleWidth*pinch.scale, scaleHeight*pinch.scale);
        self.center = scaleCenterPoint;
    }
    
    if (pinch.state == UIGestureRecognizerStateEnded)
    {
        BMWeakSelf
        // 尺寸小于默认恢复默认 只能放大
        if (self.bm_width <= self.defaultSize.width || self.bm_height <= self.defaultSize.height)
        {//小于默认最小时
            [UIView animateWithDuration:BMDEFAULT_DELAY_TIME animations:^{
                weakSelf.bm_width = weakSelf.defaultSize.width;
                weakSelf.bm_height = weakSelf.defaultSize.height;
                weakSelf.center = self->scaleCenterPoint;
            }];
            
            if (self.lastSize.width>self.defaultSize.width || self.lastSize.height>self.defaultSize.height)
            {
                if ((self.lastSize.width/self.defaultSize.width) < (self.lastSize.height/self.defaultSize.height))
                {
                    self.endScale *= self.lastSize.width/self.defaultSize.width;
                }else
                {
                    self.endScale *= self.lastSize.height/self.defaultSize.height;
                }
            }
            else
            {
                self.endScale = 1;
            }
        }
        else if(self.bm_width >= self.maxSize.width || self.bm_height >= self.maxSize.height)
        {//大于最大时
            if ((self.defaultSize.width/self.defaultSize.height)>(self.maxSize.width/self.maxSize.height))
            {//宽先达到最大
                CGFloat defaultScale = self.defaultSize.height/self.defaultSize.width;
                
                [UIView animateWithDuration:BMDEFAULT_DELAY_TIME animations:^{
                    weakSelf.bm_width = weakSelf.maxSize.width;
                    weakSelf.bm_height = weakSelf.maxSize.width * defaultScale;
                    weakSelf.center = self->scaleCenterPoint;
                }];
                
                self.endScale *= self.maxSize.width/self.lastSize.width;
            }
            else
            {//高先达到最大
                
                CGFloat defaultScale = self.defaultSize.width/self.defaultSize.height;
                [UIView animateWithDuration:BMDEFAULT_DELAY_TIME animations:^{
                    weakSelf.bm_height = weakSelf.maxSize.height;
                    weakSelf.bm_width = weakSelf.maxSize.height * defaultScale;
                    weakSelf.center = self->scaleCenterPoint;
                }];
                self.endScale *= self.maxSize.height/self.lastSize.height;
            }
        }
        else
        {
            self.endScale *= pinch.scale;
        }
        [self stayMove];
        if (!self.isFullBackgrond)
        {
             [[YSLiveManager shareInstance] sendSignalingTopinchVideoViewWithPeerId:self.peerId scale:self.endScale];
        }
    }
}

- (void)stayMove
{
    // 计算距离最近的边缘 吸附到边缘停靠
    CGRect currentFrame = self.frame;

    CGFloat superwidth = self.superview.bounds.size.width;
    CGFloat superheight = self.superview.bounds.size.height;
    // 上距离
    CGFloat topRange = currentFrame.origin.y - self.edgeInsets.top;
    // 下距离
    CGFloat bottomRange = (superheight - self.edgeInsets.bottom) - (currentFrame.origin.y+currentFrame.size.height);
    // 左距离
    CGFloat leftRange = currentFrame.origin.x - self.edgeInsets.left;
    // 右距离
    CGFloat rightRange = (superwidth - self.edgeInsets.right) - (currentFrame.origin.x+currentFrame.size.width);

    if (leftRange < 0)
    {
        currentFrame.origin.x = self.edgeInsets.left;
        if (topRange < 0)
        {
            currentFrame.origin.y = self.edgeInsets.top;
        }
        else if (bottomRange < 0)
        {
            currentFrame.origin.y = self.superview.bounds.size.height - currentFrame.size.height - self.edgeInsets.bottom;
        }
        [UIView animateWithDuration:0.5 animations:^{
            self.frame = currentFrame;
        }];
    }
    else if (rightRange < 0)
    {
        currentFrame.origin.x = self.superview.bounds.size.width - currentFrame.size.width - self.edgeInsets.right;
        if (topRange < 0)
        {
            currentFrame.origin.y = self.edgeInsets.top;
        }
        else if (bottomRange < 0)
        {
            currentFrame.origin.y = self.superview.bounds.size.height - currentFrame.size.height - self.edgeInsets.bottom;
        }
        [UIView animateWithDuration:BMDEFAULT_DELAY_TIME animations:^{
            self.frame = currentFrame;
        }];
    }
    else if (topRange < 0)
    {
        currentFrame.origin.y = self.edgeInsets.top;
        [UIView animateWithDuration:BMDEFAULT_DELAY_TIME animations:^{
            self.frame = currentFrame;
        }];
    }
    else if (bottomRange < 0)
    {
        currentFrame.origin.y = self.superview.bounds.size.height - currentFrame.size.height - self.edgeInsets.bottom;
        [UIView animateWithDuration:BMDEFAULT_DELAY_TIME animations:^{
            self.frame = currentFrame;
        }];
    }
}

- (void)showWithContentView:(UIView *)contentView
{
    [self.backScrollView addSubview:contentView];
    [self setContentView:contentView];
}

- (void)cleanContent
{
    if (self.contentView.superview)
    {
        [self.contentView removeFromSuperview];
    }
    
    self.contentView = nil;
}


#pragma mark -
#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if (self.canZoom && self.contentView.superview)
    {
        return self.contentView;
    }

    return nil;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
//    self.bm_width = self.bm_width*scale;
//    self.bm_height = self.bm_height*scale;
}


@end
