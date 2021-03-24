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

@property (nonatomic, strong) UIWindow *window;

/// 是否使用allowRotation控制转屏 YES时需要修改info.plist的方向设置，只保留竖屏；NO时根据使用使用的转屏方向修改info.plist设置所有需要的方向
@property (nonatomic, assign) BOOL useAllowRotation;
@property (nonatomic, assign) BOOL allowRotation;

/// 小班课是否可转屏，支持左右转屏    默认： YES
@property (nonatomic, assign) BOOL classCanRotation;

- (void)logoutOnlineSchool;

@end

