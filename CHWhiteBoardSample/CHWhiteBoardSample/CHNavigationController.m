//
//  CHNavigationController.m
//  CHLiveSample
//
//  Created by jiang deng on 2019/12/23.
//  Copyright © 2019 ysxl. All rights reserved.
//

#import "CHNavigationController.h"

@implementation CHNavigationController

#pragma mark -
#pragma mark 横竖屏

/// 1.决定当前界面是否开启自动转屏
- (BOOL)shouldAutorotate
{
    //return [self.visibleViewController shouldAutorotate];
    return [self.topViewController shouldAutorotate];
}

/// 2.返回支持的旋转方向
/// iPhone设备上，默认返回值UIInterfaceOrientationMaskAllButUpSideDwon
/// iPad设备上，默认返回值是UIInterfaceOrientationMaskAll
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [self.topViewController supportedInterfaceOrientations];
}

/// 3.返回进入界面默认显示方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [self.topViewController preferredInterfaceOrientationForPresentation];
}

@end
