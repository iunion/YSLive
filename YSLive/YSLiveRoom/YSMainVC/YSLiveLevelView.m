//
//  YSLiveLevelView.m
//  YSLive
//
//  Created by fzxm on 2020/9/22.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSLiveLevelView.h"

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

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *findView = nil;
    for (UIView *view in self.toolsAutoHideView.subviews)
    {
        if (CGRectContainsPoint(view.frame, point))
        {
            findView = view;
            break;
        }
    }

    if (!findView)
    {
        for (UIView *view in self.toolsView.subviews)
        {
            if (CGRectContainsPoint(view.frame, point))
            {
                findView = view;
                break;
            }
        }
    }

    if (!findView)
    {
        for (UIView *view in self.liveView.subviews)
        {
            if (CGRectContainsPoint(view.frame, point))
            {
                findView = view;
                break;
            }
        }
    }

    if (!findView)
    {
        for (UIView *view in self.bgView.subviews)
        {
            if (CGRectContainsPoint(view.frame, point))
            {
                findView = view;
                break;
            }
        }
    }
    
    if (findView)
    {
        return findView;
    }
    else
    {
        return [super hitTest:point withEvent:event];
    }
}

@end

