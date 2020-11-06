//
//  UIAlertController+SCAlertAutorotate.m
//  YSLive
//
//  Created by 马迪 on 2019/11/12.
//  Copyright © 2019 YS. All rights reserved.
//

#import "UIAlertController+SCAlertAutorotate.h"
#import <objc/runtime.h>
#if YSSDK
#import "YSSDKManager.h"
#else
#import "AppDelegate.h"
#endif
//#import <AppKit/AppKit.h>


@implementation UIAlertController (SCAlertAutorotate)

- (BOOL)sc_Portrait
{
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj boolValue] : NO;
}

- (void)setSc_Portrait:(BOOL)portrait
{
    objc_setAssociatedObject(self, @selector(sc_Portrait), @(portrait), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
    if (self.sc_Portrait)
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
    if (self.sc_Portrait)
    {
        return UIInterfaceOrientationPortrait;
    }
    else
    {
        return UIInterfaceOrientationLandscapeRight;
    }
}

@end
