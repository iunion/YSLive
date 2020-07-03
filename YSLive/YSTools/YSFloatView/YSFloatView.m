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
    //缩放开始时的数据
    CGPoint scaleCenterPoint;
    CGFloat scaleWidth;
    CGFloat scaleHeight;
}

@property (nonatomic, strong) UIScrollView *backScrollView;

@property (nonatomic, strong) UIImageView *backImageView;

@property (nonatomic, weak) UIView *contentView;


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
        self.endScale = 2;
        // 设置默认偏移
        self.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        self.minSize = CGSizeZero;

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
    if (!CGSizeEqualToSize(self.minSize, CGSizeZero))
    {
        [UIView animateWithDuration:BMDEFAULT_DELAY_TIME animations:^{
            CGPoint center = self.center;
            self.bm_width = self.minSize.width;
            self.bm_height = self.minSize.height;
            self.center = center;
        }];
    }
    
    [self stayMove];
}

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
    
    if (!CGSizeEqualToSize(self.minSize, CGSizeZero))
    {
        self.bm_size = CGSizeMake(scaleWidth*pinch.scale, scaleHeight*pinch.scale);
        self.center = scaleCenterPoint;
    }
    
    if (pinch.state == UIGestureRecognizerStateEnded)
    {
        CGFloat percentLeft = 0.0;
        CGFloat percentTop = 0.0;
        
        BMWeakSelf
        // 尺寸小于默认恢复默认 只能放大
        if (self.bm_width <= self.minSize.width || self.bm_height <= self.minSize.height)
        {//小于默认最小时
            [UIView animateWithDuration:BMDEFAULT_DELAY_TIME animations:^{
                weakSelf.bm_width = weakSelf.minSize.width;
                weakSelf.bm_height = weakSelf.minSize.height;
                weakSelf.center = self->scaleCenterPoint;
            }];
            
            if (self.lastSize.width > self.minSize.width || self.lastSize.height > self.minSize.height)
            {
                if ((self.lastSize.width/self.minSize.width) < (self.lastSize.height/self.minSize.height))
                {
                    self.endScale *= self.lastSize.width/self.minSize.width;
                }else
                {
                    self.endScale *= self.lastSize.height/self.minSize.height;
                }
            }
            else
            {
                self.endScale = 1;
            }
            
            percentLeft = (self.center.x - self.minSize.width/2)/(self.maxSize.width - self.minSize.width - 2);
            percentTop = (self.center.y - self.minSize.height/2)/(self.maxSize.height - self.minSize.height - 2);
        }
        else if(self.bm_width >= self.maxSize.width || self.bm_height >= self.maxSize.height)
        {//大于最大时
            if ((self.minSize.width/self.minSize.height)>(self.maxSize.width/self.maxSize.height))
            {//宽先达到最大
                CGFloat defaultScale = self.minSize.height/self.minSize.width;
                
                [UIView animateWithDuration:BMDEFAULT_DELAY_TIME animations:^{
                    weakSelf.bm_width = weakSelf.maxSize.width;
                    weakSelf.bm_height = weakSelf.maxSize.width * defaultScale;
                    weakSelf.center = self->scaleCenterPoint;
                }];
                
                self.endScale *= self.maxSize.width/self.lastSize.width;
            }
            else
            {//高先达到最大
                
                CGFloat defaultScale = self.minSize.width/self.minSize.height;
                [UIView animateWithDuration:BMDEFAULT_DELAY_TIME animations:^{
                    weakSelf.bm_height = weakSelf.maxSize.height;
                    weakSelf.bm_width = weakSelf.maxSize.height * defaultScale;
                    weakSelf.center = self->scaleCenterPoint;
                }];
                self.endScale *= self.maxSize.height/self.lastSize.height;
            }
            percentLeft = 0.0;
            percentTop = 0.0;
        }
        else
        {
            self.endScale *= pinch.scale;
            
            percentLeft = (self.center.x - self.bm_width/2)/(self.maxSize.width - self.bm_width - 2);
            percentTop = (self.center.y - self.bm_height/2)/(self.maxSize.height - self.bm_height - 2);
            
        }
        [self stayMove];
        if (!self.isFullBackgrond)
        {
            
            NSDictionary * dict = @{
                @"userId":self.peerId,
                @"percentLeft":[NSString stringWithFormat:@"%f",percentLeft],
                @"percentTop":[NSString stringWithFormat:@"%f",percentTop],
                @"isDrag": @1, // 是否拖拽了
                @"scale":@(self.endScale)
            };
            [[YSLiveManager sharedInstance]sendSignalingTopinchVideoViewWithPeerId:self.peerId withData:dict];
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

@end
