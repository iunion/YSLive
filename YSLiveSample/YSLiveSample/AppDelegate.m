//
//  AppDelegate.m
//  YSLogin
//
//  Created by fzxm on 2019/11/26.
//  Copyright © 2019 ysxl. All rights reserved.
//

#import "AppDelegate.h"
#import "YSLoginVC.h"
#import "YSNavigationController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.useAllowRotation = NO;
    self.allowRotation = NO;
    
    self.classCanRotation = YES;

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    YSNavigationController *nav = [[YSNavigationController alloc] initWithRootViewController:[[YSLoginVC alloc] init]];
    
    self.window.rootViewController = nav;
    
    return YES;
}

/// 强制应用只能响应竖屏
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if (!self.useAllowRotation)
    {
        return UIInterfaceOrientationMaskAll;
    }
    if (self.allowRotation)
    {
        //return UIInterfaceOrientationMaskAll;
        if (self.classCanRotation)
        {
            return UIInterfaceOrientationMaskLandscape;
        }
        else
        {
            return UIInterfaceOrientationMaskLandscapeRight;
        }
    }
    else
    {
        return UIInterfaceOrientationMaskPortrait;
    }
}

@end
