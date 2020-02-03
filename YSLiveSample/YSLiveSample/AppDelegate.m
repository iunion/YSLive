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
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    YSNavigationController *nav = [[YSNavigationController alloc] initWithRootViewController:[[YSLoginVC alloc] init]];
    
    self.window.rootViewController = nav;
    
    return YES;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskAll;
}


@end
