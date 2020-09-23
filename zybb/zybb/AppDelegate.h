//
//  AppDelegate.h
//  zybb
//
//  Created by fzxm on 2020/9/22.
//

#import <UIKit/UIKit.h>
#define GetAppDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (assign, nonatomic) BOOL allowRotation;


- (void)logoutOnlineSchool;

@end

