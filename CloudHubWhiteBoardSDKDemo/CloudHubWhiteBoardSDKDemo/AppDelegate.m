//
//  AppDelegate.m
//  YSLogin
//
//

#import "AppDelegate.h"
#import "CHLoginVC.h"
#import "CHNavigationController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.allowRotation = NO;

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    CHNavigationController *nav = [[CHNavigationController alloc] initWithRootViewController:[[CHLoginVC alloc] init]];
    
    self.window.rootViewController = nav;
    
    return YES;
}

/// 强制应用只能响应竖屏
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if (self.allowRotation)
    {
        //return UIInterfaceOrientationMaskAll;
        return UIInterfaceOrientationMaskLandscapeRight;
    }
    else
    {
        return UIInterfaceOrientationMaskPortrait;
    }
}

@end
