//
//  YSEyeCareManager.m
//  YSAll
//
//  Created by jiang deng on 2019/12/25.
//  Copyright © 2019 YS. All rights reserved.
//

#import "YSEyeCareManager.h"
#import "YSBasicAnimation.h"
#import "YSSkinCoverWindow.h"
#import "YSEyeCareMaskView.h"

#define kAnimationDuration 0.25

static NSString *const kEyeCareRemindKey = @"ysEyeCareRemindKey";

static NSString *const kEyeCareModeStatusKey = @"ysEyeCareModeStatusKey";
static NSString *const kEyeCareModeRemindTimeKey = @"ysEyeCareModeRemindTimeKey";
static NSInteger const kYSSkinCoverWindowLevel = 2099;

@interface YSEyeCareManager ()

@property (nonatomic, strong) YSSkinCoverWindow *skinCoverWindow;
/// 原keywindow
@property(nonatomic, weak) UIWindow *previousKeyWindow;

/// maskView
@property (nonatomic, strong) YSEyeCareMaskView *eyeMaskView;

@end

@implementation YSEyeCareManager

+ (instancetype)shareInstance
{
    static YSEyeCareManager *_sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[YSEyeCareManager alloc] init];
    });
    
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
//        // 给window赋值上初始的frame，在ios9之前如果不赋值系统默认认为是CGRectZero
//        YSSkinCoverWindow *skinCoverWindow = [[YSSkinCoverWindow alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT)];
//        skinCoverWindow.windowLevel = kYSSkinCoverWindowLevel;
//        skinCoverWindow.userInteractionEnabled = NO;
//        // 添加到 UIScreen
//        //[skinCoverWindow makeKeyWindow];
//
//        self.skinCoverWindow = skinCoverWindow;
        
        YSEyeCareMaskView *eyeCareMaskView = [[YSEyeCareMaskView alloc] init];
        self.eyeMaskView = eyeCareMaskView;
    }
    return self;
}

- (void)changeSkinCoverColor:(UIColor *)color;
{
    [self.skinCoverWindow changeSkinCoverColor:color];
}

- (void)changeMaskColor:(UIColor *)color
{
    self.eyeMaskView.backgroundColor = color;
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    keyWindow.maskView = nil;
    keyWindow.maskView = self.eyeMaskView;
}

- (BOOL)getEyeCareNeverRemind
{
    BOOL remind = [[NSUserDefaults standardUserDefaults] boolForKey:kEyeCareRemindKey];
    
    return remind;
}

- (void)setEyeCareNeverRemind:(BOOL)neverRemind
{
    [[NSUserDefaults standardUserDefaults] setBool:neverRemind forKey:kEyeCareRemindKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)getEyeCareModeStatus
{
    BOOL eyeCareModeStatus = [[NSUserDefaults standardUserDefaults] boolForKey:kEyeCareModeStatusKey];
    
    return eyeCareModeStatus;
}

- (NSUInteger)getEyeCareModeRemindTime
{
    NSUInteger remindTime = [[NSUserDefaults standardUserDefaults] integerForKey:kEyeCareModeRemindTimeKey];
    if (remindTime == 0)
    {
        remindTime = 30;
    }
    
    return remindTime;
}

- (void)setEyeCareModeRemindTime:(NSUInteger)remindTime
{
    [[NSUserDefaults standardUserDefaults] setInteger:remindTime forKey:kEyeCareModeRemindTimeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)startRemindtime
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(remind) object:nil];
    NSUInteger remindTime = [self getEyeCareModeRemindTime];
#if USE_TEST_HELP
    [self performSelector:@selector(remind) withObject:nil afterDelay:remindTime*1.0f];
#else
    [self performSelector:@selector(remind) withObject:nil afterDelay:remindTime*60.0f];
#endif
}

- (void)stopRemindtime
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(remind) object:nil];
}

- (void)remind
{
    if (self.showRemindBlock)
    {
        self.showRemindBlock();
    }
    NSUInteger remindTime = [self getEyeCareModeRemindTime];
#if USE_TEST_HELP
    [self performSelector:@selector(remind) withObject:nil afterDelay:remindTime*1.0f];
#else
    [self performSelector:@selector(remind) withObject:nil afterDelay:remindTime*60.0f];
#endif
}

- (void)makeSkinCoverWindow
{
    YSSkinCoverWindow *skinCoverWindow = [[YSSkinCoverWindow alloc] initWithFrame:CGRectMake(0, 0, BMUI_SCREEN_WIDTH, BMUI_SCREEN_HEIGHT)];
    skinCoverWindow.windowLevel = kYSSkinCoverWindowLevel;
    skinCoverWindow.userInteractionEnabled = NO;
    
    [skinCoverWindow freshWindowWithShowStatusBar:YES isRientationPortrait:YES];

    self.skinCoverWindow = skinCoverWindow;
}

