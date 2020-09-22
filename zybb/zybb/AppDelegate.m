//
//  AppDelegate.m
//  zybb
//
//  Created by fzxm on 2020/9/22.
//

#import "AppDelegate.h"
#import "ViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
//    NSURL *url = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
    
    //NSString *cx = [[NSString alloc] initWithCString:YSRoomSDKVersionString];
    
//    BMNavigationController *nav;
////    if ([UIDevice bm_isiPad])
////    {
////        UIViewController *vc = [[UIViewController alloc] init];
////        nav = [[BMNavigationController alloc] initWithRootViewController:vc];
////    }
////    else
//    {
//        YSLoginVC *vc = [[YSLoginVC alloc] initWithLoginURL:url];
//        nav = [[BMNavigationController alloc] initWithRootViewController:vc];
//        nav.popOnBackButtonHandler = [YSSuperVC getPopOnBackButtonHandler];
//        self.loginVC = vc;
//
//        //nav.modalPresentationStyle = UIModalPresentationFullScreen;
//    }
    ViewController * vc = [[ViewController alloc] init];
    self.window.rootViewController = vc;
    
    
    
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
