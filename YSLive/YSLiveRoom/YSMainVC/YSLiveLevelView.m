//
//  YSLiveLevelView.m
//  YSLive
//
//  Created by fzxm on 2020/9/22.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSLiveLevelView.h"
#import "SCVideoView.h"

@interface YSLiveLevelView ()

/// 背景
@property (nonatomic, strong) UIView *bgView;
/// 视频容器
@property (nonatomic, strong) UIView *liveView;
/// 视频蒙版
@property (nonatomic, strong) UIView *maskView;
/// 弹幕容器
@property (nonatomic, strong) UIView *barrageView;
/// 工具容器
@property (nonatomic, strong) UIView *toolsAutoHideView;
/// 工具容器
@property (nonatomic, strong) UIView *toolsView;

@end

@implementation YSLiveLevelView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    /// 背景
    UIView *bgView = [[UIView alloc] init];
    self.bgView = bgView;
    [self addSubview:bgView];
    bgView.backgroundColor = [UIColor clearColor];
    bgView.frame = self.bounds;
    bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    /// 视频容器
    UIView *liveView = [[UIView alloc] init];
    self.liveView = liveView;
    [self addSubview:liveView];
    liveView.backgroundColor = [UIColor clearColor];
    liveView.frame = self.bounds;
    liveView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    /// 视频蒙版
    UIView *maskView = [[UIView alloc] init];
    self.maskView = maskView;
    [self addSubview:maskView];
    maskView.backgroundColor = [UIColor clearColor];
    maskView.frame = self.bounds;
    maskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    /// 弹幕容器
    UIView *barrageView = [[UIView alloc] init];
    self.barrageView = barrageView;
    [self addSubview:barrageView];
    barrageView.backgroundColor = [UIColor clearColor];
    barrageView.frame = self.bounds;
    barrageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    /// 工具容器
    UIView *toolsView = [[UIView alloc] init];
    self.toolsView = toolsView;
    [self addSubview:toolsView];
    toolsView.backgroundColor = [UIColor clearColor];
    toolsView.frame = self.bounds;
    toolsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    UIView *toolsAutoHideView = [[UIView alloc] init];
    self.toolsAutoHideView = toolsAutoHideView;
    [self addSubview:toolsAutoHideView];
    toolsAutoHideView.backgroundColor = [UIColor clearColor];
    toolsAutoHideView.frame = self.bounds;
    toolsAutoHideView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (NSArray *)getSubViewsWithView:(UIView *)view
{
    return [self getSubViewsWithView:view class:nil];
}

- (NSArray *)getSubViewsWithView:(UIView *)view class:(Class)class
{
    if (![view.subviews bm_isNotEmpty])
    {
        return nil;
    }
    
    NSMutableArray *subViewArray = [[NSMutableArray alloc] initWithArray:view.subviews];
    if (class)
    {
        NSMutableArray *newSubViewArray = [NSMutableArray array];
        for (UIView *subview in subViewArray)
        {
            if ([subview isKindOfClass:class])
            {
                [newSubViewArray addObject:subview];
            }
        }
        
        return newSubViewArray;
    }
    
    return subViewArray;
}

- (UIView *)getHitTest:(CGPoint)point inView:(UIView *)view class:(Class)class
{
    if (view.hidden)
    {
        return nil;
    }
    CGPoint newPoint = [view.superview convertPoint:point toView:view];
    UIView *findView = nil;
    NSArray *subViewArray = [self getSubViewsWithView:view class:class];
    for (UIView *subview in subViewArray)
    {
        if (!subview.hidden && CGRectContainsPoint(subview.frame, newPoint))
        {
            findView = subview;
            break;
        }
    }
    
    return findView;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    static BOOL firstClick = NO;
    if (event.type != UIEventTypeTouches)
    {
        return [super hitTest:point withEvent:event];
    }

    UIView *findView = [self getHitTest:point inView:self.toolsAutoHideView class:[UIButton class]];
    if (!findView)
    {
        findView = [self getHitTest:point inView:self.toolsAutoHideView class:[UIControl class]];
    }

    if (!findView)
    {
        findView = [self getHitTest:point inView:self.toolsView class:[UIButton class]];
    }
    if (!findView)
    {
        findView = [self getHitTest:point inView:self.toolsView class:[UIControl class]];
    }

    if (!findView)
    {
        findView = [self getHitTest:point inView:[self.liveView viewWithTag:111] class:[SCVideoView class]];
        if (findView)
        {
            if (firstClick)
            {
                SCVideoView *videoView = (SCVideoView *)findView;
                [videoView.delegate clickViewToControlWithVideoView:videoView];
            }
            firstClick = !firstClick;
            return findView;
        }
    }
    if (!findView)
    {
        findView = [self getHitTest:point inView:self.liveView class:[UIButton class]];
    }
    if (!findView)
    {
        findView = [self getHitTest:point inView:self.liveView class:[UIControl class]];
    }

    if (!findView)
    {
        findView = [self getHitTest:point inView:self.bgView class:[UIButton class]];
    }
    if (!findView)
    {
        findView = [self getHitTest:point inView:self.bgView class:[UIControl class]];
    }
    
    if (findView)
    {
        return findView;
    }

    return [super hitTest:point withEvent:event];
}

@end

