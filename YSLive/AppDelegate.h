//
//  AppDelegate.h
//  YSLive
//
//  Created by jiang deng on 2019/10/11.
//  Copyright © 2019 FS. All rights reserved.
//

#import <UIKit/UIKit.h>

#define GetAppDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (assign, nonatomic) BOOL allowRotation;

- (void)logOut;

@end

