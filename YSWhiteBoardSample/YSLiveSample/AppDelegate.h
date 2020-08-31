//
//  AppDelegate.h
//  YSLogin
//
//  Created by fzxm on 2019/11/26.
//  Copyright © 2019 ysxl. All rights reserved.
//

#import <UIKit/UIKit.h>

#define GetAppDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (assign, nonatomic) BOOL allowRotation;

@end

