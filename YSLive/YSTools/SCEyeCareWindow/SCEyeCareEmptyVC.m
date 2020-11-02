//
//  SCEyeCareEmptyVC.m
//  YSAll
//
//  Created by jiang deng on 2019/12/27.
//  Copyright © 2019 YS. All rights reserved.
//

#import "SCEyeCareEmptyVC.h"
#if YSSDK
#import "YSSDKManager.h"
#else
#import "AppDelegate.h"
#endif

@interface SCEyeCareEmptyVC ()

@end

@implementation SCEyeCareEmptyVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.modalPresentationStyle = UIModalPresentationCurrentContext;
//    self.providesPresentationContextTransitionStyle = YES;
//    self.definesPresentationContext = YES;
    
    self.view.backgroundColor = [UIColor clearColor];
    self.view.userInteractionEnabled = NO;
}

- (BOOL)prefersStatusBarHidden
{
    return !self.showStatusBar;
}

#pragma mark 横竖屏

/// 1.决定当前界面是否开启自动转屏，如果返回NO，后面两个方法也不会被调用，只是会支持默认的方向
- (BOOL)shouldAutorotate
{
#if YSSDK
    if ([YSSDKManager sharedInstance].useAppDelegateAllowRotation)
    {
        return NO;
    }
#else
    if (GetAppDelegate.useAllowRotation)
    {
        return NO;
    }
#endif
    
    return YES;
}

/// 2.返回支持的旋转方向
/// iPhone设备上，默认返回值UIInterfaceOrientationMaskAllButUpSideDwon
/// iPad设备上，默认返回值是UIInterfaceOrientationMaskAll
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (self.isRientationPortrait)
    {
        return UIInterfaceOrientationMaskPortrait;
    }
    else
    {
        return UIInterfaceOrientationMaskLandscape;
    }
}

/// 3.返回进入界面默认显示方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    if (self.isRientationPortrait)
    {
        return UIInterfaceOrientationPortrait;
    }
    else
    {
        return UIInterfaceOrientationLandscapeRight;
    }
}


@end