- (void)freshWindowWithShowStatusBar:(BOOL)showStatusBar isRientationPortrait:(BOOL)isRientationPortrait
{
    if (self.skinCoverWindow && !self.skinCoverWindow.hidden)
    {
        [self.previousKeyWindow makeKeyWindow];
        self.skinCoverWindow = nil;
        
        [self makeSkinCoverWindow];

        [self.skinCoverWindow freshWindowWithShowStatusBar:showStatusBar isRientationPortrait:isRientationPortrait];
        [self.skinCoverWindow makeKeyWindow];
        self.skinCoverWindow.hidden = NO;
        
        BMWeakSelf
        // 出现动画
        YSBasicAnimation *opacityAnimation = [YSBasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.fromValue = @(0.5);
        opacityAnimation.toValue = @(1);
        opacityAnimation.duration = kAnimationDuration;
        opacityAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        opacityAnimation.fillMode = kCAFillModeForwards;
        opacityAnimation.removedOnCompletion = YES;

        opacityAnimation.animationDidStopBlock = ^(CAAnimation * _Nonnull anim, BOOL flag) {
            // 把key还给之前的window
            [weakSelf.previousKeyWindow makeKeyWindow];
        };

        [self.skinCoverWindow.layer addAnimation:opacityAnimation forKey:@"showAnimation"];
    }
}

- (void)switchEyeCareWithWindowMode:(BOOL)on
{
    // 切换的具体实现
    
    // 将状态写入设置
    [[NSUserDefaults standardUserDefaults] setBool:on forKey:kEyeCareModeStatusKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    BMWeakSelf
    if (on)
    {
        // 记录上一个keywindow
        self.previousKeyWindow = [UIApplication sharedApplication].keyWindow;
        
        [self makeSkinCoverWindow];
        // 显示出来
        [self.skinCoverWindow makeKeyWindow];
        self.skinCoverWindow.hidden = NO;
        
        // 出现动画
        YSBasicAnimation *opacityAnimation = [YSBasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.fromValue = @(0);
        opacityAnimation.toValue = @(1);
        opacityAnimation.duration = kAnimationDuration;
        opacityAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        opacityAnimation.fillMode = kCAFillModeForwards;
        opacityAnimation.removedOnCompletion = YES;
        
        opacityAnimation.animationDidStopBlock = ^(CAAnimation * _Nonnull anim, BOOL flag) {
            // 把key还给之前的window
            [weakSelf.previousKeyWindow makeKeyWindow];
        };
        
        [self.skinCoverWindow.layer addAnimation:opacityAnimation forKey:@"showAnimation"];
    }
    else
    {
        if ([[UIApplication sharedApplication].windows containsObject:self.skinCoverWindow])
        {
            // 隐藏skinCoverWindow
            // 消失动画
            YSBasicAnimation *opacityAnimation = [YSBasicAnimation animationWithKeyPath:@"opacity"];
            opacityAnimation.fromValue = @(1);
            opacityAnimation.toValue = @(0);
            opacityAnimation.duration = kAnimationDuration;
            opacityAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            opacityAnimation.fillMode = kCAFillModeForwards;
            opacityAnimation.removedOnCompletion = YES;
            opacityAnimation.animationDidStopBlock = ^(CAAnimation * _Nonnull anim, BOOL flag) {
                [weakSelf.previousKeyWindow makeKeyWindow];
                weakSelf.skinCoverWindow = nil;
                weakSelf.previousKeyWindow = nil;
            };
            
            [self.skinCoverWindow makeKeyWindow];
            [self.skinCoverWindow.layer addAnimation:opacityAnimation forKey:@"hideAnimation"];
        }
        else
        {
            NSAssert(NO, @"Error:关闭护眼模式的时windows没有找到WESkinCoverWindow！！");
        }
    }
}

//直接使用keyWindow
- (void)switchEyeCareMode:(BOOL)on
{
    // 切换的具体实现
    // 将状态写入设置
    [[NSUserDefaults standardUserDefaults] setBool:on forKey:kEyeCareModeStatusKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (on)
    {
        // 显示出来
        UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
        self.eyeMaskView.alpha = 1.0f;
        keyWindow.maskView = self.eyeMaskView;
        
        [UIView animateWithDuration:kAnimationDuration animations:^{
            self.eyeMaskView.alpha = 0.5f;
        } completion:^(BOOL finished) {
            
        }];
    }
    else
    {
        // 隐藏skinCoverWindow
        // 消失动画
        self.eyeMaskView.alpha = 0.5f;
        UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
        [UIView animateWithDuration:kAnimationDuration animations:^{
            self.eyeMaskView.alpha = 1.0f;
        } completion:^(BOOL finished) {
            keyWindow.maskView = nil;
        }];
    }
}

@end
