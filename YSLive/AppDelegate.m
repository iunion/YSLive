//
//  AppDelegate.m
//  YSLive
//
//  Created by jiang deng on 2019/10/11.
//  Copyright © 2019 FS. All rights reserved.
//

#import "AppDelegate.h"
//#import <BMKit/BMNavigationController.h>
 
#if USE_TEST_HELP
#import "YSTestHelp.h"
#endif

#import "YSLoginVC.h"
#import "YSCoreStatus.h" //网络状态

#define Ues_Bugly   1

#ifdef YSCUSTOMIZED_WSKJ
#undef Ues_Bugly
#define Ues_Bugly   0
#endif

#if Ues_Bugly
#import <Bugly/Bugly.h>
#endif

@interface AppDelegate ()
<
    YSCoreNetWorkStatusProtocol
>

@property (nonatomic, weak) YSLoginVC *loginVC;

@end

@implementation AppDelegate

- (void)dealloc
{
    [YSCoreStatus endMonitorNetwork:self];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [YSCoreStatus beginMonitorNetwork:self];
    [[UIButton appearance] setExclusiveTouch:YES];
    self.useAllowRotation = NO;
    self.allowRotation = NO;
    
    self.classCanRotation = YES;
    
#if Ues_Bugly
    [Bugly startWithAppId:@"55ff7e6968"];
#endif
    
#if USE_TEST_HELP
    [YSTestHelp sharedInstance];
    self.window = [[BMConsoleWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //[[BMConsole sharedConsole] handleConsoleCommand:@"mn"];
#else
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
#endif

    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    NSURL *url = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
    
    //NSString *cx = [[NSString alloc] initWithCString:YSRoomSDKVersionString];
    
    BMNavigationController *nav;
    YSLoginVC *vc = [[YSLoginVC alloc] initWithLoginURL:url];
    nav = [[BMNavigationController alloc] initWithRootViewController:vc];
    nav.popOnBackButtonHandler = [YSSuperVC getPopOnBackButtonHandler];
    self.loginVC = vc;
    
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

//- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler
//{
//    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
//        NSURL *webUrl = userActivity.webpageURL;
//        if ([webUrl.host isEqualToString:@"demo.roadofcloud.com"])
//        {
//
//        }
//        else
//        {
//            [[UIApplication sharedApplication] openURL:webUrl];
//        }
//    }
//    return YES;
//}

- (BOOL)application:(UIApplication*)application shouldAllowExtensionPointIdentifier:(nonnull UIApplicationExtensionPointIdentifier)extensionPointIdentifier
{
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    /*
     直播: enterlive
     
     会议: entermeeting
     
     小班课: enterclassroom    这个是网页跳转APP的scheme头
     */

    BMNavigationController *nav = (BMNavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    if (![nav isKindOfClass:[BMNavigationController class]])
    {
        return NO;
    }
    YSLoginVC *loginVC = (YSLoginVC *)nav.topViewController;
    if (![loginVC isKindOfClass:[YSLoginVC class]])
    {
        return NO;
    }

    if ([loginVC.loginUrl bm_isNotEmpty])
    {
        return NO;
    }

    NSDictionary *dic = [YSLiveManager resolveJoinRoomParamsWithUrl:url];
    if (![dic bm_isNotEmptyDictionary])
    {
        return NO;
    }

    if ([dic bm_containsObjectForKey:@"roomid"])
    {
        NSString *roomId = [dic bm_stringTrimForKey:@"roomid"];
        if ([roomId bm_isNotEmpty])
        {
            [loginVC joinRoomWithRoomId:roomId];
        }
    }
    else
    {
        [loginVC joinRoomWithRoomParams:dic userParams:nil];
    }

    return YES;
}

#else

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation
{
    NSDictionary *dic = [YSLiveManager resolveJoinRoomParamsWithUrl:url];
    if (![dic bm_isNotEmptyDictionary])
    {
        return NO;
    }
    
    BMNavigationController *nav = (BMNavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    if (![nav isKindOfClass:[BMNavigationController class]])
    {
        return NO;
    }
    YSLoginVC *loginVC = (YSLoginVC *)nav.topViewController;
    if (![loginVC isKindOfClass:[YSLoginVC class]])
    {
        return NO;
    }
    
    if ([dic bm_containsObjectForKey:@"roomid"])
    {
        NSString *roomId = [dic bm_stringTrimForKey:@"roomid"];
        if ([roomId bm_isNotEmpty])
        {
            [loginVC joinRoomWithRoomId:roomId];
        }
    }
    else
    {
        [loginVC joinRoomWithRoomParams:dic userParams:nil];
    }

    return YES;
}

#endif

#pragma mark -
#pragma mark BITCrashManagerDelegate
#if 0
- (BOOL)didCrashInLastSessionOnStartup
{
    return ([[BITHockeyManager sharedHockeyManager].crashManager didCrashInLastSession] &&
            [[BITHockeyManager sharedHockeyManager].crashManager timeIntervalCrashInLastSessionOccurred] < 5);
}

//crashManagerWillCancelSendingCrashReport
- (void)crashManagerWillCancelSendingCrashReport:(BITCrashManager *)__unused crashManager
{
    if ([self didCrashInLastSessionOnStartup])
    {
        
    }
}

//crashManagerWillCancelSendingCrashReport
- (void)crashManager:(BITCrashManager *)__unused crashManager didFailWithError:(NSError *)__unused error
{
    if ([self didCrashInLastSessionOnStartup])
    {
        
    }
}

//crashManagerWillCancelSendingCrashReport
- (void)crashManagerDidFinishSendingCrashReport:(BITCrashManager *)__unused crashManager
{
    if ([self didCrashInLastSessionOnStartup])
    {
        
    }
}
#endif

#pragma mark - network status

- (void)coreNetworkChanged:(NSNotification *)noti
{
    NSDictionary *userDic = noti.userInfo;
    
    BMLog(@"网络环境: %@", [userDic bm_stringForKey:@"currentStatusString"]);
    BMLog(@"网络运营商: %@", [userDic bm_stringForKey:@"currentBrandName"]);
}


- (void)logoutOnlineSchool
{
    if (self.loginVC)
    {
        [self.loginVC logoutOnlineSchool];
    }
}

@end
