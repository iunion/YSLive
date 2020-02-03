//
//  UIAlertController+SCAlertAutorotate.m
//  YSLive
//
//  Created by 马迪 on 2019/11/12.
//  Copyright © 2019 YS. All rights reserved.
//

#import "UIAlertController+SCAlertAutorotate.h"

//#import <AppKit/AppKit.h>


@implementation UIAlertController (SCAlertAutorotate)

#pragma mark 横竖屏

/// 1.决定当前界面是否开启自动转屏，如果返回NO，后面两个方法也不会被调用，只是会支持默认的方向
- (BOOL)shouldAutorotate
{
    return NO;
}

/// 2.返回支持的旋转方向
/// iPad设备上，默认返回值UIInterfaceOrientationMaskAllButUpSideDwon
/// iPad设备上，默认返回值是UIInterfaceOrientationMaskAll
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

/// 3.返回进入界面默认显示方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
}

@end
